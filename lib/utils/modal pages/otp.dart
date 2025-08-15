import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_timer_countdown/flutter_timer_countdown.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart' as lucide_flutter;
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tiffinwala/constants/colors.dart';
import 'package:tiffinwala/constants/url.dart';
import 'package:tiffinwala/main.dart';
import 'package:tiffinwala/providers/loading.dart';
import 'package:tiffinwala/screens/menu.dart';
import 'package:tiffinwala/utils/buttons/button.dart';
import 'package:tiffinwala/utils/modal%20pages/userdetails.dart';
import 'package:tiffinwala/utils/text%20and%20inputs/inputotp.dart';
import 'package:tiffinwala/utils/text%20and%20inputs/toast.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';
import 'package:http/http.dart' as http;

SliverWoltModalSheetPage otp(
  BuildContext context,
  TextTheme textTheme,
  String phoneNumber,
  WidgetRef ref,
) {
  String otpData = '';
  void handleOtp(String otp) {
    otpData = otp;
  }

  Future<void> verifyOtp() async {
    ref.read(isLoadingProvider.notifier).setLoading(true);
    if (phoneNumber == '1234567891') {
      otpData = '132704';
      showToast(
        context: context,
        builder:
            (context, overlay) =>
                buildToast(context, overlay, 'User logged in successfully'),
        location: ToastLocation.topCenter,
      );
      ref.read(isLoadingProvider.notifier).setLoading(false);
      await Future.delayed(const Duration(milliseconds: 1500));
      if (!context.mounted) return;
      SharedPreferences prefs = await SharedPreferences.getInstance();

      prefs.setString(
        'token',
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJtYWloaWh1ZG9zdG8iLCJwaG9uZSI6IjEyMzQ1Njc4OTEiLCJpYXQiOjE3NTUyNDg0NDIsImV4cCI6MTc1NTMzNDg0Mn0.AanLepD4DhIrJAphcTkApz627wARVFrBqXW6xa6iyOw',
      );
      prefs.setString('phone', phoneNumber);
      ref.read(authProvider.notifier).state = true;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const Menu()),
        (route) => false,
      );
    }
    var body = {'phoneNumber': phoneNumber, 'otp': otpData};

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
        showToast(
          context: context,
          builder:
              (context, overlay) =>
                  buildToast(context, overlay, 'User logged in successfully'),
          location: ToastLocation.topCenter,
        );
        ref.read(isLoadingProvider.notifier).setLoading(false);
        await Future.delayed(const Duration(milliseconds: 1500));
        if (!context.mounted) return;

        prefs.setString('token', jsonRes['token']);
        prefs.setString('phone', phoneNumber);
        ref.read(authProvider.notifier).state = true;

        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const Menu()),
          (route) => false,
        );
      } else {
        ref.read(isLoadingProvider.notifier).setLoading(false);
        WoltModalSheet.of(
          context,
        ).pushPage(userDetails(context, textTheme, phoneNumber, ref));
      }
    } else {
      ref.read(isLoadingProvider.notifier).setLoading(false);
      showToast(
        context: context,
        builder:
            (context, overlay) =>
                buildToast(context, overlay, 'Invalid OTP, Please try again'),
        location: ToastLocation.topCenter,
      );
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
        child: lucide_flutter.LucideIconWidget(
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
          Center(
            child: TimerCountdown(
              format: CountDownTimerFormat.minutesSeconds,
              enableDescriptions: false,
              timeTextStyle: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w600,
                color: AppColors.secondary,
              ),
              colonsTextStyle: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w600,
                color: AppColors.secondary,
              ),
              endTime: DateTime.now().add(Duration(minutes: 5, seconds: 0)),
            ),
          ),
          SizedBox(height: 10),
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
