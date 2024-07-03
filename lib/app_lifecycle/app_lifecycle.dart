import 'package:flutter/widgets.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';

typedef AppLifecycleStateNotifier = ValueNotifier<AppLifecycleState>;

class AppLifecycleObserver extends StatefulWidget {
  final Widget child;

  const AppLifecycleObserver({
    super.key,
    required this.child,
  });

  @override
  State<AppLifecycleObserver> createState() => _AppLifecycleObserverState();
}

class _AppLifecycleObserverState extends State<AppLifecycleObserver> {
  static final log = Logger('AppLifeCycleObserver');
  late final AppLifecycleListener appLifecycleListener;

  final ValueNotifier<AppLifecycleState> lifecycleListenable =
      ValueNotifier(AppLifecycleState.inactive);

  @override
  void initState() {
    super.initState();
    appLifecycleListener = AppLifecycleListener(
      onStateChange: (s) => lifecycleListenable.value = s,
    );
    log.info('Subscribed to app lifecycle updates');
  }

  @override
  void dispose() {
    appLifecycleListener.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InheritedProvider<AppLifecycleStateNotifier>.value(
      value: lifecycleListenable,
      child: widget.child,
    );
  }
}
