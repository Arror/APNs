import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provide/provide.dart';
import 'app/notifiers/environment.dart';
import 'app/app.dart';

void main() {

  debugDefaultTargetPlatformOverride = TargetPlatform.fuchsia;

  final providers = Providers();
  providers
    ..provide(Provider.value(Environment()));

  runApp(ProviderNode(
    providers: providers,
    child: App(),
  ));
}
