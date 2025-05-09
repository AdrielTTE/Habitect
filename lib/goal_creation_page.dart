import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'HomePage.dart';


class GoalCreationPage extends StatefulWidget {
  @override
  _GoalCreationPageState createState() => _GoalCreationPageState();
}

class _GoalCreationPageState extends State<GoalCreationPage> {
  final _formKey = GlobalKey<FormState>();
  final List<Map<String, dynamic>> categories = [
    {"name": "Daily",   "icon": Icons.today},
    {"name": "Family",  "icon": Icons.family_restroom},
    {"name": "Groceries","icon": Icons.shopping_cart},
    {"name": "Exercise","icon": Icons.fitness_center},
    {"name": "Works",   "icon": Icons.home_repair_service},
    {"name": "Schools", "icon": Icons.book},
    {"name": "Others",  "icon": Icons.more_horiz},
  ];

  // Controllers and state
  int _currentCategoryIndex = 0;
  final _taskController      = TextEditingController();
  final _dateController      = TextEditingController();
  final _timeController      = TextEditingController();
  final _endDateController   = TextEditingController();
  final _endTimeController   = TextEditingController();
  String _selectedFrequency  = "Weekly";
  final List<String> frequencies   = ["Daily", "Weekly", "Monthly", "Custom"];
  int    _customInterval     = 1;
  String _intervalUnit       = "Days";
  final List<String> intervalUnits = ["Days", "Weeks", "Months"];

  @override
  void dispose() {
    _taskController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    _endDateController.dispose();
    _endTimeController.dispose();
    super.dispose();
  }

