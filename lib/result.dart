import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'highscore.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({super.key});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  int score = 0;
  int highScore = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadResult();
  }

  Future<void> loadResult() async {
    final prefs = await SharedPreferences.getInstance();

    score = prefs.getInt('last_score') ?? 0;
    highScore = prefs.getInt('highscore') ?? 0;

    setState(() {
      isLoading = false;
    });
  }

  String getTitle() {
    if (score == 5) return "Maestro dell'Indovinello (Master of Riddles)";
    if (score == 4) return "Esperto dell'Indovinello (Expert of Riddles)";
    if (score == 3) return " Abile Indovinatore (Skillful Guesser)";
    if (score == 2) return "Principiante dell'Indovinello (Riddle Beginner)";
    if (score == 1) return "Neofita dell'Indovinello (Riddle Novice)";
    return "Sfortunato Indovinatore (Unlucky Guesser)";
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Hasil Permainan"),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              const SizedBox(height: 20),

              Text(
                getTitle(),
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              const Text("Score Kamu:", style: TextStyle(fontSize: 18)),

              Text(
                "$score",
                style: const TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                "High Score: $highScore",
                style: const TextStyle(fontSize: 18),
              ),

              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text("Play Again"),
                ),
              ),

              const SizedBox(height: 10),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("Main Menu"),
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const HighScoreScreen(),
                      ),
                    );
                  },
                  child: const Text("Highscore"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
