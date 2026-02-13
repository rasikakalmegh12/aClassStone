import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:apclassstone/api/models/request/PostSearchRequestBody.dart';
import 'package:apclassstone/bloc/catalogue/post_catalogue_methods/post_catalogue_bloc.dart';
import 'package:apclassstone/bloc/catalogue/post_catalogue_methods/post_catalogue_event.dart';
import 'package:apclassstone/bloc/generate_pdf/generate_pdf_bloc.dart';
import 'package:apclassstone/bloc/generate_pdf/generate_pdf_event.dart';
import 'package:apclassstone/bloc/generate_pdf/generate_pdf_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import '../../api/models/response/GetCatalogueProductResponseBody.dart' hide Data;
import '../../bloc/catalogue/get_catalogue_methods/get_catalogue_bloc.dart';
import '../../bloc/catalogue/get_catalogue_methods/get_catalogue_event.dart';
import '../../bloc/catalogue/get_catalogue_methods/get_catalogue_state.dart';
import '../../bloc/catalogue/post_catalogue_methods/post_catalogue_state.dart';
import '../../core/constants/app_colors.dart';
import '../../core/session/session_manager.dart';
import '../../api/models/response/GetCatalogueProductDetailsResponseBody.dart';

/// ==========================
/// SIMPLE PRODUCT MODEL (for list view only)
/// ==========================


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
  late PageController _pageController;
  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;
  late AnimationController _shimmerController;
  late Animation<double> _shimmerAnimation;
  late AnimationController _pulseController;

  Timer? _debounce;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _gridScrollController = ScrollController(); // For grid view scroll position

  String _search = '';
  Map<String, List<String>> _filters = {};

  // Store filter data with ID mappings
  Map<String, String> _productTypeIdMap = {}; // name -> id
  Map<String, String> _utilityIdMap = {};
  Map<String, String> _colorIdMap = {};
  Map<String, String> _finishIdMap = {};
  Map<String, String> _textureIdMap = {};
  Map<String, String> _naturalColorIdMap = {};
  Map<String, String> _originIdMap = {};
  Map<String, String> _stateCountryIdMap = {};
  Map<String, String> _processingNatureIdMap = {};
  Map<String, String> _materialNaturalityIdMap = {};
  Map<String, String> _handicraftIdMap = {};
  Map<String, String> _priceRangeIdMap = {};

  List<Items> _products = [];
  int _currentIndex = 0;
  bool _isListView = false; // Toggle between swipeable and list view
  bool _hasFiltersApplied = false; // Track if any filters are currently applied
  bool _usePostSearchApi = false; // Flag to determine which API to use

  // Pagination variables
  int _currentPage = 1;
  int _pageSize = 20;
  bool _hasNextPage = false;
  bool _isLoadingMore = false;
  int _totalItems = 0;
  DateTime? _lastLoadMoreTime; // Track last load more call

  String get role => SessionManager.getUserRoleForPermissions();
  bool get isAdmin => role == 'admin' || role == 'superadmin';
  bool get isExecutive => role == 'executive';

  Color get primary => RoleTheme.primary(role);
  Color get light => RoleTheme.primaryLight(role);
  Color get dark => RoleTheme.primaryDark(role);

  // Selection state
  bool _isSelectionMode = false;
  final Set<String> _selectedProductIds = {};


  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();

    _pageController = PageController(viewportFraction: 0.88);

    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _bounceAnimation = CurvedAnimation(
      parent: _bounceController,
      curve: Curves.elasticOut,
    );

    // Shimmer effect for badges
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
    _shimmerAnimation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOutSine),
    );

    // Pulse effect for CTA button
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    BlocProvider<GetProductTypeBloc>(create: (context) => GetProductTypeBloc(),);
    BlocProvider<GetUtilitiesBloc>(create: (context) => GetUtilitiesBloc(),);
    BlocProvider<GetColorsBloc>(create: (context) => GetColorsBloc(),);
    BlocProvider<GetFinishesBloc>(create: (context) => GetFinishesBloc(),);
    BlocProvider<GetTexturesBloc>(create: (context) => GetTexturesBloc(),);
    BlocProvider<GetNaturalColorsBloc>(create: (context) => GetNaturalColorsBloc(),);
    BlocProvider<GetOriginsBloc>(create: (context) => GetOriginsBloc(),);
    BlocProvider<GetStateCountriesBloc>(create: (context) => GetStateCountriesBloc(),);
    BlocProvider<GetProcessingNatureBloc>(create: (context) => GetProcessingNatureBloc(),);
    BlocProvider<GetNaturalMaterialBloc>(create: (context) => GetNaturalMaterialBloc(),);
    BlocProvider<GetHandicraftsBloc>(create: (context) => GetHandicraftsBloc(),);
    BlocProvider<GetMinesOptionBloc>(create: (context) => GetMinesOptionBloc(),);
    BlocProvider<GetPriceRangeBloc>(create: (context) => GetPriceRangeBloc(),);


    // Load products from API using BLoC
    context.read<GetCatalogueProductListBloc>().add(FetchGetCatalogueProductList(
      page: 1,
      pageSize: 20,
      showLoader: true,
    ));
  }

  /// Handle pull-to-refresh
  Future<void> _handleRefresh() async {
    // Reset all flags and filters on refresh
    setState(() {
      _hasFiltersApplied = false;
      _usePostSearchApi = false;
      _filters.clear();
      _search = '';
      _searchController.clear();
      _currentPage = 1;
      _hasNextPage = false;
      _isLoadingMore = false;
      _products.clear();
      _lastLoadMoreTime = null;
    });

    // Reset scroll position
    if (_gridScrollController.hasClients) {
      _gridScrollController.jumpTo(0);
    }

    // Always trigger GetCatalogueProductListBloc on refresh
    context.read<GetCatalogueProductListBloc>().add(
      FetchGetCatalogueProductList(page: 1, pageSize: _pageSize, showLoader: false),
    );

    // Wait for the API call to complete
    await Future.delayed(const Duration(milliseconds: 800));
  }

  /// Load more products (pagination)
  Future<void> _loadMoreProducts() async {
    if (_isLoadingMore || !_hasNextPage) return;

    // Debounce: Don't load if called within last 1 second
    final now = DateTime.now();
    if (_lastLoadMoreTime != null &&
        now.difference(_lastLoadMoreTime!) < const Duration(seconds: 1)) {
      return;
    }

    setState(() {
      _isLoadingMore = true;
      _lastLoadMoreTime = now;
    });

    final nextPage = _currentPage + 1;

    if (_usePostSearchApi) {
      // Use PostSearch API with filters
      context.read<PostSearchBloc>().add(
        SubmitPostSearch(
          showLoader: false,
          requestBody: PostSearchRequestBody(
            page: nextPage,
            pageSize: _pageSize,
            search: _search.isEmpty ? null : _search,
            sort: 0,
            productTypeIds: _filters['Product Type']?.map((name) => _productTypeIdMap[name]).whereType<String>().toList() ?? [],
            colourOptionIds: _filters['Colour']?.map((name) => _colorIdMap[name]).whereType<String>().toList() ?? [],
            finishOptionIds: _filters['Finish']?.map((name) => _finishIdMap[name]).whereType<String>().toList() ?? [],
            textureOptionIds: _filters['Texture']?.map((name) => _textureIdMap[name]).whereType<String>().toList() ?? [],
            naturalColourOptionIds: _filters['Natural Colour']?.map((name) => _naturalColorIdMap[name]).whereType<String>().toList() ?? [],
            utilityIds: _filters['Utility']?.map((name) => _utilityIdMap[name]).whereType<String>().toList() ?? [],
            originOptionIds: _filters['Origin']?.map((name) => _originIdMap[name]).whereType<String>().toList() ?? [],
            stateCountryOptionIds: _filters['State/Country']?.map((name) => _stateCountryIdMap[name]).whereType<String>().toList() ?? [],
            processingNatureOptionIds: _filters['Processing Nature']?.map((name) => _processingNatureIdMap[name]).whereType<String>().toList() ?? [],
            materialNaturalityOptionIds: _filters['Material Naturality']?.map((name) => _materialNaturalityIdMap[name]).whereType<String>().toList() ?? [],
            handicraftTypeOptionIds: _filters['Handicraft']?.map((name) => _handicraftIdMap[name]).whereType<String>().toList() ?? [],
            priceRangeIds: _filters['Price Range']?.map((name) => _priceRangeIdMap[name]).whereType<String>().toList() ?? [],
          ),
        ),
      );
    } else {
      // Use GetCatalogueProductList API
      context.read<GetCatalogueProductListBloc>().add(
        FetchGetCatalogueProductList(
          page: nextPage,
          pageSize: _pageSize,
          showLoader: false,
        ),
      );
    }
  }

  bool _isSelected(Items p) => _selectedProductIds.contains(p.id);

  void _enterSelectionModeWith(Items p) {
    // For superadmin, show edit option
    if (SessionManager.getUserRole() == 'superadmin') {
      _showEditOptionMenu(p);
      return;
    }

    // For executives, enter selection mode
    if (!isExecutive) return; // only executives can select

    setState(() {
      _isSelectionMode = true;
      _selectedProductIds.add(p.id ?? '');
    });
  }

  void _showEditOptionMenu(Items product) {
    // ✅ Capture bloc reference from OUTER context (valid at this point)
    final catalogueBloc = context.read<GetCatalogueProductListBloc>();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              // Product info
              Text(
                product.name ?? 'Product',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Code: ${product.productCode ?? 'N/A'}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 24),
              // Edit button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {

                    Navigator.pop(context);

                    // Navigate to edit product page and wait for result
                    final result = await context.pushNamed(
                      'editProduct',
                      extra: product.id,
                    );

                    // If edit was successful (returns true), refresh product list
                    if (result == true) {
                      // Use WidgetsBinding to safely update after navigation
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        catalogueBloc.add(
                          FetchGetCatalogueProductList(
                            page: 1,
                            pageSize: 20,
                            showLoader: true,
                          ),
                        );
                      });
                    }
                  },
                  icon: const Icon(Icons.edit, size: 20),
                  label: const Text('Edit Product'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Cancel button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: BorderSide(color: Colors.grey[300]!),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _toggleSelection(Items p) {
    if (!isExecutive) return; // safety guard

    setState(() {
      if (_selectedProductIds.contains(p.id)) {
        _selectedProductIds.remove(p.id);
        if (_selectedProductIds.isEmpty) {
          _isSelectionMode = false;
        }
      } else {
        _selectedProductIds.add(p.id ?? '');
      }
    });
  }

  void _clearSelection() {
    setState(() {
      _isSelectionMode = false;
      _selectedProductIds.clear();
    });
  }

  List<Items> _getSelectedProducts() =>
      _products.where((p) => _selectedProductIds.contains(p.id)).toList();


  /// Convert API Items to SimpleProduct model
  Items _convertApiItemToSimpleProduct1(dynamic item) {
    final hasValidImage = item.primaryImageUrl != null &&
                          item.primaryImageUrl.toString().isNotEmpty &&
                          item.primaryImageUrl.toString() != 'null';

    return Items(
      id: item.id ?? '',
      productCode: item.productCode ?? '',
      name: item.name ?? 'Unnamed Product',
      // pricePerSqft: (item.pricePerSqft ?? 0).toDouble(),
      productTypeName: item.productTypeName ?? 'Stone',
      primaryImageUrl: hasValidImage ? item.primaryImageUrl.toString() : null,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _pageController.dispose();
    _bounceController.dispose();
    _shimmerController.dispose();
    _pulseController.dispose();
    _debounce?.cancel();
    _searchController.dispose();
    _gridScrollController.dispose();
    super.dispose();
  }

  /// ==========================
  /// UI
  /// ==========================

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      resizeToAvoidBottomInset: false,
      // backgroundColor: Colors.grey.shade200,
      appBar: AppBar(
        backgroundColor: primary,
        title: const Text("Product Catalogue"),
        actions: [
          // if (isExecutive)
          //   IconButton(
          //     icon: const Icon(Icons.share),
          //     onPressed: _shareAllProducts,
          //   ),
          if(isAdmin || isExecutive)
            IconButton(
              icon: Icon(_isListView ? Icons.view_carousel : Icons.list),
              onPressed: () {
                setState(() {
                  _isListView = !_isListView;
                });
              },
            ),
          IconButton(
            icon: const Icon(Icons.tune),
            onPressed: (){
              _openFilters(context);
            },
          ),
        ],
      ),
      floatingActionButton: _isSelectionMode && _selectedProductIds.isNotEmpty
          ? FloatingActionButton.extended(
        onPressed: () {
          final selected = _getSelectedProducts();
          if (selected.isEmpty) return;

          context.pushNamed(
            "addToLead",        // <-- your Add to Lead route name
            extra: selected,    // pass list<Items>
          );
        },
        backgroundColor: primary,
        icon: const Icon(Icons.playlist_add, color: AppColors.white),
        label: const Text(
          'Add to Lead',
          style: TextStyle(color: AppColors.white),
        ),
      )
          : (SessionManager.getUserRole().toString().toLowerCase() == "superadmin" ||
          SessionManager.getUserRole().toString().toLowerCase() == "admin"
          ? FloatingActionButton(
        onPressed: () {
          context.pushNamed("catalogueEntry");
        },
        backgroundColor: primary,
        child: const Icon(
          Icons.add,
          color: AppColors.white,
        ),
      )
          : null),

      // floatingActionButton:  SessionManager.getUserRole().toString().toLowerCase() =="superadmin" || SessionManager.getUserRole().toString().toLowerCase() =="admin"  ?FloatingActionButton(
      //   onPressed: () {
      //     context.pushNamed("catalogueEntry");
      //   },
      //   backgroundColor: primary,
      //   child: const Icon(Icons.add,color: AppColors.white,),
      // ):null,

      body: BlocListener<PostSearchBloc, PostSearchState>(
        listener: (context, searchState) {
          if (searchState is PostSearchSuccess) {
            // Update products with search results
            final apiProducts = searchState.response.data?.items ?? [];
            final currentPage = searchState.response.data?.page ?? 1;
            final hasNext = searchState.response.data?.hasNext ?? false;
            final total = searchState.response.data?.total ?? 0;

            setState(() {
              _usePostSearchApi = true; // Mark that we're using PostSearch API
              _isLoadingMore = false;
              _currentPage = currentPage;
              _hasNextPage = hasNext;
              _totalItems = total;

              if (currentPage == 1) {
                // First page - replace products
                _products = apiProducts;
              } else {
                // Subsequent pages - append products
                // Get existing product IDs to prevent duplicates
                final existingIds = _products.map((p) => p.id).toSet();
                final newProducts = apiProducts.where((p) => !existingIds.contains(p.id)).toList();
                if (newProducts.isNotEmpty) {
                  _products.addAll(newProducts);
                }
              }
            });
          } else if (searchState is PostSearchError) {
            setState(() {
              _isLoadingMore = false;
            });
            // Don't change the flag on error, keep showing previous results
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Search error: ${searchState.message}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: BlocBuilder<GetCatalogueProductListBloc, GetCatalogueProductListState>(
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
            // Convert API response to SimpleProduct models (only if not using PostSearch API)
            if (!_usePostSearchApi) {
              final apiProducts = state.response.data?.items ?? [];
              final currentPage = state.response.data?.page ?? 1;
              final hasNext = state.response.data?.hasNext ?? false;
              final total = state.response.data?.total ?? 0;

              // Use addPostFrameCallback to avoid setState during build
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  setState(() {
                    _isLoadingMore = false;
                    _currentPage = currentPage;
                    _hasNextPage = hasNext;
                    _totalItems = total;

                    if (currentPage == 1) {
                      // First page - replace products
                      _products = apiProducts;
                    } else {
                      // Subsequent pages - append products
                      // Get existing product IDs to prevent duplicates
                      final existingIds = _products.map((p) => p.id).toSet();
                      final newProducts = apiProducts.where((p) => !existingIds.contains(p.id)).toList();
                      if (newProducts.isNotEmpty) {
                        _products.addAll(newProducts);
                      }
                    }
                  });
                }
              });
            }
          }

          // Use products directly from API (search is handled by API)
          final products = _products;

          return FadeTransition(
            opacity: _fade,
            child: Column(
              children: [
                // Selection toolbar (shows only when executive + selected items)
                if (isExecutive && _isSelectionMode && _selectedProductIds.isNotEmpty)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  padding: const EdgeInsets.symmetric(horizontal: 8,vertical: 2),
                  height: 45,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    top: false,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Left: Cancel + count
                        Row(
                          children: [

                            Row(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  '${_selectedProductIds.length}',
                                  style: TextStyle(
                                    color: primary,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  ' selected',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        // Right: Select all / Clear actions
                        Row(
                          children: [
                            // Select All
                            TextButton.icon(
                              onPressed: () {
                                setState(() {
                                  _selectedProductIds
                                    ..clear()
                                    ..addAll(_products.map((e) => e.id ?? ''));
                                  if (_selectedProductIds.isNotEmpty) {
                                    _isSelectionMode = true;
                                  }
                                });
                              },
                              icon: Icon(Icons.select_all, size: 18, color: primary),
                              label: Text(
                                'Select all',
                                style: TextStyle(color: primary, fontWeight: FontWeight.w600),
                              ),
                              style: TextButton.styleFrom(
                                backgroundColor: primary.withValues(alpha: 0.08),
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                foregroundColor: primary,
                              ),
                            ),

                            const SizedBox(width: 8),

                            // Clear selection (redundant with close but provided as explicit action)
                            TextButton(
                              onPressed: _clearSelection,
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: Text(
                                'Clear',
                                style: TextStyle(color: Colors.red.shade600, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

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
                        : _isListView
                            ? _buildListView(products)
                            : _buildSwipeableView(products),
                  ),
                ),
              ],
            ),
          );
        },
        ),
      ),
    );
  }

  /// Build List View (Grid Layout)
  Widget _buildListView(List<Items> products) {
    // Calculate columns based on screen width
    final screenWidth = MediaQuery.of(context).size.width;
    final columns = screenWidth > 600 ? 3 : 2;

    // Only show extra item if actively loading or has next page
    final shouldShowExtraItem = _isLoadingMore || (_hasNextPage && !_isLoadingMore);
    final itemCount = products.length + (shouldShowExtraItem ? 1 : 0);

    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification scrollInfo) {
        // Load more when user scrolls to 90% of content (more conservative)
        // Only trigger if scrolling down
        if (!_isLoadingMore &&
            _hasNextPage &&
            scrollInfo.metrics.pixels >= scrollInfo.metrics.maxScrollExtent * 0.9 &&
            scrollInfo.metrics.pixels > 0) {
          _loadMoreProducts();
        }
        return false;
      },
      child: GridView.builder(
        controller: _gridScrollController, // Use controller to maintain scroll position
        physics: const BouncingScrollPhysics(), // Smooth bouncing physics
        key: ValueKey('grid_$_search'), // Only rebuild on search change, not on products length
        padding: const EdgeInsets.all(12),
        itemCount: itemCount,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          childAspectRatio: 0.65,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemBuilder: (_, i) {
          // Show loading indicator at the end
          if (i == products.length && _isLoadingMore) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(child: CircularProgressIndicator(color: primary)),
              ),
            );
          }

          // Show "Load More" button at the end if there's more data
          if (i == products.length && _hasNextPage && !_isLoadingMore) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton.icon(
                  onPressed: _loadMoreProducts,
                  icon: const Icon(Icons.arrow_downward),
                  label: const Text('Load More'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            );
          }

          return _productCard(products[i],screenWidth);
        },
      ),
    );
  }

  /// Build Swipeable View
  Widget _buildSwipeableView(List<Items> products) {
    // Only add loading/end card if there's something to show
    final shouldShowExtraCard = _isLoadingMore || (_hasNextPage && !_isLoadingMore);
    final displayItemCount = products.length + (shouldShowExtraCard ? 1 : 0);

    return Column(
      children: [
        // Swipeable product cards with 3D effect
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            itemCount: displayItemCount,
            physics: const BouncingScrollPhysics(),
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
              // Trigger bounce animation on page change
              _bounceController.forward(from: 0);

              // Load more ONLY when user reaches the LAST actual product card
              // This ensures they can see the "swipe up" message properly
              if (!_isLoadingMore && _hasNextPage && index == products.length - 1) {
                // Delay slightly to let user see the current card
                Future.delayed(const Duration(milliseconds: 300), () {
                  if (mounted && !_isLoadingMore) {
                    _loadMoreProducts();
                  }
                });
              }
            },
            itemBuilder: (context, index) {
              // Show loading card
              if (index == products.length && _isLoadingMore) {
                return Center(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: primary),
                        const SizedBox(height: 20),
                        Text(
                          'Loading more products...',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              // Show "No more products" or "Load More" card
              if (index == products.length && !_isLoadingMore) {
                return Center(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                    padding: const EdgeInsets.all(40),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _hasNextPage ? Icons.arrow_downward : Icons.check_circle_outline,
                          size: 64,
                          color: _hasNextPage ? primary : Colors.green,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          _hasNextPage ? 'Load More Products' : 'You\'ve seen all products!',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[800],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (_hasNextPage) ...[
                          const SizedBox(height: 20),
                          ElevatedButton.icon(
                            onPressed: _loadMoreProducts,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Load More'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              }

              return AnimatedBuilder(
                animation: _pageController,
                builder: (context, child) {
                  double value = 1.0;
                  double rotation = 0.0;

                  if (_pageController.hasClients && _pageController.position.haveDimensions) {
                    value = _pageController.page! - index;
                    // Scale effect
                    value = (1 - (value.abs() * 0.3)).clamp(0.7, 1.0);
                    // Rotation effect for 3D feel
                    rotation = ((_pageController.page! - index) * 0.1).clamp(-0.1, 0.1);
                  }

                  return Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.001) // perspective
                      ..rotateY(rotation),
                    child: Center(
                      child: SizedBox(
                        height: Curves.easeOut.transform(value) *
                               MediaQuery.of(context).size.height * 0.68,
                        child: Opacity(
                          opacity: value.clamp(0.85, 1.0),
                          child: child,
                        ),
                      ),
                    ),
                  );
                },
                child: _swipeableProductCard(products[index]),
              );
            },
          ),
        ),
        // Enhanced navigation hints with icons
        Container(
          margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.swipe, size: 18, color: Colors.grey[700]),
                  const SizedBox(width: 6),
                  Text(
                    'Swipe',
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text(
                  '${_currentIndex + 1} / ${_totalItems > 0 ? _totalItems : products.length}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: primary,
                  ),
                ),
              ),
              Row(
                children: [
                  Text(
                    'Details',
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(Icons.touch_app, size: 18, color: Colors.grey[700]),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _searchBar() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: "Search products...",
          prefixIcon: Icon(Icons.search, color: primary),
          suffixIcon: _search.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear, color: primary),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _search = '';
                      _currentIndex = 0;
                      _currentPage = 1;
                      _hasNextPage = false;
                      _isLoadingMore = false;
                      _products.clear();
                      // If no filters are applied, switch back to GetCatalogueProductList
                      if (!_hasFiltersApplied) {
                        _usePostSearchApi = false;
                      }
                    });
                    // Reset page controller if in swipeable view
                    if (!_isListView && _pageController.hasClients) {
                      _pageController.jumpToPage(0);
                    }
                    // Reset grid scroll position if in list view
                    if (_isListView && _gridScrollController.hasClients) {
                      _gridScrollController.jumpTo(0);
                    }
                    // Call appropriate API
                    if (_hasFiltersApplied) {
                      // If filters are applied, call PostSearch with empty search
                      _callPostSearch(searchQuery: "");
                    } else {
                      // Otherwise call GetCatalogueProductList
                      context.read<GetCatalogueProductListBloc>().add(
                        FetchGetCatalogueProductList(
                          page: 1,
                          pageSize: _pageSize,
                          showLoader: false,
                          search: null,
                        ),
                      );
                    }
                  },
                )
              : null,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: primary, width: 2),
          ),
        ),
        onChanged: (v) {
          setState(() {
            _search = v;
            _currentIndex = 0;
            _currentPage = 1;
            _hasNextPage = false;
            _isLoadingMore = false;
            _products.clear();
          });

          // Reset page controller if in swipeable view
          if (!_isListView && _pageController.hasClients) {
            _pageController.jumpToPage(0);
          }

          // Reset grid scroll position if in list view
          if (_isListView && _gridScrollController.hasClients) {
            _gridScrollController.jumpTo(0);
          }

          // Cancel previous timer
          if (_debounce?.isActive ?? false) _debounce!.cancel();

          // Start new timer for debouncing (500ms delay)
          _debounce = Timer(const Duration(milliseconds: 500), () {
            // If filters are applied, always use PostSearch
            if (_hasFiltersApplied) {
              _callPostSearch(searchQuery: v.trim().isEmpty ? "" : v.trim());
            } else {
              // No filters: use GetCatalogueProductList for search
              setState(() {
                _usePostSearchApi = false;
              });
              context.read<GetCatalogueProductListBloc>().add(
                FetchGetCatalogueProductList(
                  page: 1,
                  pageSize: _pageSize,
                  showLoader: false,
                  search: v.trim().isEmpty ? null : v.trim(),
                ),
              );
            }
          });
        },
      ),
    );
  }

  // Helper method to call PostSearchBloc with current filters
  void _callPostSearch({String? searchQuery}) {
    // Build filter ID lists
    List<String> productTypeIds = _filters["Product Type"]
        ?.map((name) => _productTypeIdMap[name])
        .where((id) => id != null)
        .cast<String>()
        .toList() ?? [];

    List<String> utilityIds = _filters["Utility"]
        ?.map((name) => _utilityIdMap[name])
        .where((id) => id != null)
        .cast<String>()
        .toList() ?? [];

    List<String> colorIds = _filters["Colour"]
        ?.map((name) => _colorIdMap[name])
        .where((id) => id != null)
        .cast<String>()
        .toList() ?? [];

    List<String> finishIds = _filters["Finish"]
        ?.map((name) => _finishIdMap[name])
        .where((id) => id != null)
        .cast<String>()
        .toList() ?? [];

    List<String> textureIds = _filters["Texture"]
        ?.map((name) => _textureIdMap[name])
        .where((id) => id != null)
        .cast<String>()
        .toList() ?? [];

    List<String> naturalColorIds = _filters["Natural Colour"]
        ?.map((name) => _naturalColorIdMap[name])
        .where((id) => id != null)
        .cast<String>()
        .toList() ?? [];

    List<String> originIds = _filters["Origin"]
        ?.map((name) => _originIdMap[name])
        .where((id) => id != null)
        .cast<String>()
        .toList() ?? [];

    List<String> stateCountryIds = _filters["State/Country"]
        ?.map((name) => _stateCountryIdMap[name])
        .where((id) => id != null)
        .cast<String>()
        .toList() ?? [];

    List<String> processingNatureIds = _filters["Processing Nature"]
        ?.map((name) => _processingNatureIdMap[name])
        .where((id) => id != null)
        .cast<String>()
        .toList() ?? [];

    List<String> materialNaturalityIds = _filters["Material Naturality"]
        ?.map((name) => _materialNaturalityIdMap[name])
        .where((id) => id != null)
        .cast<String>()
        .toList() ?? [];

    List<String> handicraftIds = _filters["Handicraft"]
        ?.map((name) => _handicraftIdMap[name])
        .where((id) => id != null)
        .cast<String>()
        .toList() ?? [];

    List<String> priceRangeIds = _filters["Price Range"]
        ?.map((name) => _priceRangeIdMap[name])
        .where((id) => id != null)
        .cast<String>()
        .toList() ?? [];

    context.read<PostSearchBloc>().add(
      SubmitPostSearch(
        showLoader: false,
        requestBody: PostSearchRequestBody(
          page: 1,
          pageSize: _pageSize,
          search: searchQuery,


          sort: 0,
          productTypeIds: productTypeIds,
          utilityIds: utilityIds,
          colourOptionIds: colorIds,
          finishOptionIds: finishIds,
          textureOptionIds: textureIds,
          naturalColourOptionIds: naturalColorIds,
          originOptionIds: originIds,
          stateCountryOptionIds: stateCountryIds,
          processingNatureOptionIds: processingNatureIds,
          materialNaturalityOptionIds: materialNaturalityIds,
          handicraftTypeOptionIds: handicraftIds,
          priceRangeIds: priceRangeIds,
        ),
      ),
    );
  }

  Widget _swipeableProductCard(Items p) {
    return Container(
      // padding: const EdgeInsets.symmetric(horizontal: 5),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            Colors.grey[50]!,
            Colors.grey[100]!,
          ],
        ),
        // Selected border
        border: isExecutive && _isSelected(p)
            ? Border.all(color: Colors.black87, width: 2)
            : null,
        // boxShadow: [
        //   BoxShadow(
        //     color: primary.withValues(alpha: 0.5),
        //     blurRadius: 30,
        //     spreadRadius: 0,
        //     offset: const Offset(0, 10),
        //   ),
        //   BoxShadow(
        //     color: Colors.black.withValues(alpha: 0.08),
        //     blurRadius: 25,
        //     offset: const Offset(0, 10),
        //   ),
        //   // Extra glow when selected
        //   if (isExecutive && _isSelected(p))
        //     BoxShadow(
        //       color: primary.withOpacity(0.4),
        //       blurRadius: 25,
        //       spreadRadius: 3,
        //     ),
        // ],
      ),
      child: GestureDetector(
        key: ValueKey('swipeable_card_${p.id}'), // Unique key for proper rebuild
        onTap: () {
          _bounceController.forward(from: 0);
          Future.delayed(const Duration(milliseconds: 150), () => _openDetails(p));
        },
          onLongPress: () => _enterSelectionModeWith(p),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          child: Hero(
            tag: 'product_${p.id}',
            child: Material(
              color: Colors.transparent,
              child: AnimatedBuilder(
                animation: _bounceAnimation,
                builder: (context, child) {
                  final scale = 1.0 - (_bounceAnimation.value * 0.05);
                  return Transform.scale(
                    scale: scale,
                    child: child,
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(32),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white,
                        Colors.grey[50]!,
                        Colors.grey[100]!,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: primary.withValues(alpha: 0.5),
                        blurRadius: 30,
                        spreadRadius: 0,
                        offset: const Offset(0, 10),
                      ),
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 25,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(32),
                    child: Stack(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            /// IMAGE Section with parallax and shimmer
                            Expanded(
                              flex: 3,
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  // Main Image with parallax effect
                                  // AnimatedBuilder(
                                  //   animation: _pageController,
                                  //   builder: (context, child) {
                                  //     double offset = 0.0;
                                  //     if (_pageController.hasClients && _pageController.position.haveDimensions) {
                                  //       final page = _pageController.page ?? 0;
                                  //       final index = _products.indexOf(p);
                                  //       offset = (page - index) * 50;
                                  //     }
                                  //     return Transform.translate(
                                  //       offset: Offset(offset, 0),
                                  //       child: child,
                                  //     );
                                  //   },
                                  //   child: p.primaryImageUrl == null
                                  //       ? _buildNoImagePlaceholder()
                                  //       : Image.network(
                                  //           p.primaryImageUrl!,
                                  //           key: ValueKey('swipeable_image_${p.id}_${p.primaryImageUrl}'), // Force image rebuild
                                  //           fit: BoxFit.cover,
                                  //           loadingBuilder: (context, child, loadingProgress) {
                                  //             if (loadingProgress == null) return child;
                                  //             return Container(
                                  //               color: Colors.grey[300],
                                  //               child: Center(
                                  //                 child: CircularProgressIndicator(
                                  //                   value: loadingProgress.expectedTotalBytes != null
                                  //                       ? loadingProgress.cumulativeBytesLoaded /
                                  //                           loadingProgress.expectedTotalBytes!
                                  //                       : null,
                                  //                   color: primary,
                                  //                   strokeWidth: 3,
                                  //                 ),
                                  //               ),
                                  //             );
                                  //           },
                                  //           errorBuilder: (context, error, stackTrace) => _buildImageErrorPlaceholder(),
                                  //         ),
                                  // ),
                           p.primaryImageUrl != null
                              ? Image.network(
                                p.primaryImageUrl!,  // Safe now
                                key: ValueKey('swipeable_image_${p.id}_${p.primaryImageUrl}'),
                                fit: BoxFit.cover,
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Container(
                                    color: Colors.grey[300],
                                    child: const Icon(Icons.image, color: Colors.white70, size: 40),
                                  );
                                },
                                errorBuilder: (context, error, stackTrace) => _buildImageErrorPlaceholder(),
                              )
                            : _buildNoImagePlaceholder(),



                  // Animated gradient overlay
                                  Positioned(
                                    bottom: 0,
                                    left: 0,
                                    right: 0,
                                    child: Container(
                                      height: 160,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            Colors.transparent,
                                            Colors.black.withValues(alpha: 0.3),
                                            Colors.black.withValues(alpha: 0.85),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),

                                  // Shimmer effect on top
                                  Positioned.fill(
                                    child: AnimatedBuilder(
                                      animation: _shimmerAnimation,
                                      builder: (context, child) {
                                        return Container(
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              begin: Alignment(_shimmerAnimation.value, -1),
                                              end: Alignment(-_shimmerAnimation.value, 1),
                                              colors: [
                                                Colors.transparent,
                                                Colors.white.withValues(alpha: 0.05),
                                                Colors.transparent,
                                              ],
                                              stops: const [0.0, 0.5, 1.0],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),

                                  // Product Type Badge
                                  // Positioned(
                                  //   top: 20,
                                  //   right: 20,
                                  //   child: Container(
                                  //     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  //     decoration: BoxDecoration(
                                  //       color: primary,
                                  //       borderRadius: BorderRadius.circular(20),
                                  //       boxShadow: [
                                  //         BoxShadow(
                                  //           color: Colors.black.withValues(alpha: 0.2),
                                  //           blurRadius: 8,
                                  //           offset: const Offset(0, 2),
                                  //         ),
                                  //       ],
                                  //     ),
                                  //     child: Text(
                                  //       p.name!.toUpperCase(),
                                  //       style: const TextStyle(
                                  //         color: Colors.white,
                                  //         fontSize: 11,
                                  //         fontWeight: FontWeight.w700,
                                  //         letterSpacing: 0.8,
                                  //       ),
                                  //     ),
                                  //   ),
                                  // ),

                                  // Product code badge
                                  Positioned(
                                    top: 20,
                                    left: 20,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withValues(alpha: 0.5),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: Colors.white.withValues(alpha: 0.3),
                                          width: 1.5,
                                        ),
                                      ),
                                      child: Text(
                                        p.productCode!,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 0.8,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                        /// CONTENT Section with enhanced design
                        Expanded(
                          flex: 1,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.white,
                                  Colors.grey[50]!,
                                ],
                              ),
                            ),
                            padding: const EdgeInsets.all(8),
                            child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    /// PRODUCT NAME with slide-in effect
                                    TweenAnimationBuilder<double>(
                                      duration: const Duration(milliseconds: 600),
                                      tween: Tween(begin: 0.0, end: 1.0),
                                      builder: (context, value, child) {
                                        return Opacity(
                                          opacity: value,
                                          child: Transform.translate(
                                            offset: Offset(0, 20 * (1 - value)),
                                            child: child,
                                          ),
                                        );
                                      },
                                      child: Text(
                                        p.name!,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w900,
                                          fontSize: 20,
                                          height: 1.2,
                                          color: Colors.grey[900],
                                          letterSpacing: -0.5,
                                        ),
                                      ),
                                    ),

                                    const SizedBox(height: 5),

                                    /// PRICE ROW with animated elements
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        // Price section with shine effect
                                        Expanded(
                                          child: TweenAnimationBuilder<double>(
                                            duration: const Duration(milliseconds: 800),
                                            tween: Tween(begin: 0.0, end: 1.0),
                                            curve: Curves.elasticOut,
                                            builder: (context, value, child) {
                                              return Transform.scale(
                                                scale: value,
                                                alignment: Alignment.centerLeft,
                                                child: child,
                                              );
                                            },
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),

                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        '₹',
                                                        style: TextStyle(
                                                          color: primary,
                                                          fontWeight: FontWeight.w900,
                                                          fontSize: 20,
                                                        ),
                                                      ),
                                                      const SizedBox(width: 2),
                                                      Text(
                                                        '${(p.lowestPricePerSqft ?? 0).toInt()}',
                                                        style: TextStyle(
                                                          color: primary,
                                                          fontWeight: FontWeight.w900,
                                                          fontSize: 25,
                                                          height: 1,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                                    decoration: BoxDecoration(
                                                      color: primary.withValues(alpha: 0.15),
                                                      borderRadius: BorderRadius.circular(8),
                                                    ),
                                                    child: Text(
                                                      'per sqft',
                                                      style: TextStyle(
                                                        fontSize: 10,
                                                        color: primary,
                                                        fontWeight: FontWeight.w700,
                                                        letterSpacing: 0.5,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),

                                        const SizedBox(width: 16),

                                        // Animated CTA Button with shimmer
                                        AnimatedBuilder(
                                          animation: _pulseController,
                                          builder: (context, child) {
                                            final scale = 1.0 + (_pulseController.value * 0.08);
                                            return Transform.scale(
                                              scale: scale,
                                              child: AnimatedBuilder(
                                                animation: _shimmerController,
                                                builder: (context, shimmerChild) {
                                                  return Container(
                                                    width: 50,
                                                    height: 50,
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      gradient: LinearGradient(
                                                        begin: Alignment.topLeft,
                                                        end: Alignment.bottomRight,
                                                        colors: [primary, light, dark],
                                                      ),
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: primary.withValues(alpha: 0.3),
                                                          blurRadius: 20 + (_pulseController.value * 10),
                                                          spreadRadius:0.5+ (_pulseController.value * 2),
                                                          offset: const Offset(0, 6),
                                                        ),
                                                        BoxShadow(
                                                          color: Colors.white.withValues(alpha: 0.8),
                                                          blurRadius: 8,
                                                          spreadRadius: -3,
                                                          offset: const Offset(0, -2),
                                                        ),
                                                      ],
                                                    ),
                                                    child: Stack(
                                                      children: [
                                                        // Shimmer overlay
                                                        Positioned.fill(
                                                          child: ClipOval(
                                                            child: Container(
                                                              decoration: BoxDecoration(
                                                                gradient: LinearGradient(
                                                                  begin: Alignment(-1.5 + (_shimmerController.value * 3), -1),
                                                                  end: Alignment(1.5 + (_shimmerController.value * 3), 1),
                                                                  colors: [
                                                                    Colors.transparent,
                                                                    Colors.white.withValues(alpha: 0.2),
                                                                    Colors.white.withValues(alpha: 0.3),
                                                                    Colors.white.withValues(alpha: 0.2),
                                                                    Colors.transparent,
                                                                  ],
                                                                  stops: const [0.0, 0.35, 0.5, 0.65, 1.0],
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        // Button content
                                                        Material(
                                                          color: Colors.transparent,
                                                          child: InkWell(
                                                            onTap: () => _openDetails(p),
                                                            customBorder: const CircleBorder(),
                                                            splashColor: Colors.white.withValues(alpha: 0.5),
                                                            child: const Center(
                                                              child: Icon(
                                                                Icons.arrow_forward_rounded,
                                                                size: 32,
                                                                color: Colors.white,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                },
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                          ),

                          ],
                        ),

                        // Floating particles effect (optional decoration)
                        // Positioned(
                        //   top: 100,
                        //   right: 30,
                        //   child: AnimatedBuilder(
                        //     animation: _shimmerController,
                        //     builder: (context, child) {
                        //       return Transform.translate(
                        //         offset: Offset(0, _shimmerAnimation.value * 10),
                        //         child: Opacity(
                        //           opacity: 0.3,
                        //           child: Container(
                        //             width: 8,
                        //             height: 8,
                        //             decoration: BoxDecoration(
                        //               color: primary,
                        //               shape: BoxShape.circle,
                        //               boxShadow: [
                        //                 BoxShadow(
                        //                   color: primary.withValues(alpha: 0.5),
                        //                   blurRadius: 10,
                        //                 ),
                        //               ],
                        //             ),
                        //           ),
                        //         ),
                        //       );
                        //     },
                        //   ),
                        // ),
                     ]
                    ),
                  ),
                ),
              ),
            ),

          )
        )
      ),
    );
  }

  Widget _productCard(Items p, double screenWidth) {
    return Container(
      // padding: const EdgeInsets.symmetric(horizontal: 5),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            Colors.grey[50]!,
            Colors.grey[100]!,
          ],
        ),
        // Selected border
        border: isExecutive && _isSelected(p)
            ? Border.all(color: Colors.black87, width: 2)
            : null,
        // boxShadow: [
        //   BoxShadow(
        //     color: primary.withValues(alpha: 0.5),
        //     blurRadius: 30,
        //     spreadRadius: 0,
        //     offset: const Offset(0, 10),
        //   ),
        //   BoxShadow(
        //     color: Colors.black.withValues(alpha: 0.08),
        //     blurRadius: 25,
        //     offset: const Offset(0, 10),
        //   ),
        //   // Extra glow when selected
        //   if (isExecutive && _isSelected(p))
        //     BoxShadow(
        //       color: primary.withOpacity(0.4),
        //       blurRadius: 25,
        //       spreadRadius: 3,
        //     ),
        // ],
      ),
      child: GestureDetector(
        key: ValueKey('product_card_${p.id}'), // Unique key for proper rebuild
        onTap: () => _openDetails(p),
        onLongPress: () => _enterSelectionModeWith(p),
        child: Card(
          elevation: 3,
          color: light.withValues(alpha: 0.05),
          shadowColor: Colors.black26,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16),side: const BorderSide(color: AppColors.grey300)),
          clipBehavior: Clip.antiAlias, // Important: ensures child respects border radius
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// IMAGE with overlay badge
              Stack(
                children: [
                  // Use LayoutBuilder to get exact dimensions
                  LayoutBuilder(
                    builder: (context, constraints) {
                      return AspectRatio(
                        aspectRatio: screenWidth>600 ?0.8: 1.1,
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
                          key: ValueKey('image_${p.id}_${p.primaryImageUrl}'), // Force image rebuild
                          fit: BoxFit.cover,
                          width: constraints.maxWidth,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              color: Colors.grey[200],
                              child: Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                                  color: primary,
                                  strokeWidth: 2,
                                ),
                              ),
                            );
                          },
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
                      );
                    },
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
                        p.name!,
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// PRODUCT NAME
                    Text(
                      p.name!,
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
                              // '₹${p.lowestPricePerSqft?.toInt()}',
                              '₹${(p.lowestPricePerSqft ?? 0).toInt()}',
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
      ),
    );
  }

  Widget _buildNoImagePlaceholder() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            primary.withValues(alpha: 0.1),
            light.withValues(alpha: 0.05),
            Colors.grey[100]!,
          ],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.8),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: primary.withValues(alpha: 0.2),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Icon(
              Icons.image_not_supported_outlined,
              size: 100,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Text(
              'No Image Available',
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 16,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageErrorPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.red[50]!,
            Colors.grey[100]!,
          ],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.9),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.red.withValues(alpha: 0.2),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Icon(
              Icons.broken_image_outlined,
              size: 100,
              color: Colors.red[300],
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Text(
              'Image Load Error',
              style: TextStyle(
                color: Colors.red[400],
                fontSize: 16,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }


  // List<SimpleProduct> _applyFilters(List<SimpleProduct> products) {
  //   // Simple search filter - just filter by name since SimpleProduct doesn't have all fields
  //   return products.where((p) =>
  //     p.name.toLowerCase().contains(_search.toLowerCase()) ||
  //     p.productCode.toLowerCase().contains(_search.toLowerCase()) ||
  //     p.productTypeName.toLowerCase().contains(_search.toLowerCase())
  //   ).toList();
  // }


  /// ==========================
  /// DETAILS PAGE
  /// ==========================

  void _openDetails(Items p) {
    // Get the BLoC instance before showing bottom sheet
    final detailsBloc = context.read<GetCatalogueProductDetailsBloc>();

    // Trigger BLoC to fetch product details
    detailsBloc.add(
      FetchGetCatalogueProductDetails(productId: p.id!, showLoader: true),
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width,
      ),
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) => BlocProvider<GetCatalogueProductDetailsBloc>.value(
        value: detailsBloc,
        child: BlocBuilder<GetCatalogueProductDetailsBloc, GetCatalogueProductDetailsState>(
          builder: (context, state) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.85,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
                boxShadow: [BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.08), blurRadius: 10)],
              ),
              padding: const EdgeInsets.all(16),
              child: _buildDetailsContent(state, null, p),
            );
          },
        ),
      ),
    );
  }

  Widget _buildDetailsContent(GetCatalogueProductDetailsState state, ScrollController? scrollController, Items simpleProduct) {
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
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Code: ${data.productCode ?? 'N/A'}',
                      style: TextStyle(color: Colors.grey[700],fontSize: 12),
                    ),
                  ],
                ),
              ),
              BlocProvider(
                create: (context) => GeneratePdfBloc(),
                child: BlocConsumer<GeneratePdfBloc, GeneratePdfState>(
                  listener: (context, pdfState) {
                    if (pdfState is GeneratePdfSuccess) {
                      final pdfUrl = pdfState.response.data?.fullUrl;
                      if (pdfUrl != null) {
                        _sharePdf(pdfUrl, data.name ?? 'Product');
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('PDF URL not available'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    } else if (pdfState is GeneratePdfError) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(pdfState.message),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  builder: (context, pdfState) {
                    final isGenerating = pdfState is GeneratePdfLoading;

                    return IconButton(
                      onPressed: isGenerating
                          ? null
                          : () {
                              if (data.id != null) {
                                context.read<GeneratePdfBloc>().add(
                                      GeneratePdfForProduct(
                                        productId: data.id!,
                                        showLoader: true,
                                      ),
                                    );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Product ID not available'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            },
                      icon: isGenerating
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.grey[700],
                              ),
                            )
                          : Icon(Icons.share, color: Colors.grey[700]),
                    );
                  },
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
          if (data.priceRangeName != null)
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
                      '₹${data.priceRangeName} / sqft',
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
          if (data.marketingOneLiner!.isNotEmpty)
            _buildInfoRow('One Liner', data.marketingOneLiner ?? "NA"),
          // Synonyms
        if ((data.synonyms ?? []).isNotEmpty)
          _buildInfoRow(
            'Synonyms',
            (data.synonyms ?? []).join(', '),
          ),
          // Product Type
          if (data.productTypeName != null)
            _buildInfoRow('Product Type', data.productTypeName!),

          // Utilities
          if (data.utilities!.isNotEmpty)
            _buildInfoRow('Utilities', data.utilities!.map((u) => u.name ?? '').join(', ')),

          // Colors
          if (data.colours!.isNotEmpty)
            _buildInfoRow('Colors', '', colorList: data.colours),

          // Natural Colors
          if (data.naturalColours!.isNotEmpty)
            _buildInfoRow('Natural Colors', '', colorList: data.naturalColours),

          // Finishes
          if (data.finishes!.isNotEmpty)
            _buildInfoRow('Finishes', data.finishes!.map((f) => f.name ?? '').join(', ')),

          // Textures
          if (data.textures!.isNotEmpty)
            _buildInfoRow('Textures', data.textures!.map((t) => t.name ?? '').join(', ')),

          // Origins
          if (data.origins!.isNotEmpty)
            _buildInfoRow('Origins', data.origins!.map((o) => o.name ?? '').join(', ')),

          // State/Countries
          if (data.stateCountries!.isNotEmpty)
            _buildInfoRow('State/Countries', data.stateCountries!.map((s) => s.name ?? '').join(', ')),

          // Processing Natures
          if (data.processingNatures!.isNotEmpty)
            _buildInfoRow('Processing Nature', data.processingNatures!.map((p) => p.name ?? '').join(', ')),

          // Material Naturalities
          if (data.materialNaturalities!.isNotEmpty)
            _buildInfoRow('Material Naturality', data.materialNaturalities!.map((m) => m.name ?? '').join(', ')),

          // Handicraft Types
          if (data.handicraftTypes!.isNotEmpty)
            _buildInfoRow('Handicraft Types', data.handicraftTypes!.map((h) => h.name ?? '').join(', ')),

          if (data.priceSqftArchitectGradeA != null ||
              data.priceSqftArchitectGradeB != null ||
              data.priceSqftArchitectGradeC != null)
            Container(
              margin: const EdgeInsets.all(8),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: RoleTheme.primary(role).withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: RoleTheme.primaryLight(role),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.price_check, size: 18, color: RoleTheme.primary(role)),
                        const SizedBox(width: 8),
                        Text(
                          'Pricing (₹/sqft)',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: RoleTheme.primary(role),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Architect Pricing Row
                  if (data.priceSqftArchitectGradeA != null ||
                      data.priceSqftArchitectGradeB != null ||
                      data.priceSqftArchitectGradeC != null)
                    _buildPricingGroup(
                      'Architect',
                      data.priceSqftArchitectGradeA,
                      data.priceSqftArchitectGradeB,
                      data.priceSqftArchitectGradeC,
                      RoleTheme.primary(role),
                    ),

                  // Trader Pricing Row
                  if (data.priceSqftTraderGradeA != null ||
                      data.priceSqftTraderGradeB != null ||
                      data.priceSqftTraderGradeC != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: _buildPricingGroup(
                        'Trader',
                        data.priceSqftTraderGradeA,
                        data.priceSqftTraderGradeB,
                        data.priceSqftTraderGradeC,
                        RoleTheme.primary(role),
                      ),
                    ),
                ],
              ),
            ),



          if (isAdmin && data.mineName != null)
            Container(
              margin: const EdgeInsets.all(8),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: RoleTheme.primary(role).withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                    decoration: BoxDecoration(
                      color: RoleTheme.primaryLight(role),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.business,
                          size: 18,
                          color: RoleTheme.primary(role),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Mine Details',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: RoleTheme.primary(role),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Compact info rows
                  if (data.mineName != null) _buildCompactRow(Icons.business, 'Mine', data.mineName!, RoleTheme.primary(role)),
                  if (data.mineOwnerName != null) _buildCompactRow(Icons.person, 'Owner', data.mineOwnerName!, RoleTheme.primary(role)),
                  if (data.mineContactPhone != null) _buildCompactRow(Icons.phone, 'Mobile', data.mineContactPhone!, RoleTheme.primary(role)),
                  if (data.mineContactEmail != null) _buildCompactRow(Icons.email, 'Email', data.mineContactEmail!, RoleTheme.primary(role)),
                  if (data.mineLocation != null) _buildCompactRow(Icons.location_on, 'Location', data.mineLocation!, RoleTheme.primary(role)),
                ],
              ),
            ),
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

  Widget _buildCompactRow(IconData icon, String title, String value, Color roleColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: roleColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, size: 16, color: roleColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 14, color: Colors.black87),
                children: [
                  TextSpan(
                    text: '$title: ',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  TextSpan(text: value),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPricingGroup(
      String category,
      int? gradeA,
      int? gradeB,
      int? gradeC,
      Color roleColor,
      ) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border(
          left: BorderSide(width: 4, color: roleColor),  // Fixed: Use BorderSide
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            category,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: roleColor,
            ),
          ),
          const SizedBox(height: 5),
          Row(
            children: [
              _buildPriceChip('A', gradeA, roleColor),
              const SizedBox(width: 8),
              _buildPriceChip('B', gradeB, roleColor),
              const SizedBox(width: 8),
              _buildPriceChip('C', gradeC, roleColor),
            ],
          ),
        ],
      ),
    );
  }

