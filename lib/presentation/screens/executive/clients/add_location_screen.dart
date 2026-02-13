import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';

import '../../../../api/models/request/PostClientAddContactRequestBody.dart';
import '../../../../api/models/request/PostClientAddLocationRequestBody.dart';
import '../../../../bloc/client/post_client/post_client_bloc.dart';
import '../../../../bloc/client/post_client/post_client_event.dart';
import '../../../../bloc/client/post_client/post_client_state.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/session/session_manager.dart';
import '../../../widgets/app_bar.dart';
import '../../../widgets/custom_loader.dart';

class AddLocationScreen extends StatefulWidget {
  final String clientId;
  final String? locationIdToAddContact; // If provided, skip location and go to contact

  const AddLocationScreen({
    super.key,
    required this.clientId,
    this.locationIdToAddContact,
  });

  @override
  State<AddLocationScreen> createState() => _AddLocationScreenState();
}

class _AddLocationScreenState extends State<AddLocationScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _locationNameController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();

  double? _gpsLat;
  double? _gpsLng;
  String currentLocation = 'Fetching location...';

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _locationNameController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    super.dispose();
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
        currentLocation =
            '${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}';
      });
    } catch (e) {
      setState(() {
        currentLocation = 'Unable to get location';
      });
    }
  }

  void _saveLocation() {
    if (_formKey.currentState!.validate()) {
      final requestBody = PostClientAddLocationRequestBody(
        locationName: _locationNameController.text.trim(),
        state: _stateController.text.trim(),
        city: _cityController.text.trim(),
        gpsLat: _gpsLat,
        gpsLng: _gpsLng,
      );

      context.read<PostClientAddLocationBloc>().add(
            FetchPostClientAddLocation(
              showLoader: true,
              requestBody: requestBody,
              clientId: widget.clientId,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = SessionManager.getUserRole() == "superadmin"
        ? AppColors.superAdminPrimary
        : SessionManager.getUserRole() == "admin"
            ? AppColors.adminPrimary
            : AppColors.primaryTealDark;

    return BlocListener<PostClientAddLocationBloc, PostClientAddLocationState>(
      listener: (context, state) {
        if (state is PostClientAddLocationLoading && state.showLoader) {
          showCustomProgressDialog(context, title: 'Adding location...');
        } else if (state is PostClientAddLocationLoaded) {
          dismissCustomProgressDialog(context);

          if (state.response.status == true) {
            // Get the newly created location ID from response
            final locationId = state.response.data?.id;

            if (locationId != null) {
              // Navigate to add contact screen using push (not pushReplacement)
              // This keeps the bloc providers alive
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MultiBlocProvider(
                    providers: [
                      BlocProvider.value(
                        value: context.read<PostClientAddContactBloc>(),
                      ),
                      BlocProvider.value(
                        value: context.read<PostClientAddLocationBloc>(),
                      ),
                    ],
                    child: AddContactScreen(
                      clientId: widget.clientId,
                      locationId: locationId,
                    ),
                  ),
                ),
              ).then((shouldGoBack) {
                // When contact screen is done, go back to client details
                if (shouldGoBack == true) {
                  Navigator.pop(context, true);
                }
              });
            } else {
              // If no location ID, just go back
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Location added successfully'),
                  backgroundColor: AppColors.success,
                ),
              );
              Navigator.pop(context, true);
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.response.message ?? 'Failed to add location'),
                backgroundColor: AppColors.error,
              ),
            );
          }
        } else if (state is PostClientAddLocationError) {
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
        appBar: const PreferredSize(
          preferredSize: Size.fromHeight(56),
          child: CoolAppCard(title: 'Add Location'),
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
                      _buildTextField(
                        'Location Name',
                        _locationNameController,
                        isRequired: true,
                        hint: 'e.g., Head Office, Branch Office',
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        'State',
                        _stateController,
                        isRequired: true,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        'City',
                        _cityController,
                        isRequired: true,
                      ),
                      const SizedBox(height: 16),
                      _buildLocationField(),
                      const SizedBox(height: 24),
                      _buildInfoBanner(),
                    ],
                  ),
                ),
              ),
              _buildBottomButtons(primaryColor),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    bool isRequired = false,
    String? hint,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label + (isRequired ? ' *' : ''),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint ?? 'Enter $label',
            filled: true,
            fillColor: AppColors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.grey300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.grey300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primaryTealDark, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          validator: isRequired
              ? (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '$label is required';
                  }
                  return null;
                }
              : null,
        ),
      ],
    );
  }

  Widget _buildLocationField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'GPS Location',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.grey100,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.grey300),
          ),
          child: Row(
            children: [
              const Icon(Icons.location_on, color: AppColors.primaryTealDark, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  currentLocation,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              IconButton(
                onPressed: _getCurrentLocation,
                icon: const Icon(Icons.refresh, size: 20),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
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
        children: [
          Icon(Icons.info_outline, color: AppColors.accentAmber, size: 20),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'After adding location, you can add contacts for this location',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButtons(Color primaryColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _saveLocation,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Continue to Add Contact',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Add Contact Screen
class AddContactScreen extends StatefulWidget {
  final String clientId;
  final String locationId;

  const AddContactScreen({
    super.key,
    required this.clientId,
    required this.locationId,
  });

  @override
  State<AddContactScreen> createState() => _AddContactScreenState();
}

class _AddContactScreenState extends State<AddContactScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  String? selectedRole;

  final List<String> contactRoles = [
    'OWNER',
    'MANAGER',
    'ACCOUNTANT',
    'SALES',
    'OTHER',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _saveContact() {
    if (_formKey.currentState!.validate()) {
      if (selectedRole == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select contact role'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }

      final requestBody = PostClientAddContactRequestBody(
        contactRole: selectedRole,
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
      );

      // Read the bloc before using it in the event
      final contactBloc = context.read<PostClientAddContactBloc>();

      contactBloc.add(
        FetchPostClientAddContact(
          showLoader: true,
          requestBody: requestBody,
          clientId: widget.clientId,
          locationId: widget.locationId,
        ),
      );
    }
  }

  void _skipContact() {
    Navigator.pop(context, true); // Return to AddLocationScreen
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = SessionManager.getUserRole() == "superadmin"
        ? AppColors.superAdminPrimary
        : SessionManager.getUserRole() == "admin"
            ? AppColors.adminPrimary
            : AppColors.primaryTealDark;

    return BlocListener<PostClientAddContactBloc, PostClientAddContactState>(
      listener: (context, state) {
        if (state is PostClientAddContactLoading && state.showLoader) {
          showCustomProgressDialog(context, title: 'Adding contact...');
        } else if (state is PostClientAddContactLoaded) {
          dismissCustomProgressDialog(context);

          if (state.response.status == true) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Contact added successfully'),
                backgroundColor: AppColors.success,
              ),
            );

            // Ask if user wants to add another contact
            _showAddAnotherContactDialog();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.response.message ?? 'Failed to add contact'),
                backgroundColor: AppColors.error,
              ),
            );
          }
        } else if (state is PostClientAddContactError) {
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
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: CoolAppCard(title: 'Add Contact',backgroundColor: SessionManager.getUserRole() =="superadmin"?AppColors.superAdminPrimary:SessionManager.getUserRole() =="admin"?
          AppColors.adminPrimaryDark :AppColors.primaryTealDark),
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
                      _buildRoleDropdown(),
                      const SizedBox(height: 16),
                      _buildTextField(
                        'Contact Name',
                        _nameController,
                        isRequired: true,
                      ),
                      const SizedBox(height: 16),
                      _buildPhoneField(),
                      const SizedBox(height: 16),
                      _buildTextField(
                        'Email (optional)',
                        _emailController,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 24),
                      _buildInfoBanner(),
                    ],
                  ),
                ),
              ),
              _buildBottomButtons(primaryColor),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Contact Role *',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: selectedRole,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.grey300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.grey300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primaryTealDark, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          hint: const Text('Select role'),
          items: contactRoles.map((role) {
            return DropdownMenuItem(
              value: role,
              child: Text(role),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              selectedRole = value;
            });
          },
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
        Text(
          label + (isRequired ? ' *' : ''),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: 'Enter $label',
            filled: true,
            fillColor: AppColors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.grey300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.grey300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primaryTealDark, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          validator: isRequired
              ? (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '$label is required';
                  }
                  return null;
                }
              : null,
        ),
      ],
    );
  }

  Widget _buildPhoneField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Phone Number *',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          maxLength: 10,
          decoration: InputDecoration(
            hintText: 'Enter phone number',
            filled: true,
            fillColor: AppColors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.grey300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.grey300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primaryTealDark, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            counterText: '',
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Phone number is required';
            }
            if (value.trim().length != 10) {
              return 'Phone number must be 10 digits';
            }
            return null;
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
        children: [
          Icon(Icons.info_outline, color: AppColors.accentAmber, size: 20),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'You can add multiple contacts for this location',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButtons(Color primaryColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _skipContact,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: BorderSide(color: primaryColor),
                ),
                child: Text(
                  'Skip',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: primaryColor,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: _saveContact,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Save Contact',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddAnotherContactDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Contact Added',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const Text('Would you like to add another contact for this location?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Close dialog
                // Pop twice: once for AddContactScreen, once for AddLocationScreen
                // This will return to client details with refresh
                Navigator.of(context).pop(true); // Go back to AddLocationScreen
                Navigator.of(context).pop(true); // Go back to client details
              },
              child: const Text('No, Go Back'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Close dialog
                // Reset form for new contact
                if (mounted) {
                  setState(() {
                    _nameController.clear();
                    _phoneController.clear();
                    _emailController.clear();
                    selectedRole = null;
                  });
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: SessionManager.getUserRole() == "superadmin"
                    ? AppColors.superAdminPrimary
                    : SessionManager.getUserRole() == "admin"
                        ? AppColors.adminPrimary
                        : AppColors.primaryTealDark,
              ),
              child: const Text('Yes, Add Another'),
            ),
          ],
        );
      },
    );
  }
}

