import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/glass_surface.dart';
import '../academic_calendar_view.dart';

/// Barra flotante inferior con información del documento y contador de páginas.
class CalendarBottomBar extends StatelessWidget {
  final AcademicCalendarDoc activeDoc;
  final int currentPage;
  final int pageCount;
  final Color activeColor;
  final bool isDark;

  const CalendarBottomBar({
    super.key,
    required this.activeDoc,
    required this.currentPage,
    required this.pageCount,
    required this.activeColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GlassSurface(
      borderRadius: BorderRadius.circular(28),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      tintColor: isDark ? const Color(0xFF141418) : null,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: activeColor.withValues(alpha: 0.15),
            ),
            child: Icon(
              Icons.description_rounded,
              size: 16,
              color: activeColor,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activeDoc.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: AppTheme.brandFont,
                    fontWeight: FontWeight.w700,
                    fontSize: 12.5,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.mineralInk,
                  ),
                ),
                Text(
                  activeDoc.subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10.5,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.slateMuted,
                  ),
                ),
              ],
            ),
          ),
          if (pageCount > 1) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: activeColor.withValues(alpha: isDark ? 0.22 : 0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: activeColor.withValues(alpha: 0.35),
                  width: 1,
                ),
              ),
              child: Text(
                'Pág $currentPage / $pageCount',
                style: TextStyle(
                  fontFamily: AppTheme.brandFont,
                  fontWeight: FontWeight.w800,
                  fontSize: 11,
                  color: activeColor,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
