part of elingua;

@Controller(selector: '[password-reset]', publishAs: 'ctrl')
class PasswordReset {
  Http http;
  I18n i18n;
  Router router;
  String email, error;
  PasswordReset(this.http, this.i18n, this.router);

  sendResetLink() {
    error = null;
    http.post('/node/', JSON.encode({'email': email})).then((HttpResponse response) {
      router.gotoUrl('/');
    }).catchError((HttpResponse response) {
      if (response.status == 404) {
        error = i18n.call('Invalid Email Address');
      } else {
        error = i18n.call('Unable to send Email');
      }
    });
  }
}