// Price chip helper
  Widget _buildPriceChip(String grade, int? price, Color roleColor) {
    if (price == null) return const SizedBox.shrink();

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: roleColor.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Text(
              grade,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade600,
              ),
            ),
            Text(
              '₹$price',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: roleColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection(Data data) {
    // Build complete image list (same logic)
    final List<String> allImages = [];
    if (data.primaryImageUrl != null && data.primaryImageUrl!.isNotEmpty && data.primaryImageUrl != 'null') {
      allImages.add(data.primaryImageUrl!);
    }
    for (var imageUrl in data.imageUrls ?? []) {
      if (imageUrl.isNotEmpty && imageUrl != 'null' && !allImages.contains(imageUrl)) {
        allImages.add(imageUrl);
      }
    }

    if (allImages.isEmpty) {
      return Container(
        height: 220,
        decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(12)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.broken_image_outlined, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 12),
            Text('No Images Available', style: TextStyle(color: Colors.grey[500], fontSize: 14)),
          ],
        ),
      );
    }

    return GestureDetector(
      onTap: () => _showImageDialog(context, allImages),
          // _showFullScreenImages(context, allImages),
      child: SizedBox(
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
                        Text('Image Load Error', style: TextStyle(color: Colors.grey[500], fontSize: 14)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // Zoom hint
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.zoom_in, color: Colors.white, size: 18),
              ),
            ),
            // Image counter
            if (allImages.length > 1)
              Positioned(
                bottom: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${allImages.length} images',
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

// Full screen zoomable gallery
  void _showFullScreenImages(BuildContext context, List<String> images) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => FullScreenImageGallery(images: images),
    );
  }
  // Widget _buildImageSection(Data data) {
  //   // Build complete image list: primaryImageUrl first, then imageUrls
  //   final List<String> allImages = [];
  //
  //   // Add primary image first if it exists
  //   if (data.primaryImageUrl != null &&
  //       data.primaryImageUrl!.isNotEmpty &&
  //       data.primaryImageUrl != 'null') {
  //     allImages.add(data.primaryImageUrl!);
  //   }
  //
  //   // Add other images from imageUrls (excluding duplicates)
  //   for (var imageUrl in data.imageUrls!) {
  //     if (imageUrl.isNotEmpty &&
  //         imageUrl != 'null' &&
  //         !allImages.contains(imageUrl)) {
  //       allImages.add(imageUrl);
  //     }
  //   }
  //
  //   // If no images available, show placeholder
  //   if (allImages.isEmpty) {
  //     return Container(
  //       height: 220,
  //       decoration: BoxDecoration(
  //         color: Colors.grey[200],
  //         borderRadius: BorderRadius.circular(12),
  //       ),
  //       child: Column(
  //         mainAxisAlignment: MainAxisAlignment.center,
  //         children: [
  //           Icon(Icons.broken_image_outlined, size: 80, color: Colors.grey[400]),
  //           const SizedBox(height: 12),
  //           Text(
  //             'No Images Available',
  //             style: TextStyle(color: Colors.grey[500], fontSize: 14),
  //           ),
  //         ],
  //       ),
  //     );
  //   }
  //
  //   // Show single image or image carousel
  //   return SizedBox(
  //     height: 220,
  //     child: Stack(
  //       children: [
  //         PageView.builder(
  //           itemCount: allImages.length,
  //           itemBuilder: (context, index) => ClipRRect(
  //             borderRadius: BorderRadius.circular(12),
  //             child: Image.network(
  //               allImages[index],
  //               fit: BoxFit.cover,
  //               errorBuilder: (context, error, stackTrace) => Container(
  //                 color: Colors.grey[200],
  //                 child: Column(
  //                   mainAxisAlignment: MainAxisAlignment.center,
  //                   children: [
  //                     Icon(Icons.broken_image_outlined, size: 80, color: Colors.grey[400]),
  //                     const SizedBox(height: 12),
  //                     Text(
  //                       'Image Load Error',
  //                       style: TextStyle(color: Colors.grey[500], fontSize: 14),
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //             ),
  //           ),
  //         ),
  //         // Show image counter if multiple images
  //         if (allImages.length > 1)
  //           Positioned(
  //             bottom: 12,
  //             right: 12,
  //             child: Container(
  //               padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
  //               decoration: BoxDecoration(
  //                 color: Colors.black.withValues(alpha: 0.6),
  //                 borderRadius: BorderRadius.circular(20),
  //               ),
  //               child: Text(
  //                 '${allImages.length} images',
  //                 style: const TextStyle(
  //                   color: Colors.white,
  //                   fontSize: 12,
  //                   fontWeight: FontWeight.w600,
  //                 ),
  //               ),
  //             ),
  //           ),
  //       ],
  //     ),
  //   );
  // }


  void _showImageDialog(BuildContext context, List<String> images) {
    int currentIndex = 0;
    final PageController pageController = PageController();
    final TransformationController transformationController =
    TransformationController();

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'ImageDialog',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 280),
      pageBuilder: (_, __, ___) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Center(
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  height: MediaQuery.of(context).size.height * 0.75,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black45,
                        blurRadius: 30,
                        offset: Offset(0, 15),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [

                      /// ================= IMAGE VIEW =================
                      ClipRRect(
                        borderRadius: BorderRadius.circular(22),
                        child: PageView.builder(
                          controller: pageController,
                          itemCount: images.length,
                          onPageChanged: (index) {
                            setState(() {
                              currentIndex = index;
                              transformationController.value =
                                  Matrix4.identity(); // reset zoom on page change
                            });
                          },
                          itemBuilder: (context, index) {
                            return InteractiveViewer(
                              transformationController:
                              transformationController,
                              minScale: 1,
                              maxScale: 4,
                              panEnabled: true,
                              child: Center(
                                child: Image.network(
                                  images[index],
                                  fit: BoxFit.contain,
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return const CircularProgressIndicator(
                                      color: Colors.white,
                                    );
                                  },
                                  errorBuilder: (_, __, ___) => const Icon(
                                    Icons.broken_image,
                                    size: 70,
                                    color: Colors.white54,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      /// ================= TOP BAR =================
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withOpacity(0.75),
                                Colors.transparent,
                              ],
                            ),
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(22),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${currentIndex + 1} / ${images.length}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              GestureDetector(
                                onTap: () => Navigator.pop(context),
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white24,
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      /// ================= DOT INDICATOR =================
                      if (images.length > 1)
                        Positioned(
                          bottom: 16,
                          left: 0,
                          right: 0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              images.length,
                                  (index) => AnimatedContainer(
                                duration: const Duration(milliseconds: 250),
                                margin:
                                const EdgeInsets.symmetric(horizontal: 4),
                                height: 8,
                                width: currentIndex == index ? 22 : 8,
                                decoration: BoxDecoration(
                                  color: currentIndex == index
                                      ? Colors.white
                                      : Colors.white38,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                          ),
                        ),

                      /// ================= ZOOM CONTROLS =================
                      Positioned(
                        bottom: 50,
                        right: 16,
                        child: Column(
                          children: [
                            _ZoomButton(
                              icon: Icons.add,
                              onTap: () => _zoom(
                                  transformationController, 1.25),
                            ),
                            const SizedBox(height: 10),
                            _ZoomButton(
                              icon: Icons.remove,
                              onTap: () =>
                                  _zoom(transformationController, 0.8),
                            ),
                            const SizedBox(height: 10),
                            _ZoomButton(
                              icon: Icons.refresh,
                              onTap: () => transformationController.value =
                                  Matrix4.identity(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },

      /// ================= ANIMATION =================
      transitionBuilder: (context, animation, _, child) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween(begin: 0.92, end: 1.0).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOut),
            ),
            child: child,
          ),
        );
      },


    );
  }

  /// ================= ZOOM LOGIC =================
  void _zoom(
      TransformationController controller,
      double scaleFactor,
      ) {
    final Matrix4 matrix = controller.value.clone();
    matrix.scale(scaleFactor);
    matrix.scale(scaleFactor, scaleFactor, 1.0);
    controller.value = matrix;
  }








  Widget _buildInfoRow(String label, String value, {List<dynamic>? colorList}) {
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
                child: (label == "Colors" || label == "Natural Colors") && colorList != null
                    ? Wrap(
                        spacing: 5,
                        runSpacing: 5,
                        children: colorList.map((colorItem) {
                          final colorCode = colorItem.code ?? '';
                          final colorName = colorItem.name ?? '';

                          // Parse color code safely
                          Color displayColor;
                          try {
                            // Handle format like "0XA20101" or "0xff9c27b0"
                            String hexString = colorCode
                                .toUpperCase()
                                .replaceAll('0X', '')
                                .trim();

                            // If it's 6 characters (RGB), add FF prefix for full opacity (ARGB)
                            // If it's 8 characters (ARGB), use as is
                            if (hexString.length == 6) {
                              // Add FF for full opacity: A20101 -> FFA20101
                              displayColor = Color(int.parse('FF$hexString', radix: 16));
                            } else if (hexString.length == 8) {
                              // Already has alpha channel
                              displayColor = Color(int.parse(hexString, radix: 16));
                            } else {
                              if (kDebugMode) {
                                print('⚠️ Invalid color hex length for "$colorCode": ${hexString.length} chars');
                              }
                              displayColor = Colors.grey; // fallback
                            }
                          } catch (e) {
                            if (kDebugMode) {
                              print('⚠️ Error parsing color code "$colorCode": $e');
                            }
                            displayColor = Colors.grey; // fallback
                          }

                          return Tooltip(
                            message: colorName,
                            child: Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: displayColor,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.grey.shade300,
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withAlpha(20),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      )
                    : Text(
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

  void _openFilters(BuildContext context) {
    // Capture bloc instances from the parent context
    final productTypeBloc = context.read<GetProductTypeBloc>();
    final utilitiesBloc = context.read<GetUtilitiesBloc>();
    final colorsBloc = context.read<GetColorsBloc>();
    final finishesBloc = context.read<GetFinishesBloc>();
    final texturesBloc = context.read<GetTexturesBloc>();
    final naturalColorsBloc = context.read<GetNaturalColorsBloc>();
    final originsBloc = context.read<GetOriginsBloc>();
    final stateCountriesBloc = context.read<GetStateCountriesBloc>();
    final processingNatureBloc = context.read<GetProcessingNatureBloc>();
    final naturalMaterialBloc = context.read<GetNaturalMaterialBloc>();
    final handicraftsBloc = context.read<GetHandicraftsBloc>();
    final priceRangeBloc = context.read<GetPriceRangeBloc>();

    // Trigger events
    productTypeBloc.add(FetchGetProductType());
    utilitiesBloc.add(FetchGetUtilities());
    colorsBloc.add(FetchGetColors());
    finishesBloc.add(FetchGetFinishes());
    texturesBloc.add(FetchGetTextures());
    naturalColorsBloc.add(FetchGetNaturalColors());
    originsBloc.add(FetchGetOrigins());
    stateCountriesBloc.add(FetchGetStateCountries());
    processingNatureBloc.add(FetchGetProcessingNature());
    naturalMaterialBloc.add(FetchGetNaturalMaterial());
    handicraftsBloc.add(FetchGetHandicrafts());
    priceRangeBloc.add(FetchGetPriceRange());

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomSheetContext) => StatefulBuilder(
        builder: (BuildContext ctx, StateSetter setModalState) => DraggableScrollableSheet(
          initialChildSize: 0.9,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (sheetContext, scrollController) => Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Filters',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: primary,
                      ),
                    ),
                    Row(
                      children: [
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _filters.clear();
                              _hasFiltersApplied = false;
                              _usePostSearchApi = false;
                              _currentPage = 1;
                              _hasNextPage = false;
                              _isLoadingMore = false;
                              _products.clear();
                            });
                            Navigator.pop(sheetContext);

                            // Reset scroll position
                            if (!_isListView && _pageController.hasClients) {
                              _pageController.jumpToPage(0);
                            }
                            if (_isListView && _gridScrollController.hasClients) {
                              _gridScrollController.jumpTo(0);
                            }

                            // Always call GetCatalogueProductList when clearing all filters
                            context.read<GetCatalogueProductListBloc>().add(
                              FetchGetCatalogueProductList(
                                page: 1,
                                pageSize: _pageSize,
                                showLoader: false,
                                search: _search.isEmpty ? null : _search,
                              ),
                            );
                          },
                          child: const Text('Clear All'),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(sheetContext),
                        ),
                      ],
                    ),
                  ],
                ),
                const Divider(),

                // Filter sections
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    children: [
                      // Product Type
                      BlocBuilder<GetProductTypeBloc, GetProductTypeState>(
                        bloc: productTypeBloc,
                        builder: (context, state) {
                          if (state is GetProductTypeLoading) {
                            return _buildFilterLoadingSection("Product Type");
                          }
                          if (state is GetProductTypeLoaded) {
                            final types = state.response.data
                                ?.where((item) => item.name != null && item.name!.isNotEmpty)
                                .map((item) => item.name!)
                                .toList() ??
                                [];
                            // Populate ID map
                            _productTypeIdMap.clear();
                            state.response.data?.forEach((item) {
                              if (item.name != null && item.id != null) {
                                _productTypeIdMap[item.name!] = item.id!;
                              }
                            });
                            return _filterSection("Product Type", types, setModalState: setModalState);
                          }
                          return _filterSection("Product Type", [], setModalState: setModalState);
                        },
                      ),

                      // Utilities
                      BlocBuilder<GetUtilitiesBloc, GetUtilitiesState>(
                        bloc: utilitiesBloc,
                        builder: (context, state) {
                          if (state is GetUtilitiesLoaded) {
                            final utilities = state.response.data
                                ?.where((item) => item.name != null && item.name!.isNotEmpty)
                                .map((item) => item.name!)
                                .toList() ??
                                [];
                            // Populate ID map
                            _utilityIdMap.clear();
                            state.response.data?.forEach((item) {
                              if (item.name != null && item.id != null) {
                                _utilityIdMap[item.name!] = item.id!;
                              }
                            });
                            return _filterSection("Utility", utilities, setModalState: setModalState);
                          }
                          return _filterSection("Utility", [], setModalState: setModalState);
                        },
                      ),

                      // Finishes
                      BlocBuilder<GetFinishesBloc, GetFinishesState>(
                        bloc: finishesBloc,
                        builder: (context, state) {
                          if (state is GetFinishesLoaded) {
                            final finishes = state.response.data
                                ?.where((item) => item.name != null && item.name!.isNotEmpty)
                                .map((item) => item.name!)
                                .toList() ??
                                [];
                            _finishIdMap.clear();



                            state.response.data?.forEach((item) {
                              if (item.name != null && item.id != null) {
                                _finishIdMap[item.name!] = item.id!;
                              }
                            });
                            return _filterSection("Finish", finishes, setModalState: setModalState);
                          }
                          return _filterSection("Finish", [], setModalState: setModalState);
                        },
                      ),

                      // Textures
                      BlocBuilder<GetTexturesBloc, GetTexturesState>(
                        bloc: texturesBloc,
                        builder: (context, state) {
                          if (state is GetTexturesLoaded) {
                            final textures = state.response.data
                                ?.where((item) => item.name != null && item.name!.isNotEmpty)
                                .map((item) => item.name!)
                                .toList() ??
                                [];
                            _textureIdMap.clear();
                            state.response.data?.forEach((item) {
                              if (item.name != null && item.id != null) {
                                _textureIdMap[item.name!] = item.id!;
                              }
                            });
                            return _filterSection("Texture", textures, setModalState: setModalState);
                          }
                          return _filterSection("Texture", [], setModalState: setModalState);
                        },
                      ),

                      // Colors
                      BlocBuilder<GetColorsBloc, GetColorsState>(
                        bloc: colorsBloc,
                        builder: (context, state) {
                          if (state is GetColorsLoaded) {
                            final colors = state.response.data
                                ?.where((item) => item.name != null && item.name!.isNotEmpty)
                                .map((item) => item.name!)
                                .toList() ??
                                [];
                            _colorIdMap.clear();
                            state.response.data?.forEach((item) {
                              if (item.name != null && item.id != null) {
                                _colorIdMap[item.name!] = item.id!;
                              }
                            });
                            return _filterSection("Colour", colors, setModalState: setModalState);
                          }
                          return _filterSection("Colour", [], setModalState: setModalState);
                        },
                      ),

                      // Natural Colors
                      BlocBuilder<GetNaturalColorsBloc, GetNaturalColorsState>(
                        bloc: naturalColorsBloc,
                        builder: (context, state) {
                          if (state is GetNaturalColorsLoaded) {
                            final naturalColors = state.response.data
                                ?.where((item) => item.name != null && item.name!.isNotEmpty)
                                .map((item) => item.name!)
                                .toList() ??
                                [];
                            _naturalColorIdMap.clear();
                            state.response.data?.forEach((item) {
                              if (item.name != null && item.id != null) {
                                _naturalColorIdMap[item.name!] = item.id!;
                              }
                            });
                            return _filterSection("Natural Colour", naturalColors, setModalState: setModalState);
                          }
                          return _filterSection("Natural Colour", [], setModalState: setModalState);
                        },
                      ),

                      // Origins
                      BlocBuilder<GetOriginsBloc, GetOriginsState>(
                        bloc: originsBloc,
                        builder: (context, state) {
                          if (state is GetOriginsLoaded) {
                            final origins = state.response.data
                                ?.where((item) => item.name != null && item.name!.isNotEmpty)
                                .map((item) => item.name!)
                                .toList() ??
                                [];
                            _originIdMap.clear();
                            state.response.data?.forEach((item) {
                              if (item.name != null && item.id != null) {
                                _originIdMap[item.name!] = item.id!;
                              }
                            });
                            return _filterSection("Origin", origins, setModalState: setModalState);
                          }
                          return _filterSection("Origin", [], setModalState: setModalState);
                        },
                      ),

                      // State/Countries
                      BlocBuilder<GetStateCountriesBloc, GetStateCountriesState>(
                        bloc: stateCountriesBloc,
                        builder: (context, state) {
                          if (state is GetStateCountriesLoaded) {
                            final states = state.response.data
                                ?.where((item) => item.name != null && item.name!.isNotEmpty)
                                .map((item) => item.name!)
                                .toList() ??
                                [];
                            _stateCountryIdMap.clear();
                            state.response.data?.forEach((item) {
                              if (item.name != null && item.id != null) {
                                _stateCountryIdMap[item.name!] = item.id!;
                              }
                            });
                            return _filterSection("State/Country", states, setModalState: setModalState);
                          }
                          return _filterSection("State/Country", [], setModalState: setModalState);
                        },
                      ),

                      // Processing Nature
                      BlocBuilder<GetProcessingNatureBloc, GetProcessingNatureState>(
                        bloc: processingNatureBloc,
                        builder: (context, state) {
                          if (state is GetProcessingNatureLoaded) {
                            final processing = state.response.data
                                ?.where((item) => item.name != null && item.name!.isNotEmpty)
                                .map((item) => item.name!)
                                .toList() ??
                                [];
                            _processingNatureIdMap.clear();
                            state.response.data?.forEach((item) {
                              if (item.name != null && item.id != null) {
                                _processingNatureIdMap[item.name!] = item.id!;
                              }
                            });
                            return _filterSection("Processing Nature", processing, setModalState: setModalState);
                          }
                          return _filterSection("Processing Nature", [], setModalState: setModalState);
                        },
                      ),

                      // Material Naturality
                      BlocBuilder<GetNaturalMaterialBloc, GetNaturalMaterialState>(
                        bloc: naturalMaterialBloc,
                        builder: (context, state) {
                          if (state is GetNaturalMaterialLoaded) {
                            final materials = state.response.data
                                ?.where((item) => item.name != null && item.name!.isNotEmpty)
                                .map((item) => item.name!)
                                .toList() ??
                                [];
                            _materialNaturalityIdMap.clear();
                            state.response.data?.forEach((item) {
                              if (item.name != null && item.id != null) {
                                _materialNaturalityIdMap[item.name!] = item.id!;
                              }
                            });
                            return _filterSection("Material Naturality", materials, setModalState: setModalState);
                          }
                          return _filterSection("Material Naturality", [], setModalState: setModalState);
                        },
                      ),

                      // Handicrafts
                      BlocBuilder<GetHandicraftsBloc, GetHandicraftsState>(
                        bloc: handicraftsBloc,
                        builder: (context, state) {
                          if (state is GetHandicraftsLoaded) {
                            final handicrafts = state.response.data
                                ?.where((item) => item.name != null && item.name!.isNotEmpty)
                                .map((item) => item.name!)
                                .toList() ??
                                [];
                            _handicraftIdMap.clear();
                            state.response.data?.forEach((item) {
                              if (item.name != null && item.id != null) {
                                _handicraftIdMap[item.name!] = item.id!;
                              }
                            });
                            return _filterSection("Handicraft", handicrafts, setModalState: setModalState);
                          }
                          return _filterSection("Handicraft", [], setModalState: setModalState);
                        },
                      ),

                      // Price Range
                      BlocBuilder<GetPriceRangeBloc, GetPriceRangeState>(
                        bloc: priceRangeBloc,
                        builder: (context, state) {
                          if (state is GetPriceRangeLoaded) {
                            final priceRanges = state.response.data
                                ?.where((item) => item.name != null && item.name!.isNotEmpty)
                                .map((item) => item.name!)
                                .toList() ??
                                [];
                            _priceRangeIdMap.clear();
                            state.response.data?.forEach((item) {
                              if (item.name != null && item.id != null) {
                                _priceRangeIdMap[item.name!] = item.id!;
                              }
                            });
                            return _filterSection("Price Range", priceRanges, setModalState: setModalState);
                          }
                          return _filterSection("Price Range", [], setModalState: setModalState);
                        },
                      ),
                    ],
                  ),
                ),

                // Apply button
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(sheetContext);

                      // Check if any filters are applied
                      bool hasFilters = _filters.values.any((list) => list.isNotEmpty);

                      setState(() {
                        _hasFiltersApplied = hasFilters;
                        _currentPage = 1;
                        _hasNextPage = false;
                        _isLoadingMore = false;
                        _products.clear();
                      });

                      // Reset scroll position
                      if (!_isListView && _pageController.hasClients) {
                        _pageController.jumpToPage(0);
                      }
                      if (_isListView && _gridScrollController.hasClients) {
                        _gridScrollController.jumpTo(0);
                      }

                      if (hasFilters) {
                        // Filters are applied: use PostSearchBloc
                        setState(() {
                          _usePostSearchApi = true;
                        });
                        _callPostSearch(searchQuery: _search.isEmpty ? "" : _search);
                      } else {
                        // No filters: use GetCatalogueProductList
                        setState(() {
                          _usePostSearchApi = false;
                        });
                        context.read<GetCatalogueProductListBloc>().add(
                          FetchGetCatalogueProductList(
                            page: 1,
                            pageSize: _pageSize,
                            showLoader: false,
                            search: _search.isEmpty ? null : _search,
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Apply Filters',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _filterSection(String title, List<String> items, {StateSetter? setModalState}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: primary,
            ),
          ),
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: items.map((e) {
            final selected = _filters[title]?.contains(e) ?? false;
            return FilterChip(
              label: Text(e),
              selected: selected,
              selectedColor: primary.withValues(alpha: 0.2),
              checkmarkColor: primary,
              side: BorderSide(
                color: selected ? primary : Colors.grey.shade300,
                width: selected ? 2 : 1,
              ),
              onSelected: (v) {
                final updateState = setModalState ?? setState;
                updateState(() {
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

  Widget _buildFilterLoadingSection(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
              color: primary,
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(primary),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  void _shareAllProducts() {
    // TODO: Implement share functionality
  }

  /// Helper method to download and open PDF file
  Future<void> _sharePdf(String pdfUrl, String productName) async {
    try {
      // Show downloading indicator
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: 16),
                Text('Downloading PDF...'),
              ],
            ),
            duration: Duration(seconds: 30),
          ),
        );
      }

      // Download the PDF file
      final response = await http.get(Uri.parse(pdfUrl));

      if (response.statusCode == 200) {
        // Get temporary directory
        final tempDir = await getTemporaryDirectory();
        final fileName = productName != null && productName.isNotEmpty
            ? '${productName.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}.pdf'
            : 'product_${DateTime.now().millisecondsSinceEpoch}.pdf';
        final filePath = '${tempDir.path}/$fileName';

        // Save PDF to file
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);

        if (kDebugMode) {
          print('PDF saved to: $filePath');
        }

        // Dismiss downloading indicator
        if (mounted) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
        }

        // Open the PDF file in external app
        final uri = Uri.file(filePath);
        final canLaunch = await canLaunchUrl(uri);

        if (canLaunch) {
          final launched = await launchUrl(
            uri,
            mode: LaunchMode.externalApplication,
          );

          if (!launched && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Could not open PDF. No PDF viewer found.'),
                backgroundColor: Colors.orange,
              ),
            );
          }
        } else {
          // Fallback: Open URL in browser if file launch fails
          if (kDebugMode) {
            print('Cannot launch file URI, trying URL instead');
          }

          final urlUri = Uri.parse(pdfUrl);
          if (await canLaunchUrl(urlUri)) {
            await launchUrl(
              urlUri,
              mode: LaunchMode.externalApplication,
            );
          } else {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Could not open PDF'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        }
      } else {
        throw Exception('Failed to download PDF: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error downloading PDF: $e');
      }

      // Dismiss any showing snackbar
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
      }

      // Fallback: Open PDF URL directly in browser
      try {
        final uri = Uri.parse(pdfUrl);
        if (await canLaunchUrl(uri)) {
          await launchUrl(
            uri,
            mode: LaunchMode.externalApplication,
          );
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Failed to open PDF. Please check your connection.'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } catch (urlError) {
        if (kDebugMode) {
          print('Error opening URL: $urlError');
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to open PDF. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
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


class FullScreenImageGallery extends StatefulWidget {
  final List<String> images;

  const FullScreenImageGallery({Key? key, required this.images}) : super(key: key);

  @override
  State<FullScreenImageGallery> createState() => _FullScreenImageGalleryState();
}

class _FullScreenImageGalleryState extends State<FullScreenImageGallery> {
  late PageController _controller;
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (widget.images.length > 1)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                '${currentIndex + 1} / ${widget.images.length}',
                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
      body: PageView.builder(
        controller: _controller,
        onPageChanged: (index) => setState(() => currentIndex = index),
        itemCount: widget.images.length,
        itemBuilder: (context, index) => InteractiveViewer(
          panEnabled: true,
          boundaryMargin: const EdgeInsets.all(20),
          minScale: 0.5,
          maxScale: 4.0,
          child: Center(
            child: Image.network(
              widget.images[index],
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => Container(
                color: Colors.grey[900],
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.broken_image, size: 80, color: Colors.grey),
                    SizedBox(height: 16),
                    Text('Failed to load image', style: TextStyle(color: Colors.grey, fontSize: 16)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}




/// ================= ZOOM BUTTON =================
class _ZoomButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _ZoomButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black54,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(icon, color: Colors.white, size: 22),
        ),
      ),
    );
  }
}