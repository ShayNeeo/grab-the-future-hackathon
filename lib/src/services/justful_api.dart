import 'dart:convert';
import 'dart:typed_data';
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

  Stream<String> analyzeStream(AnalysisRequest request) async* {
    final response = await _dio.post<ResponseBody>(
      '/analyze',
      data: request.toJson(),
      options: Options(responseType: ResponseType.stream),
    );
    await for (final chunk in response.data!.stream) {
      yield utf8.decode(chunk);
    }
  }

  Stream<String> chatStream({
    required String text,
    required List<Map<String, dynamic>> history,
  }) async* {
    final response = await _dio.post<ResponseBody>(
      '/chat',
      data: {
        'text': text,
        'history': history,
      },
      options: Options(responseType: ResponseType.stream),
    );
    await for (final chunk in response.data!.stream) {
      yield utf8.decode(chunk);
    }
  }

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

  /// Gửi audio bytes lên Gemini Flash để nhận dạng giọng nói tiếng Việt.
  Future<String> transcribeAudio(Uint8List audioBytes,
      {String mimeType = 'audio/mp4'}) async {
    final audio64 = base64Encode(audioBytes);
    final resp = await _dio.post<Map<String, dynamic>>(
      '/transcribe',
      data: {'audio_base64': audio64, 'mime_type': mimeType},
      options: Options(receiveTimeout: const Duration(seconds: 30)),
    );
    return ((resp.data?['text'] as String?) ?? '').trim();
  }
}
