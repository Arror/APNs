import 'package:apns/model/server.dart';
import 'package:apns/model/application.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provide/provide.dart';
import 'app/app.dart';

void main() {
  debugDefaultTargetPlatformOverride = TargetPlatform.iOS;

  final providers = Providers()
    ..provide(Provider.value(Server('', '', '')))
    ..provide(Provider.value(ApplicationController()));

  runApp(ProviderNode(
    providers: providers,
    child: App(),
  ));
}
