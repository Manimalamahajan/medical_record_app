import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/custom_icon_widget.dart';

class RecordFilterWidget extends StatelessWidget {
  final TextEditingController searchController;
  final List<String> sortOptions;
  final String selectedSortOption;
  final Function(String?) onSortChanged;
  final VoidCallback onClearFilters;
  final List<String> selectedTags;
  final Function(String) onTagSelected;
  final List<String> availableTags;

  const RecordFilterWidget({
    Key? key,
    required this.searchController,
    required this.sortOptions,
    required this.selectedSortOption,
    required this.onSortChanged,
    required this.onClearFilters,
    required this.selectedTags,
    required this.onTagSelected,
    required this.availableTags,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search bar
          TextField(
            controller: searchController,
            decoration: InputDecoration(
              hintText: 'Search records...',
              prefixIcon: const CustomIconWidget(
                iconName: 'search',
                size: 20,
              ),
              suffixIcon: searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const CustomIconWidget(
                        iconName: 'clear',
                        size: 20,
                      ),
                      onPressed: () {
                        searchController.clear();
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: AppTheme.lightTheme.colorScheme.outline,
                ),
              ),
              contentPadding: EdgeInsets.symmetric(vertical: 1.h),
            ),
          ),
          
          SizedBox(height: 2.h),
          
          // Sort and filter options
          Row(
            children: [
              // Sort dropdown
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 3.w),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppTheme.lightTheme.colorScheme.outline,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedSortOption,
                      icon: const CustomIconWidget(
                        iconName: 'arrow_drop_down',
                        size: 24,
                      ),
                      isExpanded: true,
                      hint: const Text('Sort by'),
                      items: sortOptions.map((String option) {
                        return DropdownMenuItem<String>(
                          value: option,
                          child: Text(option),
                        );
                      }).toList(),
                      onChanged: onSortChanged,
                    ),
                  ),
                ),
              ),
              
              SizedBox(width: 3.w),
              
              // Filter button
              OutlinedButton.icon(
                onPressed: () {
                  _showFilterBottomSheet(context);
                },
                icon: const CustomIconWidget(
                  iconName: 'filter_list',
                  size: 20,
                ),
                label: const Text('Filter'),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                ),
              ),
              
              SizedBox(width: 2.w),
              
              // Clear filters button (only shown when filters are active)
              if (selectedTags.isNotEmpty || searchController.text.isNotEmpty)
                IconButton(
                  onPressed: onClearFilters,
                  icon: const CustomIconWidget(
                    iconName: 'clear_all',
                    size: 24,
                  ),
                  tooltip: 'Clear all filters',
                ),
            ],
          ),
          
          // Selected tags display
          if (selectedTags.isNotEmpty) ...[
            SizedBox(height: 1.5.h),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: selectedTags.map((tag) {
                  return Padding(
                    padding: EdgeInsets.only(right: 2.w),
                    child: Chip(
                      label: Text(tag),
                      deleteIcon: const CustomIconWidget(
                        iconName: 'close',
                        size: 16,
                      ),
                      onDeleted: () => onTagSelected(tag),
                      backgroundColor: AppTheme.lightTheme.colorScheme.primary.withAlpha(26),
                      labelStyle: TextStyle(
                        color: AppTheme.lightTheme.colorScheme.primary,
                        fontSize: 10.sp,
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 1.w),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return Padding(
            padding: EdgeInsets.all(4.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Filter by Tags',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const CustomIconWidget(
                        iconName: 'close',
                        size: 24,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 2.h),
                
                if (availableTags.isEmpty)
                  Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 4.h),
                      child: Text(
                        'No tags available',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: SingleChildScrollView(
                      child: Wrap(
                        spacing: 2.w,
                        runSpacing: 1.h,
                        children: availableTags.map((tag) {
                          final isSelected = selectedTags.contains(tag);
                          return FilterChip(
                            label: Text(tag),
                            selected: isSelected,
                            onSelected: (selected) {
                              onTagSelected(tag);
                              setState(() {});
                            },
                            backgroundColor: AppTheme.lightTheme.colorScheme.surfaceVariant,
                            selectedColor: AppTheme.lightTheme.colorScheme.primary.withAlpha(51),
                            checkmarkColor: AppTheme.lightTheme.colorScheme.primary,
                            labelStyle: TextStyle(
                              color: isSelected
                                  ? AppTheme.lightTheme.colorScheme.primary
                                  : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                
                SizedBox(height: 2.h),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        for (final tag in selectedTags.toList()) {
                          onTagSelected(tag);
                        }
                        setState(() {});
                      },
                      child: const Text('Clear All'),
                    ),
                    SizedBox(width: 2.w),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Apply'),
                    ),
                  ],
                ),
                SizedBox(height: 1.h),
              ],
            ),
          );
        },
      ),
    );
  }
}