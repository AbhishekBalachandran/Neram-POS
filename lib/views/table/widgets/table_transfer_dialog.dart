import 'package:flutter/material.dart';
import 'package:neram_pos/core/services/haptic_service.dart';
import 'package:neram_pos/core/theme/app_colors.dart';
import 'package:neram_pos/core/theme/app_spacing.dart';
import 'package:neram_pos/core/theme/app_typography.dart';
import 'package:neram_pos/data/models/order_model.dart';
import 'package:neram_pos/data/models/table_model.dart';
import 'package:neram_pos/viewmodels/table_viewmodel.dart';
import 'package:provider/provider.dart';

/// Alert dialog for transferring an active table or order to another table.
/// Displays source table, target tables with live availability, a reason input,
/// and Cancel / Transfer action buttons.
class TableTransferDialog extends StatefulWidget {
  const TableTransferDialog({
    super.key,
    required this.fromTableId,
    this.order,
  });

  final String fromTableId;
  final OrderModel? order;

  static Future<bool?> show(
    BuildContext context, {
    required String fromTableId,
    OrderModel? order,
  }) {
    HapticService.selection();
    return showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.75),
      builder: (_) => TableTransferDialog(
        fromTableId: fromTableId,
        order: order,
      ),
    );
  }

  @override
  State<TableTransferDialog> createState() => _TableTransferDialogState();
}

class _TableTransferDialogState extends State<TableTransferDialog> {
  String? _selectedTargetTableId;
  late final TextEditingController _reasonController;

  static const List<String> _quickReasons = [
    'Window seat request',
    'AC cooling issue',
    'Table joining',
    'More guests',
    'Spill / cleaning',
  ];

