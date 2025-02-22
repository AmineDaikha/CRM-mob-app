import 'package:flutter/material.dart';

class CustomSwitch extends StatefulWidget {
  final double width;
  final bool value;
  final ValueChanged<bool> onChanged;

  CustomSwitch({
    required this.width,
    required this.value,
    required this.onChanged,
  });

  @override
  _CustomSwitchState createState() => _CustomSwitchState();
}

class _CustomSwitchState extends State<CustomSwitch> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      child: InkWell(
        onTap: () {
          widget.onChanged(!widget.value);
        },
        child: Stack(
          children: [
            Container(
              width: widget.width,
              height: 30,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: widget.value ? Colors.blue : Colors.grey,
              ),
              alignment: widget.value ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}