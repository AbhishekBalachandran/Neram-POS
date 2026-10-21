import 'dart:async';
import 'package:flutter/material.dart';
import 'package:neram_pos/core/services/haptic_service.dart';
import 'package:neram_pos/core/theme/app_colors.dart';
import 'package:neram_pos/core/theme/app_spacing.dart';

/// Uncongested, fluid search bar featuring an animated vertical scrolling dish carousel
/// inspired by Swiggy / Zepto food discovery search interactions.
class AnimatedSearchBar extends StatefulWidget {
  const AnimatedSearchBar({
    super.key,
    required this.onChanged,
    this.onFilterTap,
    this.hintItems = defaultSearchItems,
  });

  final ValueChanged<String> onChanged;
  final VoidCallback? onFilterTap;
  final List<String> hintItems;

  static const List<String> defaultSearchItems = [
    "'Pizza'",
    "'Biryani'",
    "'Cold Brew'",
    "'Butter Chicken'",
    "'Crispy Corn'",
    "'Garlic Naan'",
    "'Falooda'",
  ];

  @override
  State<AnimatedSearchBar> createState() => _AnimatedSearchBarState();
}

class _AnimatedSearchBarState extends State<AnimatedSearchBar> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  Timer? _timer;
  int _currentHintIndex = 0;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _startHintCarousel();
    _controller.addListener(_onTextChanged);
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.removeListener(_onTextChanged);
    _focusNode.removeListener(_onFocusChanged);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = _controller.text.isNotEmpty;
    if (_hasText != hasText) {
      setState(() {
        _hasText = hasText;
      });
    }
    widget.onChanged(_controller.text);
  }

  void _onFocusChanged() {
    setState(() {});
  }

  void _startHintCarousel() {
    _timer = Timer.periodic(const Duration(milliseconds: 2600), (timer) {
      if (mounted && !_hasText) {
        setState(() {
          _currentHintIndex = (_currentHintIndex + 1) % widget.hintItems.length;
        });
      }
    });
  }

  void _clearSearch() {
    HapticService.selection();
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isFocused = _focusNode.hasFocus;

    final backgroundColor = isDark
        ? AppColors.darkSurfaceContainer
        : AppColors.lightSurface;

    final borderColor = isFocused
        ? AppColors.primary
        : isDark
        ? AppColors.darkBorder
        : AppColors.lightBorder;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: 48,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: isFocused ? 1.5 : 1.0),
        boxShadow: [
          BoxShadow(
            color: isFocused
                ? AppColors.primary.withValues(alpha: 0.15)
                : Colors.black.withValues(alpha: isDark ? 0.20 : 0.04),
            blurRadius: isFocused ? 12 : 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            if (!_focusNode.hasFocus) {
              HapticService.selection();
              _focusNode.requestFocus();
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Row(
              children: [
                // Leading Search Icon with amber pulse on focus
                Icon(
                  Icons.search_rounded,
                  size: 20,
                  color: isFocused
                      ? AppColors.primary
                      : isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
                const SizedBox(width: AppSpacing.sm + 2),

                // Search Input with Animated Swiggy-Style Rotating Carousel
                Expanded(
                  child: Stack(
                    alignment: Alignment.centerLeft,
                    children: [
                      // Animated Rotating Hint (Visible only when text field is empty)
                      if (!_hasText)
                        IgnorePointer(
                          child: Row(
                            children: [
                              Text(
                                'Search for ',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: isDark
                                      ? AppColors.darkTextMuted
                                      : AppColors.lightTextMuted,
                                ),
                              ),
                              Expanded(
                                child: ClipRect(
                                  child: AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 400),
                                    transitionBuilder: (child, animation) {
                                      final inAnimation =
                                          Tween<Offset>(
                                            begin: const Offset(0.0, 1.2),
                                            end: Offset.zero,
                                          ).animate(
                                            CurvedAnimation(
                                              parent: animation,
                                              curve: Curves.easeOutCubic,
                                            ),
                                          );
                                      return SlideTransition(
                                        position: inAnimation,
                                        child: FadeTransition(
                                          opacity: animation,
                                          child: child,
                                        ),
                                      );
                                    },
                                    child: Text(
                                      widget.hintItems[_currentHintIndex],
                                      key: ValueKey<int>(_currentHintIndex),
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: isDark
                                            ? AppColors.darkTextSecondary
                                            : AppColors.lightTextSecondary,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                      // Actual Editable Text Input
                      TextField(
                        controller: _controller,
                        focusNode: _focusNode,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.lightTextPrimary,
                        ),
                        cursorColor: AppColors.primary,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ],
                  ),
                ),

                // Trailing Clear or Filter Button
                if (_hasText)
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 18),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 28,
                      minHeight: 28,
                    ),
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                    onPressed: _clearSearch,
                  )
                else
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () {
                        HapticService.selection();
                        widget.onFilterTap?.call();
                      },
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.darkSurfaceContainerHigh
                              : AppColors.lightSurfaceSubtle,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isDark
                                ? AppColors.darkBorder.withValues(alpha: 0.5)
                                : AppColors.lightBorder,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.tune_rounded,
                          size: 15,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
