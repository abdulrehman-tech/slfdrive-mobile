import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'app_bottom_sheet.dart';

/// A beautiful bottom sheet for single-select dropdown.
/// Shows a searchable list of items with smooth animations.
class DropdownBottomSheet extends StatefulWidget {
  final String? selectedValue;
  final List<String> items;
  final String title;
  final String? searchHint;
  final ValueChanged<String?> onSelected;

  const DropdownBottomSheet({
    super.key,
    this.selectedValue,
    required this.items,
    required this.title,
    this.searchHint,
    required this.onSelected,
  });

  static Future<void> show({
    required BuildContext context,
    String? selectedValue,
    required List<String> items,
    required String title,
    String? searchHint,
    required ValueChanged<String?> onSelected,
  }) {
    return AppBottomSheet.show(
      context: context,
      title: title,
      height: MediaQuery.of(context).size.height * 0.7,
      child: DropdownBottomSheet(
        selectedValue: selectedValue,
        items: items,
        title: title,
        searchHint: searchHint,
        onSelected: onSelected,
      ),
    );
  }

  @override
  State<DropdownBottomSheet> createState() => _DropdownBottomSheetState();
}

class _DropdownBottomSheetState extends State<DropdownBottomSheet> {
  late List<String> _filteredItems;
  final _searchController = TextEditingController();
  String? _selectedValue;

  @override
  void initState() {
    super.initState();
    _filteredItems = widget.items;
    _selectedValue = widget.selectedValue;
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

  void _onItemSelected(String item) {
    HapticFeedback.lightImpact();
    setState(() => _selectedValue = item);
    widget.onSelected(item);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
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

        if (widget.items.length > 6) SizedBox(height: 16.r),

        // Items list
        Expanded(
          child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            itemCount: _filteredItems.length,
            itemBuilder: (context, index) {
              final item = _filteredItems[index];
              final isSelected = _selectedValue == item;

              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: EdgeInsets.only(bottom: 8.r),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF4D63DD).withValues(alpha: 0.1)
                      : isDark
                          ? Colors.white.withValues(alpha: 0.03)
                          : Colors.black.withValues(alpha: 0.02),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF4D63DD).withValues(alpha: 0.5)
                        : Colors.transparent,
                    width: 1.5,
                  ),
                ),
                child: ListTile(
                  onTap: () => _onItemSelected(item),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16.r, vertical: 4.r),
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
                  trailing: isSelected
                      ? Container(
                          width: 24.r,
                          height: 24.r,
                          decoration: BoxDecoration(
                            color: const Color(0xFF4D63DD),
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Icon(Icons.check, size: 16.r, color: Colors.white),
                        )
                      : null,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
