import 'package:flutter/material.dart';
import 'package:live_activities/live_activities.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Live Activities Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Pizza Delivery Tracker'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _liveActivitiesPlugin = LiveActivities();
  String? _activityId;
  String _status = 'idle';

  static const _appGroupId = 'group.example.liveActivitiesSample';

  final Map<String, dynamic> _pizzaOrder = {
    'name': 'Margherita',
    'ingredient': 'Tomato, Mozzarella, Basil',
    'quantity': 2,
  };

  Future<void> _startActivity() async {
    try {
      await _liveActivitiesPlugin.init(appGroupId: _appGroupId);

      final data = Map<String, dynamic>.from(_pizzaOrder)
        ..['status'] = 'preparing'
        ..['startedAt'] = DateTime.now().toIso8601String();

      final activityId = await _liveActivitiesPlugin.createActivity('', data);
      setState(() {
        _activityId = activityId;
        _status = 'preparing';
      });
    } catch (e) {
      debugPrint('startActivity error: $e');
    }
  }

  Future<void> _updateStatus(String newStatus) async {
    if (_activityId == null) return;
    try {
      await _liveActivitiesPlugin.updateActivity(
        _activityId!,
        {'status': newStatus},
      );
      setState(() => _status = newStatus);
    } catch (e) {
      debugPrint('updateStatus error: $e');
    }
  }

  Future<void> _endActivity() async {
    if (_activityId == null) return;
    try {
      await _liveActivitiesPlugin.updateActivity(
        _activityId!,
        {'status': 'delivered'},
      );
      await _liveActivitiesPlugin.endActivity(_activityId!);
      setState(() {
        _activityId = null;
        _status = 'idle';
      });
    } catch (e) {
      debugPrint('endActivity error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Pizza Order', style: theme.textTheme.titleMedium),
                    const SizedBox(height: 12),
                    _dataRow('Name', _pizzaOrder['name']),
                    _dataRow('Ingredients', _pizzaOrder['ingredient']),
                    _dataRow('Quantity', '${_pizzaOrder['quantity']}'),
                    if (_status != 'idle') ...[
                      const Divider(height: 24),
                      _dataRow('Status', _status.toUpperCase()),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (_status == 'idle')
              FilledButton.icon(
                onPressed: _startActivity,
                icon: const Icon(Icons.play_arrow),
                label: const Text('Start Live Activity'),
              ),
            if (_status == 'preparing')
              FilledButton.icon(
                onPressed: () => _updateStatus('baking'),
                icon: const Icon(Icons.local_fire_department),
                label: const Text('Start Baking'),
              ),
            if (_status == 'baking')
              FilledButton.icon(
                onPressed: () => _updateStatus('delivering'),
                icon: const Icon(Icons.bike_scooter),
                label: const Text('Out for Delivery'),
              ),
            if (_status == 'delivering')
              FilledButton.icon(
                onPressed: _endActivity,
                icon: const Icon(Icons.check_circle),
                label: const Text('Delivered & End Activity'),
              ),
            if (_status != 'idle') ...[
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _endActivity,
                icon: const Icon(Icons.stop),
                label: const Text('End Activity Now'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _dataRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
