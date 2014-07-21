var http = require('http');
var nodemailer = require('nodemailer');

var transport = nodemailer.createTransport('SMTP', {
  host: 'localhost'
});

function sendMail(recipient, subject, content, callback) {
  transport.sendMail({
    from: 'eLingua <' + config.mailingAddress + '>',
    to: recipient,
    subject: subject,
    html: content
  }, callback);
};

var config = require('./config.js').config;

http.createServer(function (request, response) {
  if (request.type == 'POST') {

  } else {
    response.code = 400;
    response.end();
  }
}).listen(8081);