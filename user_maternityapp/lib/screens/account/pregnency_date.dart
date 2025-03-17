import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:user_maternityapp/screens/account/auth_page.dart';
import 'package:user_maternityapp/main.dart';

class PregnancyDatePicker extends StatefulWidget {
  const PregnancyDatePicker({super.key});

  @override
  _PregnancyDate createState() => _PregnancyDate();
}

class _PregnancyDate extends State<PregnancyDatePicker> {
  DateTime _selectedDate = DateTime.now();

  Future<void> updatePD() async {
    try {
      String userId = supabase.auth.currentUser!.id;
      await supabase.from('tbl_user').update({
        'user_pregnancy_date':
            _selectedDate.toIso8601String(), // Convert to string
      }).eq('id', userId);
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => AuthPage()));
    } catch (e) {
      print("Error : $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 170, 200, 252),
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 66, 68, 202),
        title: Text("Select Pregnancy Start Date"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TableCalendar(
              focusedDay: _selectedDate,
              firstDay: DateTime.now().subtract(Duration(days: 280)),
              lastDay: DateTime.now(),
              calendarFormat: CalendarFormat.month,
              selectedDayPredicate: (day) {
                return isSameDay(_selectedDate, day);
              },
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDate = selectedDay;
                });
              },
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
              ),
            ),
          ),
          SizedBox(height: 20),
          Text(
            "Selected Date: ${_selectedDate.toLocal()}".split(' ')[0],
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onPressed: () {
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => AuthPage()));
                },
                child: Text("Skip"),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF4A90E2),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onPressed: () {
                  // Continue button action
                  updatePD();
                },
                child: Text("Continue"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
