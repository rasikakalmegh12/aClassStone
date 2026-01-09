// Add this new file: lib/pages/add_to_lead_page.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../api/models/response/GetCatalogueProductResponseBody.dart';
import '../../../../core/session/session_manager.dart';
import '../../../catalog/catalog_main.dart';


class AddToLeadPage extends StatefulWidget {
  final List<Items> selectedProducts;
  const AddToLeadPage({super.key, required this.selectedProducts});

  @override
  State<AddToLeadPage> createState() => _AddToLeadPageState();
}

class _AddToLeadPageState extends State<AddToLeadPage> {
  late List<Items> _selectedProducts;
  final TextEditingController _leadNameController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();


  @override
  void initState() {
    super.initState();
    _selectedProducts = []; // default empty
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final extra = GoRouterState.of(context).extra as List<Items>?;
      if (extra != null && mounted) {
        setState(() {
          _selectedProducts = List<Items>.from(extra);
        });
      }
    });
  }
  void _proceedToCreateLead(BuildContext context) {

    context.pushNamed(
      'newLeadScreen',
      extra: {
        // 'leadName': _leadNameController.text,
        // 'notes': _notesController.text,
        'products': _selectedProducts.map((p) => p.id!).toList(),
      },
    );
    // Navigate to NewLeadScreen with pre-selected products
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => NewLeadScreen(
    //       // Pass lead info
    //       existingLead: {
    //         'leadName': _leadNameController.text,
    //         'notes': _notesController.text,
    //         'products': _selectedProducts.map((p) => p.id!).toList(),
    //       },
    //     ),
    //   ),
    // );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${_selectedProducts.length} Products to Lead'),
        backgroundColor: RoleTheme.primary(SessionManager.getUserRole()),
        // actions: [
        //   TextButton(
        //     onPressed: _selectedProducts.isEmpty
        //         ? null
        //         : () => _saveLead(),
        //     child: const Text(
        //       'Save Lead',
        //       style: TextStyle(fontWeight: FontWeight.bold),
        //     ),
        //   ),
        // ],
      ),
      floatingActionButton: _selectedProducts.isNotEmpty
          ? FloatingActionButton.extended(
        onPressed: () => _proceedToCreateLead(context),
        backgroundColor: Colors.green,
        icon: const Icon(Icons.arrow_forward,color: Colors.white,),
        label: Text('Proceed (${_selectedProducts.length})',style: const TextStyle(color: Colors.white),),
      )
          : null,

      body: Column(
        children: [
          // Lead Info Form
          // Container(
          //   color: Colors.grey[50],
          //   padding: const EdgeInsets.all(16),
          //   child: Column(
          //     crossAxisAlignment: CrossAxisAlignment.start,
          //     children: [
          //       Text(
          //         'Lead Information',
          //         style: TextStyle(
          //           fontSize: 18,
          //           fontWeight: FontWeight.bold,
          //           color: Colors.grey[800],
          //         ),
          //       ),
          //       const SizedBox(height: 16),
          //       TextField(
          //         controller: _leadNameController,
          //         decoration: InputDecoration(
          //           labelText: 'Lead Name',
          //           hintText: 'e.g., Hotel Project Mumbai',
          //           border: OutlineInputBorder(
          //             borderRadius: BorderRadius.circular(12),
          //           ),
          //           prefixIcon: const Icon(Icons.person),
          //         ),
          //       ),
          //       const SizedBox(height: 12),
          //       TextField(
          //         controller: _notesController,
          //         maxLines: 3,
          //         decoration: InputDecoration(
          //           labelText: 'Notes',
          //           hintText: 'Additional requirements...',
          //           border: OutlineInputBorder(
          //             borderRadius: BorderRadius.circular(12),
          //           ),
          //           prefixIcon: const Icon(Icons.note),
          //         ),
          //       ),
          //     ],
          //   ),
          // ),

          // Products List
          Expanded(
            child: _selectedProducts.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No products selected',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Back to Catalogue'),
                  ),
                ],
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _selectedProducts.length,
              itemBuilder: (context, index) {
                final product = _selectedProducts[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Product Image
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius:
                              BorderRadius.circular(12),
                            ),
                            child: product.primaryImageUrl != null
                                ? Image.network(
                              product.primaryImageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error,
                                  stackTrace) =>
                                  Container(
                                    color: Colors.grey[300],
                                    child: const Icon(
                                      Icons.image_not_supported,
                                      color: Colors.grey,
                                    ),
                                  ),
                            )
                                : const Icon(
                              Icons.image_not_supported,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),

                        // Product Details
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.name ?? 'Unnamed Product',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Code: ${product.productCode ?? 'N/A'}',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                              if (product.lowestPricePerSqft != null)
                                Padding(
                                  padding:
                                  const EdgeInsets.only(top: 4),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.currency_rupee,
                                        size: 14,
                                        color: Colors.green,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${product.lowestPricePerSqft!.toInt()} /sqft',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: Colors.green,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),

                        // Remove button
                        IconButton(
                          icon: const Icon(
                            Icons.close,
                            color: Colors.red,
                          ),
                          onPressed: () {
                            setState(() {
                              _selectedProducts.removeAt(index);
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _saveLead() {
    // TODO: Call your API to save lead with:
    // - leadName: _leadNameController.text
    // - notes: _notesController.text
    // - productIds: _selectedProducts.map((p) => p.id).toList()

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Lead saved successfully!'),
        backgroundColor: Colors.green,
      ),
    );

    context.pop();
  }

  @override
  void dispose() {
    _leadNameController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}
