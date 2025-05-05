class ToDo {
  final String title;
  final String subtitle;
  final bool isDon;
  final String time;
  final double progress; // Optional: You can store progress as a double (0.0 to 1.0)

  ToDo({
    required this.title,
    required this.subtitle,
    required this.time,
    required this.isDon,
    required this.progress,
  });

  // Factory method to create ToDo from Firestore data
  factory ToDo.fromFirestore(Map<String, dynamic> data) {
    return ToDo(
      title: data['title'] ?? '',
      subtitle: data['subtitle'] ?? '',
      time: data['time'] ?? '',
      isDon: data['isDon'] ?? false,
      progress: data['progress']?.toDouble() ?? 0.0, // Assuming 'progress' is a number
    );
  }
}
