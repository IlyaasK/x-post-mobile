class Message {
  final String text;
  final DateTime timestamp;
  bool isSent;
  bool isError;
  String? tweetId;
  final List<Message> replies;
  final List<String> imagePaths;

  Message({
    required this.text,
    required this.timestamp,
    this.isSent = false,
    this.isError = false,
    this.imagePaths = const [],
    this.tweetId,
    this.replies = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'timestamp': timestamp.toIso8601String(),
      'isSent': isSent,
      'isError': isError,
      'imagePaths': imagePaths,
      'tweetId': tweetId,
      'replies': replies.map((r) => r.toJson()).toList(),
    };
  }

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      text: json['text'] ?? '',
      timestamp: DateTime.parse(json['timestamp']),
      isSent: json['isSent'] ?? false,
      isError: json['isError'] ?? false,
      imagePaths: List<String>.from(json['imagePaths'] ?? []),
      tweetId: json['tweetId'],
      replies: (json['replies'] as List<dynamic>?)
              ?.map((r) => Message.fromJson(r))
              .toList() ??
          [],
    );
  }
}
