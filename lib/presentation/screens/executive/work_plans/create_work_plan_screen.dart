import 'dart:convert';

import 'package:apclassstone/bloc/work_plan/work_plan_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../api/models/request/PostWorkPlanRequestBody.dart';
import '../../../../bloc/client/get_client/get_client_bloc.dart';
import '../../../../bloc/client/get_client/get_client_event.dart';
import '../../../../bloc/client/get_client/get_client_state.dart';
import '../../../../bloc/work_plan/work_plan_event.dart';
import '../../../../bloc/work_plan/work_plan_state.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../widgets/dropdown_widget.dart';


class WorkPlanDay {
  DateTime planDate;
  String dayNote;
  List<String> clientIds;
  List<Prospects> prospects;
  bool isSaved;

  WorkPlanDay({
    required this.planDate,
    this.dayNote = '',
    List<String>? clientIds,
    List<Prospects>? prospects,
    this.isSaved = false,
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

  bool get _isRange => dateType == 'range';

  bool get _workflowComplete =>
      workPlanDays.isNotEmpty && workPlanDays.every((d) => d.isSaved);

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
      body: MultiBlocListener(
        listeners: [
          BlocListener<PostWorkPlanBloc, PostWorkPlanState>(
            listener: (context, state) {
              if (state is PostWorkPlanSuccess) {
                if(state.response.statusCode==200 || state.response.statusCode==201){
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Work-Plan Successfully Added!')),
                  );
                  // Optionally refresh pending list
                  context.pop(true);
                }
                else{
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("${state.response.message}")),
                  );
                }

              } else if (state is PostWorkPlanError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message ?? 'Failed to approve user')),
                );
              }
            },
          ),
        ],
        child: Form(
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


                      _buildDateSection(),
                      const SizedBox(height: 24),

                      _buildCitySection(),
                      const SizedBox(height: 24),

                      // _buildClientsSection(),
                      // const SizedBox(height: 16),

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
        style: const TextStyle(
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
                      _buildWorkPlanDays();

                      // Reset the step flow
                      currentDayIndex = 0;
                      isEditing = false;
                      editingIndex = null;
                      _resetDayForm();
                    });
                  },

                  // onChanged: (value) {
                  //   setState(() {
                  //     dateType = value!;
                  //   });
                  // },
                  activeColor: AppColors.primaryTeal,
                ),
                const Text(
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
                      _buildWorkPlanDays();

                      // Reset the step flow
                      currentDayIndex = 0;
                      isEditing = false;
                      editingIndex = null;
                      _resetDayForm();
                    });
                  },


                  // onChanged: (value) {
                  //   setState(() {
                  //     dateType = value!;
                  //   });
                  // },
                  activeColor: AppColors.primaryTeal,
                ),
                const Text(
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
      print('📅 Date range picked: ${formatDateYyyyMmDd(picked.start)} to ${formatDateYyyyMmDd(picked.end)}');

      setState(() {
        _dateRange = picked;
        _fromDateController.text = _formatDate(picked.start);
        _toDateController.text = _formatDate(picked.end);

        _buildWorkPlanDays();

        print('📅 Total work plan days created: ${workPlanDays.length}');
        for (var i = 0; i < workPlanDays.length; i++) {
          print('  Day ${i + 1}: ${formatDateYyyyMmDd(workPlanDays[i].planDate)}');
        }
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
        ),

      ],
    );
  }

  String _clientSearch = '';
  Widget _buildClientsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Clients',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
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

  Widget _buildActiveDayEditor() {
    final day = workPlanDays[currentDayIndex];
    final isLastDay = currentDayIndex == workPlanDays.length - 1;

    // Hide prospects only when workflow complete AND not editing old day
    final hideProspects = _workflowComplete && !isEditing;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Header row: Plan Date + progress for range
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Plan Date: ${formatDateDdMmmYyyy(day.planDate)}',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                if (_isRange)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primaryTeal.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${currentDayIndex + 1}/${workPlanDays.length}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryTeal,
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 12),

            /// Day Note
            TextField(
              controller: dayNoteController,
              decoration: const InputDecoration(labelText: 'Day Note'),
            ),

            const SizedBox(height: 12),

            /// Clients
            _buildClientsSection(),

            const SizedBox(height: 12),

            /// Prospects (hidden only after last day is saved)
            if (!hideProspects) ...[
              _buildProspectsSection(),
              const SizedBox(height: 16),
            ] else ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.green.withOpacity(0.3)),
                ),
                child: const Text(
                  'All days saved. Prospects section is now closed.',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.green,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            /// Save Button (disabled only when completed and not editing)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (_workflowComplete && !isEditing) ? null : _saveCurrentDay,
                child: Text(
                  (_workflowComplete && !isEditing)
                      ? 'Days Saved'
                      : (isEditing ? 'Update Day' : (isLastDay ? 'Save Day (Finish)' : 'Save Day')),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  // Widget _buildProspectsSection() {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       const Text(
  //         'Prospects',
  //         style: TextStyle(
  //           fontSize: 14,
  //           fontWeight: FontWeight.w600,
  //         ),
  //       ),
  //       const SizedBox(height: 8),
  //
  //       ListView.builder(
  //         shrinkWrap: true,
  //         physics: const NeverScrollableScrollPhysics(),
  //         itemCount: currentProspects.length,
  //         itemBuilder: (context, index) {
  //           return _prospectCard(index);
  //         },
  //       ),
  //
  //       const SizedBox(height: 8),
  //
  //       TextButton.icon(
  //         onPressed: _addProspect,
  //         icon: const Icon(Icons.add),
  //         label: const Text('Add Prospect'),
  //       ),
  //     ],
  //   );
  // }

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
      onPressed: () {
        setState(() {
          // Add empty Prospects directly
          currentProspects.add(Prospects());
        });
      },
            icon: const Icon(Icons.add),
            label: const Text('Add Prospect'),
          ),
        // Direct add button - no dialog


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

  Widget _buildSavedDaysSummary() {
    final savedDays = workPlanDays.where((d) => d.isSaved).toList();
    if (savedDays.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Saved days',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: savedDays.length,
          itemBuilder: (context, i) {
            final day = savedDays[i];
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.grey200),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          formatDateDdMmmYyyy(day.planDate),
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Clients: ${day.clientIds.length}   •   Prospects: ${day.prospects.length}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        if ((day.dayNote).trim().isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            day.dayNote.trim(),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit, size: 20),
                    onPressed: () {
                      final index = workPlanDays.indexOf(day);
                      _editDay(index);
                    },
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 16),
      ],
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

    // Basic validation: require at least one client
    // if (selectedClientIds.isEmpty) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(
    //       content: Text('Please select at least one client for this day'),
    //       backgroundColor: AppColors.error,
    //     ),
    //   );
    //   return;
    // }

    day.dayNote = dayNoteController.text;
    day.clientIds = selectedClientIds.toList();
    day.prospects = List<Prospects>.from(currentProspects);
    day.isSaved = true;

    print('✅ Saved day ${currentDayIndex + 1}/${workPlanDays.length}: ${formatDateYyyyMmDd(day.planDate)}');
    print('   Note: "${day.dayNote}"');
    print('   Clients: ${day.clientIds.length}');
    print('   Prospects: ${day.prospects.length}');

    setState(() {
      isEditing = false;
      editingIndex = null;

      // Move to next day if exists, else finish & hide prospects (handled in UI)
      if (currentDayIndex < workPlanDays.length - 1) {
        currentDayIndex++;
        print('📍 Moving to next day (${currentDayIndex + 1}/${workPlanDays.length})');
        _resetDayForm();
      } else {
        // last day saved -> clear current form so it doesn't look editable
        print('🎉 All days saved! Workflow complete.');
        _resetDayForm();
      }
    });
  }

  void _saveCurrentDay1() {
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
    print('🚀 Submitting work plan...');

    // Validate that at least one day has been saved
    if (!_workflowComplete) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please save all days before submitting'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Validate required fields (only city is mandatory)
    if (_cityController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a city'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    print('📊 Total workPlanDays: ${workPlanDays.length}');

    // Convert workPlanDays to Days format for API
    final List<Days> daysForApi = workPlanDays.map((day) {
      print('  Converting day: ${formatDateYyyyMmDd(day.planDate)} (Saved: ${day.isSaved}, Clients: ${day.clientIds.length}, Prospects: ${day.prospects.length})');

      return Days(
        planDate: formatDateYyyyMmDd(day.planDate),
        dayNote: day.dayNote.trim().isEmpty ? null : day.dayNote.trim(),
        clientIds: day.clientIds.isNotEmpty ? day.clientIds : null,
        prospects: day.prospects.isNotEmpty ? day.prospects : null,
      );
    }).toList();

    // Determine the date range from workPlanDays
    final firstDate = workPlanDays.first.planDate;
    final lastDate = workPlanDays.last.planDate;

    print('📅 Date range: ${formatDateYyyyMmDd(firstDate)} to ${formatDateYyyyMmDd(lastDate)}');
    print('📋 Days for API: ${daysForApi.length}');

    final requestBody = PostWorkPlanRequestBody(
      fromDate: formatDateYyyyMmDd(firstDate),
      toDate: formatDateYyyyMmDd(lastDate),
      executiveNote: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      submitNow: true,
      days: daysForApi,
    );

    print("📤 work plan request body: ${jsonEncode(requestBody.toJson())}");

    context.read<PostWorkPlanBloc>().add(SubmitWorkPlan(requestBody: requestBody));
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



String formatDateYyyyMmDd(DateTime date) {
  final y = date.year.toString().padLeft(4, '0');
  final m = date.month.toString().padLeft(2, '0');
  final d = date.day.toString().padLeft(2, '0');
  return '$y-$m-$d';
}
}

