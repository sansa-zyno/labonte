/*import 'package:flutter/material.dart';

class CustomFilePickerField extends StatefulWidget {
  final String? title;
  final String? hintText;
  final Function? onTap;

  const CustomFilePickerField({this.hintText, this.onTap, this.title, Key? key})
      : super(key: key);

  @override
  State<CustomFilePickerField> createState() => _CustomFilePickerFieldState();
}

class _CustomFilePickerFieldState extends State<CustomFilePickerField> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.only(top: 0.0, left: 16.0, bottom: 8.0),
          alignment: Alignment.topLeft,
          child: Text(
            '${widget.title}',
            style: const TextStyle(
              fontSize: 12.0,
              color: kPrimaryDarkTextColor,
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
        GestureDetector(
          onTap: widget.onTap as void Function()?,
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: 50,
            decoration: BoxDecoration(
              border: Border.all(color: kPrimaryColor),
              borderRadius: const BorderRadius.all(Radius.circular(6.0)),
            ),
            margin:
                const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 15.0),
            padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 0.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '${widget.hintText}',
                style: const TextStyle(
                  fontSize: 16.0,
                  color: kPrimaryDarkTextColor,
                  fontWeight: FontWeight.normal,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ),
        ),
      ],
    );
  }
}*/
