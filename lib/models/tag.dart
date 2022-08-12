import 'dart:ui';
import 'package:equatable/equatable.dart';

class Tag extends Equatable {
  String name;
  Color color;

  Tag({
    /*required*/ required this.name,
    this.color = const Color(0xFFFFFFFF),
  });

  @override
  List<Object> get props => [name, color.value];
}
