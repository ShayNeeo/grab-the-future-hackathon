import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kCoolingOffKey = 'cooling_off_deadline_ms';

class CoolingOffNotifier extends StateNotifier<DateTime?> {
  CoolingOffNotifier() : super(null) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final ms = prefs.getInt(_kCoolingOffKey);
    if (ms != null) {
      final deadline = DateTime.fromMillisecondsSinceEpoch(ms);
      if (deadline.isAfter(DateTime.now())) state = deadline;
    }
  }

  Future<void> start({int hours = 48}) async {
    final deadline = DateTime.now().add(Duration(hours: hours));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kCoolingOffKey, deadline.millisecondsSinceEpoch);
    state = deadline;
  }

  Future<void> cancel() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kCoolingOffKey);
    state = null;
  }

  bool get isActive => state != null && state!.isAfter(DateTime.now());

  Duration get remaining =>
      isActive ? state!.difference(DateTime.now()) : Duration.zero;
}

final coolingOffProvider =
    StateNotifierProvider<CoolingOffNotifier, DateTime?>(
  (ref) => CoolingOffNotifier(),
);
