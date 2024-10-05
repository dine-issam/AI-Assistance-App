import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MyMessage extends StatelessWidget {
  const MyMessage({super.key, required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topRight,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: message.isEmpty
            ? null
            : Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Text(
                  message,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                  ),
                ),
              ),
      ),
    );
  }
}
