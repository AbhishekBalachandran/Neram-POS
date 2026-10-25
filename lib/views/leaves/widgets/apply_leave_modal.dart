import 'package:flutter/material.dart';
import 'package:neram_pos/core/services/haptic_service.dart';
import 'package:neram_pos/core/theme/app_colors.dart';
import 'package:neram_pos/core/theme/app_spacing.dart';
import 'package:neram_pos/core/theme/app_typography.dart';
import 'package:neram_pos/core/widgets/app_bottom_sheet.dart';
import 'package:neram_pos/data/models/leave_model.dart';
import 'package:neram_pos/viewmodels/auth_viewmodel.dart';
import 'package:neram_pos/viewmodels/leaves_viewmodel.dart';
import 'package:provider/provider.dart';

/// Modal sheet for applying duty absence / leave request from Stitch design.
class ApplyLeaveModal extends StatefulWidget {
  const ApplyLeaveModal({super.key});

  static Future<void> show(BuildContext context) {
    return AppBottomSheet.show(
      context: context,
      builder: (_) => const ApplyLeaveModal(),
    );
  }

  @override
  State<ApplyLeaveModal> createState() => _ApplyLeaveModalState();
}

class _ApplyLeaveModalState extends State<ApplyLeaveModal> {
  DateTime _startDate = DateTime.now().add(const Duration(days: 3));
  DateTime _endDate = DateTime.now().add(const Duration(days: 4));
  LeaveType _selectedType = LeaveType.paidLeave;
  final TextEditingController _reasonController = TextEditingController();

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    HapticService.selection();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final initialDate = isStart ? _startDate : _endDate;
    final firstDate = isStart ? DateTime.now() : _startDate;
    final lastDate = DateTime.now().add(const Duration(days: 180));

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: isDark
                ? const ColorScheme.dark(
                    primary: AppColors.primary,
                    onPrimary: Colors.white,
                    surface: AppColors.darkSurfaceContainer,
                    onSurface: AppColors.darkTextPrimary,
                  )
                : const ColorScheme.light(
                    primary: AppColors.primary,
                    onPrimary: Colors.white,
                    surface: AppColors.lightSurface,
                    onSurface: AppColors.lightTextPrimary,
                  ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          if (_endDate.isBefore(_startDate)) {
            _endDate = _startDate;
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  void _handleSubmit() {
    final reason = _reasonController.text.trim();
    if (reason.isEmpty) {
      HapticService.error();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('Please state a reason for absence.'),
        ),
      );
      return;
    }

    final authVm = context.read<AuthViewModel>();
    final leavesVm = context.read<LeavesViewModel>();
    final user = authVm.currentUser;

    leavesVm.applyLeave(
      startDate: _startDate,
      endDate: _endDate,
      type: _selectedType,
      reason: reason,
      applicantName: user?.name ?? 'Staff Member',
      applicantRole: user?.role.name.toUpperCase() ?? 'BARISTA',
      staffId: 'Staff #${user?.id ?? "N-101"}',
    );

    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: const Row(
          children: [
            Icon(
              Icons.check_circle_rounded,
              color: AppColors.primary,
              size: 20,
            ),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Leave Request Dispatched! Sent to Floor Manager for rota confirmation.',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final keyboardPadding = MediaQuery.viewInsetsOf(context).bottom;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.90,
      ),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkSurfaceContainerLowest
            : AppColors.lightSurface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            width: 1.0,
          ),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.only(bottom: keyboardPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            const SizedBox(height: AppSpacing.sm),
            Container(
              width: 48,
              height: 5,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkBorder : const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            const SizedBox(height: AppSpacing.xs),

            // Header
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.sm,
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.calendar_month_rounded,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Apply for Leave',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.headlineFont(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.lightTextPrimary,
                          ),
                        ),
                        Text(
                          'Submit duty absence for manager authorization',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // Form Body
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Date pickers row
                    Row(
                      children: [
                        Expanded(
                          child: _buildDateButton(
                            label: 'From Date *',
                            icon: Icons.event_rounded,
                            date: _startDate,
                            isDark: isDark,
                            onTap: () => _selectDate(context, true),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildDateButton(
                            label: 'To Date *',
                            icon: Icons.event_available_rounded,
                            date: _endDate,
                            isDark: isDark,
                            onTap: () => _selectDate(context, false),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Leave Type Selector
                    Text(
                      'Leave Type *',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.4,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.darkSurfaceContainer
                            : AppColors.lightSurfaceSubtle,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark
                              ? AppColors.darkBorder
                              : AppColors.lightBorder,
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<LeaveType>(
                          value: _selectedType,
                          isExpanded: true,
                          dropdownColor: isDark
                              ? AppColors.darkSurfaceContainerHigh
                              : AppColors.lightSurface,
                          icon: const Icon(
                            Icons.expand_more_rounded,
                            color: AppColors.primary,
                          ),
                          onChanged: (val) {
                            if (val != null) {
                              HapticService.selection();
                              setState(() => _selectedType = val);
                            }
                          },
                          items: LeaveType.values.map((type) {
                            return DropdownMenuItem<LeaveType>(
                              value: type,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                    child: Text(
                                      type.displayName,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: isDark
                                            ? AppColors.darkTextPrimary
                                            : AppColors.lightTextPrimary,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    type.balanceText,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Reason for Absence Textarea
                    Text(
                      'Reason for Absence *',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.4,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _reasonController,
                      maxLines: 3,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary,
                      ),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: isDark
                            ? AppColors.darkSurfaceContainer
                            : AppColors.lightSurfaceSubtle,
                        hintText:
                            'State operational reason and designated shift cover colleague...',
                        hintStyle: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? AppColors.darkTextMuted
                              : AppColors.lightTextMuted,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: isDark
                                ? AppColors.darkBorder
                                : AppColors.lightBorder,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: isDark
                                ? AppColors.darkBorder
                                : AppColors.lightBorder,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppColors.primary,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Policy Reminder Callout
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.darkSurfaceContainerLow
                            : AppColors.lightSurfaceSubtle,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark
                              ? AppColors.darkBorder.withValues(alpha: 0.5)
                              : AppColors.lightBorder,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.info_outline_rounded,
                            size: 16,
                            color: Color(0xFFF59E0B),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Requests for Friday or Saturday evening shifts require a minimum of 7 days advance notice per NERAM POS hospitality roster guidelines.',
                              style: TextStyle(
                                fontSize: 11,
                                height: 1.35,
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.lightTextSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Actions Row
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size.fromHeight(50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              side: BorderSide(
                                color: isDark
                                    ? AppColors.darkBorder
                                    : AppColors.lightBorder,
                              ),
                            ),
                            onPressed: () => Navigator.of(context).pop(),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                'Cancel',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: isDark
                                      ? AppColors.darkTextSecondary
                                      : AppColors.lightTextSecondary,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            height: 50,
                            decoration: BoxDecoration(
                              gradient: AppColors.primaryGradient,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x4DF59E0B),
                                  blurRadius: 12,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: _handleSubmit,
                                child: const Center(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 6),
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.send_rounded,
                                            size: 17,
                                            color: Colors.white,
                                          ),
                                          SizedBox(width: 6),
                                          Text(
                                            'Submit Request',
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateButton({
    required String label,
    required IconData icon,
    required DateTime date,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    final dateStr =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.4,
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.lightTextSecondary,
          ),
        ),
        const SizedBox(height: 6),
        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.darkSurfaceContainer
                    : AppColors.lightSurfaceSubtle,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
              ),
              child: Row(
                children: [
                  Icon(icon, size: 18, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      dateStr,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
