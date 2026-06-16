import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';

import '../../../reusable/colors.dart';

class RowDropdown<T> extends StatelessWidget {
  final T value;
  final List<T> items;
  final double? width;
  final double? height;
  final Function(T?) onChanged;
  final String? hintText;

  final String? title;
  const RowDropdown({super.key, required this.value, required this.items, this.width, this.height, required this.onChanged, this.hintText, this.title});

  @override
  Widget build(BuildContext context) {
    final itemList = items.toSet().toList();
    final selectedValue = itemList.contains(value) ? value : null;

    return Wrap(
      spacing: 10,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        if (title != null) Text('$title :'),
        SizedBox(
          height: height ?? 30,
          width: width ?? 150,
          child: DropdownButtonFormField2<T>(
            value: selectedValue,
            isDense: false,
            isExpanded: true,
            iconStyleData: IconStyleData(icon: const Icon(Icons.arrow_drop_down, color: black)),
            dropdownStyleData: DropdownStyleData(
              elevation: 0,
              offset: const Offset(0, 0),
              width: width ?? 150,
              maxHeight: ((itemList.isNotEmpty ? itemList.length : 1) * 30) + 20,
              decoration: BoxDecoration(
                color: white,
                border: Border.all(color: black),
              ),
            ),
            menuItemStyleData: const MenuItemStyleData(padding: EdgeInsets.symmetric(horizontal: 10), height: 30),
            decoration: InputDecoration(
              filled: true,
              fillColor: white,
              contentPadding: const EdgeInsets.only(left: 10, right: 4),
              hintStyle: TextStyle(color: grey, fontSize: 12, height: 1.25),
              focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: blue, width: 2)),
              border: OutlineInputBorder(borderSide: BorderSide(color: grey)),
              enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: grey)),
            ),
            items: itemList.map((item) {
              return DropdownMenuItem<T>(
                value: item,
                child: Text(
                  item.toString(),
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12, height: 1.25, color: black),
                ),
              );
            }).toList(),
            onChanged: onChanged,
            hint: hintText != null ? Text(hintText!, style: TextStyle(fontSize: 12, color: Colors.grey)) : null,
          ),
        ),
      ],
    );
  }
}
