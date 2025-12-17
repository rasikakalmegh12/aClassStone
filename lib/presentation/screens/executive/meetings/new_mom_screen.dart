import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';

import '../../../../core/constants/app_colors.dart';

class NewMomScreen extends StatefulWidget {
  const NewMomScreen({super.key});

  @override
  State<NewMomScreen> createState() => _NewMomScreenState();
}

class _NewMomScreenState extends State<NewMomScreen> {
  final _formKey = GlobalKey<FormState>();

  // Form Controllers
  final _clientController = TextEditingController();
  final _contactController = TextEditingController();
  final _otherNameController = TextEditingController();
  final _otherDesignationController = TextEditingController();
  final _otherPhoneController = TextEditingController();
  final _otherEmailController = TextEditingController();
  final _notesController = TextEditingController();
  final _followUpDateController = TextEditingController();
  final _followUpTimeController = TextEditingController();

  // Form State
  String? selectedClient;
  String? selectedContact;
  String? selectedMeetingType;
  String contactType = 'existing';
  bool discussedProduct = false;
  bool priceInquiry = false;
  bool sampleRequested = false;
  bool followUpRequired = false;
  bool needsFollowUp = false;
  List<File> photos = [];
  String currentLocation = 'Captured automatically';

  final List<String> clients = [
    'A Class Stone',
    'Patwari Marble',
    'Sangam Granites',
    'New Client',
  ];

  final List<String> contacts = [
    'Jitendra S.',
    'Rajkumar P.',
    'Priya M.',
  ];

