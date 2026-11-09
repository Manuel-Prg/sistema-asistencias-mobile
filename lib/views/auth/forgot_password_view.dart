import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({super.key});

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  final _emailController = TextEditingController();
  bool _isLoading = false;
  String? _message;
  bool _isSuccess = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit(WidgetRef ref) async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      setState(() {
        _message = 'Por favor ingresa un correo electrónico válido.';
        _isSuccess = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _message = null;
    });

    final success = await ref.read(authProvider.notifier).resetPassword(email);

    if (mounted) {
      setState(() {
        _isLoading = false;
        _isSuccess = success;
        _message = success
            ? 'Hemos enviado un enlace de recuperación a tu correo. Revisa tu bandeja de entrada.'
            : 'Error al enviar el correo. Verifica que esté registrado en el sistema.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recuperar Contraseña'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.lock_reset_rounded,
                  size: 36,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                '¿Olvidaste tu contraseña?',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Ingresa tu correo institucional registrado y te enviaremos las instrucciones para restablecer tu contraseña.',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.slateMuted,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Correo Electrónico',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
              ),
              if (_message != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _isSuccess
                        ? AppColors.statusOnTime.withOpacity(0.12)
                        : AppColors.terracottaRule.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _isSuccess
                          ? AppColors.statusOnTime
                          : AppColors.terracottaRule,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _isSuccess ? Icons.check_circle_outline : Icons.error_outline,
                        color: _isSuccess
                            ? AppColors.statusOnTime
                            : AppColors.terracottaRule,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _message!,
                          style: TextStyle(
                            fontSize: 13,
                            color: _isSuccess
                                ? AppColors.statusOnTime
                                : AppColors.terracottaRule,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 24),
              Consumer(
                builder: (context, ref, child) {
                  return ElevatedButton(
                    onPressed: _isLoading ? null : () => _handleSubmit(ref),
                    child: _isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('ENVIAR ENLACE DE RECUPERACIÓN'),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
