import 'package:flutter/material.dart';
import 'package:rm_app_flutter_core/core/theme/rm_paddings.dart';
import 'package:rm_app_flutter_core/state_management.dart';
import 'package:rm_app_flutter_core/presentation/common/widgets/scaffold/rm_scaffold.dart';
import 'package:rm_app_flutter_core/presentation/common/widgets/scaffold/rm_scaffold_body.dart';
import 'package:rm_app_flutter_fan/presentation/news/notifier/news_notifier.dart';

class NewsPage extends ConsumerWidget {
  const NewsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userIsLoaded = ref.read(newsNotifierProvider).isUserLogged;
    return RMScaffold(
      backgroundColor: Colors.blue,
      appBar: null,
      bodyBuilder: (_) => RMBody(
        bodyPadding: RMPaddings.horizontal24,
        topSafe: true,
        child: Text('news $userIsLoaded'),
      ),
    );
  }
}
