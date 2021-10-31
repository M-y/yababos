import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

class Setting extends Equatable {
  String name;
  Object value;

  Setting({@required this.name, this.value});

  @override
  List<Object> get props => [name, value];
}
