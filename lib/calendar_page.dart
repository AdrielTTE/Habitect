import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'dart:async';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({Key? key}) : super(key: key);

  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final CalendarController _calendarController = CalendarController();
  CalendarView _currentView = CalendarView.month;
  _EventDataSource? _events;
  bool _isLoading = true;
  String? _errorMessage;
  StreamSubscription? _eventSubscription;

  List<String> _categories = [
    'Consulting',
    'Project Plan',
    'Development',
    'Support',
    'Scrum',
    'General',
    'Groceries'
  ];
  String _selectedCategory = 'General';

  final Map<String, Color> _categoryColors = {
    'Consulting': Colors.red[700]!,
    'Project Plan': Colors.green[700]!,
    'Development': Colors.grey[700]!,
    'Support': Colors.purple[700]!,
    'Scrum': Colors.blue[700]!,
    'General': Colors.orange[700]!,
    'Groceries': Colors.green[700]!,
  };

  @override
  void initState() {
    super.initState();
    _calendarController.view = _currentView;
    _calendarController.displayDate = DateTime(2025, 5, 5);
    _fetchEvents();
  }

  @override
  void dispose() {
    _eventSubscription?.cancel();
    _calendarController.dispose();
    super.dispose();
  }

  Future<void> _fetchEvents() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    _eventSubscription?.cancel();
    _eventSubscription = FirebaseFirestore.instance.collection('events').snapshots().listen(
          (snapshot) {
        final List<Event> appointments = snapshot.docs.map((doc) {
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

          final category = (data['category'] as String?) ?? 'General';
          final backgroundColor = _categoryColors[category] ?? _categoryColors['General']!;

          return Event(
            id: doc.id,
            title: data['title'] ?? category,
            category: category,
            createdAt: data['createdAt'] as Timestamp?,
            startDate: data['startDate'] as String?,
            startTime: data['startTime'] as String?,
            endDate: data['endDate'] as String?,
            endTime: data['endTime'] as String?,
            frequency: data['frequency'] as Map<String, dynamic>?,
            reminder: data['reminder'],
            from: from,
            to: to,
            background: backgroundColor,
            isAllDay: (data['frequency'] != null && (data['frequency'] as Map<String, dynamic>)['type'] == 'Daily'),
          );
        }).toList();

        final filteredAppointments = appointments.where((event) => event.category == _selectedCategory).toList();

        setState(() {
          _events = _EventDataSource(filteredAppointments);
          _isLoading = false;
          _errorMessage = null;
        });
      },
      onError: (e, stackTrace) {
        print('Error fetching events: $e\nStackTrace: $stackTrace');
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to load events. Please try again.';
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
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list, color: Colors.black),
            onSelected: (String value) {
              setState(() {
                _selectedCategory = value;
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
    final Event event = details.appointments.first as Event;

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
            event.category ?? 'General',
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
              event.category ?? 'General',
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

class Event {
  final String id;
  final String title;
  final String? category;
  final Timestamp? createdAt;
  final String? startDate;
  final String? startTime;
  final String? endDate;
  final String? endTime;
  final Map<String, dynamic>? frequency;
  final dynamic reminder;
  final DateTime from;
  final DateTime to;
  final Color background;
  final bool isAllDay;

  Event({
    required this.id,
    required this.title,
    this.category,
    this.createdAt,
    this.startDate,
    this.startTime,
    this.endDate,
    this.endTime,
    this.frequency,
    this.reminder,
    required this.from,
    required this.to,
    required this.background,
    required this.isAllDay,
  });
}

class _EventDataSource extends CalendarDataSource {
  _EventDataSource(List<Event> source) {
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
