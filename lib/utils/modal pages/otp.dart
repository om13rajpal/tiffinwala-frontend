import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tiffinwala/constants/colors/url.dart';
import 'package:tiffinwala/screens/menu.dart';
import 'package:tiffinwala/utils/buttons/button.dart';
import 'package:tiffinwala/utils/modal%20pages/userdetails.dart';
import 'package:tiffinwala/utils/text%20and%20inputs/inputotp.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';
import 'package:http/http.dart' as http;

SliverWoltModalSheetPage otp(
  BuildContext context,
  TextTheme textTheme,
  String phoneNumber,
) {
  String otpData = '';
  void handleOtp(String otp) {
    otpData = otp;
  }

  Future<void> verifyOtp() async {
    var body = {'phoneNumber': '+91$phoneNumber', 'otp': otpData};

    var response = await http.post(
      Uri.parse('${BaseUrl.url}/otp/verify'),
      body: jsonEncode(body),
      headers: {'Content-Type': 'application/json'},
    );

    var jsonRes = await jsonDecode(response.body);

    if (!context.mounted) return;

    if (jsonRes['status']) {
      var body = {'phoneNumber': phoneNumber};
      var response = await http.post(
        Uri.parse('${BaseUrl.url}/user/auth'),
        body: jsonEncode(body),
        headers: {'Content-Type': 'application/json'},
      );

      var jsonRes = await jsonDecode(response.body);

      SharedPreferences prefs = await SharedPreferences.getInstance();
      if (!context.mounted) return;
      if (jsonRes['status']) {
        prefs.setString('token', jsonRes['token']);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Menu()),
        );
      } else {
        WoltModalSheet.of(
          context,
        ).pushPage(userDetails(context, textTheme, phoneNumber));
      }
    } else {
      log('otp not verified');
    }
  }

  return WoltModalSheetPage(
    topBar: const Center(
      child: Text(
        'Enter the OTP',
        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    ),
    isTopBarLayerAlwaysVisible: true,
    useSafeArea: true,
    leadingNavBarWidget: Padding(
      padding: const EdgeInsets.only(left: 20),
      child: GestureDetector(
        onTap: () {
          WoltModalSheet.of(context).showPrevious();
        },
        child: LucideIconWidget(
          icon: LucideIcons.arrowUpLeft,
          size: 18,
          strokeWidth: 2,
        ),
      ),
    ),
    child: Padding(
      padding: EdgeInsets.symmetric(vertical: 20),
      child: Column(
        spacing: 10,
        children: [
          Otp(otpHandler: handleOtp),
          TiffinButton(
            label: 'VERIFY',
            width: 70,
            height: 28,
            onPressed: () {
              verifyOtp();
            },
          ),
        ],
      ),
    ),
  );
}
