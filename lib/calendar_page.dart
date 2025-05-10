import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

class CalendarEvent {
  final String id;
  final String title;
  final String category;
  final Timestamp? createdAt;
  final String startDate;
  final String startTime;
  final String endDate;
  final String endTime;
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
    required this.startDate,
    required this.startTime,
    required this.endDate,
    required this.endTime,
    required this.frequency,
    this.reminder,
    required this.from,
    required this.to,
    required this.background,
    required this.isAllDay,
  });

  factory CalendarEvent.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final dateFormatter = DateFormat('M/d/yyyy');
    final timeFormatter = DateFormat('h a');

    // Parse start date/time
    final startDate = dateFormatter.parse(data['startDate'] ?? '1/1/1970');
    final startTime = timeFormatter.parse(data['startTime'] ?? '12:00 AM');
    final from = DateTime(
      startDate.year,
      startDate.month,
      startDate.day,
      startTime.hour,
      startTime.minute,
    );

    // Parse end date/time
    final endDate = dateFormatter.parse(data['endDate'] ?? data['startDate']);
    final endTime = timeFormatter.parse(data['endTime'] ?? data['startTime']);
    final to = DateTime(
      endDate.year,
      endDate.month,
      endDate.day,
      endTime.hour,
      endTime.minute,
    );

    // Parse frequency
    final frequencyData = data['frequency'] as Map<String, dynamic>? ?? {};
    final frequency = Frequency(
      type: frequencyData['type']?.toString() ?? '',
      unit: frequencyData['unit']?.toString() ?? '',
      interval: (frequencyData['interval'] as num?)?.toInt() ?? 1,
    );

    // Parse reminder
    final reminderData = data['reminder'] as Map<String, dynamic>?;
    final reminder = reminderData != null
        ? Reminder(
      type: reminderData['type']?.toString() ?? '',
      value: (reminderData['value'] as num?)?.toInt() ?? 0,
    )
        : null;

    // Determine background color
    final category = data['category']?.toString() ?? 'General';
    final background = _getCategoryColor(category);

    return CalendarEvent(
      id: doc.id,
      title: data['title']?.toString() ?? 'No Title',
      category: category,
      createdAt: data['createdAt'] as Timestamp?,
      startDate: data['startDate']?.toString() ?? '',
      startTime: data['startTime']?.toString() ?? '',
      endDate: data['endDate']?.toString() ?? '',
      endTime: data['endTime']?.toString() ?? '',
      frequency: frequency,
      reminder: reminder,
      from: from,
      to: to,
      background: background,
      isAllDay: frequency.type.toLowerCase() == 'daily',
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

class AppointmentDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final String _collection = 'appointments';

  // Get appointments from Firestore
  Stream<List<CalendarEvent>> getAppointments() {
    return _firestore
        .collection('users')
        .doc(_auth.currentUser?.uid)
        .collection(_collection)
        .orderBy('createdAt', descending: true)
        .limit(100)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => CalendarEvent.fromFirestore(doc))
        .toList());
  }

  // Get appointments by date range
  Stream<List<CalendarEvent>> getAppointmentsByDateRange(DateTime start, DateTime end) {
    // We'll query by startDate field which contains the date string
    // This is a simplified approach - ideally you'd store dates as timestamps for range queries
    return _firestore
        .collection('users')
        .doc(_auth.currentUser?.uid)
        .collection(_collection)
        .snapshots()
        .map((snapshot) {
      final events = snapshot.docs.map((doc) => CalendarEvent.fromFirestore(doc)).toList();
      // Filter the events in memory based on date range
      return events.where((event) {
        return (event.from.isAfter(start) || event.from.isAtSameMomentAs(start)) &&
            (event.from.isBefore(end) || event.from.isAtSameMomentAs(end));
      }).toList();
    });
  }
}

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final CalendarController _calendarController = CalendarController();
  final AppointmentDataSource _appointmentDataSource = AppointmentDataSource();
  CalendarView _currentView = CalendarView.month;
  int _selectedYear = DateTime.now().year; // Track selected year
  _EventDataSource? _events;
  bool _isLoading = true;
  String? _errorMessage;
  StreamSubscription? _eventSubscription;
  DateTime? _startDate;
  DateTime? _endDate;
  DateTime? _selectedDate; // Track the selected date

  @override
  void initState() {
    super.initState();
    _calendarController.view = _currentView;
    _selectedDate = DateTime.now(); // Initialize with current date
    _calendarController.displayDate = _selectedDate; // Set initial display date
    FirebaseFirestore.instance.settings = const Settings(persistenceEnabled: true);
    _fetchAppointments();
  }

  @override
  void dispose() {
    _eventSubscription?.cancel();
    _calendarController.dispose();
    super.dispose();
  }

  Future<void> _fetchAppointments() async {
    setState(() => _isLoading = true);
    _eventSubscription?.cancel();

    Stream<List<CalendarEvent>> stream = _appointmentDataSource.getAppointments();

    _eventSubscription = stream.listen(
          (events) => setState(() {
        _events = _EventDataSource(events);
        _isLoading = false;
        _errorMessage = null;
      }),
      onError: (e) => setState(() {
        _isLoading = false;
        _errorMessage = e is FirebaseException
            ? e.message ?? 'Firestore error occurred'
            : 'Failed to load appointments';
      }),
    );
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
          // Year dropdown filter
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: DropdownButton<int>(
              value: _selectedYear,
              items: List.generate(9, (index) => 2021 + index)
                  .map((year) => DropdownMenuItem<int>(
                value: year,
                child: Text(year.toString()),
              ))
                  .toList(),
              onChanged: (int? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedYear = newValue;
                    // Update selected date to stay within the selected year
                    _selectedDate = DateTime(newValue, _selectedDate?.month ?? 1,
                        _selectedDate?.day ?? 1);
                    _calendarController.displayDate = _selectedDate;
                    _startDate = DateTime(newValue, 1, 1);
                    _endDate = DateTime(newValue, 12, 31);
                    _fetchAppointments();
                  });
                }
              },
            ),
          ),
          // Calendar view selector
          PopupMenuButton<CalendarView>(
            onSelected: (view) => setState(() {
              _currentView = view;
              _calendarController.view = view;
              // Ensure the selected date is displayed in the new view
              _calendarController.displayDate = _selectedDate;
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
      view: _currentView,
      dataSource: _events,
      onTap: (details) {
        // Capture the selected date when a day is tapped in month view
        if (_currentView == CalendarView.month && details.date != null) {
          setState(() {
            _selectedDate = details.date;
            _calendarController.displayDate = _selectedDate;
          });
        }
        // Show event details if an appointment is tapped
        if (details.appointments?.isNotEmpty ?? false) {
          _showEventDetails(details.appointments!.first as CalendarEvent);
        }
      },
      onViewChanged: (ViewChangedDetails details) {
        // Ensure the selected date is maintained when navigating in month view
        if (_currentView == CalendarView.month &&
            details.visibleDates.isNotEmpty) {
          // Check if the selected date is within the visible dates
          final visibleStart = details.visibleDates.first;
          final visibleEnd = details.visibleDates.last;
          if (_selectedDate != null &&
              (_selectedDate!.isBefore(visibleStart) ||
                  _selectedDate!.isAfter(visibleEnd))) {
            // Adjust selected date to the first visible date if it's outside the range
            setState(() {
              _selectedDate = visibleStart;
              _calendarController.displayDate = _selectedDate;
            });
          }
        }
      },
      headerStyle: const CalendarHeaderStyle(
        textAlign: TextAlign.center,
      ),
      monthViewSettings: const MonthViewSettings(
        showAgenda: true,
        appointmentDisplayMode: MonthAppointmentDisplayMode.appointment,
      ),
      timeSlotViewSettings: const TimeSlotViewSettings(
        startHour: 0,
        endHour: 24,
        timeFormat: 'h a',
        timeInterval: Duration(hours: 1),
        minimumAppointmentDuration: Duration(hours: 1),
        dayFormat: 'EEE',
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
              onPressed: _fetchAppointments, child: const Text('Retry')),
        ],
      ),
    );
  }
}

class _EventDataSource extends CalendarDataSource {
  _EventDataSource(List<CalendarEvent> source) {
    appointments = source;
  }

  @override
  DateTime getStartTime(int index) => (appointments![index] as CalendarEvent).from;

  @override
  DateTime getEndTime(int index) => (appointments![index] as CalendarEvent).to;

  @override
  String getSubject(int index) => (appointments![index] as CalendarEvent).title;

  @override
  Color getColor(int index) => (appointments![index] as CalendarEvent).background;

  @override
  bool isAllDay(int index) => (appointments![index] as CalendarEvent).isAllDay;

  @override
  String? getRecurrenceRule(int index) =>
      (appointments![index] as CalendarEvent).frequency.recurrenceRule;

  @override
  String getNotes(int index) =>
      'Category: ${(appointments![index] as CalendarEvent).category}';
}