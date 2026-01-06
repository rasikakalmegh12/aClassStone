import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/session/session_manager.dart';
import 'dropdown_widget.dart';

class CustomAutocompleteSection extends StatelessWidget {
  final String title;
  final List<DropdownOption> options;
  final String? selectedId;
  final Function(String? id, String? name) onSelected;
  final IconData icon;
  final Widget? trailingWidget;
  final bool showTrailing;

  const CustomAutocompleteSection({
    super.key,
    required this.title,
    required this.options,
    required this.selectedId,
    required this.onSelected,
    this.icon = Icons.search,
    this.trailingWidget,
    this.showTrailing = false,
  });

  Color get _primaryColor =>
      SessionManager.getUserRole().toString().toLowerCase() == "superadmin"
          ? AppColors.superAdminPrimary
          : AppColors.primaryDeepBlue;
  static const double _itemHeight = 48;
  static const int _maxVisibleItems = 5;
  static const double _verticalPadding = 8;
  @override
  Widget build(BuildContext context) {
    final selectedOption =
    options.where((e) => e.id == selectedId).isNotEmpty
        ? options.firstWhere((e) => e.id == selectedId)
        : null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Header
          Row(
            children: [
              Icon(icon, size: 20, color: _primaryColor),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (selectedOption != null)
                Icon(Icons.check_circle, color: _primaryColor, size: 18),
              if (showTrailing && trailingWidget != null) ...[
                const SizedBox(width: 8),
                trailingWidget!,
              ]
            ],
          ),
          const SizedBox(height: 12),

          /// Autocomplete
          RawAutocomplete<DropdownOption>(
            textEditingController: TextEditingController(
              text: selectedOption?.name ?? '',
            ),
            focusNode: FocusNode(),
            displayStringForOption: (option) => option.name,
            optionsBuilder: (TextEditingValue textValue) {
              if (options.isEmpty) {
                return const Iterable<DropdownOption>.empty();
              }
              if (textValue.text.isEmpty) {
                return options;
              }
              return options.where((option) =>
                  option.name
                      .toLowerCase()
                      .contains(textValue.text.toLowerCase()));
            },
            onSelected: (DropdownOption option) {
              onSelected(option.id, option.name);
            },
            fieldViewBuilder:
                (context, controller, focusNode, onFieldSubmitted) {
              return TextField(
                controller: controller,
                focusNode: focusNode,
                decoration: InputDecoration(
                  hintText: 'Search $title',
                  suffixIcon: controller.text.isNotEmpty
                      ? IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: () {
                      controller.clear();
                      onSelected(null, null);
                    },
                  )
                      : const Icon(Icons.keyboard_arrow_down),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: _primaryColor.withAlpha(120)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: _primaryColor, width: 1.5),
                  ),
                  contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                ),
              );
            },
            optionsViewBuilder:
                (context, onSelected, Iterable<DropdownOption> list) {
              final items = list.toList();

              final int itemCount = items.length;



              /// Calculate adaptive height
              final double calculatedHeight = itemCount == 0
                  ? 56
                  : (itemCount > _maxVisibleItems
                  ? (_itemHeight * _maxVisibleItems)
                  : (_itemHeight * itemCount));

              return Align(
                alignment: Alignment.topLeft,
                child: Material(
                  elevation: 6,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: MediaQuery.of(context).size.width - 64,
                    constraints: BoxConstraints(
                      maxHeight: calculatedHeight + _verticalPadding,
                    ),
                    child: itemCount == 0
                        ? const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        "No options to select",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    )
                        : ListView.builder(
                      padding: EdgeInsets.zero,
                      shrinkWrap: itemCount <= _maxVisibleItems,
                      itemCount: itemCount,
                      itemBuilder: (context, index) {
                        final option = items[index];
                        return InkWell(
                          onTap: () => onSelected(option),
                          child: SizedBox(
                            height: _itemHeight,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  option.name,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              );
            },

          ),
        ],
      ),
    );
  }
}
