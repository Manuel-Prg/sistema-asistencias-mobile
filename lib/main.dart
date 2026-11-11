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
import 'views/auth/login_view.dart';
import 'views/navigation/main_navigation_view.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar localización en español (México)
  await initializeDateFormatting('es_MX', null);

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
    if (authState.isLoading && !authState.isInitialCheckDone) {
      return Scaffold(
        backgroundColor: AppColors.limestoneGround,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(12),
                child: Image.asset(
                  'assets/logo/logo_remove_background.png',
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.water_drop, size: 40, color: AppColors.primary),
                ),
              ),
              const SizedBox(height: 20),
              const CircularProgressIndicator(color: AppColors.primary),
              const SizedBox(height: 16),
              const Text(
                'Iniciando Sistema de Asistencia...',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.slateMuted,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (authState.isAuthenticated) {
      return const MainNavigationView();
    }

    return const LoginView();
  }
}
