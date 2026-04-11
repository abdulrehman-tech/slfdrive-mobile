import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'app_bottom_sheet.dart';

/// A beautiful bottom sheet for multi-select with checkboxes.
/// Shows a searchable list of items with selection tracking.
class MultiSelectBottomSheet extends StatefulWidget {
  final List<String> selectedValues;
  final List<String> items;
  final String title;
  final String? searchHint;
  final String? doneText;
  final ValueChanged<List<String>> onSelectionChanged;

  const MultiSelectBottomSheet({
    super.key,
    required this.selectedValues,
    required this.items,
    required this.title,
    this.searchHint,
    this.doneText,
    required this.onSelectionChanged,
  });

  static Future<List<String>?> show({
    required BuildContext context,
    required List<String> selectedValues,
    required List<String> items,
    required String title,
    String? searchHint,
    String? doneText,
    required ValueChanged<List<String>> onSelectionChanged,
  }) {
    return AppBottomSheet.show<List<String>>(
      context: context,
      title: title,
      height: MediaQuery.of(context).size.height * 0.75,
      headerAction: _DoneButton(
        onTap: () {},
        label: doneText ?? 'done'.tr(),
      ),
      child: MultiSelectBottomSheet(
        selectedValues: selectedValues,
        items: items,
        title: title,
        searchHint: searchHint,
        doneText: doneText,
        onSelectionChanged: onSelectionChanged,
      ),
    );
  }

  @override
  State<MultiSelectBottomSheet> createState() => _MultiSelectBottomSheetState();
}

class _MultiSelectBottomSheetState extends State<MultiSelectBottomSheet> {
  late List<String> _filteredItems;
  late List<String> _selectedItems;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredItems = widget.items;
    _selectedItems = List.from(widget.selectedValues);
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredItems = widget.items.where((item) => item.toLowerCase().contains(query)).toList();
    });
  }

  void _toggleItem(String item) {
    HapticFeedback.lightImpact();
    setState(() {
      if (_selectedItems.contains(item)) {
        _selectedItems.remove(item);
      } else {
        _selectedItems.add(item);
      }
    });
  }

  void _onDone() {
    widget.onSelectionChanged(_selectedItems);
    Navigator.pop(context, _selectedItems);
  }

  void _selectAll() {
    HapticFeedback.lightImpact();
    setState(() {
      _selectedItems = List.from(widget.items);
    });
  }

  void _clearAll() {
    HapticFeedback.lightImpact();
    setState(() {
      _selectedItems.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        // Selection summary
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.r, vertical: 12.r),
          decoration: BoxDecoration(
            color: const Color(0xFF4D63DD).withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Row(
            children: [
              Icon(
                Icons.check_circle_outline,
                size: 20.r,
                color: const Color(0xFF4D63DD),
              ),
              SizedBox(width: 10.r),
              Expanded(
                child: Text(
                  '${_selectedItems.length} ${'items_selected'.tr()}',
                  style: TextStyle(
                    fontSize: 14.r,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : const Color(0xFF3D3D3D),
                  ),
                ),
              ),
              if (_selectedItems.isNotEmpty)
                GestureDetector(
                  onTap: _clearAll,
                  child: Text(
                    'clear_all'.tr(),
                    style: TextStyle(
                      fontSize: 13.r,
                      fontWeight: FontWeight.w600,
                      color: Colors.red.withValues(alpha: 0.8),
                    ),
                  ),
                )
              else
                GestureDetector(
                  onTap: _selectAll,
                  child: Text(
                    'select_all'.tr(),
                    style: TextStyle(
                      fontSize: 13.r,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF4D63DD),
                    ),
                  ),
                ),
            ],
          ),
        ),

        SizedBox(height: 12.r),

        // Search field
        if (widget.items.length > 6)
          Container(
            height: 48.r,
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: TextField(
              controller: _searchController,
              style: TextStyle(
                fontSize: 15.r,
                color: isDark ? Colors.white : Colors.black87,
              ),
              decoration: InputDecoration(
                hintText: widget.searchHint ?? 'search'.tr(),
                hintStyle: TextStyle(
                  fontSize: 14.r,
                  color: isDark ? Colors.white.withValues(alpha: 0.4) : Colors.black.withValues(alpha: 0.3),
                ),
                prefixIcon: Icon(
                  Icons.search,
                  size: 20.r,
                  color: isDark ? Colors.white.withValues(alpha: 0.5) : Colors.black.withValues(alpha: 0.4),
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 12.r, vertical: 14.r),
              ),
            ),
          ),

        if (widget.items.length > 6) SizedBox(height: 12.r),

        // Items list
        Expanded(
          child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            itemCount: _filteredItems.length,
            itemBuilder: (context, index) {
              final item = _filteredItems[index];
              final isSelected = _selectedItems.contains(item);

              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: EdgeInsets.only(bottom: 8.r),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF4D63DD).withValues(alpha: 0.08)
                      : isDark
                          ? Colors.white.withValues(alpha: 0.02)
                          : Colors.black.withValues(alpha: 0.01),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF4D63DD).withValues(alpha: 0.3)
                        : Colors.transparent,
                    width: 1,
                  ),
                ),
                child: CheckboxListTile(
                  value: isSelected,
                  onChanged: (_) => _toggleItem(item),
                  title: Text(
                    item,
                    style: TextStyle(
                      fontSize: 15.r,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected
                          ? const Color(0xFF4D63DD)
                          : isDark
                              ? Colors.white
                              : Colors.black87,
                    ),
                  ),
                  activeColor: const Color(0xFF4D63DD),
                  checkColor: Colors.white,
                  checkboxShape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  side: BorderSide(
                    color: isDark ? Colors.white.withValues(alpha: 0.3) : Colors.black.withValues(alpha: 0.2),
                    width: 1.5,
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 8.r),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                ),
              );
            },
          ),
        ),

        SizedBox(height: 12.r),

        // Done button
        GestureDetector(
          onTap: _onDone,
          child: Container(
            width: double.infinity,
            height: 52.r,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4D63DD), Color(0xFF677EF0)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Center(
              child: Text(
                widget.doneText ?? 'done'.tr(),
                style: TextStyle(
                  fontSize: 16.r,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _DoneButton extends StatelessWidget {
  final VoidCallback onTap;
  final String label;

  const _DoneButton({required this.onTap, required this.label});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        label,
        style: TextStyle(
          fontSize: 14.r,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF4D63DD),
        ),
      ),
    );
  }
}
