import 'package:flutter/foundation.dart';

class Wallet {
  int id;
  String name;
  String curreny;
  double amount; // starting amount

  Wallet({@required this.id, this.name, this.curreny, this.amount = 0});
}
