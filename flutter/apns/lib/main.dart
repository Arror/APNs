import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'app/app.dart';

void main() {
  debugDefaultTargetPlatformOverride =TargetPlatform.fuchsia;
  runApp(App());
}