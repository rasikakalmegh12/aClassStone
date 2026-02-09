import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:io';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../api/models/request/PostMomEntryRequestBody.dart';
import '../../../../bloc/client/get_client/get_client_bloc.dart';
import '../../../../bloc/client/get_client/get_client_event.dart';
import '../../../../bloc/client/get_client/get_client_state.dart';
import '../../../../bloc/mom/mom_bloc.dart';
import '../../../../bloc/mom/mom_event.dart';
import '../../../../bloc/mom/mom_state.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../widgets/app_bar.dart';
import '../../../widgets/autocomplete_container.dart';
import '../../../widgets/dropdown_widget.dart';

// ContactOption class to hold contact details
class ContactOption {
  final String id;
  final String name;
  final String phone;
  final String locationName;

  ContactOption({
    required this.id,
    required this.name,
    required this.phone,
    required this.locationName,
  });
}

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
  String? selectedContactId;
  String? selectedMeetingType;
  String contactType = 'existing';
  bool discussedProduct = false;
  bool priceInquiry = false;
  bool sampleRequested = false;
  bool followUpRequired = false;
  bool needsFollowUp = false;
  List<File> photos = [];
  List<DropdownOption> clientOptions = [];
  List<ContactOption> contactOptions = [];
  String? selectedClientId;
  String currentLocation = 'Fetching location...';
  double? currentLat;
  double? currentLng;
  final List<File> _capturedImages = [];
  bool _isUploadingImages = false;


  final List<Map<String, String>> meetingTypes = [
    {'display': 'First Introduction', 'value': 'FIRST_INTRO'},
    {'display': 'Follow-up', 'value': 'FOLLOW_UP'},
    {'display': 'Negotiation', 'value': 'NEGOTIATION'},
    {'display': 'Product Demo', 'value': 'PRODUCT_DEMO'},
    {'display': 'Sample Display', 'value': 'SAMPLE_DISPLAY'},
    {'display': 'Site Visit', 'value': 'SITE_VISIT'},
    {'display': 'Project Discussion', 'value': 'PROJECT_DISCUSSION'},
  ];

