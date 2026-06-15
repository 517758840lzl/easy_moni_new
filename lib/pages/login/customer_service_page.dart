import 'package:flutter/material.dart';

/// 客服留白页。
class CustomerServicePage extends StatelessWidget {
  const CustomerServicePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('客服')),
      backgroundColor: Colors.white,
      body: SafeArea(child: SizedBox.expand()),
    );
  }
}
