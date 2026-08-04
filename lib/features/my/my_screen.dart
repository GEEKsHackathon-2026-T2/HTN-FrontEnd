import 'package:flutter/material.dart';
import '../../shared/widgets/placeholder_screen.dart';

class MyScreen extends StatelessWidget {
  const MyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(label: '마이 페이지');
  }
}
