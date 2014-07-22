var http = require('http');
var nodemailer = require('nodemailer');
var crypto = require('crypto');
var fs = require('fs');

var users = require('felix-couchdb').createClient(5987, auth.couchDb.username, auth.couchDb.password).db('_users');

var auth = require('./auth.js');
var config = require('./config.js');

var transport = nodemailer.createTransport('SMTP', {
  host: 'localhost'
});

function sendMail(recipient, subject, content, callback) {
  transport.sendMail({
    from: config.mailFrom,
    to: recipient,
    subject: subject,
    html: content
  }, callback);
}

var emailContent = fs.readFileSync('./email_content.html');

http.createServer(function (request, response) {
  if (request.type != 'POST') {

    response.code = 400;
    response.end('Expected POST request type, got: ' + request.type);
  } else {

    var data = '';

    request.on('data', function(err, result) {
      if (err) {
        response.code = 400;
        response.end('Unknown error occurred while receiving data');
      } else if (data.length > 1000) {
        response.code = 400;
        response.end('POST request too large');
      } else {
        data += result;
      }
    });

    request.on('end', function() {
      var content = JSON.parse(data);
      if (!content) {
        response.code = 400;
        response.end('Invalid JSON');
      } else {
        users.view('views', 'users_by_email', {key: content['email']}, function(err, result){
          if (err) {
            response.code = 500;
            response.end('Database Error - Unable to search users');
          } else if (!result['rows'].length < 1) {
            response.code = 404;
            response.end('Unknown email address');
          } else {
            var document = result['rows']['value'];
            if (!document['password_reset_tokens']) {
              document['password_reset_tokens'] = [];
            }
            crypto.randomBytes(64, function(err, bytes) {
              if(err) {
                response.code = 500;
                response.end('Unable to Generate Random Token');
              } else {
                var token = bytes.toString('hex');
                document['password_reset_tokens'].push({
                  token: token,
                  created: Date.now()
                });
                document.save(function(err) {
                  if (err) {
                    response.code = 500;
                    response.end('Unable to save modified User Document');
                  } else {
                    sendMail(document['name'], 'Password Reset Link', emailContent.replaceAll('{link}', config.resetUrl + token), function(err){
                      if (err) {
                        response.code = 500;
                        response.end('Unable to send Email');
                      } else {
                        response.code = 200;
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
}).listen(8081);