import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';

import '../../../../api/models/response/GetCatalogueProductResponseBody.dart';
import '../../../../bloc/catalogue/get_catalogue_methods/get_catalogue_bloc.dart';
import '../../../../bloc/catalogue/get_catalogue_methods/get_catalogue_event.dart';
import '../../../../bloc/catalogue/get_catalogue_methods/get_catalogue_state.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../widgets/app_bar.dart';

class NewLeadScreen extends StatefulWidget {
  final Map<String, dynamic>? existingLead;
  final String? meetingRef;

  const NewLeadScreen({super.key, this.existingLead, this.meetingRef});

  @override
  State<NewLeadScreen> createState() => _NewLeadScreenState();
}

class _NewLeadScreenState extends State<NewLeadScreen> {
  final _formKey = GlobalKey<FormState>();

  // Form Controllers
  final _piecesController = TextEditingController();
  final _weightController = TextEditingController();
  final _deadlineController = TextEditingController();
  final _targetController = TextEditingController();
  final _productRemarksController = TextEditingController();
  final _notesController = TextEditingController();

  // Form State
  String leadNumber = 'L-2025-021';
  String clientName = 'A Class Stone';
  String meetingReference = 'MOM #1287';
  List<String> selectedProducts = [];
  String? selectedProcessType;
  List<File> sampleImages = [];

  final List<Map<String, dynamic>> availableProducts = [
    {'name': 'Polished 18mm Slab', 'selected': true},
    {'name': 'Raw Block 50+MT', 'selected': false},
    {'name': 'Customized Tile 10mm', 'selected': false},
    {'name': 'Natural Stone Blocks', 'selected': false},
    {'name': 'Granite Slabs', 'selected': false},
    {'name': 'Marble Tiles', 'selected': false},
  ];

  final List<String> processTypes = [
    'Polished',
    'Honed',
    'Brushed',
    'Flamed',
    'Bush Hammered',
    'Natural',
  ];

  @override
  void initState() {
    super.initState();
    context.read<GetCatalogueProductListBloc>().add(
        FetchGetCatalogueProductList(

          showLoader: true,
        ),
    );
    _initializeForm();

  }

