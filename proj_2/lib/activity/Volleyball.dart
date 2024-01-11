import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Firebase.apps.length == 0) {
    await Firebase.initializeApp();
  }

  runApp(VolleyballMatchApp());
}

class VolleyballMatchApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Volleyball Tournament App',
      home: VolleyballMatchScreen(),
    );
  }
}

class VolleyballMatchScreen extends StatefulWidget {
  @override
  _VolleyballMatchScreenState createState() => _VolleyballMatchScreenState();
}

class _VolleyballMatchScreenState extends State<VolleyballMatchScreen> {
  String teamAName = '';
  String teamBName = '';
  int teamASetsWon = 0;
  int teamBSetsWon = 0;
  int teamAPoints = 0;
  int teamBPoints = 0;
  int setPoints = 15; // Default set points
  int numberOfSets = 3; // Default number of sets
  int currentSet = 1;
  List<Map<String, int>> setPointsList = [];
  List<Map<String, int>> currentSetPointsList = [];
  bool isMatchOver = false;

  void _scorePoint(String team) {
    setState(() {
      if (team == 'A') {
        teamAPoints++;
      } else if (team == 'B') {
        teamBPoints++;
      }

      if (teamAPoints >= setPoints || teamBPoints >= setPoints) {
        _endSet();
      }
    });
  }

  void _endSet() {
    String winner = (teamAPoints > teamBPoints) ? teamAName : teamBName;

    currentSetPointsList.add({'A': teamAPoints, 'B': teamBPoints});
    setPointsList.add({'A': teamASetsWon, 'B': teamBSetsWon});

    if (currentSet < numberOfSets) {
      setState(() {
        currentSet++;
        teamAPoints = 0;
        teamBPoints = 0;
        currentSetPointsList = [];
      });
    } else {
      _showMatchResults();
    }
  }

  void _showMatchResults() async {
    final CollectionReference matchResults = FirebaseFirestore.instance.collection('volleyball_match_results');

    await matchResults.add({
      'teamA': {'name': teamAName, 'sets_won': teamASetsWon},
      'teamB': {'name': teamBName, 'sets_won': teamBSetsWon},
      'timestamp': FieldValue.serverTimestamp(),
    });

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Match Over'),
          content: Column(
            children: [
              Text('Final Scores:\n$teamAName: $teamASetsWon sets\n$teamBName: $teamBSetsWon sets'),
              SizedBox(height: 20),
              _buildPointsTable(setPointsList),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _resetMatch();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _resetMatch() {
    setState(() {
      teamASetsWon = 0;
      teamBSetsWon = 0;
      teamAPoints = 0;
      teamBPoints = 0;
      currentSet = 1;
      setPointsList = [];
      currentSetPointsList = [];
      isMatchOver = false;
    });
  }

  Widget _buildPointsTable(List<Map<String, int>> pointsList) {
    return Table(
      defaultColumnWidth: IntrinsicColumnWidth(),
      children: [
        TableRow(
          children: [
            Center(child: Text('Set')),
            Center(child: Text('$teamAName Points')),
            Center(child: Text('$teamBName Points')),
          ],
        ),
        for (int i = 0; i < pointsList.length; i++)
          TableRow(
            children: [
              Center(child: Text('Set ${i + 1}')),
              Center(child: Text('${pointsList[i]['A']}')),
              Center(child: Text('${pointsList[i]['B']}')),
            ],
          ),
        TableRow(
          children: [
            Center(child: Text('Current Set')),
            Center(child: Text('$teamAName Points')),
            Center(child: Text('$teamBName Points')),
          ],
        ),
        if (currentSetPointsList.isNotEmpty)
          TableRow(
            children: [
              Center(child: Text('Set $currentSet')),
              Center(child: Text('${currentSetPointsList.last['A']}')),
              Center(child: Text('${currentSetPointsList.last['B']}')),
            ],
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Volleyball Tournament App'),
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
                  numberOfSets = int.tryParse(value) ?? numberOfSets;
                });
              },
              decoration: InputDecoration(labelText: 'Enter Number of Sets'),
            ),
            SizedBox(height: 20),
            TextField(
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  setPoints = int.tryParse(value) ?? setPoints;
                });
              },
              decoration: InputDecoration(labelText: 'Enter Set Points (15 or 25)'),
            ),
            SizedBox(height: 20),
            Text('Set: $currentSet / $numberOfSets'),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildTeamScore(teamAName, teamASetsWon),
                _buildTeamScore(teamBName, teamBSetsWon),
              ],
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => _scorePoint('A'),
                  child: Text('$teamAName: Score Point'),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () => _scorePoint('B'),
                  child: Text('$teamBName: Score Point'),
                ),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _resetMatch();
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Match Started'),
                      content: Text('The match has started. Good luck to both teams!'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text('OK'),
                        ),
                      ],
                    );
                  },
                );
              },
              child: Text('Start Match'),
            ),
            SizedBox(height: 20),
            _buildPointsTable(currentSetPointsList),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamScore(String teamName, int setsWon) {
    return Column(
      children: [
        Text(
          '$teamName Sets Won: $setsWon',
          style: TextStyle(fontSize: 20),
        ),
        if (setsWon >= (numberOfSets / 2).ceil()) Text('$teamName wins the match!', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
