import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;
import 'core/constants/app_colors.dart';
import 'core/constants/app_constants.dart';
import 'core/constants/supabase_config.dart';
import 'core/theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/color_theme_provider.dart';
import 'providers/theme_provider.dart';
import 'services/report_notification_service.dart';
import 'views/auth/forgot_password_view.dart';
import 'views/auth/login_view.dart';
import 'views/common/app_splash_loading_view.dart';
import 'views/navigation/main_navigation_view.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar localización en español (México)
  await initializeDateFormatting('es_MX', null);

  // Inicializar notificaciones locales y zona horaria (Villahermosa, Tabasco UTC-6)
  await ReportNotificationService.initialize();

  // Inicializar Supabase
  await Supabase.initialize(
    url: SupabaseConfig.url,
    // ignore: deprecated_member_use
    anonKey: SupabaseConfig.anonKey,
  );

  runApp(
    const ProviderScope(
      child: SistemaAsistenciaApp(),
    ),
  );
}

class SistemaAsistenciaApp extends ConsumerWidget {
  const SistemaAsistenciaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final colorPalette = ref.watch(colorThemeProvider);
    final authState = ref.watch(authProvider);

    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.getThemeWithPalette(
        AppTheme.lightTheme,
        colorPalette,
        isDark: false,
      ),
      darkTheme: AppTheme.getThemeWithPalette(
        AppTheme.darkTheme,
        colorPalette,
        isDark: true,
      ),
      themeMode: themeMode,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('es', 'MX'),
        Locale('es', ''),
      ],
      home: _buildHome(authState),
    );
  }

  Widget _buildHome(AppAuthState authState) {
    final Widget targetWidget;
    final String targetKey;

    if (authState.isLoading && !authState.isInitialCheckDone) {
      targetWidget = const AppSplashLoadingView();
      targetKey = 'splash';
    } else if (authState.isPasswordRecovery) {
      targetWidget = ForgotPasswordView(
        isDeepLinkRecovery: true,
        initialEmail: authState.user?.email,
      );
      targetKey = 'password_recovery';
    } else if (authState.isAuthenticated) {
      targetWidget = const MainNavigationView();
      targetKey = 'main_navigation';
    } else {
      targetWidget = const LoginView();
      targetKey = 'login';
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 550),
      switchInCurve: Curves.easeInOutCubic,
      switchOutCurve: Curves.easeInOutCubic,
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
      child: KeyedSubtree(
        key: ValueKey(targetKey),
        child: targetWidget,
      ),
    );
  }
}
