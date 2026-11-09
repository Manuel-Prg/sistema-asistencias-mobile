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
    // y se encuentra sobre un fondo claro, modulamos con gracia para que el texto conserve
    // legibilidad pero responda al deslizador de transparencia del usuario.
    final isDarkBase = activeBase.computeLuminance() < 0.20;
    final effectiveAlpha = (!isDark && isDarkBase)
        ? (0.38 + (1.0 - settings.transparency) * 0.44).clamp(0.30, 0.85)
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
                ? Colors.white.withValues(alpha: 0.18)
                : const Color(0xFF0C3C4C).withValues(alpha: 0.14),
            width: 1.2,
          )
        : null;

    final shadow = [
      BoxShadow(
        color: isDark
            ? Colors.black.withValues(alpha: 0.35)
            : AppColors.primary.withValues(alpha: 0.08),
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
                      Colors.white.withValues(
                        alpha: settings.showBorders
                            ? (isDark ? 0.35 : 0.60)
                            : 0.25,
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

    Widget blurred = shape == BoxShape.circle
        ? ClipOval(
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: settings.blurSigma,
                sigmaY: settings.blurSigma,
              ),
              child: content,
            ),
          )
        : ClipRRect(
            borderRadius: radius,
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: settings.blurSigma,
                sigmaY: settings.blurSigma,
              ),
              child: content,
            ),
          );

    Widget result = DecoratedBox(
      decoration: BoxDecoration(
        shape: shape,
        borderRadius: shape == BoxShape.circle ? null : radius,
        boxShadow: shadow,
      ),
      child: blurred,
    );

    if (margin != null) {
      result = Padding(padding: margin!, child: result);
    }

    return result;
  }
}

/// Diálogo modal con estética de cristal líquido translúcido estilo iOS
class GlassDialog extends StatelessWidget {
  final Widget? title;
  final Widget? content;
  final List<Widget>? actions;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;

  const GlassDialog({
    super.key,
    this.title,
    this.content,
    this.actions,
    this.padding,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: GlassSurface(
        borderRadius: borderRadius ?? BorderRadius.circular(24),
        padding: padding ?? const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (title != null) ...[
              DefaultTextStyle(
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ) ??
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                child: title!,
              ),
              const SizedBox(height: 12),
            ],
            if (content != null) ...[
              DefaultTextStyle(
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      height: 1.45,
                    ) ??
                    const TextStyle(fontSize: 14),
                child: content!,
              ),
              const SizedBox(height: 20),
            ],
            if (actions != null && actions!.isNotEmpty)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: actions!,
              ),
          ],
        ),
      ),
    );
  }
}
