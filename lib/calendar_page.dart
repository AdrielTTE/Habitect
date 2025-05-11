import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // Ensure intl is in your pubspec.yaml
import 'package:firebase_auth/firebase_auth.dart';

class CalendarEvent {
  final String id;
  final String title;
  final String category;
  final Timestamp? createdAt;
  final Timestamp fromTimestamp;
  final Timestamp toTimestamp;
  final Frequency frequency;
  final Reminder? reminder;
  final DateTime from;
  final DateTime to;
  final Color background;
  final bool isAllDay;

  CalendarEvent({
    required this.id,
    required this.title,
    required this.category,
    this.createdAt,
    required this.fromTimestamp,
    required this.toTimestamp,
    required this.frequency,
    this.reminder,
    required this.from,
    required this.to,
    required this.background,
    required this.isAllDay,
  });

  factory CalendarEvent.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    final fromTimestamp = data['from'] as Timestamp?;
    final toTimestamp = data['to'] as Timestamp?;

    final fromDate = fromTimestamp?.toDate() ?? DateTime.now();
    final toDate = toTimestamp?.toDate() ?? fromDate.add(const Duration(hours: 1));

    final frequencyData = data['frequency'] as Map<String, dynamic>? ?? {};
    final frequency = Frequency(
      type: frequencyData['type']?.toString() ?? '',
      unit: frequencyData['unit']?.toString() ?? '',
      interval: (frequencyData['interval'] as num?)?.toInt() ?? 1,
    );

    final reminderData = data['reminder'] as Map<String, dynamic>?;
    final reminder = reminderData != null
        ? Reminder(
      type: reminderData['type']?.toString() ?? '',
      value: (reminderData['value'] as num?)?.toInt() ?? 0,
    )
        : null;

    final category = data['category']?.toString() ?? 'General';
    final background = _getCategoryColor(category);

    return CalendarEvent(
      id: doc.id,
      title: data['title']?.toString() ?? 'No Title',
      category: category,
      createdAt: data['createdAt'] as Timestamp?,
      fromTimestamp: fromTimestamp ?? Timestamp.fromDate(fromDate),
      toTimestamp: toTimestamp ?? Timestamp.fromDate(toDate),
      from: fromDate,
      to: toDate,
      background: background,
      isAllDay: frequency.type.toLowerCase() == 'daily',
      frequency: frequency,
      reminder: reminder,
    );
  }

  static Color _getCategoryColor(String category) {
    return switch (category) {
      'Daily' => Colors.red[300]!,
      'Family' => Colors.green[300]!,
      'Groceries' => Colors.grey[350]!,
      'Exercise' => Colors.purple[200]!,
      'Works' => Colors.blue[200]!,
      'Schools' => Colors.orange[200]!,
      'Others' => Colors.green[100]!,
      _ => Colors.red[50]!,
    };
  }
}

class Frequency {
  final String type;
  final String unit;
  final int interval;

  Frequency({
    required this.type,
    required this.unit,
    required this.interval,
  });

  String? get recurrenceRule {
    if (type.isEmpty) return null;
    final freq = switch (type.toLowerCase()) {
      'daily' => 'DAILY',
      'weekly' => 'WEEKLY',
      'monthly' => 'MONTHLY',
      'yearly' => 'YEARLY',
      'custom' => unit.toUpperCase(),
      _ => null,
    };
    return freq != null ? 'FREQ=$freq;INTERVAL=$interval' : null;
  }
}

class Reminder {
  final String type;
  final int value;

  Reminder({
    required this.type,
    required this.value,
  });
}

class AppointmentDataSource extends CalendarDataSource {
  AppointmentDataSource(List<CalendarEvent> source) {
    appointments = source;
  }

  @override
  DateTime getStartTime(int index) => appointments![index].from;

  @override
  DateTime getEndTime(int index) => appointments![index].to;

  @override
  String getSubject(int index) => appointments![index].title;

  @override
  Color getColor(int index) => appointments![index].background;

  @override
  bool isAllDay(int index) => appointments![index].isAllDay;

  @override
  String? getRecurrenceRule(int index) => appointments![index].frequency.recurrenceRule;

