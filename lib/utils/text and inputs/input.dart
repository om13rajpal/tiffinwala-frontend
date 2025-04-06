import 'package:flutter/material.dart';
import 'package:tiffinwala/constants/colors.dart';

class Input extends StatelessWidget {
  final bool prefix;
  final String label;
  final String hint;
  final TextEditingController controller;
  const Input({
    super.key,
    required this.prefix,
    required this.label,
    required this.hint, required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 5,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Color(0XFFC9C9C9),
          ),
        ),
        SizedBox(
          height: 36,
          child: TextField(
            controller: controller,
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w500,
              color: AppColors.secondary,
            ),
            textAlignVertical: TextAlignVertical.center,
            cursorOpacityAnimates: true,
            enableIMEPersonalizedLearning: true,
            enableInteractiveSelection: true,
            keyboardType: TextInputType.text,
            stylusHandwritingEnabled: true,
            decoration: InputDecoration(
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: const Color.fromARGB(255, 94, 94, 94),
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: const Color.fromARGB(255, 94, 94, 94),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              hintText: hint,
              hintStyle: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Color(0XFF505050),
              ),
              border: InputBorder.none,
              prefixStyle: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: AppColors.secondary,
              ),
              hintFadeDuration: const Duration(milliseconds: 150),
              prefixIcon:
                  (prefix)
                      ? Padding(
                        padding: const EdgeInsets.only(top: 8, left: 8),
                        child: Text(
                          '+91',
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                            color: Color(0XFFD0D0D0),
                          ),
                        ),
                      )
                      : null,
            ),
          ),
        ),
      ],
    );
  }
}
