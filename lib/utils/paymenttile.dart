import 'package:flutter/material.dart';

class PaymentDetailsTile extends StatelessWidget {
  final String title;
  final String badge;
  final IconData icon;

  const PaymentDetailsTile({
    super.key,
    required this.title,
    required this.badge,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      margin: const EdgeInsets.only(bottom: 7),
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: const Color(0xff212121),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: Colors.white.withValues(alpha: 200)),
              const SizedBox(width: 12),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFFFFFFFF),
                    ),
                  ),
                ],
              ),
            ],
          ),
          Container(
            height: 16,
            width: 56,
            decoration: BoxDecoration(
              color:
                  badge.isNotEmpty
                      ? const Color(0xff285531)
                      : Colors.transparent,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Center(
              child: Text(
                badge,
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 7.5,
                  color:
                      badge.isNotEmpty
                          ? const Color(0xFF98B995)
                          : Colors.transparent,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
