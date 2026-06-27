import 'package:dio/dio.dart';
import 'package:scamshield/core/constants/app_constants.dart';
import 'package:scamshield/src/models/analysis_request.dart';
import 'package:scamshield/src/models/analysis_response.dart';
import 'package:scamshield/src/models/family_alert_response.dart';

class ScamShieldApi {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: AppConstants.apiBaseUrl,
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 60),
  ));

  Future<AnalysisResponse> analyze(AnalysisRequest request) async {
    final resp = await _dio.post('/analyze', data: request.toJson());
    return AnalysisResponse.fromJson(resp.data as Map<String, dynamic>);
  }

  Future<AnalysisResponse> chat({
    required String text,
    required List<Map<String, dynamic>> history,
  }) async {
    final resp = await _dio.post('/chat', data: {
      'text': text,
      'history': history,
    });
    return AnalysisResponse.fromJson(resp.data as Map<String, dynamic>);
  }

  Future<AnalysisResponse> analyzeContract(String imageBase64) async {
    final resp = await _dio.post('/contract', data: {
      'image_base64': imageBase64,
    });
    return AnalysisResponse.fromJson(resp.data as Map<String, dynamic>);
  }

  Future<FamilyAlertResponse> generateFamilyAlert(
      AnalysisResponse analysis) async {
    final resp = await _dio.post('/family-alert', data: {
      'risk_level': analysis.riskLevel.name,
      'case_type': analysis.caseType,
      'stage': analysis.stage,
      'red_flags': analysis.redFlags
          .map((f) => {'type': f.type, 'detail': f.detail})
          .toList(),
      'manipulation_tactics': analysis.manipulationTactics,
      'next_actions': analysis.nextActions,
    });
    return FamilyAlertResponse.fromJson(resp.data as Map<String, dynamic>);
  }
}
