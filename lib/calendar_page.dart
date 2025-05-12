import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
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

    // Debug: Print the raw data from Firestore
    //print('Firestore Data for doc.id: ${doc.id}: $data');

    final startDateStr = data['startDate'] as String? ?? '';
    final startTimeStr = data['startTime'] as String? ?? '';
    final endDateStr = data['endDate'] as String? ?? '';
    final endTimeStr = data['endTime'] as String? ?? '';
    final frequencyStr = data['frequency']?.toString() ?? '';

    final from = _parseDateTime(startDateStr, startTimeStr);
    final to = _parseDateTime(endDateStr, endTimeStr);

    // Debug: Print the parsed DateTime values
    //print('Parsed from (startDateStr: $startDateStr, startTimeStr: $startTimeStr): $from');


    final category = data['category']?.toString() ?? 'General';
    final background = _getCategoryColor(category);

    String? byDay;
    if (frequencyStr.toLowerCase() == 'weekly') {
      byDay = _getDayAbbreviation(from.weekday);
    }

    return CalendarEvent(
      id: doc.id,
      title: data['title']?.toString() ?? 'No Title',
      category: category,
      createdAt: data['createdAt'] as Timestamp?,
      fromTimestamp: Timestamp.fromDate(from),
      toTimestamp: Timestamp.fromDate(to),
      from: from,
      to: to,
      background: background,
      isAllDay: data['isAllDay'] ?? false,
      frequency: Frequency(type: frequencyStr, unit: '', interval: 1, byDay: byDay),
      reminder: null,
    );
  }

  static String _getDayAbbreviation(int weekday) {
    return switch (weekday) {
      DateTime.monday => 'MO',
      DateTime.tuesday => 'TU',
      DateTime.wednesday => 'WE',
      DateTime.thursday => 'TH',
      DateTime.friday => 'FR',
      DateTime.saturday => 'SA',
      DateTime.sunday => 'SU',
      _ => 'MO',
    };
  }

  static DateTime _parseDateTime(String dateStr, String timeStr) {
    // Debug: Check input strings

    if (dateStr.isEmpty || timeStr.isEmpty) {
      // Handle empty date or time strings

      return DateTime.now();
    }
    try {
      final date = DateFormat('M/d/yyyy').parse(dateStr);
      final time = DateFormat('h:mm a').parse(timeStr);
      return DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    } catch (e) {
      // Handle parsing errors

      return DateTime.now();
    }
  }

  static Color _getCategoryColor(String category) {
    return switch (category) {
      'Daily' => Colors.red[300]!,
      'Family' => Colors.green[300]!,
      'Groceries' => Colors.grey[300]!,
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
  final String? byDay;

  Frequency({
    required this.type,
    required this.unit,
    required this.interval,
    this.byDay,
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

    if (freq == null) return null;

    if (freq == 'WEEKLY' && byDay != null) {
      return 'FREQ=$freq;INTERVAL=$interval;BYDAY=$byDay';
    }

    return 'FREQ=$freq;INTERVAL=$interval';
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
    appointments = source.map((event) {
      final appointment = Appointment(
        startTime: event.from,
        endTime: event.to,
        subject: event.title,
        color: event.background,
        isAllDay: event.isAllDay,
        recurrenceRule: event.frequency.recurrenceRule,
        notes: 'Category: ${event.category}',
      );
      // Debug: Print the Appointment details.

      return appointment;
    }).toList();
  }

  @override
  DateTime getStartTime(int index) => appointments![index].startTime;

  @override
  DateTime getEndTime(int index) => appointments![index].endTime;

  @override
  String getSubject(int index) => appointments![index].subject;

  @override
  Color getColor(int index) => appointments![index].color;

  @override
  bool isAllDay(int index) => appointments![index].isAllDay;

  @override
  String? getRecurrenceRule(int index) => appointments![index].recurrenceRule;

  @override
  String? getNotes(int index) => appointments![index].notes;
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
    print('Fetching appointments for date range: $startDate to $endDate'); // Debug
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(_auth.currentUser?.uid)
          .collection('tasks')
          .where('startDate', isGreaterThanOrEqualTo: DateFormat('M/d/yyyy').format(startDate))
          .where('startDate', isLessThanOrEqualTo: DateFormat('M/d/yyyy').format(endDate))
          .orderBy('startDate')
          .get();

      final calendarEvents = snapshot.docs.map((doc) => CalendarEvent.fromFirestore(doc)).toList();
      setState(() {
        _events = AppointmentDataSource(calendarEvents);
        _isLoading = false;
        _errorMessage = null;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e is FirebaseException ? e.message ?? 'Firestore error occurred' : 'Failed to load tasks';
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
            if (event.frequency.type.isNotEmpty) Text('Repeats: ${event.frequency.type}'),
            if (event.reminder != null) Text('Reminder: ${event.reminder!.value} mins before'),
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
              const PopupMenuItem(value: CalendarView.month, child: Text('Month View')),
              const PopupMenuItem(value: CalendarView.week, child: Text('Week View')),
              const PopupMenuItem(value: CalendarView.day, child: Text('Day View')),
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
      onTap: (CalendarTapDetails details) {
        if (details.appointments != null && details.appointments!.isNotEmpty) {
          final Appointment appointment = details.appointments!.first;
          _showEventDetails(CalendarEvent( // Use CalendarEvent to show details.
            id: '',
            title: appointment.subject,
            category: appointment.notes?.split('Category: ').last ?? 'General',
            fromTimestamp: Timestamp.fromDate(appointment.startTime),
            toTimestamp: Timestamp.fromDate(appointment.endTime),
            frequency: Frequency(type: appointment.recurrenceRule ?? '', unit: '', interval: 1),
            from: appointment.startTime,
            to: appointment.endTime,
            background: appointment.color,
            isAllDay: appointment.isAllDay,
          ));
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
      monthViewSettings: const MonthViewSettings(
        showAgenda: true,
        appointmentDisplayMode: MonthAppointmentDisplayMode.appointment,
      ),
      scheduleViewSettings: const ScheduleViewSettings(),
      timeSlotViewSettings: TimeSlotViewSettings(
        startHour: 0,
        endHour: 24,
        timeFormat: 'h:mm a',
        timeInterval: const Duration(hours: 1),
        minimumAppointmentDuration: const Duration(minutes: 30),
        dayFormat: _currentView == CalendarView.week || _currentView == CalendarView.day
            ? 'EEE, d'
            : 'EEE, MMM d',
        nonWorkingDays: const <int>[DateTime.saturday, DateTime.sunday],
      ),
      appointmentBuilder: _buildAppointment,
    );
  }

  Widget _buildAppointment(BuildContext context, CalendarAppointmentDetails details) {
    final Appointment appointment = details.appointments.first;
    return Container(
      decoration: BoxDecoration(
        color: appointment.color,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Center(
        child: _currentView == CalendarView.month
            ? Text(
          appointment.subject,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: Colors.white, fontSize: 10),
        )
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              appointment.notes?.split('Category: ').last ?? 'General',
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
            const SizedBox(height: 2),
            Text(
              appointment.subject,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
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
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

