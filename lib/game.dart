import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final int totalRound = 5;

  int currentRound = 0;
  int score = 0;
  bool isMemorizing = true;

  int memorizeIndex = 0;
  int timeLeft = 30;
  int memorizeTimeLeft = 3;

  Timer? timer;

  List<String> images = [
    'assets/earth.png',
    'assets/earth_2.png',
    'assets/earth_3.png',
    'assets/earth_4.png',
  ];

  late List<String> sequence;
  late List<String> options;
  late String correctAnswer;

  @override
  void initState() {
    super.initState();
    startGame();
  }

  void startGame() {
    sequence = List.generate(
      totalRound,
      (_) => images[Random().nextInt(images.length)],
    );

    startMemorize();
  }

  void startMemorize() {
    isMemorizing = true;
    memorizeIndex = 0;
    memorizeTimeLeft = 3;

    timer?.cancel();

    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      setState(() {
        memorizeTimeLeft--;
      });

      if (memorizeTimeLeft == 0) {
        memorizeIndex++;

        if (memorizeIndex >= sequence.length) {
          t.cancel();
          startQuiz();
        } else {
          memorizeTimeLeft = 3; // reset untuk gambar berikutnya
        }
      }
    });
  }

  void startQuiz() {
    isMemorizing = false;
    currentRound = 0;
    loadQuestion();
  }

  void loadQuestion() {
    if (currentRound >= totalRound) {
      endGame();
      return;
    }

    correctAnswer = sequence[currentRound];

    options = List.from(images)..shuffle();

    timeLeft = 30;

    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      setState(() {
        timeLeft--;
      });

      if (timeLeft <= 0) {
        t.cancel();
        nextQuestion();
      }
    });

    setState(() {});
  }

  void selectAnswer(String selected) {
    timer?.cancel();

    if (selected == correctAnswer) {
      score += 1;
    }

    nextQuestion();
  }

  void nextQuestion() {
    currentRound++;
    loadQuestion();
  }

  void endGame() async {
    timer?.cancel();

    final prefs = await SharedPreferences.getInstance();

    int highScore = prefs.getInt('highscore') ?? 0;

    if (score > highScore) {
      await prefs.setInt('highscore', score);
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Game Finished"),
        content: Text(
          "Score: $score\nHigh Score: ${prefs.getInt('highscore')}",
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Game"),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Center(child: isMemorizing ? buildMemorize() : buildQuiz()),
    );
  }

  Widget buildMemorize() {
    if (memorizeIndex >= sequence.length) {
      return const Text("Loading...");
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("Gambar ${memorizeIndex + 1}/${sequence.length}"),
        const SizedBox(height: 10),

        Text(
          "$memorizeTimeLeft",
          style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 20),

        Image.asset(sequence[memorizeIndex], height: 150),
      ],
    );
  }

  Widget buildQuiz() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("Round ${currentRound + 1}/$totalRound"),
        const SizedBox(height: 10),
        Text("Time: $timeLeft"),
        const SizedBox(height: 20),

        GridView.builder(
          shrinkWrap: true,
          itemCount: options.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
          ),
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () => selectAnswer(options[index]),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Image.asset(options[index]),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
