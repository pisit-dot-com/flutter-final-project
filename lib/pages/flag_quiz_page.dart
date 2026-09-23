import 'package:flutter/material.dart';
import '../models/country.dart';
import '../services/country_service.dart';

// มินิเกม: ดูธงแล้วทายชื่อประเทศ
class FlagQuizPage extends StatefulWidget {
  const FlagQuizPage({super.key});

  @override
  State<FlagQuizPage> createState() => _FlagQuizPageState();
}

class _FlagQuizPageState extends State<FlagQuizPage> {
  static const int totalQuestions = 10; // 1 รอบมี 10 ข้อ

  List<Country> allCountries = []; // ทุกประเทศจาก API
  List<Country> questions = [];    // 10 ประเทศที่สุ่มมาเป็นโจทย์
  int currentIndex = 0;            // ตอนนี้อยู่ข้อที่เท่าไหร่
  int score = 0;                   // คะแนน

  bool isLoading = true;
  String? errorMessage;

  final TextEditingController controller = TextEditingController();
  final FocusNode focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    loadCountries();
  }

  // ---------- โหลดข้อมูลจาก API ----------
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

  // ---------- เริ่มเกมใหม่ ----------
  void startNewGame() {
    // สุ่มลำดับประเทศ แล้วเอามา 10 ประเทศ
    final shuffled = List<Country>.from(allCountries)..shuffle();
    setState(() {
      questions = shuffled.take(totalQuestions).toList();
      currentIndex = 0;
      score = 0;
    });
  }

  // ---------- ตรวจคำตอบ ----------
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
    focusNode.requestFocus(); // ให้พิมพ์ต่อได้เลย
  }

  // ---------- ข้ามข้อนี้ ----------
  void skipQuestion() {
    showMessage('เฉลย: ${questions[currentIndex].name}', Colors.orange);
    controller.clear();
    goToNextQuestion();
  }

  // ---------- ไปข้อถัดไป ----------
  void goToNextQuestion() {
    if (currentIndex + 1 >= questions.length) {
      showResultDialog(); // ครบ 10 ข้อแล้ว
    } else {
      setState(() {
        currentIndex++;
      });
    }
  }

  // ---------- แถบข้อความด้านล่างจอ ----------
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

  // ---------- หน้าต่างสรุปคะแนน ----------
  void showResultDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // ต้องกดปุ่มเท่านั้น
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
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext); // ปิดหน้าต่าง
              Navigator.pop(context);       // กลับหน้าเมนู
            },
            child: const Text('กลับเมนู'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              startNewGame();
            },
            child: const Text('เล่นอีกครั้ง'),
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
      body: buildBody(),
    );
  }

  Widget buildBody() {
    // กำลังโหลด
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // โหลดไม่สำเร็จ
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

    // พร้อมเล่น
    final country = questions[currentIndex];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Center(
        // จำกัดความกว้างไม่เกิน 500 จะได้ไม่ยืดเกินไปบนจอคอม
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Column(
            children: [
              // ข้อที่ / คะแนน
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

              // รูปธง (โหลดจากอินเทอร์เน็ต)
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