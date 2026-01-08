import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../api/models/request/PostWorkPlanRequestBody.dart';
import '../../../../bloc/client/get_client/get_client_bloc.dart';
import '../../../../bloc/client/get_client/get_client_event.dart';
import '../../../../bloc/client/get_client/get_client_state.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../widgets/dropdown_widget.dart';


class WorkPlanDay {
  DateTime planDate;
  String dayNote;
  List<String> clientIds;
  List<Prospects> prospects;

  WorkPlanDay({
    required this.planDate,
    this.dayNote = '',
    List<String>? clientIds,
    List<Prospects>? prospects,
  })  : clientIds = clientIds ?? [],
        prospects = prospects ?? [];
}


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
  // List<String> selectedClientIds = [];
  List<DropdownOption> clientOptions = [];
  Set<String> selectedClientIds = {};
  DateTime _singleDate = DateTime.now();
  DateTimeRange? _dateRange;


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
  List<WorkPlanDay> workPlanDays = [];
  List<Days> workDays = [];

  DateTime fromDate = DateTime.now();
  DateTime toDate = DateTime.now();

  int currentDayIndex = 0;
  bool isEditing = false;
  int? editingIndex;

  /// Active day form state
  final TextEditingController dayNoteController = TextEditingController();

  List<Prospects> currentProspects = [];



  @override
  void initState() {
    super.initState();

    context.read<GetClientListBloc>().add(FetchGetClientList());
    _singleDate = DateTime.now();
    _dateController.text = _formatDate(_singleDate);

    _dateRange = DateTimeRange(
      start: DateTime.now(),
      end: DateTime.now(),
    );

    _fromDateController.text = _formatDate(_dateRange!.start);
    _toDateController.text = _formatDate(_dateRange!.end);

    _buildWorkPlanDays();
  }

  void _buildWorkPlanDays() {
    workPlanDays.clear();

    if (dateType == 'single') {
      workPlanDays.add(
        WorkPlanDay(planDate: _singleDate),
      );
    } else {
      final start = _dateRange!.start;
      final end = _dateRange!.end;

      for (int i = 0; i <= end.difference(start).inDays; i++) {
        workPlanDays.add(
          WorkPlanDay(
            planDate: start.add(Duration(days: i)),
          ),
        );
      }
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
                    const SizedBox(height: 16),

                    // _buildDayWisePlans(),   // 👈 ADD HERE
                    _buildActiveDayEditor(),
                    const SizedBox(height: 24),

                    _buildNotesSection(),
                    const SizedBox(height: 80),

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
        style: TextStyle(
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
        const Text(
          'Date type',
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
                  style: TextStyle(
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
                  style: TextStyle(
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
          const Row(
            children: [
              Text(
                'Date',
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

          InkWell(
            onTap: _pickSingleDate,
            child: TextFormField(
              controller: _dateController,
              enabled: false,
              decoration: _dateDecoration(),
            ),
          ),
        ] else ...[
          const Text(
            'Date Range',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),

          InkWell(
            onTap: _pickDateRange,
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(

                    controller: _fromDateController,
                    enabled: false,
                    decoration: _dateDecoration(hint: 'From'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _toDateController,
                    enabled: false,
                    decoration: _dateDecoration(hint: 'To'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  InputDecoration _dateDecoration({String? hint}) {
    return InputDecoration(
      contentPadding: const EdgeInsets.symmetric(vertical: 2,horizontal: 5),
      hintText: hint,
      suffixIcon: const Icon(Icons.calendar_today, size: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.grey300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.grey300),
      ),
    );
  }


  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')} '
        '${_getMonthName(date.month)} '
        '${date.year}';
  }

  Future<void> _pickSingleDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _singleDate,
      firstDate: DateTime(2023),
      lastDate: DateTime(2035),
    );

    if (picked != null) {
      setState(() {
        _singleDate = picked;
        _dateController.text = _formatDate(picked);

        workPlanDays = [
          WorkPlanDay(planDate: picked),
        ];
      });
    }
  }


  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2023),
      lastDate: DateTime(2035),
      initialDateRange: _dateRange,
    );

    if (picked != null) {
      setState(() {
        _dateRange = picked;
        _fromDateController.text = _formatDate(picked.start);
        _toDateController.text = _formatDate(picked.end);

        _buildWorkPlanDays();
      });
    }
  }

  Widget _buildDayWisePlans() {
    if (workPlanDays.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Day-wise Plan',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),

        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: workPlanDays.length,
          itemBuilder: (context, index) {
            final day = workPlanDays[index];

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _formatDate(day.planDate),
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 8),

                    TextFormField(
                      decoration: const InputDecoration(
                        hintText: 'Day note',
                      ),
                      onChanged: (v) => day.dayNote = v,
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      'Clients',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Wrap(
                      spacing: 8,
                      children: clientOptions.map((client) {
                        final selected = day.clientIds.contains(client.id);

                        return FilterChip(
                          label: Text(client.name),
                          selected: selected,
                          selectedColor:
                          AppColors.primaryTeal.withOpacity(0.15),
                          onSelected: (val) {
                            setState(() {
                              val
                                  ? day.clientIds.add(client.id)
                                  : day.clientIds.remove(client.id);
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }


  Widget _buildCitySection() {
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
        TextFormField(
          controller: _cityController,
          decoration: InputDecoration(
            hintText: 'Enter City',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
          validator: (v) => v == null || v.isEmpty ? 'City required' : null,
        ),

      ],
    );
  }

  String _clientSearch = '';
  Widget _buildClientsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Text(
              'Clients',
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

        /// 🔍 Search Field
        TextField(
          decoration: InputDecoration(
            hintText: 'Search clients',
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onChanged: (value) {
            setState(() {
              _clientSearch = value;
            });
          },
        ),

        const SizedBox(height: 8),

        /// ☑️ Checkbox List (Scrollable, Fixed Height)
        BlocBuilder<GetClientListBloc, GetClientListState>(
          builder: (context, state) {
            if (state is GetClientListLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is GetClientListLoaded) {
              clientOptions = state.response.data!
                  .map((e) => DropdownOption(id: e.id!, name: e.firmName!))
                  .toList();

              final filteredClients = clientOptions
                  .where((c) =>
                  c.name.toLowerCase().contains(_clientSearch.toLowerCase()))
                  .toList();

              return Container(
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.grey300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListView.builder(
                  itemCount: filteredClients.length,
                  itemBuilder: (_, index) {
                    final client = filteredClients[index];
                    final selected =
                    selectedClientIds.contains(client.id);

                    return CheckboxListTile(
                      dense: true,
                      value: selected,
                      title: Text(client.name),
                      controlAffinity: ListTileControlAffinity.leading,
                      onChanged: (val) {
                        setState(() {
                          val!
                              ? selectedClientIds.add(client.id)
                              : selectedClientIds.remove(client.id);
                        });
                      },
                    );
                  },
                ),
              );
            }

            return const SizedBox();
          },
        ),

        /// 🏷 Selected Clients as Chips
        if (selectedClientIds.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: clientOptions
                .where((c) => selectedClientIds.contains(c.id))
                .map(
                  (c) => Chip(
                label: Text(c.name),
                onDeleted: () {
                  setState(() {
                    selectedClientIds.remove(c.id);
                  });
                },
              ),
            )
                .toList(),
          ),
        ],


      ],
    );
  }

  void _generateDaysFromRange() {
    workPlanDays.clear();

    final totalDays = toDate.difference(fromDate).inDays + 1;

    for (int i = 0; i < totalDays; i++) {
      final date = fromDate.add(Duration(days: i));

      workDays.add(
        Days(
          planDate: formatDateDdMmmYyyy(date), // ✅ STORED FORMAT
          clientIds: [],
          prospects: [],
        ),
      );
    }

    currentDayIndex = 0;
    _resetDayForm();
  }
  Widget _buildActiveDayEditor() {
    final day = workPlanDays[currentDayIndex];

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Plan Date
            Text(
              'Plan Date: ${formatDateDdMmmYyyy(day.planDate!)}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 12),

            /// Day Note
            TextField(
              controller: dayNoteController,
              decoration: const InputDecoration(
                labelText: 'Day Note',
              ),
            ),

            const SizedBox(height: 12),

            /// Clients (reuse your checkbox list)
            _buildClientsSection(),

            const SizedBox(height: 12),

            /// Prospects
            _buildProspectsSection(),

            const SizedBox(height: 16),

            /// Save Button
            ElevatedButton(
              onPressed: _saveCurrentDay,
              child: Text(isEditing ? 'Update Day' : 'Save Day'),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildProspectsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Prospects',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),

        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: currentProspects.length,
          itemBuilder: (context, index) {
            return _prospectCard(index);
          },
        ),

        const SizedBox(height: 8),

        TextButton.icon(
          onPressed: _addProspect,
          icon: const Icon(Icons.add),
          label: const Text('Add Prospect'),
        ),
      ],
    );
  }

  Widget _prospectCard(int index) {
    final prospect = currentProspects[index];

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            _textField(
              initialValue: prospect.prospectName,
              label: 'Prospect Name',
              onChanged: (v) => prospect.prospectName = v,
            ),
            _textField(
              initialValue: prospect.locationText,
              label: 'Location',
              onChanged: (v) => prospect.locationText = v,
            ),
            _textField(
              maxLength: 10,
              initialValue: prospect.contactText,
              label: 'Contact',
              keyboardType: TextInputType.phone,
              onChanged: (v) => prospect.contactText = v,
            ),
            _textField(
              initialValue: prospect.note,
              label: 'Note',
              maxLines: 2,
              onChanged: (v) => prospect.note = v,
            ),

            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  setState(() {
                    currentProspects.removeAt(index);
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _textField({
    String? initialValue,
    required String label,
    int maxLines = 1,
    int? maxLength,
    TextInputType keyboardType = TextInputType.text,
    required Function(String) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: TextFormField(
        initialValue: initialValue,
        maxLines: maxLines,
        maxLength:maxLength ,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          counterText: "",
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        onChanged: onChanged,
      ),
    );
  }

  void _addProspect() {
    final nameCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add Prospect'),
        content: TextField(
          controller: nameCtrl,
          decoration: const InputDecoration(labelText: 'Prospect Name'),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                currentProspects.add(
                  Prospects(prospectName: nameCtrl.text),
                );
              });
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
  void _saveCurrentDay() {
    final day = workPlanDays[currentDayIndex];

    day.dayNote = dayNoteController.text;
    day.clientIds = selectedClientIds.toList();
    day.prospects = List.from(currentProspects);

    setState(() {
      isEditing = false;
      editingIndex = null;

      /// Move to next day
      if (currentDayIndex < workPlanDays.length - 1) {
        currentDayIndex++;
        _resetDayForm();
      }
    });
  }
  void _resetDayForm() {
    dayNoteController.clear();
    selectedClientIds.clear();
    currentProspects.clear();
  }
  Widget _buildSavedDaysList() {
    return Column(
      children: workPlanDays.asMap().entries.map((entry) {
        final index = entry.key;
        final day = entry.value;

        if (day.dayNote == null && day.clientIds!.isEmpty) {
          return const SizedBox();
        }

        return Card(
          child: ListTile(
            title: Text(formatDateDdMmmYyyy(day.planDate!)),
            subtitle: Text(day.dayNote ?? ''),
            trailing: IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _editDay(index),
            ),
          ),
        );
      }).toList(),
    );
  }
  void _editDay(int index) {
    final day = workPlanDays[index];

    setState(() {
      currentDayIndex = index;
      isEditing = true;
      editingIndex = index;

      dayNoteController.text = day.dayNote ?? '';
      selectedClientIds = day.clientIds?.toSet() ?? {};
      currentProspects = List.from(day.prospects ?? []);
    });
  }


  String formatDateDdMmmYyyy(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];

    final day = date.day.toString().padLeft(2, '0');
    final month = months[date.month - 1];
    final year = date.year;

    return '$day-$month-$year';
  }


  Widget _buildNotesSection() {
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

  void _submitPlan() {
    if (_formKey.currentState!.validate() && selectedClientIds.isNotEmpty) {
      final action = widget.workPlan != null ? 'updated' : 'submitted';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Work plan $action successfully'),
          backgroundColor: AppColors.success,
        ),
      );
      final requestBody= PostWorkPlanRequestBody(
        fromDate: formatDateDdMmmYyyy(fromDate),
        toDate: formatDateDdMmmYyyy(toDate),
        submitNow: true,
        days: workDays,
      );
      print("work plan request body :${jsonEncode(requestBody.toJson())}");

      // Navigator.pop(context);
    } else if (selectedClientIds.isEmpty) {
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

