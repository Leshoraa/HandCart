import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_dimens.dart';

/// A horizontal category filter bar adhering to Material 3 Expressive guidelines.
///
/// Transitions active state in-place with a smooth fade in/out and an eased
/// corner radius morph between active (capsule) and inactive (rounded rectangle) states.
///
/// Pulse/hold effect activates only when held down, keeping single-tap clean and responsive.
class CategoryFilterBar extends StatefulWidget {
  final List<String> categories;
  final String selectedCategory;
  final ValueChanged<String> onCategorySelected;

  const CategoryFilterBar({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  State<CategoryFilterBar> createState() => _CategoryFilterBarState();
}

class _CategoryFilterBarState extends State<CategoryFilterBar> {
  late final ScrollController _scrollController;

  static const double _barHeight = 42.0;
  static const double _chipHeight = 32.0;
  static const double _separatorWidth = AppDimens.sm;
  static const double _listMargin = AppDimens.md;
  static const Duration _scrollDuration = Duration(milliseconds: 300);
  static const Curve _scrollCurve = Curves.easeInOut;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _handleTap(BuildContext chipContext, String category) {
    widget.onCategorySelected(category);
    Scrollable.ensureVisible(
      chipContext,
      duration: _scrollDuration,
      curve: _scrollCurve,
      alignment: 0.5,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _barHeight,
      child: ListView.separated(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: _listMargin),
        itemCount: widget.categories.length,
        separatorBuilder: (context, index) =>
            const SizedBox(width: _separatorWidth),
        itemBuilder: (context, index) {
          final category = widget.categories[index];
          final isSelected = category == widget.selectedCategory;

          return Center(
            child: Builder(
              builder: (chipContext) => _CategoryChipItem(
                category: category,
                isSelected: isSelected,
                height: _chipHeight,
                onTap: () => _handleTap(chipContext, category),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// An individual category chip item with in-place fade transition and eased
/// corner radius morphing.
class _CategoryChipItem extends StatefulWidget {
  final String category;
  final bool isSelected;
  final double height;
  final VoidCallback onTap;

  const _CategoryChipItem({
    required this.category,
    required this.isSelected,
    required this.height,
    required this.onTap,
  });

  @override
  State<_CategoryChipItem> createState() => _CategoryChipItemState();
}

class _CategoryChipItemState extends State<_CategoryChipItem> {
  Timer? _holdTimer;
  bool _isHeld = false;

  static const Duration _holdThreshold = Duration(milliseconds: 150);
  static const Duration _transitionDuration = Duration(milliseconds: 260);
  static const Curve _easeCurve = Curves.easeInOut;
  static const double _horizontalPadding = 14.0;
  static const double _activeRadius = AppDimens.radiusMd;
  static const double _inactiveRadius = AppDimens.radiusChip;

  @override
  void dispose() {
    _holdTimer?.cancel();
    super.dispose();
  }

  void _startHoldTimer() {
    _holdTimer?.cancel();
    _holdTimer = Timer(_holdThreshold, () {
      if (mounted) {
        setState(() {
          _isHeld = true;
        });
      }
    });
  }

  void _endHold() {
    _holdTimer?.cancel();
    if (_isHeld && mounted) {
      setState(() {
        _isHeld = false;
      });
    }
  }

  void _cancelHold() {
    _holdTimer?.cancel();
    if (_isHeld && mounted) {
      setState(() {
        _isHeld = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final targetRadius =
        widget.isSelected ? _activeRadius : _inactiveRadius;

    return AnimatedContainer(
      duration: _transitionDuration,
      curve: _easeCurve,
      height: widget.height,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(targetRadius),
        border: Border.all(
          color: widget.isSelected
              ? Colors.transparent
              : colorScheme.outlineVariant.withValues(alpha: 0.8),
          width: 1.0,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          splashFactory: NoSplash.splashFactory,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          borderRadius: BorderRadius.circular(targetRadius),
          onTapDown: (_) => _startHoldTimer(),
          onTapUp: (_) => _endHold(),
          onTapCancel: _cancelHold,
          onTap: widget.onTap,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned.fill(
                child: IgnorePointer(
                  child: AnimatedOpacity(
                    duration: _transitionDuration,
                    curve: _easeCurve,
                    opacity: widget.isSelected ? 1.0 : 0.0,
                    child: AnimatedContainer(
                      duration: _transitionDuration,
                      curve: _easeCurve,
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        borderRadius: BorderRadius.circular(targetRadius),
                      ),
                    ),
                  ),
                ),
              ),

              Positioned.fill(
                child: IgnorePointer(
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 180),
                    opacity: _isHeld ? 1.0 : 0.0,
                    child: AnimatedContainer(
                      duration: _transitionDuration,
                      curve: _easeCurve,
                      decoration: BoxDecoration(
                        color: widget.isSelected
                            ? colorScheme.onPrimary.withValues(alpha: 0.22)
                            : colorScheme.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(targetRadius),
                      ),
                    ),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: _horizontalPadding),
                child: Center(
                  child: AnimatedDefaultTextStyle(
                    duration: _transitionDuration,
                    curve: _easeCurve,
                    style: (theme.textTheme.labelMedium ?? const TextStyle()).copyWith(
                      fontWeight:
                          widget.isSelected ? FontWeight.w700 : FontWeight.w600,
                      color: widget.isSelected
                          ? colorScheme.onPrimary
                          : colorScheme.onSurfaceVariant,
                    ),
                    child: Text(widget.category),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
