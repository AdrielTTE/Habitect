import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarScreen extends StatefulWidget {
  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  String _currentView = 'Month';

  List<String> weekDays = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"];
  List<String> timeSlots = [
    "6am", "7am", "8am", "9am", "10am", "11am", "12pm",
    "1pm", "2pm", "3pm", "4pm", "5pm", "6pm", "7pm",
    "8pm", "9pm", "10pm", "11pm", "12am", "1am", "2am",
    "3am", "4am", "5am"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Icon(Icons.menu, color: Colors.black),
            SizedBox(width: 8),
            Text(
              'Calendar',
              style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Spacer(),
            PopupMenuButton<String>(
              icon: Icon(Icons.calendar_today, color: Colors.black),
              onSelected: (value) {
                setState(() {
                  _currentView = value;
                });
              },
              itemBuilder: (context) => [
                PopupMenuItem(value: 'Month', child: Text('Month View')),
                PopupMenuItem(value: 'Week', child: Text('Week View')),
                PopupMenuItem(value: 'Day', child: Text('Day View')),
              ],
            ),
            SizedBox(width: 16),
            Icon(Icons.search, color: Colors.black),
          ],
        ),
      ),
      body: buildCalendarBody(),
    );
  }

  Widget buildCalendarBody() {
    switch (_currentView) {
      case 'Month':
        return buildMonthView();
      case 'Week':
        return buildWeekView();
      case 'Day':
        return buildDayView();
      default:
        return Center(child: Text("Invalid view"));
    }
  }

  Widget buildMonthView() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TableCalendar(
        headerStyle: HeaderStyle(formatButtonVisible: false, titleCentered: true),
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: _focusedDay,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
        },
        calendarFormat: _calendarFormat,
        onFormatChanged: (format) {
          setState(() {
            _calendarFormat = format;
          });
        },
        startingDayOfWeek: StartingDayOfWeek.sunday,
        calendarStyle: CalendarStyle(
          todayDecoration: BoxDecoration(color: Colors.orange, shape: BoxShape.circle),
          selectedDecoration: BoxDecoration(color: Colors.deepOrange, shape: BoxShape.circle),
        ),
      ),
    );
  }

  Widget buildWeekView() {
    DateTime startOfWeek = _selectedDay ?? _focusedDay;
    int dayOfWeek = startOfWeek.weekday;
    DateTime firstDayOfWeek = startOfWeek.subtract(Duration(days: dayOfWeek - 1));

    List<DateTime> daysOfWeek = List.generate(7, (index) {
      return firstDayOfWeek.add(Duration(days: index));
    });

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          Row(
            children: [
              Container(width: 50, child: Text("")),
              Expanded(
                child: Row(
                  children: daysOfWeek.map((day) {
                    return Expanded(
                      child: Center(
                        child: Column(
                          children: [
                            Text('${day.day}', style: TextStyle(fontWeight: FontWeight.bold)),
                            SizedBox(height: 4),
                            Container(
                              height: 4,
                              width: 4,
                              decoration: BoxDecoration(
                                color: Colors.orange,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              itemCount: timeSlots.length,
              itemBuilder: (context, timeIndex) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 50,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(timeSlots[timeIndex], style: TextStyle(fontSize: 12)),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        height: 60,
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: Colors.grey.shade200),
                          ),
                        ),
                        child: Row(
                          children: List.generate(7, (dayIndex) {
                            return Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border(
                                    right: BorderSide(color: Colors.grey.shade200),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget buildDayView() {
    DateTime displayDay = _focusedDay;
    List<String> months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    String weekday = weekDays[displayDay.weekday % 7]; // Adjust for Sunday start
    String month = months[displayDay.month - 1]; // Get month name

    return Column(
      children: [
        const SizedBox(height: 16),

        // Month & Navigation
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: Icon(Icons.arrow_left),
              onPressed: () {
                setState(() {
                  _focusedDay = _focusedDay.subtract(Duration(days: 1));
                  _selectedDay = _focusedDay;
                });
              },
            ),
            Column(
              children: [
                Text(month, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Text(
                  weekday,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${displayDay.day}',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            IconButton(
              icon: Icon(Icons.arrow_right),
              onPressed: () {
                setState(() {
                  _focusedDay = _focusedDay.add(Duration(days: 1));
                  _selectedDay = _focusedDay;
                });
              },
            ),
          ],
        ),

        const Divider(),

        // Scrollable Time Grid
        Expanded(
          child: ListView.builder(
            itemCount: timeSlots.length,
            itemBuilder: (context, index) {
              return Container(
                height: 60,
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.shade300, width: 1.0),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      timeSlots[index],
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

}
