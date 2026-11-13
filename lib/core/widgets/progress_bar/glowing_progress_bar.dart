import 'package:flutter/material.dart';

/// Barra de progreso estilo Resplandor Neón / Aura Fluídica.
/// Despliega un halo difuso exterior (bloom) y un faro luminoso pulsante
/// en el extremo de avance sin sufrir recortes.
class GlowingProgressBar extends StatefulWidget {
  final double ratio;
  final Color barColor;
  final double height;
  final double maxWidth;
  final bool isDark;

  const GlowingProgressBar({
    super.key,
    required this.ratio,
    required this.barColor,
    required this.height,
    required this.maxWidth,
    required this.isDark,
  });

  @override
  State<GlowingProgressBar> createState() => _GlowingProgressBarState();
}

class _GlowingProgressBarState extends State<GlowingProgressBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final barWidth = (widget.maxWidth * widget.ratio).clamp(
      0.0,
      widget.maxWidth,
    );
    if (barWidth <= 0) return const SizedBox.shrink();

    final radius = widget.height / 2;
    final leadBright =
        Color.lerp(widget.barColor, Colors.white, 0.35) ?? widget.barColor;

    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, _) {
        final pulseValue = _pulseController.value;
        final glowSpread = 1.0 + (pulseValue * 1.5);
        final glowBlur = 8.0 + (pulseValue * 6.0);

        return Align(
          alignment: Alignment.centerLeft,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // 1. Halo exterior difuso (Bloom de neón sin recorte)
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                width: barWidth,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(radius),
                    boxShadow: [
                      BoxShadow(
                        color: widget.barColor.withValues(
                          alpha: widget.isDark ? 0.65 : 0.45,
                        ),
                        blurRadius: glowBlur,
                        spreadRadius: glowSpread,
                      ),
                      BoxShadow(
                        color: leadBright.withValues(
                          alpha: widget.isDark ? 0.40 : 0.25,
                        ),
                        blurRadius: glowBlur * 1.8,
                        spreadRadius: glowSpread * 0.5,
                      ),
                    ],
                  ),
                ),
              ),

              // 2. Núcleo principal de la barra con gradiente eléctrico
              Container(
                width: barWidth,
                height: widget.height,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(radius),
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Color.lerp(
                        widget.barColor,
                        const Color(0xFF0C3C4C),
                        0.20,
                      )!,
                      widget.barColor,
                      leadBright,
                    ],
                    stops: const [0.0, 0.65, 1.0],
                  ),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.50),
                    width: 0.8,
                  ),
                ),
                child: Stack(
                  children: [
                    // Reflejo especular superior
                    Positioned(
                      top: 1.0,
                      left: 2.0,
                      right: 2.0,
                      height: widget.height * 0.40,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(radius),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.white.withValues(alpha: 0.65),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Destello de faro frontera (Neón Beacon)
                    if (barWidth > 10)
                      Positioned(
                        top: 1.5,
                        bottom: 1.5,
                        right: 2.5,
                        width: widget.height - 3.0,
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.white.withValues(alpha: 0.90),
                                blurRadius: 4 + pulseValue * 4,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
