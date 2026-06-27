import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:justifty/src/models/analysis_request.dart';
import 'package:justifty/src/models/analysis_response.dart';
import 'package:justifty/src/services/scamshield_api.dart';

final apiProvider = Provider<JustfulApi>((ref) => JustfulApi());

class ChatMessage {
  final String role; // 'user' | 'assistant'
  final String text;
  final String? imageBase64;
  final AnalysisResponse? response;

  const ChatMessage({
    required this.role,
    required this.text,
    this.imageBase64,
    this.response,
  });
}

class ChatNotifier extends StateNotifier<AsyncValue<List<ChatMessage>>> {
  ChatNotifier(this._api) : super(const AsyncValue.data([]));

  final JustfulApi _api;

  List<Map<String, dynamic>> get _history {
    final messages = state.valueOrNull ?? [];
    return messages
        .where((m) => m.response == null)
        .map((m) => {'role': m.role, 'content': m.text})
        .toList();
  }

  Future<void> send({required String text, String? imageBase64}) async {
    final current = state.valueOrNull ?? [];
    final userMsg = ChatMessage(
      role: 'user',
      text: text,
      imageBase64: imageBase64,
    );
    state = AsyncValue.data([...current, userMsg]);
    state = const AsyncValue.loading();
    try {
      final response = await _api.analyze(AnalysisRequest(
        text: text,
        imageBase64: imageBase64,
        history: _history,
      ));
      final assistantMsg = ChatMessage(
        role: 'assistant',
        text: response.suggestedReply,
        response: response,
      );
      state = AsyncValue.data([...current, userMsg, assistantMsg]);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  void reset() => state = const AsyncValue.data([]);
}

final chatProvider =
    StateNotifierProvider<ChatNotifier, AsyncValue<List<ChatMessage>>>(
  (ref) => ChatNotifier(ref.watch(apiProvider)),
);