  @override
  void initState() {
    super.initState();
    _reasonController = TextEditingController();
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tableViewModel = context.watch<TableViewModel>();
    final allTables = tableViewModel.tables;

    final sourceTable = allTables.firstWhere(
      (t) => t.id == widget.fromTableId,
      orElse: () => allTables.first,
    );

    // Filter out the source table
    final destinationTables =
        allTables.where((t) => t.id != widget.fromTableId).toList();

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: 520,
          maxHeight: MediaQuery.sizeOf(context).height * 0.88,
        ),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.darkSurfaceContainerLowest
              : AppColors.lightSurface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x66000000),
              blurRadius: 32,
              offset: Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Dialog Header
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.md,
                AppSpacing.sm,
                AppSpacing.xs,
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.35),
                      ),
                    ),
                    child: const Icon(
                      Icons.swap_horiz_rounded,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Transfer Table',
                          style: AppTypography.headlineFont(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.lightTextPrimary,
                          ),
                        ),
                        Text(
                          'Shift active order to another table',
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
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20),
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                    onPressed: () => Navigator.of(context).pop(false),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // 2. Scrollable Body
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // From -> To Transfer Route Banner
                    _buildRouteCard(isDark, sourceTable),
                    const SizedBox(height: AppSpacing.md),

                    // Destination Tables Grid with Availability
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.table_restaurant_rounded,
                              size: 15,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'SELECT DESTINATION TABLE',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.8,
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.lightTextSecondary,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '${destinationTables.length} Tables',
                          style: TextStyle(
                            fontSize: 10,
                            color: isDark
                                ? AppColors.darkTextMuted
                                : AppColors.lightTextMuted,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _buildTablesGrid(isDark, destinationTables),
                    const SizedBox(height: AppSpacing.md),

                    // Reason Input Section
                    Row(
                      children: [
                        const Icon(
                          Icons.edit_note_rounded,
                          size: 16,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'TRANSFER REASON',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),

                    // Quick Reason Suggestions
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _quickReasons.map((reason) {
                          final isSelected =
                              _reasonController.text.trim() == reason;
                          return Padding(
                            padding: const EdgeInsets.only(right: 6, bottom: 6),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(999),
                                onTap: () {
                                  setState(() {
                                    _reasonController.text = reason;
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 9,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppColors.primary.withValues(alpha: 0.2)
                                        : isDark
                                        ? AppColors.darkSurfaceContainer
                                        : AppColors.lightSurfaceSubtle,
                                    borderRadius: BorderRadius.circular(999),
                                    border: Border.all(
                                      color: isSelected
                                          ? AppColors.primary
                                          : isDark
                                          ? AppColors.darkBorder
                                          : AppColors.lightBorder,
                                    ),
                                  ),
                                  child: Text(
                                    reason,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: isSelected
                                          ? FontWeight.w700
                                          : FontWeight.w500,
                                      color: isSelected
                                          ? AppColors.primary
                                          : isDark
                                          ? AppColors.darkTextSecondary
                                          : AppColors.lightTextSecondary,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Reason TextField
                    Container(
                      height: 42,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.darkSurfaceContainer
                            : AppColors.lightSurfaceSubtle,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isDark
                              ? AppColors.darkBorder
                              : AppColors.lightBorder,
                        ),
                      ),
                      child: TextField(
                        controller: _reasonController,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.lightTextPrimary,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Enter reason for table transfer...',
                          hintStyle: TextStyle(
                            fontSize: 11.5,
                            color: isDark
                                ? AppColors.darkTextMuted
                                : AppColors.lightTextMuted,
                          ),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          isDense: true,
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 11),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Divider(height: 1),

            // 3. Footer Action Buttons: Cancel and Transfer
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.sm + 2,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: BorderSide(
                          color: isDark
                              ? AppColors.darkBorder
                              : AppColors.lightBorder,
                        ),
                      ),
                      onPressed: () => Navigator.of(context).pop(false),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.lightTextPrimary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.onPrimary,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        disabledBackgroundColor: isDark
                            ? AppColors.darkSurfaceContainerHigh
                            : const Color(0xFFE2E8F0),
                        disabledForegroundColor: isDark
                            ? AppColors.darkTextMuted
                            : const Color(0xFF94A3B8),
                      ),
                      onPressed: _selectedTargetTableId == null
                          ? null
                          : () => _handleTransfer(context, tableViewModel),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.swap_horiz_rounded, size: 17),
                          SizedBox(width: 6),
                          Text(
                            'Transfer',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
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
      ),
    );
  }

  Widget _buildRouteCard(bool isDark, TableModel sourceTable) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm + 2),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkSurfaceContainer
            : AppColors.lightSurfaceSubtle,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Row(
        children: [
          // Source Table Pill
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.darkSurfaceContainerLowest
                    : AppColors.lightSurface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'CURRENT TABLE',
                    style: TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        sourceTable.id,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            '(${sourceTable.seats} Seats)',
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.lightTextSecondary,
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
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Icon(
              Icons.arrow_forward_rounded,
              size: 20,
              color: AppColors.primary,
            ),
          ),
          // Target Table Pill
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
              decoration: BoxDecoration(
                color: _selectedTargetTableId != null
                    ? AppColors.primary.withValues(alpha: 0.12)
                    : isDark
                    ? AppColors.darkSurfaceContainerLowest
                    : AppColors.lightSurface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: _selectedTargetTableId != null
                      ? AppColors.primary
                      : isDark
                      ? AppColors.darkBorder
                      : AppColors.lightBorder,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'NEW TABLE',
                    style: TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w700,
                      color: _selectedTargetTableId != null
                          ? AppColors.primary
                          : (isDark
                              ? AppColors.darkTextMuted
                              : AppColors.lightTextMuted),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _selectedTargetTableId ?? 'Select table below',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: _selectedTargetTableId != null
                          ? FontWeight.w800
                          : FontWeight.w500,
                      color: _selectedTargetTableId != null
                          ? AppColors.primary
                          : (isDark
                              ? AppColors.darkTextMuted
                              : AppColors.lightTextMuted),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTablesGrid(bool isDark, List<TableModel> tables) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 1.15,
      ),
      itemCount: tables.length,
      itemBuilder: (context, index) {
        final table = tables[index];
        final isSelected = _selectedTargetTableId == table.id;
        final isVacant = table.status == TableStatus.vacant;

        return Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              HapticService.selection();
              setState(() {
                _selectedTargetTableId = table.id;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.16)
                    : isDark
                    ? AppColors.darkSurfaceContainer
                    : AppColors.lightSurface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary
                      : isDark
                      ? AppColors.darkBorder
                      : AppColors.lightBorder,
                  width: isSelected ? 2.0 : 1.0,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        table.id,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                          color: isSelected
                              ? AppColors.primary
                              : (isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.lightTextPrimary),
                        ),
                      ),
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: table.status.color,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${table.seats}S',
                        style: TextStyle(
                          fontSize: 10,
                          color: isDark
                              ? AppColors.darkTextMuted
                              : AppColors.lightTextMuted,
                        ),
                      ),
                      Flexible(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 5,
                              vertical: 1.5,
                            ),
                            decoration: BoxDecoration(
                              color: table.status.backgroundColor,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              isVacant ? 'Vacant' : table.status.displayName,
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: table.status.color,
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
        );
      },
    );
  }

  void _handleTransfer(BuildContext context, TableViewModel tableViewModel) {
    if (_selectedTargetTableId == null) return;

    final targetId = _selectedTargetTableId!;
    final reason = _reasonController.text.trim();

    tableViewModel.transferTable(
      fromTableId: widget.fromTableId,
      toTableId: targetId,
      reason: reason,
    );

    Navigator.of(context).pop(true);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Table ${widget.fromTableId} transferred to $targetId'
          '${reason.isNotEmpty ? " ($reason)" : ""}',
        ),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}

