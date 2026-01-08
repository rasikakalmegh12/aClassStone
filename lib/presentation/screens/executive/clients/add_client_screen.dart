import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';

import '../../../../api/models/request/PostClientAddRequestBody.dart';
import '../../../../bloc/client/post_client/post_client_bloc.dart';
import '../../../../bloc/client/post_client/post_client_event.dart';
import '../../../../bloc/client/post_client/post_client_state.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/session/session_manager.dart';
import '../../../widgets/app_bar.dart';
import '../../../widgets/custom_loader.dart';


class AddClientScreen extends StatefulWidget {
  final Map<String, dynamic>? existingClient;

  const AddClientScreen({super.key, this.existingClient});

  @override
  State<AddClientScreen> createState() => _AddClientScreenState();
}

class _AddClientScreenState extends State<AddClientScreen> {
  final _formKey = GlobalKey<FormState>();

  // Form Controllers
  final _clientNameController = TextEditingController();
  final _firmNameController = TextEditingController();
  final _traderNameController = TextEditingController();
  final _ownerNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _gstController = TextEditingController();
  final _instagramController = TextEditingController();
  final _facebookController = TextEditingController();
  final _websiteController = TextEditingController();
  final _locationNameController = TextEditingController();
  final _stateController = TextEditingController();
  final _cityController = TextEditingController();

  // Form State
  String? selectedClientType;
  String? selectedCity;
  String? selectedState;
  String currentLocation = 'Captured automatically';
  bool showDuplicateWarning = false;

  // GPS Coordinates
  double? _gpsLat;
  double? _gpsLng;

  final List<String> clientTypes = [
    'Builder',
    'Architect',
    'Interior Designer',
    'Contractor',
    'Dealer',
    'Other',
  ];

  final List<String> cities = [
    'Jaipur',
    'Udaipur',
    'Jodhpur',
    'Ajmer',
    'Kota',
    'Bikaner',
    'Alwar',
    'Bhilwara',
    'Sikar',
    'Pali',
  ];

  final List<String> states = [
    'Rajasthan',
    'Gujarat',
    'Maharashtra',
    'Delhi',
    'Haryana',
    'Punjab',
    'Uttar Pradesh',
    'Madhya Pradesh',
  ];

  @override
  void initState() {
    super.initState();
    _initializeForm();
    _getCurrentLocation();
  }

  // Convert client type display name to API code
  String _getClientTypeCode(String displayName) {
    final Map<String, String> typeCodeMap = {
      'Builder': 'BUILDER',
      'Architect': 'ARCHITECT',
      'Interior Designer': 'INTERIOR_DESIGNER',
      'Contractor': 'CONTRACTOR',
      'Dealer': 'DEALER',
      'Other': 'OTHER',
    };
    return typeCodeMap[displayName] ?? 'OTHER';
  }

