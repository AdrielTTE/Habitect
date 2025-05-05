import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class GoalCreationPage extends StatefulWidget {
  @override
  _GoalCreationPageState createState() => _GoalCreationPageState();
}

class _GoalCreationPageState extends State<GoalCreationPage> {
  final _formKey = GlobalKey<FormState>();
  final List<Map<String, dynamic>> categories = [
    {"name": "Daily", "icon": Icons.today},
    {"name": "Family", "icon": Icons.family_restroom},
    {"name": "Groceries", "icon": Icons.shopping_cart},
    {"name": "Exercise", "icon": Icons.fitness_center},
    {"name": "Works", "icon": Icons.home_repair_service},
    {"name": "Schools", "icon": Icons.book},
    {"name": "Others", "icon": Icons.more_horiz},
  ];

  // Controllers and State Variables
  int _currentCategoryIndex = 0;
  TextEditingController _taskController = TextEditingController();
  TextEditingController _dateController = TextEditingController();
  TextEditingController _timeController = TextEditingController();
  TextEditingController _endDateController = TextEditingController();
  TextEditingController _endTimeController = TextEditingController();
  String _selectedFrequency = "Daily";
  bool _reminderEnabled = false;
  bool _isOneTime = false;
  int _reminderInDays = 1;
  int _reminderInHours = 1;
  int _reminderInMinutes = 1;
  String _reminderType = 'minute';

  // Frequency variables
  final List<String> frequencies = ["Daily", "Weekly", "Monthly", "Custom"];
  int _customInterval = 1;
  String _intervalUnit = "Days";
  final List<String> intervalUnits = ["Days", "Weeks", "Months"];

