import 'package:flutter/material.dart';
import '../models/country.dart';
import '../services/country_service.dart';
import '../services/score_service.dart';
import 'scores_page.dart';

class FlagQuizPage extends StatefulWidget {
  const FlagQuizPage({super.key});

  @override
  State<FlagQuizPage> createState() => _FlagQuizPageState();
}

class _FlagQuizPageState extends State<FlagQuizPage> {
  static const int totalQuestions = 10;

  List<Country> allCountries = [];
  List<Country> questions = [];
  int currentIndex = 0;
  int score = 0;

  bool isLoading = true;
  String? errorMessage;

  final TextEditingController controller = TextEditingController();
  final FocusNode focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    loadCountries();
  }

  Future<void> loadCountries() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      allCountries = await CountryService().fetchCountries();
      startNewGame();
    } catch (e) {
      errorMessage = 'โหลดข้อมูลไม่สำเร็จ กรุณาเช็คอินเทอร์เน็ต';
    }

    setState(() {
      isLoading = false;
    });
  }

  void startNewGame() {
    final shuffled = List<Country>.from(allCountries)..shuffle();
    setState(() {
      questions = shuffled.take(totalQuestions).toList();
      currentIndex = 0;
      score = 0;
    });
  }

  void checkAnswer(String value) {
    final answer = value.trim().toLowerCase();
    if (answer.isEmpty) return;

    final correct = questions[currentIndex].name.toLowerCase();

    if (answer == correct) {
      score++;
      showMessage('ถูกต้อง! 🎉', Colors.green);
      goToNextQuestion();
    } else {
      showMessage('ยังไม่ถูก ลองใหม่อีกครั้ง', Colors.red);
    }

    controller.clear();
    focusNode.requestFocus();
  }

  void skipQuestion() {
    showMessage('เฉลย: ${questions[currentIndex].name}', Colors.orange);
    controller.clear();
    goToNextQuestion();
  }

  // ---------- ไปข้อถัดไป ----------
  void goToNextQuestion() {
    if (currentIndex + 1 >= questions.length) {
      showResultDialog();
    } else {
      setState(() {
        currentIndex++;
      });
    }
  }

  void showMessage(String text, Color color) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        backgroundColor: color,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  Future<void> saveScore(String name) async {
    if (name.trim().isEmpty) name = 'ไม่ระบุชื่อ';

    await ScoreService().addScore(name.trim(), score); // C

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const ScoresPage()),
    );
  }

  void showResultDialog() {
    final nameController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text('จบเกม!', textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.emoji_events, color: Colors.amber, size: 70),
            const SizedBox(height: 10),
            Text(
              'คุณได้ $score / $totalQuestions คะแนน',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'ชื่อของคุณ',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              startNewGame();
            },
            child: const Text('เล่นอีกครั้ง'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              saveScore(nameController.text);
            },
            child: const Text('บันทึกคะแนน'),
          ),
        ],
      ),
    );
  }

  // ---------- หน้าจอ ----------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xff4f6fb0),
        foregroundColor: Colors.white,
        title: const Text('ทายธงชาติ'),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xffa8c8ff),
              Color(0xffeef3f8),
            ],
          ),
        ),
        child: buildBody(),
      ),
    );
  }

  Widget buildBody() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(errorMessage!),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: loadCountries,
              child: const Text('ลองใหม่'),
            ),
          ],
        ),
      );
    }

    final country = questions[currentIndex];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'ข้อ ${currentIndex + 1} / $totalQuestions',
                    style: const TextStyle(fontSize: 18),
                  ),
                  Text(
                    'คะแนน: $score',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Image.network(
                    country.flagUrl,
                    height: 200,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stack) =>
                        const Icon(Icons.flag, size: 100),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // ช่องพิมพ์คำตอบ
              TextField(
                controller: controller,
                focusNode: focusNode,
                autofocus: true,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                  hintText: 'ธงนี้คือประเทศอะไร? (ภาษาอังกฤษ)',
                ),
                onSubmitted: checkAnswer,
              ),
              const SizedBox(height: 12),

              // ปุ่ม ข้าม / ตอบ
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: skipQuestion,
                      child: const Text('ข้าม'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => checkAnswer(controller.text),
                      child: const Text('ตอบ'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}