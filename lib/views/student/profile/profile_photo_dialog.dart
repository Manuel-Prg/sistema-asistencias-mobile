import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/glass_surface.dart';
import '../../../providers/auth_provider.dart';
import 'photo/photo_preview_card.dart';
import 'photo/photo_source_controls.dart';

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

  void _showSnack(BuildContext targetContext, String message, bool isSuccess) {
    if (!targetContext.mounted) return;
    ScaffoldMessenger.of(targetContext).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isSuccess
                  ? Icons.check_circle_rounded
                  : Icons.error_outline_rounded,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isSuccess
            ? AppColors.primary
            : AppColors.terracottaRule,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final xFile = await _picker.pickImage(
        source: source,
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 80,
      );
      if (xFile == null) return;

      final bytes = await xFile.readAsBytes();
      if (bytes.lengthInBytes > _maxBytes) {
        if (!mounted) return;
        _showSnack(
          context,
          'La imagen seleccionada supera el límite de 1 MB. Por favor elige otra.',
          false,
        );
        return;
      }

      setState(() {
        _selectedBytes = bytes;
        _selectedFileSize = bytes.lengthInBytes;
      });
    } catch (e) {
      if (!mounted) return;
      _showSnack(context, 'No fue posible seleccionar la imagen: $e', false);
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
    if (_selectedBytes != null) {
      setState(() => _isSaving = true);
      Navigator.of(context).pop();

      widget.onStartUpdate();
      final success = await widget.ref
          .read(authProvider.notifier)
          .uploadAndSetProfileAvatar(_selectedBytes!);
      widget.onFinishUpdate();

      _showSnack(
        widget.parentContext,
        success
            ? '¡Foto de perfil actualizada y optimizada (< 1 MB)!'
            : 'No fue posible subir la foto a Supabase.',
        success,
      );
      return;
    }

    final url = _urlController.text.trim();
    if (url.isEmpty) {
      _showSnack(
        widget.parentContext,
        'Por favor elige una foto de la galería o ingresa un enlace.',
        false,
      );
      return;
    }
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      _showSnack(
        widget.parentContext,
        'El enlace debe comenzar con https:// o http://',
        false,
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

    _showSnack(
      widget.parentContext,
      success
          ? '¡Foto de perfil actualizada!'
          : 'No fue posible guardar la foto.',
      success,
    );
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
            if (_selectedBytes != null) ...[
              PhotoPreviewCard(
                bytes: _selectedBytes!,
                fileSizeBytes: _selectedFileSize,
                isDark: isDark,
                onClear: () => setState(() {
                  _selectedBytes = null;
                  _selectedFileSize = 0;
                }),
              ),
              const SizedBox(height: 14),
            ],
            PhotoSourceControls(
              urlController: _urlController,
              isSaving: _isSaving,
              showUrlField: _showUrlField,
              isDark: isDark,
              themePrimary: themePrimary,
              onPickGallery: () => _pickImage(ImageSource.gallery),
              onPickCamera: () => _pickImage(ImageSource.camera),
              onToggleUrlField: () =>
                  setState(() => _showUrlField = !_showUrlField),
              onPasteUrl: _pasteFromClipboard,
            ),
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
