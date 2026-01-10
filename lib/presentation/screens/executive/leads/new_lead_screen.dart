import 'dart:convert';
import 'dart:developer';

import 'package:apclassstone/api/models/request/PostNewLeadRequestBody.dart' as NewLead;
import 'package:apclassstone/bloc/lead/lead_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';

import '../../../../api/models/response/GetCatalogueProductResponseBody.dart';
import '../../../../bloc/catalogue/get_catalogue_methods/get_catalogue_bloc.dart';
import '../../../../bloc/catalogue/get_catalogue_methods/get_catalogue_event.dart';
import '../../../../bloc/catalogue/get_catalogue_methods/get_catalogue_state.dart';
import '../../../../bloc/client/get_client/get_client_bloc.dart';
import '../../../../bloc/client/get_client/get_client_event.dart';
import '../../../../bloc/client/get_client/get_client_state.dart';

import '../../../../bloc/lead/lead_event.dart';
import '../../../../bloc/lead/lead_state.dart';
import '../../../../bloc/mom/mom_bloc.dart';
import '../../../../bloc/mom/mom_event.dart';
import '../../../../bloc/mom/mom_state.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/session/session_manager.dart';
import '../../../widgets/app_bar.dart';
import '../../../widgets/autocomplete_container.dart';
import '../../../widgets/dropdown_widget.dart';

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
  final _transportAmountController = TextEditingController();
  final _otherChargesController = TextEditingController();
  final _taxAmountController = TextEditingController();

  // Form State
  String leadNumber = 'L-2025-021';
  String clientName = 'A Class Stone';
  String meetingReference = 'MOM #1287';
  List<String> selectedProducts = [];
  String? selectedProcessType;
  List<File> sampleImages = [];
  bool useMom = false;
  List<LeadItemDraft> leadItems = [];

  // Financial totals
  double transportAmount = 0;
  double otherChargesAmount = 0;
  double taxAmount = 0;
  double materialsTotal = 0;
  double grandTotal = 0;

  // Deadline date
  DateTime? deadlineDate;

  // Store fetched product details by product ID
  Map<String, dynamic> productDetailsCache = {};
  // Store price options for each product
  Map<String, List<PriceOption>> productPriceOptionsCache = {};


// MOM selection
  String? selectedMomId;
  String? selectedMomClientName;
  String? selectedMomClientCode;

