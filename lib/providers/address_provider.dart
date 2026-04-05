import 'package:flutter/foundation.dart';
import '../models/address.dart';
import '../data/app_data.dart';

/// Manages the currently selected delivery/pickup address.
class AddressProvider extends ChangeNotifier {
  int _selectedId = 1;

  int get selectedId => _selectedId;

  List<Address> get addresses => AppData.savedAddresses;

  Address get selected => AppData.savedAddresses.firstWhere(
        (a) => a.id == _selectedId,
        orElse: () => AppData.savedAddresses.first,
      );

  void select(int id) {
    _selectedId = id;
    notifyListeners();
  }

  void addAddress(Address address) {
    AppData.addAddress(address);
    _selectedId = address.id;
    notifyListeners();
  }

  void removeAddress(int id) {
    AppData.removeAddress(id);
    if (_selectedId == id && AppData.savedAddresses.isNotEmpty) {
      _selectedId = AppData.savedAddresses.first.id;
    }
    notifyListeners();
  }
}
