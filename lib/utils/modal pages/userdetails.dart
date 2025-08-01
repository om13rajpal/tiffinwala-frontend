import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tiffinwala/constants/url.dart';
import 'package:tiffinwala/main.dart';
import 'package:tiffinwala/providers/loading.dart';
import 'package:tiffinwala/utils/buttons/button.dart';
import 'package:tiffinwala/utils/text%20and%20inputs/input.dart';
import 'package:tiffinwala/utils/text%20and%20inputs/toast.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';
import 'package:http/http.dart' as http;

SliverWoltModalSheetPage userDetails(
  BuildContext context,
  TextTheme textTheme,
  String phoneNumber,
  WidgetRef ref,
) {
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController referralController = TextEditingController();

  Future<void> registerUser() async {
    ref.read(isLoadingProvider.notifier).setLoading(true);

    var body = {
      'firstName': firstNameController.text.trim(),
      'lastName': lastNameController.text.trim(),
      'phoneNumber': phoneNumber,
      'address': addressController.text.trim(),
      'referral': referralController.text.trim(),
    };

    var response = await http.post(
      Uri.parse('${BaseUrl.url}/user/signup'),
      body: jsonEncode(body),
      headers: {'Content-Type': 'application/json'},
    );

    var jsonRes = await jsonDecode(response.body);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (!context.mounted) return;

    if (jsonRes['status']) {
      ref.read(isLoadingProvider.notifier).setLoading(false);

      prefs.setString('token', jsonRes['token']);
      prefs.setString('phone', phoneNumber);
      ref.read(authProvider.notifier).state = true;
      Navigator.popUntil(context, (route) => route.isFirst);
    } else {
      ref.read(isLoadingProvider.notifier).setLoading(false);
      shadcn.showToast(
        context: context,
        builder:
            (context, overlay) => buildToast(
              context,
              overlay,
              'Error registering, please try again',
            ),
        location: shadcn.ToastLocation.topCenter,
      );
      log('user not registered');
    }
  }

  return WoltModalSheetPage(
    child: SizedBox(),
    topBar: Center(
      child: Text(
        'Enter your details',
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
    heroImageHeight: 400,
    heroImage: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
      child: Column(
        spacing: 15,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Input(
            prefix: false,
            label: 'First Name',
            hint: 'John',
            controller: firstNameController,
          ),
          Input(
            prefix: false,
            label: 'Last Name',
            hint: 'Doe',
            controller: lastNameController,
          ),
          Input(
            prefix: false,
            label: 'Address',
            hint: 'Street xyz, Patiala',
            controller: addressController,
          ),
          Input(
            prefix: false,
            label: 'Referral (optional)',
            hint: '',
            controller: referralController,
          ),
          TiffinButton(
            label: 'SAVE',
            width: 65,
            height: 28,
            onPressed: () {
              registerUser();
            },
          ),
        ],
      ),
    ),
  );
}
