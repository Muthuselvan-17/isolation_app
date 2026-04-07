import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rabis_abc_center/core/router/app_router.dart';
import 'package:rabis_abc_center/features/dashboard/presentation/providers/dashboard_notifier.dart';
import 'package:rabis_abc_center/common/widgets/barcode_scanner_screen.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  Future<void> _searchAndNavigate(BuildContext context, WidgetRef ref, String query) async {
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      await ref.read(dashboardProvider.notifier).loadDogs(ephemeralId: query);
      
      if (!context.mounted) return;
      Navigator.pop(context); // Close loading

      final dogs = ref.read(dashboardProvider).dogs;
      if (dogs.isNotEmpty) {
        Navigator.pushNamed(
          context,
          AppRouter.dogDetails,
          arguments: dogs.first.id,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No dog found with this Token/ID')),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      Navigator.pop(context); // Close loading
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _onScan(BuildContext context, WidgetRef ref) async {
    final String? code = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const BarcodeScannerScreen()),
    );

    if (code != null && code.isNotEmpty && context.mounted) {
      await _searchAndNavigate(context, ref, code);
    }
  }

  void _showManualEntryDialog(BuildContext context, WidgetRef ref) {
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
                _searchAndNavigate(context, ref, val);
              }
            },
            child: const Text('Search'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                          title: Text('Dog ID: ${dog.ephemeralId}'),
                          subtitle: Text('Ward: ${dog.ward} / District: ${dog.district}'),
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              AppRouter.dogDetails,
                              arguments: dog.id,
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
            onPressed: () => _showManualEntryDialog(context, ref),
            tooltip: 'Manual Entry',
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            heroTag: 'scan',
            onPressed: () => _onScan(context, ref),
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
