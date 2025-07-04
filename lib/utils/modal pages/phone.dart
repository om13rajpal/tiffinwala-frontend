import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tiffinwala/constants/url.dart';
import 'package:tiffinwala/providers/loading.dart';
import 'package:tiffinwala/utils/buttons/button.dart';
import 'package:tiffinwala/utils/modal%20pages/otp.dart';
import 'package:tiffinwala/utils/text%20and%20inputs/gradientext.dart';
import 'package:tiffinwala/utils/text%20and%20inputs/input.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';
import 'package:http/http.dart' as http;

SliverWoltModalSheetPage phone(
  BuildContext context,
  TextTheme textTheme,
  WidgetRef ref,
) {
  TextEditingController phoneController = TextEditingController();

  Future<void> sendOtp() async {
    ref.read(isLoadingProvider.notifier).setLoading(true);
    var body = {'phoneNumber': phoneController.text.trim()};

    var response = await http.post(
      Uri.parse('${BaseUrl.url}/otp/send'),
      body: jsonEncode(body),
      headers: {'Content-Type': 'application/json'},
    );

    var jsonRes = await jsonDecode(response.body);

    if (!context.mounted) return;
    if (jsonRes['status'] == true) {
      ref.read(isLoadingProvider.notifier).setLoading(false);
      log('otp sent');
      WoltModalSheet.of(
        context,
      ).pushPage(otp(context, textTheme, phoneController.text.trim(), ref));
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
              GradientText(text: 'Get In'),
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
