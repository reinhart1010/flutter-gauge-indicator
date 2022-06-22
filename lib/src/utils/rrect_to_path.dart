import 'package:flutter/material.dart';

Path rRectToPath(RRect rRect) {
  return Path()..addRRect(rRect);
}
