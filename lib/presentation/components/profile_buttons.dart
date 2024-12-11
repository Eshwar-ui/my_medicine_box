import 'package:flutter/material.dart';

class myButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onTap;
  const myButton(
      {super.key, required this.text, required this.onTap, required this.icon});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(10),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
            ),
            SizedBox(
              width: 20,
            ),
            Text(
              text,
              style: TextStyle(fontSize: 20),
            ),
          ],
        ),
      ),
    );
  }
}
