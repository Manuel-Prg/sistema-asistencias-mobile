import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/widgets/progress_bar_style.dart';

final progressBarStyleProvider =
    NotifierProvider<ProgressBarStyleNotifier, ProgressBarStyle>(
      ProgressBarStyleNotifier.new,
    );

class ProgressBarStyleNotifier extends Notifier<ProgressBarStyle> {
  static const _styleKey = 'progress_bar_style';

  @override
  ProgressBarStyle build() {
    _loadStyle();
    return ProgressBarStyle.defaultStyle;
  }

  Future<void> _loadStyle() async {
    final prefs = await SharedPreferences.getInstance();
    final savedIndex = prefs.getInt(_styleKey);

    if (savedIndex != null && savedIndex >= 0 && savedIndex < ProgressBarStyle.values.length) {
      state = ProgressBarStyle.values[savedIndex];
    }
  }

  Future<void> setStyle(ProgressBarStyle style) async {
    state = style;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_styleKey, style.index);
  }
}
