import 'package:flutter/material.dart';

/// Paleta de colores oficial según el Design System
/// de la Casa Universitaria del Agua
class AppColors {
  AppColors._();

  // Colores principales
  static const Color primary = Color(0xFF0C3C4C); // Azul estanque profundo
  static const Color primaryDeep = Color(0xFF082935);
  static const Color secondary = Color(0xFFEAE5DA);

  // Acentos y estados
  static const Color accentLimnological = Color(0xFF0F766E);
  static const Color signalAqua = Color(0xFF5EEAD4);
  static const Color terracottaRule = Color(0xFFB84A27); // Faltas / Baja
  static const Color amberTolerance = Color(0xFFC26D2D); // Retardos

  // Superficies Modo Claro
  static const Color limestoneGround = Color(0xFFF4F1EA); // Fondo cantera
  static const Color sillarCard = Color(0xFFFAF8F3); // Tarjetas sillar
  static const Color stoneBorder = Color(0xFFD5CFC2); // Cortes secos 1px
  static const Color mineralInk = Color(0xFF12232B); // Texto primario
  static const Color slateMuted = Color(
    0xFF325766,
  ); // Texto secundario y subtítulos nítidos de alto contraste

  // Superficies Modo Oscuro (Puro Negro AMOLED)
  static const Color abyssalGroundDark = Color(
    0xFF000000,
  ); // 100% Puro negro AMOLED
  static const Color pondCardDark = Color(
    0xFF121214,
  ); // Tarjetas carbón neutro / vidrio ahumado
  static const Color darkBorder = Color(
    0xFF26262B,
  ); // Borde sutil y limpio estilo cristal oscuro
  static const Color darkTextPrimary = Color(0xFFF4F1EA);
  static const Color darkTextSecondary = Color(
    0xFF9E9EA8,
  ); // Gris plata neutro de alto contraste

  // Estados de Asistencia (Heatmap & Badges)
  static const Color statusOnTime = Color(0xFF10B981); // Verde puntual
  static const Color statusLate = Color(0xFF991B1B); // Rojo opaco retardo
  static const Color statusFalta = Color(0xFFEF4444); // Rojo brillante falta
  static const Color statusJustified = Color(0xFF0EA5E9); // Azul justificado
  static const Color statusInactive = Color(0xFFD1D5DB); // Gris sin registro
  static const Color statusInactiveDark = Color(0xFF222226);
}
