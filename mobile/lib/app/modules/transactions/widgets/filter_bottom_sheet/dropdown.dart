import 'package:flutter/material.dart';

class DropDown<T> extends StatelessWidget {
  const DropDown({
    super.key,
    required this.items,
    required this.onChanged,
    required this.value,
    required this.icon,
  });

  final List<DropdownMenuItem<T>> items;
  final Function(T?) onChanged;
  final T? value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          items: items,
          onChanged: onChanged,
          icon: const Icon(Icons.arrow_drop_down),
          isExpanded: true,
          hint: const Text('Seçiniz'),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
