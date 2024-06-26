import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';

class SearchableDropDown extends StatefulWidget {
  final items;
  final value;
  final onChanged;
  final searchMatchFn;
  final searchController;
  final controller;
  const SearchableDropDown({
    super.key,
    this.items,
    this.value,
    this.onChanged,
    this.searchMatchFn,
    this.searchController,
    this.controller,
  });

  @override
  State<SearchableDropDown> createState() => _SearchableDropDownState();
}

class _SearchableDropDownState extends State<SearchableDropDown> {
  // TextEditingController searchController = TextEditingController();
  // TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: DropdownButton2<String>(
        isExpanded: true,
        hint: Text(
          '',
          style: TextStyle(
            fontSize: 14,
            color: Theme.of(context).hintColor,
          ),
        ),
        items: widget.items,
        value: widget.value,
        onChanged: widget.onChanged,
        buttonStyleData: const ButtonStyleData(
          padding: EdgeInsets.symmetric(
            horizontal: 16,
          ),
          height: 40,
          width: 200,
        ),
        dropdownStyleData: const DropdownStyleData(
          maxHeight: 200,
        ),
        menuItemStyleData: const MenuItemStyleData(
          height: 40,
        ),
        dropdownSearchData: DropdownSearchData(
          searchController: widget.searchController,
          searchInnerWidgetHeight: 50,
          searchInnerWidget: Container(
            height: 50,
            padding: const EdgeInsets.only(
              top: 8,
              bottom: 4,
              right: 8,
              left: 8,
            ),
            child: TextFormField(
              onChanged: (value) {},
              expands: true,
              maxLines: null,
              controller: widget.controller,
              decoration: InputDecoration(
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                hintText: 'Search for an item...',
                hintStyle: const TextStyle(fontSize: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    8,
                  ),
                ),
              ),
            ),
          ),
          searchMatchFn: widget.searchMatchFn,
          // searchMatchFn: (item, searchValue) {
          //   final ledgerName =
          //       suggestionItems5.firstWhere((e) => e.id == item.value).name;

          //   return ledgerName.toLowerCase().contains(searchValue.toLowerCase());
          // },
        ),
      ),
    );
    ;
  }
}
