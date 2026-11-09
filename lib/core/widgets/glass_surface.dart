import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_colors.dart';
import '../../providers/glass_settings_provider.dart';

/// Superficie con efecto de vidrio esmerilado translúcido estilo iOS (Liquid Glass)
/// con desenfoque gaussiano en tiempo real, refracción y contornos configurables.
class GlassSurface extends ConsumerWidget {
  final Widget child;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final Color? tintColor;
  final bool enableRefraction;
  final BoxShape shape;

  const GlassSurface({
    super.key,
    required this.child,
    this.borderRadius,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.tintColor,
    this.enableRefraction = true,
    this.shape = BoxShape.rectangle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(glassSettingsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final radius = borderRadius ?? BorderRadius.circular(16);
    final opacity = settings.effectiveOpacity;

    // Colores base con ajuste de opacidad según preferencia del usuario
    final defaultBaseColor = isDark ? AppColors.pondCardDark : AppColors.sillarCard;
    final activeBase = tintColor ?? defaultBaseColor;

    // Si el color base es oscuro (como la tarjeta principal de check-in en azul estanque)
    // y se encuentra sobre un fondo claro, protegemos la opacidad mínima para que el texto
    // blanco y aqua nunca pierda contraste frente al fondo claro exterior.
    final isDarkBase = activeBase.computeLuminance() < 0.20;
    final effectiveAlpha = (!isDark && isDarkBase)
        ? (0.86 + (1.0 - settings.transparency) * 0.10).clamp(0.82, 0.96)
        : opacity;

    // Gradiente de refracción de vidrio estilo iOS
    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        activeBase.withValues(alpha: (effectiveAlpha * 1.06).clamp(0.12, 0.96)),
        activeBase.withValues(alpha: (effectiveAlpha * 0.88).clamp(0.10, 0.92)),
      ],
    );

    // Contorno decorativo de cristal
    final border = settings.showBorders
        ? Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.16)
                : Colors.white.withValues(alpha: 0.70),
            width: 1.2,
          )
        : null;

    final shadow = [
      BoxShadow(
        color: isDark
            ? Colors.black.withValues(alpha: 0.30)
            : AppColors.primary.withValues(alpha: 0.06),
        blurRadius: 18,
        offset: const Offset(0, 6),
      ),
    ];

    Widget content = Container(
      width: width,
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        shape: shape,
        gradient: gradient,
        borderRadius: shape == BoxShape.circle ? null : radius,
        border: border,
        boxShadow: shadow,
      ),
      child: Stack(
        children: [
          // Destello especular de refracción en el borde superior
          if (enableRefraction && shape != BoxShape.circle)
            Positioned(
              top: 0,
              left: 12,
              right: 12,
              height: 1,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      (isDark ? Colors.white : Colors.white).withValues(
                        alpha: settings.showBorders ? 0.45 : 0.25,
                      ),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          child,
        ],
      ),
    );

    if (shape == BoxShape.circle) {
      content = ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: settings.blurSigma,
            sigmaY: settings.blurSigma,
          ),
          child: content,
        ),
      );
    } else {
      content = ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: settings.blurSigma,
            sigmaY: settings.blurSigma,
          ),
          child: content,
        ),
      );
    }

    if (margin != null) {
      content = Padding(padding: margin!, child: content);
    }

    return content;
  }
}
