import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/glass_scaffold.dart';
import 'resources/bitacora_banner_card.dart';
import 'resources/quick_resource_card.dart';
import 'resources/regulations_section.dart';
import 'resources/resource_category_chips.dart';
import 'resources/resource_item_card.dart';
import 'resources/resource_search_bar.dart';
import 'resources/resources_empty_state.dart';
import 'resources/student_resource_model.dart';

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
      bool launched = false;
      try {
        launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      } catch (_) {
        launched = false;
      }

      if (!launched) {
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
          backgroundColor: Theme.of(context).colorScheme.primary,
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
      appBar: const GlassAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 140),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 2),
              child: Text(
                'Recursos y Materiales',
                style: TextStyle(
                  fontSize: 24,
                  fontFamily: AppTheme.brandFont,
                  fontWeight: FontWeight.w800,
                  color: Theme.of(context).colorScheme.primary,
                  letterSpacing: -0.4,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 16),
              child: Text(
                'Documentación, guías y formatos para tu servicio social',
                style: TextStyle(
                  fontSize: 13,
                  fontFamily: AppTheme.brandFont,
                  color: isDark ? const Color(0xFFC5D7DF) : AppColors.slateMuted,
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: QuickResourceCard(
                    title: 'Manual de Guardianes',
                    subtitle: 'Protocolos y normas',
                    iconEmoji: '📚',
                    accentColor: const Color(0xFF10B981),
                    url: 'https://xurl.es/manualCUA',
                    onOpen: _openUrl,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: QuickResourceCard(
                    title: 'Diapositivas y Capacitación',
                    subtitle: 'Inducción y material',
                    iconEmoji: '🗓️',
                    accentColor: const Color(0xFF0F766E),
                    url: 'https://acortar.link/gWVHrb',
                    onOpen: _openUrl,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            ResourceSearchBar(
              controller: _searchController,
              onChanged: (val) => setState(() => _searchTerm = val),
              onClear: () {
                _searchController.clear();
                setState(() => _searchTerm = '');
              },
            ),
            const SizedBox(height: 12),
            ResourceCategoryChips(
              selectedCategory: _selectedCategory,
              onSelectCategory: (cat) => setState(() => _selectedCategory = cat),
            ),
            const SizedBox(height: 16),
            if (filtered.isEmpty)
              const ResourcesEmptyState()
            else
              ...filtered.map((res) {
                return ResourceItemCard(
                  resource: res,
                  isCopied: _copiedId == res.id,
                  onOpen: _openUrl,
                  onCopy: _copyUrl,
                );
              }),
            const SizedBox(height: 12),
            BitacoraBannerCard(onOpen: _openUrl),
            const SizedBox(height: 24),
            const RegulationsSection(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