  final List<String> meetingTypes = [
    'First Introduction',
    'Follow-up',
    'Negotiation',
    'Product Demo',
    'Site Visit',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: _buildAppBar(),
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
                      'CLIENT & LOCATION',
                      [
                        _buildClientSelector(),
                        const SizedBox(height: 16),
                        _buildLocationField(),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildSection(
                      'CONTACT',
                      [
                        _buildContactSelector(),
                        if (contactType == 'other') ...[
                          const SizedBox(height: 16),
                          _buildOtherContactFields(),
                        ],
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildSection(
                      'MEETING DETAILS',
                      [
                        _buildMeetingTypeSelector(),
                        const SizedBox(height: 16),
                        _buildChecklist(),
                        const SizedBox(height: 16),
                        _buildNotesField(),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildSection(
                      'ATTACHMENTS & FOLLOW-UP',
                      [
                        _buildPhotoSection(),
                        const SizedBox(height: 16),
                        _buildFollowUpSection(),
                      ],
                    ),
                    const SizedBox(height: 100), // Space for bottom bar
                  ],
                ),
              ),
            ),
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.white,
      elevation: 1,
      shadowColor: AppColors.grey200,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
      ),
      title: Text(
        'New Meeting / MOM',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
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
          style: TextStyle(
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

  Widget _buildClientSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Client',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: 4),
            const Text('*', style: TextStyle(color: AppColors.error)),
          ],
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: selectedClient,
          decoration: InputDecoration(
            hintText: 'Select Client',
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
          items: clients.map((client) {
            return DropdownMenuItem(
              value: client,
              child: Text(client),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              selectedClient = value;
            });
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select a client';
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
        Text(
          'Location',
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
                style: TextStyle(
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

  Widget _buildContactSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Contact person',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: 4),
            const Text('*', style: TextStyle(color: AppColors.error)),
          ],
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: selectedContact,
          decoration: InputDecoration(
            hintText: 'Select Contact',
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
          items: [...contacts, 'Other'].map((contact) {
            return DropdownMenuItem(
              value: contact,
              child: Text(contact),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              selectedContact = value;
              contactType = value == 'Other' ? 'other' : 'existing';
            });
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select a contact';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildOtherContactFields() {
    return Column(
      children: [
        _buildTextField('Name', _otherNameController, isRequired: true),
        const SizedBox(height: 12),
        _buildTextField('Designation', _otherDesignationController),
        const SizedBox(height: 12),
        _buildTextField('Phone', _otherPhoneController, keyboardType: TextInputType.phone, prefix: '+91'),
        const SizedBox(height: 12),
        _buildTextField('Email', _otherEmailController, keyboardType: TextInputType.emailAddress),
      ],
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    bool isRequired = false,
    TextInputType keyboardType = TextInputType.text,
    String? prefix,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: TextStyle(
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
            prefixText: prefix,
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
              return 'Please enter $label';
            }
            return null;
          } : null,
        ),
      ],
    );
  }

  Widget _buildMeetingTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Meeting type',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: 4),
            const Text('*', style: TextStyle(color: AppColors.error)),
          ],
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: selectedMeetingType,
          decoration: InputDecoration(
            hintText: 'First Introduction',
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
          items: meetingTypes.map((type) {
            return DropdownMenuItem(
              value: type,
              child: Text(type),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              selectedMeetingType = value;
            });
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select meeting type';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildChecklist() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Checklist',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        _buildCheckboxItem('Discussed product', discussedProduct, (value) {
          setState(() {
            discussedProduct = value!;
          });
        }),
        _buildCheckboxItem('Price inquiry', priceInquiry, (value) {
          setState(() {
            priceInquiry = value!;
          });
        }),
        _buildCheckboxItem('Sample requested', sampleRequested, (value) {
          setState(() {
            sampleRequested = value!;
          });
        }),
        _buildCheckboxItem('Follow-up required', followUpRequired, (value) {
          setState(() {
            followUpRequired = value!;
          });
        }),
      ],
    );
  }

  Widget _buildCheckboxItem(String title, bool value, Function(bool?) onChanged) {
    return Row(
      children: [
        Checkbox(
          value: value,
          onChanged: onChanged,
          activeColor: AppColors.primaryTeal,
        ),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNotesField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Notes',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _notesController,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'Meeting notes...',
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

  Widget _buildPhotoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Photos (max 3)',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            GestureDetector(
              onTap: _addPhoto,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.grey300, style: BorderStyle.solid),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add, color: AppColors.textLight),
                    Text('Add Photo', style: TextStyle(fontSize: 10, color: AppColors.textLight)),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            ...photos.asMap().entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Stack(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(
                          image: FileImage(entry.value),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: () => _removePhoto(entry.key),
                        child: const Icon(Icons.close, color: AppColors.error, size: 20),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ],
    );
  }

  Widget _buildFollowUpSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Follow-up required',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Row(
              children: [
                Radio<bool>(
                  value: false,
                  groupValue: needsFollowUp,
                  onChanged: (value) {
                    setState(() {
                      needsFollowUp = value!;
                    });
                  },
                  activeColor: AppColors.primaryTeal,
                ),
                Text(
                  'No',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 24),
            Row(
              children: [
                Radio<bool>(
                  value: true,
                  groupValue: needsFollowUp,
                  onChanged: (value) {
                    setState(() {
                      needsFollowUp = value!;
                    });
                  },
                  activeColor: AppColors.primaryTeal,
                ),
                Text(
                  'Yes',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ],
        ),
        if (needsFollowUp) ...[
          const SizedBox(height: 16),
          Text(
            'Reminder',
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
                child: _buildTextField('Date', _followUpDateController),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField('Time', _followUpTimeController),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildBottomBar() {
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
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _saveOffline,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textSecondary,
                  side: const BorderSide(color: AppColors.grey300),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Save Offline',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: _submitMom,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryTeal,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Submit MOM',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addPhoto() async {
    // Placeholder for image picker functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Photo capture will be implemented'),
        backgroundColor: AppColors.primaryTeal,
      ),
    );
  }

  void _removePhoto(int index) {
    setState(() {
      photos.removeAt(index);
    });
  }

  void _saveOffline() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Meeting saved offline'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _submitMom() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Meeting submitted successfully'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _clientController.dispose();
    _contactController.dispose();
    _otherNameController.dispose();
    _otherDesignationController.dispose();
    _otherPhoneController.dispose();
    _otherEmailController.dispose();
    _notesController.dispose();
    _followUpDateController.dispose();
    _followUpTimeController.dispose();
    super.dispose();
  }
}
