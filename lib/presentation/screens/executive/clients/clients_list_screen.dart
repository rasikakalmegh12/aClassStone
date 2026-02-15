import 'package:apclassstone/bloc/client/get_client/get_client_bloc.dart';
import 'package:apclassstone/bloc/client/get_client/get_client_event.dart';
import 'package:apclassstone/bloc/client/get_client/get_client_state.dart';
import 'package:apclassstone/bloc/client/post_client/post_client_bloc.dart';
import 'package:apclassstone/core/session/session_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:apclassstone/api/models/response/GetClientListResponseBody.dart';
import 'package:apclassstone/api/models/response/GetClientIdDetailsResponseBody.dart' as GetClientIdDetailsResponseBody;
import '../../../../core/constants/app_colors.dart';
import '../../../widgets/app_bar.dart';
import 'add_location_screen.dart';

class ClientsListScreen extends StatefulWidget {
  const ClientsListScreen({super.key});

  @override
  State<ClientsListScreen> createState() => _ClientsListScreenState();
}

class _ClientsListScreenState extends State<ClientsListScreen> {
  String selectedFilter = 'All';
  final List<Map<String, String>> filters = [
    {'display': 'All', 'code': ''},
    {'display': 'Builder', 'code': 'BUILDER'},
    {'display': 'Architect', 'code': 'ARCHITECT'},
    {'display': 'Interior Designer', 'code': 'INTERIOR_DESIGNER'},
    {'display': 'Other', 'code': 'OTHER'},
  ];

  final TextEditingController _searchController = TextEditingController();
  final List<Data> clients = [];

