import 'dart:html';
import 'package:googleapis_auth/auth_browser.dart';
import 'package:googleapis/oauth2/v2.dart' as oauth;
import 'package:googleapis/drive/v2.dart' as drive;
import 'package:google_oauth2_client/google_oauth2_browser.dart';
import 'package:google_oauth2_jwt/jwt.dart' as jwt;
import 'package:http/browser_client.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

DivElement loggedInDiv;
ButtonElement loginButton;

var id = new ClientId(
    "392928056442-j1tfq9a0tko6o3ld4e3ptv2k6gtuo8ri.apps.googleusercontent.com",
    null);
var scopes = [
  oauth.Oauth2Api.UserinfoEmailScope, oauth.Oauth2Api.UserinfoProfileScope];

main() async {
  loggedInDiv = querySelector("#loggedIn");
  loginButton = querySelector("#login");

  BrowserOAuth2Flow flow = await createImplicitBrowserFlow(id, scopes);
  HybridFlowResult result;

  loginButton.onClick.listen((_) async {
    result = await flow.runHybridFlow();
    login(result);
  });
}

login(HybridFlowResult flowResult) async {
  BrowserClient httpClient = new BrowserClient();
  var response = await httpClient.post(
      'http://localhost:8081/signIn?auth=${flowResult.authorizationCode}');

  Map json = JSON.decode(response.body);

  loggedInDiv..append(new ParagraphElement()
    ..text = 'Welcome ${json['firstName']} ${json['lastName']}')..append(
      new ImageElement(src: json['pictureUrl']));

  loginButton.classes.toggle('hidden');
  loggedInDiv.classes.toggle('hidden');
}
