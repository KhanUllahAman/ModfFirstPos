import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Error404View extends StatelessWidget {
  const Error404View({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search_off_rounded,
                size: 100,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 30),
              Text(
                '404',
                style: TextStyle(
                  fontSize: 60,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Page Not Found',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 15),
              Text(
                'The resource you are looking for\nmight have been removed or is temporarily unavailable',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                onPressed: () => Get.back(),
                icon: const Icon(Icons.home),
                label: const Text('Go Home'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 15,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}