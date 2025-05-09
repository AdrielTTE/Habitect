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
    final timeFormatter = DateFormat('h:mm a');



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

class CalendarService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'events';

  Stream<List<CalendarEvent>> getCalendarEvents() {
    return _firestore.collection(_collection)
        .orderBy('createdAt', descending: true)
        .limit(100)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => CalendarEvent.fromFirestore(doc))
        .toList());
  }

  Stream<List<CalendarEvent>> getEventsByCategory(String category) {
    return _firestore.collection(_collection)
        .where('category', isEqualTo: category)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => CalendarEvent.fromFirestore(doc))
        .toList());
  }

  Stream<List<CalendarEvent>> getEventsByDateRange(DateTime start, DateTime end) {
    return _firestore.collection(_collection)
        .where('from', isGreaterThanOrEqualTo: start)
        .where('from', isLessThanOrEqualTo: end)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => CalendarEvent.fromFirestore(doc))
        .toList());
  }
}

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final CalendarController _calendarController = CalendarController();
  final CalendarService _calendarService = CalendarService();
  CalendarView _currentView = CalendarView.month;
  int _selectedYear = DateTime.now().year;  // Track selected year
  _EventDataSource? _events;
  bool _isLoading = true;
  String? _errorMessage;
  StreamSubscription? _eventSubscription;
  DateTime? _startDate;
  DateTime? _endDate;
  final List<String> categories = [
    'All', 'Daily', 'Family', 'Groceries',
    'Exercise', 'Works', 'Schools', 'Others'
  ];
  String _selectedCategory = 'Daily';


  @override
  void initState() {
    super.initState();
    _calendarController.view = _currentView;
    _calendarController.displayDate = DateTime(_selectedYear); // Set initial display date



    FirebaseFirestore.instance.settings = const Settings(persistenceEnabled: true);
    //_setYearRange(_selectedYear); // Initialize with current year's range
    _fetchEvents();
  }

  void _setYearRange(int year) {
    _startDate = DateTime(year, 1, 1);
    _endDate = DateTime(year, 12, 31);
  }


  @override
  void dispose() {
    _eventSubscription?.cancel();
    _calendarController.dispose();
    super.dispose();
  }

  /*
  Future<void> _selectDateRange(BuildContext context) async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
    );
    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
        _selectedCategory = 'All';
      });
      _fetchEvents();
    }
  } */

  Future<void> _fetchEvents() async {
    setState(() => _isLoading = true);
    _eventSubscription?.cancel();

    Stream<List<CalendarEvent>> stream;

    if (_selectedCategory == 'All') {
      stream = _calendarService.getCalendarEvents();
    } else if (_startDate != null && _endDate != null) {
      stream = _calendarService.getEventsByDateRange(_startDate!, _endDate!);
    } else {
      stream = _calendarService.getEventsByCategory(_selectedCategory);
    }

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
            : 'Failed to load events';
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
                    // Update calendar display to show the selected year
                    _calendarController.displayDate = DateTime(newValue);
                    // Set date range for event filtering
                    _startDate = DateTime(newValue, 1, 1);
                    _endDate = DateTime(newValue, 12, 31);
                    _fetchEvents();
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
              // Keep the display date consistent when changing views
              _calendarController.displayDate = DateTime(_selectedYear);
            }),
            itemBuilder: (context) => [
              const PopupMenuItem(
                  value: CalendarView.month,
                  child: Text('Month View')),
              const PopupMenuItem(
                  value: CalendarView.week,
                  child: Text('Week View')),
              const PopupMenuItem(
                  value: CalendarView.day,
                  child: Text('Day View')),
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
        if (details.appointments?.isNotEmpty ?? false) {
          _showEventDetails(details.appointments!.first as CalendarEvent);
        }
      },
      headerStyle: const CalendarHeaderStyle(
        textAlign: TextAlign.center, // Ensures the title is centered
      ),
      monthViewSettings: const MonthViewSettings(
        showAgenda: true,
        appointmentDisplayMode: MonthAppointmentDisplayMode.appointment,
      ),
      timeSlotViewSettings: const TimeSlotViewSettings(
        startHour: 0,
        endHour: 24,
        timeFormat: 'h:mm a',
        timeInterval: Duration(hours: 1),
        minimumAppointmentDuration: Duration(hours: 1),
        dayFormat: 'EEE',
        nonWorkingDays: <int>[DateTime.saturday, DateTime.sunday],
      ),
      appointmentBuilder: _buildAppointment,
    );
  }

  Widget _buildAppointment(BuildContext context, CalendarAppointmentDetails details) {
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
              onPressed: _fetchEvents,
              child: const Text('Retry')),
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