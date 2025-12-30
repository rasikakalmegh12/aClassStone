import 'dart:io';
import 'package:apclassstone/bloc/catalogue/get_catalogue_methods/get_catalogue_bloc.dart';
import 'package:apclassstone/bloc/catalogue/get_catalogue_methods/get_catalogue_event.dart';
import 'package:apclassstone/bloc/catalogue/get_catalogue_methods/get_catalogue_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:path_provider/path_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/session/session_manager.dart';
import '../widgets/app_bar.dart';

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
          setState(() {
            _images.add(compressedFile);
          });
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

  void _submitForm() {
    // Validate
    if (_productNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter product name')),
      );
      return;
    }

    if (_images.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one image')),
      );
      return;
    }

    // Show success and data (for now, will connect to API later)
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Catalogue Entry'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Product: ${_productNameController.text}'),
              Text('Images: ${_images.length}'),
              Text('Product Types: ${_selectedProductTypes.join(", ")}'),
              Text('Utilities: ${_selectedUtilities.join(", ")}'),
              const Text('\n✅ Ready for API submission'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        // pass headerColor to the custom app bar
        child: CoolAppCard(title: "Catalogue Product Entry",
          backgroundColor: SessionManager.getUserRole().toString().toLowerCase() =="superadmin" ?AppColors.superAdminPrimary: AppColors.primaryTealDark,),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildImageUploadSection(),
                  const SizedBox(height: 20),
                  _buildBasicInfoSection(),
                  const SizedBox(height: 20),
                  // Product Type with BlocBuilder
                  BlocBuilder<GetProductTypeBloc, GetProductTypeState>(
                    builder: (context, state) {
                      if (state is GetProductTypeLoaded) {
                        // Populate productTypes from API response
                        if (state.response.data != null && state.response.data!.isNotEmpty) {
                          productTypes = state.response.data!
                              .where((item) => item.name != null && item.name!.isNotEmpty)
                              .map((item) => item.name!)
                              .toList();
                        }
                        return _buildFilterSection('Product Type', productTypes, _selectedProductTypes);
                      } else if (state is GetProductTypeLoading && state.showLoader) {
                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        );
                      } else if (state is GetProductTypeError) {
                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            'Error loading product types: ${state.message}',
                            style: const TextStyle(color: Colors.red),
                          ),
                        );
                      }
                      // Initial state - show empty or default
                      return _buildFilterSection('Product Type', productTypes, _selectedProductTypes);
                    },
                  ),
                  const SizedBox(height: 16),
                  // Utility / Application with BlocBuilder
                  BlocBuilder<GetUtilitiesBloc, GetUtilitiesState>(
                    builder: (context, state) {
                      if (state is GetUtilitiesLoaded) {
                        if (state.response.data != null && state.response.data!.isNotEmpty) {
                          utilities = state.response.data!
                              .where((item) => item.name != null && item.name!.isNotEmpty)
                              .map((item) => item.name!)
                              .toList();
                        }
                        return _buildFilterSection('Utility / Application', utilities, _selectedUtilities);
                      } else if (state is GetUtilitiesLoading && state.showLoader) {
                        return _buildLoadingContainer();
                      } else if (state is GetUtilitiesError) {
                        return _buildErrorContainer('utilities', state.message);
                      }
                      return _buildFilterSection('Utility / Application', utilities, _selectedUtilities);
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
                  // State / Country with BlocBuilder
                  BlocBuilder<GetStateCountriesBloc, GetStateCountriesState>(
                    builder: (context, state) {
                      if (state is GetStateCountriesLoaded) {
                        if (state.response.data != null && state.response.data!.isNotEmpty) {
                          states = state.response.data!
                              .where((item) => item.name != null && item.name!.isNotEmpty)
                              .map((item) => item.name!)
                              .toList();
                        }
                        return _buildFilterSection('State / Country', states, _selectedStates);
                      } else if (state is GetStateCountriesLoading && state.showLoader) {
                        return _buildLoadingContainer();
                      } else if (state is GetStateCountriesError) {
                        return _buildErrorContainer('states/countries', state.message);
                      }
                      return _buildFilterSection('State / Country', states, _selectedStates);
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildFilterSection('Price Range (Per Sqft)', priceRanges, _selectedPriceRanges),
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
                  if (_selectedProductTypes.contains('Handicrafts'))
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
                  const SizedBox(height: 100), // Space for submit button
                ],
              ),
            ),
          ),
          _buildSubmitButton(),
        ],
      ),
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

  Widget _buildBasicInfoSection() {
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
              Icon(Icons.edit_note, color:SessionManager.getUserRole().toString().toLowerCase() =="superadmin" ?AppColors.superAdminPrimary: AppColors.primaryDeepBlue),
              const SizedBox(width: 8),
              const Text(
                'Basic Information',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _productNameController,
            decoration: InputDecoration(
              labelText: 'Product Name *',
              hintText: 'Enter product name',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              prefixIcon: const Icon(Icons.inventory_2_outlined),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _productCodeController,
            decoration: InputDecoration(
              labelText: 'Product Code',
              hintText: 'Auto-generated if empty',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              prefixIcon: const Icon(Icons.qr_code),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _descriptionController,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'Description',
              hintText: 'Enter product description',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              prefixIcon: const Icon(Icons.description_outlined),
            ),
          ),
        ],
      ),
    );
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

   setState(() {
     options.add(newOption);
     _addingSectionTitle = null;
     _newOptionController.clear();
   });

   ScaffoldMessenger.of(context).showSnackBar(
     SnackBar(
       content: Text('✅ Added "$newOption" to $sectionTitle'),
       backgroundColor: AppColors.success,
       duration: const Duration(seconds: 2),
     ),
   );
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _submitForm,
            style: ElevatedButton.styleFrom(
              backgroundColor: SessionManager.getUserRole().toString().toLowerCase() =="superadmin" ?AppColors.superAdminPrimary: AppColors.primaryDeepBlue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Submit Catalogue Entry',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
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
}
