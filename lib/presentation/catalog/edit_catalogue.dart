import 'package:apclassstone/presentation/widgets/app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import 'dart:io';

import '../../bloc/catalogue/post_catalogue_methods/post_catalogue_bloc.dart';
import '../../bloc/catalogue/post_catalogue_methods/post_catalogue_event.dart';
import '../../bloc/catalogue/post_catalogue_methods/post_catalogue_state.dart';
import '../../core/constants/app_colors.dart';
import '../../bloc/catalogue/get_catalogue_methods/get_catalogue_bloc.dart';
import '../../bloc/catalogue/get_catalogue_methods/get_catalogue_event.dart';
import '../../bloc/catalogue/get_catalogue_methods/get_catalogue_state.dart';
import '../../bloc/catalogue/put_catalogues_methods/put_edit_product_bloc.dart';
import '../../bloc/catalogue/put_catalogues_methods/put_edit_product_event.dart';
import '../../bloc/catalogue/put_catalogues_methods/put_edit_product_state.dart';
import '../../bloc/catalogue/put_catalogues_methods/put_catalogue_image_operations_bloc.dart';
import '../../bloc/catalogue/put_catalogues_methods/put_catalogue_image_operations_event.dart';
import '../../bloc/catalogue/put_catalogues_methods/put_catalogue_image_operations_state.dart';
import '../../api/models/request/PutEditCatalogueRequestBody.dart';
import '../../api/models/response/GetCatalogueProductDetailsResponseBody.dart' show ImageMetas;
import '../../presentation/widgets/custom_loader.dart';

class EditCatalogue extends StatefulWidget {
  final String? productId;

  const EditCatalogue({super.key, this.productId});

  @override
  State<EditCatalogue> createState() => _EditCatalogueState();
}

