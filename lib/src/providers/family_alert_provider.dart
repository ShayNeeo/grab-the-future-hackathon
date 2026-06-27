import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scamshield/src/models/analysis_response.dart';
import 'package:scamshield/src/models/family_alert_response.dart';
import 'package:scamshield/src/services/scamshield_api.dart';

class FamilyAlertNotifier
    extends StateNotifier<AsyncValue<FamilyAlertResponse?>> {
  FamilyAlertNotifier() : super(const AsyncValue.data(null));

  final _api = ScamShieldApi();

  Future<void> generate(AnalysisResponse analysis) async {
    state = const AsyncValue.loading();
    try {
      final alert = await _api.generateFamilyAlert(analysis);
      state = AsyncValue.data(alert);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  void reset() => state = const AsyncValue.data(null);
}

final familyAlertProvider = StateNotifierProvider.autoDispose<
    FamilyAlertNotifier, AsyncValue<FamilyAlertResponse?>>(
  (_) => FamilyAlertNotifier(),
);