  void _initializeForm() {
    if (widget.existingLead != null) {
      // Initialize with existing lead data
      final lead = widget.existingLead!;
      // leadNumber = lead['leadNumber'];
      // clientName = lead['clientName'];
      selectedProducts = List<String>.from(lead['products'] ?? []);

      // Update available products selection
      for (var product in availableProducts) {
        product['selected'] = selectedProducts.contains(product['name']);
      }
    } else {
      // Initialize selected products from the initial state
      selectedProducts = availableProducts
          .where((product) => product['selected'] == true)
          .map<String>((product) => product['name'])
          .toList();
    }

    if (widget.meetingRef != null) {
      meetingReference = widget.meetingRef!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        // pass headerColor to the custom app bar
        child: CoolAppCard(title:  widget.existingLead != null ? 'Update Lead' : 'New Lead',),
      ),
      // appBar: _buildAppBar(),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildContextCard(),
                    const SizedBox(height: 24),
                    _buildProductsSection(),
                    const SizedBox(height: 24),
                    _buildQuantitySection(),
                    const SizedBox(height: 24),
                    _buildDeadlineSection(),
                    const SizedBox(height: 24),
                    _buildRemarksSection(),
                    const SizedBox(height: 24),
                    _buildSampleImagesSection(),
                    const SizedBox(height: 80), // Space for bottom button
                  ],
                ),
              ),
            ),
            _buildBottomButton(),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.white,
      elevation: 1,
      shadowColor: AppColors.grey200,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
      ),
      title: Text(
        widget.existingLead != null ? 'Update Lead' : 'New Lead',
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildContextCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'LEAD CONTEXT',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 12),
          _buildContextRow('Lead No', leadNumber),
          _buildContextRow('Client', clientName),
          _buildContextRow('Meeting Ref', meetingReference),
        ],
      ),
    );
  }

  Widget _buildContextRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildProductsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: BlocBuilder<GetCatalogueProductListBloc, GetCatalogueProductListState>(
        builder: (context, state) {
          if (state is GetCatalogueProductListLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is GetCatalogueProductListLoaded) {
            final products = state.response.data?.items ?? [];
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Text(
                      'PRODUCTS',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                        letterSpacing: 0.8,
                      ),
                    ),
                    SizedBox(width: 4),
                    Text('*', style: TextStyle(color: AppColors.error)),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Selected from Catalogue (${products.length})',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),

                // Pre-selected products (green background)
                if (widget.existingLead?['products'] != null &&
                    widget.existingLead!['products']!.isNotEmpty)
                  ...widget.existingLead!['products']!.map<Widget>((productId) {
                    final product = products.firstWhere(
                          (p) => p.id == productId,
                      orElse: () => Items(id: productId, name: 'Product $productId'),
                    );
                    return _buildSelectedProductTile(product, true);
                  }).toList(),

                // All catalogue products (selectable)
                if (products.isNotEmpty) ...[
                  if (widget.existingLead?['products'] != null) const Divider(),
                  TextButton.icon(
                    onPressed: () {
                      context.read<GetCatalogueProductListBloc>().add(
                         FetchGetCatalogueProductList(),
                      );
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Refresh Catalogue'),
                  ),
                  SizedBox(
                    height: 265,
                    child: ListView.builder(
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final product = products[index];
                        final isPreSelected = widget.existingLead?['products']
                            ?.contains(product.id) ?? false;
                        return _buildSelectedProductTile(product, isPreSelected);
                      },
                    ),
                  ),
                ] else ...[
                  const Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Icon(Icons.inventory_2, size: 48, color: Colors.grey),
                        SizedBox(height: 8),
                        Text('No products available'),
                      ],
                    ),
                  ),
                ],
              ],
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Text(
                    'PRODUCTS',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                      letterSpacing: 0.8,
                    ),
                  ),
                  SizedBox(width: 4),
                  Text('*', style: TextStyle(color: AppColors.error)),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {
                  context.read<GetCatalogueProductListBloc>().add(
                    FetchGetCatalogueProductList(),
                  );
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Load Catalogue Products'),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSelectedProductTile(Items product, bool isPreSelected) {
    // Check if currently selected (pre-selected OR manually selected)
    final isCurrentlySelected =
    (isPreSelected || selectedProducts.contains(product.id ?? product.name ?? ''));

    return GestureDetector(
      onTap: () {
        setState(() {
          if (isCurrentlySelected) {
            selectedProducts.remove(product.id ?? product.name ?? '');
          } else {
            selectedProducts.add(product.id ?? product.name ?? '');
          }
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 5),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isCurrentlySelected ? Colors.green.withOpacity(0.15) : Colors.grey[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isCurrentlySelected ? Colors.green : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Checkbox(
              value: isCurrentlySelected,
              onChanged: (value) {
                setState(() {
                  if (value == true) {
                    selectedProducts.add(product.id ?? product.name ?? '');
                  } else {
                    selectedProducts.remove(product.id ?? product.name ?? '');
                  }
                });
              },
              activeColor: AppColors.primaryTeal,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name ?? 'Unnamed',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: isCurrentlySelected ? Colors.green[800] : null,
                    ),
                  ),
                  if (product.productCode != null)
                    Text(
                      'Code: ${product.productCode}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  if (product.lowestPricePerSqft != null)
                    Text(
                      '₹${product.lowestPricePerSqft}/sqft',
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                ],
              ),
            ),
            if (isCurrentlySelected)
              const Icon(Icons.check_circle, color: Colors.green, size: 20),
          ],
        ),
      ),
    );
  }

  // Widget _buildProductsSection() {
  //   return Container(
  //     padding: const EdgeInsets.all(16),
  //     decoration: BoxDecoration(
  //       color: AppColors.white,
  //       borderRadius: BorderRadius.circular(12),
  //       boxShadow: [
  //         BoxShadow(
  //           color: AppColors.black.withOpacity(0.04),
  //           blurRadius: 8,
  //           offset: const Offset(0, 2),
  //         ),
  //       ],
  //     ),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Row(
  //           children: [
  //             Text(
  //               'PRODUCTS',
  //               style: TextStyle(
  //                 fontSize: 11,
  //                 fontWeight: FontWeight.w600,
  //                 color: AppColors.textSecondary,
  //                 letterSpacing: 0.8,
  //               ),
  //             ),
  //             const SizedBox(width: 4),
  //             const Text('*', style: TextStyle(color: AppColors.error)),
  //           ],
  //         ),
  //         const SizedBox(height: 12),
  //         Text(
  //           'Select products',
  //           style: TextStyle(
  //             fontSize: 14,
  //             fontWeight: FontWeight.w500,
  //             color: AppColors.textPrimary,
  //           ),
  //         ),
  //         const SizedBox(height: 8),
  //         ...availableProducts.map((product) {
  //           return CheckboxListTile(
  //             title: Text(
  //               product['name'],
  //               style: TextStyle(
  //                 fontSize: 14,
  //                 color: AppColors.textPrimary,
  //               ),
  //             ),
  //             value: product['selected'],
  //             onChanged: (value) {
  //               setState(() {
  //                 product['selected'] = value!;
  //                 if (value) {
  //                   selectedProducts.add(product['name']);
  //                 } else {
  //                   selectedProducts.remove(product['name']);
  //                 }
  //               });
  //             },
  //             activeColor: AppColors.primaryTeal,
  //             controlAffinity: ListTileControlAffinity.leading,
  //             contentPadding: EdgeInsets.zero,
  //           );
  //         }),
  //         const SizedBox(height: 8),
  //         OutlinedButton.icon(
  //           onPressed: _selectMoreProducts,
  //           icon: const Icon(Icons.add, size: 18),
  //           label: Text(
  //             'Select more from catalogue',
  //             style: TextStyle(
  //               fontSize: 12,
  //               fontWeight: FontWeight.w500,
  //             ),
  //           ),
  //           style: OutlinedButton.styleFrom(
  //             foregroundColor: AppColors.primaryTeal,
  //             side: const BorderSide(color: AppColors.primaryTeal),
  //             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
  //           ),
  //         ),
  //         if (selectedProducts.isEmpty)
  //           Padding(
  //             padding: const EdgeInsets.only(top: 8),
  //             child: Text(
  //               'Please select at least one product',
  //               style: TextStyle(
  //                 fontSize: 12,
  //                 color: AppColors.error,
  //               ),
  //             ),
  //           ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildQuantitySection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'QUANTITY',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildTextField('Pieces', _piecesController),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField('Weight (kg/MT)', _weightController),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDeadlineSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'DEADLINE & PROCESS',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildTextField('Deadline', _deadlineController, suffixIcon: Icons.keyboard_arrow_down),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField('Target', _targetController, suffixIcon: Icons.keyboard_arrow_down),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Process type',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: selectedProcessType,
            decoration: InputDecoration(
              hintText: 'Select process type',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.grey300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.grey300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.primaryTeal),
              ),
            ),
            items: processTypes.map((type) {
              return DropdownMenuItem(
                value: type,
                child: Text(type),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                selectedProcessType = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRemarksSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'REMARKS',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 12),
          _buildTextField('Product remarks', _productRemarksController, maxLines: 2),
          const SizedBox(height: 16),
          _buildTextField('Notes', _notesController, maxLines: 3),
        ],
      ),
    );
  }

  Widget _buildSampleImagesSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SAMPLE IMAGES (OPTIONAL)',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              GestureDetector(
                onTap: _addSampleImage,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.grey300, style: BorderStyle.solid),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_photo_alternate_outlined, color: AppColors.textLight),
                      Text('Add Photo', style: TextStyle(fontSize: 10, color: AppColors.textLight)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ...sampleImages.asMap().entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Stack(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          image: DecorationImage(
                            image: FileImage(entry.value),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () => _removeSampleImage(entry.key),
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                              color: AppColors.error,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.close, color: AppColors.white, size: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
    IconData? suffixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: label,
            suffixIcon: suffixIcon != null ? Icon(suffixIcon) : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.grey300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.grey300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.primaryTeal),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.grey200,
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _submitLead,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryTeal,
              foregroundColor: AppColors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
            child: Text(
              'Submit Lead',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _selectMoreProducts() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Opening product catalogue'),
        backgroundColor: AppColors.primaryTeal,
      ),
    );
  }

  void _addSampleImage() async {
    // Placeholder for image picker functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Sample image upload will be implemented'),
        backgroundColor: AppColors.primaryTeal,
      ),
    );
  }

  void _removeSampleImage(int index) {
    setState(() {
      sampleImages.removeAt(index);
    });
  }

  void _submitLead() {
    if (selectedProducts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one product'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      final action = widget.existingLead != null ? 'updated' : 'created';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lead $action successfully'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _piecesController.dispose();
    _weightController.dispose();
    _deadlineController.dispose();
    _targetController.dispose();
    _productRemarksController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}
