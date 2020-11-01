import 'dart:ui';
import 'package:flutter/foundation.dart';

class Tag {
  String name;
  Color color;

  Tag({
    @required this.name,
    this.color = const Color(0xFFFFFFFF),
  });
}
