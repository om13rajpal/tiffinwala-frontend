import 'package:flutter/material.dart';
import 'package:tiffinwala/constants/colors/colors.dart';

class ItemDetails extends StatelessWidget {
  const ItemDetails({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 3,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset('assets/icons/veg.png', width: 11, fit: BoxFit.cover),
              SizedBox(width: 5),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 0.5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(3.5),
                  color: Color(0xFFF78080),
                ),
                child: Center(
                  child: Text(
                    'Best Seller',
                    style: TextStyle(
                      fontSize: 6,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFB30000),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 150,
                child: Text(
                  'Veg Biryani with Raita & Salad',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
              SizedBox(
                width: 50,
                height: 24,
                child: ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll(Color(0xFF3E3E3E)),
                    padding: WidgetStatePropertyAll(
                      EdgeInsets.symmetric(horizontal: 6),
                    ),
                    shape: WidgetStatePropertyAll(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                  onPressed: () {},
                  child: Text(
                    'ADD',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: AppColors.secondary,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Text(
            '₹ 79',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: Color(0xFF787878),
            ),
          ),
        ],
      ),
    );
  }
}
