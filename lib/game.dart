import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'result.dart';

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

  List<List<String>> categories = [
    [
      'assets/earth.png',
      'assets/earth_2.png',
      'assets/earth_3.png',
      'assets/earth_4.png',
    ],
    [
      'assets/car.png',
      'assets/car_2.png',
      'assets/car_3.png',
      'assets/car_4.png',
    ],
    [
      'assets/bottle.png',
      'assets/bottle_2.png',
      'assets/bottle_3.png',
      'assets/bottle_4.png',
    ],
    [
      'assets/rocket.png',
      'assets/rocket_2.png',
      'assets/rocket_3.png',
      'assets/rocket_4.png',
    ],
    [
      'assets/person.png',
      'assets/person_2.png',
      'assets/person_3.png',
      'assets/person_4.png',
    ],
  ];

  late List<Map<String, dynamic>> sequence;
  late List<String> options;
  late String correctAnswer;
  List<String> leaderboard = [];

  @override
  void initState() {
    super.initState();
    startGame();
  }

  void startGame() {
    final random = Random();

    sequence = List.generate(totalRound, (_) {
      int categoryIndex = random.nextInt(categories.length);

      List<String> selectedCategory = categories[categoryIndex];

      String answer = selectedCategory[random.nextInt(selectedCategory.length)];

      return {"categoryIndex": categoryIndex, "answer": answer};
    });

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
          memorizeTimeLeft = 3;
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

    var current = sequence[currentRound];

    correctAnswer = current["answer"];

    List<String> categoryImages = categories[current["categoryIndex"]];

    options = List.from(categoryImages)..shuffle();

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

    String username = prefs.getString('username') ?? "Guest";

    List<String> leaderboard = prefs.getStringList('leaderboard') ?? [];

    leaderboard.add("$username|$score");

    leaderboard.sort((a, b) {
      int scoreA = int.parse(a.split('|')[1]);
      int scoreB = int.parse(b.split('|')[1]);
      return scoreB.compareTo(scoreA);
    });

    if (leaderboard.length > 3) {
      leaderboard = leaderboard.sublist(0, 3);
    }

    await prefs.setStringList('leaderboard', leaderboard);
    await prefs.setInt('last_score', score);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const ResultScreen()),
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

        Image.asset(sequence[memorizeIndex]["answer"], height: 150),
      ],
    );
  }

  Widget buildQuiz() {
    return Column(
      children: [
        const SizedBox(height: 20),

        Text("Round ${currentRound + 1}/$totalRound"),
        const SizedBox(height: 10),
        Text("Time: $timeLeft"),
        const SizedBox(height: 20),

        Expanded(
          child: GridView.builder(
            itemCount: options.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1,
            ),
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () => selectAnswer(options[index]),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Image.asset(options[index], fit: BoxFit.contain),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
