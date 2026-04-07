import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rabis_abc_center/features/dog_details/presentation/providers/dog_details_notifier.dart';

class FeedingSection extends ConsumerWidget {
  const FeedingSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(feedingProvider);
    final notifier = ref.read(feedingProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Feeding Behaviour',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextButton.icon(
              onPressed: notifier.addDay,
              icon: const Icon(Icons.add),
              label: const Text('Add Day'),
            ),
          ],
        ),
        ...state.history.map((feeding) => Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Row(
            children: [
              Text('Day ${feeding.day}', style: const TextStyle(fontWeight: FontWeight.w500)),
              const Spacer(),
              const Text('Food'),
              Checkbox(
                value: feeding.food,
                onChanged: (val) => notifier.updateFeeding(feeding.day, val, feeding.water),
              ),
              const SizedBox(width: 8),
              const Text('Water'),
              Checkbox(
                value: feeding.water,
                onChanged: (val) => notifier.updateFeeding(feeding.day, feeding.food, val),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () => notifier.removeDay(feeding.day),
                icon: const Icon(Icons.delete, color: Colors.red),
                tooltip: 'Remove Day',
              ),
            ],
          ),
        )),
      ],
    );
  }
}
