import 'package:flutter/services.dart';

class APNsSystemPlugin {

  final _channel = MethodChannel('com.Arror.APNs.SystemAction');

  void performClose() {
    _channel.invokeMethod('close').then((_) {}).catchError((_) {});
  }

  void performMiniaturize() {
    _channel.invokeMethod('minimize').then((_) {}).catchError((_) {});
  }
}