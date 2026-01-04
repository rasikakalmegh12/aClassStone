import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:apclassstone/bloc/catalogue/get_catalogue_methods/get_catalogue_bloc.dart';
import 'package:apclassstone/bloc/catalogue/get_catalogue_methods/get_catalogue_event.dart';
import 'package:apclassstone/bloc/catalogue/get_catalogue_methods/get_catalogue_state.dart';
import 'package:apclassstone/bloc/catalogue/post_catalogue_methods/post_catalogue_bloc.dart';
import 'package:apclassstone/bloc/catalogue/post_catalogue_methods/post_catalogue_event.dart';
import 'package:apclassstone/bloc/catalogue/post_catalogue_methods/post_catalogue_state.dart';
import 'package:apclassstone/api/models/request/PostCatalogueCommonRequestBody.dart';
import 'package:apclassstone/api/models/request/ProductEntryRequestBody.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:path_provider/path_provider.dart';
import '../../api/models/request/PostMinesEntryRequestBody.dart';
import '../../api/models/request/PutCatalogueOptionEntryRequestBody.dart';
import '../../core/constants/app_colors.dart';
import '../../core/session/session_manager.dart';
import '../widgets/app_bar.dart';
import '../widgets/dropdown_widget.dart';
import '../widgets/custom_loader.dart';

class CatalogueEntryPage extends StatefulWidget {
  const CatalogueEntryPage({super.key});

  @override
  State<CatalogueEntryPage> createState() => _CatalogueEntryPageState();
}

class _CatalogueEntryPageState extends State<CatalogueEntryPage> {
  final ImagePicker _picker = ImagePicker();
  final List<File> _images = [];
  final int _maxImages = 7;
// Add controllers / variables in your State
  final _priceArchitectAGradeController = TextEditingController();
  final _priceArchitectBGradeController = TextEditingController();
  final _priceArchitectCGradeController = TextEditingController();

  final _priceTraderAGradeController = TextEditingController();
  final _priceTraderBGradeController = TextEditingController();
  final _priceTraderCGradeController = TextEditingController();

  final _marketingOneLinerController = TextEditingController();


  String? selectedPriceRangeId;
  String? selectedMineId;

  List<DropdownOption> priceRangeOptions = [];
  List<DropdownOption> mineOptions = [];

  // Form data
  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _productCodeController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _pricePerSqFtController = TextEditingController();

  // Section visibility
  bool _showSection1 = true;
  bool _showSection2 = false;
  String? _savedProductId; // Store product ID from successful section 1 submission

  // Multi-select filters
  final TextEditingController _synonymController = TextEditingController();
  final List<String> _synonyms = [];

  final List<String> _selectedProductTypes = [];
  final List<String> _selectedUtilities = [];
  final List<String> _selectedColours = [];
  final List<String> _selectedNaturalColours = [];
  final List<String> _selectedOrigins = [];
  final List<String> _selectedStates = [];
  final List<String> _selectedPriceRanges = [];
  final List<String> _selectedProcessing = [];
  final List<String> _selectedNaturality = [];
  final List<String> _selectedFinishes = [];
  final List<String> _selectedTextures = [];
  final List<String> _selectedHandicrafts = [];

  // Track which section is in "add mode"
  String? _addingSectionTitle;
  final TextEditingController _newOptionController = TextEditingController();

  // For State/Country type selection
  String? _selectedStateCountryType; // 'State' or 'Country'

  // For custom color picker
  Color _pickerColor = const Color(0xFF2196F3);
  final TextEditingController _colorNameController = TextEditingController();

  // Filter options - populated from API
  List<String> productTypes = [];
  List<String> utilities = [];
  List<String> origins = [];
  List<String> states = [];
  List<String> processing = [];
  List<String> naturality = [];
  List<String> finishes = [];
  List<String> textures = [];
  List<String> handicrafts = [];

  // Store full data objects for dropdowns (with id and name)
  List<DropdownOption> productTypeOptions = [];
  List<DropdownOption> utilityOptions = [];

  // Maps to store option ID by name (for converting selected names to IDs)
  Map<String, String> colorIdMap = {};
  Map<String, String> naturalColorIdMap = {};
  Map<String, String> finishIdMap = {};
  Map<String, String> textureIdMap = {};
  Map<String, String> originIdMap = {};
  Map<String, String> stateCountryIdMap = {};
  Map<String, String> processingNatureIdMap = {};
  Map<String, String> materialNaturalityIdMap = {};
  Map<String, String> handicraftIdMap = {};

  // Selected dropdown values
  String? selectedProductTypeId;
  String? selectedUtilityId;

  // // Color options with hex codes
  // final Map<String, Color> colourMap = {
  //   'Black': const Color(0xFF000000),
  //   'Blue': const Color(0xFF2196F3),
  //   'Beige': const Color(0xFFF5F5DC),
  //   'White': const Color(0xFFFFFFFF),
  //   'Red': const Color(0xFFE53935),
  //   'Pink': const Color(0xFFE91E63),
  //   'Golden': const Color(0xFFFFD700),
  //   'Brown': const Color(0xFF795548),
  //   'Silver': const Color(0xFFC0C0C0),
  //   'Grey': const Color(0xFF9E9E9E),
  //   'Green': const Color(0xFF4CAF50),
  //   'Yellow': const Color(0xFFFDD835),
  //   'Orange': const Color(0xFFFF9800),
  //   'Purple': const Color(0xFF9C27B0),
  //   'Cream': const Color(0xFFFFFDD0),
  // };

  final List<String> colours = [
    'Black', 'Blue', 'Beige', 'White', 'Red', 'Pink', 'Golden',
    'Brown', 'Silver', 'Grey', 'Green', 'Yellow', 'Orange', 'Purple', 'Cream'
  ];

  final List<String> priceRanges = [
    '0–50', '50–100', '100–200', '200–1000', 'Above 1000'
  ];

  final _mineFormKey = GlobalKey<FormState>();

  final _mineNameController = TextEditingController();
  final _mineLocationController = TextEditingController();
  final _ownerNameController = TextEditingController();
  final _contactPhoneController = TextEditingController();
  final _contactEmailController = TextEditingController();
  final _websiteUrlController = TextEditingController();
  final _instagramUrlController = TextEditingController();
  final _youtubeUrlController = TextEditingController();
  final _pinterestUrlController = TextEditingController();

