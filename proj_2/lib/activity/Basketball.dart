import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(BasketballMatchApp());
}

class BasketballMatchApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Basketball Tournament App',
      home: BasketballMatchScreen(),
    );
  }
}

class BasketballMatchScreen extends StatefulWidget {
  @override
  _BasketballMatchScreenState createState() => _BasketballMatchScreenState();
}

class _BasketballMatchScreenState extends State<BasketballMatchScreen> {
  String teamAName = '';
  String teamBName = '';
  int teamAScore = 0;
  int teamBScore = 0;
  int matchDurationInSeconds = 600; // Default match time: 10 minutes
  int initialMatchDuration = 600;
  bool isTimerRunning = false;
  late Timer _timer;

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (Timer timer) {
      setState(() {
        if (matchDurationInSeconds > 0) {
          matchDurationInSeconds--;
        } else {
          timer.cancel();
          _showGameResults();
        }
      });
    });
  }

  void _scorePoints(int points, String team) {
    setState(() {
      if (team == 'A') {
        teamAScore += points;
      } else if (team == 'B') {
        teamBScore += points;
      }
    });

    if (!isTimerRunning) {
      _startTimer();
      isTimerRunning = true;
    }
  }

  void _pauseTimer() {
    if (_timer.isActive) {
      _timer.cancel();
      setState(() {
        isTimerRunning = false;
      });
    }
  }

  void _resetScore() {
    setState(() {
      teamAScore = 0;
      teamBScore = 0;
      matchDurationInSeconds = initialMatchDuration;
      isTimerRunning = false;
      _timer.cancel();
    });
  }

  Future<void> _showGameResults() async {
    final CollectionReference matchResults = FirebaseFirestore.instance.collection('match_results');

    await matchResults.add({
      'teamA': {'name': teamAName, 'score': teamAScore},
      'teamB': {'name': teamBName, 'score': teamBScore},
      'timestamp': FieldValue.serverTimestamp(),
    });

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Game Over'),
          content: Text('Final Scores:\n$teamAName: $teamAScore\n$teamBName: $teamBScore'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _resetScore();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Basketball Tournament App'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              onChanged: (value) => teamAName = value,
              decoration: InputDecoration(labelText: 'Enter Team A Name'),
            ),
            TextField(
              onChanged: (value) => teamBName = value,
              decoration: InputDecoration(labelText: 'Enter Team B Name'),
            ),
            SizedBox(height: 20),
            TextField(
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  initialMatchDuration = int.tryParse(value) ?? initialMatchDuration;
                  matchDurationInSeconds = initialMatchDuration;
                });
              },
              decoration: InputDecoration(labelText: 'Enter Match Time (in seconds)'),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildTeamScore(teamAName, teamAScore),
                _buildTeamScore(teamBName, teamBScore),
              ],
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => _scorePoints(1, 'A'),
                  child: Text('$teamAName: 1 P'),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () => _scorePoints(2, 'A'),
                  child: Text('$teamAName: 2 P'),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () => _scorePoints(3, 'A'),
                  child: Text('$teamAName: 3 P'),
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => _scorePoints(1, 'B'),
                  child: Text('$teamBName: 1 P'),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () => _scorePoints(2, 'B'),
                  child: Text('$teamBName: 2 P'),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () => _scorePoints(3, 'B'),
                  child: Text('$teamBName: 3 P'),
                ),
              ],
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _pauseTimer,
                  child: Text(isTimerRunning ? 'Pause Timer' : 'Resume Timer'),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _resetScore,
                  child: Text('Reset Score'),
                ),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _startTimer,
              child: Text('Start Scoring'),
            ),
            SizedBox(height: 20),
            Text('Time Remaining: ${_formatTime(matchDurationInSeconds)}'),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamScore(String teamName, int score) {
    return Column(
      children: [
        Text(
          '$teamName Score: $score',
          style: TextStyle(fontSize: 20),
        ),
        if (score >= 100) Text('$teamName wins!', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
}
