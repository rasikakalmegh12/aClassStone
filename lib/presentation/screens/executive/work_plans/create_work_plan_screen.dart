import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';

class CreateWorkPlanScreen extends StatefulWidget {
  final Map<String, dynamic>? workPlan;

  const CreateWorkPlanScreen({super.key, this.workPlan});

  @override
  State<CreateWorkPlanScreen> createState() => _CreateWorkPlanScreenState();
}

class _CreateWorkPlanScreenState extends State<CreateWorkPlanScreen> {
  final _formKey = GlobalKey<FormState>();

  // Form Controllers
  final _dateController = TextEditingController();
  final _fromDateController = TextEditingController();
  final _toDateController = TextEditingController();
  final _cityController = TextEditingController();
  final _notesController = TextEditingController();

  // Form State
  String dateType = 'single';
  String? selectedCity;
  List<String> selectedClients = [];

  final List<String> cities = [
    'Jaipur',
    'Udaipur',
    'Jodhpur',
    'Ajmer',
    'Kota',
    'Bikaner',
    'Alwar',
  ];

  final List<Map<String, dynamic>> availableClients = [
    {'name': 'A Class Stone', 'selected': false},
    {'name': 'Sangam Granites', 'selected': false},
    {'name': 'Patwari Marble', 'selected': false},
    {'name': 'Rajasthan Marbles', 'selected': false},
    {'name': 'Desert Stones', 'selected': false},
    {'name': 'Marble Palace', 'selected': false},
  ];

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  void _initializeForm() {
    if (widget.workPlan != null) {
      final plan = widget.workPlan!;
      selectedCity = plan['city'];

      if (plan['type'] == 'range') {
        dateType = 'range';
        // Parse date range
        final range = plan['dateRange'].split('–');
        if (range.length == 2) {
          _fromDateController.text = range[0].trim();
          _toDateController.text = range[1].trim();
        }
      } else {
        dateType = 'single';
        _dateController.text = plan['date'];
      }

      if (plan['clients'] != null) {
        selectedClients = List<String>.from(plan['clients']);

        // Update available clients selection
        for (var client in availableClients) {
          client['selected'] = selectedClients.contains(client['name']);
        }
      }
    } else {
      // Set default date to today for new work plans
      final today = DateTime.now();
      final dateStr = '${today.day.toString().padLeft(2, '0')} ${_getMonthName(today.month)} ${today.year}';
      _dateController.text = dateStr;
    }
  }

  String _getMonthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }

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
                    _buildDateTypeSection(),
                    const SizedBox(height: 24),
                    _buildDateSection(),
                    const SizedBox(height: 24),
                    _buildCitySection(),
                    const SizedBox(height: 24),
                    _buildClientsSection(),
                    const SizedBox(height: 24),
                    _buildNotesSection(),
                    const SizedBox(height: 80), // Space for bottom button
                  ],
                ),
              ),
            ),
            _buildBottomButton(),
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
        widget.workPlan != null ? 'Edit Work Plan' : 'Create Work Plan',
        style: GoogleFonts.lato(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildDateTypeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Date type',
          style: GoogleFonts.lato(
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
                Radio<String>(
                  value: 'single',
                  groupValue: dateType,
                  onChanged: (value) {
                    setState(() {
                      dateType = value!;
                    });
                  },
                  activeColor: AppColors.primaryTeal,
                ),
                Text(
                  'Single day',
                  style: GoogleFonts.lato(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 32),
            Row(
              children: [
                Radio<String>(
                  value: 'range',
                  groupValue: dateType,
                  onChanged: (value) {
                    setState(() {
                      dateType = value!;
                    });
                  },
                  activeColor: AppColors.primaryTeal,
                ),
                Text(
                  'Date range',
                  style: GoogleFonts.lato(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDateSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (dateType == 'single') ...[
          Row(
            children: [
              Text(
                'Date',
                style: GoogleFonts.lato(
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
          TextFormField(
            controller: _dateController,
            decoration: InputDecoration(
              hintText: '15 Dec 2025',
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
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select a date';
              }
              return null;
            },
          ),
        ] else ...[
          Text(
            'Date Range',
            style: GoogleFonts.lato(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'From',
                      style: GoogleFonts.lato(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    TextFormField(
                      controller: _fromDateController,
                      decoration: InputDecoration(
                        hintText: '10 Dec',
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
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'To',
                      style: GoogleFonts.lato(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    TextFormField(
                      controller: _toDateController,
                      decoration: InputDecoration(
                        hintText: '12 Dec',
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
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildCitySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'City',
              style: GoogleFonts.lato(
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
          value: selectedCity,
          decoration: InputDecoration(
            hintText: 'Select City',
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
              return 'Please select a city';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildClientsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Clients',
              style: GoogleFonts.lato(
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
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.grey300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              ...availableClients.asMap().entries.map((entry) {
                final index = entry.key;
                final client = entry.value;
                final isLast = index == availableClients.length - 1;

                return Container(
                  decoration: BoxDecoration(
                    border: isLast ? null : const Border(
                      bottom: BorderSide(color: AppColors.grey200),
                    ),
                  ),
                  child: CheckboxListTile(
                    title: Text(
                      client['name'],
                      style: GoogleFonts.lato(
                        fontSize: 14,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    value: client['selected'],
                    onChanged: (value) {
                      setState(() {
                        client['selected'] = value!;
                        if (value) {
                          selectedClients.add(client['name']);
                        } else {
                          selectedClients.remove(client['name']);
                        }
                      });
                    },
                    activeColor: AppColors.primaryTeal,
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                );
              }),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  border: Border(
                    top: BorderSide(color: AppColors.grey200),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.add, color: AppColors.primaryTeal, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Add new client',
                      style: GoogleFonts.lato(
                        fontSize: 14,
                        color: AppColors.primaryTeal,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (selectedClients.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Please select at least one client',
              style: GoogleFonts.lato(
                fontSize: 12,
                color: AppColors.error,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildNotesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Notes',
          style: GoogleFonts.lato(
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
            hintText: 'Additional notes for this work plan...',
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
            onPressed: _submitPlan,
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
              widget.workPlan != null ? 'Update Plan' : 'Submit Plan',
              style: GoogleFonts.lato(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _submitPlan() {
    if (_formKey.currentState!.validate() && selectedClients.isNotEmpty) {
      final action = widget.workPlan != null ? 'updated' : 'submitted';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Work plan $action successfully'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pop(context);
    } else if (selectedClients.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one client'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  void dispose() {
    _dateController.dispose();
    _fromDateController.dispose();
    _toDateController.dispose();
    _cityController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}
