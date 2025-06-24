import 'package:flutter/material.dart';

import 'package:keep/models/app_colors.dart';

class ColorPickerDialog extends StatelessWidget {
  final Color selectedColor;

  final Function(Color) onColorSelected;

  const ColorPickerDialog({
    super.key,

    required this.selectedColor,

    required this.onColorSelected,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Choose a Color'),

      content: SizedBox(
        width: double.maxFinite,

        child: _buildColorGrid(context),
      ),

      actions: <Widget>[
        TextButton(
          child: const Text('Transparent'),

          onPressed: () {
            onColorSelected(Colors.transparent);
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: const Text('Close'),

          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }

  Widget _buildColorGrid(BuildContext context) {
    return OrientationBuilder(
      builder: (context, orientation) {
        return GridView.builder(
          shrinkWrap: true,

          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: orientation == Orientation.portrait ? 6 : 12,

            crossAxisSpacing: 8.0,

            mainAxisSpacing: 8.0,
          ),

          itemCount: AppColors.fixedColors.length,

          itemBuilder: (context, index) {
            final color = AppColors.fixedColors[index];

            return _buildColorCircle(context, color);
          },
        );
      },
    );
  }

  Widget _buildColorCircle(BuildContext context, Color color) {
    final bool isSelected = selectedColor == color;

    final Color foregroundColor =
        ThemeData.estimateBrightnessForColor(color) == Brightness.dark
            ? Colors.white
            : Colors.black;

    return GestureDetector(
      onTap: () {
        onColorSelected(color);

        Navigator.of(context).pop();
      },

      child: Container(
        height: 50,

        width: 50,

        decoration: BoxDecoration(
          shape: BoxShape.circle,

          color: color,

          border: Border.all(
            color:
                isSelected
                    ? foregroundColor.withOpacity(0.8)
                    : Colors.black.withOpacity(0.2),

            width: 2.5,
          ),
        ),

        child: isSelected ? Icon(Icons.check, color: foregroundColor) : null,
      ),
    );
  }
}