class _EditCatalogueState extends State<EditCatalogue> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _marketingOneLinedController;

  late TextEditingController _archGradeAController;
  late TextEditingController _archGradeBController;
  late TextEditingController _archGradeCController;
  late TextEditingController _traderGradeAController;
  late TextEditingController _traderGradeBController;
  late TextEditingController _traderGradeCController;

  String? selectedProductTypeId;
  String? selectedPriceRangeId;
  String? selectedMineId;
  List<String> uploadedImageUrls = [];
  List<ImageMetas> imageMetas = []; // Contains image data with id, url, isPrimary, sortOrder
  String? primaryImageUrl;
  String? primaryImageId;
  List<File> newLocalImages = [];
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    if (widget.productId != null) {
      context.read<GetCatalogueProductDetailsBloc>().add(
        FetchGetCatalogueProductDetails(
          productId: widget.productId!,
          showLoader: true,
        ),
      );
    }
  }

  void _initializeControllers() {
    _nameController = TextEditingController();
    _descriptionController = TextEditingController();
    _marketingOneLinedController = TextEditingController();
    _archGradeAController = TextEditingController();
    _archGradeBController = TextEditingController();
    _archGradeCController = TextEditingController();
    _traderGradeAController = TextEditingController();
    _traderGradeBController = TextEditingController();
    _traderGradeCController = TextEditingController();
  }

  void _populateFormWithData(dynamic data) {
    _nameController.text = data.name ?? '';
    _descriptionController.text = data.description ?? '';
    _marketingOneLinedController.text = data.marketingOneLiner ?? '';
    _archGradeAController.text = data.priceSqftArchitectGradeA?.toString() ?? '';
    _archGradeBController.text = data.priceSqftArchitectGradeB?.toString() ?? '';
    _archGradeCController.text = data.priceSqftArchitectGradeC?.toString() ?? '';
    _traderGradeAController.text = data.priceSqftTraderGradeA?.toString() ?? '';
    _traderGradeBController.text = data.priceSqftTraderGradeB?.toString() ?? '';
    _traderGradeCController.text = data.priceSqftTraderGradeC?.toString() ?? '';
    selectedProductTypeId = data.productTypeId;
    selectedPriceRangeId = data.priceRangeId;
    selectedMineId = data.mineId;

    // Use imageMetas from API response
    imageMetas = data.imageMetas ?? [];

    // Extract URLs from imageMetas for display in carousel
    uploadedImageUrls = imageMetas.map((meta) => meta.imageUrl ?? '').where((url) => url.isNotEmpty).toList();

    // Find primary image from imageMetas
    final primaryMeta = imageMetas.firstWhere(
      (meta) => meta.isPrimary == true,
      orElse: () => ImageMetas(),
    );
    if (primaryMeta.id != null) {
      primaryImageUrl = primaryMeta.imageUrl;
      primaryImageId = primaryMeta.id;
    }
  }

  Future<void> _pickImage({bool fromCamera = false}) async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: fromCamera ? ImageSource.camera : ImageSource.gallery,
        imageQuality: 70,
      );

      if (pickedFile != null) {
        final file = File(pickedFile.path);
        setState(() {
          newLocalImages.add(file);
        });

        // Show upload dialog
        if (mounted) {
          _showUploadDialog(file);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking image: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _showUploadDialog(File imageFile) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Upload Image?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(
                imageFile,
                height: 150,
                width: 150,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Set this as primary image?',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _uploadImage(imageFile, setAsPrimary: false);
            },
            child: const Text('Upload'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _uploadImage(imageFile, setAsPrimary: true);
            },
            child: const Text(
              'Upload as Primary',
              style: TextStyle(color: AppColors.success),
            ),
          ),
        ],
      ),
    );
  }

  void _uploadImage(File imageFile, {required bool setAsPrimary}) {
    context.read<CatalogueImageEntryBloc>().add(
      UploadCatalogueImage(
        productId: widget.productId!,
        imageFile: imageFile,
        setAsPrimary: setAsPrimary,
        showLoader: true,
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final requestBody = PutEditCatalogueRequestBody(
        name: _nameController.text,
        description: _descriptionController.text,
        productTypeId: selectedProductTypeId,
        priceRangeId: selectedPriceRangeId,
        mineId: selectedMineId,
        priceSqftArchitectGradeA: int.tryParse(_archGradeAController.text),
        priceSqftArchitectGradeB: int.tryParse(_archGradeBController.text),
        priceSqftArchitectGradeC: int.tryParse(_archGradeCController.text),
        priceSqftTraderGradeA: int.tryParse(_traderGradeAController.text),
        priceSqftTraderGradeB: int.tryParse(_traderGradeBController.text),
        priceSqftTraderGradeC: int.tryParse(_traderGradeCController.text),
        marketingOneLiner: _marketingOneLinedController.text,
        sortOrder: 0,
        isActive: true
      );

      context.read<PutEditProductBloc>().add(
        SubmitPutEditProduct(
          productId: widget.productId!,
          requestBody: requestBody,
          showLoader: true,
        ),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _marketingOneLinedController.dispose();
    _archGradeAController.dispose();
    _archGradeBController.dispose();
    _archGradeCController.dispose();
    _traderGradeAController.dispose();
    _traderGradeBController.dispose();
    _traderGradeCController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(56),
        child: CoolAppCard(
          title: "Edit Product",
          backgroundColor: AppColors.superAdminPrimary,
        ),
      ),
      body: BlocListener<CatalogueImageEntryBloc, CatalogueImageEntryState>(
        listener: (context, state) {
          if (state is CatalogueImageEntryLoading && state.showLoader) {
            showCustomProgressDialog(context, title: 'Uploading image...');
          } else if (state is CatalogueImageEntrySuccess) {
            dismissCustomProgressDialog(context);

            setState(() {
              newLocalImages.clear();
            });

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.response.message ?? 'Image uploaded successfully'),
                backgroundColor: AppColors.success,
              ),
            );

            // Refresh product details to show new image
            if (widget.productId != null) {
              context.read<GetCatalogueProductDetailsBloc>().add(
                FetchGetCatalogueProductDetails(
                  productId: widget.productId!,
                  showLoader: false,
                ),
              );
            }
          } else if (state is CatalogueImageEntryError) {
            dismissCustomProgressDialog(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        child: BlocListener<PutCatalogueImageOperationsBloc, PutCatalogueImageOperationsState>(
          listener: (context, state) {
            if (state is PutCatalogueImageOperationsLoading && state.showLoader) {
              if (state.operationType == 'delete') {
                showCustomProgressDialog(context, title: 'Deleting image...');
              } else if (state.operationType == 'setPrimary') {
                showCustomProgressDialog(context, title: 'Setting as primary...');
              }
            } else if (state is DeleteImageSuccess) {
              dismissCustomProgressDialog(context);

              // Remove the deleted image from imageMetas
              setState(() {
                imageMetas.removeWhere((meta) => meta.id == state.imageId);
                uploadedImageUrls = imageMetas.map((meta) => meta.imageUrl ?? '').where((url) => url.isNotEmpty).toList();

                // Reset primary if deleted image was primary
                if (primaryImageId == state.imageId) {
                  primaryImageUrl = null;
                  primaryImageId = null;
                }
              });

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.response.message ?? 'Image deleted successfully'),
                  backgroundColor: AppColors.success,
                ),
              );

              // Refresh product details
              if (widget.productId != null) {
                context.read<GetCatalogueProductDetailsBloc>().add(
                  FetchGetCatalogueProductDetails(
                    productId: widget.productId!,
                    showLoader: false,
                  ),
                );
              }
            } else if (state is SetImagePrimarySuccess) {
              dismissCustomProgressDialog(context);

              // Update imageMetas to set new primary
              setState(() {
                // Clear old primary flag
                for (var meta in imageMetas) {
                  if (meta.isPrimary == true) {
                    meta.isPrimary = false;
                  }
                }

                // Set new primary
                final primaryMeta = imageMetas.firstWhere(
                  (meta) => meta.id == state.imageId,
                  orElse: () => ImageMetas(),
                );
                if (primaryMeta.id != null) {
                  primaryMeta.isPrimary = true;
                  primaryImageUrl = primaryMeta.imageUrl;
                  primaryImageId = primaryMeta.id;
                }
              });

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.response.message ?? 'Image set as primary'),
                  backgroundColor: AppColors.success,
                ),
              );

              // Refresh product details
              if (widget.productId != null) {
                context.read<GetCatalogueProductDetailsBloc>().add(
                  FetchGetCatalogueProductDetails(
                    productId: widget.productId!,
                    showLoader: false,
                  ),
                );
              }
            } else if (state is PutCatalogueImageOperationsError) {
              dismissCustomProgressDialog(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.error,
                ),
              );
            }
          },
          child: BlocListener<PutEditProductBloc, PutEditProductState>(
            listener: (context, state) {
              if (state is PutEditProductLoading && state.showLoader) {
                showCustomProgressDialog(context);
              } else if (state is PutEditProductSuccess) {
                dismissCustomProgressDialog(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Product updated successfully'),
                    backgroundColor: AppColors.success,
                  ),
                );
                context.pop(true);
              } else if (state is PutEditProductError) {
                dismissCustomProgressDialog(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            },
            child: RefreshIndicator(
              onRefresh: () async {
                if (widget.productId != null) {
                  context.read<GetCatalogueProductDetailsBloc>().add(
                    FetchGetCatalogueProductDetails(
                      productId: widget.productId!,
                      showLoader: false,
                    ),
                  );
                }
              },
              child: BlocBuilder<GetCatalogueProductDetailsBloc, GetCatalogueProductDetailsState>(
                builder: (context, state) {
                  if (state is GetCatalogueProductDetailsLoading && state.showLoader) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is GetCatalogueProductDetailsLoaded) {
                    final data = state.response.data;
                    if (data != null && _nameController.text.isEmpty) {
                      _populateFormWithData(data);
                    }

                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildImagesSection(),
                            const SizedBox(height: 24),
                            _buildSectionTitle('Basic Information'),
                            _buildTextField(
                              controller: _nameController,
                              label: 'Product Name',
                              hint: 'Enter product name',
                              required: true,
                            ),
                            const SizedBox(height: 12),
                            _buildTextField(
                              controller: _descriptionController,
                              label: 'Description',
                              hint: 'Enter product description',
                              maxLines: 3,
                            ),
                            const SizedBox(height: 12),
                            _buildTextField(
                              controller: _marketingOneLinedController,
                              label: 'Marketing One Liner',
                              hint: 'Enter marketing one liner',
                            ),
                            const SizedBox(height: 24),
                            _buildSectionTitle('Pricing - Architect Grade'),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildTextField(
                                    controller: _archGradeAController,
                                    label: 'Grade A',
                                    hint: 'Price',
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildTextField(
                                    controller: _archGradeBController,
                                    label: 'Grade B',
                                    hint: 'Price',
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildTextField(
                                    controller: _archGradeCController,
                                    label: 'Grade C',
                                    hint: 'Price',
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            _buildSectionTitle('Pricing - Trader Grade'),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildTextField(
                                    controller: _traderGradeAController,
                                    label: 'Grade A',
                                    hint: 'Price',
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildTextField(
                                    controller: _traderGradeBController,
                                    label: 'Grade B',
                                    hint: 'Price',
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildTextField(
                                    controller: _traderGradeCController,
                                    label: 'Grade C',
                                    hint: 'Price',
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: _submitForm,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.superAdminPrimary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text(
                                  'Update Product',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    );
                  }

                  if (state is GetCatalogueProductDetailsError) {
                    return Center(
                      child: Text(
                        'Error: ${state.message}',
                        textAlign: TextAlign.center,
                      ),
                    );
                  }

                  return const SizedBox();
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Build Images Section with Swipeable Carousel
  Widget _buildImagesSection() {
    final images = uploadedImageUrls.isEmpty ? [] : uploadedImageUrls;

    if (images.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Product Images'),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 40),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.grey[300]!,
                width: 1,
              ),
            ),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.image_not_supported,
                    color: Colors.grey[400],
                    size: 48,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No images uploaded yet',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildAddImageButton(),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Product Images'),
        const SizedBox(height: 12),
        SizedBox(
          height: 230,
          child: PageView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: images.length,
            itemBuilder: (context, index) {
              final imageUrl = images[index];
              final isPrimary = imageUrl == primaryImageUrl;

              return GestureDetector(
                onLongPress: () => _showImageContextMenu(imageUrl, isPrimary),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: isPrimary
                        ? Border.all(color: AppColors.success, width: 3)
                        : Border.all(color: Colors.grey[300]!, width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[300],
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.broken_image,
                                    color: Colors.grey[600],
                                    size: 48,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Failed to load image',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.4),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                      if (isPrimary)
                        Positioned(
                          top: 12,
                          right: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.success,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.2),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.star,
                                  color: Colors.white,
                                  size: 14,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'PRIMARY',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      Positioned(
                        bottom: 16,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.6),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.touch_app,
                                  color: Colors.white,
                                  size: 14,
                                ),
                                SizedBox(width: 6),
                                Text(
                                  'Long press for options',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 12,
                        right: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${index + 1}/${images.length}',
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
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 20),
        _buildAddImageButton(),
      ],
    );
  }

  Widget _buildAddImageButton() {
    return GestureDetector(
      onTap: _showImageSourceOptions,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 5),
        decoration: BoxDecoration(
          color: AppColors.superAdminPrimary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.superAdminPrimary,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: AppColors.superAdminPrimary.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.add_photo_alternate,
                color: AppColors.superAdminPrimary,
                size: 25,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Add New Image',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.superAdminPrimary,
              ),
            ),

          ],
        ),
      ),
    );
  }

  void _showImageSourceOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.superAdminPrimary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.camera_alt,
                  color: AppColors.superAdminPrimary,
                  size: 24,
                ),
              ),
              title: const Text(
                'Take from Camera',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: const Text('Capture a new photo'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(fromCamera: true);
              },
            ),
            const SizedBox(height: 12),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.superAdminPrimary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.image,
                  color: AppColors.superAdminPrimary,
                  size: 24,
                ),
              ),
              title: const Text(
                'Choose from Gallery',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: const Text('Select from your device'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(fromCamera: false);
              },
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const SizedBox(
                  width: double.infinity,
                  child: Text(
                    'Cancel',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showImageContextMenu(String imageUrl, bool isPrimary) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: 120,
              height: 120,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(11),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.broken_image),
                    );
                  },
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete Image'),
              subtitle: const Text('Remove this image from product'),
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirmation(imageUrl);
              },
            ),
            if (!isPrimary)
              ListTile(
                leading: const Icon(Icons.star, color: AppColors.success),
                title: const Text('Set as Primary'),
                subtitle: const Text('Make this the primary product image'),
                onTap: () {
                  Navigator.pop(context);
                  _showSetPrimaryConfirmation(imageUrl);
                },
              ),
            if (isPrimary)
              ListTile(
                leading: const Icon(Icons.star, color: AppColors.success),
                title: const Text('Primary Image'),
                subtitle: const Text('This is already the primary image'),
                enabled: false,
              ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                alignment: Alignment.center,
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Image?'),
        content: const Text('Are you sure you want to delete this image? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteImageAndRefresh(imageUrl);
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _showSetPrimaryConfirmation(String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Set as Primary?'),
        content: const Text('This image will be displayed as the primary product image.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _setPrimaryImageAndRefresh(imageUrl);
            },
            child: const Text(
              'Set Primary',
              style: TextStyle(color: AppColors.success),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteImageAndRefresh(String imageUrl) async {
    try {
      // Find the ImageMeta for this URL
      final imageMeta = imageMetas.firstWhere(
        (meta) => meta.imageUrl == imageUrl,
        orElse: () => ImageMetas(),
      );
      if (imageMeta.id == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error: Image not found'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }

      // Dispatch the delete event to BLoC
      if (mounted && widget.productId != null) {
        context.read<PutCatalogueImageOperationsBloc>().add(
          DeleteProductImage(
            productId: widget.productId!,
            imageId: imageMeta.id!,
            showLoader: true,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _setPrimaryImageAndRefresh(String imageUrl) async {
    try {
      // Find the ImageMeta for this URL
      final imageMeta = imageMetas.firstWhere(
        (meta) => meta.imageUrl == imageUrl,
        orElse: () => ImageMetas(),
      );
      if (imageMeta.id == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error: Image not found'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }

      // Dispatch the set primary event to BLoC
      if (mounted && widget.productId != null) {
        context.read<PutCatalogueImageOperationsBloc>().add(
          SetImagePrimary(
            productId: widget.productId!,
            imageId: imageMeta.id!,
            showLoader: true,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    bool required = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.grey300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.grey300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: AppColors.superAdminPrimary,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
          ),
          validator: required
              ? (value) {
                  if (value == null || value.isEmpty) {
                    return '$label is required';
                  }
                  return null;
                }
              : null,
        ),
      ],
    );
  }
}

