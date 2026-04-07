import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rabis_abc_center/core/router/app_router.dart';
import 'package:rabis_abc_center/features/dashboard/presentation/providers/dashboard_notifier.dart';
import 'package:rabis_abc_center/common/widgets/barcode_scanner_screen.dart';
import 'package:rabis_abc_center/features/auth/presentation/providers/auth_notifier.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Load dogs on initial screen entry
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(dashboardProvider.notifier).loadDogs();
    });
  }

  Future<void> _searchAndNavigate(BuildContext context, String query) async {
    try {
      await ref.read(dashboardProvider.notifier).loadDogs(ephemeralId: query);
      
      if (!mounted) return;

      final dogs = ref.read(dashboardProvider).dogs;
      if (dogs.isNotEmpty) {
        Navigator.pushNamed(
          context,
          AppRouter.dogDetails,
          arguments: dogs.first,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No dog found with this Token/ID')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _onScan(BuildContext context) async {
    final String? code = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const BarcodeScannerScreen()),
    );

    if (code != null && code.isNotEmpty && mounted) {
      await _searchAndNavigate(context, code);
    }
  }

  void _showManualEntryDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Manual Token Entry'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Enter Token Number / Ephemeral ID',
            hintText: 'e.g. 05252099',
          ),
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final val = controller.text.trim();
              if (val.isNotEmpty) {
                Navigator.pop(context);
                _searchAndNavigate(context, val);
              }
            },
            child: const Text('Search'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(dashboardProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('ABC Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: DogSearchDelegate(ref),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(dashboardProvider.notifier).loadDogs(),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Confirm Logout'),
                  content: const Text('Are you sure you want to log out?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Logout', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );

              if (confirm == true && context.mounted) {
                await ref.read(authProvider.notifier).logout();
                if (context.mounted) {
                  Navigator.pushReplacementNamed(context, AppRouter.login);
                }
              }
            },
          ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(state.error!, style: const TextStyle(color: Colors.red)),
                      ElevatedButton(
                        onPressed: () => ref.read(dashboardProvider.notifier).loadDogs(),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : state.dogs.isEmpty
                  ? const Center(child: Text('No dogs found.'))
                  : ListView.builder(
                      itemCount: state.dogs.length,
                      itemBuilder: (context, index) {
                        final dog = state.dogs[index];
                        return ListTile(
                          leading: dog.imageUrl != null
                              ? CircleAvatar(backgroundImage: NetworkImage(dog.imageUrl!))
                              : const CircleAvatar(child: Icon(Icons.pets)),
                          title: Text('ID: ${dog.ephemeralId}'),
                          subtitle: Text(dog.name ?? 'No Name'),
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              AppRouter.dogDetails,
                              arguments: dog,
                            );
                          },
                        );
                      },
                    ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'manual',
            onPressed: () => _showManualEntryDialog(context),
            tooltip: 'Manual Entry',
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            heroTag: 'scan',
            onPressed: () => _onScan(context),
            tooltip: 'Scan QR/Barcode',
            child: const Icon(Icons.qr_code_scanner),
          ),
        ],
      ),
    );
  }
}

class DogSearchDelegate extends SearchDelegate {
  final WidgetRef ref;

  DogSearchDelegate(this.ref);

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () => query = '',
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    // Perform search via provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(dashboardProvider.notifier).loadDogs(ephemeralId: query);
      close(context, null);
    });
    return const Center(child: CircularProgressIndicator());
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return const Center(child: Text('Search by Ephemeral ID or Token No.'));
  }
}
