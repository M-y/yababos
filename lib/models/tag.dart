import 'dart:ui';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

class Tag extends Equatable {
  String name;
  Color color;

  Tag({
    @required this.name,
    this.color = const Color(0xFFFFFFFF),
  });

  @override
  List<Object> get props => [name, color];
}
