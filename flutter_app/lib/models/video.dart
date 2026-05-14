import 'package:intl/intl.dart';

class Video {
  final String id;
  final String title;
  final String url;
  final String status; // 'selected', 'created', 'published'
  final DateTime createdAt;
  final DateTime updatedAt;

  Video({
    required this.id,
    required this.title,
    required this.url,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  // Factory constructor to create Video from JSON
  factory Video.fromJson(Map<String, dynamic> json) {
    return Video(
      id: json['id'] as String,
      title: json['title'] as String,
      url: json['url'] as String,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  // Convert Video to JSON
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'url': url,
    'status': status,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  // Copy with method
  Video copyWith({
    String? id,
    String? title,
    String? url,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Video(
      id: id ?? this.id,
      title: title ?? this.title,
      url: url ?? this.url,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Get formatted date
  String get formattedDate {
    return DateFormat('MMM d, yyyy').format(createdAt);
  }

  // Get status color
  int getStatusColor() {
    switch (status) {
      case 'selected':
        return 0xFF3b82f6; // blue
      case 'created':
        return 0xFFf59e0b; // amber
      case 'published':
        return 0xFF10b981; // green
      default:
        return 0xFF94a3b8; // gray
    }
  }

  // Get status icon
  String getStatusIcon() {
    switch (status) {
      case 'selected':
        return '⭐';
      case 'created':
        return '✏️';
      case 'published':
        return '✅';
      default:
        return '•';
    }
  }

  // Get next status
  String? getNextStatus() {
    if (status == 'selected') return 'created';
    if (status == 'created') return 'published';
    return null;
  }

  // Check if video can transition
  bool canTransition() => getNextStatus() != null;
}
