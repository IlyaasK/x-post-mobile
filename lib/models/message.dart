class Message {
  final String text;
  final DateTime timestamp;
  bool isSent;
  bool isError;
  final List<String> imagePaths;

  Message({
    required this.text,
    required this.timestamp,
    this.isSent = false,
    this.isError = false,
    this.imagePaths = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'timestamp': timestamp.toIso8601String(),
      'isSent': isSent,
      'isError': isError,
      'imagePaths': imagePaths,
    };
  }

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      text: json['text'] ?? '',
      timestamp: DateTime.parse(json['timestamp']),
      isSent: json['isSent'] ?? false,
      isError: json['isError'] ?? false,
      imagePaths: List<String>.from(json['imagePaths'] ?? []),
    );
  }
}