  Future<void> _getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        setState(() {
          currentLocation = 'Location permission denied';
        });
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );

      setState(() {
        _gpsLat = position.latitude;
        _gpsLng = position.longitude;
        currentLocation = '${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}';
      });
    } catch (e) {
      setState(() {
        currentLocation = 'Unable to get location';
      });
    }
  }

  void _initializeForm() {
    if (widget.existingClient != null) {
      final client = widget.existingClient!;
      _clientNameController.text = client['name'] ?? '';
      _firmNameController.text = client['firmName'] ?? '';
      _traderNameController.text = client['traderName'] ?? '';
      _ownerNameController.text = client['ownerName'] ?? '';
      _phoneController.text = client['ownerPhone']?.replaceAll('+91-', '') ?? '';
      _emailController.text = client['email'] ?? '';
      _gstController.text = client['gstNumber'] ?? '';
      selectedClientType = client['type'];

      // Parse location
      if (client['location'] != null) {
        final locationParts = client['location'].split(', ');
        if (locationParts.length == 2) {
          selectedCity = locationParts[0];
          selectedState = locationParts[1];
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PostClientAddBloc, PostClientAddState>(
      listener: (context, state) {
        if (state is PostClientAddLoading && state.showLoader) {
          showCustomProgressDialog(context);
        } else if (state is PostClientAddLoaded) {
          dismissCustomProgressDialog(context);

          if (state.response.status == true) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(widget.existingClient != null
                    ? 'Client updated successfully'
                    : 'Client added successfully'),
                backgroundColor: AppColors.success,
              ),
            );
            Navigator.pop(context, true); // Return true to refresh the list
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.response.message ?? 'Failed to save client'),
                backgroundColor: AppColors.error,
              ),
            );
          }
        } else if (state is PostClientAddError) {
          dismissCustomProgressDialog(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.backgroundLight,
        appBar:
        // _buildAppBar(),
        PreferredSize(
            preferredSize: const Size.fromHeight(56),
            child: CoolAppCard(title: widget.existingClient != null ? 'Edit Client' : 'Add Client',backgroundColor: SessionManager.getUserRole() =="superadmin"?AppColors.superAdminPrimary:SessionManager.getUserRole() =="admin"?
            AppColors.adminPrimaryDark :AppColors.primaryTealDark,)
        ),
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
                      _buildSection(
                        'BASIC INFO',
                        [
                          _buildClientTypeDropdown(),
                          const SizedBox(height: 10),
                          // _buildTextField('Client name', _clientNameController, isRequired: true),
                          // const SizedBox(height: 16),
                          _buildTextField('Firm / company name', _firmNameController, isRequired: true),
                          const SizedBox(height: 10),
                          _buildTextField('Trader name (optional)', _traderNameController),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _buildSection(
                        'LOCATION',
                        [
                          _buildTextField('Location Name', _locationNameController,isRequired: true),
                          const SizedBox(height: 10),
                          _buildTextField('State', _stateController,isRequired: true),
                          // _buildCityDropdown(),
                          const SizedBox(height: 10),
                          _buildTextField('City', _cityController,isRequired: true),
                          // _buildStateDropdown(),
                          const SizedBox(height: 10),
                          _buildLocationField(),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _buildSection(
                        'CONTACT & OTHER',
                        [
                          _buildTextField('Owner name', _ownerNameController, isRequired: true),
                          const SizedBox(height: 10),
                          _buildPhoneField(),
                          const SizedBox(height: 10),
                          _buildTextField('Email', _emailController, keyboardType: TextInputType.emailAddress),
                          const SizedBox(height: 10),
                          _buildTextField('GST No (optional)', _gstController),
                          const SizedBox(height: 10),
                          _buildSocialHandlesSection(),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _buildInfoBanner(),
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



  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildClientTypeDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Text(
              'Client type',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(width: 4),
            Text('*', style: TextStyle(color: AppColors.error)),
          ],
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: selectedClientType,
          decoration: InputDecoration(
            hintText: 'Select client type',
            suffixIcon: const Icon(Icons.keyboard_arrow_down),
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
          items: clientTypes.map((type) {
            return DropdownMenuItem(
              value: type,
              child: Text(type),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              selectedClientType = value;
            });
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select client type';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildCityDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Text(
              'City',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(width: 4),
            Text('*', style: TextStyle(color: AppColors.error)),
          ],
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: selectedCity,
          decoration: InputDecoration(
            hintText: 'Select city',
            suffixIcon: const Icon(Icons.keyboard_arrow_down),
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
          items: cities.map((city) {
            return DropdownMenuItem(
              value: city,
              child: Text(city),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              selectedCity = value;
            });
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select city';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildStateDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Text(
              'State',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(width: 4),
            Text('*', style: TextStyle(color: AppColors.error)),
          ],
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: selectedState,
          decoration: InputDecoration(
            hintText: 'Select state',
            suffixIcon: const Icon(Icons.keyboard_arrow_down),
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
          items: states.map((state) {
            return DropdownMenuItem(
              value: state,
              child: Text(state),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              selectedState = value;
            });
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select state';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildLocationField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Location coordinates',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.grey50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.grey300),
          ),
          child: Row(
            children: [
              const Icon(Icons.location_on, color: AppColors.primaryTeal, size: 20),
              const SizedBox(width: 8),
              Text(
                currentLocation,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Text(
              'Phone',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(width: 4),
            Text('*', style: TextStyle(color: AppColors.error)),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          maxLength: 10,
          decoration: InputDecoration(
            counterText: "",
            hintText: 'Phone number',
            prefixText: '+91 ',
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
              return 'Please enter phone number';
            }
            if (value.length != 10) {
              return 'Please enter valid 10-digit phone number';
            }
            return null;
          },
          onChanged: (value) {
            _checkForDuplicates();
          },
        ),
      ],
    );
  }

  Widget _buildSocialHandlesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Social handles (optional)',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _instagramController,
                decoration: InputDecoration(
                  labelText: 'IG',
                  hintText: '@username',
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
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _facebookController,
                decoration: InputDecoration(
                  labelText: 'FB',
                  hintText: 'Page name',
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
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _websiteController,
          decoration: InputDecoration(
            labelText: 'Web',
            hintText: 'Website URL',
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

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    bool isRequired = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            if (isRequired) ...[
              const SizedBox(width: 4),
              const Text('*', style: TextStyle(color: AppColors.error)),
            ],
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: label,
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
          validator: isRequired ? (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter ${label.toLowerCase()}';
            }
            return null;
          } : null,
          onChanged: (value) {
            if (label.contains('name') || label.contains('GST') || label.contains('email')) {
              _checkForDuplicates();
            }
          },
        ),
      ],
    );
  }

  Widget _buildInfoBanner() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.accentAmber.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.accentAmber.withValues(alpha: 0.3)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline,
            color: AppColors.accentAmber,
            size: 20,
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'App will check for duplicate client using firm name, GST, phone and email.',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.accentAmber,
              ),
            ),
          ),
        ],
      ),
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
            onPressed: _saveClient,
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
            child: Text(
              widget.existingClient != null ? 'Update Client' : 'Save Client',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _checkForDuplicates() {
    // Simulate duplicate checking logic
    final firmName = _firmNameController.text.toLowerCase();
    final phone = _phoneController.text;
    final email = _emailController.text.toLowerCase();

    // Check against some mock existing clients
    final existingClients = ['a class stone', 'patwari marble', 'sangam granites'];
    final existingPhones = ['9876543210', '9987654321'];
    final existingEmails = ['contact@aclassstone.com', 'info@patwarimarble.com'];

    setState(() {
      showDuplicateWarning = existingClients.contains(firmName) ||
                           existingPhones.contains(phone) ||
                           existingEmails.contains(email);
    });

    if (showDuplicateWarning) {
      _showDuplicateDialog();
    }
  }

  void _showDuplicateDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Potential Duplicate Found',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Similar clients found:',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.grey50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'A Class Stone',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    Text(
                      'Builder · Jaipur, Rajasthan',
                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                    Text(
                      '+91-9876543210',
                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Continue Anyway',
                style: TextStyle(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // You can add logic to prefill with existing client data
              },
              child: const Text(
                'Use Existing',
                style: TextStyle(
                  color: AppColors.primaryTeal,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _saveClient() {
    if (_formKey.currentState!.validate()) {
      // Validate required fields
      if (selectedClientType == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select client type'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }

      // if (selectedCity == null) {
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     const SnackBar(
      //       content: Text('Please select city'),
      //       backgroundColor: AppColors.error,
      //     ),
      //   );
      //   return;
      // }
      //
      // if (selectedState == null) {
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     const SnackBar(
      //       content: Text('Please select state'),
      //       backgroundColor: AppColors.error,
      //     ),
      //   );
      //   return;
      // }

      // Prepare the request body
      final requestBody = PostClientAddRequestBody(
        clientTypeCode: _getClientTypeCode(selectedClientType!),
        firmName: _firmNameController.text.trim(),
        gstn: _gstController.text.trim().isEmpty ? "" : _gstController.text.trim(),
        traderName: _traderNameController.text.trim().isEmpty ? "" : _traderNameController.text.trim(),
        facebookUrl: _facebookController.text.trim().isEmpty ? "" : _facebookController.text.trim(),
        instagramUrl: _instagramController.text.trim().isEmpty ? "" : _instagramController.text.trim(),
        twitterUrl: _websiteController.text.trim().isEmpty ? "" : _websiteController.text.trim(),
        initialLocation: InitialLocation(
          locationName: _locationNameController.text.toString(), // Default location name
          state: _stateController.text.trim().isEmpty ? "" : _stateController.text.trim(),
          city: _cityController.text.trim().isEmpty ? "" : _cityController.text.trim(),
          gpsLat: _gpsLat,
          gpsLng: _gpsLng,
        ),
        ownerContact: OwnerContact(
          name: _ownerNameController.text.trim(),
          phone: _phoneController.text.trim(),
          email: _emailController.text.trim().isEmpty ? "" : _emailController.text.trim(),
        ),
      );

      // Dispatch the event
      context.read<PostClientAddBloc>().add(
        FetchPostClientAdd(
          showLoader: true,
          requestBody: requestBody,
        ),
      );
    }
  }

  @override
  void dispose() {
    _clientNameController.dispose();
    _firmNameController.dispose();
    _traderNameController.dispose();
    _ownerNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _gstController.dispose();
    _instagramController.dispose();
    _facebookController.dispose();
    _websiteController.dispose();
    super.dispose();
  }
}
