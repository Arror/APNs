
import 'package:flutter/widgets.dart';

abstract class BLocBase {
  void dispose();
}

class BLocProvider<T extends BLocBase> extends StatefulWidget {

  final T bloc;
  final Widget child;

  BLocProvider({
    Key key, 
    @required this.bloc, 
    @required this.child
  }) : super(key: key);

  @override
  _BLocProviderState createState() => _BLocProviderState();

  static T of<T extends BLocBase>(BuildContext context){
    final type = _typeOf<BLocProvider<T>>();
    BLocProvider<T> provider = context.ancestorWidgetOfExactType(type);
    return provider.bloc;
  }

  static Type _typeOf<T>() => T;
}

class _BLocProviderState<T extends BLocBase> extends State<BLocProvider<T>> {

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