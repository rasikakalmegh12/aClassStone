import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../bloc/catalogue/get_catalogue_methods/get_catalogue_bloc.dart';
import '../../bloc/catalogue/get_catalogue_methods/get_catalogue_event.dart';
import '../../bloc/catalogue/get_catalogue_methods/get_catalogue_state.dart';
import '../../core/constants/app_colors.dart';
import '../../core/session/session_manager.dart';
import '../../api/models/response/GetCatalogueProductDetailsResponseBody.dart';

/// ==========================
/// SIMPLE PRODUCT MODEL (for list view only)
/// ==========================

class SimpleProduct {
  final String id;
  final String productCode;
  final String name;
  final double pricePerSqft;
  final String productTypeName;
  final String? primaryImageUrl;

  SimpleProduct({
    required this.id,
    required this.productCode,
    required this.name,
    required this.pricePerSqft,
    required this.productTypeName,
    this.primaryImageUrl,
  });
}

/// ==========================
/// CATALOGUE PAGE
/// ==========================

class CataloguePage extends StatefulWidget {
  const CataloguePage({super.key});

  @override
  State<CataloguePage> createState() => _CataloguePageState();
}

class _CataloguePageState extends State<CataloguePage>
    with TickerProviderStateMixin {

  late AnimationController _controller;
  late Animation<double> _fade;

  String _search = '';
  Map<String, List<String>> _filters = {};
  List<SimpleProduct> _products = [];

  String get role => SessionManager.getUserRoleForPermissions();
  bool get isAdmin => role == 'admin' || role == 'superadmin';
  bool get isExecutive => role == 'executive';

  Color get primary => RoleTheme.primary(role);
  Color get light => RoleTheme.primaryLight(role);
  Color get dark => RoleTheme.primaryDark(role);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();

    // Load products from API using BLoC
    context.read<GetCatalogueProductListBloc>().add(FetchGetCatalogueProductList(
      page: 1,
      pageSize: 20,
      showLoader: true,
    ));
  }

  /// Handle pull-to-refresh
  Future<void> _handleRefresh() async {
    // Trigger BLoC to fetch fresh data without showing loader
    context.read<GetCatalogueProductListBloc>().add(
      FetchGetCatalogueProductList(page: 1, pageSize: 20, showLoader: false),
    );

    // Wait for the API call to complete
    await Future.delayed(const Duration(milliseconds: 800));
  }

  // Removed old _loadProducts method - now using BLoC

  /// Convert API Items to SimpleProduct model
  SimpleProduct _convertApiItemToSimpleProduct(dynamic item) {
    final hasValidImage = item.primaryImageUrl != null &&
                          item.primaryImageUrl.toString().isNotEmpty &&
                          item.primaryImageUrl.toString() != 'null';

    return SimpleProduct(
      id: item.id ?? '',
      productCode: item.productCode ?? '',
      name: item.name ?? 'Unnamed Product',
      pricePerSqft: (item.pricePerSqft ?? 0).toDouble(),
      productTypeName: item.productTypeName ?? 'Stone',
      primaryImageUrl: hasValidImage ? item.primaryImageUrl.toString() : null,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// ==========================
  /// UI
  /// ==========================

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    int columns;
    if (width < 600) {
      columns = 2;        // phones
    } else if (width < 900) {
      columns = 3;        // tablets
    } else {
      columns = 4;        // large screens
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: primary,
        title: const Text("Product Catalogue"),
        actions: [
          if (isExecutive)
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: _shareAllProducts,
            ),
          IconButton(
            icon: const Icon(Icons.tune),
            onPressed: _openFilters,
          ),
        ],
      ),

      floatingActionButton:  SessionManager.getUserRole().toString().toLowerCase() =="superadmin" || SessionManager.getUserRole().toString().toLowerCase() =="admin"  ?FloatingActionButton(
        onPressed: () {
          context.pushNamed("catalogueEntry");
        },
        backgroundColor: primary,
        child: const Icon(Icons.add,color: AppColors.white,),
      ):null,

      body: BlocBuilder<GetCatalogueProductListBloc, GetCatalogueProductListState>(
        builder: (context, state) {
          if (state is GetCatalogueProductListLoading && state.showLoader) {
            return Center(
              child: CircularProgressIndicator(color: primary),
            );
          }

          if (state is GetCatalogueProductListError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading products',
                    style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.message,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      context.read<GetCatalogueProductListBloc>().add(
                        FetchGetCatalogueProductList(page: 1, pageSize: 20, showLoader: true),
                      );
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                    style: ElevatedButton.styleFrom(backgroundColor: primary),
                  ),
                ],
              ),
            );
          }

          if (state is GetCatalogueProductListLoaded) {
            // Convert API response to SimpleProduct models
            final apiProducts = state.response.data?.items ?? [];

            if (apiProducts.isNotEmpty) {
              _products = apiProducts.map((item) => _convertApiItemToSimpleProduct(item)).toList();
            } else {
              _products = []; // Empty list if no products
            }
          }

          final products = _applyFilters(_products);

          return FadeTransition(
            opacity: _fade,
            child: Column(
              children: [
                _searchBar(),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _handleRefresh,
                    color: primary,
                    backgroundColor: Colors.white,
                    child: products.isEmpty
                        ? ListView(
                            // Use ListView to enable pull-to-refresh even when empty
                            children: [
                              SizedBox(
                                height: MediaQuery.of(context).size.height - 200,
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey[400]),
                                      const SizedBox(height: 16),
                                      Text(
                                        'No products found',
                                        style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          )
                        : GridView.builder(
                            padding: const EdgeInsets.all(12),
                            itemCount: products.length,
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: columns,
                              childAspectRatio: 0.65,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                            ),
                            itemBuilder: (_, i) => _productCard(products[i]),
                          ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _searchBar() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: TextField(
        decoration: InputDecoration(
          hintText: "Search products...",
          prefixIcon: Icon(Icons.search, color: primary),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
        ),
        onChanged: (v) => setState(() => _search = v),
      ),
    );
  }
  Widget _productCard(SimpleProduct p) {
    return GestureDetector(
      onTap: () => _openDetails(p),
      child: Card(
        elevation: 3,
        shadowColor: Colors.black26,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// IMAGE with overlay badge
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 1.2,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    child: p.primaryImageUrl == null
                        ? Container(
                            color: Colors.grey[200],
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.broken_image_outlined,
                                  size: 64,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'No Image',
                                  style: TextStyle(
                                    color: Colors.grey[500],
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Image.network(
                            p.primaryImageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              color: Colors.grey[200],
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.broken_image_outlined,
                                    size: 64,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Image Error',
                                    style: TextStyle(
                                      color: Colors.grey[500],
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                  ),
                ),
                // Product Type Badge
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: primary,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: primary.withValues(alpha: 0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      p.productTypeName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            /// CONTENT
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// PRODUCT NAME
                  Text(
                    p.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      height: 1.2,
                    ),
                  ),

                  const SizedBox(height: 4),

                  /// PRICE + CTA
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '₹${p.pricePerSqft.toInt()}',
                            style: TextStyle(
                              color: primary,
                              fontWeight: FontWeight.w800,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'per sqft',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 6),
                        decoration: BoxDecoration(
                          color: light,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white),

                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }





  List<SimpleProduct> _applyFilters(List<SimpleProduct> products) {
    // Simple search filter - just filter by name since SimpleProduct doesn't have all fields
    return products.where((p) =>
      p.name.toLowerCase().contains(_search.toLowerCase()) ||
      p.productCode.toLowerCase().contains(_search.toLowerCase()) ||
      p.productTypeName.toLowerCase().contains(_search.toLowerCase())
    ).toList();
  }


  /// ==========================
  /// DETAILS PAGE
  /// ==========================

  void _openDetails(SimpleProduct p) {
    // Get the BLoC instance before showing bottom sheet
    final detailsBloc = context.read<GetCatalogueProductDetailsBloc>();

    // Trigger BLoC to fetch product details
    detailsBloc.add(
      FetchGetCatalogueProductDetails(productId: p.id, showLoader: true),
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) => BlocProvider<GetCatalogueProductDetailsBloc>.value(
        value: detailsBloc,
        child: BlocBuilder<GetCatalogueProductDetailsBloc, GetCatalogueProductDetailsState>(
          builder: (context, state) {
            return DraggableScrollableSheet(
              initialChildSize: 0.85,
              expand: false,
              builder: (context, scrollController) => Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
                  boxShadow: [BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.08), blurRadius: 10)],
                ),
                padding: const EdgeInsets.all(16),
                child: _buildDetailsContent(state, scrollController, p),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildDetailsContent(GetCatalogueProductDetailsState state, ScrollController scrollController, SimpleProduct simpleProduct) {
    if (state is GetCatalogueProductDetailsLoading && state.showLoader) {
      return Center(
        child: CircularProgressIndicator(color: primary),
      );
    }

    if (state is GetCatalogueProductDetailsError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              'Error loading product details',
              style: TextStyle(fontSize: 18, color: Colors.grey[700]),
            ),
            const SizedBox(height: 8),
            Text(
              state.message,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.close),
              label: const Text('Close'),
              style: ElevatedButton.styleFrom(backgroundColor: primary),
            ),
          ],
        ),
      );
    }

    if (state is GetCatalogueProductDetailsLoaded) {
      final data = state.response.data;
      if (data == null) {
        return Center(
          child: Text('No product details available', style: TextStyle(color: Colors.grey[600])),
        );
      }

      return ListView(
        controller: scrollController,
        children: [
          // Header: Name + Code + Close
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.name ?? 'Unnamed Product',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Code: ${data.productCode ?? 'N/A'}',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: Icon(Icons.close, color: Colors.grey[700]),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Image carousel/single image
          _buildImageSection(data),

          const SizedBox(height: 16),

          // Price
          if (data.pricePerSqft != null)
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              color: primary.withValues(alpha: 0.1),
              child: Padding(
                padding: const EdgeInsets.all(5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Price',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    Text(
                      '₹${data.pricePerSqft} / sqft',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 10),

          // Description
          if (data.description != null && data.description!.isNotEmpty)
            _buildInfoRow('Description', data.description!),

          // Synonyms
          if (data.synonyms.isNotEmpty)
            _buildInfoRow('Synonyms', data.synonyms.join(', ')),

          // Product Type
          if (data.productTypeName != null)
            _buildInfoRow('Product Type', data.productTypeName!),

          // Utilities
          if (data.utilities.isNotEmpty)
            _buildInfoRow('Utilities', data.utilities.map((u) => u.name ?? '').join(', ')),

          // Colors
          if (data.colours.isNotEmpty)
            _buildInfoRow('Colors', data.colours.map((c) => c.name ?? '').join(', ')),

          // Natural Colors
          if (data.naturalColours.isNotEmpty)
            _buildInfoRow('Natural Colors', data.naturalColours.map((c) => c.name ?? '').join(', ')),

          // Finishes
          if (data.finishes.isNotEmpty)
            _buildInfoRow('Finishes', data.finishes.map((f) => f.name ?? '').join(', ')),

          // Textures
          if (data.textures.isNotEmpty)
            _buildInfoRow('Textures', data.textures.map((t) => t.name ?? '').join(', ')),

          // Origins
          if (data.origins.isNotEmpty)
            _buildInfoRow('Origins', data.origins.map((o) => o.name ?? '').join(', ')),

          // State/Countries
          if (data.stateCountries.isNotEmpty)
            _buildInfoRow('State/Countries', data.stateCountries.map((s) => s.name ?? '').join(', ')),

          // Processing Natures
          if (data.processingNatures.isNotEmpty)
            _buildInfoRow('Processing Nature', data.processingNatures.map((p) => p.name ?? '').join(', ')),

          // Material Naturalities
          if (data.materialNaturalities.isNotEmpty)
            _buildInfoRow('Material Naturality', data.materialNaturalities.map((m) => m.name ?? '').join(', ')),

          // Handicraft Types
          if (data.handicraftTypes.isNotEmpty)
            _buildInfoRow('Handicraft Types', data.handicraftTypes.map((h) => h.name ?? '').join(', ')),

          const SizedBox(height: 20),

          // Close Button
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Done', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      );
    }

    // Initial or unknown state
    return Center(
      child: Text('Loading...', style: TextStyle(color: Colors.grey[600])),
    );
  }

  Widget _buildImageSection(Data data) {
    // Build complete image list: primaryImageUrl first, then imageUrls
    final List<String> allImages = [];

    // Add primary image first if it exists
    if (data.primaryImageUrl != null &&
        data.primaryImageUrl!.isNotEmpty &&
        data.primaryImageUrl != 'null') {
      allImages.add(data.primaryImageUrl!);
    }

    // Add other images from imageUrls (excluding duplicates)
    for (var imageUrl in data.imageUrls) {
      if (imageUrl.isNotEmpty &&
          imageUrl != 'null' &&
          !allImages.contains(imageUrl)) {
        allImages.add(imageUrl);
      }
    }

    // If no images available, show placeholder
    if (allImages.isEmpty) {
      return Container(
        height: 220,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.broken_image_outlined, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 12),
            Text(
              'No Images Available',
              style: TextStyle(color: Colors.grey[500], fontSize: 14),
            ),
          ],
        ),
      );
    }

    // Show single image or image carousel
    return SizedBox(
      height: 220,
      child: Stack(
        children: [
          PageView.builder(
            itemCount: allImages.length,
            itemBuilder: (context, index) => ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                allImages[index],
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey[200],
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.broken_image_outlined, size: 80, color: Colors.grey[400]),
                      const SizedBox(height: 12),
                      Text(
                        'Image Load Error',
                        style: TextStyle(color: Colors.grey[500], fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Show image counter if multiple images
          if (allImages.length > 1)
            Positioned(
              bottom: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${allImages.length} images',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }


  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: Colors.grey[50],
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 140,
                child: Text(
                  '$label:',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  value,
                  style: TextStyle(
                    color: Colors.grey[800],
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  /// ==========================
  /// FILTERS
  /// ==========================

  void _openFilters() {
    showModalBottomSheet(
      context: context,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            _filterSection("Type", ["Marble", "Granite", "Quartzite"]),
            _filterSection("Finish", ["Polish", "Leather", "Honed"]),
            _filterSection("Origin", ["North India", "South India", "Imported"]),
            _filterSection("Natural Colour", ["White","Black","Beige","Grey","Brown","Gold"]),
            _filterSection("Price Range", ["0-50","50-100","100-200","200-1000","1000+"]),
            _filterSection("Handicraft", ["Ganesh Murti","Other"]),
          ],
        ),
      ),
    );
  }

  Widget _filterSection(String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        Wrap(
          children: items.map((e) {
            final selected = _filters[title]?.contains(e) ?? false;
            return FilterChip(
              label: Text(e),
              selected: selected,
              onSelected: (v) {
                setState(() {
                  _filters.putIfAbsent(title, () => []);
                  v ? _filters[title]!.add(e) : _filters[title]!.remove(e);
                });
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  void _shareAllProducts() {
    // TODO: Implement share functionality
  }
}

class RoleTheme {
  static Color primary(String role) =>
      role == 'superadmin'
          ? AppColors.superAdminPrimary
          : role == 'admin'
          ? AppColors.secondaryBlue
          : AppColors.primaryTeal;

  static Color primaryLight(String role) =>
      role == 'superadmin'
          ? AppColors.superAdminLight
          : role == 'admin'
          ? AppColors.secondaryBlueLight
          : AppColors.primaryTealLight;

  static Color primaryDark(String role) =>
      role == 'superadmin'
          ? AppColors.superAdminPrimaryDark
          : role == 'admin'
          ? AppColors.secondaryBlueDark
          : AppColors.primaryTealDark;
}
