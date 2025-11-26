import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DatePickerCalendar extends StatefulWidget {
  const DatePickerCalendar({super.key});

  @override
  State<DatePickerCalendar> createState() => _DatePickerCalendarState();
}

class _DatePickerCalendarState extends State<DatePickerCalendar> {
  DateTime selectedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      title: Center(
        child: Text(
          "Pick a Date",
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.black),
        ),
      ),
      content: SizedBox(
        height: 320,
        width: 350,
        child: CalendarDatePicker(
          initialDate: selectedDay,
          firstDate: DateTime(2020),
          lastDate: DateTime(2100),
          onDateChanged: (date) {
            setState(() => selectedDay = date);
          },
        ),
      ),
      actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, null),
          child: Text(
            "Cancel",
            style: GoogleFonts.poppins(fontWeight: FontWeight.w500, color: Colors.black),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF07BEB8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: () => Navigator.pop(context, selectedDay),
          child: Text(
            "Select",
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.white),
          ),
        ),
      ],
    );
  }
}