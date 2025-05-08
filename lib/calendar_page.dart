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

  // Map categories to colors based on the sample data
  final Map<String, Color> _categoryColors = {
    'Consulting': Colors.red[700]!,
    'Project Plan': Colors.green[700]!,
    'Development': Colors.grey[700]!,
    'Support': Colors.purple[700]!,
    'Scrum': Colors.blue[700]!,
    'General': Colors.orange[700]!,
    'Groceries': Colors.green[700]!, // Matching Firestore sample
  };

  String _formatAppBarDate(DateTime date, CalendarView view) {
    if (view == CalendarView.month) {
      return '${_getMonthName(date.month)} ${date.year}';
    } else if (view == CalendarView.week) {
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
      return '${date.day} ${_getMonthName(date.month)} ${date.year}';
    }
  }

  String _getMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
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

        setState(() {
          _events = _EventDataSource(appointments);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        centerTitle: true,
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
            icon: const Icon(Icons.today, color: Colors.black),
            onPressed: () {
              _calendarController.displayDate = DateTime.now();
            },
          ),
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
      body: RefreshIndicator(
        onRefresh: _fetchEvents,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null
            ? Center(child: Text(_errorMessage!))
            : SfCalendar(
          controller: _calendarController,
          viewHeaderHeight: 40,
          headerHeight: 0,
          todayHighlightColor: Colors.orange,
          showNavigationArrow: false,
          allowViewNavigation: true,
          dataSource: _events,
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
            dayFormat: 'EEE',
            numberOfWeeksInView: 6,
            appointmentDisplayMode: MonthAppointmentDisplayMode.appointment,
            showAgenda: true,
            agendaStyle: AgendaStyle(
              backgroundColor: Colors.white,
              appointmentTextStyle: TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
              dateTextStyle: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              dayTextStyle: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            appointmentDisplayCount: 4,
            monthCellStyle: MonthCellStyle(
              textStyle: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
                color: Colors.black87,
              ),
              todayTextStyle: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Colors.orange,
              ),
              trailingDatesTextStyle: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 14,
                color: Colors.grey,
              ),
              leadingDatesTextStyle: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ),
          viewHeaderStyle: const ViewHeaderStyle(
            dayTextStyle: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.black87,
            ),
            dateTextStyle: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          firstDayOfWeek: 7,
          appointmentBuilder: _buildAppointment,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to add event screen - implement as needed
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
  DateTime getStartTime(int index) {
    return appointments![index].from;
  }

  @override
  DateTime getEndTime(int index) {
    return appointments![index].to;
  }

  @override
  String getSubject(int index) {
    return appointments![index].category ?? 'General';
  }

  @override
  Color getColor(int index) {
    return appointments![index].background;
  }

  @override
  bool isAllDay(int index) {
    return appointments![index].isAllDay;
  }

  @override
  String? getRecurrenceRule(int index) {
    final event = appointments![index] as Event;
    final freqType = event.frequency?['type'] as String?;
    if (freqType == 'Daily') {
      return 'FREQ=DAILY;INTERVAL=1;COUNT=365';
    }
    return null;
  }
}