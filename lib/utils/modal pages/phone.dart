import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:tiffinwala/constants/url.dart';
import 'package:tiffinwala/utils/buttons/button.dart';
import 'package:tiffinwala/utils/modal%20pages/otp.dart';
import 'package:tiffinwala/utils/text%20and%20inputs/gradientext.dart';
import 'package:tiffinwala/utils/text%20and%20inputs/input.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';
import 'package:http/http.dart' as http;

SliverWoltModalSheetPage phone(BuildContext context, TextTheme textTheme) {
  TextEditingController phoneController = TextEditingController();

  Future<void> sendOtp() async {
    var body = {'phoneNumber': '+91${phoneController.text.trim()}'};

    var response = await http.post(
      Uri.parse('${BaseUrl.url}/otp/send'),
      body: jsonEncode(body),
      headers: {'Content-Type': 'application/json'},
    );

    var jsonRes = await jsonDecode(response.body);

    if (!context.mounted) return;
    if (jsonRes['status'] == true) {
      log('otp sent');
      WoltModalSheet.of(
        context,
      ).pushPage(otp(context, textTheme, phoneController.text.trim()));
    } else {
      log('otp not sent');
    }
  }

  return WoltModalSheetPage(
    child: SizedBox(),
    heroImageHeight: 220,
    heroImage: Container(
      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 15,
        children: [
          const Row(
            children: [
              Text(
                'Hola amigo!',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              SizedBox(width: 5),
              GradientText(),
            ],
          ),
          Input(
            controller: phoneController,
            prefix: true,
            label: 'Phone Number',
            hint: 'Phone Number',
          ),
          TiffinButton(
            label: 'GET IN',
            width: 65,
            height: 28,
            onPressed: () {
              sendOtp();
            },
          ),
        ],
      ),
    ),
  );
}
