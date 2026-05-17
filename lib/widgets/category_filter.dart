import 'package:flutter/material.dart';
import 'package:kayip_esya_projesi/core/constans/app_colors.dart';

class CategoryFilter extends StatelessWidget {
  final List<String> categories;
  final String selectedCategory;
  final Function(String) onCategorySelected;

  const CategoryFilter({
    Key? key,
    required this.categories,
    required this.selectedCategory,
    required this.onCategorySelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: categories.map((category) {
        return InkWell(
          onTap: () => onCategorySelected(category),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Row(
              children: [
                Radio<String>(
                  value: category,
                  groupValue: selectedCategory,
                  activeColor: AppColors.primaryDark,
                  onChanged: (String? value) {
                    if (value != null) {
                      onCategorySelected(value);
                    }
                  },
                ),
                Text(
                  category,
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}