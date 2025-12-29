import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_colors.dart';
import '../../core/session/session_manager.dart';
import '../widgets/image_carousel.dart';
import 'price_calculator.dart';

/// ==========================
/// MODELS
/// ==========================

class MiningDetails {
  final String mineName;
  final String ownerName;
  final String location;
  final String contact;

  MiningDetails({
    required this.mineName,
    required this.ownerName,
    required this.location,
    required this.contact,
  });

  Map<String, dynamic> toJson() => {
        'mineName': mineName,
        'ownerName': ownerName,
        'location': location,
        'contact': contact,
      };

  factory MiningDetails.fromJson(Map<String, dynamic> j) => MiningDetails(
        mineName: j['mineName'] ?? '',
        ownerName: j['ownerName'] ?? '',
        location: j['location'] ?? '',
        contact: j['contact'] ?? '',
      );
}

class SocialLinks {
  final String website;
  final String instagram;
  final String youtube;

  SocialLinks({
    required this.website,
    required this.instagram,
    required this.youtube,
  });

  Map<String, dynamic> toJson() => {
        'website': website,
        'instagram': instagram,
        'youtube': youtube,
      };

  factory SocialLinks.fromJson(Map<String, dynamic> j) => SocialLinks(
        website: j['website'] ?? '',
        instagram: j['instagram'] ?? '',
        youtube: j['youtube'] ?? '',
      );
}

class Product {
  final String id;
  final String productCode;
  final String name;
  final String description;
  final List<String> images;

  // Additional attributes per spec
  final List<String> synonyms;
  final String materialPointers; // material liners & pointers (text)
  final String? handcraftItemName; // if handicraft
  final Map<String, double>? traderGradePrice; // optional trader measurement pricing

  /// Filters
  final List<String> types;
  final List<String> utilities;
  final List<String> colors;
  final List<String> naturalColors;
  final String origin;
  final String stateOrCountry;
  final String processingNature;
  final String materialNaturality;
  final List<String> finishes;
  final List<String> textures;

  /// Availability
  final String sizes;
  final String thickness;

  /// Pricing
  final Map<String, double> gradePrice;

  /// Admin only
  final MiningDetails? miningDetails;

  final SocialLinks socialLinks;

