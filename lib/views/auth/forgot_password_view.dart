import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/glass_scaffold.dart';
import '../../core/widgets/glass_surface.dart';
import '../../core/widgets/glass_toast.dart';
import '../../providers/auth_provider.dart';
import '../../providers/security_settings_provider.dart';
import '../../services/supabase_service.dart';

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
  int _step = 0; // 0 = Solicitar código, 1 = Ingresar código y nueva clave, 2 = Éxito

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
    final isRecovery = widget.isDeepLinkRecovery ||
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

    final result = await ref.read(authProvider.notifier).confirmPasswordReset(
          email: email,
          token: token,
          newPassword: newPassword,
          isDeepLinkRecovery: isRecovery,
        );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result.success) {
      await ref.read(securitySettingsProvider.notifier).onPasswordReset(
            email: email,
            newPassword: newPassword,
          );
      setState(() => _step = 2);
    } else {
      AppGlassToast.show(
        context,
        message: result.error ?? 'Código incorrecto o expirado.',
        type: GlassToastType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;

    final authState = ref.watch(authProvider);
    final hasActiveSession = SupabaseService.client.auth.currentSession != null;
    final isRecovery = widget.isDeepLinkRecovery ||
        authState.isPasswordRecovery ||
        hasActiveSession;

    // Si detectamos la sesión de recuperación y estábamos en el paso 0, avanzar automáticamente al paso 1
    if (isRecovery && _step == 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _step == 0) {
          setState(() => _step = 1);
        }
      });
    }

    // Si hay correo en la sesión y el campo está vacío, llenarlo
    final sessionEmail = authState.user?.email ??
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
              ref.read(authProvider.notifier).cancelPasswordRecovery();
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              }
              return;
            }
            if (_step == 1) {
              setState(() => _step = 0);
            } else {
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              }
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
                  ? _buildRequestStep(isDark, primaryColor)
                  : _step == 1
                      ? _buildConfirmStep(isDark, primaryColor, isRecovery)
                      : _buildSuccessStep(isDark, primaryColor, isRecovery),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRequestStep(bool isDark, Color primaryColor) {
    return GlassSurface(
      key: const ValueKey('step_0'),
      padding: const EdgeInsets.all(24),
      borderRadius: BorderRadius.circular(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: primaryColor.withValues(alpha: isDark ? 0.22 : 0.12),
                border: Border.all(
                  color: primaryColor.withValues(alpha: isDark ? 0.45 : 0.30),
                  width: 1.2,
                ),
              ),
              child: Icon(
                Icons.lock_reset_rounded,
                size: 38,
                color: primaryColor,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            '¿Olvidaste tu contraseña?',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: AppTheme.brandFont,
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: isDark ? AppColors.darkTextPrimary : primaryColor,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Ingresa tu correo institucional registrado y te enviaremos un código de seguridad para restablecer tu contraseña dentro de la aplicación.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontFamily: AppTheme.brandFont,
              color: isDark ? const Color(0xFFC5D7DF) : AppColors.slateMuted,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'Correo Electrónico',
              hintText: 'alumno@ejemplo.com',
              prefixIcon: Icon(Icons.email_outlined, color: primaryColor),
              filled: true,
              fillColor: isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.white.withValues(alpha: 0.65),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: isDark ? AppColors.darkBorder : AppColors.stoneBorder,
                ),
              ),
            ),
          ),
          const SizedBox(height: 22),
          ElevatedButton(
            onPressed: _isLoading ? null : _handleSendResetEmail,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
            ),
            child: _isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    'ENVIAR CÓDIGO AL CORREO',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                      color: Colors.white,
                    ),
                  ),
          ),
          const SizedBox(height: 16),
          Center(
            child: TextButton(
              onPressed: () => setState(() => _step = 1),
              child: Text(
                '¿Ya tienes un código? Ingresar código',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: primaryColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmStep(bool isDark, Color primaryColor, bool isRecovery) {
    return GlassSurface(
      key: const ValueKey('step_1'),
      padding: const EdgeInsets.all(24),
      borderRadius: BorderRadius.circular(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.signalAqua.withValues(alpha: isDark ? 0.22 : 0.12),
                border: Border.all(
                  color: AppColors.signalAqua.withValues(alpha: isDark ? 0.45 : 0.30),
                  width: 1.2,
                ),
              ),
              child: Icon(
                isRecovery
                    ? Icons.lock_reset_rounded
                    : Icons.mark_email_read_rounded,
                size: 38,
                color: AppColors.signalAqua,
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            isRecovery ? 'Nueva Contraseña' : 'Ingresa el Código',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: AppTheme.brandFont,
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: isDark ? AppColors.darkTextPrimary : primaryColor,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isRecovery
                ? 'Accediste a través del enlace de tu correo. Ingresa tu nueva contraseña para completar el restablecimiento de tu cuenta.'
                : 'Revisa tu bandeja de entrada en ${_emailController.text.trim()}. Introduce el código recibido y tu nueva contraseña.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontFamily: AppTheme.brandFont,
              color: isDark ? const Color(0xFFC5D7DF) : AppColors.slateMuted,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 20),
          if (isRecovery) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.statusOnTime.withValues(alpha: isDark ? 0.15 : 0.10),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.statusOnTime.withValues(alpha: isDark ? 0.40 : 0.25),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle_outline_rounded,
                    color: AppColors.statusOnTime,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Enlace de correo verificado correctamente',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark ? const Color(0xFFB5EAD7) : const Color(0xFF0E6251),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ] else ...[
            TextField(
              controller: _tokenController,
              decoration: InputDecoration(
                labelText: 'Código de Recuperación',
                hintText: 'Ingresa el código o token del correo',
                prefixIcon: const Icon(Icons.pin_outlined, color: AppColors.signalAqua),
                filled: true,
                fillColor: isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.white.withValues(alpha: 0.65),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                    color: isDark ? AppColors.darkBorder : AppColors.stoneBorder,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
          ],
          TextField(
            controller: _newPasswordController,
            obscureText: _obscureNewPassword,
            decoration: InputDecoration(
              labelText: 'Nueva Contraseña',
              hintText: 'Mínimo 6 caracteres',
              prefixIcon: Icon(Icons.lock_outline_rounded, color: primaryColor),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureNewPassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  size: 20,
                  color: isDark ? Colors.white60 : AppColors.slateMuted,
                ),
                onPressed: () =>
                    setState(() => _obscureNewPassword = !_obscureNewPassword),
              ),
              filled: true,
              fillColor: isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.white.withValues(alpha: 0.65),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: isDark ? AppColors.darkBorder : AppColors.stoneBorder,
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _confirmPasswordController,
            obscureText: _obscureConfirmPassword,
            decoration: InputDecoration(
              labelText: 'Confirmar Nueva Contraseña',
              prefixIcon: Icon(Icons.lock_reset_rounded, color: primaryColor),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirmPassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  size: 20,
                  color: isDark ? Colors.white60 : AppColors.slateMuted,
                ),
                onPressed: () => setState(
                    () => _obscureConfirmPassword = !_obscureConfirmPassword),
              ),
              filled: true,
              fillColor: isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.white.withValues(alpha: 0.65),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: isDark ? AppColors.darkBorder : AppColors.stoneBorder,
                ),
              ),
            ),
          ),
          const SizedBox(height: 22),
          ElevatedButton(
            onPressed: _isLoading ? null : _handleConfirmReset,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
            ),
            child: _isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    'ESTABLECER NUEVA CONTRASEÑA',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                      color: Colors.white,
                    ),
                  ),
          ),
          const SizedBox(height: 14),
          if (isRecovery)
            Center(
              child: TextButton(
                onPressed: () {
                  ref.read(authProvider.notifier).cancelPasswordRecovery();
                  if (Navigator.of(context).canPop()) {
                    Navigator.of(context).pop();
                  }
                },
                child: Text(
                  'Cancelar y volver al inicio',
                  style: TextStyle(
                    fontSize: 12.5,
                    color: isDark ? Colors.white70 : AppColors.slateMuted,
                  ),
                ),
              ),
            )
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => setState(() => _step = 0),
                  child: Text(
                    'Cambiar correo',
                    style: TextStyle(
                      fontSize: 12.5,
                      color: isDark ? Colors.white70 : AppColors.slateMuted,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: _isLoading ? null : _handleSendResetEmail,
                  child: Text(
                    'Reenviar código',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: primaryColor,
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildSuccessStep(bool isDark, Color primaryColor, bool isRecovery) {
    return GlassSurface(
      key: const ValueKey('step_2'),
      padding: const EdgeInsets.all(28),
      borderRadius: BorderRadius.circular(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.statusOnTime.withValues(alpha: isDark ? 0.22 : 0.14),
                border: Border.all(
                  color: AppColors.statusOnTime.withValues(alpha: isDark ? 0.55 : 0.40),
                  width: 1.5,
                ),
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                size: 46,
                color: AppColors.statusOnTime,
              ),
            ),
          ),
          const SizedBox(height: 22),
          Text(
            '¡Contraseña Actualizada!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: AppTheme.brandFont,
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: isDark ? AppColors.darkTextPrimary : AppColors.statusOnTime,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Tu nueva contraseña ha sido configurada correctamente en el sistema. Ya puedes iniciar sesión con tus nuevas credenciales.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.5,
              fontFamily: AppTheme.brandFont,
              color: isDark ? const Color(0xFFC5D7DF) : AppColors.slateMuted,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 26),
          ElevatedButton(
            onPressed: () {
              ref.read(authProvider.notifier).cancelPasswordRecovery();
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
            ),
            child: const Text(
              'INICIAR SESIÓN',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