  List<Data> get filteredClients {
    if (selectedFilter == 'All') return clients;
    return clients.where((client) => client.clientTypeCode == selectedFilter).toList();
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {}); // Rebuild to show/hide clear button
    });
    _loadClientList(showLoader: true);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadClientList({bool showLoader = false}) {
    // Get the client type code for the selected filter
    String? clientTypeCode;
    if (selectedFilter != 'All') {
      final filterItem = filters.firstWhere(
        (f) => f['display'] == selectedFilter,
        orElse: () => {'display': 'All', 'code': ''},
      );
      clientTypeCode = filterItem['code']!.isEmpty ? null : filterItem['code'];
    }

    context.read<GetClientListBloc>().add(
      FetchGetClientList(
        showLoader: showLoader,
        search: _searchController.text.trim().isEmpty ? null : _searchController.text.trim(),
        clientTypeCode: clientTypeCode,
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(

      backgroundColor: AppColors.backgroundLight,
      appBar:
      PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: CoolAppCard(title: 'Clients',      backgroundColor: SessionManager.getUserRole() =="superadmin"?AppColors.superAdminPrimary:SessionManager.getUserRole() =="admin"?
          AppColors.adminPrimaryDark :AppColors.primaryTealDark,)
      ),
      // _buildAppBar(),
      body: Column(
        children: [
          _buildSearchAndFilters(),
          Expanded(
            child: _buildClientsList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
        context.pushNamed("addClientScreen");
        },
        backgroundColor: SessionManager.getUserRole() =="superadmin"?AppColors.superAdminPrimary:SessionManager.getUserRole() =="admin"?
        AppColors.adminPrimaryDark :AppColors.primaryTealDark,
        child: const Icon(Icons.add, color: AppColors.white),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(

      backgroundColor: SessionManager.getUserRole() =="superadmin"?AppColors.superAdminPrimary:SessionManager.getUserRole() =="admin"?
      AppColors.adminPrimary :AppColors.primaryTealDark,
      elevation: 1,
      shadowColor: AppColors.grey200,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(Icons.arrow_back_ios, color: AppColors.white),
      ),
      title: const Text(
        'Clients',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.white,
        ),
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Search Bar
          Container(
            decoration: BoxDecoration(
              color: AppColors.grey50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.grey200),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                // Debounce search - trigger after user stops typing
                Future.delayed(const Duration(milliseconds: 500), () {
                  if (_searchController.text == value) {
                    _loadClientList(showLoader: false);
                  }
                });
              },
              decoration: InputDecoration(
                hintText: 'Search client name, contact, or location',
                hintStyle: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textLight,
                ),
                prefixIcon: const Icon(Icons.search, color: AppColors.textLight),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: AppColors.textLight),
                        onPressed: () {
                          _searchController.clear();
                          _loadClientList(showLoader: false);
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Filter Chips
          SizedBox(
            height: 32,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: filters.length,
              itemBuilder: (context, index) {
                final filter = filters[index]['display']!;
                final isSelected = filter == selectedFilter;

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedFilter = filter;
                      });
                      // Trigger API call with new filter
                      _loadClientList(showLoader: false);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? (SessionManager.getUserRole() == "superadmin"
                                ? AppColors.superAdminPrimary
                                : SessionManager.getUserRole() == "admin"
                                    ? AppColors.adminPrimary
                                    : AppColors.primaryTealDark)
                            : AppColors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? (SessionManager.getUserRole() == "superadmin"
                                  ? AppColors.superAdminPrimary
                                  : SessionManager.getUserRole() == "admin"
                                      ? AppColors.adminPrimary
                                      : AppColors.primaryTealDark)
                              : AppColors.grey300,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          filter,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: isSelected ? AppColors.white : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClientsList() {
    // Use BLoC to fetch and render client list. Fall back to local sample data if API data is not available.
    return BlocBuilder<GetClientListBloc, GetClientListState>(
      builder: (context, state) {
        // Loading state
        if (state is GetClientListLoading && state.showLoader) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        // Loaded state - render data from API
        if (state is GetClientListLoaded) {
          final items = state.response.data ?? [];

          if (items.isEmpty) {
            // No clients found
            return RefreshIndicator(
              color: SessionManager.getUserRole() == "superadmin"
                  ? AppColors.superAdminPrimary
                  : AppColors.primaryTeal,
              onRefresh: () async {
                _loadClientList(showLoader: false);
              },
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                children: const [
                  Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Column(
                        children: [
                          Icon(
                            Icons.people_outline,
                            size: 64,
                            color: AppColors.grey300,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No clients found',
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            color: SessionManager.getUserRole() == "superadmin"
                ? AppColors.superAdminPrimary
                : AppColors.primaryTeal,
            onRefresh: () async {
              _loadClientList(showLoader: false);
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final client = items[index];
                return _buildClientCardFromData(client, index);
              },
            ),
          );
        }

        // Error state
        if (state is GetClientListError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: AppColors.error,
                ),
                const SizedBox(height: 16),
                Text(
                  'Error: ${state.message}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => _loadClientList(showLoader: true),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: SessionManager.getUserRole() == "superadmin"
                        ? AppColors.superAdminPrimary
                        : SessionManager.getUserRole() == "admin"
                            ? AppColors.adminPrimary
                            : AppColors.primaryTealDark,
                    foregroundColor: AppColors.white,
                  ),
                ),
              ],
            ),
          );
        }

        // Initial state
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }

  // Render an API client item (GetClientListResponseBody.Data)
  Widget _buildClientCardFromData(Data client, int index) {
    // client is expected to have fields: firmName, clientTypeCode, city, id
    final name = (client.firmName ?? 'Unknown').toString();
    final type = (client.clientTypeCode ?? 'Other').toString();
    final city = (client.city ?? 'N/A').toString();

    Color typeColor;
    switch (type) {
      case 'Builder':
        typeColor = AppColors.primaryTeal;
        break;
      case 'Architect':
        typeColor = AppColors.accentPurple;
        break;
      case 'Interior':
        typeColor = AppColors.accentAmber;
        break;
      default:
        typeColor = AppColors.textSecondary;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // Fetch client details via Bloc and show a detailed bottom sheet
            final clientId = client.id?.toString() ?? '';
            if (clientId.isEmpty) return;

            // Create bottom sheet with its own bloc instance
            viewClientDetails(clientId);
            // _viewClientDetails(client);

          },

          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: typeColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        type,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: typeColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      city,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(delay: (index * 100).ms).slideX(begin: 0.3, end: 0);
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'Builder':
        return AppColors.primaryTeal;
      case 'Architect':
        return AppColors.accentPurple;
      case 'Interior':
        return AppColors.accentAmber;
      case 'Other':
        return AppColors.textSecondary;
      default:
        return AppColors.textSecondary;
    }
  }


  void viewClientDetails(String clientId){
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return BlocProvider(
          create: (context) => GetClientDetailsBloc()
            ..add(FetchGetClientDetails(
              clientId: clientId,
              showLoader: true,
            )),
          child: BlocConsumer<GetClientDetailsBloc, GetClientDetailsState>(
            listener: (context, state) {
              // debug
            },
            builder: (context, state) {
              return DraggableScrollableSheet(
                initialChildSize: 0.7,
                maxChildSize: 0.92,
                minChildSize: 0.5,
                builder: (context, scrollController) {
                  return Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    child: Column(
                      children: [

                        /// ================= DRAG HANDLE =================
                        Padding(
                          padding: const EdgeInsets.only(top: 8, bottom: 4),
                          child: Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),

                        /// ================= CONTENT =================
                        Expanded(
                          child: Builder(
                            builder: (_) {
                              if (state is GetClientDetailsLoading) {
                                return const Center(
                                  child: CircularProgressIndicator(
                                    color: AppColors.primaryTeal,
                                  ),
                                );
                              }

                              if (state is GetClientDetailsError) {
                                return Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Text('Failed to load client details'),
                                      const SizedBox(height: 12),
                                      ElevatedButton(
                                        onPressed: () {
                                          context.read<GetClientDetailsBloc>().add(
                                            FetchGetClientDetails(
                                              clientId: clientId,
                                              showLoader: true,
                                            ),
                                          );
                                        },
                                        child: const Text('Retry'),
                                      ),
                                    ],
                                  ),
                                );
                              }

                              if (state is! GetClientDetailsLoaded ||
                                  state.response.data == null) {
                                return const Center(
                                  child: Text('No details available'),
                                );
                              }

                              final details = state.response.data!;

                              final primaryLocation = details.locations?.isNotEmpty == true
                                  ? details.locations!.first
                                  : null;

                              final primaryContact = primaryLocation?.contacts?.isNotEmpty == true
                                  ? primaryLocation!.contacts!.first
                                  : null;


                              return Column(
                                children: [

                                  /// ================= DRAG HANDLE =================
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8, bottom: 4),
                                    child: Container(
                                      width: 40,
                                      height: 4,
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade300,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  ),

                                  /// ================= HEADER =================
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                details.firmName ?? 'NA',
                                                style: const TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                              const SizedBox(height: 6),
                              if (details.clientTypeCode != null)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: SessionManager.getUserRole() =="superadmin"?AppColors.superAdminPrimary.withValues(alpha: 0.1):SessionManager.getUserRole() =="admin"?
                                    AppColors.adminPrimary.withValues(alpha: 0.1) :AppColors.primaryTealDark.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                                  child: Text(
                                                    details.clientTypeCode!,
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.w600,
                                                      color: SessionManager.getUserRole() =="superadmin"?AppColors.superAdminPrimary:SessionManager.getUserRole() =="admin"?
                                                      AppColors.adminPrimary :AppColors.primaryTealDark,
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                        IconButton(
                                          onPressed: () => Navigator.pop(context),
                                          icon: const Icon(Icons.close),
                                        ),
                                      ],
                                    ),
                                  ),

                                  const Divider(height: 1),

                                  /// ================= SCROLLABLE CONTENT =================
                                  Expanded(
                                    child: SingleChildScrollView(
                                      controller: scrollController,
                                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [

                                          /// ===== BASIC INFO =====
                                          _buildDetailSection(
                                            'Basic Information',
                                            Icons.info_outline,
                                            [
                                              _buildDetailRow('Client Code', details.clientCode ?? '—'),
                                              _buildDetailRow('Firm Name', details.firmName ?? '—'),
                                              _buildDetailRow('Client Type', details.clientTypeCode ?? '—'),
                                              _buildDetailRow('Trader Name', details.traderName ?? '—'),
                                            ],
                                          ),


                                          /// ===== CONTACT INFO =====
                                          if (primaryContact != null)
                                            _buildDetailSection(
                                              'Contact Information',
                                              Icons.person_outline,
                                              [
                                                _buildDetailRow('Owner Name', primaryContact.name ?? '—'),
                                                _buildDetailRow('Phone', primaryContact.phone ?? '—'),
                                                if ((primaryContact.email ?? '').isNotEmpty)
                                                  _buildDetailRow('Email', primaryContact.email!),
                                              ],
                                            ),


                                          /// ===== BUSINESS INFO =====
                                          if (details.gstn != null)
                                            _buildDetailSection(
                                              'Business Information',
                                              Icons.business_outlined,
                                              [
                                                _buildDetailRow('GST Number', details.gstn!),
                                              ],
                                            ),


                                          /// ===== RECENT ACTIVITY =====
                                          _buildDetailSection(
                                            'Recent Activity',
                                            Icons.timeline_outlined,
                                            [
                                              _buildActivityItem(
                                                'Created On',
                                                details.createdAtDisplay ?? '—',
                                                Icons.event,
                                              ),
                                              _buildActivityItem(
                                                'Last Updated',
                                                details.updatedAtDisplay ?? '—',
                                                Icons.update,
                                              ),
                                              _buildActivityItem(
                                                'Total Locations',
                                                '${details.locations?.length ?? 0}',
                                                Icons.location_on_outlined,
                                              ),
                                            ],
                                          ),


                                          /// ===== LOCATIONS =====
                                          if (details.locations != null &&
                                              details.locations!.isNotEmpty) ...[
                                            const SizedBox(height: 8),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                const Text(
                                                  'Locations',
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                                OutlinedButton.icon(
                                                  onPressed: () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) => MultiBlocProvider(
                                                          providers: [
                                                            BlocProvider(
                                                              create: (context) => PostClientAddLocationBloc(),
                                                            ),
                                                            BlocProvider(
                                                              create: (context) => PostClientAddContactBloc(),
                                                            ),
                                                          ],
                                                          child: AddLocationScreen(
                                                            clientId: clientId,
                                                          ),
                                                        ),
                                                      ),
                                                    ).then((refresh) {
                                                      if (refresh == true) {
                                                        // Reload client details
                                                        context.read<GetClientDetailsBloc>().add(
                                                          FetchGetClientDetails(
                                                            clientId: clientId,
                                                            showLoader: false,
                                                          ),
                                                        );
                                                      }
                                                    });
                                                  },
                                                  icon: const Icon(Icons.add_location_outlined, size: 16),
                                                  label: const Text('Add Location', style: TextStyle(fontSize: 12)),
                                                  style: OutlinedButton.styleFrom(
                                                    foregroundColor: SessionManager.getUserRole() == "superadmin"
                                                        ? AppColors.superAdminPrimary
                                                        : SessionManager.getUserRole() == "admin"
                                                        ? AppColors.adminPrimary
                                                        : AppColors.primaryTealDark,
                                                    side: BorderSide(
                                                      color: SessionManager.getUserRole() == "superadmin"
                                                          ? AppColors.superAdminPrimary
                                                          : SessionManager.getUserRole() == "admin"
                                                          ? AppColors.adminPrimary
                                                          : AppColors.primaryTealDark,
                                                    ),
                                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 12),

                                            ...details.locations!.map(
                                                  (loc) => Container(
                                                margin: const EdgeInsets.only(bottom: 16),
                                                padding: const EdgeInsets.all(14),
                                                decoration: BoxDecoration(
                                                  color: AppColors.grey50,
                                                  borderRadius: BorderRadius.circular(14),
                                                ),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      loc.locationName ?? 'Location',
                                                      style: const TextStyle(fontWeight: FontWeight.w700),
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      '${loc.city ?? ''} ${loc.state ?? ''}',
                                                      style: TextStyle(color: Colors.grey.shade600),
                                                    ),

                                                    if (loc.contacts?.isNotEmpty == true) ...[
                                                      const SizedBox(height: 12),
                                                      Row(
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        children: [
                                                          const Text(
                                                            'Contacts',
                                                            style: TextStyle(fontWeight: FontWeight.w600),
                                                          ),
                                                          TextButton.icon(
                                                            onPressed: () {
                                                              Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                  builder: (context) => BlocProvider(
                                                                    create: (context) => PostClientAddContactBloc(),
                                                                    child: AddContactScreen(
                                                                      clientId: clientId,
                                                                      locationId: loc.id ?? '',
                                                                    ),
                                                                  ),
                                                                ),
                                                              ).then((refresh) {
                                                                if (refresh == true) {
                                                                  // Reload client details
                                                                  context.read<GetClientDetailsBloc>().add(
                                                                    FetchGetClientDetails(
                                                                      clientId: clientId,
                                                                      showLoader: false,
                                                                    ),
                                                                  );
                                                                }
                                                              });
                                                            },
                                                            icon: const Icon(Icons.add, size: 14),
                                                            label: const Text('Add', style: TextStyle(fontSize: 11)),
                                                            style: TextButton.styleFrom(
                                                              foregroundColor: SessionManager.getUserRole() == "superadmin"
                                                                  ? AppColors.superAdminPrimary
                                                                  : SessionManager.getUserRole() == "admin"
                                                                  ? AppColors.adminPrimary
                                                                  : AppColors.primaryTealDark,
                                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      ...loc.contacts!.map(
                                                            (c) => ListTile(
                                                          contentPadding: EdgeInsets.zero,
                                                          dense: true,
                                                          leading: const Icon(Icons.person_outline, size: 18),
                                                          title: Text(c.name ?? ''),
                                                          subtitle: Text(c.phone ?? ''),
                                                          trailing: IconButton(
                                                            icon: const Icon(Icons.call,
                                                                color: AppColors.primaryTeal, size: 18),
                                                            onPressed: () {
                                                              Navigator.pop(context);
                                                              _callClient(c.phone ?? '');
                                                            },
                                                          ),
                                                        ),
                                                      ),
                                                    ] else ...[
                                                      const SizedBox(height: 12),
                                                      Row(
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        children: [
                                                          const Text(
                                                            'Contacts',
                                                            style: TextStyle(fontWeight: FontWeight.w600),
                                                          ),
                                                          TextButton.icon(
                                                            onPressed: () {
                                                              Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                  builder: (context) => BlocProvider(
                                                                    create: (context) => PostClientAddContactBloc(),
                                                                    child: AddContactScreen(
                                                                      clientId: clientId,
                                                                      locationId: loc.id ?? '',
                                                                    ),
                                                                  ),
                                                                ),
                                                              ).then((refresh) {
                                                                if (refresh == true) {
                                                                  // Reload client details
                                                                  context.read<GetClientDetailsBloc>().add(
                                                                    FetchGetClientDetails(
                                                                      clientId: clientId,
                                                                      showLoader: false,
                                                                    ),
                                                                  );
                                                                }
                                                              });
                                                            },
                                                            icon: const Icon(Icons.add, size: 14),
                                                            label: const Text('Add Contact', style: TextStyle(fontSize: 11)),
                                                            style: TextButton.styleFrom(
                                                              foregroundColor: SessionManager.getUserRole() == "superadmin"
                                                                  ? AppColors.superAdminPrimary
                                                                  : SessionManager.getUserRole() == "admin"
                                                                  ? AppColors.adminPrimary
                                                                  : AppColors.primaryTealDark,
                                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      const SizedBox(height: 8),
                                                      Text(
                                                        'No contacts added yet',
                                                        style: TextStyle(
                                                          color: Colors.grey.shade600,
                                                          fontSize: 13,
                                                          fontStyle: FontStyle.italic,
                                                        ),
                                                      ),
                                                    ],
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],

                                          const SizedBox(height: 80), // space for buttons
                                        ],
                                      ),
                                    ),
                                  ),

                                  /// ================= FIXED ACTION BUTTONS =================
                                  Container(
                                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black12,
                                          blurRadius: 8,
                                          offset: Offset(0, -2),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: OutlinedButton.icon(
                                            onPressed: () {
                                              Navigator.pop(context);
                                              _editClient(details);
                                            },
                                            icon: const Icon(Icons.edit_outlined, size: 18),
                                            label: const Text('Edit Client'),
                                            style: OutlinedButton.styleFrom(
                                              foregroundColor: SessionManager.getUserRole() =="superadmin"?AppColors.superAdminPrimary:SessionManager.getUserRole() =="admin"?
                                              AppColors.adminPrimary :AppColors.primaryTealDark,
                                              side: BorderSide(color:SessionManager.getUserRole() =="superadmin"?AppColors.superAdminPrimary:SessionManager.getUserRole() =="admin"?
                                              AppColors.adminPrimary :AppColors.primaryTealDark),
                                              padding: const EdgeInsets.symmetric(vertical: 12),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: ElevatedButton.icon(
                                            onPressed: () {
                                              Navigator.pop(context);
                                              if (primaryContact?.phone != null) {
                                                _callClient(primaryContact!.phone!);
                                              }
                                            },
                                            icon: const Icon(Icons.call, size: 18),
                                            label: const Text('Call'),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: SessionManager.getUserRole() =="superadmin"?AppColors.superAdminPrimary:SessionManager.getUserRole() =="admin"?
                                              AppColors.adminPrimary :AppColors.primaryTealDark,
                                              foregroundColor: Colors.white,
                                              padding: const EdgeInsets.symmetric(vertical: 12),
                                              elevation: 0,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              );

                            },
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  //
  // void _viewClientDetails(Map<String, dynamic> client) {
  //   showModalBottomSheet(
  //     context: context,
  //     isScrollControlled: true,
  //     shape: const RoundedRectangleBorder(
  //       borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
  //     ),
  //     builder: (context) {
  //       return DraggableScrollableSheet(
  //         initialChildSize: 0.7,
  //         maxChildSize: 0.9,
  //         minChildSize: 0.5,
  //         builder: (context, scrollController) {
  //           return Container(
  //             padding: const EdgeInsets.all(16),
  //             child: Column(
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 // Header
  //                 Row(
  //                   children: [
  //                     Expanded(
  //                       child: Column(
  //                         crossAxisAlignment: CrossAxisAlignment.start,
  //                         children: [
  //                           Text(
  //                             client['name'],
  //                             style: const TextStyle(
  //                               fontSize: 20,
  //                               fontWeight: FontWeight.bold,
  //                               color: AppColors.textPrimary,
  //                             ),
  //                           ),
  //                           const SizedBox(height: 4),
  //                           Container(
  //                             padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
  //                             decoration: BoxDecoration(
  //                               color: _getTypeColor(client['type']).withOpacity(0.1),
  //                               borderRadius: BorderRadius.circular(8),
  //                             ),
  //                             child: Text(
  //                               client['type'],
  //                               style: TextStyle(
  //                                 fontSize: 12,
  //                                 fontWeight: FontWeight.w600,
  //                                 color: _getTypeColor(client['type']),
  //                               ),
  //                             ),
  //                           ),
  //                         ],
  //                       ),
  //                     ),
  //                     IconButton(
  //                       onPressed: () => Navigator.pop(context),
  //                       icon: const Icon(Icons.close),
  //                     ),
  //                   ],
  //                 ),
  //                 const SizedBox(height: 16),
  //
  //                 // Details
  //                 Expanded(
  //                   child: SingleChildScrollView(
  //                     controller: scrollController,
  //                     child: Column(
  //                       crossAxisAlignment: CrossAxisAlignment.start,
  //                       children: [
  //                         _buildDetailSection('Basic Information', [
  //                           _buildDetailRow('Client Name', client['name']),
  //                           _buildDetailRow('Client Type', client['type']),
  //                           _buildDetailRow('Location', client['location']),
  //                         ]),
  //                         const SizedBox(height: 24),
  //
  //                         _buildDetailSection('Contact Information', [
  //                           _buildDetailRow('Owner Name', client['ownerName']),
  //                           _buildDetailRow('Phone', client['ownerPhone']),
  //                           if (client['email'].isNotEmpty)
  //                             _buildDetailRow('Email', client['email']),
  //                         ]),
  //
  //                         if (client['gstNumber'].isNotEmpty) ...[
  //                           const SizedBox(height: 24),
  //                           _buildDetailSection('Business Information', [
  //                             _buildDetailRow('GST Number', client['gstNumber']),
  //                           ]),
  //                         ],
  //
  //                         const SizedBox(height: 24),
  //                         // _buildDetailSection('Recent Activity', [
  //                         //   _buildActivityItem('Last meeting', '10 Dec 2025', Icons.meeting_room_outlined),
  //                         //   _buildActivityItem('Lead created', 'L-2025-020', Icons.star_outline),
  //                         //   _buildActivityItem('Total meetings', '5', Icons.history),
  //                         // ]),
  //
  //                       ],
  //                     ),
  //                   ),
  //                 ),
  //
  //                 // Action buttons
  //                 const SizedBox(height: 16),
  //                 Row(
  //                   children: [
  //                     Expanded(
  //                       child: OutlinedButton.icon(
  //                         onPressed: () {
  //                           Navigator.pop(context);
  //                           _editClient(client);
  //                         },
  //                         icon: const Icon(Icons.edit_outlined, size: 18),
  //                         label: Text(
  //                           'Edit Client',
  //                           style: TextStyle(
  //                             fontWeight: FontWeight.w500,
  //                           ),
  //                         ),
  //                         style: OutlinedButton.styleFrom(
  //                           foregroundColor: AppColors.primaryTeal,
  //                           side: const BorderSide(color: AppColors.primaryTeal),
  //                           padding: const EdgeInsets.symmetric(vertical: 12),
  //                         ),
  //                       ),
  //                     ),
  //                     const SizedBox(width: 12),
  //                     Expanded(
  //                       child: ElevatedButton.icon(
  //                         onPressed: () {
  //                           Navigator.pop(context);
  //                           _callClient(client['ownerPhone']);
  //                         },
  //                         icon: const Icon(Icons.call, size: 18),
  //                         label: Text(
  //                           'Call',
  //                           style: TextStyle(
  //                             fontWeight: FontWeight.w600,
  //                           ),
  //                         ),
  //                         style: ElevatedButton.styleFrom(
  //                           backgroundColor: AppColors.primaryTeal,
  //                           foregroundColor: AppColors.white,
  //                           padding: const EdgeInsets.symmetric(vertical: 12),
  //                           elevation: 0,
  //                         ),
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               ],
  //             ),
  //           );
  //         },
  //       );
  //     },
  //   );
  // }

  Widget _buildDetailSection1(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildDetailSection(String title, IconData icon, List<Widget> children) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
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
              Icon(icon, size: 18, color: SessionManager.getUserRole() =="superadmin"?AppColors.superAdminPrimary:SessionManager.getUserRole() =="admin"?
              AppColors.adminPrimary :AppColors.primaryTealDark),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            flex: 6,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow1(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.textSecondary),
          const SizedBox(width: 8),
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _editClient(GetClientIdDetailsResponseBody.Data client) async {

   final result = await context.pushNamed(
      'addClientScreen',
      extra: {'existingClient': client},
    );
   if (result == true){
     _loadClientList(showLoader: true);
   }
  }

  void _callClient(String phoneNumber) async {
    try {
      // Clean phone number - remove spaces, dashes, etc.
      final cleanedNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');

      if (cleanedNumber.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Invalid phone number'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      // Try DIAL action first (user-initiated, doesn't require CALL_PHONE permission)
      final Uri dialUri = Uri(scheme: 'tel', path: cleanedNumber);

      if (await canLaunchUrl(dialUri)) {
        await launchUrl(
          dialUri,
          mode: LaunchMode.externalApplication,
        );
      } else {
        // Fallback: Try CALL action (requires CALL_PHONE permission)
        final PermissionStatus status = await Permission.phone.request();

        if (!status.isGranted) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Phone call permission is required'),
                backgroundColor: Colors.orange,
                action: SnackBarAction(
                  label: 'Settings',
                  onPressed: () {
                    openAppSettings();
                  },
                ),
              ),
            );
          }
          return;
        }

        // Try launching with CALL intent
        if (!await launchUrl(dialUri, mode: LaunchMode.externalApplication)) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Could not call $cleanedNumber'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Original _buildClientCard method to render local sample items (fallback UI)
  Widget _buildClientCard(Data client, int index) {
    final name = client.firmName ?? 'N/A';
    final type = client.clientTypeCode ?? 'Other';
    final location = client.city?? 'Unknown';
    // final ownerPhone = client['ownerPhone'] ?? '';
    // final ownerName = client['ownerName'] ?? 'N/A';
    // final gstNumber = client['gstNumber'] ?? '';
    // final email = client['email'] ?? '';

    Color typeColor;
    switch (type) {
      case 'Builder':
        typeColor = AppColors.primaryTeal;
        break;
      case 'Architect':
        typeColor = AppColors.accentPurple;
        break;
      case 'Interior':
        typeColor = AppColors.accentAmber;
        break;
      default:
        typeColor = AppColors.textSecondary;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // show simple details bottom sheet
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              builder: (context) {
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Row(children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: typeColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(type, style: TextStyle(color: typeColor, fontWeight: FontWeight.w600)),
                        ),
                        const SizedBox(width: 12),
                        Text(location, style: const TextStyle(color: Colors.grey)),
                      ]),
                      // const SizedBox(height: 12),
                      // Text('Owner: $ownerName'),
                      // Text('Phone: $ownerPhone'),
                      // if (email.isNotEmpty) Text('Email: $email'),
                      // if (gstNumber.isNotEmpty) Text('GST: $gstNumber'),
                      // const SizedBox(height: 12),
                      // Align(
                      //   alignment: Alignment.centerRight,
                      //   child: ElevatedButton(
                      //     onPressed: () => Navigator.pop(context),
                      //     style: ElevatedButton.styleFrom(
                      //       backgroundColor: AppColors.primaryTeal,
                      //     ),
                      //     child: const Text('Close'),
                      //   ),
                      // ),
                    ],
                  ),
                );
              },
            );
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: typeColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        type,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: typeColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      location,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(delay: (index * 100).ms).slideX(begin: 0.3, end: 0);
  }
}
