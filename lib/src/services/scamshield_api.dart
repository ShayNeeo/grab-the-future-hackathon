import 'package:dio/dio.dart';
import 'package:justful/core/constants/app_constants.dart';
import 'package:justful/src/models/analysis_request.dart';
import 'package:justful/src/models/analysis_response.dart';

class JustfulApi {
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
}
