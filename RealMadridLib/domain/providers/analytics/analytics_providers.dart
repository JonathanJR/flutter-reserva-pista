import 'package:rm_app_flutter_core/application/startup/providers/providers.dart';
import 'package:rm_app_flutter_core/core/notifiers/language_notifier.dart';
import 'package:rm_app_flutter_core/state_management.dart';
import 'package:rm_app_flutter_fan/data/repository/analytic/adobe_analytic_repository_impl.dart';

final analyticsRepositoryProvider = Provider<AdobeAnalyticRepositoryImpl>(
  (ref) {
    final language = ref.watch(languageNotifierProvider);
    final oneTrustManager = ref.watch(oneTrustProvider);
    return AdobeAnalyticRepositoryImpl(language, oneTrustManager);
  },
);
