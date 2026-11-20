import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/glass_scaffold.dart';
import '../../core/widgets/glass_toast.dart';
import '../../providers/auth_provider.dart';
import '../../providers/security_settings_provider.dart';
import '../../services/supabase_service.dart';
import 'forgot_password/confirm_reset_step.dart';
import 'forgot_password/request_reset_step.dart';
import 'forgot_password/reset_success_step.dart';

class ForgotPasswordView extends ConsumerStatefulWidget {
  final String? initialEmail;
  final bool isDeepLinkRecovery;

  const ForgotPasswordView({
    super.key,
    this.initialEmail,
    this.isDeepLinkRecovery = false,
  });

  @override
  ConsumerState<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends ConsumerState<ForgotPasswordView> {
  late final TextEditingController _emailController;
  final _tokenController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  int _step = 0; // 0 = Solicitar código, 1 = Código/nueva clave, 2 = Éxito

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.initialEmail ?? '');
    if (widget.isDeepLinkRecovery) {
      _step = 1;
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _tokenController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSendResetEmail() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      AppGlassToast.show(
        context,
        message: 'Por favor ingresa un correo electrónico válido.',
        type: GlassToastType.warning,
      );
      return;
    }

    setState(() => _isLoading = true);
    FocusScope.of(context).unfocus();

    final success = await ref.read(authProvider.notifier).resetPassword(email);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      AppGlassToast.show(
        context,
        message: 'Código enviado a $email. Revisa tu correo.',
        type: GlassToastType.success,
      );
      setState(() => _step = 1);
    } else {
      AppGlassToast.show(
        context,
        message: 'No se pudo enviar el correo. Verifica que esté registrado.',
        type: GlassToastType.error,
      );
    }
  }

  Future<void> _handleConfirmReset() async {
    final email = _emailController.text.trim();
    final token = _tokenController.text.trim();
    final newPassword = _newPasswordController.text;
    final confirmPassword = _confirmPasswordController.text;

    final authState = ref.read(authProvider);
    final hasActiveSession = SupabaseService.client.auth.currentSession != null;
    final isRecovery =
        widget.isDeepLinkRecovery ||
        authState.isPasswordRecovery ||
        hasActiveSession;

    if (!isRecovery && token.isEmpty) {
      AppGlassToast.show(
        context,
        message: 'Por favor ingresa el código que recibiste en tu correo.',
        type: GlassToastType.warning,
      );
      return;
    }

    if (newPassword.length < 6) {
      AppGlassToast.show(
        context,
        message: 'La contraseña debe tener al menos 6 caracteres.',
        type: GlassToastType.warning,
      );
      return;
    }

    if (newPassword != confirmPassword) {
      AppGlassToast.show(
        context,
        message: 'Las contraseñas no coinciden.',
        type: GlassToastType.warning,
      );
      return;
    }

    setState(() => _isLoading = true);
    FocusScope.of(context).unfocus();

    final result = await ref
        .read(authProvider.notifier)
        .confirmPasswordReset(
          email: email,
          token: token,
          newPassword: newPassword,
          isDeepLinkRecovery: isRecovery,
        );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result.success) {
      await ref
          .read(securitySettingsProvider.notifier)
          .onPasswordReset(email: email, newPassword: newPassword);
      setState(() => _step = 2);
    } else {
      AppGlassToast.show(
        context,
        message: result.error ?? 'Código incorrecto o expirado.',
        type: GlassToastType.error,
      );
    }
  }

  void _exitRecovery() {
    ref.read(authProvider.notifier).cancelPasswordRecovery();
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;

    final authState = ref.watch(authProvider);
    final hasActiveSession = SupabaseService.client.auth.currentSession != null;
    final isRecovery =
        widget.isDeepLinkRecovery ||
        authState.isPasswordRecovery ||
        hasActiveSession;

    if (isRecovery && _step == 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _step == 0) {
          setState(() => _step = 1);
        }
      });
    }

    final sessionEmail =
        authState.user?.email ??
        SupabaseService.client.auth.currentSession?.user.email;
    if (sessionEmail != null &&
        sessionEmail.isNotEmpty &&
        _emailController.text.isEmpty) {
      _emailController.text = sessionEmail;
    }

    return GlassScaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: isDark ? AppColors.darkTextPrimary : primaryColor,
            size: 20,
          ),
          onPressed: () {
            if (isRecovery) {
              _exitRecovery();
              return;
            }
            if (_step == 1) {
              setState(() => _step = 0);
            } else if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
          },
        ),
        title: Text(
          _step == 1 ? 'Nueva Contraseña' : 'Recuperar Cuenta',
          style: TextStyle(
            fontFamily: AppTheme.brandFont,
            fontWeight: FontWeight.w800,
            fontSize: 20,
            color: isDark ? AppColors.darkTextPrimary : primaryColor,
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, animation) => FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.04, 0),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              ),
              child: _step == 0
                  ? RequestResetStep(
                      key: const ValueKey('step_0'),
                      emailController: _emailController,
                      isLoading: _isLoading,
                      isDark: isDark,
                      primaryColor: primaryColor,
                      onSendEmail: _handleSendResetEmail,
                      onAlreadyHaveCode: () => setState(() => _step = 1),
                    )
                  : _step == 1
                  ? ConfirmResetStep(
                      key: const ValueKey('step_1'),
                      email: _emailController.text.trim(),
                      tokenController: _tokenController,
                      newPasswordController: _newPasswordController,
                      confirmPasswordController: _confirmPasswordController,
                      obscureNewPassword: _obscureNewPassword,
                      obscureConfirmPassword: _obscureConfirmPassword,
                      isLoading: _isLoading,
                      isRecovery: isRecovery,
                      isDark: isDark,
                      primaryColor: primaryColor,
                      onToggleNewPassword: () => setState(
                        () => _obscureNewPassword = !_obscureNewPassword,
                      ),
                      onToggleConfirmPassword: () => setState(
                        () =>
                            _obscureConfirmPassword = !_obscureConfirmPassword,
                      ),
                      onConfirm: _handleConfirmReset,
                      onCancelRecovery: _exitRecovery,
                      onChangeEmail: () => setState(() => _step = 0),
                      onResendCode: _handleSendResetEmail,
                    )
                  : ResetSuccessStep(
                      key: const ValueKey('step_2'),
                      isDark: isDark,
                      primaryColor: primaryColor,
                      onReturnToLogin: _exitRecovery,
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