  bool _blocksAvailable = true;
  bool _mineIsActive = true;



  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    context.read<GetProductTypeBloc>().add(FetchGetProductType());
    context.read<GetUtilitiesBloc>().add(FetchGetUtilities());
    context.read<GetColorsBloc>().add(FetchGetColors());
    context.read<GetFinishesBloc>().add(FetchGetFinishes());
    context.read<GetTexturesBloc>().add(FetchGetTextures());
    context.read<GetNaturalColorsBloc>().add(FetchGetNaturalColors());
    context.read<GetOriginsBloc>().add(FetchGetOrigins());
    context.read<GetStateCountriesBloc>().add(FetchGetStateCountries());
    context.read<GetProcessingNatureBloc>().add(FetchGetProcessingNature());
    context.read<GetNaturalMaterialBloc>().add(FetchGetNaturalMaterial());
    context.read<GetHandicraftsBloc>().add(FetchGetHandicrafts());
    context.read<GetPriceRangeBloc>().add(FetchGetPriceRange());
    context.read<GetMinesOptionBloc>().add(FetchGetMinesOption());
  }


  @override
  void dispose() {
    _productNameController.dispose();
    _productCodeController.dispose();
    _descriptionController.dispose();
    _pricePerSqFtController.dispose();
    _newOptionController.dispose();
    _colorNameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    if (_images.length >= _maxImages) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Maximum $_maxImages images allowed'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        final compressedFile = await _compressImage(File(pickedFile.path));
        if (compressedFile != null) {
          // Add to local list first
          setState(() {
            _images.add(compressedFile);
          });

          // If we have a product ID (Section 2), upload immediately
          if (_savedProductId != null && _savedProductId!.isNotEmpty) {
            _uploadImageToServer(
              compressedFile,
              setAsPrimary: _images.length == 1, // First image is primary
              sortOrder: _images.length - 1,
            );
          }
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  Future<File?> _compressImage(File file) async {
    try {
      final dir = await getTemporaryDirectory();
      final targetPath =
          '${dir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg';

      final result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath,
        quality: 70,
        minWidth: 1024,
        minHeight: 1024,
      );

      return result != null ? File(result.path) : null;
    } catch (e) {
      print('Error compressing image: $e');
      return file; // Return original if compression fails
    }
  }

  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
  }

  // Upload image to server via CatalogueImageEntryBloc
  void _uploadImageToServer(File imageFile, {required bool setAsPrimary, required int sortOrder}) {
    if (_savedProductId == null || _savedProductId!.isEmpty) {
      if (kDebugMode) print('⚠️ No product ID available, skipping image upload');
      return;
    }

    // Dispatch event to upload image
    context.read<CatalogueImageEntryBloc>().add(UploadCatalogueImage(
      productId: _savedProductId!,
      imageFile: imageFile,
      setAsPrimary: true,
      sortOrder: 0,
      showLoader: true,
    ));

    // Listen to upload state
    _listenToCatalogueImageEntryState(imageFile);
  }

  // Listener for CatalogueImageEntryBloc state changes
  void _listenToCatalogueImageEntryState(File uploadedFile) {
    final subscription = context.read<CatalogueImageEntryBloc>().stream.listen((state) {
      if (state is CatalogueImageEntryLoading && state.showLoader) {
        // Show loading indicator
        showCustomProgressDialog(context, title: 'Uploading Image...');
        if (kDebugMode) print('📤 Uploading image...');
      } else if (state is CatalogueImageEntrySuccess) {
        dismissCustomProgressDialog(context);
        if(state.response.statusCode==200|| state.response.statusCode==201){
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ ${state.response.message ?? "Image uploaded successfully"}'),
              backgroundColor: AppColors.success,
              duration: const Duration(seconds: 2),
            ),
          );
        }
        else{
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ ${state.response.message ?? "Image uploaded failed"}'),
              backgroundColor: AppColors.error,
              duration: const Duration(seconds: 2),
            ),
          );
        }
        // Show success message


        if (kDebugMode) {
          print('✅ Image uploaded: ${state.response.data?.url}');
          print('   Image ID: ${state.response.data?.imageId}');
          print('   Is Primary: ${state.response.data?.isPrimary}');
        }
      } else if (state is CatalogueImageEntryError) {
        dismissCustomProgressDialog(context);
        // Show error and remove from local list
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ ${state.message}'),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 3),
          ),
        );

        // Remove failed image from list
        setState(() {
          _images.remove(uploadedFile);
        });

        if (kDebugMode) print('❌ Image upload failed: ${state.message}');
      }
    });

    // Auto-cancel subscription after 30 seconds
    Future.delayed(const Duration(seconds: 30), () => subscription.cancel());
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Choose Image Source',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildSourceOption(
                  icon: Icons.camera_alt,
                  label: 'Camera',
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  },
                ),
                _buildSourceOption(
                  icon: Icons.photo_library,
                  label: 'Gallery',
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
                  },
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildSourceOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 120,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.primaryGold.withAlpha(50)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, size: 40, color: AppColors.primaryGold),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: CoolAppCard(
          title: _showSection1 ? "Product Entry - Step 1" : "Product Entry - Step 2",
          backgroundColor: SessionManager.getUserRole().toString().toLowerCase() == "superadmin"
              ? AppColors.superAdminPrimary
              : AppColors.primaryDeepBlue,
        ),
      ),
      body: MultiBlocListener(
        listeners: [
        BlocListener<GetMinesOptionBloc, GetMinesOptionState>(
      listener: (context, state) {
        if (state is GetMinesOptionLoaded) {
          setState(() {
            mineOptions = state.response.data!
                .where((item) => item.id != null && item.name != null && item.name!.isNotEmpty)
                .map((item) => DropdownOption(
              id: item.id!,
              name: item.name!,
              code: item.location,
            ))
                .toList();

          });
        }
      },
        )
        ],

        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section 1: Basic Product Information
                    if (_showSection1) ...[
                      _buildSection1(),
                    ],

                    // Section 2: Additional Details
                    if (_showSection2) ...[
                      _buildSection2(),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Section 1: Basic Product Information
  Widget _buildSection1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Progress Indicator
        _buildProgressIndicator(1),
        const SizedBox(height: 24),

        // Basic Information Card
        Container(
          padding: const EdgeInsets.all(12),
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
              Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: SessionManager.getUserRole().toString().toLowerCase() == "superadmin"
                        ? AppColors.superAdminPrimary
                        : AppColors.primaryDeepBlue,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Basic Product Information',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Fill in the essential details to create your product',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
              ),
              const SizedBox(height: 24),

              // Product Name
              TextField(
                controller: _productNameController,
                decoration: InputDecoration(
                  labelText: 'Product Name *',
                  hintText: 'Enter product name',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.inventory_2_outlined),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
              ),
              const SizedBox(height: 10),

              // Product Code
              TextField(
                controller: _productCodeController,
                decoration: InputDecoration(
                  labelText: 'Product Code*',
                  hintText: 'Auto-generated if empty',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.qr_code),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
              ),
              const SizedBox(height: 10 ),

              // Description
              TextField(
                controller: _descriptionController,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: 'Description',
                  hintText: 'Enter product description',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.description_outlined),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
              ),
              const SizedBox(height: 10),

              // Product Type Dropdown
              BlocBuilder<GetProductTypeBloc, GetProductTypeState>(
                builder: (context, state) {
                  if (state is GetProductTypeLoaded) {
                    if (state.response.data != null && state.response.data!.isNotEmpty) {
                      productTypeOptions = state.response.data!
                          .where((item) => item.id != null && item.name != null && item.name!.isNotEmpty)
                          .map((item) => DropdownOption(
                                id: item.id!,
                                name: item.name!,
                                code: item.code,
                              ))
                          .toList();
                    }
                    return CustomDropdownSection(
                      title: 'Product Type *',
                      options: productTypeOptions,
                      selectedId: selectedProductTypeId,
                      onChanged: (id, name) {
                        setState(() {
                          selectedProductTypeId = id;
                        });
                      },
                      icon: Icons.category,
                    );
                  } else if (state is GetProductTypeLoading && state.showLoader) {
                    return _buildLoadingContainer();
                  } else if (state is GetProductTypeError) {
                    return _buildErrorContainer('product types', state.message);
                  }
                  return CustomDropdownSection(
                    title: 'Product Type *',
                    options: productTypeOptions,
                    selectedId: selectedProductTypeId,
                    onChanged: (id, name) {
                      setState(() {
                        selectedProductTypeId = id;
                      });
                    },
                    icon: Icons.category,
                  );
                },
              ),
              const SizedBox(height: 10),

              // Price Per Sq Ft
              TextField(
                controller: _pricePerSqFtController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Price Per Sq Ft *',
                  hintText: 'Enter price per square feet',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.currency_rupee),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  suffixText: '₹/sq ft',
                ),
              ),
              // Architect & Trader Pricing Grid
              const SizedBox(height: 16),
              const Text(
                'Pricing by Segment (₹/sq ft)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(
                'Set differentiated prices for architects and traders across grade levels.',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              ),

              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                padding: const EdgeInsets.all(5),
                child: Column(
                  children: [
                    const Row(
                      children: [
                        Expanded(child: SizedBox()),
                        Expanded(
                          child: Center(
                            child: Text('Grade A', style: TextStyle(fontWeight: FontWeight.w600)),
                          ),
                        ),
                        Expanded(
                          child: Center(
                            child: Text('Grade B', style: TextStyle(fontWeight: FontWeight.w600)),
                          ),
                        ),
                        Expanded(
                          child: Center(
                            child: Text('Grade C', style: TextStyle(fontWeight: FontWeight.w600)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Architect Row
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Architect',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 2),
                            child: TextField(
                              controller: _priceArchitectAGradeController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                hintText: '0',
                                isDense: true,
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 2),
                            child: TextField(

                              controller: _priceArchitectBGradeController,
                              keyboardType: TextInputType.number,

                              decoration: const InputDecoration(
                                hintText: '0',

                                isDense: true,
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 2),
                            child: TextField(
                              controller: _priceArchitectCGradeController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                hintText: '0',
                                isDense: true,
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Trader Row
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Trader',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 2),
                            child: TextField(
                              controller: _priceTraderAGradeController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                hintText: '0',
                                isDense: true,
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 2),
                            child: TextField(
                              controller: _priceTraderBGradeController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                hintText: '0',
                                isDense: true,
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 2),
                            child: TextField(
                              controller: _priceTraderCGradeController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                hintText: '0',
                                isDense: true,
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

// Price Range Dropdown
              BlocBuilder<GetPriceRangeBloc, GetPriceRangeState>(
                builder: (context, state) {
                  if (state is GetPriceRangeLoaded) {
                    if (state.response.data != null && state.response.data!.isNotEmpty) {
                      priceRangeOptions = state.response.data!
                          .where((item) => item.id != null && item.name != null && item.name!.isNotEmpty)
                          .map((item) => DropdownOption(
                        id: item.id!,
                        name: item.name!,
                        code: item.code,
                      ))
                          .toList();
                    }
                    return CustomDropdownSection(
                      title: 'Price Range *',
                      options: priceRangeOptions,
                      selectedId: selectedPriceRangeId,
                      onChanged: (id, name) {
                        setState(() {
                          selectedPriceRangeId = id;
                        });
                      },
                      icon: Icons.stacked_bar_chart,
                    );
                  } else if (state is GetPriceRangeLoading && state.showLoader) {
                    return _buildLoadingContainer();
                  } else if (state is GetPriceRangeError) {
                    return _buildErrorContainer('price ranges', state.message);
                  }
                  return CustomDropdownSection(
                    title: 'Price Range *',
                    options: priceRangeOptions,
                    selectedId: selectedPriceRangeId,
                    onChanged: (id, name) {
                      setState(() {
                        selectedPriceRangeId = id;
                      });
                    },
                    icon: Icons.stacked_bar_chart,
                  );
                },
              ),
              const SizedBox(height: 10),

// Mine Dropdown
    BlocListener<GetMinesOptionBloc, GetMinesOptionState>(
                listener: (context, state) {
                  if (state is GetMinesOptionLoaded) {
                    setState(() {
                      mineOptions = state.response.data!
                          .where((item) => item.id != null && item.name != null && item.name!.isNotEmpty)
                          .map((item) => DropdownOption(
                        id: item.id!,
                        name: item.name!,
                        code: item.location,
                      ))
                          .toList();

                    });
                  }
                },
                child: BlocBuilder<GetMinesOptionBloc, GetMinesOptionState>(
                  builder: (context, state) {
                    if (kDebugMode) {
                      print('🔄 GetMinesOptionBloc state: ${state.runtimeType}');
                    }

                    if (state is GetMinesOptionLoaded) {
                      if (state.response.data != null && state.response.data!.isNotEmpty) {
                        mineOptions = state.response.data!
                            .where((item) => item.id != null && item.name != null && item.name!.isNotEmpty)
                            .map((item) => DropdownOption(
                          id: item.id!,
                          name: item.name!,
                          code: item.location,
                        ))
                            .toList();

                        if (kDebugMode) {
                          print('✅ Mines loaded: ${mineOptions.length} mines');
                        }
                      }
                      return CustomDropdownSection(
                        title: 'Mines *',
                        options: mineOptions,
                        selectedId: selectedMineId,
                        onChanged: (id, name) {
                          setState(() {
                            selectedMineId = id;
                          });
                        },
                        icon: Icons.landscape_outlined,
                        extraFeature: true,
                        widget: IconButton(
                            color:  SessionManager.getUserRole().toString().toLowerCase() == "superadmin"
                                ? AppColors.superAdminPrimary
                                : AppColors.primaryDeepBlue,
                            onPressed: () {
                          setState(() {
                            _openAddMineBottomSheet(context);
                          });
                          if (kDebugMode) {
                            print("Add Mines");
                          }
                        }, icon:
                         const Icon(Icons.add)),


                      );
                    } else if (state is GetMinesOptionLoading && state.showLoader) {
                      return _buildLoadingContainer();
                    } else if (state is GetMinesOptionsError) {
                      return _buildErrorContainer('mines', state.message);
                    }
                    return CustomDropdownSection(
                      title: 'Mines *',
                      options: mineOptions,
                      selectedId: selectedMineId,
                      onChanged: (id, name) {
                        setState(() {
                          selectedMineId = id;
                        });
                      },
                      icon: Icons.landscape_outlined,

                      extraFeature: true,
                        widget: const Icon(Icons.add),
                      onTap: (){
                        print("Add Mines");
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),

// Marketing One-liner
              TextField(
                controller: _marketingOneLinerController,
                maxLength: 80,
                decoration: InputDecoration(
                  labelText: 'Marketing One-liner',
                  hintText: 'Eg. Premium marble for luxury spaces',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.campaign_outlined),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  counterText: '',
                ),
              ),
              const SizedBox(height: 10),
              const SizedBox(height: 24),

              // Submit Button for Section 1
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _submitSection1,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: SessionManager.getUserRole().toString().toLowerCase() == "superadmin"
                        ? AppColors.superAdminPrimary
                        : AppColors.primaryDeepBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Continue to Add More Details',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  Color get _primaryRoleColor =>
      SessionManager.getUserRole().toString().toLowerCase() == "superadmin"
          ? AppColors.superAdminPrimary
          : AppColors.primaryDeepBlue;

  Color get _primaryRoleLight => _primaryRoleColor.withOpacity(0.08);

  void _openAddMineBottomSheet1(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return FractionallySizedBox(
          heightFactor: 0.8, // 80% of screen
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 20,
                  offset: const Offset(0, -6),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 12,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
              ),
              child: BlocConsumer<PostMinesEntryBloc, PostMinesEntryState>(
                listener: (context, state) {
                  if (state is PostMinesEntrySuccess) {
                    Navigator.of(ctx).pop();
                    context.read<GetMinesOptionBloc>().add(FetchGetMinesOption());
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Mine added successfully')),
                    );
                  } else if (state is PostMinesEntryError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(state.message ?? 'Failed to add mine')),
                    );
                  }
                },
                builder: (context, state) {
                  final isLoading = state is PostMinesEntryLoading;

                  return Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      // drag handle
                      Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade400,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),

                      // header
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                        decoration: BoxDecoration(
                          color: _primaryRoleLight,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Container(
                              height: 32,
                              width: 32,
                              decoration: BoxDecoration(
                                color: _primaryRoleColor.withOpacity(0.15),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.landscape_outlined,
                                size: 18,
                                color: _primaryRoleColor,
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Expanded(
                              child: Text(
                                'Add New Mine',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close),
                              color: Colors.grey.shade700,
                              onPressed: () => Navigator.of(ctx).pop(),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),

                      // form in scroll
                      Expanded(
                        child: SingleChildScrollView(
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: _primaryRoleColor.withOpacity(0.12),
                              ),
                            ),
                            child: Form(
                              key: _mineFormKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Name
                                  _buildLabeledField(
                                    label: 'Mine Name *',
                                    icon: Icons.terrain_outlined,
                                    controller: _mineNameController,
                                    validator: (v) =>
                                    (v == null || v.trim().isEmpty) ? 'Name is required' : null,
                                  ),
                                  const SizedBox(height: 10),

                                  // Location
                                  _buildLabeledField(
                                    label: 'Location *',
                                    icon: Icons.location_on_outlined,
                                    controller: _mineLocationController,
                                    validator: (v) =>
                                    (v == null || v.trim().isEmpty) ? 'Location is required' : null,
                                  ),
                                  const SizedBox(height: 10),

                                  // Owner
                                  _buildLabeledField(
                                    label: 'Owner Name',
                                    icon: Icons.person_outline,
                                    controller: _ownerNameController,
                                  ),
                                  const SizedBox(height: 10),

                                  // Phone + Email in a row
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _buildLabeledField(
                                          label: 'Phone',
                                          icon: Icons.phone_outlined,
                                          controller: _contactPhoneController,
                                          keyboardType: TextInputType.phone,
                                          maxLength: 10
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: _buildLabeledField(
                                          label: 'Email',
                                          icon: Icons.email_outlined,
                                          controller: _contactEmailController,
                                          keyboardType: TextInputType.emailAddress,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),

                                  // website
                                  _buildLabeledField(
                                    label: 'Website',
                                    icon: Icons.public_outlined,
                                    controller: _websiteUrlController,
                                  ),
                                  const SizedBox(height: 10),

                                  // socials row 1
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _buildLabeledField(
                                          label: 'Instagram',
                                          icon: Icons.camera_alt_outlined,
                                          controller: _instagramUrlController,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: _buildLabeledField(
                                          label: 'YouTube',
                                          icon: Icons.play_circle_outline,
                                          controller: _youtubeUrlController,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),

                                  // socials row 2
                                  _buildLabeledField(
                                    label: 'Pinterest',
                                    icon: Icons.push_pin_outlined,
                                    controller: _pinterestUrlController,
                                  ),
                                  const SizedBox(height: 8),

                                  // toggles in card
                                  Container(
                                    margin: const EdgeInsets.only(top: 6),
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: _primaryRoleColor.withOpacity(0.12),
                                      ),
                                    ),
                                    child: Column(
                                      children: [
                                        SwitchListTile(
                                          contentPadding: EdgeInsets.zero,
                                          title: const Text('Blocks Available'),
                                          activeColor: _primaryRoleColor,
                                          value: _blocksAvailable,
                                          onChanged: (val) {
                                            setState(() {
                                              _blocksAvailable = val;
                                            });
                                          },
                                        ),
                                        const Divider(height: 0),
                                        SwitchListTile(
                                          contentPadding: EdgeInsets.zero,
                                          title: const Text('Active'),
                                          activeColor: _primaryRoleColor,
                                          value: _mineIsActive,
                                          onChanged: (val) {
                                            setState(() {
                                              _mineIsActive = val;
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // bottom buttons with primary color
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: _primaryRoleColor,
                                side: BorderSide(color: _primaryRoleColor.withOpacity(0.4)),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: isLoading ? null : () => Navigator.of(ctx).pop(),
                              child: const Text('Cancel'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _primaryRoleColor,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 2,
                              ),
                              onPressed: isLoading
                                  ? null
                                  : () {
                                if (_mineFormKey.currentState!.validate()) {
                                  final req = PostMinesEntryRequestBody(
                                    name: _mineNameController.text.trim(),
                                    location: _mineLocationController.text.trim(),
                                    ownerName: _ownerNameController.text.trim(),
                                    contactPhone: _contactPhoneController.text.trim(),
                                    contactEmail: _contactEmailController.text.trim(),
                                    blocksAvailable: _blocksAvailable,
                                    websiteUrl: _websiteUrlController.text.trim(),
                                    instagramUrl: _instagramUrlController.text.trim(),
                                    youtubeUrl: _youtubeUrlController.text.trim(),
                                    pinterestUrl: _pinterestUrlController.text.trim(),
                                    isActive: _mineIsActive,
                                  );
                                  context.read<PostMinesEntryBloc>().add(
                                    SubmitPostMinesEntry(
                                      requestBody: req,
                                      showLoader: true,
                                    ),
                                  );
                                }
                              },
                              child: isLoading
                                  ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                                  : const Text('Save Mine'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
  Widget _buildLabeledField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    String? Function(String?)? validator,
    int?maxLength,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: _primaryRoleColor,
          ),
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          maxLength: maxLength,
          decoration: InputDecoration(

            counterText: '',
            prefixIcon: Icon(icon, color: _primaryRoleColor,size: 17,),
            prefixIconConstraints: const BoxConstraints(
              minWidth: 32, // default is ~48, reduce this
              minHeight: 32,
            ),
            filled: true,
            fillColor: _primaryRoleColor.withOpacity(0.03),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: _primaryRoleColor.withOpacity(0.12)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: _primaryRoleColor, width: 1.2),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            contentPadding: const EdgeInsets.symmetric( horizontal:4,vertical: 10),
          ),
        ),
      ],
    );
  }
  void _openAddMineBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        String? errorMessage; // local error text

        return StatefulBuilder(
          builder: (context, setModalState) {
            return FractionallySizedBox(
              heightFactor: 0.8, // 80% of screen
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 20,
                      offset: const Offset(0, -6),
                    ),
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.only(
                    left: 20,
                    right: 20,
                    top: 12,
                    bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                  ),
                  child: BlocConsumer<PostMinesEntryBloc, PostMinesEntryState>(
                    listener: (context, state) {
                      if (state is PostMinesEntrySuccess) {
                        Navigator.of(context).pop();

                        // Call GetMines API to refresh the list
                        if (kDebugMode) {
                          print('✅ Mine added successfully, refreshing mine list...');
                        }
                        context.read<GetMinesOptionBloc>().add(FetchGetMinesOption(showLoader: true ));

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Mine added successfully')),
                        );
                      } else if (state is PostMinesEntryError) {
                        if (kDebugMode) {
                          print('❌ Error adding mine: ${state.message}');
                        }
                        setModalState(() {
                          errorMessage =
                              state.message ?? 'Failed to add mine. Please try again.';
                        });
                      }
                    },
                    builder: (context, state) {
                      final isLoading = state is PostMinesEntryLoading;

                      return Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          // drag handle
                          Container(
                            width: 40,
                            height: 4,
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade400,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),

                          // header
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                            decoration: BoxDecoration(
                              color: _primaryRoleLight,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  height: 32,
                                  width: 32,
                                  decoration: BoxDecoration(
                                    color: _primaryRoleColor.withOpacity(0.15),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.landscape_outlined,
                                    size: 18,
                                    color: _primaryRoleColor,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                const Expanded(
                                  child: Text(
                                    'Add New Mine',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close),
                                  color: Colors.grey.shade700,
                                  onPressed: () => Navigator.of(context).pop(),
                                ),
                              ],
                            ),
                          ),

                          // inline error text (if any)
                          if (errorMessage != null && errorMessage!.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.06),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.red.withOpacity(0.4)),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.error_outline,
                                      size: 18, color: Colors.red),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      errorMessage!,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.red,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],

                          const SizedBox(height: 10),

                          // form in scroll
                          Expanded(
                            child: SingleChildScrollView(
                              child: Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade50,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: _primaryRoleColor.withOpacity(0.12),
                                  ),
                                ),
                                child: Form(
                                  key: _mineFormKey,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _buildLabeledField(
                                        label: 'Mine Name *',
                                        icon: Icons.terrain_outlined,
                                        controller: _mineNameController,
                                        validator: (v) =>
                                        (v == null || v.trim().isEmpty)
                                            ? 'Name is required'
                                            : null,
                                      ),
                                      const SizedBox(height: 10),

                                      _buildLabeledField(
                                        label: 'Location *',
                                        icon: Icons.location_on_outlined,
                                        controller: _mineLocationController,
                                        validator: (v) =>
                                        (v == null || v.trim().isEmpty)
                                            ? 'Location is required'
                                            : null,
                                      ),
                                      const SizedBox(height: 10),

                                      _buildLabeledField(
                                        label: 'Owner Name',
                                        icon: Icons.person_outline,
                                        controller: _ownerNameController,
                                      ),
                                      const SizedBox(height: 10),

                                      Row(
                                        children: [
                                          Expanded(
                                            child: _buildLabeledField(
                                              label: 'Phone',
                                              icon: Icons.phone_outlined,
                                              controller: _contactPhoneController,
                                              keyboardType: TextInputType.phone,
                                              maxLength: 10,
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: _buildLabeledField(
                                              label: 'Email',
                                              icon: Icons.email_outlined,
                                              controller: _contactEmailController,
                                              keyboardType:
                                              TextInputType.emailAddress,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 10),

                                      _buildLabeledField(
                                        label: 'Website',
                                        icon: Icons.public_outlined,
                                        controller: _websiteUrlController,
                                      ),
                                      const SizedBox(height: 10),

                                      Row(
                                        children: [
                                          Expanded(
                                            child: _buildLabeledField(
                                              label: 'Instagram',
                                              icon: Icons.camera_alt_outlined,
                                              controller: _instagramUrlController,
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: _buildLabeledField(
                                              label: 'YouTube',
                                              icon: Icons.play_circle_outline,
                                              controller: _youtubeUrlController,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 10),

                                      _buildLabeledField(
                                        label: 'Pinterest',
                                        icon: Icons.push_pin_outlined,
                                        controller: _pinterestUrlController,
                                      ),
                                      const SizedBox(height: 8),

                                      Container(
                                        margin: const EdgeInsets.only(top: 6),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(
                                            color: _primaryRoleColor.withOpacity(0.12),
                                          ),
                                        ),
                                        child: Column(
                                          children: [
                                            SwitchListTile(
                                              contentPadding: EdgeInsets.zero,
                                              title: const Text('Blocks Available'),
                                              activeColor: _primaryRoleColor,
                                              value: _blocksAvailable,
                                              onChanged: (val) {
                                                setModalState(() {
                                                  _blocksAvailable = val;
                                                });
                                              },
                                            ),
                                            const Divider(height: 0),
                                            SwitchListTile(
                                              contentPadding: EdgeInsets.zero,
                                              title: const Text('Active'),
                                              activeColor: _primaryRoleColor,
                                              value: _mineIsActive,
                                              onChanged: (val) {
                                                setModalState(() {
                                                  _mineIsActive = val;
                                                });
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 12),

                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: _primaryRoleColor,
                                    side: BorderSide(
                                        color: _primaryRoleColor.withOpacity(0.4)),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onPressed:
                                  isLoading ? null : () => Navigator.of(context).pop(),
                                  child: const Text('Cancel'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _primaryRoleColor,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 2,
                                  ),
                                  onPressed: isLoading
                                      ? null
                                      : () {
                                    if (_mineFormKey.currentState!.validate()) {
                                      setModalState(() {
                                        errorMessage = null; // clear old error
                                      });
                                      final req = PostMinesEntryRequestBody(
                                        name: _mineNameController.text.trim(),
                                        location:
                                        _mineLocationController.text.trim(),
                                        ownerName:
                                        _ownerNameController.text.trim(),
                                        contactPhone:
                                        _contactPhoneController.text.trim(),
                                        contactEmail:
                                        _contactEmailController.text.trim(),
                                        blocksAvailable: _blocksAvailable,
                                        websiteUrl:
                                        _websiteUrlController.text.trim(),
                                        instagramUrl:
                                        _instagramUrlController.text.trim(),
                                        youtubeUrl:
                                        _youtubeUrlController.text.trim(),
                                        pinterestUrl:
                                        _pinterestUrlController.text.trim(),
                                        isActive: _mineIsActive,
                                      );
                                      context
                                          .read<PostMinesEntryBloc>()
                                          .add(SubmitPostMinesEntry(
                                        requestBody: req,
                                        showLoader: true,
                                      ));
                                    }
                                  },
                                  child: isLoading
                                      ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                      : const Text('Save Mine'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }


  Widget _buildImageUploadSection() {
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
          Row(
            children: [
              Icon(Icons.image, color:SessionManager.getUserRole().toString().toLowerCase() =="superadmin" ?AppColors.superAdminPrimary: AppColors.primaryDeepBlue),
              const SizedBox(width: 8),
              const Text(
                'Product Images',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color:SessionManager.getUserRole().toString().toLowerCase() =="superadmin" ?AppColors.superAdminPrimary.withAlpha(30): AppColors.primaryDeepBlue.withAlpha(30),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_images.length}/$_maxImages',
                  style: TextStyle(
                    color: SessionManager.getUserRole().toString().toLowerCase() =="superadmin" ?AppColors.superAdminPrimary: AppColors.primaryDeepBlue,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Add up to 7 high-quality images',
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _images.length + 1,
              itemBuilder: (context, index) {
                if (index == _images.length) {
                  // Add button
                  return _buildAddImageButton();
                }
                return _buildImageThumbnail(_images[index], index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddImageButton() {
    return GestureDetector(
      onTap: _images.length < _maxImages ? _showImageSourceDialog : null,
      child: Container(
        width: 120,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color:SessionManager.getUserRole().toString().toLowerCase() =="superadmin" ?AppColors.superAdminPrimary.withAlpha(20): AppColors.primaryDeepBlue.withAlpha(20),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:SessionManager.getUserRole().toString().toLowerCase() =="superadmin" ?AppColors.superAdminPrimary.withAlpha(20): AppColors.primaryDeepBlue.withAlpha(20) ,
            width: 2,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_photo_alternate,
              size: 40,
              color: _images.length < _maxImages
                  ?SessionManager.getUserRole().toString().toLowerCase() =="superadmin" ?AppColors.superAdminPrimary: AppColors.primaryDeepBlue
                  : Colors.grey,
            ),
            const SizedBox(height: 8),
            Text(
              'Add Image',
              style: TextStyle(
                color: _images.length < _maxImages
                    ? SessionManager.getUserRole().toString().toLowerCase() =="superadmin" ?AppColors.superAdminPrimary: AppColors.primaryDeepBlue
                    : Colors.grey,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageThumbnail(File image, int index) {
    return Container(
      width: 120,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(
              image,
              width: 120,
              height: 120,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: () => _removeImage(index),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 16),
              ),
            ),
          ),
          if (index == 0)
            Positioned(
              bottom: 4,
              left: 4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color:SessionManager.getUserRole().toString().toLowerCase() =="superadmin" ?AppColors.superAdminPrimary: AppColors.primaryDeepBlue,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Primary',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Section 2: Additional Details (Images and Filters)
  Widget _buildSection2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Progress Indicator
        _buildProgressIndicator(2),
        const SizedBox(height: 24),

        // Back Button
        TextButton.icon(
          onPressed: () {
            setState(() {
              _showSection1 = true;
              _showSection2 = false;
            });
          },
          icon: const Icon(Icons.arrow_back),
          label: const Text('Back to Basic Information'),
          style: TextButton.styleFrom(
            foregroundColor: SessionManager.getUserRole().toString().toLowerCase() == "superadmin"
                ? AppColors.superAdminPrimary
                : AppColors.primaryDeepBlue,
          ),
        ),
        const SizedBox(height: 16),

        _buildImageUploadSection(),
        const SizedBox(height: 20),

        // Utility / Application with Dropdown
        BlocBuilder<GetUtilitiesBloc, GetUtilitiesState>(
          builder: (context, state) {
            if (state is GetUtilitiesLoaded) {
              if (state.response.data != null && state.response.data!.isNotEmpty) {
                utilityOptions = state.response.data!
                    .where((item) => item.id != null && item.name != null && item.name!.isNotEmpty)
                    .map((item) => DropdownOption(
                          id: item.id!,
                          name: item.name!,
                          code: item.code,
                        ))
                    .toList();
              }
              return CustomDropdownSection(
                title: 'Utility / Application',
                options: utilityOptions,
                selectedId: selectedUtilityId,
                onChanged: (id, name) {
                  setState(() {
                    selectedUtilityId = id;
                  });
                },
                icon: Icons.apps,
              );
            } else if (state is GetUtilitiesLoading && state.showLoader) {
              return _buildLoadingContainer();
            } else if (state is GetUtilitiesError) {
              return _buildErrorContainer('utilities', state.message);
            }
            return CustomDropdownSection(
              title: 'Utility / Application',
              options: utilityOptions,
              selectedId: selectedUtilityId,
              onChanged: (id, name) {
                setState(() {
                  selectedUtilityId = id;
                });
              },
              icon: Icons.apps,
            );
          },
        ),
        const SizedBox(height: 16),

        // Colour with BlocBuilder
        BlocBuilder<GetColorsBloc, GetColorsState>(
          builder: (context, state) {
            if (state is GetColorsLoaded) {
              // Populate colorIdMap
              if (state.response.data != null) {
                colorIdMap.clear();
                for (var item in state.response.data!) {
                  if (item.name != null && item.id != null) {
                    colorIdMap[item.name!] = item.id!;
                  }
                }
              }
              return _buildColorPickerSectionWithApi(
                title: 'Colour',
                colorData: state.response.data ?? [],
                selectedOptions: _selectedColours,
              );
            } else if (state is GetColorsLoading && state.showLoader) {
              return _buildLoadingContainer();
            } else if (state is GetColorsError) {
              return _buildErrorContainer('colors', state.message);
            }
            return _buildColorPickerSectionWithApi(
              title: 'Colour',
              colorData: [],
              selectedOptions: _selectedColours,
            );
          },
        ),
        const SizedBox(height: 16),

        // Natural Colour with BlocBuilder
        BlocBuilder<GetNaturalColorsBloc, GetNaturalColorsState>(
          builder: (context, state) {
            if (state is GetNaturalColorsLoaded) {
              // Populate naturalColorIdMap
              if (state.response.data != null) {
                naturalColorIdMap.clear();
                for (var item in state.response.data!) {
                  if (item.name != null && item.id != null) {
                    naturalColorIdMap[item.name!] = item.id!;
                  }
                }
              }
              return _buildColorPickerSectionWithApi(
                title: 'Natural Colour',
                colorData: state.response.data ?? [],
                selectedOptions: _selectedNaturalColours,
              );
            } else if (state is GetNaturalColorsLoading && state.showLoader) {
              return _buildLoadingContainer();
            } else if (state is GetNaturalColorsError) {
              return _buildErrorContainer('natural colors', state.message);
            }
            return _buildColorPickerSectionWithApi(
              title: 'Natural Colour',
              colorData: [],
              selectedOptions: _selectedNaturalColours,
            );
          },
        ),
        const SizedBox(height: 16),
        // Origin with BlocBuilder
        BlocBuilder<GetOriginsBloc, GetOriginsState>(
          builder: (context, state) {
            if (state is GetOriginsLoaded) {
              if (state.response.data != null && state.response.data!.isNotEmpty) {
                origins = state.response.data!
                    .where((item) => item.name != null && item.name!.isNotEmpty)
                    .map((item) => item.name!)
                    .toList();

                // Populate originIdMap
                originIdMap.clear();
                for (var item in state.response.data!) {
                  if (item.name != null && item.id != null) {
                    originIdMap[item.name!] = item.id!;
                  }
                }
              }
              return _buildFilterSection('Origin', origins, _selectedOrigins);
            } else if (state is GetOriginsLoading && state.showLoader) {
              return _buildLoadingContainer();
            } else if (state is GetOriginsError) {
              return _buildErrorContainer('origins', state.message);
            }
            return _buildFilterSection('Origin', origins, _selectedOrigins);
          },
        ),
        const SizedBox(height: 16),
        // State / Country with BlocBuilder and Type Selection
        BlocBuilder<GetStateCountriesBloc, GetStateCountriesState>(
          builder: (context, state) {
            if (state is GetStateCountriesLoaded) {
              if (state.response.data != null && state.response.data!.isNotEmpty) {
                states = state.response.data!
                    .where((item) => item.name != null && item.name!.isNotEmpty)
                    .map((item) => item.name!)
                    .toList();

                // Populate stateCountryIdMap
                stateCountryIdMap.clear();
                for (var item in state.response.data!) {
                  if (item.name != null && item.id != null) {
                    stateCountryIdMap[item.name!] = item.id!;
                  }
                }
              }
              return _buildStateCountryFilterSection(states, _selectedStates);
            } else if (state is GetStateCountriesLoading && state.showLoader) {
              return _buildLoadingContainer();
            } else if (state is GetStateCountriesError) {
              return _buildErrorContainer('states/countries', state.message);
            }
            return _buildStateCountryFilterSection(states, _selectedStates);
          },
        ),
        const SizedBox(height: 16),
        // Nature of Material Processing with BlocBuilder
        BlocBuilder<GetProcessingNatureBloc, GetProcessingNatureState>(
          builder: (context, state) {
            if (state is GetProcessingNatureLoaded) {
              if (state.response.data != null && state.response.data!.isNotEmpty) {
                processing = state.response.data!
                    .where((item) => item.name != null && item.name!.isNotEmpty)
                    .map((item) => item.name!)
                    .toList();

                // Populate processingNatureIdMap
                processingNatureIdMap.clear();
                for (var item in state.response.data!) {
                  if (item.name != null && item.id != null) {
                    processingNatureIdMap[item.name!] = item.id!;
                  }
                }
              }
              return _buildFilterSection('Nature of Material Processing', processing, _selectedProcessing);
            } else if (state is GetProcessingNatureLoading && state.showLoader) {
              return _buildLoadingContainer();
            } else if (state is GetProcessingNatureError) {
              return _buildErrorContainer('processing nature', state.message);
            }
            return _buildFilterSection('Nature of Material Processing', processing, _selectedProcessing);
          },
        ),
        const SizedBox(height: 16),
        // Material Naturality with BlocBuilder
        BlocBuilder<GetNaturalMaterialBloc, GetNaturalMaterialState>(
          builder: (context, state) {
            if (state is GetNaturalMaterialLoaded) {
              if (state.response.data != null && state.response.data!.isNotEmpty) {
                naturality = state.response.data!
                    .where((item) => item.name != null && item.name!.isNotEmpty)
                    .map((item) => item.name!)
                    .toList();

                // Populate materialNaturalityIdMap
                materialNaturalityIdMap.clear();
                for (var item in state.response.data!) {
                  if (item.name != null && item.id != null) {
                    materialNaturalityIdMap[item.name!] = item.id!;
                  }
                }
              }
              return _buildFilterSection('Material Naturality', naturality, _selectedNaturality);
            } else if (state is GetNaturalMaterialLoading && state.showLoader) {
              return _buildLoadingContainer();
            } else if (state is GetNaturalMaterialError) {
              return _buildErrorContainer('material naturality', state.message);
            }
            return _buildFilterSection('Material Naturality', naturality, _selectedNaturality);
          },
        ),
        const SizedBox(height: 16),
        // Finish with BlocBuilder
        BlocBuilder<GetFinishesBloc, GetFinishesState>(
          builder: (context, state) {
            if (state is GetFinishesLoaded) {
              if (state.response.data != null && state.response.data!.isNotEmpty) {
                finishes = state.response.data!
                    .where((item) => item.name != null && item.name!.isNotEmpty)
                    .map((item) => item.name!)
                    .toList();

                // Populate finishIdMap
                finishIdMap.clear();
                for (var item in state.response.data!) {
                  if (item.name != null && item.id != null) {
                    finishIdMap[item.name!] = item.id!;
                  }
                }
              }
              return _buildFilterSection('Finish', finishes, _selectedFinishes);
            } else if (state is GetFinishesLoading && state.showLoader) {
              return _buildLoadingContainer();
            } else if (state is GetFinishesError) {
              return _buildErrorContainer('finishes', state.message);
            }
            return _buildFilterSection('Finish', finishes, _selectedFinishes);
          },
        ),
        const SizedBox(height: 16),
        // Texture / Pattern with BlocBuilder
        BlocBuilder<GetTexturesBloc, GetTexturesState>(
          builder: (context, state) {
            if (state is GetTexturesLoaded) {
              if (state.response.data != null && state.response.data!.isNotEmpty) {
                textures = state.response.data!
                    .where((item) => item.name != null && item.name!.isNotEmpty)
                    .map((item) => item.name!)
                    .toList();

                // Populate textureIdMap
                textureIdMap.clear();
                for (var item in state.response.data!) {
                  if (item.name != null && item.id != null) {
                    textureIdMap[item.name!] = item.id!;
                  }
                }
              }
              return _buildFilterSection('Texture / Pattern', textures, _selectedTextures);
            } else if (state is GetTexturesLoading && state.showLoader) {
              return _buildLoadingContainer();
            } else if (state is GetTexturesError) {
              return _buildErrorContainer('textures', state.message);
            }
            return _buildFilterSection('Texture / Pattern', textures, _selectedTextures);
          },
        ),
        const SizedBox(height: 16),
        if (selectedProductTypeId != null)
          // Handicraft Type with BlocBuilder
          BlocBuilder<GetHandicraftsBloc, GetHandicraftsState>(
            builder: (context, state) {
              if (state is GetHandicraftsLoaded) {
                if (state.response.data != null && state.response.data!.isNotEmpty) {
                  handicrafts = state.response.data!
                      .where((item) => item.name != null && item.name!.isNotEmpty)
                      .map((item) => item.name!)
                      .toList();

                  // Populate handicraftIdMap
                  handicraftIdMap.clear();
                  for (var item in state.response.data!) {
                    if (item.name != null && item.id != null) {
                      handicraftIdMap[item.name!] = item.id!;
                    }
                  }
                }
                return _buildFilterSection('Handicraft Type', handicrafts, _selectedHandicrafts);
              } else if (state is GetHandicraftsLoading && state.showLoader) {
                return _buildLoadingContainer();
              } else if (state is GetHandicraftsError) {
                return _buildErrorContainer('handicrafts', state.message);
              }
              return _buildFilterSection('Handicraft Type', handicrafts, _selectedHandicrafts);
            },
          ),
        const SizedBox(height: 16),
        // Synonyms section
        Container(
          padding: const EdgeInsets.all(10),
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
              Row(
                children: [
                  Icon(
                    Icons.translate_outlined,
                    size: 20,
                    color: SessionManager.getUserRole().toString().toLowerCase() == "superadmin"
                        ? AppColors.superAdminPrimary
                        : AppColors.primaryDeepBlue,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Synonyms',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Add alternative names your buyers might search for.',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 12),

              // Input + add button
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _synonymController,
                      maxLength: 40,
                      decoration: InputDecoration(
                        counterText: '',
                        hintText: 'Type a synonym and tap +',
                        filled: true,
                        fillColor: Colors.white,
                        prefixIcon: Icon(
                          Icons.edit_outlined,
                          size: 18,
                          color: SessionManager.getUserRole().toString().toLowerCase() == "superadmin"
                              ? AppColors.superAdminPrimary
                              : AppColors.primaryDeepBlue,
                        ),
                        prefixIconConstraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: (SessionManager.getUserRole().toString().toLowerCase() == "superadmin"
                                ? AppColors.superAdminPrimary
                                : AppColors.primaryDeepBlue)
                                .withOpacity(0.12),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: SessionManager.getUserRole().toString().toLowerCase() == "superadmin"
                                ? AppColors.superAdminPrimary
                                : AppColors.primaryDeepBlue,
                            width: 1.2,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    height: 44,
                    width: 44,
                    decoration: BoxDecoration(
                      color: SessionManager.getUserRole().toString().toLowerCase() == "superadmin"
                          ? AppColors.superAdminPrimary
                          : AppColors.primaryDeepBlue,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.add, color: Colors.white, size: 22),
                      onPressed: () {
                        final text = _synonymController.text.trim();
                        if (text.isNotEmpty && !_synonyms.contains(text)) {
                          setState(() {
                            _synonyms.add(text);
                            _synonymController.clear();
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // Show added synonyms as chips
              if (_synonyms.isNotEmpty) ...[
                Text(
                  'Added synonyms:',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: _synonyms.map((s) {
                    return Chip(
                      label: Text(s),
                      backgroundColor: (SessionManager.getUserRole().toString().toLowerCase() == "superadmin"
                          ? AppColors.superAdminPrimary
                          : AppColors.primaryDeepBlue)
                          .withOpacity(0.06),
                      labelStyle: TextStyle(
                        fontSize: 12,
                        color: SessionManager.getUserRole().toString().toLowerCase() == "superadmin"
                            ? AppColors.superAdminPrimary
                            : AppColors.primaryDeepBlue,
                      ),
                      deleteIcon: const Icon(Icons.close, size: 16),
                      onDeleted: () {
                        setState(() {
                          _synonyms.remove(s);
                        });
                      },
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                          color: (SessionManager.getUserRole().toString().toLowerCase() == "superadmin"
                              ? AppColors.superAdminPrimary
                              : AppColors.primaryDeepBlue)
                              .withOpacity(0.25),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),


        const SizedBox(height: 24),

        // Final Submit Button
        _buildSubmitButton(),
        const SizedBox(height: 20),
      ],
    );
  }

  // Progress Indicator
  Widget _buildProgressIndicator(int currentStep) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildStepIndicator(1, 'Basic Info', currentStep >= 1),
          Expanded(
            child: Container(
              height: 2,
              color: currentStep >= 2
                  ? (SessionManager.getUserRole().toString().toLowerCase() == "superadmin"
                      ? AppColors.superAdminPrimary
                      : AppColors.primaryDeepBlue)
                  : Colors.grey.shade300,
            ),
          ),
          _buildStepIndicator(2, 'Details', currentStep >= 2),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(int step, String label, bool isActive) {
    final color = SessionManager.getUserRole().toString().toLowerCase() == "superadmin"
        ? AppColors.superAdminPrimary
        : AppColors.primaryDeepBlue;

    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? color : Colors.grey.shade300,
          ),
          child: Center(
            child: isActive
                ? const Icon(Icons.check, color: Colors.white, size: 20)
                : Text(
                    '$step',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            color: isActive ? color : Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  // Submit Section 1 - Call ProductEntryBloc API
  void _submitSection1() {
    // Validate
    if (_productNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter product name'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (selectedProductTypeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select product type'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_pricePerSqFtController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter price per sq ft'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Validate price is a number
    final price = int.tryParse(_pricePerSqFtController.text);
    if (price == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid price'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Create request body
    final requestBody = ProductEntryRequestBody(
    productCode: _productCodeController.text.isEmpty
        ? '${_productNameController.text.trim().replaceAll(RegExp(r'\s+'), '_')}_${(DateTime.now().millisecondsSinceEpoch % 9000 + 1000)}'
        : _productCodeController.text,
      name: _productNameController.text,
      description: _descriptionController.text.isEmpty
          ? null
          : _descriptionController.text,
      productTypeId: selectedProductTypeId,
      pricePerSqft: price,
      isActive: true,
      priceRangeId:selectedPriceRangeId ,
      priceSqftArchitectGradeA: int.parse(_priceArchitectAGradeController.text),
      priceSqftArchitectGradeB: int.parse(_priceArchitectBGradeController.text),
      priceSqftArchitectGradeC: int.parse(_priceArchitectCGradeController.text),
      priceSqftTraderGradeA: int.parse(_priceTraderAGradeController.text),
      priceSqftTraderGradeB: int.parse(_priceTraderBGradeController.text),
      priceSqftTraderGradeC: int.parse(_priceTraderCGradeController.text),
      mineId:selectedMineId ,
      marketingOneLiner: _marketingOneLinerController.text.toString(),

      sortOrder: 0,
    );

    // Call ProductEntryBloc API
    context.read<ProductEntryBloc>().add(FetchProductEntry(
      requestBody: requestBody,
      showLoader: true,
    ));

    // Listen to ProductEntryBloc state
    _listenToProductEntryState();
  }

  // Listener for ProductEntryBloc state changes
  void _listenToProductEntryState() {
    final subscription = context.read<ProductEntryBloc>().stream.listen((state) {
      if (state is ProductEntryLoading && state.showLoader) {
        // Show loading dialog
        showCustomProgressDialog(context, title: 'Creating product...');
      } else if (state is ProductEntrySuccess) {
        // Dismiss loading dialog
        dismissCustomProgressDialog(context);
          if(state.response.statusCode==200 ||state.response.statusCode==201){
            setState(() {
              _savedProductId = state.response.data?.id ?? 'UNKNOWN';
              _showSection1 = false;
              _showSection2 = true;
            });

            // Show success message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('✅ ${state.response.message ?? "Product created successfully! Now add additional details."}'),
                backgroundColor: AppColors.success,
                duration: const Duration(seconds: 3),
              ),
            );
          }
          else{
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('✅ ${state.response.message ?? "Product creation Failed!."}'),
                backgroundColor: AppColors.error,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        // Save product ID from response

      } else if (state is ProductEntryError) {
        // Dismiss loading dialog
        dismissCustomProgressDialog(context);

        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ ${state.message}'),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    });

    // Auto-cancel subscription after 15 seconds
    Future.delayed(const Duration(seconds: 15), () => subscription.cancel());
  }



  Widget _buildFilterSection(
    String title,
    List<String> options,
    List<String> selectedOptions,
  ) {
   final isAddingToThisSection = _addingSectionTitle == title;

    return Container(
      padding: const EdgeInsets.all(10),
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
          Row(
            children: [
              Icon(Icons.tune, color: SessionManager.getUserRole().toString().toLowerCase() =="superadmin" ?AppColors.superAdminPrimary: AppColors.primaryDeepBlue, size: 20),
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
              if (selectedOptions.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color:SessionManager.getUserRole().toString().toLowerCase() =="superadmin" ?AppColors.superAdminPrimary: AppColors.primaryDeepBlue ,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${selectedOptions.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
             // Add button
             InkWell(
               onTap: () {
                 setState(() {
                   if (isAddingToThisSection) {
                     _addingSectionTitle = null;
                     _newOptionController.clear();
                   } else {
                     _addingSectionTitle = title;
                     _newOptionController.clear();
                   }
                 });
               },
               borderRadius: BorderRadius.circular(8),
               child: Container(
                 padding: const EdgeInsets.all(6),
                 decoration: BoxDecoration(
                   color: isAddingToThisSection
                       ? AppColors.error.withAlpha(20)
                       : SessionManager.getUserRole().toString().toLowerCase() =="superadmin" ?AppColors.superAdminPrimary.withAlpha(20): AppColors.primaryDeepBlue.withAlpha(20),
                   borderRadius: BorderRadius.circular(8),
                 ),
                 child: Icon(
                   isAddingToThisSection ? Icons.close : Icons.add,
                   color: isAddingToThisSection
                       ? AppColors.error
                       : SessionManager.getUserRole().toString().toLowerCase() =="superadmin" ?AppColors.superAdminPrimary: AppColors.primaryDeepBlue,
                   size: 20,
                 ),
               ),
             ),
            ],
          ),
          const SizedBox(height: 10),

         // Show add option text field if this section is in add mode
         if (isAddingToThisSection) ...[
           Row(
             children: [
               Expanded(
                 child: Container(
                   height: 40,
                   decoration: BoxDecoration(

                     borderRadius: BorderRadius.circular(20),
                   ),
                   child: TextField(
                     controller: _newOptionController,
                     autofocus: true,
                     decoration: InputDecoration(
                       hintText: 'Enter new option...',
                       hintStyle: TextStyle(
                         color: Colors.grey.shade400,
                         fontSize: 14,
                       ),
                       border: InputBorder.none,
                       contentPadding: const EdgeInsets.symmetric(
                         horizontal: 16,
                         vertical: 10,
                       ),
                     ),
                     style: const TextStyle(fontSize: 14),
                     onSubmitted: (value) => _saveNewOption(title, options),
                   ),
                 ),
               ),
               const SizedBox(width: 8),
               // Save button
               InkWell(
                 onTap: () => _saveNewOption(title, options),
                 borderRadius: BorderRadius.circular(20),
                 child: Container(
                   height: 40,
                   padding: const EdgeInsets.symmetric(horizontal: 16),
                   decoration: BoxDecoration(
                     gradient: SessionManager.getUserRole().toString().toLowerCase() =="superadmin" ?AppColors.superAdminGradient: AppColors.primaryGradient,
                     borderRadius: BorderRadius.circular(20),
                     boxShadow: [
                       BoxShadow(
                         color:SessionManager.getUserRole().toString().toLowerCase() =="superadmin" ?AppColors.superAdminPrimary.withAlpha(50): AppColors.primaryDeepBlue.withAlpha(50),
                         blurRadius: 8,
                         offset: const Offset(0, 2),
                       ),
                     ],
                   ),
                   child: const Row(
                     mainAxisSize: MainAxisSize.min,
                     children: [
                       Icon(Icons.check, color: Colors.white, size: 18),
                       SizedBox(width: 4),
                       Text(
                         'Save',
                         style: TextStyle(
                           color: Colors.white,
                           fontSize: 14,
                           fontWeight: FontWeight.w600,
                         ),
                       ),
                     ],
                   ),
                 ),
               ),
             ],
           ),
           const SizedBox(height: 12),
         ],

          Wrap(
            spacing: 5,
            runSpacing: 2,
            children: options.map((option) {
              final isSelected = selectedOptions.contains(option);
              return FilterChip(
                labelPadding: EdgeInsets.symmetric(horizontal: 2,),
                label: Text(option),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      selectedOptions.add(option);
                    } else {
                      selectedOptions.remove(option);
                    }
                  });
                },
                selectedColor: AppColors.success.withAlpha(50),
                checkmarkColor: AppColors.success,
                labelStyle: TextStyle(
                  color: isSelected ? AppColors.success : Colors.black87,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
                side: BorderSide(
                  color: isSelected
                      ? AppColors.success
                      : Colors.grey.withAlpha(100),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

 void _saveNewOption(String sectionTitle, List<String> options) {
   final newOption = _newOptionController.text.trim();

   if (newOption.isEmpty) {
     ScaffoldMessenger.of(context).showSnackBar(
       const SnackBar(
         content: Text('Please enter an option name'),
         backgroundColor: AppColors.error,
       ),
     );
     return;
   }

   if (options.contains(newOption)) {
     ScaffoldMessenger.of(context).showSnackBar(
       SnackBar(
         content: Text('Option "$newOption" already exists'),
         backgroundColor: AppColors.warning,
       ),
     );
     return;
   }

   // Create request body
   final requestBody = PostCatalogueCommonRequestBody(
     name: newOption,
     code: newOption.toUpperCase().replaceAll(' ', '_'),
     sortOrder: 0,
     isActive: true,
   );

   // Determine which POST API to call based on section title
   switch (sectionTitle) {
     case 'Utility / Application':
       // TODO: Add postUtilities API to ApiIntegration
       ScaffoldMessenger.of(context).showSnackBar(
         const SnackBar(
           content: Text('Utility POST API not implemented yet. Contact admin.'),
           backgroundColor: AppColors.warning,
         ),
       );
       break;

     case 'Origin':
       context.read<PostOriginsBloc>().add(SubmitPostOrigins(
         requestBody: requestBody,
         showLoader: true,
       ));
       _listenToPostOriginsState();
       break;

     case 'State / Country':
       context.read<PostStateCountriesBloc>().add(SubmitPostStateCountries(
         requestBody: requestBody,
         showLoader: true,
       ));
       _listenToPostStateCountriesState();
       break;

     case 'Nature of Material Processing':
       context.read<PostProcessingNaturesBloc>().add(SubmitPostProcessingNatures(
         requestBody: requestBody,
         showLoader: true,
       ));
       _listenToPostProcessingNaturesState();
       break;

     case 'Material Naturality':
       context.read<PostNaturalMaterialsBloc>().add(SubmitPostNaturalMaterials(
         requestBody: requestBody,
         showLoader: true,
       ));
       _listenToPostNaturalMaterialsState();
       break;

     case 'Finish':
       context.read<PostFinishesBloc>().add(SubmitPostFinishes(
         requestBody: requestBody,
         showLoader: true,
       ));
       _listenToPostFinishesState();
       break;

     case 'Texture / Pattern':
       context.read<PostTexturesBloc>().add(SubmitPostTextures(
         requestBody: requestBody,
         showLoader: true,
       ));
       _listenToPostTexturesState();
       break;

     case 'Handicraft Type':
       context.read<PostHandicraftsTypesBloc>().add(SubmitPostHandicraftsTypes(
         requestBody: requestBody,
         showLoader: true,
       ));
       _listenToPostHandicraftsTypesState();
       break;

     case 'Product Type':
       // TODO: Add postProductType API if needed
       ScaffoldMessenger.of(context).showSnackBar(
         const SnackBar(
           content: Text('Product Type POST API not implemented yet. Contact admin.'),
           backgroundColor: AppColors.warning,
         ),
       );
       break;

     default:
       ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(
           content: Text('POST API not available for: $sectionTitle'),
           backgroundColor: AppColors.error,
         ),
       );
   }
 }

 // Listener methods for each POST API
 void _listenToPostOriginsState() {
   final subscription = context.read<PostOriginsBloc>().stream.listen((state) {
     if (state is PostOriginsSuccess) {
       setState(() {
         _addingSectionTitle = null;
         _newOptionController.clear();
       });
       ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(
           content: Text('✅ ${state.response.message ?? "Origin added successfully"}'),
           backgroundColor: AppColors.success,
         ),
       );
       // Refresh the GET API
       context.read<GetOriginsBloc>().add(FetchGetOrigins());
     } else if (state is PostOriginsError) {
       ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(
           content: Text('❌ ${state.message}'),
           backgroundColor: AppColors.error,
         ),
       );
     }
   });
   Future.delayed(const Duration(seconds: 10), () => subscription.cancel());
 }

 void _listenToPostStateCountriesState() {
   final subscription = context.read<PostStateCountriesBloc>().stream.listen((state) {
     if (state is PostStateCountriesSuccess) {
       setState(() {
         _addingSectionTitle = null;
         _newOptionController.clear();
         _selectedStateCountryType = null; // Reset type selection
       });
       ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(
           content: Text('✅ ${state.response.message ?? "State/Country added successfully"}'),
           backgroundColor: AppColors.success,
         ),
       );
       context.read<GetStateCountriesBloc>().add(FetchGetStateCountries());
     } else if (state is PostStateCountriesError) {
       ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(
           content: Text('❌ ${state.message}'),
           backgroundColor: AppColors.error,
         ),
       );
     }
   });
   Future.delayed(const Duration(seconds: 10), () => subscription.cancel());
 }

 void _listenToPostProcessingNaturesState() {
   final subscription = context.read<PostProcessingNaturesBloc>().stream.listen((state) {
     if (state is PostProcessingNaturesSuccess) {
       setState(() {
         _addingSectionTitle = null;
         _newOptionController.clear();
       });
       ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(
           content: Text('✅ ${state.response.message ?? "Processing nature added successfully"}'),
           backgroundColor: AppColors.success,
         ),
       );
       context.read<GetProcessingNatureBloc>().add(FetchGetProcessingNature());
     } else if (state is PostProcessingNaturesError) {
       ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(
           content: Text('❌ ${state.message}'),
           backgroundColor: AppColors.error,
         ),
       );
     }
   });
   Future.delayed(const Duration(seconds: 10), () => subscription.cancel());
 }

 void _listenToPostNaturalMaterialsState() {
   final subscription = context.read<PostNaturalMaterialsBloc>().stream.listen((state) {
     if (state is PostNaturalMaterialsSuccess) {
       setState(() {
         _addingSectionTitle = null;
         _newOptionController.clear();
       });
       ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(
           content: Text('✅ ${state.response.message ?? "Material naturality added successfully"}'),
           backgroundColor: AppColors.success,
         ),
       );
       context.read<GetNaturalMaterialBloc>().add(FetchGetNaturalMaterial());
     } else if (state is PostNaturalMaterialsError) {
       ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(
           content: Text('❌ ${state.message}'),
           backgroundColor: AppColors.error,
         ),
       );
     }
   });
   Future.delayed(const Duration(seconds: 10), () => subscription.cancel());
 }

 void _listenToPostFinishesState() {
   final subscription = context.read<PostFinishesBloc>().stream.listen((state) {
     if (state is PostFinishesSuccess) {
       setState(() {
         _addingSectionTitle = null;
         _newOptionController.clear();
       });
       ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(
           content: Text('✅ ${state.response.message ?? "Finish added successfully"}'),
           backgroundColor: AppColors.success,
         ),
       );
       context.read<GetFinishesBloc>().add(FetchGetFinishes());
     } else if (state is PostFinishesError) {
       ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(
           content: Text('❌ ${state.message}'),
           backgroundColor: AppColors.error,
         ),
       );
     }
   });
   Future.delayed(const Duration(seconds: 10), () => subscription.cancel());
 }

 void _listenToPostTexturesState() {
   final subscription = context.read<PostTexturesBloc>().stream.listen((state) {
     if (state is PostTexturesSuccess) {
       setState(() {
         _addingSectionTitle = null;
         _newOptionController.clear();
       });
       ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(
           content: Text('✅ ${state.response.message ?? "Texture added successfully"}'),
           backgroundColor: AppColors.success,
         ),
       );
       context.read<GetTexturesBloc>().add(FetchGetTextures());
     } else if (state is PostTexturesError) {
       ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(
           content: Text('❌ ${state.message}'),
           backgroundColor: AppColors.error,
         ),
       );
     }
   });
   Future.delayed(const Duration(seconds: 10), () => subscription.cancel());
 }

 void _listenToPostHandicraftsTypesState() {
   final subscription = context.read<PostHandicraftsTypesBloc>().stream.listen((state) {
     if (state is PostHandicraftsTypesSuccess) {
       setState(() {
         _addingSectionTitle = null;
         _newOptionController.clear();
       });
       ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(
           content: Text('✅ ${state.response.message ?? "Handicraft type added successfully"}'),
           backgroundColor: AppColors.success,
         ),
       );
       context.read<GetHandicraftsBloc>().add(FetchGetHandicrafts());
     } else if (state is PostHandicraftsTypesError) {
       ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(
           content: Text('❌ ${state.message}'),
           backgroundColor: AppColors.error,
         ),
       );
     }
   });
   Future.delayed(const Duration(seconds: 10), () => subscription.cancel());
 }

 void _showCustomColorPicker(String sectionTitle) {
   _pickerColor = const Color(0xFF2196F3);
   _colorNameController.clear();

   showDialog(
     context: context,
     builder: (context) => StatefulBuilder(
       builder: (context, setDialogState) => AlertDialog(
         title: Text('Add Custom  $sectionTitle'),
         content: SingleChildScrollView(
           child: Column(
             mainAxisSize: MainAxisSize.min,
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [
               const Text(
                 'Pick a Color',
                 style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
               ),
               const SizedBox(height: 16),

               // Advanced Color Picker with Hue Slider & Saturation/Brightness Grid
               ColorPicker(
                 pickerColor: _pickerColor,
                 onColorChanged: (color) {
                   setDialogState(() {
                     _pickerColor = color;
                   });
                 },
                 labelTypes: const [],
                 pickerAreaHeightPercent: 0.7,
                 displayThumbColor: true,
                 paletteType: PaletteType.hsvWithHue,
                 enableAlpha: false,
                 hexInputBar: true,
                 colorPickerWidth: 300,
               ),


               const SizedBox(height: 12),

               // Selected Color Preview with Details
               Container(
                 padding: const EdgeInsets.all(12),
                 decoration: BoxDecoration(
                   color: Colors.grey.shade50,
                   borderRadius: BorderRadius.circular(12),
                   border: Border.all(color: Colors.grey.shade300),
                 ),
                 child: Row(
                   children: [
                     Container(
                       width: 60,
                       height: 60,
                       decoration: BoxDecoration(
                         color: _pickerColor,
                         borderRadius: BorderRadius.circular(8),
                         border: Border.all(color: Colors.grey.shade400, width: 2),
                         boxShadow: [
                           BoxShadow(
                             color: _pickerColor.withAlpha(100),
                             blurRadius: 8,
                             offset: const Offset(0, 2),
                           ),
                         ],
                       ),
                     ),
                     const SizedBox(width: 3),
                     Expanded(
                       child: Column(
                         crossAxisAlignment: CrossAxisAlignment.start,
                         children: [
                           const Text(
                             'Selected Color',
                             style: TextStyle(
                               fontSize: 12,
                               color: Colors.grey,
                               fontWeight: FontWeight.w500,
                             ),
                           ),
                           const SizedBox(height: 4),
                           Text(
                             '#${_pickerColor.toARGB32().toRadixString(16).substring(2).toUpperCase()}',
                             style: const TextStyle(
                               fontWeight: FontWeight.bold,
                               fontSize: 18,
                               letterSpacing: 1.2,
                             ),
                           ),
                           const SizedBox(height: 2),
                           Text(
                             'RGB(${(_pickerColor.r * 255).round()}, ${(_pickerColor.g * 255).round()}, ${(_pickerColor.b * 255).round()})',
                             style: TextStyle(
                               color: Colors.grey.shade600,
                               fontSize: 11,
                             ),
                           ),
                         ],
                       ),
                     ),
                   ],
                 ),
               ),

               const SizedBox(height: 10),

               // Color Name Input
               TextField(
                 controller: _colorNameController,
                 decoration: InputDecoration(
                   labelText: 'Color Name *',
                   hintText: 'e.g., Ocean Blue, Sunset Orange',
                   border: OutlineInputBorder(
                     borderRadius: BorderRadius.circular(12),
                   ),
                   prefixIcon: const Icon(Icons.label_outline),
                   filled: true,
                   fillColor: Colors.grey.shade50,
                 ),
               ),
             ],
           ),
         ),
         actions: [
           TextButton(
             onPressed: () => Navigator.pop(context),
             child: const Text('Cancel'),
           ),
           ElevatedButton.icon(
             onPressed: () => _saveCustomColor(sectionTitle),
             style: ElevatedButton.styleFrom(
               backgroundColor: SessionManager.getUserRole().toString().toLowerCase() =="superadmin"
                   ? AppColors.superAdminPrimary
                   : AppColors.primaryDeepBlue,
               padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
             ),
             icon: const Icon(Icons.check, size: 20),
             label: const Text('Save Color'),
           ),
         ],
       ),
     ),
   );
 }

 void _saveCustomColor(String sectionTitle) {
   final colorName = _colorNameController.text.trim();

   if (colorName.isEmpty) {
     ScaffoldMessenger.of(context).showSnackBar(
       const SnackBar(
         content: Text('Please enter a color name'),
         backgroundColor: AppColors.error,
       ),
     );
     return;
   }


   // Create request body with hex color code
   final colorHexCode = '0X${_pickerColor.toARGB32().toRadixString(16).substring(2).toUpperCase()}';
   final requestBody = PostCatalogueCommonRequestBody(
     name: colorName,
     code: colorHexCode,
     sortOrder: 0,
     isActive: true,
   );

   // Call appropriate BLoC based on section title
   if (sectionTitle == 'Colour') {
     context.read<PostColorsBloc>().add(SubmitPostColors(
       requestBody: requestBody,
       showLoader: true,
     ));
     _listenToPostColorsState(colorName, colorHexCode);
   } else if (sectionTitle == 'Natural Colour') {
     context.read<PostNaturalColorsBloc>().add(SubmitPostNaturalColors(
       requestBody: requestBody,
       showLoader: true,
     ));
     _listenToPostNaturalColorsState(colorName, colorHexCode);
   }

   // Close the dialog
   Navigator.pop(context);
 }

 // Listener for PostColorsBloc
 void _listenToPostColorsState(String colorName, String colorHexCode) {
   final subscription = context.read<PostColorsBloc>().stream.listen((state) {
     if (state is PostColorsLoading && state.showLoader) {
       showCustomProgressDialog(context, title: 'Saving color...');
     } else if (state is PostColorsSuccess) {
       dismissCustomProgressDialog(context);

       // Show success message
       ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(
           content: Row(
             children: [
               Container(
                 width: 24,
                 height: 24,
                 decoration: BoxDecoration(
                   color: _pickerColor,
                   shape: BoxShape.circle,
                   border: Border.all(color: Colors.white, width: 2),
                   boxShadow: [
                     BoxShadow(
                       color: _pickerColor.withAlpha(100),
                       blurRadius: 4,
                     ),
                   ],
                 ),
               ),
               const SizedBox(width: 12),
               Expanded(
                 child: Text('✅ ${state.response.message ?? "Color added successfully"} ($colorHexCode)'),
               ),
             ],
           ),
           backgroundColor: AppColors.success,
           duration: const Duration(seconds: 3),
         ),
       );

       // Refresh colors from API
       context.read<GetColorsBloc>().add(FetchGetColors());
     } else if (state is PostColorsError) {
       dismissCustomProgressDialog(context);
       ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(
           content: Text('❌ ${state.message}'),
           backgroundColor: AppColors.error,
         ),
       );
     }
   });
   Future.delayed(const Duration(seconds: 10), () => subscription.cancel());
 }

 // Listener for PostNaturalColorsBloc
 void _listenToPostNaturalColorsState(String colorName, String colorHexCode) {
   final subscription = context.read<PostNaturalColorsBloc>().stream.listen((state) {
     if (state is PostNaturalColorsLoading && state.showLoader) {
       showCustomProgressDialog(context, title: 'Saving natural color...');
     } else if (state is PostNaturalColorsSuccess) {
       dismissCustomProgressDialog(context);

       // Show success message
       ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(
           content: Row(
             children: [
               Container(
                 width: 24,
                 height: 24,
                 decoration: BoxDecoration(
                   color: _pickerColor,
                   shape: BoxShape.circle,
                   border: Border.all(color: Colors.white, width: 2),
                   boxShadow: [
                     BoxShadow(
                       color: _pickerColor.withAlpha(100),
                       blurRadius: 4,
                     ),
                   ],
                 ),
               ),
               const SizedBox(width: 12),
               Expanded(
                 child: Text('✅ ${state.response.message ?? "Natural color added successfully"} ($colorHexCode)'),
               ),
             ],
           ),
           backgroundColor: AppColors.success,
           duration: const Duration(seconds: 3),
         ),
       );

       // Refresh natural colors from API
       context.read<GetNaturalColorsBloc>().add(FetchGetNaturalColors());
     } else if (state is PostNaturalColorsError) {
       dismissCustomProgressDialog(context);
       ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(
           content: Text('❌ ${state.message}'),
           backgroundColor: AppColors.error,
         ),
       );
     }
   });
   Future.delayed(const Duration(seconds: 10), () => subscription.cancel());
 }

  Widget _buildSubmitButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _submitSection2,
            style: ElevatedButton.styleFrom(
              backgroundColor: SessionManager.getUserRole().toString().toLowerCase() == "superadmin"
                  ? AppColors.superAdminPrimary
                  : AppColors.primaryDeepBlue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle, size: 24),
                SizedBox(width: 8),
                Text(
                  'Complete Product Entry',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Submit Section 2 - Complete catalogue entry
  void _submitSection2() {
    // Validate images
    if (_images.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one product image'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Convert selected option names to IDs
    List<String> colorIds = _selectedColours.map((name) => colorIdMap[name] ?? '').where((id) => id.isNotEmpty).toList();
    List<String> naturalColorIds = _selectedNaturalColours.map((name) => naturalColorIdMap[name] ?? '').where((id) => id.isNotEmpty).toList();
    List<String> finishIds = _selectedFinishes.map((name) => finishIdMap[name] ?? '').where((id) => id.isNotEmpty).toList();
    List<String> textureIds = _selectedTextures.map((name) => textureIdMap[name] ?? '').where((id) => id.isNotEmpty).toList();
    List<String> originIds = _selectedOrigins.map((name) => originIdMap[name] ?? '').where((id) => id.isNotEmpty).toList();
    List<String> stateCountryIds = _selectedStates.map((name) => stateCountryIdMap[name] ?? '').where((id) => id.isNotEmpty).toList();
    List<String> processingNatureIds = _selectedProcessing.map((name) => processingNatureIdMap[name] ?? '').where((id) => id.isNotEmpty).toList();
    List<String> materialNaturalityIds = _selectedNaturality.map((name) => materialNaturalityIdMap[name] ?? '').where((id) => id.isNotEmpty).toList();
    List<String> handicraftIds = _selectedHandicrafts.map((name) => handicraftIdMap[name] ?? '').where((id) => id.isNotEmpty).toList();
    List<String> utilityIds = selectedUtilityId != null ? [selectedUtilityId!] : [];

    // Debug logging
    if (kDebugMode) {
      print('🔍 Selected Options to IDs Conversion:');
      print('   Colors: ${_selectedColours.length} selected -> ${colorIds.length} IDs');
      print('   Natural Colors: ${_selectedNaturalColours.length} selected -> ${naturalColorIds.length} IDs');
      print('   Finishes: ${_selectedFinishes.length} selected -> ${finishIds.length} IDs');
      print('   Textures: ${_selectedTextures.length} selected -> ${textureIds.length} IDs');
      print('   Origins: ${_selectedOrigins.length} selected -> ${originIds.length} IDs');
      print('   State/Country: ${_selectedStates.length} selected -> ${stateCountryIds.length} IDs');
      print('   Processing: ${_selectedProcessing.length} selected -> ${processingNatureIds.length} IDs');
      print('   Naturality: ${_selectedNaturality.length} selected -> ${materialNaturalityIds.length} IDs');
      print('   Handicrafts: ${_selectedHandicrafts.length} selected -> ${handicraftIds.length} IDs');
      print('   Utilities: ${selectedUtilityId != null ? 1 : 0} selected -> ${utilityIds.length} IDs');
    }

    // Create request body - API requires empty arrays, not null
    final requestBody = PutCatalogueOptionEntryRequestBody(
      colourOptionIds: colorIds,
      naturalColourOptionIds: naturalColorIds,
      finishOptionIds: finishIds,
      textureOptionIds: textureIds,
      originOptionIds: originIds,
      stateCountryOptionIds: stateCountryIds,
      processingNatureOptionIds: processingNatureIds,
      materialNaturalityOptionIds: materialNaturalityIds,
      handicraftTypeOptionIds: handicraftIds,
      utilityIds: utilityIds,
      synonyms: _synonyms, // Empty array for synonyms
    );

    // Call PutCatalogueOptionsEntryBloc
    if (_savedProductId != null && _savedProductId!.isNotEmpty) {
      context.read<PutCatalogueOptionsEntryBloc>().add(UpdateCatalogueOptions(
        productId: _savedProductId!,
        requestBody: requestBody,
        showLoader: true,
      ));

      // Listen to state
      _listenToPutCatalogueOptionsEntryState();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Product ID not found. Please try again.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  // Listener for PutCatalogueOptionsEntryBloc
  void _listenToPutCatalogueOptionsEntryState() {
    final subscription = context.read<PutCatalogueOptionsEntryBloc>().stream.listen((state) {
      if (state is PutCatalogueOptionsEntryLoading && state.showLoader) {
        showCustomProgressDialog(context, title: 'Completing product entry...');
      } else if (state is PutCatalogueOptionsEntrySuccess) {
        dismissCustomProgressDialog(context);
        if(state.response.statusCode==200 || state.response.statusCode==201){
          // Show success dialog
          _showSuccessDialog();
        }
        else{
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ ${state.response.message}'),
              backgroundColor: AppColors.error,
            ),
          );
        }



      } else if (state is PutCatalogueOptionsEntryError) {
        dismissCustomProgressDialog(context);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ ${state.message}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    });
    Future.delayed(const Duration(seconds: 15), () => subscription.cancel());
  }

  // Show success dialog after completing product entry
  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: AppColors.success, size: 32),
            SizedBox(width: 12),
            Text('Product Entry Complete!',overflow: TextOverflow.ellipsis,softWrap: true,maxLines: 2,style: TextStyle(fontSize: 15),),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Your product has been successfully added to the catalogue.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSummaryRow('Product ID', _savedProductId ?? 'N/A'),
                    const Divider(),
                    _buildSummaryRow('Product Name', _productNameController.text),
                    const Divider(),
                    _buildSummaryRow('Product Code', _productCodeController.text.isEmpty ? 'Auto-generated' : _productCodeController.text),
                    const Divider(),
                    _buildSummaryRow('Price', '₹${_pricePerSqFtController.text}/sq ft'),
                    const Divider(),
                    _buildSummaryRow('Images', '${_images.length} uploaded'),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Reset form for new entry
              _resetForm();
            },
            child: const Text('Add Another Product'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context); // Go back to previous screen

            },
            style: ElevatedButton.styleFrom(
              backgroundColor: SessionManager.getUserRole().toString().toLowerCase() == "superadmin"
                  ? AppColors.superAdminPrimary
                  : AppColors.primaryDeepBlue,
            ),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  // Old _submitSection2 implementation removed - now uses BLoC

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  void _resetForm() {
    setState(() {
      // Reset controllers
      _productNameController.clear();
      _productCodeController.clear();
      _descriptionController.clear();
      _pricePerSqFtController.clear();

      // Reset images
      _images.clear();

      // Reset selections
      selectedProductTypeId = null;
      selectedUtilityId = null;
      _selectedColours.clear();
      _selectedNaturalColours.clear();
      _selectedOrigins.clear();
      _selectedStates.clear();
      _selectedProcessing.clear();
      _selectedNaturality.clear();
      _selectedFinishes.clear();
      _selectedTextures.clear();
      _selectedHandicrafts.clear();

      // Reset sections
      _showSection1 = true;
      _showSection2 = false;
      _savedProductId = null;
    });
  }

  // Build color picker section using API color data
  Widget _buildColorPickerSectionWithApi({
    required String title,
    required List<dynamic> colorData,
    required List<String> selectedOptions,
  }) {
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
          Row(
            children: [
              Icon(Icons.color_lens, color: SessionManager.getUserRole().toString().toLowerCase() == "superadmin" ? AppColors.superAdminPrimary : AppColors.primaryDeepBlue, size: 20),
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
              if (selectedOptions.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: SessionManager.getUserRole().toString().toLowerCase() == "superadmin" ? AppColors.superAdminPrimary : AppColors.primaryDeepBlue,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${selectedOptions.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              // Add custom color button
              InkWell(
                onTap: () => _showCustomColorPicker(title),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: SessionManager.getUserRole().toString().toLowerCase() == "superadmin" ? AppColors.superAdminPrimary.withAlpha(20) : AppColors.primaryDeepBlue.withAlpha(20),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.add,
                    color: SessionManager.getUserRole().toString().toLowerCase() == "superadmin" ? AppColors.superAdminPrimary : AppColors.primaryDeepBlue,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          colorData.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                    child: Text(
                      'No colors available. Add a new color using the + button.',
                      style: TextStyle(color: Colors.grey.shade600),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : Wrap(
                  spacing: 8,
                  runSpacing: 12,
                  children: colorData.where((colorItem) {
                    // Filter out colors with invalid hex codes
                    final colorCode = colorItem.code ?? '';
                    if (colorCode.isEmpty) return false;

                    try {
                      final hexString = colorCode.replaceAll('0X', '0x').replaceAll('0x', '');
                      // Test if it's a valid hex color (should be 6 or 8 characters)
                      if (hexString.length != 6 && hexString.length != 8) return false;
                      int.parse(hexString, radix: 16); // This will throw if invalid
                      return true;
                    } catch (e) {
                      if (kDebugMode) print('⚠️ Skipping invalid color code $colorCode: $e');
                      return false; // Skip this color
                    }
                  }).map((colorItem) {
                    final colorName = colorItem.name ?? '';
                    final colorCode = colorItem.code ?? '';
                    final isSelected = selectedOptions.contains(colorName);

                    // Parse hex color code (format: "0XFF9C27B0" or "0xff9c27b0")
                    Color colorValue;
                    try {
                      final hexString = colorCode.replaceAll('0X', '0x').replaceAll('0x', '');
                      colorValue = Color(int.parse('0xff$hexString'));
                    } catch (e) {
                      // This should never happen since we filtered above, but just in case
                      colorValue = Colors.grey;
                      if (kDebugMode) print('⚠️ Unexpected error parsing $colorCode: $e');
                    }

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            selectedOptions.remove(colorName);
                          } else {
                            selectedOptions.add(colorName);
                          }
                        });
                      },
                      child: Tooltip(
                        message: colorName,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: colorValue,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected
                                  ? (SessionManager.getUserRole().toString().toLowerCase() == "superadmin"
                                      ? AppColors.superAdminPrimary
                                      : AppColors.primaryDeepBlue)
                                  : Colors.grey.shade300,
                              width: isSelected ? 3 : 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: isSelected
                                    ? colorValue.withAlpha(100)
                                    : Colors.black.withAlpha(20),
                                blurRadius: isSelected ? 8 : 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: isSelected
                              ? const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 20,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black45,
                                      blurRadius: 4,
                                    ),
                                  ],
                                )
                              : null,
                        ),
                      ),
                    );
                  }).toList(),
                ),
        ],
      ),
    );
  }


  // Helper method for loading container
  Widget _buildLoadingContainer() {
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
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  // Helper method for error container
  Widget _buildErrorContainer(String filterName, String message) {
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
          Text(
            'Error loading $filterName',
            style: const TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            message,
            style: const TextStyle(color: Colors.red),
          ),
        ],
      ),
    );
  }

  // Custom filter section for State/Country with type selection
  Widget _buildStateCountryFilterSection(
    List<String> options,
    List<String> selectedOptions,
  ) {
    const title = 'State / Country';
    final isAddingToThisSection = _addingSectionTitle == title;

    return Container(
      padding: const EdgeInsets.all(10),
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
          Row(
            children: [
              Icon(Icons.tune, color: SessionManager.getUserRole().toString().toLowerCase() =="superadmin" ?AppColors.superAdminPrimary: AppColors.primaryDeepBlue, size: 20),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (selectedOptions.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color:SessionManager.getUserRole().toString().toLowerCase() =="superadmin" ?AppColors.superAdminPrimary: AppColors.primaryDeepBlue ,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${selectedOptions.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
             // Add button
             InkWell(
               onTap: () {
                 setState(() {
                   if (isAddingToThisSection) {
                     _addingSectionTitle = null;
                     _newOptionController.clear();
                     _selectedStateCountryType = null;
                   } else {
                     _addingSectionTitle = title;
                     _newOptionController.clear();
                     _selectedStateCountryType = null;
                   }
                 });
               },
               borderRadius: BorderRadius.circular(8),
               child: Container(
                 padding: const EdgeInsets.all(6),
                 decoration: BoxDecoration(
                   color: isAddingToThisSection
                       ? AppColors.error.withAlpha(20)
                       : SessionManager.getUserRole().toString().toLowerCase() =="superadmin" ?AppColors.superAdminPrimary.withAlpha(20): AppColors.primaryDeepBlue.withAlpha(20),
                   borderRadius: BorderRadius.circular(8),
                 ),
                 child: Icon(
                   isAddingToThisSection ? Icons.close : Icons.add,
                   color: isAddingToThisSection
                       ? AppColors.error
                       : SessionManager.getUserRole().toString().toLowerCase() =="superadmin" ?AppColors.superAdminPrimary: AppColors.primaryDeepBlue,
                   size: 20,
                 ),
               ),
             ),
            ],
          ),
          const SizedBox(height: 10),

         // Show type selection and text field if this section is in add mode
         if (isAddingToThisSection) ...[
           // Type selection buttons
           Row(
             children: [
               Expanded(
                 child: InkWell(
                   onTap: () {
                     setState(() {
                       _selectedStateCountryType = 'State';
                     });
                   },
                   child: Container(
                     padding: const EdgeInsets.symmetric(vertical: 10),
                     decoration: BoxDecoration(
                       color: _selectedStateCountryType == 'State'
                           ? (SessionManager.getUserRole().toString().toLowerCase() =="superadmin"
                               ? AppColors.superAdminPrimary
                               : AppColors.primaryDeepBlue)
                           : Colors.grey.shade200,
                       borderRadius: BorderRadius.circular(10),
                     ),
                     child: Row(
                       mainAxisAlignment: MainAxisAlignment.center,
                       children: [
                         Icon(
                           Icons.location_city,
                           color: _selectedStateCountryType == 'State'
                               ? Colors.white
                               : Colors.grey.shade600,
                           size: 18,
                         ),
                         const SizedBox(width: 6),
                         Text(
                           'State',
                           style: TextStyle(
                             color: _selectedStateCountryType == 'State'
                                 ? Colors.white
                                 : Colors.grey.shade600,
                             fontWeight: _selectedStateCountryType == 'State'
                                 ? FontWeight.bold
                                 : FontWeight.normal,
                             fontSize: 14,
                           ),
                         ),
                       ],
                     ),
                   ),
                 ),
               ),
               const SizedBox(width: 10),
               Expanded(
                 child: InkWell(
                   onTap: () {
                     setState(() {
                       _selectedStateCountryType = 'Country';
                     });
                   },
                   child: Container(
                     padding: const EdgeInsets.symmetric(vertical: 10),
                     decoration: BoxDecoration(
                       color: _selectedStateCountryType == 'Country'
                           ? (SessionManager.getUserRole().toString().toLowerCase() =="superadmin"
                               ? AppColors.superAdminPrimary
                               : AppColors.primaryDeepBlue)
                           : Colors.grey.shade200,
                       borderRadius: BorderRadius.circular(10),
                     ),
                     child: Row(
                       mainAxisAlignment: MainAxisAlignment.center,
                       children: [
                         Icon(
                           Icons.public,
                           color: _selectedStateCountryType == 'Country'
                               ? Colors.white
                               : Colors.grey.shade600,
                           size: 18,
                         ),
                         const SizedBox(width: 6),
                         Text(
                           'Country',
                           style: TextStyle(
                             color: _selectedStateCountryType == 'Country'
                                 ? Colors.white
                                 : Colors.grey.shade600,
                             fontWeight: _selectedStateCountryType == 'Country'
                                 ? FontWeight.bold
                                 : FontWeight.normal,
                             fontSize: 14,
                           ),
                         ),
                       ],
                     ),
                   ),
                 ),
               ),
             ],
           ),
           const SizedBox(height: 12),

           // Show text field only if type is selected
           if (_selectedStateCountryType != null) ...[
             Row(
               children: [
                 Expanded(
                   child: Container(
                     height: 40,
                     decoration: BoxDecoration(
                       borderRadius: BorderRadius.circular(20),
                     ),
                     child: TextField(
                       controller: _newOptionController,
                       autofocus: true,
                       decoration: InputDecoration(
                         hintText: 'Enter ${_selectedStateCountryType?.toLowerCase()} name...',
                         hintStyle: TextStyle(
                           color: Colors.grey.shade400,
                           fontSize: 14,
                         ),
                         border: InputBorder.none,
                         contentPadding: const EdgeInsets.symmetric(
                           horizontal: 16,
                           vertical: 10,
                         ),
                         prefixIcon: Icon(
                           _selectedStateCountryType == 'State'
                               ? Icons.location_city
                               : Icons.public,
                           size: 18,
                           color: SessionManager.getUserRole().toString().toLowerCase() =="superadmin"
                               ? AppColors.superAdminPrimary
                               : AppColors.primaryDeepBlue,
                         ),
                       ),
                       style: const TextStyle(fontSize: 14),
                       onSubmitted: (value) => _saveStateCountryOption(options),
                     ),
                   ),
                 ),
                 const SizedBox(width: 8),
                 // Save button
                 InkWell(
                   onTap: () => _saveStateCountryOption(options),
                   borderRadius: BorderRadius.circular(20),
                   child: Container(
                     height: 40,
                     padding: const EdgeInsets.symmetric(horizontal: 16),
                     decoration: BoxDecoration(
                       gradient: SessionManager.getUserRole().toString().toLowerCase() =="superadmin" ?AppColors.superAdminGradient: AppColors.primaryGradient,
                       borderRadius: BorderRadius.circular(20),
                       boxShadow: [
                         BoxShadow(
                           color:SessionManager.getUserRole().toString().toLowerCase() =="superadmin" ?AppColors.superAdminPrimary.withAlpha(50): AppColors.primaryDeepBlue.withAlpha(50),
                           blurRadius: 8,
                           offset: const Offset(0, 2),
                         ),
                       ],
                     ),
                     child: const Row(
                       mainAxisSize: MainAxisSize.min,
                       children: [
                         Icon(Icons.check, color: Colors.white, size: 18),
                         SizedBox(width: 4),
                         Text(
                           'Save',
                           style: TextStyle(
                             color: Colors.white,
                             fontSize: 14,
                             fontWeight: FontWeight.w600,
                           ),
                         ),
                       ],
                     ),
                   ),
                 ),
               ],
             ),
             const SizedBox(height: 12),
           ],
         ],

          Wrap(
            spacing: 5,
            runSpacing: 2,
            children: options.map((option) {
              final isSelected = selectedOptions.contains(option);
              return FilterChip(
                labelPadding: const EdgeInsets.symmetric(horizontal: 2,),
                label: Text(option),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      selectedOptions.add(option);
                    } else {
                      selectedOptions.remove(option);
                    }
                  });
                },
                selectedColor: AppColors.success.withAlpha(50),
                checkmarkColor: AppColors.success,
                labelStyle: TextStyle(
                  color: isSelected ? AppColors.success : Colors.black87,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
                side: BorderSide(
                  color: isSelected
                      ? AppColors.success
                      : Colors.grey.withAlpha(100),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

 void _saveStateCountryOption(List<String> options) {
   final newOption = _newOptionController.text.trim();

   if (_selectedStateCountryType == null) {
     ScaffoldMessenger.of(context).showSnackBar(
       const SnackBar(
         content: Text('Please select State or Country first'),
         backgroundColor: AppColors.warning,
       ),
     );
     return;
   }

   if (newOption.isEmpty) {
     ScaffoldMessenger.of(context).showSnackBar(
       const SnackBar(
         content: Text('Please enter a state/country name'),
         backgroundColor: AppColors.error,
       ),
     );
     return;
   }

   if (options.contains(newOption)) {
     ScaffoldMessenger.of(context).showSnackBar(
       SnackBar(
         content: Text('$_selectedStateCountryType "$newOption" already exists'),
         backgroundColor: AppColors.warning,
       ),
     );
     return;
   }

   // Create request body with type field
   final requestBody = PostCatalogueCommonRequestBody(
     name: newOption,
     code: newOption.toUpperCase().replaceAll(' ', '_'),
     type: _selectedStateCountryType, // 'State' or 'Country'
     sortOrder: 0,
     isActive: true,
   );

   // Call the POST API
   context.read<PostStateCountriesBloc>().add(SubmitPostStateCountries(
     requestBody: requestBody,
     showLoader: true,
   ));
   _listenToPostStateCountriesState();
 }
}
