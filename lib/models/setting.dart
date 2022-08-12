import 'package:equatable/equatable.dart';

class Setting extends Equatable {
  String name;
  Object? value;

  Setting({/*required*/ required this.name, this.value});

  @override
  List<Object?> get props => [name, value];
}
