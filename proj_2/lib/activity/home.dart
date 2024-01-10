import 'package:flutter/material.dart';
import 'package:proj_2/activity/badminton.dart';

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chakravyuh Games'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            IconCard(icon: Icons.sports_cricket, label: 'Cricket'),
            //IconCard(icon: Icons.sports_chess, label: 'Chess'),
            IconCard(icon: Icons.sports, label: 'Athletics'),
            IconCard(icon: Icons.sports_basketball, label: 'Basketball'),
            IconCard(icon: Icons.games_rounded, label: 'Badminton'),
            IconCard(icon: Icons.sports_tennis, label: 'Tennis'),
          ],
        ),
      ),
    );
  }
}

class IconCard extends StatelessWidget {
  final IconData icon;
  final String label;

  const IconCard({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () {
          // Handle icon click (Navigate to sports events page, for example)
          // You can implement navigation logic here
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Icon(icon, size: 64),
              SizedBox(height: 8),
              Text(label),
            ],
          ),
        ),
      ),
    );
  }
}

