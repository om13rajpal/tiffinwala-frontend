import 'package:flutter/material.dart';

class Details extends StatelessWidget {
  final String title;
  final String detail;
  final String badge;
  const Details({super.key, required this.title, required this.detail, required this.badge});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 45,
      margin: EdgeInsets.only(bottom: 7),
      padding: EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Color(0xff212121),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFFFFFFFF),
                ),
              ),
              Text(
                detail,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF9F9F9F),
                ),
              ),
            ],
          ),
          Container(
            height: 16,
            width: 56,
            decoration: BoxDecoration(
              color: Color(0xff285531),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Center(
              child: Text(
                badge,
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 7.5,
                  color: Color(0xFF98B995),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