  @override
  String getNotes(int index) => 'Category: ${appointments![index].category}';
}

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final CalendarController _calendarController = CalendarController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  CalendarView _currentView = CalendarView.month;
  int _selectedYear = DateTime.now().year;
  AppointmentDataSource? _events;
  bool _isLoading = true;
  String? _errorMessage;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _calendarController.view = _currentView;
    _calendarController.displayDate = _selectedDate;
    _fetchAppointments(_selectedDate!);
  }

  @override
  void dispose() {
    _calendarController.dispose();
    super.dispose();
  }

  Future<void> _fetchAppointments(DateTime visibleDate) async {
    setState(() => _isLoading = true);

    DateTime startDate;
    DateTime endDate;

    switch (_currentView) {
      case CalendarView.month:
        startDate = DateTime(visibleDate.year, visibleDate.month, 1);
        endDate = DateTime(visibleDate.year, visibleDate.month + 1, 0, 23, 59, 59);
        break;
      case CalendarView.week:
        startDate = visibleDate.subtract(Duration(days: visibleDate.weekday - DateTime.monday));
        endDate = startDate.add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));
        break;
      case CalendarView.day:
        startDate = DateTime(visibleDate.year, visibleDate.month, visibleDate.day);
        endDate = startDate.add(const Duration(hours: 23, minutes: 59, seconds: 59));
        break;
      default:
        startDate = DateTime(visibleDate.year, visibleDate.month, 1);
        endDate = DateTime(visibleDate.year, visibleDate.month + 1, 0, 23, 59, 59);
    }

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(_auth.currentUser?.uid)
          .collection('appointments')
          .where('from', isGreaterThanOrEqualTo: startDate)
          .where('from', isLessThanOrEqualTo: endDate)
          .orderBy('from')
          .get();

      final appointments = snapshot.docs.map((doc) => CalendarEvent.fromFirestore(doc)).toList();
      setState(() {
        _events = AppointmentDataSource(appointments);
        _isLoading = false;
        _errorMessage = null;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e is FirebaseException
            ? e.message ?? 'Firestore error occurred'
            : 'Failed to load appointments';
      });
    }
  }

  void _showEventDetails(CalendarEvent event) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(event.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Category: ${event.category}'),
            Text('Start: ${DateFormat('MMM d, y h:mm a').format(event.from)}'),
            Text('End: ${DateFormat('MMM d, y h:mm a').format(event.to)}'),
            if (event.frequency.type.isNotEmpty)
              Text('Repeats: ${event.frequency.type}'),
            if (event.reminder != null)
              Text('Reminder: ${event.reminder!.value} mins before'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar', style: TextStyle(color: Colors.black)),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: DropdownButton<int>(
              value: _selectedYear,
              items: List.generate(9, (index) => DateTime.now().year - 4 + index)
                  .map((year) => DropdownMenuItem<int>(
                value: year,
                child: Text(year.toString()),
              ))
                  .toList(),
              onChanged: (int? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedYear = newValue;
                    _selectedDate = DateTime(newValue, _selectedDate?.month ?? 1, 1);
                    _calendarController.displayDate = _selectedDate;
                    _fetchAppointments(_selectedDate!);
                  });
                }
              },
            ),
          ),
          PopupMenuButton<CalendarView>(
            onSelected: (view) => setState(() {
              _currentView = view;
              _calendarController.view = view;
              _calendarController.displayDate = _calendarController.displayDate ?? DateTime.now();
              _fetchAppointments(_calendarController.displayDate!);
            }),
            itemBuilder: (context) => [
              const PopupMenuItem(
                  value: CalendarView.month, child: Text('Month View')),
              const PopupMenuItem(
                  value: CalendarView.week, child: Text('Week View')),
              const PopupMenuItem(
                  value: CalendarView.day, child: Text('Day View')),
            ],
          ),
        ],
      ),
      body: _buildCalendarBody(),
    );
  }

  Widget _buildCalendarBody() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_errorMessage != null) return _buildErrorState();

    return SfCalendar(
      controller: _calendarController,
      //view: _currentView,
      view: CalendarView.schedule,
      dataSource: _events,
      onTap: (CalendarTapDetails details) {
        if (details.appointments != null && details.appointments!.isNotEmpty) {
          final CalendarEvent event = details.appointments!.first;
          _showEventDetails(event);
        }
      },
      onViewChanged: (ViewChangedDetails details) {
        if (details.visibleDates.isNotEmpty) {
          final firstVisibleDate = details.visibleDates.first;
          _fetchAppointments(firstVisibleDate);
        }
      },
      headerStyle: const CalendarHeaderStyle(
        textAlign: TextAlign.center,
      ),
      // Month View Settings
      monthViewSettings: const MonthViewSettings(
        showAgenda: true,
        appointmentDisplayMode: MonthAppointmentDisplayMode.appointment,
      ),
      // Schedule View Settings (for Week and Day views' agenda)
      scheduleViewSettings: const ScheduleViewSettings(
        //configure schedule-specific settings here only

      ),


      timeSlotViewSettings: const TimeSlotViewSettings(
        startHour: 0,
        endHour: 24,
        timeFormat: 'h a',
        timeInterval: Duration(hours: 1),
        minimumAppointmentDuration: Duration(minutes: 30),
        dayFormat: 'EEE, MMM d',
        nonWorkingDays: <int>[DateTime.saturday, DateTime.sunday],
      ),
      appointmentBuilder: _buildAppointment,
    );
  }

  Widget _buildAppointment(
      BuildContext context, CalendarAppointmentDetails details) {
    final event = details.appointments.first as CalendarEvent;
    return Container(
      decoration: BoxDecoration(
        color: event.background,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Center(
        child: _currentView == CalendarView.month
            ? Text(event.title,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white, fontSize: 10))
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(event.category,
                style: const TextStyle(color: Colors.white, fontSize: 12)),
            const SizedBox(height: 2),
            Text(event.title,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text(_errorMessage!, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton(
              onPressed: () {
                if (_calendarController.displayDate != null) {
                  _fetchAppointments(_calendarController.displayDate!);
                }
              },
              child: const Text('Retry')),
        ],
      ),
    );
  }
}