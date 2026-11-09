import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/widgets/glass_scaffold.dart';
import '../../core/widgets/glass_surface.dart';

class StudentResource {
  final String id;
  final String title;
  final String url;
  final String description;
  final String category;
  final String iconEmoji;
  final Color accentColor;

  const StudentResource({
    required this.id,
    required this.title,
    required this.url,
    required this.description,
    required this.category,
    required this.iconEmoji,
    required this.accentColor,
  });
}

const List<StudentResource> kStudentResources = [
  StudentResource(
    id: 'manual-guardianes',
    title: 'Manual de Guardianes',
    url: 'https://xurl.es/manualCUA',
    description:
        'Guía completa con protocolos, responsabilidades y lineamientos operativos para guardianes.',
    category: 'Manuales',
    iconEmoji: '📚',
    accentColor: Color(0xFF10B981),
  ),
  StudentResource(
    id: 'diapos-capacitacion',
    title: 'Diapos y Material de Capacitación',
    url: 'https://acortar.link/gWVHrb',
    description:
        'Presentaciones oficiales, diapositivas de inducción y material formativo interactivo.',
    category: 'Capacitación',
    iconEmoji: '🗓️',
    accentColor: Color(0xFF0F766E),
  ),
  StudentResource(
    id: 'glosario-salas',
    title: 'Glosario de Términos de las Salas en Inglés',
    url: 'https://xurl.es/glosarioCUA',
    description:
        'Vocabulario especializado, traducción y pronunciación de conceptos de salas en inglés.',
    category: 'Capacitación',
    iconEmoji: '📓',
    accentColor: Color(0xFF0284C7),
  ),
  StudentResource(
    id: 'paquete-grafico',
    title: 'Paquete Gráfico',
    url:
        'https://drive.google.com/drive/folders/1VZZBLRfqvE3ExVAwNNGPoUrSSDukYBoN?usp=sharing',
    description:
        'Recursos visuales institucionales, logotipos oficiales, elementos de diseño y plantillas.',
    category: 'Herramientas',
    iconEmoji: '💻',
    accentColor: Color(0xFF0C3C4C),
  ),
  StudentResource(
    id: 'cuento-rios-hermanos',
    title: 'Cuento: Ríos Hermanos',
    url: 'https://xurl.es/RiosHermanosCuento',
    description:
        'Narrativa y material didáctico del cuento Ríos Hermanos para actividades y dinámicas.',
    category: 'Didáctico',
    iconEmoji: '🌊',
    accentColor: Color(0xFF06B6D4),
  ),
  StudentResource(
    id: 'casita-agua-movil',
    title: 'Casita del Agua Móvil',
    url: 'https://acortar.link/NeIJR3',
    description:
        'Dinámicas, guías de operación y contenidos del proyecto interactivo Casita del Agua móvil.',
    category: 'Didáctico',
    iconEmoji: '👩🏾‍🏫',
    accentColor: Color(0xFFF59E0B),
  ),
  StudentResource(
    id: 'totem-vestibulo',
    title: 'Visualizar Tótem de Vestíbulo',
    url: 'https://xurl.es/totem',
    description:
        'Acceso interactivo a la interfaz y visualización de contenidos en pantalla de vestíbulo.',
    category: 'Herramientas',
    iconEmoji: '📺',
    accentColor: Color(0xFFF43F5E),
  ),
  StudentResource(
    id: 'discurso-agua-extraterrestre',
    title: 'Discurso Taller: El Agua es Extraterrestre',
    url:
        'https://drive.google.com/file/d/1XexampleDiscursoAgua/view?usp=sharing',
    description:
        'Guión discursivo y material didáctico oficial para el taller interactivo sobre el origen cósmico del agua.',
    category: 'Didáctico',
    iconEmoji: '🪐',
    accentColor: Color(0xFF14B8A6),
  ),
];

const List<String> kResourceCategories = [
  'Todos',
  'Capacitación',
  'Manuales',
  'Didáctico',
  'Herramientas',
];

class ResourcesView extends StatefulWidget {
  const ResourcesView({super.key});

  @override
  State<ResourcesView> createState() => _ResourcesViewState();
}

class _ResourcesViewState extends State<ResourcesView> {
  String _searchTerm = '';
  String _selectedCategory = 'Todos';
  String? _copiedId;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _openUrl(String url) async {
    try {
      final uri = Uri.parse(url.trim());
      // Intentar primero con el navegador predeterminado del sistema (Chrome/navegador externo)
      bool launched = false;
      try {
        launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      } catch (_) {
        launched = false;
      }

      if (!launched) {
        // Alternativa con el modo predeterminado de la plataforma
        launched = await launchUrl(uri, mode: LaunchMode.platformDefault);
      }

      if (!launched && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No fue posible abrir el navegador para: $url'),
            backgroundColor: AppColors.terracottaRule,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al abrir enlace: $e'),
            backgroundColor: AppColors.terracottaRule,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _copyUrl(String id, String url, String title) async {
    await Clipboard.setData(ClipboardData(text: url));
    setState(() => _copiedId = id);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Enlace de "$title" copiado al portapapeles.'),
          duration: const Duration(seconds: 2),
          backgroundColor: AppColors.primary,
        ),
      );
    }
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _copiedId = null);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final term = _searchTerm.toLowerCase().trim();

