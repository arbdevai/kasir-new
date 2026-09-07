import 'package:flutter/material.dart';

class ProductsShellScreen extends StatelessWidget {
  const ProductsShellScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Produk & Stok')),
      body: const Center(
        child: Text('Katalog produk dan stok (Shell)'),
      ),
    );
  }
}
