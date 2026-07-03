import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/logging/crash_reporting.dart';
import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/touch/presentation/controllers/touch_controller.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    await configureCrashReporting();
    final preferences = await SharedPreferences.getInstance();

    runApp(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(preferences),
        ],
        child: const TouchApp(),
      ),
    );
  } catch (error) {
    runApp(BootstrapErrorApp(error: error));
  }
}

class TouchApp extends ConsumerWidget {
  const TouchApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return CupertinoApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Touch',
      theme: AppTheme.cupertinoTheme(),
      routerConfig: router,
      builder: (context, child) {
        ErrorWidget.builder = (details) {
          if (kDebugMode) {
            return ErrorWidget(details.exception);
          }
          return const SizedBox.shrink();
        };

        return child ?? const SizedBox.shrink();
      },
    );
  }
}

class BootstrapErrorApp extends StatelessWidget {
  const BootstrapErrorApp({
    required this.error,
    super.key,
  });

  final Object error;

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      debugShowCheckedModeBanner: false,
      title: 'Touch',
      theme: AppTheme.cupertinoTheme(),
      home: CupertinoPageScaffold(
        backgroundColor: CupertinoColors.systemBackground,
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    CupertinoIcons.exclamationmark_triangle,
                    size: 40,
                    color: CupertinoColors.systemRed,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Touch cannot start on this platform.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    error.toString(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: CupertinoColors.secondaryLabel,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