  void _showValidationError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showCongratulationsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
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
                Navigator.of(context).pop();
                _taskController.clear();
                _dateController.clear();
                _timeController.clear();
                _endDateController.clear();
                _endTimeController.clear();
                setState(() {
                  _reminderEnabled = false;
                  _selectedFrequency = "Daily";
                  _currentCategoryIndex = 0;
                  _customInterval = 1;
                  _intervalUnit = "Days";
                  _isOneTime = true;
                });
              },
              child: Text(
                "Create another one",
                style: TextStyle(color: Colors.orange, fontSize: 16),
              ),
            ), // Added comma here
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                "Complete",
                style: TextStyle(color: Colors.orange, fontSize: 16),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showReminderTimePicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text("Set Reminder Time"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    DropdownButton<String>(
                      value: _reminderType,
                      items: <String>['minute', 'hour', 'day']
                          .map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text("Set reminder in $value(s)"),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setDialogState(() {
                          _reminderType = newValue!;
                        });
                        setState(() {
                          switch (_reminderType) {
                            case 'minute':
                              _reminderInMinutes = 1;
                              break;
                            case 'hour':
                              _reminderInHours = 1;
                              break;
                            case 'day':
                              _reminderInDays = 1;
                              break;
                          }
                        });
                      },
                    ),
                    SizedBox(height: 20),
                    if (_reminderType == 'minute')
                      _buildSlider("minute", 1, 60, _reminderInMinutes, (value) {
                        setDialogState(() => _reminderInMinutes = value.toInt());
                      }),
                    if (_reminderType == 'hour')
                      _buildSlider("hour", 1, 24, _reminderInHours, (value) {
                        setDialogState(() => _reminderInHours = value.toInt());
                      }),
                    if (_reminderType == 'day')
                      _buildSlider("day", 1, 30, _reminderInDays, (value) {
                        setDialogState(() => _reminderInDays = value.toInt());
                      }),
                  ],
                ),
              ),
              actions: [
                TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text("Cancel")),
                TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text("Save")),
              ],
            );
          },
        );
      },
    );
  }

  String _getReminderText() {
    if (!_reminderEnabled) return 'No reminder';
    switch (_reminderType) {
      case 'minute':
        return 'Remind me $_reminderInMinutes minute${_reminderInMinutes != 1 ? 's' : ''} before';
      case 'hour':
        return 'Remind me $_reminderInHours hour${_reminderInHours != 1 ? 's' : ''} before';
      case 'day':
        return 'Remind me $_reminderInDays day${_reminderInDays != 1 ? 's' : ''} before';
      default:
        return 'Reminder set';
    }
  }

  Widget _buildSlider(String label, double min, double max, int currentValue,
      Function(double) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Set reminder in $label(s)", style: TextStyle(fontSize: 18)),
        Slider(
          value: currentValue.toDouble(),
          min: min,
          max: max,
          divisions: (max - min).toInt(),
          label: "$currentValue $label(s)",
          onChanged: (value) {
            onChanged(value);
            WidgetsBinding.instance.addPostFrameCallback((_) {
              setState(() {
                switch (label) {
                  case 'minute':
                    _reminderInMinutes = value.toInt();
                    break;
                  case 'hour':
                    _reminderInHours = value.toInt();
                    break;
                  case 'day':
                    _reminderInDays = value.toInt();
                    break;
                }
              });
            });
          },
        ),
        Text("Selected: $currentValue $label(s)",
            style: TextStyle(fontSize: 18)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Goal Creation")),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category Carousel
                Text("Choose a Category", style: TextStyle(fontSize: 18)),
                CarouselSlider.builder(
                  itemCount: categories.length,
                  itemBuilder: (context, index, realIndex) => GestureDetector(
                    onTap: () => setState(() => _currentCategoryIndex = index),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(categories[index]["icon"], size: 50),
                        SizedBox(height: 10),
                        Text(categories[index]["name"],
                            style: TextStyle(fontSize: 18)),
                      ],
                    ),
                  ),
                  options: CarouselOptions(
                    height: 125,
                    enlargeCenterPage: true,
                    viewportFraction: 0.25,
                    initialPage: 0,
                    enableInfiniteScroll: false,
                    autoPlay: false,
                    onPageChanged: (index, _) =>
                        setState(() => _currentCategoryIndex = index),
                  ),
                ),

                // Task Input
                SizedBox(height: 20),
                Text("What do you want to do?", style: TextStyle(fontSize: 18)),
                TextFormField(
                  controller: _taskController,
                  decoration: InputDecoration(
                    hintText: "Enter your task",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                  value?.isEmpty ?? true ? 'Please enter a task name' : null,
                ),

                // Start Date & Time
                SizedBox(height: 20),
                Text("Start Date & Time", style: TextStyle(fontSize: 18)),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _dateController,
                        readOnly: true,
                        decoration: InputDecoration(
                          hintText: "Select date",
                          suffixIcon: IconButton(
                            icon: Icon(Icons.calendar_today),
                            onPressed: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2101),
                              );
                              if (date != null) {
                                setState(() => _dateController.text =
                                "${date.month}/${date.day}/${date.year}");
                              }
                            },
                          ),
                        ),
                        validator: (value) =>
                        value?.isEmpty ?? true ? 'Please select date' : null,
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
                              final time = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay.now(),
                              );
                              if (time != null) {
                                setState(() {
                                  _timeController.text = time.format(context);
                                });
                              }
                            },
                          ),
                        ),
                        validator: (value) {
                          if (value?.isEmpty ?? true) return 'Please select time';
                          try {
                            DateFormat("h:mm a").parse(value!);
                            return null;
                          } catch (e) {
                            return 'Invalid time format (Use HH:MM AM/PM)';
                          }
                        },
                      ),
                    ),
                  ],
                ),

                // One-time Event Switch
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("One-time Event?", style: TextStyle(fontSize: 18)),
                    Switch(
                      value: _isOneTime,
                      onChanged: (value) {
                        setState(() {
                          _isOneTime = value;
                          if (_isOneTime) {
                            _selectedFrequency = "Daily";
                            _customInterval = 1;
                            _intervalUnit = "Days";
                          }
                        });
                      },
                    ),
                  ],
                ),

                // Recurring Task Fields
                if (!_isOneTime) ...[
                  SizedBox(height: 20),
                  Text("Frequency", style: TextStyle(fontSize: 18)),
                  DropdownButton<String>(
                    value: _selectedFrequency,
                    items: frequencies.map((f) =>
                        DropdownMenuItem(value: f, child: Text(f))).toList(),
                    onChanged: (value) =>
                        setState(() => _selectedFrequency = value!),
                  ),

                  if (_selectedFrequency == "Custom")
                    Padding(
                      padding: EdgeInsets.only(top: 10),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.withOpacity(0.5)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Custom Frequency",
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                            SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    keyboardType: TextInputType.number,
                                    initialValue: _customInterval.toString(),
                                    decoration: InputDecoration(
                                      labelText: 'Every',
                                      border: OutlineInputBorder(),
                                      contentPadding: EdgeInsets.symmetric(horizontal: 12),
                                    ),
                                    validator: (value) {
                                      if (_selectedFrequency == "Custom") {
                                        if (value?.isEmpty ?? true) return 'Enter interval';
                                        final num = int.tryParse(value!);
                                        if (num == null || num < 1) return 'Enter valid number';
                                      }
                                      return null;
                                    },
                                    onChanged: (value) =>
                                    _customInterval = int.tryParse(value) ?? 1,
                                  ),
                                ),
                                SizedBox(width: 10),
                                Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey.withOpacity(0.3)),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 8),
                                    child: DropdownButton<String>(
                                      value: _intervalUnit,
                                      underline: SizedBox(),
                                      items: intervalUnits.map((unit) => DropdownMenuItem(
                                        value: unit,
                                        child: Text(unit, style: TextStyle(fontSize: 14)),
                                      )).toList(),
                                      onChanged: (value) =>
                                          setState(() => _intervalUnit = value!),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                  // End Date & Time
                  SizedBox(height: 20),
                  Text("End Date & Time", style: TextStyle(fontSize: 18)),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _endDateController,
                          readOnly: true,
                          decoration: InputDecoration(
                            hintText: "Select end date",
                            suffixIcon: IconButton(
                              icon: Icon(Icons.calendar_today),
                              onPressed: () async {
                                final date = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime(2101),
                                );
                                if (date != null) {
                                  setState(() => _endDateController.text =
                                  "${date.month}/${date.day}/${date.year}");
                                }
                              },
                            ),
                          ),
                          validator: (value) {
                            if (!_isOneTime && (value?.isEmpty ?? true)) {
                              return 'Please select end date';
                            }
                            if (value?.isNotEmpty ?? false) {
                              final datePattern = RegExp(r'^\d{1,2}/\d{1,2}/\d{4}$');
                              if (!datePattern.hasMatch(value!)) {
                                return 'Invalid date format (MM/DD/YYYY)';
                              }
                            }
                            return null;
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
                                final time = await showTimePicker(
                                  context: context,
                                  initialTime: TimeOfDay.now(),
                                );
                                if (time != null) {
                                  setState(() => _endTimeController.text = time.format(context));
                                }
                              },
                            ),
                          ),
                          validator: (value) {
                            if (!_isOneTime && (value?.isEmpty ?? true)) {
                              return 'Please select end time';
                            }
                            if (value?.isNotEmpty ?? false) {
                              try {
                                DateFormat("h:mm a").parse(value!);
                                return null;
                              } catch (e) {
                                return 'Invalid time format (HH:MM AM/PM)';
                              }
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                ],

                // Reminder Section
                SizedBox(height: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Set a reminder", style: TextStyle(fontSize: 18)),
                        Switch(
                          value: _reminderEnabled,
                          onChanged: (value) {
                            setState(() => _reminderEnabled = value);
                            if (value) _showReminderTimePicker(context);
                          },
                        ),
                      ],
                    ),
                    Visibility(
                      visible: _reminderEnabled,
                      child: Padding(
                        padding: EdgeInsets.only(top: 8.0),
                        child: Text(
                          _getReminderText(),
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                // Action Buttons
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        _formKey.currentState?.reset();
                        _taskController.clear();
                        _dateController.clear();
                        _timeController.clear();
                        _endDateController.clear();
                        _endTimeController.clear();
                        setState(() {
                          _reminderEnabled = false;
                          _selectedFrequency = "Daily";
                          _currentCategoryIndex = 0;
                          _customInterval = 1;
                          _intervalUnit = "Days";
                          _isOneTime = true;
                        });
                      },
                      child: Text("Cancel"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                        minimumSize: Size(170, 50),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          try {
                            final startDatePattern = RegExp(r'^\d{1,2}/\d{1,2}/\d{4}$');
                            if (!startDatePattern.hasMatch(_dateController.text)) {
                              throw FormatException('Invalid start date format (MM/DD/YYYY)');
                            }
                            final startDateParts = _dateController.text.split('/');
                            final month = int.parse(startDateParts[0]);
                            final day = int.parse(startDateParts[1]);
                            final year = int.parse(startDateParts[2]);

                            // Parse start time
                            final startTime = DateFormat("h:mm a").parse(_timeController.text);

                            // Combine into DateTime
                            final startDateTime = DateTime(
                              year,
                              month,
                              day,
                              startTime.hour,
                              startTime.minute,
                            );

                            // Create Firestore document
                            final taskData = {
                              'category': categories[_currentCategoryIndex]["name"],
                              'title': _taskController.text,
                              'date': _dateController.text,
                              'time': DateFormat.jm().format(startDateTime),
                              'isOneTime': _isOneTime,
                              'reminder': _reminderEnabled ? {
                                'type': _reminderType,
                                'value': _reminderType == 'minute'
                                    ? _reminderInMinutes
                                    : _reminderType == 'hour'
                                    ? _reminderInHours
                                    : _reminderInDays,
                              } : null,
                            };

                            // Add recurring task fields if not one-time
                            if (!_isOneTime) {
                              // Add end date/time
                              taskData['endDate'] = _endDateController.text;
                              taskData['endTime'] = _endTimeController.text;

                              // Add frequency information
                              if (_selectedFrequency == "Custom") {
                                taskData['frequency'] = {
                                  'type': 'Custom',
                                  'interval': _customInterval,
                                  'unit': _intervalUnit,
                                };
                              } else {
                                taskData['frequency'] = {
                                  'type': _selectedFrequency,
                                };
                              }
                            }

                            await FirebaseFirestore.instance
                                .collection('To Do')
                                .add(taskData);

                            _showCongratulationsDialog(context);
                          } catch (e) {
                            _showValidationError(e.toString().replaceAll('FormatException: ', ''));
                          }
                        }
                      },
                      child: Text("Save"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        minimumSize: Size(170, 50),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}