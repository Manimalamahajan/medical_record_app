import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/custom_icon_widget.dart';

class TagInputWidget extends StatefulWidget {
  final List<String> selectedTags;
  final Function(List<String>) onTagsChanged;

  const TagInputWidget({
    Key? key,
    required this.selectedTags,
    required this.onTagsChanged,
  }) : super(key: key);

  @override
  State<TagInputWidget> createState() => _TagInputWidgetState();
}

class _TagInputWidgetState extends State<TagInputWidget> {
  final TextEditingController _tagController = TextEditingController();
  final FocusNode _tagFocusNode = FocusNode();

  @override
  void dispose() {
    _tagController.dispose();
    _tagFocusNode.dispose();
    super.dispose();
  }

  void _addTag(String tag) {
    if (tag.isNotEmpty && !widget.selectedTags.contains(tag)) {
      final updatedTags = List<String>.from(widget.selectedTags)..add(tag);
      widget.onTagsChanged(updatedTags);
      _tagController.clear();
    }
  }

  void _removeTag(String tag) {
    final updatedTags = List<String>.from(widget.selectedTags)..remove(tag);
    widget.onTagsChanged(updatedTags);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tags (Optional)',
          style: Theme.of(context).textTheme.labelLarge,
        ),
        SizedBox(height: 0.5.h),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: AppTheme.lightTheme.colorScheme.outline,
              width: 1,
            ),
            color: AppTheme.lightTheme.colorScheme.surface,
          ),
          padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Display selected tags
              if (widget.selectedTags.isNotEmpty) ...[
                Wrap(
                  spacing: 2.w,
                  runSpacing: 1.h,
                  children: widget.selectedTags.map((tag) {
                    return Chip(
                      label: Text(tag),
                      deleteIcon: const CustomIconWidget(
                        iconName: 'close',
                        size: 18,
                      ),
                      onDeleted: () => _removeTag(tag),
                      backgroundColor: AppTheme.lightTheme.colorScheme.primary.withAlpha(26),
                      labelStyle: TextStyle(
                        color: AppTheme.lightTheme.colorScheme.primary,
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 1.w),
                    );
                  }).toList(),
                ),
                SizedBox(height: 1.h),
              ],
              
              // Tag input field
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _tagController,
                      focusNode: _tagFocusNode,
                      decoration: InputDecoration(
                        hintText: 'Add tags (press Enter after each tag)',
                        hintStyle: TextStyle(
                          color: AppTheme.lightTheme.colorScheme.onSurfaceVariant.withAlpha(179),
                          fontSize: 12.sp,
                        ),
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 1.h),
                        border: InputBorder.none,
                        prefixIcon: Padding(
                          padding: EdgeInsets.only(right: 2.w),
                          child: CustomIconWidget(
                            iconName: 'tag',
                            size: 20,
                            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        prefixIconConstraints: BoxConstraints(
                          minWidth: 8.w,
                          minHeight: 4.h,
                        ),
                      ),
                      onSubmitted: (value) {
                        _addTag(value.trim());
                        _tagFocusNode.requestFocus();
                      },
                    ),
                  ),
                  IconButton(
                    icon: CustomIconWidget(
                      iconName: 'add',
                      size: 24,
                      color: AppTheme.lightTheme.colorScheme.primary,
                    ),
                    onPressed: () {
                      _addTag(_tagController.text.trim());
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: 0.5.h),
        Padding(
          padding: EdgeInsets.only(left: 3.w),
          child: Text(
            'Separate tags with Enter or tap the + button',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant.withAlpha(179),
            ),
          ),
        ),
      ],
    );
  }
}