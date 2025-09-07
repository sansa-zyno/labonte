/*import 'package:flutter/material.dart';

class CustomDateTimeField extends StatefulWidget {
  final String? title;
  final Function(DateTime?)? onTextChanged;
  final DateTime? initialDate;
  final Color color;
  final double widthMultiplier;
  final String? hintText;
  const CustomDateTimeField({
    Key? key,
    this.title,
    this.onTextChanged,
    this.initialDate,
    this.color = kLightColor,
    this.widthMultiplier = 0.8,
    this.hintText,
  }) : super(key: key);

  @override
  State<CustomDateTimeField> createState() => _CustomDateTimeFieldState();
}

class _CustomDateTimeFieldState extends State<CustomDateTimeField> {
  DateFormat dobFormat = DateFormat('yyyy-MM-dd');

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: DateTimeField(
        initialValue: widget.initialDate,
        style: context.theme.textTheme.bodyText2!.copyWith(
          fontWeight: FontWeight.bold,
        ),
        resetIcon: const Icon(Icons.clear),
        decoration: InputDecoration(
          labelText: widget.hintText,
          labelStyle: Theme.of(context).textTheme.subtitle2!.copyWith(
                fontWeight: FontWeight.bold,
                color: getColorBasedOnTheme(context, kDarkColor.withOpacity(0.6), kLightColor.withOpacity(0.6)),
              ),
          contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(width: 2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: getColorBasedOnTheme(context, kDarkColor.withOpacity(0.8), kLightColor.withOpacity(0.8)), width: 2),
          ),
        ),
        onChanged: widget.onTextChanged,
        format: dobFormat,
        onShowPicker: (context, currentValue) {
          return showDatePicker(
              builder: (context, child) {
                return Theme(
                  data: lightTheme.copyWith(
                    colorScheme: const ColorScheme.light().copyWith(
                      primary: kPrimaryColor,
                    ),
                  ),
                  child: child!,
                );
              },
              context: context,
              firstDate: DateTime.utc(1900),
              initialDate: widget.initialDate ?? currentValue ?? DateTime.now(),
              lastDate: DateTime.now());
        },
      ).paddingTop(5),
    );
  }
}*/
