import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:justful/src/models/analysis_request.dart';
import 'package:justful/src/models/analysis_response.dart';
import 'package:justful/src/services/justful_api.dart';

final apiProvider = Provider<JustfulApi>((ref) => JustfulApi());

class ChatMessage {
  final String role; // 'user' | 'assistant'
  final String text;
  final String? imageBase64;
  final AnalysisResponse? response;
  final List<String> followUpQuestions;
  final bool isStreaming;
  final String thinkingText;

  const ChatMessage({
    required this.role,
    required this.text,
    this.imageBase64,
    this.response,
    this.followUpQuestions = const [],
    this.isStreaming = false,
    this.thinkingText = '',
  });

  ChatMessage copyWith({
    String? text,
    AnalysisResponse? response,
    List<String>? followUpQuestions,
    bool? isStreaming,
    String? thinkingText,
  }) => ChatMessage(
        role: role,
        text: text ?? this.text,
        imageBase64: imageBase64,
        response: response ?? this.response,
        followUpQuestions: followUpQuestions ?? this.followUpQuestions,
        isStreaming: isStreaming ?? this.isStreaming,
        thinkingText: thinkingText ?? this.thinkingText,
      );
}

class ChatNotifier extends StateNotifier<AsyncValue<List<ChatMessage>>> {
  ChatNotifier(this._api) : super(const AsyncValue.data([]));

  final JustfulApi _api;
  bool _isSending = false;

  bool get isSending => _isSending;

  /// Build conversation history for the backend.
  /// Includes both user messages and assistant replies so the AI
  /// has full context for re-analysis in the agentic loop.
  List<Map<String, dynamic>> get _history {
    final messages = state.valueOrNull ?? [];
    return messages
        .where((m) => m.role == 'user' || (m.role == 'assistant' && m.response != null))
        .map((m) {
          if (m.role == 'assistant' && m.response != null) {
            return {'role': 'assistant', 'content': m.response!.suggestedReply};
          }
          return {'role': m.role, 'content': m.text};
        }).toList();
  }

  Future<void> send({required String text, String? imageBase64}) async {
    if (_isSending) return;
    _isSending = true;
    final current = state.valueOrNull ?? [];
    final userMsg = ChatMessage(
      role: 'user',
      text: text,
      imageBase64: imageBase64,
    );
    final assistantMsg = ChatMessage(
      role: 'assistant',
      text: '',
      isStreaming: true,
      thinkingText: 'Đang chuẩn bị phân tích...',
    );
    
    // Set UI state with user and empty streaming assistant messages
    final withUser = [...current, userMsg, assistantMsg];
    state = AsyncValue.data(withUser);

    try {
      final stream = _api.analyzeStream(AnalysisRequest(
        text: text,
        imageBase64: imageBase64,
        history: _history,
      ));

      String accumulated = '';
      await for (final chunk in stream) {
        accumulated += chunk;
        
        // Parse accumulated text to split thoughts and JSON
        String thinkingText = '';
        String jsonText = '';
        
        if (accumulated.contains('<thought>')) {
          final thoughtStart = accumulated.indexOf('<thought>') + 9;
          if (accumulated.contains('</thought>')) {
            final thoughtEnd = accumulated.indexOf('</thought>');
            thinkingText = accumulated.substring(thoughtStart, thoughtEnd).trim();
            jsonText = accumulated.substring(thoughtEnd + 10).trim();
          } else {
            thinkingText = accumulated.substring(thoughtStart).trim();
          }
        } else {
          jsonText = accumulated.trim();
        }

        // Clean up markdown formatting if the model wraps it
        if (thinkingText.contains('</thought>')) {
          thinkingText = thinkingText.split('</thought>').first.trim();
        }

        // Update the last message in real-time
        final updatedList = List<ChatMessage>.from(state.valueOrNull ?? []);
        if (updatedList.isNotEmpty) {
          updatedList[updatedList.length - 1] = assistantMsg.copyWith(
            text: jsonText.isNotEmpty ? 'Đang tổng hợp kết quả...' : '',
            thinkingText: thinkingText,
            isStreaming: true,
          );
          state = AsyncValue.data(updatedList);
        }
      }

      // Stream completed. Extract final JSON
      String jsonText = accumulated;
      if (accumulated.contains('</thought>')) {
        jsonText = accumulated.split('</thought>').last.trim();
      }
      
      final start = jsonText.indexOf('{');
      final end = jsonText.lastIndexOf('}');
      if (start != -1 && end != -1 && end >= start) {
        jsonText = jsonText.substring(start, end + 1);
      }

      final repairedJson = _repairJson(jsonText);
      final response = AnalysisResponse.fromJson(
        json.decode(repairedJson) as Map<String, dynamic>
      );

      final hasFollowUps = response.followUpQuestions.isNotEmpty;
      final finalMsg = assistantMsg.copyWith(
        text: response.explanation, // friendly explanation instead of suggested_reply
        response: response,
        followUpQuestions: hasFollowUps ? response.followUpQuestions : const [],
        isStreaming: false,
      );

      final updatedList = List<ChatMessage>.from(state.valueOrNull ?? []);
      if (updatedList.isNotEmpty) {
        updatedList[updatedList.length - 1] = finalMsg;
        state = AsyncValue.data(updatedList);
      }
    } catch (e) {
      final updatedList = List<ChatMessage>.from(state.valueOrNull ?? []);
      if (updatedList.isNotEmpty) {
        updatedList[updatedList.length - 1] = ChatMessage(
          role: 'assistant',
          text: '⚠️ Không thể kết nối hoặc phân tích lỗi: $e. Vui lòng thử lại.',
          isStreaming: false,
        );
        state = AsyncValue.data(updatedList);
      }
    } finally {
      _isSending = false;
    }
  }

  void reset() => state = const AsyncValue.data([]);
}

String _repairJson(String jsonStr) {
  jsonStr = jsonStr.trim();
  if (jsonStr.isEmpty) return '{}';
  
  List<String> stack = [];
  bool inQuote = false;
  bool escaped = false;
  List<String> repaired = [];
  
  for (int i = 0; i < jsonStr.length; i++) {
    String char = jsonStr[i];
    if (inQuote) {
      if (escaped) {
        escaped = false;
      } else if (char == '\\') {
        escaped = true;
      } else if (char == '"') {
        inQuote = false;
      }
      repaired.add(char);
    } else {
      if (char == '"') {
        inQuote = true;
      } else if (char == '{' || char == '[') {
        stack.add(char);
      } else if (char == '}' || char == ']') {
        if (stack.isNotEmpty) {
          stack.removeLast();
        }
      }
      repaired.add(char);
    }
  }
  
  if (inQuote) {
    repaired.add('"');
  }
  
  String repairedStr = repaired.join('').trim();
  
  while (repairedStr.endsWith(',')) {
    repairedStr = repairedStr.substring(0, repairedStr.length - 1).trim();
  }
  
  while (stack.isNotEmpty) {
    String opener = stack.removeLast();
    if (opener == '{') {
      repairedStr += '}';
    } else if (opener == '[') {
      repairedStr += ']';
    }
  }
  
  return repairedStr;
}

final chatProvider =
    StateNotifierProvider<ChatNotifier, AsyncValue<List<ChatMessage>>>(
  (ref) => ChatNotifier(ref.watch(apiProvider)),
);