  Product({
    required this.id,
    required this.productCode,
    required this.name,
    required this.description,
    required this.images,
    this.synonyms = const [],
    this.materialPointers = '',
    this.handcraftItemName,
    this.traderGradePrice,
    required this.types,
    required this.utilities,
    required this.colors,
    required this.naturalColors,
    required this.origin,
    required this.stateOrCountry,
    required this.processingNature,
    required this.materialNaturality,
    required this.finishes,
    required this.textures,
    required this.sizes,
    required this.thickness,
    required this.gradePrice,
    this.miningDetails,
    required this.socialLinks,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'productCode': productCode,
        'name': name,
        'description': description,
        'images': images,
        'synonyms': synonyms,
        'materialPointers': materialPointers,
        'handcraftItemName': handcraftItemName,
        'traderGradePrice': traderGradePrice,
        'types': types,
        'utilities': utilities,
        'colors': colors,
        'naturalColors': naturalColors,
        'origin': origin,
        'stateOrCountry': stateOrCountry,
        'processingNature': processingNature,
        'materialNaturality': materialNaturality,
        'finishes': finishes,
        'textures': textures,
        'sizes': sizes,
        'thickness': thickness,
        'gradePrice': gradePrice,
        'miningDetails': miningDetails?.toJson(),
        'socialLinks': socialLinks.toJson(),
      };

  factory Product.fromJson(Map<String, dynamic> j) => Product(
        id: j['id'] ?? '',
        productCode: j['productCode'] ?? '',
        name: j['name'] ?? '',
        description: j['description'] ?? '',
        images: (j['images'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
        synonyms: (j['synonyms'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
        materialPointers: j['materialPointers'] ?? '',
        handcraftItemName: j['handcraftItemName'],
        traderGradePrice: (j['traderGradePrice'] as Map<String, dynamic>?)?.map((k, v) => MapEntry(k, (v as num).toDouble())),
        types: (j['types'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
        utilities: (j['utilities'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
        colors: (j['colors'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
        naturalColors: (j['naturalColors'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
        origin: j['origin'] ?? '',
        stateOrCountry: j['stateOrCountry'] ?? '',
        processingNature: j['processingNature'] ?? '',
        materialNaturality: j['materialNaturality'] ?? '',
        finishes: (j['finishes'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
        textures: (j['textures'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
        sizes: j['sizes'] ?? '',
        thickness: j['thickness'] ?? '',
        gradePrice: (j['gradePrice'] as Map<String, dynamic>?)?.map((k, v) => MapEntry(k, (v as num).toDouble())) ?? {},
        miningDetails: j['miningDetails'] != null ? MiningDetails.fromJson(Map<String, dynamic>.from(j['miningDetails'])) : null,
        socialLinks: SocialLinks.fromJson(Map<String, dynamic>.from(j['socialLinks'] ?? {})),
      );
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
  List<Product> _products = [];

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
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString('catalog_products');
    if (stored != null && stored.isNotEmpty) {
      try {
        final list = jsonDecode(stored) as List<dynamic>;
        _products = list.map((e) => Product.fromJson(Map<String, dynamic>.from(e))).toList();
        setState(() {});
        return;
      } catch (e) {
        // fallback to defaults
      }
    }
    _products = _mockProducts();
    setState(() {});
  }

  Future<void> _persistProducts() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(_products.map((p) => p.toJson()).toList());
    await prefs.setString('catalog_products', encoded);
  }

  Future<void> _saveLead(Map<String, dynamic> lead) async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString('leads') ?? '[]';
    final list = (jsonDecode(stored) as List<dynamic>).toList();
    list.add(lead);
    await prefs.setString('leads', jsonEncode(list));
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
    final products = _applyFilters(_products);
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

      floatingActionButton: FloatingActionButton(onPressed: () {

        context.pushNamed("catalogueEntry");
      },
        backgroundColor: primary,
        child: const Icon(Icons.add),

      ),
      body: FadeTransition(
        opacity: _fade,
        child: Column(
          children: [
            _searchBar(),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: products.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  childAspectRatio: 0.38,
                  crossAxisSpacing: 5,
                  mainAxisSpacing: 10,),
                itemBuilder: (_, i) => _productCard(products[i]),
              ),
            ),
          ],
        ),
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
  Widget _productCard(Product p) {
    return GestureDetector(
      onTap: () => _openDetails(p),
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// IMAGE
            AspectRatio(
              aspectRatio: 0.72,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                child: ImageCarousel.builder(
                  itemCount: p.images.length,
                  itemBuilder: (_, i) => Image.network(
                    p.images[i],
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),

            /// CONTENT
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// NAME
                  Text(
                    p.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),

                  const SizedBox(height: 6),

                  /// TAGS
                  Wrap(
                    spacing: 6,
                    runSpacing: -8,
                    children: [
                      _infoChip(p.types.first),
                      _infoChip(p.origin),
                      _infoChip(p.finishes.first),
                    ],
                  ),

                  const SizedBox(height: 8),

                  /// PRICE + CTA
                  Row(
                    children: [
                      Text(
                        "₹${p.gradePrice['A']} / sqft",
                        style: TextStyle(
                          color: dark,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const Spacer(),
                      Icon(Icons.arrow_forward_ios, size: 14, color: primary),
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

  Widget _infoChip(String text) {
    return Chip(
      label: Text(text, style: const TextStyle(fontSize: 11)),
      // Use helper to construct color with opacity without accessing deprecated getters
      backgroundColor: _colorWithOpacity(light, 0.25),
      visualDensity: VisualDensity.compact,
    );
  }

  // Helper to create a color with specified opacity without using deprecated
  // Color component getters (use bit-manipulation which is stable).
  Color _colorWithOpacity(Color c, double opacity) {
    // The .r/.g/.b accessors are in 0..1 range (double) for the current SDK.
    // Convert to 0..255 ints and clamp to valid byte range.
    int toByte(double v) {
      final val = (v * 255).round();
      if (val < 0) return 0;
      if (val > 255) return 255;
      return val;
    }

    final r = toByte(c.r);
    final g = toByte(c.g);
    final b = toByte(c.b);
    return Color.fromRGBO(r, g, b, opacity);
  }


  /// ==========================
  /// DETAILS PAGE
  /// ==========================

  void _openDetails(Product p) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        expand: false,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
            // Avoid withOpacity; use fromRGBO to specify an alpha value
            boxShadow: [BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.08), blurRadius: 10)],
          ),
          padding: const EdgeInsets.all(16),
          child: ListView(
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
                        Text(p.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text('Code: ${p.productCode}', style: TextStyle(color: Colors.grey[700])),
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

              // Image carousel
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  height: 220,
                  child: ImageCarousel.builder(
                    itemCount: p.images.length,
                    itemBuilder: (_, i) => Image.network(p.images[i], fit: BoxFit.cover),
                    autoPlay: true,
                    enableInfiniteScroll: true,
                    viewportFraction: 1.0,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Specifications section
              Text('Product Specifications', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: dark)),
              const SizedBox(height: 8),
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                color: Colors.grey[50],
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      _specRow('Type', p.types.join(', ')),
                      const Divider(),
                      _specRow('Utility', p.utilities.join(', ')),
                      const Divider(),
                      _specRow('Colour / Natural Colour', '${p.colors.join(', ')} / ${p.naturalColors.join(', ')}'),
                      const Divider(),
                      _specRow('Finish / Texture', '${p.finishes.join(', ')} / ${p.textures.join(', ')}'),
                      const Divider(),
                      _specRow('Sizes / Thickness', '${p.sizes} / ${p.thickness}'),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Additional attributes (synonyms, material pointers, handicraft name)
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                color: Colors.grey[50],
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (p.synonyms.isNotEmpty) ...[
                        const Text('Synonyms', style: TextStyle(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 6),
                        Wrap(spacing: 8, runSpacing: 6, children: p.synonyms.map((s) => Chip(label: Text(s))).toList()),
                        const Divider(),
                      ],

                      if (p.materialPointers.isNotEmpty) ...[
                        const Text('Material Pointers', style: TextStyle(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 6),
                        Text(p.materialPointers, style: TextStyle(color: Colors.grey[800])),
                        const Divider(),
                      ],

                      if (p.handcraftItemName != null && p.handcraftItemName!.isNotEmpty) ...[
                        const Text('Handicraft Item', style: TextStyle(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 6),
                        Text(p.handcraftItemName ?? '', style: TextStyle(color: Colors.grey[800])),
                        const Divider(),
                      ],

                      if (p.traderGradePrice != null && p.traderGradePrice!.isNotEmpty) ...[
                        const Text('Trader Measurement Pricing', style: TextStyle(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 6),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: p.traderGradePrice!.entries.map((e) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Text('${e.key}: ₹${e.value.toStringAsFixed(2)} per unit', style: TextStyle(color: Colors.grey[800])),
                          )).toList(),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Admin-only section (mining details)
              if (isAdmin && p.miningDetails != null) ...[
                Text('Admin - Mining Details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: dark)),
                const SizedBox(height: 8),
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  color: Colors.grey[50],
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _specRow('Mine', p.miningDetails!.mineName),
                        const Divider(),
                        _specRow('Owner', p.miningDetails!.ownerName),
                        const Divider(),
                        _specRow('Location', p.miningDetails!.location),
                        const Divider(),
                        _specRow('Contact', p.miningDetails!.contact),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // Actions
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.calculate_outlined),
                      label: const Text('Price Calculator'),
                      style: ElevatedButton.styleFrom(backgroundColor: primary),
                      onPressed: () => _priceCalculator(p),
                    ),
                  ),
                  const SizedBox(width: 12),
                  if (isAdmin) ...[
                    ElevatedButton.icon(
                      icon: const Icon(Icons.edit),
                      label: const Text('Edit'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[200]),
                      onPressed: () => _editProduct(p),
                    ),
                  ],
                ],
              ),

              const SizedBox(height: 16),

              // Features matrix table
              Text('Feature Access', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: dark)),
              const SizedBox(height: 8),
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                color: Colors.grey[50],
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Table(
                    columnWidths: const {
                      0: FlexColumnWidth(2),
                      1: FlexColumnWidth(1),
                      2: FlexColumnWidth(1),
                    },
                    children: [
                      const TableRow(children: [
                        Padding(padding: EdgeInsets.all(8), child: Text('Feature', style: TextStyle(fontWeight: FontWeight.bold))),
                        Padding(padding: EdgeInsets.all(8), child: Text('Executive', style: TextStyle(fontWeight: FontWeight.bold))),
                        Padding(padding: EdgeInsets.all(8), child: Text('Admin', style: TextStyle(fontWeight: FontWeight.bold))),
                      ]),
                      _featureRow('Catalogue', true, true),
                      _featureRow('Filters', true, true),
                      _featureRow('Price Calculator', true, false),
                      _featureRow('Mining Details', false, true),
                      _featureRow('Product Edit', false, true),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Close / Done
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Done', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _specRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 130, child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600))),
          Expanded(child: Text(value, style: TextStyle(color: Colors.grey[800]))),
        ],
      ),
    );
  }

  TableRow _featureRow(String feature, bool exec, bool admin) {
    return TableRow(children: [
      Padding(padding: const EdgeInsets.all(8), child: Text(feature)),
      Padding(padding: const EdgeInsets.all(8), child: Center(child: exec ? const Icon(Icons.check, color: Colors.green) : const SizedBox())),
      Padding(padding: const EdgeInsets.all(8), child: Center(child: admin ? const Icon(Icons.check, color: Colors.green) : const SizedBox())),
    ]);
  }


  /// ==========================
  /// PRICE CALCULATOR
  /// ==========================

  void _priceCalculator(Product p) async {
    // Open the reusable PriceCalculator dialog. It returns a PriceCalculationResult on Save.
    final PriceCalculationResult? result = await showDialog<PriceCalculationResult>(
      context: context,
      builder: (context) => PriceCalculator(productId: p.id, gradePrices: p.gradePrice),
    );

    if (result == null) return; // user cancelled

    // Build a mock lead/quote payload (ready to send to backend)
    final leadPayload = {
      'executiveId': SessionManager.getUserId()?.toString() ?? '',
      'productId': result.productId,
      'grade': result.grade,
      'measurementType': result.measurementType,
      'unit': result.unit,
      'pricePerUnit': result.pricePerUnit,
      'quantity': result.quantity,
      'weight': result.weight,
      'transportCharge': result.transportCharge,
      'tax': result.tax,
      'taxPercent': result.taxPercent,
      'misc': result.misc,
      'total': result.total,
      'timestamp': DateTime.now().toIso8601String(),
    };

    // TODO: send leadPayload to backend. For now, mock save and show confirmation.
    print('Mock Lead saved: ${leadPayload}');
    try {
      await _saveLead(leadPayload);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Quote saved locally: ₹${result.total.toStringAsFixed(2)}')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Quote saved (in-memory): ₹${result.total.toStringAsFixed(2)}')));
    }
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

  /// ==========================
  /// DATA
  /// ==========================

  List<Product> _applyFilters(List<Product> list) {
    var res = list.where((p) => p.name.toLowerCase().contains(_search.toLowerCase())).toList();

    // Apply each filter group
    _filters.forEach((key, values) {
      if (values.isEmpty) return;
      if (key == 'Type') {
        res = res.where((p) => p.types.any((t) => values.contains(t))).toList();
      } else if (key == 'Finish') {
        res = res.where((p) => p.finishes.any((f) => values.contains(f))).toList();
      } else if (key == 'Origin') {
        res = res.where((p) => values.contains(p.origin)).toList();
      } else if (key == 'Natural Colour') {
        res = res.where((p) => p.naturalColors.any((c) => values.contains(c))).toList();
      } else if (key == 'Price Range') {
        res = res.where((p) {
          final price = p.gradePrice['A'] ?? 0.0;
          for (final v in values) {
            if (v == '0-50' && price >=0 && price <50) return true;
            if (v == '50-100' && price >=50 && price <100) return true;
            if (v == '100-200' && price >=100 && price <200) return true;
            if (v == '200-1000' && price >=200 && price <1000) return true;
            if (v == '1000+' && price >=1000) return true;
          }
          return false;
        }).toList();
      } else if (key == 'Handicraft') {
        res = res.where((p) => p.handcraftItemName != null && p.handcraftItemName!.isNotEmpty && values.contains(p.handcraftItemName)).toList();
      }
    });

    return res;
  }

  List<Product> _mockProducts() => [
    Product(
      id: "1",
      productCode: "MAR-001",
      name: "Makrana White Marble",
      description: "Premium white marble",
      images: ["https://images.unsplash.com/photo-1600585154340-be6161a56a0c"],
      synonyms: ['Makrana','White Makrana'],
      materialPointers: 'Best used for flooring and countertops; avoid acid cleaners.',
      handcraftItemName: null,
      traderGradePrice: {'A': 260.0},
      types: ["Marble"],
      utilities: ["Flooring", "Kitchen"],
      colors: ["White"],
      naturalColors: ["White"],
      origin: "North India",
      stateOrCountry: "Rajasthan",
      processingNature: "Fresh",
      materialNaturality: "Natural",
      finishes: ["Polish"],
      textures: ["Plain"],
      sizes: "Random slabs",
      thickness: "18mm",
      gradePrice: {"A": 250},
      miningDetails: MiningDetails(
        mineName: "Makrana Mine",
        ownerName: "Govt",
        location: "Rajasthan",
        contact: "NA",
      ),
      socialLinks: SocialLinks(
        website: "",
        instagram: "",
        youtube: "",
      ),
    ),
  ];

  void _shareAllProducts() {}

  // Simple placeholder edit dialog for admins. Replace with full editor as needed.
  void _editProduct(Product p) {
    final nameCtrl = TextEditingController(text: p.name);
    final priceCtrl = TextEditingController(text: p.gradePrice['A']?.toString() ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Product'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Name')),
            const SizedBox(height: 8),
            TextField(controller: priceCtrl, decoration: const InputDecoration(labelText: 'Price (A)'), keyboardType: TextInputType.number),
          ],
        ),
        actions: [
          TextButton(onPressed: () {
            nameCtrl.dispose();
            priceCtrl.dispose();
            Navigator.of(context).pop();
          }, child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final newName = nameCtrl.text.trim();
              final newPrice = double.tryParse(priceCtrl.text.trim()) ?? p.gradePrice['A'] ?? 0.0;
              nameCtrl.dispose();
              priceCtrl.dispose();

              // Update in-memory list and persist
              final idx = _products.indexWhere((x) => x.id == p.id);
              if (idx != -1) {
                final updated = Product(
                  id: p.id,
                  productCode: p.productCode,
                  name: newName,
                  description: p.description,
                  images: p.images,
                  synonyms: p.synonyms,
                  materialPointers: p.materialPointers,
                  handcraftItemName: p.handcraftItemName,
                  traderGradePrice: p.traderGradePrice,
                  types: p.types,
                  utilities: p.utilities,
                  colors: p.colors,
                  naturalColors: p.naturalColors,
                  origin: p.origin,
                  stateOrCountry: p.stateOrCountry,
                  processingNature: p.processingNature,
                  materialNaturality: p.materialNaturality,
                  finishes: p.finishes,
                  textures: p.textures,
                  sizes: p.sizes,
                  thickness: p.thickness,
                  gradePrice: {...p.gradePrice, 'A': newPrice},
                  miningDetails: p.miningDetails,
                  socialLinks: p.socialLinks,
                );
                _products[idx] = updated;
                await _persistProducts();
                setState(() {});
              }

              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Saved (mock): $newName · ₹${newPrice.toStringAsFixed(2)}')));
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

class RoleTheme {
  static Color primary(String role) =>
      role == 'superadmin'
          ? AppColors.primaryGold
          : role == 'admin'
          ? AppColors.secondaryBlue
          : AppColors.primaryTeal;

  static Color primaryLight(String role) =>
      role == 'superadmin'
          ? AppColors.primaryGoldLight
          : role == 'admin'
          ? AppColors.secondaryBlueLight
          : AppColors.primaryTealLight;

  static Color primaryDark(String role) =>
      role == 'superadmin'
          ? AppColors.primaryGoldDark
          : role == 'admin'
          ? AppColors.secondaryBlueDark
          : AppColors.primaryTealDark;
}
