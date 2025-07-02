import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tiffinwala/constants/url.dart';
import 'package:tiffinwala/providers/address.dart';
import 'package:tiffinwala/providers/addressloaded.dart';
import 'package:tiffinwala/providers/firstname.dart';
import 'package:tiffinwala/providers/lastname.dart';
import 'package:tiffinwala/providers/nameloaded.dart';

class AddressPage extends ConsumerStatefulWidget {
  const AddressPage({super.key});

  @override
  ConsumerState<AddressPage> createState() => _AddressPageState();
}

class _AddressPageState extends ConsumerState<AddressPage> {
  final TextEditingController _controller = TextEditingController();

  Future<void> getUserData(WidgetRef ref, String phone, String token) async {
    try {
      final res = await http.get(
        Uri.parse('${BaseUrl.url}/user/$phone'),
        headers: {
          'Content-Type': 'application/json',
          'authorization': 'Bearer $token',
        },
      );

      final jsonRes = jsonDecode(res.body);

      if (jsonRes['status'] == true) {
        final firstName = jsonRes['data']['firstName'] as String;
        final lastName = jsonRes['data']['lastName'] as String;

        final addressesRaw = jsonRes['data']['address'] as List<dynamic>;

        final addressStrings =
            addressesRaw
                .map((e) => e?.toString() ?? "")
                .where((e) => e.isNotEmpty)
                .toList();

        ref.read(setFirstNameProvider.notifier).setFirstName(firstName);
        ref.read(setLastNameProvider.notifier).setLastName(lastName);
        ref.read(addressProvider.notifier).setAddresses(addressStrings);

        ref.read(isNameLoadedProvider.notifier).setNameLoaded(false);
        ref.read(isAddressLoadedProvider.notifier).setAddressLoaded(false);
      } else {
        log("Failed to fetch user data: ${jsonRes['message']}");
      }
    } catch (e) {
      log("Error fetching user data: $e");
    }
  }

  Future<void> addAddressToBackend(String address) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final phone = prefs.getString('phone');
    final token = prefs.getString('token');

    final res = await http.put(
      Uri.parse('${BaseUrl.url}/user/address/$phone'),
      headers: {
        'Content-Type': 'application/json',
        'authorization': 'Bearer $token',
      },
      body: jsonEncode({"address": address}),
    );

    final jsonRes = jsonDecode(res.body);

    if (jsonRes['status'] == true) {
      await getUserData(ref, phone!, token!);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(jsonRes['message'] ?? 'Failed to add address')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final addresses = ref.watch(addressProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(
                      LucideIcons.arrowLeft,
                      color: Colors.white,
                      size: 20,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'My Addresses',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),

            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Saved Addresses',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF777B8A),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Address list
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child:
                    addresses.isEmpty
                        ? Center(
                          child: Text(
                            "No addresses saved.",
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 14,
                            ),
                          ),
                        )
                        : ListView.separated(
                          itemCount: addresses.length,
                          separatorBuilder:
                              (_, __) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final addr = addresses[index];

                            return GestureDetector(
                              onTap: () {
                                ref
                                    .read(addressProvider.notifier)
                                    .setPrimary(addr.id);
                              },
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1A1A1A),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color:
                                        addr.isPrimary
                                            ? const Color(0xFF285531)
                                            : Colors.transparent,
                                    width: addr.isPrimary ? 1.2 : 0,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        addr.address,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    if (addr.isPrimary)
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF285531),
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                        child: Text(
                                          'Primary',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
              ),
            ),

            const SizedBox(height: 20),

            // Add new address field
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: _controller,
                style: TextStyle(color: Colors.white),
                cursorColor: Color(0xFF285531),
                decoration: InputDecoration(
                  hintText: "Enter new address",
                  hintStyle: TextStyle(color: Colors.white38),
                  filled: false,
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white24, width: 1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Color(0xFF285531),
                      width: 1.3,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Add Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ElevatedButton(
                onPressed: () async {
                  final newAddr = _controller.text.trim();
                  if (newAddr.isNotEmpty) {
                    await addAddressToBackend(newAddr);
                    _controller.clear();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF285531),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  minimumSize: Size(double.infinity, 48),
                  elevation: 0,
                ),
                child: Text(
                  "Add Address",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
