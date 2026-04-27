import 'package:flutter/material.dart';

class AppSettings extends ChangeNotifier {
  bool _darkMode = false;
  bool _notifications = true;
  bool _locationServices = true;
  String _vehicleType = 'four_wheeler';

  bool get darkMode => _darkMode;
  bool get notifications => _notifications;
  bool get locationServices => _locationServices;
  String get vehicleType => _vehicleType;
  bool get isFourWheeler => _vehicleType == 'four_wheeler';

  void setDarkMode(bool v)         { _darkMode = v;         notifyListeners(); }
  void setNotifications(bool v)    { _notifications = v;    notifyListeners(); }
  void setLocationServices(bool v) { _locationServices = v; notifyListeners(); }
  void setVehicleType(String v)    { _vehicleType = v;      notifyListeners(); }
}