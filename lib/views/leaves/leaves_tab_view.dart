import 'package:flutter/material.dart';
import 'package:neram_pos/core/services/haptic_service.dart';
import 'package:neram_pos/core/theme/app_colors.dart';
import 'package:neram_pos/core/theme/app_spacing.dart';
import 'package:neram_pos/core/theme/app_typography.dart';
import 'package:neram_pos/viewmodels/leaves_viewmodel.dart';
import 'package:neram_pos/views/leaves/widgets/apply_leave_modal.dart';
import 'package:provider/provider.dart';

/// Leaves & Attendance Workspace matching Google Stitch "NERAM POS - Leaves & Attendance" specification.
/// Features live shift punch station, real-time clock & shift timer, monthly attendance gauge,
/// duty roster key metrics, team leave audit log, and responsive tablet dual-pane layout.
class LeavesTabView extends StatelessWidget {
  const LeavesTabView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final leavesViewModel = context.watch<LeavesViewModel>();

    return LayoutBuilder(
      builder: (context, constraints) {
        final isTablet = constraints.maxWidth >= 760;

        if (isTablet) {
          // Responsive Tablet / Desktop Dual-Pane Layout
          return Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left Column: Shift Punch Card & Duty Roster
                Expanded(
                  flex: 5,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildTopPunchCard(context, isDark, leavesViewModel),
                        const SizedBox(height: AppSpacing.md),
                        _buildRosterCard(context, isDark, leavesViewModel, isTablet),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.lg),

                // Right Column: Leave Audit & Team Log
                Expanded(
                  flex: 6,
                  child: SingleChildScrollView(
                    child: _buildLeaveAuditSection(
                      context,
                      isDark,
                      leavesViewModel,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        // Mobile Single Column Fluid Layout
        return ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            _buildTopPunchCard(context, isDark, leavesViewModel),
            const SizedBox(height: AppSpacing.md),
            _buildRosterCard(context, isDark, leavesViewModel, isTablet),
            const SizedBox(height: AppSpacing.md),
            _buildLeaveAuditSection(context, isDark, leavesViewModel),
            const SizedBox(height: AppSpacing.xxl),
          ],
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // 1. TOP PUNCH & STATUS CARD
  // ---------------------------------------------------------------------------
  Widget _buildTopPunchCard(
    BuildContext context,
    bool isDark,
    LeavesViewModel leavesViewModel,
  ) {
    final now = leavesViewModel.currentTime;
    final hours = now.hour % 12 == 0 ? 12 : now.hour % 12;
    final minutes = now.minute.toString().padLeft(2, '0');
    final seconds = now.second.toString().padLeft(2, '0');
    final ampm = now.hour >= 12 ? 'PM' : 'AM';
    final timeStr = '$hours:$minutes:$seconds $ampm';

    const weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final dateStr =
        '${weekdays[now.weekday - 1]}, ${months[now.month - 1]} ${now.day}, ${now.year}';

    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkSurfaceContainer
            : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Live Clock & Shift Timer Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Time & Date
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: leavesViewModel.isCheckedIn
                                ? const Color(0xFF10B981)
                                : const Color(0xFFEF4444),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            timeStr,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.headlineFont(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.lightTextPrimary,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      dateStr,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),

              // Shift Timer Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkSurfaceContainerHigh
                      : AppColors.lightSurfaceSubtle,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.timer_outlined,
                      size: 16,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 6),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'SHIFT TIMER',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                            color: isDark
                                ? AppColors.darkTextMuted
                                : AppColors.lightTextMuted,
                          ),
                        ),
                        Text(
                          leavesViewModel.formattedShiftDuration,
                          style: AppTypography.headlineFont(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Active punch status indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.darkSurfaceContainerLow
                  : AppColors.lightSurfaceSubtle,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: leavesViewModel.isCheckedIn
                              ? const Color(0xFF10B981)
                              : AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 7),
                      Flexible(
                        child: Text.rich(
                          TextSpan(
                            text: 'Status: ',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.lightTextSecondary,
                            ),
                            children: [
                              TextSpan(
                                text: leavesViewModel.isCheckedIn
                                    ? 'Active'
                                    : 'Inactive',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: leavesViewModel.isCheckedIn
                                      ? const Color(0xFF10B981)
                                      : AppColors.error,
                                ),
                              ),
                            ],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                if (leavesViewModel.isCheckedIn &&
                    leavesViewModel.checkInTime != null)
                  Text(
                    'In at ${_formatTimeShort(leavesViewModel.checkInTime!)}',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark
                          ? AppColors.darkTextMuted
                          : AppColors.lightTextMuted,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Punch Actions Row (Check In, Check Out, Apply Leave)
          Row(
            children: [
              // Check In Button
              Expanded(
                child: _buildPunchButton(
                  icon: Icons.login_rounded,
                  label: 'Check In',
                  accentColor: const Color(0xFFF59E0B),
                  isDark: isDark,
                  isEnabled: !leavesViewModel.isCheckedIn,
                  onTap: () {
                    leavesViewModel.checkIn();
                    _showToast(
                      context,
                      title: 'Shift Check-In Confirmed!',
                      subtitle:
                          'Recorded at ${_formatTimeShort(DateTime.now())} • Barista Station 01',
                      isSuccess: true,
                    );
                  },
                ),
              ),
              const SizedBox(width: 8),

              // Check Out Button
              Expanded(
                child: _buildPunchButton(
                  icon: Icons.logout_rounded,
                  label: 'Check Out',
                  accentColor: const Color(0xFFEF4444),
                  isDark: isDark,
                  isEnabled: leavesViewModel.isCheckedIn,
                  onTap: () {
                    leavesViewModel.checkOut();
                    _showToast(
                      context,
                      title: 'Shift Check-Out Recorded',
                      subtitle:
                          'Logged off at ${_formatTimeShort(DateTime.now())}',
                      isSuccess: false,
                    );
                  },
                ),
              ),
              const SizedBox(width: 8),

              // Apply Leave Button (Primary Gradient)
              Expanded(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () => ApplyLeaveModal.show(context),
                    child: Container(
                      constraints: const BoxConstraints(minHeight: 54),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x40F59E0B),
                            blurRadius: 10,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.event_available_rounded,
                            size: 18,
                            color: AppColors.onPrimary,
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Apply Leave',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.onPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPunchButton({
    required IconData icon,
    required String label,
    required Color accentColor,
    required bool isDark,
    required bool isEnabled,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: isEnabled ? onTap : null,
        child: Opacity(
          opacity: isEnabled ? 1.0 : 0.45,
          child: Container(
            constraints: const BoxConstraints(minHeight: 54),
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.darkSurfaceContainerHigh
                  : AppColors.lightSurfaceSubtle,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 18, color: accentColor),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 2. MONTHLY ATTENDANCE & WORKING DAYS
  // ---------------------------------------------------------------------------
  Widget _buildRosterCard(
    BuildContext context,
    bool isDark,
    LeavesViewModel leavesViewModel,
    bool isTablet,
  ) {
    final secondaryTextColor =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final primaryTextColor =
        isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final cardBg =
        isDark ? AppColors.darkSurfaceContainerLow : AppColors.lightSurfaceSubtle;
    final borderColor =
        isDark ? AppColors.darkBorder : AppColors.lightBorder;

    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkSurfaceContainer
            : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            children: [
              const Icon(
                Icons.calendar_month_rounded,
                size: 20,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Monthly attendance & working days',
                  style: AppTypography.headlineFont(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: primaryTextColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Dropdown selectors for Year and Month
          Row(
            children: [
              // Year Selector
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Year',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: secondaryTextColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: borderColor),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          value: leavesViewModel.selectedYear,
                          isExpanded: true,
                          dropdownColor: isDark
                              ? AppColors.darkSurfaceContainer
                              : AppColors.lightSurface,
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.bold,
                            color: primaryTextColor,
                          ),
                          items: LeavesViewModel.yearsList.map((y) {
                            return DropdownMenuItem<int>(
                              value: y,
                              child: Text('$y'),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) leavesViewModel.setYear(val);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),

              // Month Selector
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Month',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: secondaryTextColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: borderColor),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: leavesViewModel.selectedMonth,
                          isExpanded: true,
                          dropdownColor: isDark
                              ? AppColors.darkSurfaceContainer
                              : AppColors.lightSurface,
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.bold,
                            color: primaryTextColor,
                          ),
                          items: LeavesViewModel.monthsList.map((m) {
                            return DropdownMenuItem<String>(
                              value: m,
                              child: Text(
                                m,
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) leavesViewModel.setMonth(val);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // 4 Required Counts:
          // 1. Days in month count
          // 2. Absent / leave count as number of days
          // 3. Count of absent
          // 4. Count of leave
          if (isTablet)
            Row(
              children: [
                Expanded(
                  child: _buildMetricTile(
                    title: 'Days in Month',
                    value: '${leavesViewModel.daysInMonth} Days',
                    icon: Icons.calendar_today_rounded,
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildMetricTile(
                    title: 'Absent / Leave Days',
                    value: '${leavesViewModel.totalAbsentLeaveDays} Days',
                    icon: Icons.event_busy_rounded,
                    accentColor: const Color(0xFFF59E0B),
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildMetricTile(
                    title: 'Count of Absent',
                    value: '${leavesViewModel.absentCount}',
                    icon: Icons.person_off_rounded,
                    accentColor: const Color(0xFFEF4444),
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildMetricTile(
                    title: 'Count of Leave',
                    value: '${leavesViewModel.leaveCount}',
                    icon: Icons.beach_access_rounded,
                    accentColor: const Color(0xFF3B82F6),
                    isDark: isDark,
                  ),
                ),
              ],
            )
          else ...[
            Row(
              children: [
                Expanded(
                  child: _buildMetricTile(
                    title: 'Days in Month',
                    value: '${leavesViewModel.daysInMonth} Days',
                    icon: Icons.calendar_today_rounded,
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildMetricTile(
                    title: 'Absent / Leave Days',
                    value: '${leavesViewModel.totalAbsentLeaveDays} Days',
                    icon: Icons.event_busy_rounded,
                    accentColor: const Color(0xFFF59E0B),
                    isDark: isDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildMetricTile(
                    title: 'Count of Absent',
                    value: '${leavesViewModel.absentCount}',
                    icon: Icons.person_off_rounded,
                    accentColor: const Color(0xFFEF4444),
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildMetricTile(
                    title: 'Count of Leave',
                    value: '${leavesViewModel.leaveCount}',
                    icon: Icons.beach_access_rounded,
                    accentColor: const Color(0xFF3B82F6),
                    isDark: isDark,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMetricTile({
    required String title,
    required String value,
    required IconData icon,
    required bool isDark,
    Color? accentColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkSurfaceContainerLow
            : AppColors.lightSurfaceSubtle,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
              color: isDark
                  ? AppColors.darkTextMuted
                  : AppColors.lightTextMuted,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                icon,
                size: 15,
                color: accentColor ?? (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: accentColor ?? (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 3. LEAVE APPLICATIONS & AUDIT SECTION
  // ---------------------------------------------------------------------------
  Widget _buildLeaveAuditSection(
    BuildContext context,
    bool isDark,
    LeavesViewModel leavesViewModel,
  ) {
    final applications = leavesViewModel.applications;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  const Icon(
                    Icons.history_edu_rounded,
                    size: 20,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      'Leave applications & audit',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.headlineFont(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.darkSurfaceContainerHigh
                    : AppColors.lightSurfaceSubtle,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                '${applications.length} Records',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Applications List Cards
        // Only datas shown: Name, Period (from date to to date), type paid or not, reason, status, reviewed by
        ...applications.map((app) {
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.darkSurfaceContainer
                  : AppColors.lightSurface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.20 : 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Name and Status Badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        app.applicantName,
                        style: AppTypography.headlineFont(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.lightTextPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3.5,
                      ),
                      decoration: BoxDecoration(
                        color: app.status.backgroundColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(app.status.icon, size: 12, color: app.status.color),
                          const SizedBox(width: 4),
                          Text(
                            app.status.displayName.toUpperCase(),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: app.status.color,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Key-value Details Section
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.darkSurfaceContainerLow
                        : AppColors.lightSurfaceSubtle,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      _buildLeaveDetailRow('Period', app.periodString, isDark, isBold: true),
                      const SizedBox(height: 6),
                      _buildLeaveDetailRow('Type', app.typePaidString, isDark),
                      const SizedBox(height: 6),
                      _buildLeaveDetailRow('Reason', app.reason, isDark),
                      const SizedBox(height: 6),
                      _buildLeaveDetailRow('Reviewed by', app.reviewedBy, isDark),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildLeaveDetailRow(
    String label,
    String value,
    bool isDark, {
    bool isBold = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.lightTextSecondary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
              color: isDark
                  ? AppColors.darkTextPrimary
                  : AppColors.lightTextPrimary,
            ),
          ),
        ),
      ],
    );
  }

  void _showToast(
    BuildContext context, {
    required String title,
    required String subtitle,
    required bool isSuccess,
  }) {
    HapticService.selection();
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Row(
          children: [
            Icon(
              isSuccess ? Icons.verified_rounded : Icons.info_outline_rounded,
              color: isSuccess ? const Color(0xFF10B981) : AppColors.primary,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 11),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _formatTimeShort(DateTime time) {
    final hours = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final minutes = time.minute.toString().padLeft(2, '0');
    final ampm = time.hour >= 12 ? 'PM' : 'AM';
    return '$hours:$minutes $ampm';
  }
}
