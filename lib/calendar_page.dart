import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
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
  final Reminder reminder;
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
    required this.reminder,
    required this.from,
    required this.to,
    required this.background,
    required this.isAllDay,
  });

  factory CalendarEvent.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final dateFormatter = DateFormat('M/d/yyyy');
    final timeFormatter = DateFormat('h:mm a');
    final startDateStr = data['startDate'] as String? ?? '1/1/1970';
    final startTimeStr = data['startTime'] as String? ?? '12:00 AM';
    final startDate = dateFormatter.parse(startDateStr);
    final startTime = timeFormatter.parse(startTimeStr);
    final from = DateTime(
      startDate.year,
      startDate.month,
      startDate.day,
      startTime.hour,
      startTime.minute,
    );
    final endDateStr = data['endDate'] as String? ?? startDateStr;
    final endTimeStr = data['endTime'] as String? ?? startTimeStr;
    final endDate = dateFormatter.parse(endDateStr);
    final endTime = timeFormatter.parse(endTimeStr);
    final to = DateTime(
      endDate.year,
      endDate.month,
      endDate.day,
      endTime.hour,
      endTime.minute,
    );

    final category = data['category'] as String? ?? 'General';
    final background = {
      'Consulting': Colors.red[700]!,
      'Project Plan': Colors.green[700]!,
      'Development': Colors.grey[700]!,
      'Support': Colors.purple[700]!,
      'Scrum': Colors.blue[700]!,
      'General': Colors.orange[700]!,
      'Groceries': Colors.green[700]!,
    }[category] ?? Colors.orange[700]!;

    return CalendarEvent(
      id: doc.id,
      title: data['title'] ?? category,
      category: category,
      createdAt: data['createdAt'] as Timestamp?,
      startDate: startDateStr,
      startTime: startTimeStr,
      endDate: endDateStr,
      endTime: endTimeStr,
      frequency: Frequency.fromMap(data['frequency'] ?? {}),
      reminder: Reminder.fromMap(data['reminder'] ?? {}),
      from: from,
      to: to,
      background: background,
      isAllDay: (data['frequency']?['type'] == 'Daily'),
    );
  }
}

class Frequency {
  final String type;

  Frequency({required this.type});

  factory Frequency.fromMap(Map<String, dynamic> map) {
    return Frequency(type: map['type'] ?? '');
  }
}

class Reminder {
  final String type;
  final int value;

  Reminder({required this.type, required this.value});

  factory Reminder.fromMap(Map<String, dynamic> map) {
    return Reminder(
      type: map['type'] ?? '',
      value: map['value'] ?? 0,
    );
  }
}

