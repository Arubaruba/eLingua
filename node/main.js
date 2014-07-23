var http = require('http');
var nodemailer = require('nodemailer');
var sendmailTransport = require('nodemailer-sendmail-transport');
var crypto = require('crypto');
var fs = require('fs');

var auth = require('./auth');
var config = require('./config');

var users = require('felix-couchdb').createClient(5984, 'localhost', auth.couchDb.username, auth.couchDb.password).db('_users');


var transport = nodemailer.createTransport(sendmailTransport());

function sendMail(recipient, subject, content, callback) {
  transport.sendMail({
    from: config.mailFrom,
    to: recipient,
    subject: subject,
    html: content
  }, callback);
}

var emailContent = fs.readFileSync(__dirname + '/email_content.html', {encoding: 'utf8'});

http.createServer(function (request, response) {
  if (request.method != 'POST') {

    response.statusCode = 400;
    response.end('Expected POST request type, got: ' + request.method);

  } else {

    var data = '';

    request.on('data', function(result) {
      if (data.length > 1000) {
        response.statusCode = 400;
        response.end('POST request too large');
      } else {
        data += result;
      }
    });

    request.on('end', function() {
      var content = JSON.parse(data);
      if (!content) {
        response.statusCode = 400;
        response.end('Invalid JSON');
      } else {
        users.view('generic', 'users_by_name', {key: content['email']}, function(err, result){
          if (err || !result) {
            response.statusCode = 500;
            response.end('Database Error - Unable to search users');
          } else if (result['rows'].length < 1) {
            response.statusCode = 404;
            response.end('Unknown email address');
          } else {
            var document = result['rows'][0]['value'];
            if (!document['password_reset_tokens']) {
              document['password_reset_tokens'] = [];
            }
            crypto.randomBytes(64, function(err, bytes) {
              if(err) {
                response.statusCode = 500;
                response.end('Unable to Generate Random Token');
              } else {
                var token = bytes.toString('hex');
                document['password_reset_tokens'].push({
                  token: token,
                  created: Date.now()
                });
                users.saveDoc(document['_id'], document, function(err) {
                  if (err) {
                    response.statusCode = 500;
                    response.end('Unable to save modified User Document');
                  } else {
                    sendMail(document['name'], 'Password Reset Link', emailContent.replace(/{link}/g, config.resetUrl + token), function(err){
                      if (err) {
                        response.statusCode = 500;
                        response.end('Unable to send Email');
                      } else {
                        response.statusCode = 200;
                        response.end('Success! Token created and Email sent');
                      }
                    });
                  }
                });
              }
            });
          }
        });
      }
    });
  }
}).listen(config.port);