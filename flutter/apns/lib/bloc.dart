
import 'package:flutter/widgets.dart';

abstract class BLoCBase {
  void dispose();
}

class BLoCProvider<T extends BLoCBase> extends StatefulWidget {

  final T bloc;
  final Widget child;

  BLoCProvider({
    Key key, 
    @required this.bloc, 
    @required this.child
  }) : super(key: key);

  @override
  _BLoCProviderState createState() => _BLoCProviderState();

  static T of<T extends BLoCBase>(BuildContext context){
    final type = _typeOf<BLoCProvider<T>>();
    BLoCProvider<T> provider = context.ancestorWidgetOfExactType(type);
    return provider.bloc;
  }

  static Type _typeOf<T>() => T;
}

class _BLoCProviderState<T extends BLoCBase> extends State<BLoCProvider<T>> {

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  @override
  void dispose() {
    widget.bloc.dispose();
    super.dispose();
  }
}