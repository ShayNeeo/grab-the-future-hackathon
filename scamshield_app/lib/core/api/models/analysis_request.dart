class AnalysisRequest {
  final String text;
  final String? imageBase64;
  final List<Map<String, dynamic>> history;

  const AnalysisRequest({
    required this.text,
    this.imageBase64,
    this.history = const [],
  });

  Map<String, dynamic> toJson() => {
        'text': text,
        if (imageBase64 != null) 'image_base64': imageBase64,
        'history': history,
      };
}
