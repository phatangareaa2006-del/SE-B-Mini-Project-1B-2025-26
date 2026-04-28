import 'package:flutter/material.dart';
import '../models/request_model.dart';
import '../utils/constants.dart';

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items    => List.unmodifiable(_items);
  int            get count    => _items.fold(0, (s,i) => s + i.quantity);
  bool           get isEmpty  => _items.isEmpty;
  double get subtotal       => _items.fold(0.0, (s,i) => s + i.totalPrice);
  double get deliveryCharge => subtotal >= AppConstants.freeDeliveryThreshold
      ? 0 : AppConstants.deliveryCharge;
  double get grandTotal     => subtotal + deliveryCharge;

  void addItem(CartItem item) {
    final i = _items.indexWhere((x) => x.id == item.id);
    if (i != -1) {
      _items[i] = _items[i].copyWith(quantity: _items[i].quantity + 1);
    } else {
      _items.add(item.copyWith(quantity: 1));
    }
    notifyListeners();
  }

  void updateQty(String id, int qty) {
    if (qty <= 0) { removeItem(id); return; }
    final i = _items.indexWhere((x) => x.id == id);
    if (i != -1) { _items[i] = _items[i].copyWith(quantity: qty); notifyListeners(); }
  }

  void removeItem(String id) {
    _items.removeWhere((x) => x.id == id); notifyListeners();
  }

  void clear() { _items.clear(); notifyListeners(); }
}