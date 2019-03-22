import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provide/provide.dart';
import 'package:apns/app/models/environment.dart';
import 'package:apns/app/models/certificate.dart';
import 'app/app.dart';

void main() {
  debugDefaultTargetPlatformOverride = TargetPlatform.fuchsia;

  final providers = Providers()
  ..provide(Provider.value(Environment()))
  ..provide(Provider.value(Certificate()));


  runApp(ProviderNode(
    providers: providers,
    child: App(),
  ));
}
