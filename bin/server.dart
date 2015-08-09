// Copyright (c) 2015, <your name>. All rights reserved. Use of this source code

// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:redstone/redstone.dart' as app;
import 'package:googleapis/oauth2/v2.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:shelf/shelf.dart' as shelf;
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart' as crypto;
import 'dart:convert';
import 'dart:async';

Map<String, AccessCredentials> credentials = {};

Map<String, User> users = {};

class User {
  String id;
  String firstName;
  String lastName;
  String pictureUrl;
  String emailAddress;

  String get gravatarImageHash {
    // Url to fetch avatar : http://www.gravatar.com/avatar/HASH
    var md5 = new crypto.MD5();
    var encode = UTF8.encode(emailAddress.toLowerCase().trim());
    md5.add(encode);
    List<int> encrypted = md5.close();
    return crypto.CryptoUtils.bytesToHex(encrypted);
  }

  Map toJson() {
    var json = {};
    json['id'] = id;
    json['firstName'] = firstName;
    json['lastName'] = lastName;
    json['pictureUrl'] = 'http://gravatar.com/avatar/$gravatarImageHash';

    return json;
  }
}

@app.Route("/signIn", methods: const [app.POST], responseType: 'application/json')
Future<shelf.Response> authenticate(@app.QueryParam("auth") String authorizationCode) async {
  const _SCOPES = const [
    Oauth2Api.UserinfoProfileScope, Oauth2Api.UserinfoEmailScope];

  final _credentials = new ServiceAccountCredentials.fromJson(r'''
{
  "private_key_id": "363a9085b94a02875d06280065400165aadac5fe",
  "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEwAIBADANBgkqhkiG9w0BAQEFAASCBKowggSmAgEAAoIBAQDHW1svp5pPSlYc\nHb+Jt21D8bulYa0VSLTzkiq1vbUUxL+MgA/cKlzElF2HkloIbgeUVvgt6nXU12K5\nIA0nzE9ZxGLNdIlp9s10JcJliRkaWFOmu6rp8C9A6cpZ561EGDF3NzrcjWjz4X01\nAH1K7X88FeNdmLGNqKhJ2KM8gNuoETk98Tutsv6sQvHCe0wx04pxe+tVyCIMrabx\nbsCubJ+5GVDGXSKxpSREkkH604SctQidk0ROzF2LEBfj7ICxZx/I7NwQQCIRpARY\nLBpCd8zjlVz98tGk0iPhJVnlnZ+qi/gteLgVNLGXM1Q6S22wohf07mOcj+tF6grr\n6GRfSVqvAgMBAAECggEBALoTcGproyGNPhCiR6yQlCFOGZrFL9vk8FlEvi7Csql+\n91d6FNOoisxFu4MWPIkPwm1YO/AHnxIaNCCdZQoXrp0YLCyfML/CSIS31doV/GNV\nvEatdltC/6g0T9ZY46XiexFOcNd5+lNgzhBRs6DjStZXi9BJ/Lg/i0zaM4r+r4gP\nXWdE7iOiEGfDXL4NWTeVXZYI0DUO9AzcbsJwJd/idrY5U/yzi0LGLXDBNUoBnH4V\nVY6HFRnVBPEtrmzr8G5rRCnrJxwIi5/guy30mo29gjQ8T3LqzeYf4Nmhddcuj1nO\nAhix0mnw4aygU3SIsVkqLsOdwSwmW8xNFrVPZ5gFlMkCgYEA66bEU9XbJANqSI5y\niYV8s4+mjTKacBUNlq4NkeuDbrfG4K9bHIN2PuK90sA3a63eSpzYnybEJ3Zd+AbS\nbnrTAULVmYK3e6wH9ylYbf9WJ6FQ9sOOxo3FBLdipOR1p6JU/WP2QFKXx2bQlTQt\nzkA9mt2V3xdhiOjAFYmibhAnStsCgYEA2JJF/R8Xfr/hqSa747Fr6g5dQNn1DhnB\niWK+CKG9QC94QKYRzk84yumRNwpWGOAqv76PzP9yDxe4DEI30QsEr0Tt4xWH2RAU\nVyVCyEESeJOorVwB/FAqLI2PCHNVYdTPHOAImbfcSAXQ5iIZoX2CoAL3heXCmZyE\nSYz8HT2Ddb0CgYEAlSkTPmmwc4RB4zlfYJMBEvuLlfaA8Q8ycb0sU7/6iruDBDea\n+VpxH28QbnVC30LH4PyU1XCJWt0+r79JtarDIxo18BxgncSPqjAejEnCNAWVJQ01\ns5KLMegOZYdCveAv4dBDUAW3kv0ObFMB53qcRAmcUwEOuMVyyG89RGOvK18CgYEA\nv1xgI0y5wfFiP8hN9N7sb5/Jnmf4NEFl1TM+nvnq8y/+nYEf8p/lmsXO3kdv1AMf\nQtXq0kRUUCmxIoPQNhH6TbQmTqTTqGSg1G/EFpYI8CnovWWzC3L6EOv0Go9uPkd/\nyg/bCZiAN9OLxg0TgLIaHbEBbXqa/IhkC2lby6py4jECgYEAzunHCYBX2u8ukaKZ\nZTuTgqtrB04Z71NGJSkjVw8oIkmUlVCqj3uW8BJR7pDJRSwkqPSfrYV3OvrL2EVZ\nuJ2RDYKHiTSFJmAIzoQW1KrqXJP9XaRmYVv+NYIZpEBVtS8M/D3CAgB/3E2T5f9J\nEsqbLHJTdzzjkAvejAvZReaeU6c\u003d\n-----END PRIVATE KEY-----\n",
  "client_email": "392928056442-6ep11gc2pcbg8sksvm69vpoh84sh7s9o@developer.gserviceaccount.com",
  "client_id": "392928056442-6ep11gc2pcbg8sksvm69vpoh84sh7s9o.apps.googleusercontent.com",
  "type": "service_account"
}
''');

  AutoRefreshingAuthClient client = await clientViaServiceAccount(
      _credentials, _SCOPES);

  ClientId clientId = new ClientId(
      "392928056442-j1tfq9a0tko6o3ld4e3ptv2k6gtuo8ri.apps.googleusercontent.com",
      "eksKZeDRvaX9JEdbi1WTzGaO");

  var accessCredentials = await obtainAccessCredentialsViaCodeExchange(
      client, clientId, authorizationCode);

  var newClient = autoRefreshingClient(
      clientId, accessCredentials, new http.Client());

  Oauth2Api api = new Oauth2Api(newClient);
  Userinfoplus userinfoplus = await api.userinfo.get();

  User user = new User()
    ..firstName = userinfoplus.givenName
    ..lastName = userinfoplus.familyName
    ..id = userinfoplus.id
    ..emailAddress = userinfoplus.email;

  print(JSON.encode(user));

  return new shelf.Response.ok(JSON.encode(user));
}

@app.Interceptor(r'/.*')
handleCORS() async {
  if (app.request.method != "OPTIONS") {
    await app.chain.next();
  }
  return app.response.change(headers: _createCorsHeader());
}

_createCorsHeader() => {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'PUT, GET, POST, OPTIONS, DELETE',
  'Access-Control-Allow-Headers': 'Origin, X-Requested-With, Content-Type, Accept'
};

main() {
  app.setupConsoleLog();
  app.start(port: 8081);
}