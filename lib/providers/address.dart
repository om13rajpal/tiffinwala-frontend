import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

class AddressModel {
  final String id;
  final String address;
  final bool isPrimary;

  AddressModel({
    required this.id,
    required this.address,
    this.isPrimary = false,
  });

  AddressModel copyWith({
    String? id,
    String? address,
    bool? isPrimary,
  }) {
    return AddressModel(
      id: id ?? this.id,
      address: address ?? this.address,
      isPrimary: isPrimary ?? this.isPrimary,
    );
  }
}


class AddressNotifier extends StateNotifier<List<AddressModel>> {
  AddressNotifier() : super([]);

  void setAddresses(List<String> addresses) {
    state = addresses.asMap().entries.map((entry) {
      return AddressModel(
        id: const Uuid().v4(),
        address: entry.value,
        isPrimary: entry.key == 0, // make the first primary
      );
    }).toList();
  }

  void addAddress(String newAddress) {
    final newAddr = AddressModel(
      id: const Uuid().v4(),
      address: newAddress,
      isPrimary: state.isEmpty, // if first address, make primary
    );
    state = [...state, newAddr];
  }

  void setPrimary(String id) {
    state = state.map((addr) {
      return addr.copyWith(isPrimary: addr.id == id);
    }).toList();
  }
}

final addressProvider =
    StateNotifierProvider<AddressNotifier, List<AddressModel>>(
  (ref) => AddressNotifier(),
);