import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/glass_surface.dart';
import '../../../providers/auth_provider.dart';

class ProfilePhotoDialog {
  static void show(
    BuildContext context,
    WidgetRef ref, {
    String? currentAvatarUrl,
    required VoidCallback onStartUpdate,
    required VoidCallback onFinishUpdate,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => _ProfilePhotoDialogContent(
        ref: ref,
        parentContext: context,
        currentAvatarUrl: currentAvatarUrl,
        onStartUpdate: onStartUpdate,
        onFinishUpdate: onFinishUpdate,
      ),
    );
  }
}

class _ProfilePhotoDialogContent extends StatefulWidget {
  final WidgetRef ref;
  final BuildContext parentContext;
  final String? currentAvatarUrl;
  final VoidCallback onStartUpdate;
  final VoidCallback onFinishUpdate;

  const _ProfilePhotoDialogContent({
    required this.ref,
    required this.parentContext,
    this.currentAvatarUrl,
    required this.onStartUpdate,
    required this.onFinishUpdate,
  });

  @override
  State<_ProfilePhotoDialogContent> createState() =>
      _ProfilePhotoDialogContentState();
}

class _ProfilePhotoDialogContentState
    extends State<_ProfilePhotoDialogContent> {
  final ImagePicker _picker = ImagePicker();
  late final TextEditingController _urlController;
  Uint8List? _selectedBytes;
  int _selectedFileSize = 0;
  bool _isSaving = false;
  bool _showUrlField = false;

  static const int _maxBytes = 1024 * 1024; // 1 MB

  @override
  void initState() {
    super.initState();
    _urlController = TextEditingController(text: widget.currentAvatarUrl ?? '');
    _urlController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? xFile = await _picker.pickImage(
        source: source,
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 80, // Comprime automáticamente al seleccionar
      );

      if (xFile == null) return;

      final bytes = await xFile.readAsBytes();

      if (bytes.lengthInBytes > _maxBytes) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'La imagen seleccionada supera el límite de 1 MB. Por favor elige otra.',
            ),
            backgroundColor: AppColors.terracottaRule,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      setState(() {
        _selectedBytes = bytes;
        _selectedFileSize = bytes.lengthInBytes;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No fue posible seleccionar la imagen: $e'),
          backgroundColor: AppColors.terracottaRule,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text?.trim() ?? '';
    if (text.isNotEmpty) {
      _urlController.text = text;
      _urlController.selection = TextSelection.fromPosition(
        TextPosition(offset: _urlController.text.length),
      );
    }
  }

  Future<void> _submit() async {
    // Caso 1: Imagen seleccionada de la galería o cámara
    if (_selectedBytes != null) {
      setState(() => _isSaving = true);
      Navigator.of(context).pop();

      widget.onStartUpdate();
      final success = await widget.ref
          .read(authProvider.notifier)
          .uploadAndSetProfileAvatar(_selectedBytes!);
      widget.onFinishUpdate();

      if (widget.parentContext.mounted) {
        ScaffoldMessenger.of(widget.parentContext).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  success
                      ? Icons.check_circle_rounded
                      : Icons.error_outline_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    success
                        ? '¡Foto de perfil actualizada y optimizada (< 1 MB)!'
                        : 'No fue posible subir la foto a Supabase.',
                  ),
                ),
              ],
            ),
            backgroundColor: success
                ? AppColors.primary
                : AppColors.terracottaRule,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    // Caso 2: Ingresó enlace manual
    final url = _urlController.text.trim();
    if (url.isEmpty) {
      ScaffoldMessenger.of(widget.parentContext).showSnackBar(
        const SnackBar(
          content: Text(
            'Por favor elige una foto de la galería o ingresa un enlace.',
          ),
          backgroundColor: AppColors.terracottaRule,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      ScaffoldMessenger.of(widget.parentContext).showSnackBar(
        const SnackBar(
          content: Text('El enlace debe comenzar con https:// o http://'),
          backgroundColor: AppColors.terracottaRule,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);
    Navigator.of(context).pop();

    widget.onStartUpdate();
    final success = await widget.ref
        .read(authProvider.notifier)
        .updateProfileAvatar(url);
    widget.onFinishUpdate();

    if (widget.parentContext.mounted) {
      ScaffoldMessenger.of(widget.parentContext).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                success
                    ? Icons.check_circle_rounded
                    : Icons.error_outline_rounded,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  success
                      ? '¡Foto de perfil actualizada!'
                      : 'No fue posible guardar la foto.',
                ),
              ),
            ],
          ),
          backgroundColor: success
              ? AppColors.primary
              : AppColors.terracottaRule,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themePrimary = Theme.of(context).colorScheme.primary;
    final currentText = _urlController.text.trim();
    final hasValidUrl =
        currentText.startsWith('http://') || currentText.startsWith('https://');
    final hasSelection = _selectedBytes != null || hasValidUrl;

    return GlassDialog(
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: themePrimary.withValues(alpha: isDark ? 0.22 : 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.photo_library_rounded,
              size: 20,
              color: isDark ? Colors.white : themePrimary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Foto de Perfil',
              style: TextStyle(
                fontFamily: AppTheme.brandFont,
                fontWeight: FontWeight.w800,
                fontSize: 18,
                color: isDark ? AppColors.darkTextPrimary : themePrimary,
              ),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Vista previa de imagen seleccionada de la galería
            if (_selectedBytes != null) ...[
              Center(
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.topRight,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: isDark
                                    ? AppColors.signalAqua
                                    : AppColors.primary,
                                width: 2,
                              ),
                            ),
                            child: Image.memory(
                              _selectedBytes!,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          top: -6,
                          right: -6,
                          child: IconButton(
                            icon: const CircleAvatar(
                              radius: 12,
                              backgroundColor: AppColors.terracottaRule,
                              child: Icon(
                                Icons.close_rounded,
                                size: 14,
                                color: Colors.white,
                              ),
                            ),
                            onPressed: () => setState(() {
                              _selectedBytes = null;
                              _selectedFileSize = 0;
                            }),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.signalAqua.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.check_circle_rounded,
                            size: 14,
                            color: AppColors.accentLimnological,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Optimizada: ${_formatFileSize(_selectedFileSize)} (Límite: 1 MB)',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
            ],

            // Botones principales: Galería y Cámara
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isSaving
                        ? null
                        : () => _pickImage(ImageSource.gallery),
                    icon: const Icon(
                      Icons.photo_library_rounded,
                      size: 18,
                      color: Colors.white,
                    ),
                    label: const Text(
                      'Galería',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: themePrimary,
                      foregroundColor: Colors.white,
                      iconColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isSaving
                        ? null
                        : () => _pickImage(ImageSource.camera),
                    icon: Icon(
                      Icons.photo_camera_rounded,
                      size: 18,
                      color: isDark ? Colors.white : themePrimary,
                    ),
                    label: Text(
                      'Cámara',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : themePrimary,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: isDark ? Colors.white : themePrimary,
                      iconColor: isDark ? Colors.white : themePrimary,
                      side: BorderSide(
                        color: (isDark ? Colors.white38 : themePrimary)
                            .withValues(alpha: 0.5),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            Text(
              'Las fotos se optimizan y comprimen automáticamente a < 1 MB antes de subir.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.slateMuted,
              ),
            ),
            const SizedBox(height: 12),

            // Opción alternativa: Ingresar enlace URL
            InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () => setState(() => _showUrlField = !_showUrlField),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _showUrlField
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      size: 18,
                      color: isDark ? AppColors.signalAqua : AppColors.primary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _showUrlField
                          ? 'Ocultar opción de enlace web'
                          : 'O ingresar enlace web directo (URL)',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.signalAqua
                            : AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            if (_showUrlField) ...[
              const SizedBox(height: 8),
              TextField(
                controller: _urlController,
                keyboardType: TextInputType.url,
                autocorrect: false,
                enableSuggestions: false,
                style: TextStyle(
                  fontSize: 13,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.mineralInk,
                ),
                decoration: InputDecoration(
                  hintText: 'https://ejemplo.com/mifoto.jpg',
                  prefixIcon: const Icon(Icons.link_rounded, size: 18),
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (currentText.isNotEmpty)
                        IconButton(
                          tooltip: 'Limpiar',
                          icon: const Icon(Icons.clear_rounded, size: 16),
                          onPressed: () => _urlController.clear(),
                        ),
                      IconButton(
                        tooltip: 'Pegar',
                        icon: const Icon(Icons.content_paste_rounded, size: 16),
                        onPressed: _pasteFromClipboard,
                      ),
                    ],
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
          child: Text(
            'Cancelar',
            style: TextStyle(
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.slateMuted,
            ),
          ),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: _isSaving || !hasSelection ? null : _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: themePrimary,
            foregroundColor: Colors.white,
            iconColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            minimumSize: const Size(100, 42),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: _isSaving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text(
                  'Guardar',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
        ),
      ],
    );
  }
}