class CalendarService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'events';

  Stream<List<CalendarEvent>> getCalendarEvents() {
    return _firestore
        .collection(_collection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => CalendarEvent.fromFirestore(doc))
        .toList());
  }

  Stream<List<CalendarEvent>> getEventsByCategory(String category) {
    return _firestore
        .collection(_collection)
        .where('category', isEqualTo: category)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => CalendarEvent.fromFirestore(doc))
        .toList());
  }

  Stream<List<CalendarEvent>> getEventsByDateRange(DateTime start, DateTime end) {
    return _firestore
        .collection(_collection)
        .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(end))
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => CalendarEvent.fromFirestore(doc))
        .toList());
  }
}

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({Key? key}) : super(key: key);

  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final CalendarController _calendarController = CalendarController();
  final CalendarService _calendarService = CalendarService();
  CalendarView _currentView = CalendarView.month;
  _EventDataSource? _events;
  bool _isLoading = true;
  String? _errorMessage;
  StreamSubscription? _eventSubscription;
  DateTime? _startDate;
  DateTime? _endDate;

  List<String> _categories = [
    'Daily',
    'Family',
    'Groceries',
    'Exercise',
    'Works',
    'Schools',
    'Others'
  ];
  String _selectedCategory = 'Daily';

  @override
  void initState() {
    super.initState();
    _calendarController.view = _currentView;
    _calendarController.displayDate = DateTime(2025, 5, 5);
    FirebaseFirestore.instance.settings = const Settings(persistenceEnabled: true);
    _fetchEvents();
  }

  @override
  void dispose() {
    _eventSubscription?.cancel();
    _calendarController.dispose();
    super.dispose();
  }

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
      });
      _fetchEvents();
    }
  }

  Future<void> _fetchEvents() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    _eventSubscription?.cancel();
    final stream = _startDate != null && _endDate != null
        ? _calendarService.getEventsByDateRange(_startDate!, _endDate!)
        : _calendarService.getEventsByCategory(_selectedCategory);
    _eventSubscription = stream.listen(
          (events) {
        setState(() {
          _events = _EventDataSource(events);
          _isLoading = false;
          _errorMessage = null;
        });
      },
      onError: (e, stackTrace) {
        final message = e is FirebaseException
            ? e.message ?? 'Failed to load events.'
            : 'An unexpected error occurred.';
        setState(() {
          _isLoading = false;
          _errorMessage = message;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        centerTitle: true,
        title: const Text('Calendar', style: TextStyle(color: Colors.black)),
        actions: [
          IconButton(
            icon: const Icon(Icons.date_range, color: Colors.black),
            onPressed: () => _selectDateRange(context),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list, color: Colors.black),
            onSelected: (String value) {
              setState(() {
                _selectedCategory = value;
                _startDate = null;
                _endDate = null;
              });
              _fetchEvents();
            },
            itemBuilder: (context) {
              return _categories.map((category) {
                return PopupMenuItem<String>(
                  value: category,
                  child: Text(category),
                );
              }).toList();
            },
          ),
          PopupMenuButton<CalendarView>(
            icon: const Icon(Icons.calendar_view_day, color: Colors.black),
            onSelected: (CalendarView value) {
              setState(() {
                _calendarController.view = value;
                _currentView = value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: CalendarView.month,
                child: Text('Month View'),
              ),
              const PopupMenuItem(
                value: CalendarView.week,
                child: Text('Week View'),
              ),
              const PopupMenuItem(
                value: CalendarView.day,
                child: Text('Day View'),
              ),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchEvents,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null
            ? Center(child: Text(_errorMessage!))
            : SfCalendar(
          controller: _calendarController,
          view: _currentView,
          dataSource: _events,
          headerHeight: 50,
          headerStyle: const CalendarHeaderStyle(
            textAlign: TextAlign.center,
            textStyle: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          timeSlotViewSettings: const TimeSlotViewSettings(
            startHour: 0,
            endHour: 24,
            timeInterval: Duration(hours: 1),
            timeFormat: 'h a',
            timeTextStyle: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12,
              color: Colors.black87,
            ),
          ),
          monthViewSettings: const MonthViewSettings(
            appointmentDisplayMode: MonthAppointmentDisplayMode.appointment,
            showAgenda: true,
          ),
          appointmentBuilder: _buildAppointment,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to add event screen
        },
        child: const Icon(Icons.add),
        backgroundColor: Colors.orange,
      ),
    );
  }

  Widget _buildAppointment(BuildContext context, CalendarAppointmentDetails details) {
    final CalendarEvent event = details.appointments.first as CalendarEvent;

    return Container(
      width: details.bounds.width,
      height: details.bounds.height,
      decoration: BoxDecoration(
        color: event.background,
        borderRadius: BorderRadius.circular(3),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: _currentView == CalendarView.month
            ? Center(
          child: Text(
            event.category,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        )
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              event.category,
              style: const TextStyle(color: Colors.white, fontSize: 12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              event.title,
              style: const TextStyle(color: Colors.white, fontSize: 12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _EventDataSource extends CalendarDataSource {
  _EventDataSource(List<CalendarEvent> source) {
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
}