    final filtered = kStudentResources.where((res) {
      final matchesCategory =
          _selectedCategory == 'Todos' || res.category == _selectedCategory;
      final matchesSearch = term.isEmpty ||
          res.title.toLowerCase().contains(term) ||
          res.description.toLowerCase().contains(term) ||
          res.category.toLowerCase().contains(term);
      return matchesCategory && matchesSearch;
    }).toList();

    return GlassScaffold(
      appBar: const GlassAppBar(
        title: Text('Recursos y Materiales'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Banner introductorio
            GlassSurface(
              padding: const EdgeInsets.all(16),
              borderRadius: BorderRadius.circular(16),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: isDark ? 0.35 : 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.menu_book_rounded,
                      color: AppColors.signalAqua,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Recursos y Materiales',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: isDark ? AppColors.darkTextPrimary : AppColors.mineralInk,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Accede rápidamente a manuales, guías, diapositivas y herramientas de apoyo para tus actividades.',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? const Color(0xFFC5D7DF) : AppColors.slateMuted,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Barra de Búsqueda
            GlassSurface(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
              borderRadius: BorderRadius.circular(16),
              child: TextField(
                controller: _searchController,
                onChanged: (val) => setState(() => _searchTerm = val),
                decoration: InputDecoration(
                  icon: const Icon(Icons.search_rounded, color: AppColors.signalAqua, size: 22),
                  hintText: 'Buscar por nombre o descripción...',
                  hintStyle: TextStyle(
                    fontSize: 13,
                    color: isDark ? const Color(0xFF8FA7B2) : AppColors.slateMuted.withValues(alpha: 0.8),
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  fillColor: Colors.transparent,
                  filled: false,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  suffixIcon: _searchTerm.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchTerm = '');
                          },
                        )
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Filtros de Categoría
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: kResourceCategories.map((cat) {
                  final isSelected = _selectedCategory == cat;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedCategory = cat),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? (isDark ? AppColors.signalAqua : AppColors.primary)
                              : (isDark
                                  ? Colors.white.withValues(alpha: 0.06)
                                  : Colors.white.withValues(alpha: 0.65)),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? (isDark ? AppColors.signalAqua : AppColors.primary)
                                : (isDark
                                    ? AppColors.darkBorder
                                    : AppColors.primary.withValues(alpha: 0.15)),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          cat,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                            color: isSelected
                                ? (isDark ? AppColors.abyssalGroundDark : Colors.white)
                                : (isDark ? AppColors.darkTextPrimary : AppColors.mineralInk),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),

            // Lista de Tarjetas de Recursos
            if (filtered.isEmpty)
              GlassSurface(
                padding: const EdgeInsets.all(32),
                borderRadius: BorderRadius.circular(16),
                child: Center(
                  child: Column(
                    children: [
                      const Icon(Icons.folder_open_rounded, size: 44, color: AppColors.signalAqua),
                      const SizedBox(height: 10),
                      Text(
                        'No se encontraron recursos',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.mineralInk,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Prueba con otro término de búsqueda o cambia de categoría.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? const Color(0xFFC5D7DF) : AppColors.slateMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...filtered.map((res) {
                final isCopied = _copiedId == res.id;

                return GlassSurface(
                  margin: const EdgeInsets.only(bottom: 14),
                  borderRadius: BorderRadius.circular(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Barra de acento superior
                      Container(
                        height: 3,
                        decoration: BoxDecoration(
                          color: res.accentColor,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Cabecera: Emoji y Categoría
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  width: 42,
                                  height: 42,
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? Colors.white.withValues(alpha: 0.08)
                                        : Colors.white.withValues(alpha: 0.65),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isDark ? AppColors.darkBorder : AppColors.stoneBorder,
                                    ),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    res.iconEmoji,
                                    style: const TextStyle(fontSize: 20),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: res.accentColor.withValues(alpha: isDark ? 0.22 : 0.12),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: res.accentColor.withValues(alpha: 0.40),
                                    ),
                                  ),
                                  child: Text(
                                    res.category,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: isDark ? AppColors.signalAqua : res.accentColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            // Título
                            Text(
                              res.title,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: isDark ? AppColors.darkTextPrimary : AppColors.mineralInk,
                              ),
                            ),
                            const SizedBox(height: 6),

                            // Descripción
                            Text(
                              res.description,
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark ? const Color(0xFFC5D7DF) : AppColors.slateMuted,
                                height: 1.45,
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Acciones: Abrir y Copiar
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () => _openUrl(res.url),
                                    icon: const Icon(Icons.open_in_new_rounded, size: 16),
                                    label: const Text(
                                      'Abrir recurso',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          isDark ? AppColors.signalAqua : AppColors.primary,
                                      foregroundColor:
                                          isDark ? AppColors.abyssalGroundDark : Colors.white,
                                      minimumSize: const Size.fromHeight(42),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Tooltip(
                                  message: 'Copiar enlace',
                                  child: OutlinedButton(
                                    onPressed: () => _copyUrl(res.id, res.url, res.title),
                                    style: OutlinedButton.styleFrom(
                                      minimumSize: const Size(44, 42),
                                      padding: EdgeInsets.zero,
                                      side: BorderSide(
                                        color: isCopied
                                            ? AppColors.signalAqua
                                            : (isDark
                                                ? AppColors.darkBorder
                                                : AppColors.stoneBorder),
                                        width: 1.2,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: Icon(
                                      isCopied
                                          ? Icons.check_rounded
                                          : Icons.copy_rounded,
                                      size: 18,
                                      color: isCopied
                                          ? AppColors.signalAqua
                                          : (isDark
                                              ? AppColors.darkTextPrimary
                                              : AppColors.mineralInk),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),
            const SizedBox(height: 12),

            // Banner Informativo de Bitácora
            GlassSurface(
              padding: const EdgeInsets.all(16),
              borderRadius: BorderRadius.circular(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: isDark ? 0.35 : 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.assignment_turned_in_rounded,
                          color: AppColors.signalAqua,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '¿Necesitas llenar tu bitácora ahora?',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: isDark ? AppColors.darkTextPrimary : AppColors.mineralInk,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'El sistema te la recordará automáticamente al registrar tu salida o cerrar sesión, pero también puedes acceder directamente.',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? const Color(0xFFC5D7DF) : AppColors.slateMuted,
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  OutlinedButton.icon(
                    onPressed: () => _openUrl('https://xurl.es/bitacora'),
                    icon: const Icon(Icons.open_in_new_rounded, size: 16),
                    label: const Text('Ir a Bitácora'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: isDark ? AppColors.signalAqua : AppColors.primary,
                      side: BorderSide(
                        color: isDark ? AppColors.signalAqua : AppColors.primary,
                        width: 1.2,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Reglamentos Operativos (Desplegable)
            Theme(
              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                tilePadding: EdgeInsets.zero,
                childrenPadding: EdgeInsets.zero,
                leading: const Icon(Icons.gavel_rounded, color: AppColors.accentLimnological),
                title: Text(
                  'Ver Reglamentos y Lineamientos',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.mineralInk,
                  ),
                ),
                children: const [
                  SizedBox(height: 8),
                  _RegulationCard(
                    icon: Icons.timer_outlined,
                    iconColor: AppColors.amberTolerance,
                    title: 'Regla de Tolerancia y Retardos',
                    description:
                        'Tienes 15 minutos de tolerancia tras tu hora pactada de inicio. Entrar con más de 15 minutos se registra como retardo automático. Cada 3 retardos se transforman en 1 falta injustificada.',
                  ),
                  SizedBox(height: 10),
                  _RegulationCard(
                    icon: Icons.warning_amber_rounded,
                    iconColor: AppColors.terracottaRule,
                    title: 'Límite de Faltas y Riesgo de Baja',
                    description:
                        'Acumular 3 faltas injustificadas (directas o derivadas de retardos) activa el protocolo de baja institucional de tu programa de servicio social o prácticas.',
                  ),
                  SizedBox(height: 10),
                  _RegulationCard(
                    icon: Icons.stars_rounded,
                    iconColor: AppColors.signalAqua,
                    title: 'Eventos Especiales y Horas Dobles',
                    description:
                        'Las actividades especiales en fin de semana, talleres comunitarios y eventos acreditados otorgan horas al doble (2x). Debes registrarlos seleccionando el turno correspondiente.',
                  ),
                  SizedBox(height: 10),
                  _RegulationCard(
                    icon: Icons.hourglass_bottom_rounded,
                    iconColor: AppColors.accentLimnological,
                    title: 'Límites de Horas y Salidas Tempranas',
                    description:
                        'El turno mínimo acreditable es de 3 horas. Si debes retirarte antes, es obligatorio declarar el motivo para auditoría. El tope máximo de horas acreditables por jornada es de 10 horas normales y 20 horas en eventos.',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 120),
          ],
        ),
      ),
    );
  }
}

class _RegulationCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String description;

  const _RegulationCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassSurface(
      padding: const EdgeInsets.all(16),
      borderRadius: BorderRadius.circular(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: isDark ? 0.22 : 0.14),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.mineralInk,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? const Color(0xFFC5D7DF) : AppColors.slateMuted,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
