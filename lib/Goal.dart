
class Goal {
  final String title;
  final String category;
  final String startDate;
  final String endDate;
  final String startTime;
  final String endTime;
  final String frequencyType;
  final String frequencyValue;
  final String reminderType;
  final int reminderValue;
  final String createdAt;

  Goal({
    required this.title,
    required this.category,
    required this.startDate,
    required this.endDate,
    required this.startTime,
    required this.endTime,
    required this.frequencyType,
    required this.frequencyValue,
    required this.reminderType,
    required this.reminderValue,
    required this.createdAt,
  });

  // Convert Firestore document to Goal object
  factory Goal.fromFirestore(Map<String, dynamic> data) {
    return Goal(
      title: data['title'],
      category: data['category'],
      startDate: data['startDate'],
      endDate: data['endDate'],
      startTime: data['startTime'],
      endTime: data['endTime'],
      frequencyType: data['frequency']['type'],
      frequencyValue: data['frequency']['value'],
      reminderType: data['reminder']['type'],
      reminderValue: data['reminder']['value'],
      createdAt: data['createdAt'],
    );
  }
}
