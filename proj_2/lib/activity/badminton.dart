import 'package:flutter/material.dart';

class BadmintonGame {
  int player1Score = 0;
  int player2Score = 0;
  int setsPlayed = 0;

  void scorePointForPlayer1() {
    player1Score++;
    checkForSetWinner();
  }

  void scorePointForPlayer2() {
    player2Score++;
    checkForSetWinner();
  }

  void checkForSetWinner() {
    if ((player1Score >= 21 || player2Score >= 21) && (player1Score - player2Score).abs() >= 2) {
      setsPlayed++;
      print('Set $setsPlayed won by ${player1Score > player2Score ? 'Player 1' : 'Player 2'}');
      player1Score = 0;
      player2Score = 0;
    }

    if (setsPlayed == 3) {
      print('Game Over. Player ${player1Score > player2Score ? '1' : '2'} wins!');
    }
  }

  void displayScore() {
    print('Set $setsPlayed | Player 1: $player1Score | Player 2: $player2Score');
  }
}

void main() {
  BadmintonGame game = BadmintonGame();

  // Simulating a game where Player 1 wins the first set 21-18, Player 2 wins the second set 21-15,
  // and Player 1 wins the third set 21-19.
  for (int i = 0; i < 18; i++) {
    game.scorePointForPlayer1();
  }

  for (int i = 0; i < 21; i++) {
    game.scorePointForPlayer2();
  }

  for (int i = 0; i < 19; i++) {
    game.scorePointForPlayer1();
  }

  // Displaying the final score
  game.displayScore();
}


class Badminton extends StatefulWidget {
  const Badminton({super.key});

  @override
  State<Badminton> createState() => _BadmintonState();
}

class _BadmintonState extends State<Badminton> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