// Client selection (when MOM = No)
  String? selectedClientId;
  String? selectedClientName;

  // Assigned user selection
  String? selectedAssignedUserId;
  String? selectedAssignedUserName;


  List<PriceOption> buildPriceOptions(dynamic data) {
    final options = <PriceOption>[];

    // Trader Grade A
    if (data.priceSqftTraderGradeA != null && data.priceSqftTraderGradeA > 0) {
      options.add(PriceOption(
        label: 'Trader Grade A',
        code: 'TRADER_A',
        price: data.priceSqftTraderGradeA.toDouble(),
      ));
    }

    // Trader Grade B
    if (data.priceSqftTraderGradeB != null && data.priceSqftTraderGradeB > 0) {
      options.add(PriceOption(
        label: 'Trader Grade B',
        code: 'TRADER_B',
        price: data.priceSqftTraderGradeB.toDouble(),
      ));
    }

    // Trader Grade C
    if (data.priceSqftTraderGradeC != null && data.priceSqftTraderGradeC > 0) {
      options.add(PriceOption(
        label: 'Trader Grade C',
        code: 'TRADER_C',
        price: data.priceSqftTraderGradeC.toDouble(),
      ));
    }

    // Architect Grade A
    if (data.priceSqftArchitectGradeA != null && data.priceSqftArchitectGradeA > 0) {
      options.add(PriceOption(
        label: 'Architect Grade A',
        code: 'ARCH_A',
        price: data.priceSqftArchitectGradeA.toDouble(),
      ));
    }

    // Architect Grade B
    if (data.priceSqftArchitectGradeB != null && data.priceSqftArchitectGradeB > 0) {
      options.add(PriceOption(
        label: 'Architect Grade B',
        code: 'ARCH_B',
        price: data.priceSqftArchitectGradeB.toDouble(),
      ));
    }

    // Architect Grade C
    if (data.priceSqftArchitectGradeC != null && data.priceSqftArchitectGradeC > 0) {
      options.add(PriceOption(
        label: 'Architect Grade C',
        code: 'ARCH_C',
        price: data.priceSqftArchitectGradeC.toDouble(),
      ));
    }

    return options;
  }


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
    context.read<GetClientListBloc>().add(
      FetchGetClientList(

          showLoader: true,
        ),
    );

    context.read<GetAssignableUsersBloc>().add(
      FetchAssignableUsers(

          showLoader: true,
        ),
    );
    _initializeForm();

  }

  void _initializeForm() {
    if (widget.existingLead != null) {
      // Initialize with existing lead data
      final lead = widget.existingLead!;
      final productIds = List<String>.from(lead['products'] ?? []);

      // Load product details for pre-selected products
      if (productIds.isNotEmpty) {
        // Delay to ensure context is ready
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _loadPreSelectedProducts(productIds);
        });
      }
    }

    if (widget.meetingRef != null) {
      meetingReference = widget.meetingRef!;
    }
  }

  void _loadPreSelectedProducts(List<String> productIds) {
    // Fetch details for each pre-selected product
    for (final productId in productIds) {
      // Add placeholder to leadItems (will be updated when details load)
      final placeholder = LeadItemDraft(
        productId: productId,
        productName: 'Loading...',
        productCode: '',
        baseRate: 0,
      );

      if (!leadItems.any((item) => item.productId == productId)) {
        setState(() {
          leadItems.add(placeholder);
        });
      }

      // Fetch product details
      context.read<GetCatalogueProductDetailsBloc>().add(
        FetchGetCatalogueProductDetails(
          productId: productId,
          showLoader: false,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        // pass headerColor to the custom app bar
        child: CoolAppCard(title:  widget.existingLead != null ? 'Update Lead' : 'New Lead',backgroundColor: SessionManager.getUserRole() =="superadmin"?AppColors.superAdminPrimary:SessionManager.getUserRole() =="admin"?
        AppColors.adminPrimaryDark :AppColors.primaryTealDark,),
      ),
      // appBar: _buildAppBar(),
      body: MultiBlocListener(
        listeners: [
          // Listen to PostNewLeadBloc for submission result
          BlocListener<PostNewLeadBloc, LeadState>(
            listener: (context, state) {
              if (state is PostNewLeadLoading && state.showLoader) {
                // Show loading indicator
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => const Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              } else if (state is PostNewLeadSuccess) {
                // Dismiss loading dialog
                Navigator.of(context, rootNavigator: true).pop();

                // Show success message
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Lead created successfully'),
                    backgroundColor: AppColors.success,
                  ),
                );

                // Pop back with result (status code 200/201)
                if (state.response.statusCode == 200 || state.response.statusCode == 201) {
                  Navigator.of(context).pop(true);
                }
              } else if (state is PostNewLeadError) {
                // Dismiss loading dialog
                Navigator.of(context, rootNavigator: true).pop();

                // Show error message
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            },
          ),

          // Existing listener for GetCatalogueProductDetailsBloc
          BlocListener<GetCatalogueProductDetailsBloc, GetCatalogueProductDetailsState>(
            listener: (context, state) {
              if (state is GetCatalogueProductDetailsLoaded) {
                final productId = state.response.data?.id;
                if (productId != null) {
                  // Cache the product details
                  productDetailsCache[productId] = state.response.data;

                  // Cache the price options
                  final options = buildPriceOptions(state.response.data!);
                  productPriceOptionsCache[productId] = options;

                  // Update placeholder leadItems with actual product data
                  final existingItemIndex = leadItems.indexWhere((item) => item.productId == productId);
                  if (existingItemIndex != -1) {
                    final existingItem = leadItems[existingItemIndex];
                    // Check if this is a placeholder (has 'Loading...' as name)
                    if (existingItem.productName == 'Loading...') {
                      // Update with actual product data
                      setState(() {
                        leadItems[existingItemIndex] = LeadItemDraft(
                          productId: productId,
                          productName: state.response.data!.name ?? 'Unknown',
                          productCode: state.response.data!.productCode ?? '',
                          baseRate: 0,
                        );
                  });
                }
              }

              // Trigger UI update
              setState(() {});
            }
          }
        },
      ),
    ],
    child: Form(
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
                      _buildSelectedProductDetailsSection(),
                      // const SizedBox(height: 24),
                      // _buildQuantitySection(),
                      const SizedBox(height: 24),
                      _buildFinancialSummarySection(),
                      // const SizedBox(height: 24),
                      // _buildDeadlineSection(),
                      const SizedBox(height: 24),
                      _buildRemarksSection(),
                      const SizedBox(height: 24),

                      const SizedBox(height: 80), // Space for bottom button
                    ],
                  ),
                ),
              ),
              _buildBottomButton(),
            ],
          ),
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

          // _buildContextRow('Lead No', leadNumber),
          // _buildContextRow('Meeting Ref', meetingReference),
          //
          // const Divider(height: 32),

          /// MOM YES / NO
          const Text(
            'Is this lead from MOM?',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),

          Row(
            children: [
              _buildRadioOption('No', !useMom, () {
                setState(() {
                  useMom = false;
                  selectedMomId = null;
                });
              }),
              const SizedBox(width: 16),
              _buildRadioOption('Yes', useMom, () {
                setState(() {
                  useMom = true;
                  selectedClientId = null;
                });

                context.read<GetMomListBloc>().add(
                  FetchMomList(
                    isConvertedToLead: false,
                    showLoader: true,
                  ),
                );
              }),
            ],
          ),

          const SizedBox(height: 10),

          /// MOM AUTOCOMPLETE
          if (useMom) _buildMomAutocomplete(),

          /// MOM CLIENT INFO
          if (useMom && selectedMomId != null) _buildMomClientInfo(),

          /// CLIENT AUTOCOMPLETE (WHEN MOM = NO)
          if (!useMom) _buildClientAutocomplete(),

          const SizedBox(height: 10),

          /// DEADLINE DATE
          const Text(
            'Deadline Date *',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _deadlineController,
            readOnly: true,
            decoration: InputDecoration(
              hintText: 'Select deadline date',
              suffixIcon: const Icon(Icons.calendar_today, size: 20),
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
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select a deadline date';
              }
              return null;
            },
            onTap: () async {
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: deadlineDate ?? DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (picked != null) {
                setState(() {
                  deadlineDate = picked;
                  _deadlineController.text =
                      '${picked.day.toString().padLeft(2, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.year}';
                });
              }
            },
          ),

          const SizedBox(height: 10),

          /// ASSIGN TO USER
          _buildAssignToAutocomplete(),
        ],
      ),
    );
  }
  Widget _buildRadioOption(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(
            selected ? Icons.radio_button_checked : Icons.radio_button_off,
            color: selected ? AppColors.primaryTeal : Colors.grey,
          ),
          const SizedBox(width: 6),
          Text(label),
        ],
      ),
    );
  }
  Widget _buildMomAutocomplete() {
    return BlocBuilder<GetMomListBloc, GetMomListState>(
      builder: (context, state) {
        if (state is GetMomListLoading) {
          return const Padding(
            padding: EdgeInsets.all(12),
            child: CircularProgressIndicator(),
          );
        }

        if (state is GetMomListSuccess) {
          final options = state.response.data!.items
              ?.where((e) => e.isConvertedToLead == false)
              .map((e) => DropdownOption(
            id: e.id!,
            name: e.momId!,
          ))
              .toList();

          return CustomAutocompleteSection(
            title: 'Select MOM',
            options: options??[],
            selectedId: selectedMomId,
            icon: Icons.event_note,
            onSelected: (id, name) {
              final mom = state.response.data!.items
                  ?.firstWhere((e) => e.id == id);

              setState(() {
                selectedMomId = id;
                selectedMomClientName = mom?.clientName!;
                selectedMomClientCode = mom?.clientCode!;
                selectedClientId = mom?.clientId!;
                print("selectedMomClientName: $selectedMomClientName");
                print("selectedMomClientCode: $selectedMomClientCode");
                print("selectedClientId: $selectedClientId");
              });
            },
          );
        }

        return const SizedBox();
      },
    );
  }
  Widget _buildMomClientInfo() {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primaryTeal.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.primaryTeal),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            selectedMomClientName ?? '',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            'Client Code: ${selectedMomClientCode ?? ''}',
            style: const TextStyle(fontSize: 13),
          ),
        ],
      ),
    );
  }
  Widget _buildClientAutocomplete() {
    return BlocBuilder<GetClientListBloc, GetClientListState>(
      builder: (context, state) {
        if (state is GetClientListLoaded) {
          final options = state.response.data!
              .map((e) => DropdownOption(
            id: e.id!,
            name: '${e.firmName} (${e.clientCode})',
          ))
              .toList();

          return CustomAutocompleteSection(
            title: 'Client *',
            options: options,
            selectedId: selectedClientId,
            icon: Icons.business,
            onSelected: (id, name) {
              setState(() {
                selectedClientId = id;
                selectedClientName = name;
              });
            },
          );
        }

        return const SizedBox();
      },
    );
  }

  Widget _buildAssignToAutocomplete() {
    return BlocBuilder<GetAssignableUsersBloc, LeadState>(
      builder: (context, state) {
        if (state is GetAssignableUsersLoading && state.showLoader) {
          return const Padding(
            padding: EdgeInsets.all(10),
            child: CircularProgressIndicator(),
          );
        }

        if (state is GetAssignableUsersLoaded) {
          // Get the users list from response (LeadAssignResponseBody)
          final usersList = state.response.data ?? [];

          // Map users to dropdown options (Data has: id, fullName, role)
          final options = usersList.map((user) {
            return DropdownOption(
              id: user.id ?? '',
              name: user.fullName ?? 'Unknown',
            );
          }).toList();

          return CustomAutocompleteSection(
            title: 'Assign To',
            options: options,
            selectedId: selectedAssignedUserId,
            icon: Icons.person_add,
            onSelected: (id, name) {
              setState(() {
                selectedAssignedUserId = id;
                selectedAssignedUserName = name;
              });
            },
          );
        }

        // Trigger fetch if not loaded yet
        if (state is LeadInitial) {
          context.read<GetAssignableUsersBloc>().add(FetchAssignableUsers());
        }

        return const SizedBox();
      },
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
            // Remove from selected products and leadItems
            selectedProducts.remove(product.id ?? product.name ?? '');
            leadItems.removeWhere((item) => item.productId == product.id);
          } else {
            // Add to selected products
            selectedProducts.add(product.id ?? product.name ?? '');

            // Convert to LeadItemDraft and add to leadItems
            leadItems.add(LeadItemDraft(
              productId: product.id ?? '',
              productName: product.name ?? 'Unnamed Product',
              productCode: product.productCode ?? '',
              baseRate: product.lowestPricePerSqft?.toDouble() ?? 0.0,
              thicknessMm: 15, // Default thickness
              qtySqft: 0,
              process: '',
              remarks: '',
            ));

            // 🔥 Trigger API call to fetch product details
            if (product.id != null && product.id!.isNotEmpty) {
              context.read<GetCatalogueProductDetailsBloc>().add(
                FetchGetCatalogueProductDetails(
                  productId: product.id!,
                  showLoader: false,
                ),
              );
            }
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

                    // Convert to LeadItemDraft and add to leadItems
                    leadItems.add(LeadItemDraft(
                      productId: product.id ?? '',
                      productName: product.name ?? 'Unnamed Product',
                      productCode: product.productCode ?? '',
                      baseRate: product.lowestPricePerSqft?.toDouble() ?? 0.0,
                      thicknessMm: 15, // Default thickness
                      qtySqft: 0,
                      process: '',
                      remarks: '',
                    ));

                    // 🔥 Trigger API call to fetch product details
                    if (product.id != null && product.id!.isNotEmpty) {
                      context.read<GetCatalogueProductDetailsBloc>().add(
                        FetchGetCatalogueProductDetails(
                          productId: product.id!,
                          showLoader: false,
                        ),
                      );
                    }
                  } else {
                    selectedProducts.remove(product.id ?? product.name ?? '');
                    leadItems.removeWhere((item) => item.productId == product.id);
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
                      style: const TextStyle(
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
  void addProductToLead(LeadItemDraft product) {
    if (leadItems.any((e) => e.productId == product.productId)) return;

    final draft = LeadItemDraft(
      productId: product.productId!,
      productName: product.productName!,
      productCode: product.productCode!, baseRate: 0,

    );

    setState(() {
      leadItems.add(draft);
    });

    /// 👇 Fetch detailed pricing
    context.read<GetCatalogueProductDetailsBloc>().add(
      FetchGetCatalogueProductDetails(
        productId: product.productId!,
        showLoader: false,
      ),
    );
  }
  //
  // Widget _buildSelectedProductDetailsSection() {
  //   if (leadItems.isEmpty) return const SizedBox();
  //
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
  //
  //     ),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         const Text(
  //           'PRODUCT DETAILS',
  //           style: TextStyle(
  //             fontSize: 11,
  //             fontWeight: FontWeight.w600,
  //             color: AppColors.textSecondary,
  //             letterSpacing: 0.8,
  //           ),
  //         ),
  //         const SizedBox(height: 12),
  //
  //         ...leadItems.map((item) => _buildProductItemCard(item)).toList(),
  //
  //       ],
  //     ),
  //   );
  // }
  //
  // Widget _buildProductItemCard(LeadItemDraft item) {
  //   addProductToLead(item);
  //   return Container(
  //     margin: const EdgeInsets.only(bottom: 12),
  //     padding: const EdgeInsets.all(12),
  //     decoration: BoxDecoration(
  //       color: AppColors.grey50,
  //       borderRadius: BorderRadius.circular(10),
  //       border: Border.all(color: AppColors.grey200),
  //     ),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         /// Header
  //         Text(
  //           item.productName,
  //           style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
  //         ),
  //         const SizedBox(height: 4),
  //         Text(
  //           'Base Price (15mm): ₹${item.baseRate}/sqft',
  //           style: TextStyle(fontSize: 12, color: Colors.grey[600]),
  //         ),
  //
  //         const SizedBox(height: 12),
  //
  //         /// 🔹 PRICE DROPDOWN - Using cached options per product
  //         Builder(
  //           builder: (context) {
  //             // Check if we have cached options for this product
  //             final cachedOptions = productPriceOptionsCache[item.productId];
  //
  //             if (cachedOptions != null && cachedOptions.isNotEmpty) {
  //               // We have cached options - show dropdown
  //               return Column(
  //                 crossAxisAlignment: CrossAxisAlignment.start,
  //                 children: [
  //                   DropdownButtonFormField<String>(
  //                     value: item.selectedPriceCode != null &&
  //                            cachedOptions.any((o) => o.code == item.selectedPriceCode)
  //                         ? item.selectedPriceCode
  //                         : null,
  //                     hint: const Text('Select Price Grade'),
  //                     decoration: InputDecoration(
  //                       labelText: 'Price Grade *',
  //                       border: OutlineInputBorder(
  //                         borderRadius: BorderRadius.circular(8),
  //                       ),
  //                       contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
  //                     ),
  //                     isExpanded: true,
  //                     items: cachedOptions.map((o) {
  //                       return DropdownMenuItem(
  //                         value: o.code,
  //                         child: Row(
  //                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                           children: [
  //                             Text(
  //                               o.label,
  //                               style: const TextStyle(fontSize: 14),
  //                             ),
  //                             Text(
  //                               '₹${o.price.toStringAsFixed(0)}/sqft',
  //                               style: const TextStyle(
  //                                 fontSize: 13,
  //                                 fontWeight: FontWeight.w600,
  //                                 color: AppColors.primaryTeal,
  //                               ),
  //                             ),
  //                           ],
  //                         ),
  //                       );
  //                     }).toList(),
  //                     onChanged: (code) {
  //                       if (code != null) {
  //                         final selected = cachedOptions.firstWhere((e) => e.code == code);
  //
  //                         setState(() {
  //                           item.selectedPriceCode = selected.code;
  //                           item.selectedRatePerSqft = selected.price;
  //                           // Trigger full calculation
  //                           item.calculatePricing();
  //                         });
  //                       }
  //                     },
  //                   ),
  //                   if (item.selectedPriceCode != null && item.selectedRatePerSqft > 0)
  //                     Padding(
  //                       padding: const EdgeInsets.only(top: 8),
  //                       child: Container(
  //                         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
  //                         decoration: BoxDecoration(
  //                           color: AppColors.primaryTeal.withValues(alpha: 0.1),
  //                           borderRadius: BorderRadius.circular(6),
  //                         ),
  //                         child: Row(
  //                           mainAxisSize: MainAxisSize.min,
  //                           children: [
  //                             Icon(Icons.check_circle, size: 16, color: AppColors.primaryTeal),
  //                             const SizedBox(width: 6),
  //                             Text(
  //                               'Selected Rate: ₹${item.selectedRatePerSqft.toStringAsFixed(0)}/sqft',
  //                               style: const TextStyle(
  //                                 fontSize: 12,
  //                                 fontWeight: FontWeight.w600,
  //                                 color: AppColors.primaryTeal,
  //                               ),
  //                             ),
  //                           ],
  //                         ),
  //                       ),
  //                     ),
  //                 ],
  //               );
  //             } else if (cachedOptions != null && cachedOptions.isEmpty) {
  //               // Cached but empty - no pricing available
  //               return Container(
  //                 padding: const EdgeInsets.all(12),
  //                 decoration: BoxDecoration(
  //                   color: Colors.orange.withValues(alpha: 0.1),
  //                   borderRadius: BorderRadius.circular(8),
  //                   border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
  //                 ),
  //                 child: Row(
  //                   children: [
  //                     Icon(Icons.info_outline, size: 16, color: Colors.orange[700]),
  //                     const SizedBox(width: 8),
  //                     Expanded(
  //                       child: Text(
  //                         'No pricing grades available for this product',
  //                         style: TextStyle(fontSize: 12, color: Colors.orange[700]),
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               );
  //             } else {
  //               // Check if currently loading this product
  //               return BlocBuilder<GetCatalogueProductDetailsBloc, GetCatalogueProductDetailsState>(
  //                 builder: (context, state) {
  //                   if (state is GetCatalogueProductDetailsLoading) {
  //                     return Container(
  //                       padding: const EdgeInsets.all(16),
  //                       child: Row(
  //                         children: [
  //                           const SizedBox(
  //                             width: 16,
  //                             height: 16,
  //                             child: CircularProgressIndicator(strokeWidth: 2),
  //                           ),
  //                           const SizedBox(width: 12),
  //                           Text(
  //                             'Loading pricing options...',
  //                             style: TextStyle(fontSize: 12, color: Colors.grey[600]),
  //                           ),
  //                         ],
  //                       ),
  //                     );
  //                   }
  //
  //                   if (state is GetCatalogueProductDetailsError) {
  //                     return Container(
  //                       padding: const EdgeInsets.all(12),
  //                       decoration: BoxDecoration(
  //                         color: Colors.red.withValues(alpha: 0.1),
  //                         borderRadius: BorderRadius.circular(8),
  //                         border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
  //                       ),
  //                       child: Row(
  //                         children: [
  //                           const Icon(Icons.error_outline, size: 16, color: Colors.red),
  //                           const SizedBox(width: 8),
  //                           Expanded(
  //                             child: Text(
  //                               'Failed to load pricing. Please try again.',
  //                               style: TextStyle(fontSize: 12, color: Colors.red[700]),
  //                             ),
  //                           ),
  //                           TextButton(
  //                             onPressed: () {
  //                               context.read<GetCatalogueProductDetailsBloc>().add(
  //                                 FetchGetCatalogueProductDetails(
  //                                   productId: item.productId,
  //                                   showLoader: false,
  //                                 ),
  //                               );
  //                             },
  //                             child: const Text('Retry', style: TextStyle(fontSize: 12)),
  //                           ),
  //                         ],
  //                       ),
  //                     );
  //                   }
  //
  //                   // Not loaded yet - waiting
  //                   return Container(
  //                     padding: const EdgeInsets.all(12),
  //                     decoration: BoxDecoration(
  //                       color: Colors.grey[100],
  //                       borderRadius: BorderRadius.circular(8),
  //                       border: Border.all(color: Colors.grey[300]!),
  //                     ),
  //                     child: Row(
  //                       children: [
  //                         Icon(Icons.info_outline, size: 16, color: Colors.grey[600]),
  //                         const SizedBox(width: 8),
  //                         Expanded(
  //                           child: Text(
  //                             'Product selected - loading pricing...',
  //                             softWrap: true,
  //                             style: TextStyle(fontSize: 12, color: Colors.grey[600]),
  //                           ),
  //                         ),
  //                       ],
  //                     ),
  //                   );
  //                 },
  //               );
  //             }
  //           },
  //         ),
  //
  //         const SizedBox(height: 12),
  //
  //         /// Thickness + Quantity
  //         Row(
  //           crossAxisAlignment: CrossAxisAlignment.end,
  //           children: [
  //             Column(
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 const Text('Thickness'),
  //                 const SizedBox(height: 6),
  //                 thicknessStepper(
  //                   value: item.thicknessMm,
  //                   onChanged: (v) {
  //                     setState(() {
  //                       item.thicknessMm = v;
  //                       // Trigger full calculation
  //                       item.calculatePricing();
  //                     });
  //                   },
  //                 ),
  //               ],
  //             ),
  //             const SizedBox(width: 16),
  //             Expanded(
  //               child: TextFormField(
  //                 controller: item.qtyController,
  //                 keyboardType: TextInputType.number,
  //                 decoration: const InputDecoration(
  //                   labelText: 'Quantity (sqft)',
  //                 ),
  //                 onChanged: (val) {
  //                   setState(() {
  //                     item.qtySqft = double.tryParse(val) ?? 0;
  //                     // Trigger full calculation
  //
  //                     item.calculatePricing();
  //                   });
  //                 },
  //               ),
  //             ),
  //           ],
  //         ),
  //
  //         const SizedBox(height: 12),
  //
  //         /// Process Type Dropdown
  //         DropdownButtonFormField<String>(
  //           value: item.process.isEmpty ? null : item.process,
  //           decoration: InputDecoration(
  //             labelText: 'Process Type *',
  //             hintText: 'Select process type',
  //             border: OutlineInputBorder(
  //               borderRadius: BorderRadius.circular(8),
  //             ),
  //             contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
  //           ),
  //           items: const [
  //             DropdownMenuItem(value: 'Polished', child: Text('Polished')),
  //             DropdownMenuItem(value: 'Honed', child: Text('Honed')),
  //             DropdownMenuItem(value: 'Brushed', child: Text('Brushed')),
  //             DropdownMenuItem(value: 'Flamed', child: Text('Flamed')),
  //             DropdownMenuItem(value: 'Bush Hammered', child: Text('Bush Hammered')),
  //             DropdownMenuItem(value: 'Natural', child: Text('Natural')),
  //           ],
  //           onChanged: (value) {
  //             setState(() {
  //               item.process = value ?? '';
  //             });
  //           },
  //         ),
  //
  //         const SizedBox(height: 12),
  //
  //         /// Remarks Field
  //         TextFormField(
  //           controller: item.remarksController,
  //           decoration: InputDecoration(
  //             labelText: 'Remarks',
  //             hintText: 'Add any remarks for this product',
  //             border: OutlineInputBorder(
  //               borderRadius: BorderRadius.circular(8),
  //             ),
  //             contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
  //           ),
  //           maxLines: 2,
  //           onChanged: (value) {
  //             setState(() {
  //               item.remarks = value;
  //             });
  //           },
  //         ),
  //
  //         const SizedBox(height: 12),
  //
  //         /// Calculation Summary
  //         Container(
  //           padding: const EdgeInsets.all(12),
  //           decoration: BoxDecoration(
  //             color: AppColors.grey50,
  //             borderRadius: BorderRadius.circular(8),
  //             border: Border.all(color: AppColors.grey200),
  //           ),
  //           child: Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               const Text(
  //                 'Pricing Breakdown',
  //                 style: TextStyle(
  //                   fontSize: 12,
  //                   fontWeight: FontWeight.w600,
  //                   color: AppColors.textSecondary,
  //                 ),
  //               ),
  //               const SizedBox(height: 8),
  //
  //               // Base Amount - Always shown
  //               _buildCalculationRow(
  //                 'Base Amount',
  //                 '₹${item.selectedRatePerSqft.toStringAsFixed(2)} × ${item.qtySqft.toStringAsFixed(0)} sqft',
  //                 '₹${item.baseAmount.toStringAsFixed(2)}',
  //               ),
  //
  //               const Divider(height: 12),
  //
  //               // Slab 1 - Shown for 16mm and above
  //               if (item.thicknessMm >= 16)
  //                 _buildCalculationRow(
  //                   'Slab 1 (${(item.slab1Percent * 100).toStringAsFixed(0)}%)',
  //                   item.thicknessMm >= 19
  //                       ? 'Base 18mm thickness: ${item.qtySqft < 5000 ? "Qty < 5000 → 15%" : "Qty ≥ 5000 → 10%"}'
  //                       : '${item.thicknessMm}mm thickness: ${item.qtySqft < 5000 ? "Qty < 5000 → 15%" : "Qty ≥ 5000 → 10%"}',
  //                   '+₹${item.slab1Amount.toStringAsFixed(2)}',
  //                   isPositive: true,
  //                 )
  //               else
  //                 _buildCalculationRow(
  //                   'Slab 1 (0%)',
  //                   'Not applicable for ${item.thicknessMm}mm thickness',
  //                   '₹0.00',
  //                 ),
  //
  //               // Slab 2 - Only shown for 19mm or 20mm
  //               if (item.thicknessMm == 19 || item.thicknessMm == 20) ...[
  //                 const Divider(height: 12),
  //                 _buildCalculationRow(
  //                   'Slab 2 (${(item.slab2PerMmPercent * 100).toStringAsFixed(0)}% per mm)',
  //                   '${item.thicknessMm}mm: +${item.extraMm.toStringAsFixed(0)}mm extra × ${item.qtySqft >= 5000 ? "3%" : "5%"}',
  //                   '+₹${item.slab2Amount.toStringAsFixed(2)}',
  //                   isPositive: true,
  //                 ),
  //               ],
  //
  //               const Divider(height: 12, thickness: 2),
  //
  //               // Line Total - Always shown
  //               _buildCalculationRow(
  //                 'Line Total',
  //                 item.thicknessMm >= 19
  //                     ? 'Base + Slab 1 + Slab 2'
  //                     : item.thicknessMm >= 16
  //                         ? 'Base + Slab 1'
  //                         : 'Base Only',
  //                 '₹${item.lineTotal.toStringAsFixed(2)}',
  //                 isBold: true,
  //               ),
  //             ],
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }


  Widget _buildSelectedProductDetailsSection() {
    if (leadItems.isEmpty) return const SizedBox();

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Header
          Row(
            children: const [
              Icon(Icons.inventory_2_outlined,
                  size: 18, color: AppColors.primaryTeal),
              SizedBox(width: 8),
              Text(
                'Product Details',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Selected materials with quantity & pricing',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),

          ...leadItems.map(
                (item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildProductItemCard(item),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildProductItemCard(LeadItemDraft item) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.grey50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Title
          Text(
            item.productName,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            'Base Price (15mm): ₹${item.baseRate}/sqft',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),

          const SizedBox(height: 14),

          /// PRICE GRADE DROPDOWN (UNCHANGED LOGIC)
          _buildPriceDropdown(item),

          const SizedBox(height: 14),

          /// Thickness + Qty
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Thickness',
                      style: TextStyle(fontSize: 12)),
                  const SizedBox(height: 6),
                  thicknessStepper(
                    value: item.thicknessMm,
                    onChanged: (v) {
                      setState(() {
                        item.thicknessMm = v;
                        item.calculatePricing();
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: item.qtyController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Quantity (sqft)',
                  ),
                  onChanged: (val) {
                    setState(() {
                      item.qtySqft = double.tryParse(val) ?? 0;
                      item.calculatePricing();
                    });
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          /// Process
          DropdownButtonFormField<String>(
            value: item.process.isEmpty ? null : item.process,
            decoration: InputDecoration(
              labelText: 'Process Type',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            items: const [
              DropdownMenuItem(value: 'Polished', child: Text('Polished')),
              DropdownMenuItem(value: 'Honed', child: Text('Honed')),
              DropdownMenuItem(value: 'Brushed', child: Text('Brushed')),
              DropdownMenuItem(value: 'Flamed', child: Text('Flamed')),
              DropdownMenuItem(value: 'Bush Hammered', child: Text('Bush Hammered')),
              DropdownMenuItem(value: 'Natural', child: Text('Natural')),
            ],
            onChanged: (v) => setState(() => item.process = v ?? ''),
          ),

          const SizedBox(height: 14),

          /// Remarks
          TextFormField(
            controller: item.remarksController,
            maxLines: 2,
            decoration: InputDecoration(
              labelText: 'Remarks',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onChanged: (v) => item.remarks = v,
          ),

          const SizedBox(height: 14),

          /// 🔢 PRICING SUMMARY (REDESIGNED)
          _buildPricingSummary(item),
        ],
      ),
    );
  }

  Widget _buildPriceDropdown(LeadItemDraft item) {
    return Builder(
      builder: (context) {
        final cachedOptions = productPriceOptionsCache[item.productId];

        /// 1️⃣ Cached & available
        if (cachedOptions != null && cachedOptions.isNotEmpty) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownButtonFormField<String>(
                value: item.selectedPriceCode != null &&
                    cachedOptions.any(
                            (o) => o.code == item.selectedPriceCode)
                    ? item.selectedPriceCode
                    : null,
                hint: const Text('Select Price Grade'),
                decoration: InputDecoration(
                  labelText: 'Price Grade *',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
                isExpanded: true,
                items: cachedOptions.map((o) {
                  return DropdownMenuItem<String>(
                    value: o.code,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          o.label,
                          style: const TextStyle(fontSize: 14),
                        ),
                        Text(
                          '₹${o.price.toStringAsFixed(0)}/sqft',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryTeal,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (code) {
                  if (code != null) {
                    final selected =
                    cachedOptions.firstWhere((e) => e.code == code);

                    setState(() {
                      item.selectedPriceCode = selected.code;
                      item.selectedRatePerSqft = selected.price;

                      /// 🔥 Important – triggers slab & total calculation
                      item.calculatePricing();
                    });
                  }
                },
              ),

              /// Selected price badge
              if (item.selectedPriceCode != null &&
                  item.selectedRatePerSqft > 0)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryTeal.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.check_circle,
                            size: 16, color: AppColors.primaryTeal),
                        const SizedBox(width: 6),
                        Text(
                          'Selected Rate: ₹${item.selectedRatePerSqft.toStringAsFixed(0)}/sqft',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryTeal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        }

        /// 2️⃣ Cached but empty (no pricing)
        if (cachedOptions != null && cachedOptions.isEmpty) {
          return _infoBox(
            icon: Icons.info_outline,
            color: Colors.orange,
            message: 'No pricing grades available for this product',
          );
        }

        /// 3️⃣ Fetching / error handling
        return BlocBuilder<GetCatalogueProductDetailsBloc,
            GetCatalogueProductDetailsState>(
          builder: (context, state) {
            if (state is GetCatalogueProductDetailsLoading) {
              return Row(
                children: const [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Loading pricing options...',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              );
            }

            if (state is GetCatalogueProductDetailsError) {
              return _errorBox(
                message: 'Failed to load pricing',
                onRetry: () {
                  context.read<GetCatalogueProductDetailsBloc>().add(
                    FetchGetCatalogueProductDetails(
                      productId: item.productId,
                      showLoader: false,
                    ),
                  );
                },
              );
            }

            return _infoBox(
              icon: Icons.info_outline,
              color: Colors.grey,
              message: 'Product selected – loading pricing...',
            );
          },
        );
      },
    );
  }
  Widget _infoBox({
    required IconData icon,
    required Color color,
    required String message,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(fontSize: 12, color: color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _errorBox({
    required String message,
    required VoidCallback onRetry,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, size: 16, color: Colors.red),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(fontSize: 12, color: Colors.red),
            ),
          ),
          TextButton(
            onPressed: onRetry,
            child: const Text('Retry', style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }



  Widget _buildPricingSummary(LeadItemDraft item) {
    final extraCharges = item.slab1Amount + item.slab2Amount;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pricing Summary',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 10),

          _buildCalculationRow(
            'Base Amount',
            '${item.qtySqft.toStringAsFixed(0)} sqft × ₹${item.selectedRatePerSqft.toStringAsFixed(0)}',
            '₹${item.baseAmount.toStringAsFixed(2)}',
          ),

          const Divider(height: 16),

          /// 🔹 MERGED SLABS
          _buildCalculationRow(
            'Extra Charges',
            item.thicknessMm >= 19
                ? 'Thickness & quantity adjustments'
                : item.thicknessMm >= 16
                ? 'Thickness adjustment'
                : 'Not applicable',
            extraCharges > 0
                ? '+₹${extraCharges.toStringAsFixed(2)}'
                : '₹0.00',
            isPositive: extraCharges > 0,
          ),

          const Divider(height: 18, thickness: 1.5),

          _buildCalculationRow(
            'Line Total',
            'Final product amount',
            '₹${item.lineTotal.toStringAsFixed(2)}',
            isBold: true,
          ),
        ],
      ),
    );
  }


  Widget _buildCalculationRow(String label, String detail, String value, {bool isPositive = false, bool isBold = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
              if (detail.isNotEmpty)
                Text(
                  detail,
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.textSecondary,
                  ),
                ),
            ],
          ),
        ),
        Text(
          isPositive ? '+$value' : value,
          style: TextStyle(
            fontSize: isBold ? 14 : 12,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w600,
            color: isPositive ? Colors.green[700] : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }



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
          const Text(
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
          const Text(
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
          const Text(
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

  Widget _buildFinancialSummarySection() {
    // Calculate totals whenever this widget builds
    _calculateTotals();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'FINANCIAL SUMMARY',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 16),

          // Materials Total (Read-only)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: _amountRowReadOnly(
              label: 'Materials Total',
              value: materialsTotal,
            ),
          ),


          const SizedBox(height: 16),

          // Tax Amount
          // Transport Amount
          _amountRowField(
            label: 'Transport Amount',
            controller: _transportAmountController,
            onChanged: (value) {
              setState(() {
                transportAmount = double.tryParse(value) ?? 0;
              });
            },
          ),

          const SizedBox(height: 12),

// Other Charges
          _amountRowField(
            label: 'Other Charges',
            controller: _otherChargesController,
            onChanged: (value) {
              setState(() {
                otherChargesAmount = double.tryParse(value) ?? 0;
              });
            },
          ),

          const SizedBox(height: 12),

// Tax Amount
          _amountRowField(
            label: 'Tax Amount',
            controller: _taxAmountController,
            onChanged: (value) {
              setState(() {
                taxAmount = double.tryParse(value) ?? 0;
              });
            },
          ),


          const SizedBox(height: 16),
          const Divider(thickness: 2),
          const SizedBox(height: 16),

          // Grand Total
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryTeal.withValues(alpha: 0.1),
                  AppColors.primaryTeal.withValues(alpha: 0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.primaryTeal,
                width: 2,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'GRAND TOTAL',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                        letterSpacing: 0.8,
                      ),
                    ),

                  ],
                ),
                Text(
                  '₹${grandTotal.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primaryTeal,
                  ),
                ),
              ],
            ),
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
          const Text(
            'REMARKS',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 12),
          _buildTextField('Product remarks', _productRemarksController, maxLines: 1),
          const SizedBox(height: 16),
          _buildTextField('Notes', _notesController, maxLines: 2),
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
          style: const TextStyle(
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

  Widget _amountRowReadOnly({
    required String label,
    required double value,
    Color valueColor = AppColors.primaryTeal,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        /// Label (same width as input rows)
        SizedBox(
          width: 140,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
        ),

        /// Value Box (same height, border, radius)
        Expanded(
          child: Container(
            height: 55,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            alignment: Alignment.centerLeft,
            decoration: BoxDecoration(
              color: AppColors.grey50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.grey200),
            ),
            child: Text(
              '₹ ${value.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: valueColor,
              ),
            ),
          ),
        ),
      ],
    );
  }



  Widget _amountRowField({
    required String label,
    required TextEditingController controller,
    required ValueChanged<String> onChanged,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        /// Label
        SizedBox(
          width: 140,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),

        /// Input
        Expanded(
          child: TextFormField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'Enter amount',
              prefixText: '₹ ',
              contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onChanged: onChanged,
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
              backgroundColor: SessionManager.getUserRole() =="superadmin"?AppColors.superAdminPrimary:SessionManager.getUserRole() =="admin"?
              AppColors.adminPrimaryDark :AppColors.primaryTealDark,
              foregroundColor: AppColors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
            child: const Text(
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

  double calculateRate({
    required double basePrice,
    required int thickness,
    required double qty,
  }) {
    final bool isHighQty = qty >= 5000;
    double multiplier = 1.0;

    if (thickness <= 15) {
      multiplier = 1.0;
    } else if (thickness <= 18) {
      multiplier = isHighQty ? 1.10 : 1.15;
    } else {
      final extraMm = thickness - 18;
      multiplier = isHighQty
          ? (1 + 0.10 + extraMm * 0.03)
          : (1 + 0.15 + extraMm * 0.05);
    }

    return basePrice * multiplier;
  }
  void recalculateItem(LeadItemDraft item) {
    item.ratePerSqft = calculateRate(
      basePrice: item.baseRate,
      thickness: item.thicknessMm,
      qty: item.qtySqft,
    );

    item.lineTotal = item.ratePerSqft * item.qtySqft;
  }

  /// Calculate all financial totals
  void _calculateTotals() {
    // Materials Total = Sum of all line totals
    materialsTotal = leadItems.fold(0.0, (sum, item) => sum + item.lineTotal);

    // Grand Total = materialsTotal + transportAmount + otherChargesAmount + taxAmount
    grandTotal = materialsTotal + transportAmount + otherChargesAmount + taxAmount;
  }

  Widget thicknessStepper({
    required int value,
    required ValueChanged<int> onChanged,
  }) {
    const int min = 15;
    const int max = 20;

    return Container(
      width: 120,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.grey300),
        color: Colors.white,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          /// Value
          Expanded(
            child: Text(
              '$value mm',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          /// Increase/Decrease buttons
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              /// Increase
              InkWell(
                onTap: value < max ? () => onChanged(value + 1) : null,
                child: Icon(
                  Icons.keyboard_arrow_up,
                  size: 20,
                  color: value < max ? AppColors.primaryTeal : Colors.grey,
                ),
              ),
              const SizedBox(height: 4),
              /// Decrease
              InkWell(
                onTap: value > min ? () => onChanged(value - 1) : null,
                child: Icon(
                  Icons.keyboard_arrow_down,
                  size: 20,
                  color: value > min ? AppColors.primaryTeal : Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }


  void _submitLead() {
    // Validate form
    if (_formKey.currentState!.validate()) {
      // Validate at least one product is added
      if (leadItems.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please add at least one product'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }

      // Validate all products have required data
      for (var item in leadItems) {
        if (item.selectedPriceCode == null || item.selectedPriceCode!.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Please select price grade for ${item.productName}'),
              backgroundColor: AppColors.error,
            ),
          );
          return;
        }
        if (item.qtySqft <= 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Please enter quantity for ${item.productName}'),
              backgroundColor: AppColors.error,
            ),
          );
          return;
        }
        if (item.process.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Please select process type for ${item.productName}'),
              backgroundColor: AppColors.error,
            ),
          );
          return;
        }
      }

      // Validate client or MOM is selected
      if (!useMom && (selectedClientId == null || selectedClientId!.isEmpty)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a client'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }

      if (useMom && (selectedMomId == null || selectedMomId!.isEmpty)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a MOM'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }

      // Validate Assign To is selected (required field)
      if (selectedAssignedUserId == null || selectedAssignedUserId!.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please assign the lead to a user'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }

      // Get assigned user ID
      final assignedUserId = selectedAssignedUserId!;

      // Format deadline date to yyyy-MM-dd
      String? formattedDeadline;
      if (deadlineDate != null) {
        formattedDeadline = '${deadlineDate!.year}-${deadlineDate!.month.toString().padLeft(2, '0')}-${deadlineDate!.day.toString().padLeft(2, '0')}';
      }

      // Calculate totals
      _calculateTotals();

      // Build items list
      final items = leadItems.map((item) {
        return NewLead.Items(
          productId: item.productId,
          qtySqft: item.qtySqft.toInt(),
          thicknessMm: item.thicknessMm,
          selectedPriceCode: item.selectedPriceCode,
          selectedRatePerSqft: item.selectedRatePerSqft.toInt(),
          baseAmount: item.baseAmount.toInt(),
          slab1Percent: (item.slab1Percent * 100).toInt(), // Convert to percentage (0.15 -> 15)
          slab1Amount: item.slab1Amount.toInt(),
          slab2PerMmPercent: (item.slab2PerMmPercent * 100).toInt(), // Convert to percentage (0.05 -> 5)
          extraMm: item.extraMm.toInt(),
          slab2Amount: item.slab2Amount.toInt(),
          lineTotal: item.lineTotal.toInt(),
          productCode: item.productCode,
          productName: item.productName,
          productProcess: item.process,
          productRemarks: item.remarks,
        );
      }).toList();

      // Create request body
      final requestBody = NewLead.PostNewLeadRequestBody(
        clientId:  selectedClientId,
        momId: useMom ? selectedMomId : null,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
        deadlineDate: formattedDeadline,
        assignedToUserId: assignedUserId,
        transportAmount: transportAmount.toInt(),
        otherChargesAmount: otherChargesAmount.toInt(),
        taxAmount: taxAmount.toInt(),
        materialsTotal: materialsTotal.toInt(),
        grandTotal: grandTotal.toInt(),
        pricingRuleVersion: "v1", // You can make this dynamic if needed
        items: items,
      );

      // Print request body for debugging
      log("📤 New Lead Request Body: ${jsonEncode(requestBody.toJson())}");

      // Submit the lead using PostNewLeadBloc
      context.read<PostNewLeadBloc>().add(
        SubmitNewLead(
          requestBody: requestBody,
          showLoader: true,
        ),
      );
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
    _transportAmountController.dispose();
    _otherChargesController.dispose();
    _taxAmountController.dispose();
    super.dispose();
  }
}


class LeadItemDraft {
  String productId;
  String productName;
  String productCode;

  double baseRate; // price for 15mm
  int thicknessMm; // 15–20
  double qtySqft;

  String process;
  String remarks;

  /// Pricing
  String? selectedPriceCode; // TRADER_A, ARCH_A, etc
  double selectedRatePerSqft;

  /// Calculated fields for API
  double baseAmount; // selectedRatePerSqft × qtySqft
  double slab1Percent; // 15% if qty<5000, else 10%
  double slab1Amount; // baseAmount × slab1Percent
  double slab2PerMmPercent; // To be calculated based on thickness
  double extraMm; // thicknessMm - 15 (if > 15)
  double slab2Amount; // To be calculated
  double lineTotal; // Final total after all calculations

  // Legacy field
  double ratePerSqft;

  // Controllers for form fields
  final TextEditingController qtyController = TextEditingController();
  final TextEditingController remarksController = TextEditingController();

  LeadItemDraft({
    required this.productId,
    required this.productName,
    required this.productCode,
    required this.baseRate,
    this.thicknessMm = 15,
    this.selectedPriceCode,
    this.selectedRatePerSqft = 0,
    this.qtySqft = 0,
    this.process = '',
    this.remarks = '',
    this.ratePerSqft = 0,
    this.baseAmount = 0,
    this.slab1Percent = 0,
    this.slab1Amount = 0,
    this.slab2PerMmPercent = 0,
    this.extraMm = 0,
    this.slab2Amount = 0,
    this.lineTotal = 0,
  });

  // Dispose method to clean up controllers
  void dispose() {
    qtyController.dispose();
    remarksController.dispose();
  }

  /// Calculate all pricing fields
  void calculatePricing() {
    // Step 1: Base Amount
    baseAmount = selectedRatePerSqft * qtySqft;

    // Step 2: Slab 1 - Applicable for thickness 16mm and above
    // For 19mm and 20mm, Slab 1 is calculated as if it's 18mm
    if (thicknessMm >= 16) {
      // Slab 1 Percent (15% if qty < 5000, else 10%)
      slab1Percent = qtySqft < 5000 ? 0.15 : 0.10;
      // Slab 1 Amount
      slab1Amount = baseAmount * slab1Percent;
    } else {
      slab1Percent = 0;
      slab1Amount = 0;
    }

    // Step 3: Slab 2 - Only applicable for thickness 19mm or 20mm
    // This is for the EXTRA thickness beyond 18mm
    if (thicknessMm == 19 || thicknessMm == 20) {
      // Extra MM (1 if 19mm, 2 if 20mm)
      extraMm = (thicknessMm - 18).toDouble();

      // Slab 2 Percent (3% if qty >= 5000, else 5%)
      slab2PerMmPercent = qtySqft >= 5000 ? 0.03 : 0.05;

      // Slab 2 Amount = baseAmount × slab2Percent × extraMm
      slab2Amount = baseAmount * slab2PerMmPercent * extraMm;
    } else {
      extraMm = 0;
      slab2PerMmPercent = 0;
      slab2Amount = 0;
    }

    // Step 4: Line Total = Base + Slab1 + Slab2
    lineTotal = baseAmount + slab1Amount + slab2Amount;
  }
}



class PriceOption {
  final String label; // UI label
  final String code;  // API code (CAPS)
  final double price;

  PriceOption({
    required this.label,
    required this.code,
    required this.price,
  });
}