  void _showValidationError(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.red));
  }

  void _showCongratulationsDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        contentPadding: EdgeInsets.all(20),
        title: Text("CONGRATULATIONS!",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.star_border, size: 80, color: Colors.orange),
            SizedBox(height: 20),
            Text("You successfully created a task!",
                style: TextStyle(fontSize: 18), textAlign: TextAlign.center),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _formKey.currentState?.reset();
              _taskController.clear();
              _dateController.clear();
              _timeController.clear();
              _endDateController.clear();
              _endTimeController.clear();
              setState(() {
                _selectedFrequency = "Weekly";
                _currentCategoryIndex = 0;
                _customInterval = 1;
                _intervalUnit = "Days";
              });
            },
            child: Text("Create another one",
                style: TextStyle(color: Colors.orange, fontSize: 16)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => HomePage()));
            },
            child: Text("Complete",
                style: TextStyle(color: Colors.orange, fontSize: 16)),
          ),
        ],
      ),
    );
  }

  Future<void> _saveGoalToFirestore() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final startDateParsed = DateFormat("MM/dd/yyyy").parse(_dateController.text);
      final startTimeParsed = DateFormat("h:mm a").parse(_timeController.text);
      final endDateParsed   = DateFormat("MM/dd/yyyy").parse(_endDateController.text);
      final endTimeParsed   = DateFormat("h:mm a").parse(_endTimeController.text);

      final startDateTime = DateTime(
        startDateParsed.year,
        startDateParsed.month,
        startDateParsed.day,
        startTimeParsed.hour,
        startTimeParsed.minute,
      );
      final endDateTime = DateTime(
        endDateParsed.year,
        endDateParsed.month,
        endDateParsed.day,
        endTimeParsed.hour,
        endTimeParsed.minute,
      );

      if (!endDateTime.isAfter(startDateTime)) {
        _showValidationError('End date and time must be after start date and time');
        return;
      }

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _showValidationError('No user is currently logged in.');
        return;
      }

      final frequency = _selectedFrequency == "Custom"
          ? "Every $_customInterval $_intervalUnit"
          : _selectedFrequency;

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('tasks')
          .add({
        'category': categories[_currentCategoryIndex]["name"],
        'title': _taskController.text.trim(),
        'startDate': _dateController.text,
        'startTime': DateFormat.jm().format(startDateTime),
        'endDate': _endDateController.text,
        'endTime': DateFormat.jm().format(endDateTime),
        'frequency': frequency,
        'createdAt': FieldValue.serverTimestamp(),
      });

      _showCongratulationsDialog();
    } catch (e) {
      _showValidationError('Failed to save goal. Please try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Goal Creation"),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                // Category Carousel
                Text("Choose a Category", style: TextStyle(fontSize: 18)),
                CarouselSlider.builder(
                  itemCount: categories.length,
                  itemBuilder: (ctx, idx, real) => GestureDetector(
                    onTap: () => setState(() => _currentCategoryIndex = idx),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(categories[idx]["icon"], size: 50),
                        SizedBox(height: 10),
                        Text(categories[idx]["name"], style: TextStyle(fontSize: 18)),
                      ],
                    ),
                  ),
                  options: CarouselOptions(
                    height: 125,
                    enlargeCenterPage: true,
                    viewportFraction: 0.25,
                    enableInfiniteScroll: false,
                    autoPlay: false,
                    onPageChanged: (idx, _) => setState(() => _currentCategoryIndex = idx),
                  ),
                ),

                // Task Input
                SizedBox(height: 20),
                Text("What do you want to do?", style: TextStyle(fontSize: 18)),
                TextFormField(
                  controller: _taskController,
                  decoration: InputDecoration(
                    hintText: "Enter your task",
                    border: OutlineInputBorder(
                      borderSide: BorderSide(width: 4),
                      borderRadius: BorderRadius.circular(40.0),
                    ),
                  ),
                  validator: (v) => (v?.isEmpty ?? true) ? 'Please enter a task name' : null,
                ),

                // Start Date & Time
                SizedBox(height: 20),
                Text("Start Date & Time", style: TextStyle(fontSize: 18)),
                Row(children: [
                  Expanded(
                    child: TextFormField(
                      controller: _dateController,
                      readOnly: true,
                      decoration: InputDecoration(
                        hintText: "Select date",
                        suffixIcon: IconButton(
                          icon: Icon(Icons.calendar_today),
                          onPressed: () async {
                            final d = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2101),
                            );
                            if (d != null)
                              setState(() => _dateController.text = "${d.month}/${d.day}/${d.year}");
                          },
                        ),
                      ),
                      validator: (v) => (v?.isEmpty ?? true) ? 'Please select date' : null,
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _timeController,
                      readOnly: true,
                      decoration: InputDecoration(
                        hintText: "Select time",
                        suffixIcon: IconButton(
                          icon: Icon(Icons.access_time),
                          onPressed: () async {
                            final t = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.now(),
                            );
                            if (t != null)
                              setState(() => _timeController.text = t.format(context));
                          },
                        ),
                      ),
                      validator: (v) {
                        if (v?.isEmpty ?? true) return 'Please select time';
                        try {
                          DateFormat("h:mm a").parse(v!);
                          return null;
                        } catch (_) {
                          return 'Invalid time format (Use HH:MM AM/PM)';
                        }
                      },
                    ),
                  ),
                ]),

                // End Date & Time
                SizedBox(height: 20),
                Text("End Date & Time", style: TextStyle(fontSize: 18)),
                Row(children: [
                  Expanded(
                    child: TextFormField(
                      controller: _endDateController,
                      readOnly: true,
                      decoration: InputDecoration(
                        hintText: "Select end date",
                        suffixIcon: IconButton(
                          icon: Icon(Icons.calendar_today),
                          onPressed: () async {
                            final d = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2101),
                            );
                            if (d != null)
                              setState(() => _endDateController.text = "${d.month}/${d.day}/${d.year}");
                          },
                        ),
                      ),
                      validator: (v) {
                        if (v?.isEmpty ?? true) return 'Please select end date';
                        final pat = RegExp(r'^\d{1,2}/\d{1,2}/\d{4}$');
                        return pat.hasMatch(v!) ? null : 'Invalid date format (MM/DD/YYYY)';
                      },
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _endTimeController,
                      readOnly: true,
                      decoration: InputDecoration(
                        hintText: "Select end time",
                        suffixIcon: IconButton(
                          icon: Icon(Icons.access_time),
                          onPressed: () async {
                            final t = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.now(),
                            );
                            if (t != null)
                              setState(() => _endTimeController.text = t.format(context));
                          },
                        ),
                      ),
                      validator: (v) {
                        if (v?.isEmpty ?? true) return 'Please select end time';
                        try {
                          DateFormat("h:mm a").parse(v!);
                          return null;
                        } catch (_) {
                          return 'Invalid time format (HH:MM AM/PM)';
                        }
                      },
                    ),
                  ),
                ]),

                // Frequency
                SizedBox(height: 20),
                Text("Frequency", style: TextStyle(fontSize: 18)),
                DropdownButton<String>(
                  value: _selectedFrequency,
                  items: frequencies
                      .map((f) => DropdownMenuItem(value: f, child: Text(f)))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedFrequency = v!),
                ),

                if (_selectedFrequency == "Custom") ...[
                  SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.withOpacity(0.5)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Custom Frequency", style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w500)),
                        SizedBox(height: 10),
                        Row(children: [
                          Expanded(
                            child: TextFormField(
                              initialValue: _customInterval.toString(),
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Every',
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(horizontal: 12),
                              ),
                              validator: (v) {
                                if (_selectedFrequency == "Custom") {
                                  if (v?.isEmpty ?? true) return 'Enter interval';
                                  final n = int.tryParse(v!);
                                  if (n == null || n < 1) return 'Enter valid number';
                                }
                                return null;
                              },
                              onChanged: (v) => _customInterval = int.tryParse(v) ?? 1,
                            ),
                          ),
                          SizedBox(width: 10),
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.withOpacity(0.3)),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            child: DropdownButton<String>(
                              value: _intervalUnit,
                              underline: SizedBox(),
                              items: intervalUnits
                                  .map((unit) => DropdownMenuItem(
                                value: unit,
                                child: Text(unit, style: TextStyle(fontSize: 14)),
                              ))
                                  .toList(),
                              onChanged: (v) => setState(() => _intervalUnit = v!),
                            ),
                          ),
                        ]),
                      ],
                    ),
                  ),
                ],

                SizedBox(height: 30),
                Center(
                  child: ElevatedButton(
                    onPressed: _saveGoalToFirestore,
                    child: Text("Save Goal"),
                    style: ElevatedButton.styleFrom(
                        minimumSize: Size(200, 50),
                        backgroundColor: Colors.orangeAccent),
                  ),
                ),

              ]),
            ),
          ),
        ));
  }
}