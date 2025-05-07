import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({Key? key}) : super(key: key);

  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final CalendarController _calendarController = CalendarController();
  CalendarView _currentView = CalendarView.month;

  // Data source for calendar events
  _EventDataSource? _events;
  bool _isLoading = true;

  // Format the date for the app bar title
  String _formatAppBarDate(DateTime date, CalendarView view) {
    if (view == CalendarView.month) {
      return '${_getMonthName(date.month)} ${date.year}';
    } else if (view == CalendarView.week) {
      // Get the start and end of the visible week
      final firstDay = date.subtract(Duration(days: date.weekday % 7));
      final lastDay = firstDay.add(const Duration(days: 6));

      if (firstDay.month == lastDay.month) {
        return '${_getMonthName(firstDay.month)} ${firstDay.year}';
      } else if (firstDay.year == lastDay.year) {
        return '${_getMonthName(firstDay.month)} - ${_getMonthName(lastDay.month)} ${firstDay.year}';
      } else {
        return '${_getMonthName(firstDay.month)} ${firstDay.year} - ${_getMonthName(lastDay.month)} ${lastDay.year}';
      }
    } else {
      // Day view
      return '${date.day} ${_getMonthName(date.month)} ${date.year}';
    }
  }

  // Helper to get month name
  String _getMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }

  // Fetch events from Firestore
  Future<void> _fetchEvents() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('events')
          .get();

      final List<Event> appointments = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;

        // Date and time formatters
        final dateFormatter = DateFormat('M/d/yyyy');
        final timeFormatter = DateFormat('h:mm a');

        // Parse start date and time
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

        // Parse end date and time
        final endDateStr = data['endDate'] as String? ?? '1/1/1970';
        final endTimeStr = data['endTime'] as String? ?? '12:00 AM';
        final endDate = dateFormatter.parse(endDateStr);
        final endTime = timeFormatter.parse(endTimeStr);
        final to = DateTime(
          endDate.year,
          endDate.month,
          endDate.day,
          endTime.hour,
          endTime.minute,
        );

        return Event(
          id: doc.id,
          title: data['title'] ?? 'No Title',
          category: data['category'] as String?,
          createdAt: data['createdAt'] as Timestamp?,
          startDate: data['startDate'] as String?,
          startTime: data['startTime'] as String?,
          endDate: data['endDate'] as String?,
          endTime: data['endTime'] as String?,
          frequency: data['frequency'] as Map<String, dynamic>?,
          reminder: data['reminder'],
          from: from,
          to: to,
          background: Colors.blue, // Default color
          isAllDay: from.day != to.day || (data['frequency']?['type'] == 'Daily'),
        );
      }).toList();

      setState(() {
        _events = _EventDataSource(appointments);
        _isLoading = false;
      });
    } catch (e, stackTrace) {
      print('Error fetching events: $e\nStackTrace: $stackTrace');
      setState(() {
        _isLoading = false;
      });
    }
  }


  @override
  void initState() {
    super.initState();
    _calendarController.view = _currentView;
    _fetchEvents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        centerTitle: true, // Center the title
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () {
            DateTime currentDate = _calendarController.displayDate!;
            if (_currentView == CalendarView.month) {
              _calendarController.displayDate = DateTime(currentDate.year, currentDate.month - 1, 1);
            } else if (_currentView == CalendarView.week) {
              _calendarController.displayDate = currentDate.subtract(const Duration(days: 7));
            } else {
              _calendarController.displayDate = currentDate.subtract(const Duration(days: 1));
            }
          },
        ),
        title: StreamBuilder<DateTime>(
          stream: Stream.periodic(const Duration(seconds: 1), (_) => _calendarController.displayDate ?? DateTime.now()),
          builder: (context, snapshot) {
            final date = _calendarController.displayDate ?? DateTime.now();
            return Text(
              _formatAppBarDate(date, _currentView),
              style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios, color: Colors.black),
            onPressed: () {
              DateTime currentDate = _calendarController.displayDate!;
              if (_currentView == CalendarView.month) {
                _calendarController.displayDate = DateTime(currentDate.year, currentDate.month + 1, 1);
              } else if (_currentView == CalendarView.week) {
                _calendarController.displayDate = currentDate.add(const Duration(days: 7));
              } else {
                _calendarController.displayDate = currentDate.add(const Duration(days: 1));
              }
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SfCalendar(
        controller: _calendarController,
        viewHeaderHeight: 40,
        headerHeight: 0, // Hide the default header since we have our custom navigation
        todayHighlightColor: Colors.orange,
        showNavigationArrow: false, // Hide the default navigation arrows
        allowViewNavigation: true,
        dataSource: _events,
        timeSlotViewSettings: const TimeSlotViewSettings(
          startHour: 0,
          endHour: 24,
          timeInterval: Duration(hours: 1),
          timeFormat: 'h a',
          timeTextStyle: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 12,
            color: Colors.black54,
          ),
        ),
        monthViewSettings: const MonthViewSettings(
          dayFormat: 'EEE',
          numberOfWeeksInView: 6,
          appointmentDisplayMode: MonthAppointmentDisplayMode.indicator,
        ),
        firstDayOfWeek: 7, // Sunday
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to add event screen
          // You can implement this later
        },
        child: const Icon(Icons.add),
        backgroundColor: Colors.orange,
      ),
    );
  }

  @override
  void dispose() {
    _calendarController.dispose();
    super.dispose();
  }
}

// Event model class
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
  final DateTime from; // Parsed startDate + startTime
  final DateTime to; // Parsed endDate + endTime
  final Color background; // Default for calendar
  final bool isAllDay; // Default or derived

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

// Calendar data source
class _EventDataSource extends CalendarDataSource {
  _EventDataSource(List<Event> source) {
    appointments = source;
  }

  @override
  DateTime getStartTime(int index) {
    return (appointments![index] as Event).from;
  }

  @override
  DateTime getEndTime(int index) {
    return (appointments![index] as Event).to;
  }

  @override
  String getSubject(int index) {
    final event = appointments![index] as Event;
    return event.category != null ? '${event.title} (${event.category})' : event.title;
  }

  @override
  Color getColor(int index) {
    return (appointments![index] as Event).background;
  }

  @override
  bool isAllDay(int index) {
    return (appointments![index] as Event).isAllDay;
  }

  @override
  String? getRecurrenceRule(int index) {
    final event = appointments![index] as Event;
    final freqType = event.frequency?['type'] as String?;
    if (freqType == 'Daily') {
      return 'FREQ=DAILY;INTERVAL=1;COUNT=365'; // Repeat daily for 1 year
    }
    return null;
  }
}