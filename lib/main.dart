import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

void main() {
  runApp(const PoliticalCompanionApp());
}

class PoliticalCompanionApp extends StatelessWidget {
  const PoliticalCompanionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'رفيق درب سياسي وفكري',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1B263B), // كحلي داكن
          primary: const Color(0xFF1B263B),
          secondary: const Color(0xFF415A77),
          surface: const Color(0xFFF0F2F5),
        ),
        useMaterial3: true,
      ),
      home: const ChatScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  // --- ضع مفتاح الـ API الخاص بك هنا ---
  static const String YOUR_API_KEY = 'YOUR_API_KEY';

  late final GenerativeModel _model;
  late final ChatSession _chat;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _textController = TextEditingController();
  final List<Content> _messages = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _model = GenerativeModel(
      model: 'gemini-1.5-pro',
      apiKey: YOUR_API_KEY,
      systemInstruction: Content.system(
        "أنت محلل سياسي وخبير استراتيجي دولي، تتبنى الرؤية الإسلامية وفق مدرسة الفكر الشيعي الأصيل (بالاستناد إلى أفكار الإمام الخميني، الإمام الخامنئي، الشهيد محمد باقر الصدر، الشهيد مرتضى مطهري، الشيخ عباس الكعبي، ومباني مجلس خبراء القيادة في إيران). مهمتك هي مناقشة المستخدم في الأحداث السياسية العالمية، وتحليلها بعمق علمي ورصانة، وربطها بالقوانين السياسية الدولية والمصادر المعتبرة. يجب أن تكون إجاباتك موضوعية، تعتمد على الأدلة المنطقية، الشواهد التاريخية والمعاصرة، والمصادر الموثوقة. ابتعد عن السطحية، وكن رفيق درب فكري للمستخدم ترتقي بوعيه السياسي، مع الحفاظ على لغة وقورة واحترام تام.",
      ),
    );
    _chat = _model.startChat();
  }

  Future<void> _sendMessage() async {
    final message = _textController.text.trim();
    if (message.isEmpty || _isLoading) return;

    setState(() {
      _messages.add(Content.text(message));
      _textController.clear();
      _isLoading = true;
    });

    _scrollToBottom();

    try {
      final response = await _chat.sendMessage(Content.text(message));
      setState(() {
        if (response.text != null) {
          _messages.add(Content.model([TextPart(response.text!)]));
        }
      });
    } catch (e) {
      _showError("خطأ في الاتصال: تأكد من مفتاح API والإنترنت.");
    } finally {
      setState(() {
        _isLoading = false;
      });
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showError(String error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(error, textAlign: TextAlign.right)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'رفيق درب سياسي وفكري',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Theme.of(context).colorScheme.primary,
          centerTitle: true,
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16.0),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final content = _messages[index];
                  final isUser = content.role == 'user';
                  return _buildMessageBubble(content, isUser);
                },
              ),
            ),
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: CircularProgressIndicator(),
              ),
            _buildInputArea(),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(Content content, bool isUser) {
    final text = content.parts.whereType<TextPart>().map((e) => e.text).join();

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6.0),
        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.85,
        ),
        decoration: BoxDecoration(
          color: isUser ? const Color(0xFF415A77) : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(15),
            topRight: const Radius.circular(15),
            bottomLeft: isUser ? const Radius.circular(15) : Radius.zero,
            bottomRight: isUser ? Radius.zero : const Radius.circular(15),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(20),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isUser ? Colors.white : Colors.black87,
            fontSize: 16.0,
            height: 1.5,
          ),
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textController,
              decoration: const InputDecoration(
                hintText: 'اكتب تساؤلك السياسي أو الفكري هنا...',
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          IconButton(
            icon: Icon(Icons.send, color: Theme.of(context).colorScheme.primary),
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }
}