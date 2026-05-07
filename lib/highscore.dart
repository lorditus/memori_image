import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HighScoreScreen extends StatefulWidget {
  const HighScoreScreen({super.key});

  @override
  State<HighScoreScreen> createState() => _HighScoreScreenState();
}

class _HighScoreScreenState extends State<HighScoreScreen> {
  List<Map<String, dynamic>> top3 = [];

  @override
  void initState() {
    super.initState();
    loadScore();
  }

  void loadScore() async {
    final prefs = await SharedPreferences.getInstance();

    List<String> data = prefs.getStringList('leaderboard') ?? [];

    setState(() {
      top3 = data.map((item) {
        final split = item.split('|');
        return {'name': split[0], 'score': int.parse(split[1]), 'time_score': int.parse(split[2])};
      }).toList();
    });
  }

  Widget buildItem(int index, String name, int score, int timeScore) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Text(
        "${index + 1}. $name - $score - $timeScore",
        style: const TextStyle(fontSize: 20),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("High Score"),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: top3.isEmpty
            ? const Text("Belum ada skor")
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.emoji_events, size: 100, color: Colors.amber),

                  const Text(
                    "Top 3 Player",
                    style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 20),

                  ...top3.asMap().entries.map((entry) {
                    int index = entry.key;
                    var data = entry.value;

                    return buildItem(index, data['name'], data['score'], data['time_score']);
                  }).toList(),
                ],
              ),
      ),
    );
  }
}
