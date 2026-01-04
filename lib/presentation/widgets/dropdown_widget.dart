import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/session/session_manager.dart';

// Dropdown option model
class DropdownOption {
  final String id;
  final String name;
  final String? code;

  DropdownOption({required this.id, required this.name, this.code});
}

// Reusable dropdown section widget
class CustomDropdownSection extends StatelessWidget {
  final String title;
  final List<DropdownOption> options;
  final String? selectedId;
  final Function(String? id, String? name) onChanged;
  final IconData icon;
  final bool? extraFeature;
  final Widget? widget;
  final VoidCallback? onTap;


   const CustomDropdownSection({
    super.key,
    required this.title,
    required this.options,
    required this.selectedId,
    required this.onChanged,
    this.icon = Icons.arrow_drop_down_circle, this.extraFeature=false, this.widget, this.onTap,
  });

  @override
  Widget build(BuildContext context) {
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
          // Header
          Row(
            children: [
              Icon(
                icon,
                color: SessionManager.getUserRole().toString().toLowerCase() == "superadmin"
                    ? AppColors.superAdminPrimary
                    : AppColors.primaryDeepBlue,
                size: 20,
              ),
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
              if (selectedId != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: SessionManager.getUserRole().toString().toLowerCase() == "superadmin"
                        ? AppColors.superAdminPrimary
                        : AppColors.primaryDeepBlue,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 16,
                  ),
                ),

              if(extraFeature==true)
                InkWell(
                  onTap: onTap,
                  child:widget ,
                )
            ],
          ),
          const SizedBox(height: 12),
          // Dropdown
          Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: SessionManager.getUserRole().toString().toLowerCase() == "superadmin"
                    ? AppColors.superAdminPrimary.withAlpha(100)
                    : AppColors.primaryDeepBlue.withAlpha(100),
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                value: selectedId,
                hint: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    'Select $title',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                    ),
                  ),
                ),
                icon: Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Icon(
                    Icons.keyboard_arrow_down,
                    color: SessionManager.getUserRole().toString().toLowerCase() == "superadmin"
                        ? AppColors.superAdminPrimary
                        : AppColors.primaryDeepBlue,
                  ),
                ),
                borderRadius: BorderRadius.circular(12),
                dropdownColor: Colors.white,
                elevation: 8,
                menuMaxHeight: 300, // Limit dropdown height to prevent overflow
                items: options.map((option) {
                  return DropdownMenuItem<String>(
                    value: option.id,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            option.name,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          // if (option.code != null && option.code!.isNotEmpty)
                          //   Text(
                          //     'Code: ${option.code}',
                          //     style: TextStyle(
                          //       fontSize: 12,
                          //       color: Colors.grey.shade600,
                          //     ),
                          //   ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (String? newId) {
                  if (newId != null) {
                    final selectedOption = options.firstWhere((opt) => opt.id == newId);
                    onChanged(newId, selectedOption.name);
                    debugPrint('Selected: ${selectedOption.name} (ID: ${selectedOption.id})');
                  } else {
                    onChanged(null, null);
                  }
                },
                selectedItemBuilder: (BuildContext context) {
                  return options.map((option) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              option.name,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: SessionManager.getUserRole().toString().toLowerCase() == "superadmin"
                                    ? AppColors.superAdminPrimary
                                    : AppColors.primaryDeepBlue,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList();
                },
              ),
            ),
          ),
          // Show selected item details
          // if (selectedId != null) ...[
          //   const SizedBox(height: 12),
          //   Container(
          //     padding: const EdgeInsets.all(12),
          //     decoration: BoxDecoration(
          //       color: (SessionManager.getUserRole().toString().toLowerCase() == "superadmin"
          //               ? AppColors.superAdminPrimary
          //               : AppColors.primaryDeepBlue)
          //           .withAlpha(20),
          //       borderRadius: BorderRadius.circular(8),
          //     ),
          //     child: Row(
          //       children: [
          //         Icon(
          //           Icons.info_outline,
          //           size: 16,
          //           color: SessionManager.getUserRole().toString().toLowerCase() == "superadmin"
          //               ? AppColors.superAdminPrimary
          //               : AppColors.primaryDeepBlue,
          //         ),
          //         const SizedBox(width: 8),
          //         Expanded(
          //           child: Text(
          //             'Selected ID: $selectedId',
          //             style: TextStyle(
          //               fontSize: 12,
          //               color: SessionManager.getUserRole().toString().toLowerCase() == "superadmin"
          //                   ? AppColors.superAdminPrimary
          //                   : AppColors.primaryDeepBlue,
          //               fontWeight: FontWeight.w500,
          //             ),
          //           ),
          //         ),
          //         InkWell(
          //           onTap: () {
          //             onChanged(null, null);
          //           },
          //           child: Container(
          //             padding: const EdgeInsets.all(4),
          //             decoration: BoxDecoration(
          //               color: AppColors.error.withAlpha(20),
          //               borderRadius: BorderRadius.circular(4),
          //             ),
          //             child: const Icon(
          //               Icons.close,
          //               size: 14,
          //               color: AppColors.error,
          //             ),
          //           ),
          //         ),
          //       ],
          //     ),
          //   ),
          // ],
        ],
      ),
    );
  }
}

