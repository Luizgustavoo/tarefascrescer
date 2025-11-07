import 'package:flutter/material.dart';

class ColorSelector extends StatefulWidget {
  final String initialColor;

  final Function(String) onColorSelected;

  const ColorSelector({
    super.key,
    required this.initialColor,
    required this.onColorSelected,
  });

  @override
  State<ColorSelector> createState() => _ColorSelectorState();
}

class _ColorSelectorState extends State<ColorSelector> {
  late String _currentColor;

  static const List<String> _availableColors = [
    '#F8BBD0',
    '#FFE0B2',
    '#FFF9C4',
    '#DCEDC8',
    '#B3E5FC',
    '#D1C4E9',
    '#FFCCBC',
    '#C8E6C9',
    '#BBDEFB',
    '#E1BEE7',
    '#FFECB3',
    '#C5CAE9',
    '#F0F4C3',
    '#FFCDD2',
    '#D7CCC8',
    '#F5F5F5',
    '#E0F7FA',
    '#FCE4EC',
    '#FFF3E0',
    '#E8F5E9',
  ];

  @override
  void initState() {
    super.initState();
    _currentColor = widget.initialColor;
  }

  Color _colorFromHex(String hexColor) {
    final hexCode = hexColor.replaceAll('#', '');
    return Color(int.parse('FF$hexCode', radix: 16));
  }

  void _showColorPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Selecione uma cor',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 20),
                  GridView.count(
                    crossAxisCount: 5,
                    shrinkWrap: true,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    children: _availableColors.map((colorHex) {
                      final color = _colorFromHex(colorHex);
                      final isSelected = colorHex == _currentColor;
                      return GestureDetector(
                        onTap: () {
                          setState(() => _currentColor = colorHex);

                          widget.onColorSelected(colorHex);

                          Navigator.of(context).pop();
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected
                                  ? Theme.of(context).primaryColor
                                  : Colors.transparent,
                              width: 2.5,
                            ),
                          ),
                          child: isSelected
                              ? const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 18,
                                )
                              : null,
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _showColorPicker,
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Cor',
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 16,
          ),
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: _colorFromHex(_currentColor),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                ),
                const SizedBox(width: 12),
                Text('Cor selecionada'),
              ],
            ),
            const Icon(Icons.arrow_drop_down, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
