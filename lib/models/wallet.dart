import 'package:equatable/equatable.dart';

class Wallet extends Equatable {
  int id;
  String? name;
  String? curreny;
  double? amount; // starting amount

  Wallet({/*required*/ required this.id, this.name, this.curreny, this.amount = 0});

  @override
  List<Object?> get props => [id, name, curreny, amount];
}