// Replace checklistNotes map
  Map<String, TextEditingController> checklistNotes = {
    'INTRO_OBJECTIVE': TextEditingController(),
    'PRODUCT': TextEditingController(),
    'PRICE': TextEditingController(),
    'DEALERSHIP': TextEditingController(),
    'COMMISSION': TextEditingController(),
    'PAYMENT_TERMS': TextEditingController(),
    'RELATIONS_REFERRALS': TextEditingController(),
  };


  bool introObjective = false;
  bool product = false;
  bool price = false;
  bool dealership = false;
  bool commission = false;
  bool paymentTerms = false;
  bool relationsReferrals = false;
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



  @override
  void initState() {
    super.initState();
    context.read<GetClientListBloc>().add(FetchGetClientList());
    _captureLocation();
  }

  Future<void> _captureLocation() async {
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
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        currentLat = position.latitude;
        currentLng = position.longitude;
        currentLocation = 'Lat: ${position.latitude.toStringAsFixed(6)}, Lng: ${position.longitude.toStringAsFixed(6)}';
      });
    } catch (e) {
      setState(() {
        currentLocation = 'Could not get location';
      });
      if (kDebugMode) {
        print('❌ Error capturing location: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PostMomEntryBloc, PostMomEntryState>(
        listener: (context, state) async {
          if (state is PostMomEntryLoading && state.showLoader) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (_) => const Center(child: CircularProgressIndicator()),
            );
          }

          if (state is PostMomEntrySuccess) {
            final momId = state.response.data!.momId;

            if (_capturedImages.isNotEmpty) {
              await _uploadMomImages(state.response.data!.id!);
            }

            Navigator.of(context, rootNavigator: true).pop(); // close loader
            Navigator.pop(context, true); // SUCCESS POP
          }

          if (state is PostMomEntryError) {
            Navigator.of(context, rootNavigator: true).pop();
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          return Scaffold(

          backgroundColor: AppColors.backgroundLight,
      appBar:
      PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: CoolAppCard(title: "New MOM Entry",)
      ),
      // _buildAppBar(),
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
                        BlocBuilder<GetClientListBloc, GetClientListState>(
                          builder: (context, state) {
                            if (kDebugMode) {
                              print('🔄 clientOptions state: ${state.runtimeType}');
                            }
                            if (state is GetClientListLoading && state.showLoader) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                            if (state is GetClientListLoaded) {
                              if (state.response.data != null && state.response.data!.isNotEmpty) {
                                clientOptions = state.response.data!
                                    .where((item) => item.id != null && item.firmName != null && item.firmName!.isNotEmpty)
                                    .map((item) => DropdownOption(
                                  id: item.id!,
                                  name: item.firmName!,
                                  code: item.city,
                                ))
                                    .toList();

                                if (kDebugMode) {
                                  print('✅ Mines loaded: ${clientOptions.length} mines');
                                }
                              }
                              return CustomAutocompleteSection(
                                title: 'Clients *',
                                options: clientOptions,
                                selectedId: selectedClientId,
                                onSelected: (id, name) {
                                  setState(() {
                                    selectedClientId = id;
                                  });
                                },
                                icon: Icons.landscape_outlined,
                                showTrailing: true,

                              );
                              // return CustomDropdownSection(
                              //   title: 'Mines *',
                              //   options: mineOptions,
                              //   selectedId: selectedMineId,
                              //   onChanged: (id, name) {
                              //     setState(() {
                              //       selectedMineId = id;
                              //     });
                              //   },
                              //   icon: Icons.landscape_outlined,
                              //   extraFeature: true,
                              //   widget: IconButton(
                              //       color:  SessionManager.getUserRole().toString().toLowerCase() == "superadmin"
                              //           ? AppColors.superAdminPrimary
                              //           : AppColors.primaryDeepBlue,
                              //       onPressed: () {
                              //     _openAddMineBottomSheet(context);
                              //     if (kDebugMode) {
                              //       print("🔧 Opening Add Mine Bottom Sheet");
                              //     }
                              //   }, icon:
                              //    const Icon(Icons.add)),
                              // );
                            } else if (state is GetClientListError) {
                              if (kDebugMode) {
                                print('❌ Error loading mines: ${state.message}');
                              }
                              return _buildErrorContainer('mines', state.message);
                            }
                            return CustomAutocompleteSection(
                              title: 'Mines *',
                              options: clientOptions,
                              selectedId: selectedClientId,
                              onSelected: (id, name) {
                                setState(() {
                                  selectedClientId = id;
                                });
                              },
                              icon: Icons.landscape_outlined,
                              showTrailing: true,

                            );
                            // Default state - show dropdown with current options
                            // return CustomDropdownSection(
                            //   title: 'Mines *',
                            //   options: mineOptions,
                            //   selectedId: selectedMineId,
                            //   onChanged: (id, name) {
                            //     setState(() {
                            //       selectedMineId = id;
                            //     });
                            //   },
                            //   icon: Icons.landscape_outlined,
                            //   extraFeature: true,
                            //   widget: IconButton(
                            //       color:  SessionManager.getUserRole().toString().toLowerCase() == "superadmin"
                            //           ? AppColors.superAdminPrimary
                            //           : AppColors.primaryDeepBlue,
                            //       onPressed: () {
                            //     _openAddMineBottomSheet(context);
                            //     if (kDebugMode) {
                            //       print("🔧 Opening Add Mine Bottom Sheet");
                            //     }
                            //   }, icon:
                            //    const Icon(Icons.add)),
                            // );
                          },
                        ),
                        // _buildClientSelector(),
                        const SizedBox(height: 16),
                        _buildLocationField(),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildSection(
                      'CONTACT',
                      [
                        _buildContactSelectorWithClientDetails(),
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
                        // _buildAddPhotoTile(),
                        _buildCapturedImages(),
                        // _buildPhotoSection(),
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
  });}

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.white,
      elevation: 1,
      shadowColor: AppColors.grey200,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
      ),
      title: const Text(
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

  Widget _buildContactSelectorWithClientDetails() {
    if (selectedClientId == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text(
                'Contact person',
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
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.grey50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.grey300),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: AppColors.textSecondary, size: 20),
                SizedBox(width: 8),
                Text(
                  'Please select a client first',
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

    return BlocProvider(
      create: (context) => GetClientDetailsBloc()
        ..add(FetchGetClientDetails(clientId: selectedClientId!, showLoader: false)),
      child: BlocConsumer<GetClientDetailsBloc, GetClientDetailsState>(
        listener: (context, state) {
          if (state is GetClientDetailsLoaded) {
            if (kDebugMode) {
              print('✅ Client details loaded');
            }
            // Populate contact options from all locations
            setState(() {
              contactOptions = [];
              if (state.response.data?.locations != null) {
                for (var location in state.response.data!.locations!) {
                  if (location.contacts != null) {
                    for (var contact in location.contacts!) {
                      if (contact.name != null && contact.phone != null) {
                        contactOptions.add(ContactOption(
                          id: contact.id ?? '',
                          name: contact.name!,
                          phone: contact.phone!,
                          locationName: location.locationName ?? '',
                        ));
                      }
                    }
                  }
                }
              }
            });
          } else if (state is GetClientDetailsError) {
            if (kDebugMode) {
              print('❌ Error loading client details: ${state.message}');
            }
          }
        },
        builder: (context, state) {
          if (state is GetClientDetailsLoading && state.showLoader) {
            return const Column(
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
                    SizedBox(width: 4),
                    Text('*', style: TextStyle(color: AppColors.error)),
                  ],
                ),
                SizedBox(height: 8),
                Center(child: CircularProgressIndicator()),
              ],
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Text(
                    'Contact person',
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

              if (contactOptions.isEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.grey50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.grey300),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline, color: AppColors.textSecondary, size: 20),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'No contacts found for this client',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              else
                Autocomplete<ContactOption>(
                  optionsBuilder: (TextEditingValue textEditingValue) {
                    if (textEditingValue.text.isEmpty) {
                      return contactOptions;
                    }
                    return contactOptions.where((ContactOption option) {
                      return option.name
                              .toLowerCase()
                              .contains(textEditingValue.text.toLowerCase()) ||
                          option.phone.contains(textEditingValue.text);
                    });
                  },
                  displayStringForOption: (ContactOption option) =>
                      '${option.name} - ${option.phone}',
                  onSelected: (ContactOption selection) {
                    setState(() {
                      selectedContactId = selection.id;
                      selectedContact = selection.name;
                      contactType = 'existing';
                    });
                    if (kDebugMode) {
                      print('✅ Selected contact: ${selection.name} - ${selection.phone}');
                    }
                  },
                  fieldViewBuilder: (BuildContext context,
                      TextEditingController textEditingController,
                      FocusNode focusNode,
                      VoidCallback onFieldSubmitted) {
                    return TextFormField(
                      controller: textEditingController,
                      focusNode: focusNode,
                      decoration: InputDecoration(
                        hintText: 'Search contact by name or phone',
                        prefixIcon: const Icon(Icons.person_outline),
                        suffixIcon: textEditingController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  textEditingController.clear();
                                  setState(() {
                                    selectedContactId = null;
                                    selectedContact = null;
                                  });
                                },
                              )
                            : const Icon(Icons.keyboard_arrow_down),
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
                        if (selectedContactId == null || selectedContactId!.isEmpty) {
                          return 'Please select a contact';
                        }
                        return null;
                      },
                    );
                  },

                ),
            ],
          );
        },
      ),
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
        const Row(
          children: [
            Text(
              'Meeting type',
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
          value: selectedMeetingType,
          decoration: InputDecoration(
            hintText: 'Select meeting type',
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
              value: type['value'],
              child: Text(type['display']!),
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
        const Text(
          'Checklist',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),

        _buildCheckboxItemWithNote(
          'Introduction & Objective',
          'INTRO_OBJECTIVE',
          introObjective,
              (value) {
            setState(() {
              introObjective = value!;
              if (!value) checklistNotes['INTRO_OBJECTIVE']?.clear();
            });
          },
        ),

        _buildCheckboxItemWithNote(
          'Product Discussion',
          'PRODUCT',
          product,
              (value) {
            setState(() {
              product = value!;
              if (!value) checklistNotes['PRODUCT']?.clear();
            });
          },
        ),

        _buildCheckboxItemWithNote(
          'Price Inquiry',
          'PRICE',
          price,
              (value) {
            setState(() {
              price = value!;
              if (!value) checklistNotes['PRICE']?.clear();
            });
          },
        ),

        _buildCheckboxItemWithNote(
          'Dealership',
          'DEALERSHIP',
          dealership,
              (value) {
            setState(() {
              dealership = value!;
              if (!value) checklistNotes['DEALERSHIP']?.clear();
            });
          },
        ),

        _buildCheckboxItemWithNote(
          'Commission',
          'COMMISSION',
          commission,
              (value) {
            setState(() {
              commission = value!;
              if (!value) checklistNotes['COMMISSION']?.clear();
            });
          },
        ),

        _buildCheckboxItemWithNote(
          'Payment Terms',
          'PAYMENT_TERMS',
          paymentTerms,
              (value) {
            setState(() {
              paymentTerms = value!;
              if (!value) checklistNotes['PAYMENT_TERMS']?.clear();
            });
          },
        ),

        _buildCheckboxItemWithNote(
          'Relations & Referrals',
          'RELATIONS_REFERRALS',
          relationsReferrals,
              (value) {
            setState(() {
              relationsReferrals = value!;
              if (!value) checklistNotes['RELATIONS_REFERRALS']?.clear();
            });
          },
        ),
      ],
    );
  }


  Widget _buildCheckboxItemWithNote(
      String title,
      String key,
      bool value,
      Function(bool?) onChanged,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Checkbox(
              value: value,
              onChanged: onChanged,
              activeColor: AppColors.primaryTeal,
            ),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),

        /// 🔥 Show only when checkbox is checked
        if (value)
          Padding(
            padding: const EdgeInsets.only(left: 48, right: 16, bottom: 8),
            child: TextFormField(
              controller: checklistNotes[key],
              maxLines: 2,
              decoration: InputDecoration(
                hintText: 'Add notes for $title...',
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
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
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
        const Text(
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
        const Text(
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
        const Text(
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
        // if (needsFollowUp) ...[
        //   const SizedBox(height: 16),
        //   Text(
        //     'Reminder',
        //     style: TextStyle(
        //       fontSize: 14,
        //       fontWeight: FontWeight.w500,
        //       color: AppColors.textPrimary,
        //     ),
        //   ),
        //   const SizedBox(height: 8),
        //   Row(
        //     children: [
        //       Expanded(
        //         child: _buildTextField('Date', _followUpDateController),
        //       ),
        //       const SizedBox(width: 12),
        //       Expanded(
        //         child: _buildTextField('Time', _followUpTimeController),
        //       ),
        //     ],
        //   ),
        // ],
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
            // Expanded(
            //   child: OutlinedButton(
            //     onPressed: _saveOffline,
            //     style: OutlinedButton.styleFrom(
            //       foregroundColor: AppColors.textSecondary,
            //       side: const BorderSide(color: AppColors.grey300),
            //       padding: const EdgeInsets.symmetric(vertical: 12),
            //       shape: RoundedRectangleBorder(
            //         borderRadius: BorderRadius.circular(8),
            //       ),
            //     ),
            //     child: const Text(
            //       'Save Offline',
            //       style: TextStyle(
            //         fontSize: 14,
            //         fontWeight: FontWeight.w500,
            //       ),
            //     ),
            //   ),
            // ),
            // const SizedBox(width: 12),
            Expanded(
              // flex: 2,
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
                child: const Text(
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
  final ImagePicker _picker = ImagePicker();

  Future<void> _captureImage() async {
    if (_capturedImages.length >= 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Maximum 3 images allowed'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final XFile? image = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 70,
    );

    if (image != null) {
      setState(() {
        _capturedImages.add(File(image.path));
      });
    }
  }


  Widget _buildAddPhotoTile() {
    return GestureDetector(
      onTap: _captureImage,
      child: Container(
        height: 80,
        width: 80,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.grey300),
          color: AppColors.grey50,
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.camera_alt, color: AppColors.primaryTeal),
            SizedBox(height: 6),
            Text(
              'Add Photo',
              style: TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCapturedImages() {
    return SizedBox(
      height: 90,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _capturedImages.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, index) {
          /// 📸 First item = Camera tile (only show if less than 3 images)
          if (index == 0) {
            if (_capturedImages.length >= 3) {
              return const SizedBox.shrink(); // Hide camera tile if 3 images already captured
            }
            return _buildAddPhotoTile();
          }

          final image = _capturedImages[index - 1];

          return Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.file(
                  image,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 4,
                right: 4,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _capturedImages.removeAt(index - 1);
                    });
                  },
                  child: const CircleAvatar(
                    radius: 12,
                    backgroundColor: Colors.black54,
                    child: Icon(Icons.close, size: 14, color: Colors.white),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }


  Future<void> _uploadMomImages(String momId) async {
    final imageBloc = context.read<MomImageUploadBloc>();

    for (int i = 0; i < _capturedImages.length; i++) {
      final completer = Completer<void>();
      late final StreamSubscription sub;

      sub = imageBloc.stream.listen((state) {
        if (state is MomImageUploadSuccess || state is MomImageUploadError) {
          completer.complete();
          sub.cancel();
        }
      });

      imageBloc.add(
        UploadMomImage(
          momId: momId,
          imageFile: _capturedImages[i],
          caption: 'Image ${i + 1}',
          sortOrder: i,
          showLoader: false,
        ),
      );

      await completer.future;
    }
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
    if (!_formKey.currentState!.validate()) return;

    final requestBody = PostMomEntryRequestBody(
      momId: "MOM-${DateTime.now().year}${DateTime.now().millisecondsSinceEpoch}",

      clientId: selectedClientId!,
      clientContactId: selectedContactId!,
      meetingType: selectedMeetingType!,
      gpsLat: currentLat,
      gpsLng: currentLng,
      gpsAccuracyM: 10,
      detailedNotes: _notesController.text,
      followUpRequired: needsFollowUp,
      checklistItems: [
        if (introObjective)
          ChecklistItems(
            itemKey: 'INTRO_OBJECTIVE',
            notes: checklistNotes['INTRO_OBJECTIVE']!.text,
          ),
        if (product)
          ChecklistItems(
            itemKey: 'PRODUCT',
            notes: checklistNotes['PRODUCT']!.text,
          ),
        if (price)
          ChecklistItems(
            itemKey: 'PRICE',
            notes: checklistNotes['PRICE']!.text,
          ),
        if (dealership)
          ChecklistItems(
            itemKey: 'DEALERSHIP',
            notes: checklistNotes['DEALERSHIP']!.text,
          ),
        if (commission)
          ChecklistItems(
            itemKey: 'COMMISSION',
            notes: checklistNotes['COMMISSION']!.text,
          ),
        if (paymentTerms)
          ChecklistItems(
            itemKey: 'PAYMENT_TERMS',
            notes: checklistNotes['PAYMENT_TERMS']!.text,
          ),
        if (relationsReferrals)
          ChecklistItems(
            itemKey: 'RELATIONS_REFERRALS',
            notes: checklistNotes['RELATIONS_REFERRALS']!.text,
          ),
      ],
    );

    context.read<PostMomEntryBloc>().add(
      SubmitMomEntry(
        requestBody: requestBody,
        showLoader: true,
      ),
    );
  }


  void _submitMom1() {
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

    // Dispose checklist note controllers
    checklistNotes.forEach((key, controller) {
      controller.dispose();
    });

    super.dispose();
  }
}

