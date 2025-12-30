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

  // Selected dropdown values
  String? selectedProductTypeId;
  String? selectedUtilityId;

  // Color options with hex codes
  final Map<String, Color> colourMap = {
    'Black': const Color(0xFF000000),
    'Blue': const Color(0xFF2196F3),
    'Beige': const Color(0xFFF5F5DC),
    'White': const Color(0xFFFFFFFF),
    'Red': const Color(0xFFE53935),
    'Pink': const Color(0xFFE91E63),
    'Golden': const Color(0xFFFFD700),
    'Brown': const Color(0xFF795548),
    'Silver': const Color(0xFFC0C0C0),
    'Grey': const Color(0xFF9E9E9E),
    'Green': const Color(0xFF4CAF50),
    'Yellow': const Color(0xFFFDD835),
    'Orange': const Color(0xFFFF9800),
    'Purple': const Color(0xFF9C27B0),
    'Cream': const Color(0xFFFFFDD0),
  };

  final List<String> colours = [
    'Black', 'Blue', 'Beige', 'White', 'Red', 'Pink', 'Golden',
    'Brown', 'Silver', 'Grey', 'Green', 'Yellow', 'Orange', 'Purple', 'Cream'
  ];

  final List<String> priceRanges = [
    '0–50', '50–100', '100–200', '200–1000', 'Above 1000'
  ];


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
              : AppColors.primaryTealDark,
        ),
      ),
      body: Column(
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
          padding: const EdgeInsets.all(20),
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
              const SizedBox(height: 16),

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
              const SizedBox(height: 16),

              // Description
              TextField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Description',
                  hintText: 'Enter product description',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.description_outlined),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
              ),
              const SizedBox(height: 16),

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
              const SizedBox(height: 16),

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
        _buildColorPickerSection('Colour', _selectedColours),
        const SizedBox(height: 16),
        _buildColorPickerSection('Natural Colour', _selectedNaturalColours),
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

   if (colourMap.containsKey(colorName)) {
     ScaffoldMessenger.of(context).showSnackBar(
       SnackBar(
         content: Text('Color "$colorName" already exists'),
         backgroundColor: AppColors.warning,
       ),
     );
     return;
   }

   setState(() {
     colourMap[colorName] = _pickerColor;
     colours.add(colorName);
   });

   Navigator.pop(context);

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
             child: Text('✅ Added "$colorName" (#${_pickerColor.toARGB32().toRadixString(16).substring(2).toUpperCase()})'),
           ),
         ],
       ),
       backgroundColor: AppColors.success,
       duration: const Duration(seconds: 3),
     ),
   );
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

    // Show success dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: AppColors.success, size: 32),
            SizedBox(width: 12),
            Text('Product Entry Complete!'),
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

  Widget _buildColorPickerSection(
    String title,
    List<String> selectedOptions,
  ) {
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
              Icon(Icons.color_lens, color: SessionManager.getUserRole().toString().toLowerCase() =="superadmin" ?AppColors.superAdminPrimary: AppColors.primaryDeepBlue, size: 20),
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
                    color: SessionManager.getUserRole().toString().toLowerCase() =="superadmin" ?AppColors.superAdminPrimary: AppColors.primaryDeepBlue,
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
                    color: SessionManager.getUserRole().toString().toLowerCase() =="superadmin" ?AppColors.superAdminPrimary.withAlpha(20): AppColors.primaryDeepBlue.withAlpha(20),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.add,
                    color: SessionManager.getUserRole().toString().toLowerCase() =="superadmin" ?AppColors.superAdminPrimary: AppColors.primaryDeepBlue,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 12,
            children: colourMap.keys.map((colourName) {
              final isSelected = selectedOptions.contains(colourName);
              final colourValue = colourMap[colourName]!;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      selectedOptions.remove(colourName);
                    } else {
                      selectedOptions.add(colourName);
                    }
                  });
                },
                child: Tooltip(
                  message: colourName,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: colourValue,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected
                            ? (SessionManager.getUserRole().toString().toLowerCase() =="superadmin"
                                ? AppColors.superAdminPrimary
                                : AppColors.primaryDeepBlue)
                            : Colors.grey.shade300,
                        width: isSelected ? 3 : 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isSelected
                              ? colourValue.withAlpha(100)
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
