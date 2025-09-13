import 'package:rm_app_flutter_core/application/startup/providers/providers.dart';
import 'package:rm_app_flutter_core/state_management.dart';
import 'package:rm_app_flutter_fan/core/listener/one_trust_manager_listener.dart';

final oneTrustManagerListenerProvider = Provider<OneTrustManagerListenerImpl>(
  (ref) {
    final oneTrustManager = ref.watch(oneTrustProvider);
    final listener = OneTrustManagerListenerImpl(oneTrustManager);

    listener.init();
    ref.onDispose(() {
      listener.dispose();
    });
    
    return listener;
  },
);
