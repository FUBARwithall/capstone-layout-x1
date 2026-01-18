import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/api_service.dart';

class ChatbotPage extends StatefulWidget {
  const ChatbotPage({super.key});

  @override
  State<ChatbotPage> createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  List<Map<String, dynamic>> messages = [];
  List<dynamic> conversations = [];

  int? activeConversationId;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _initChat();
  }

  // ================= LOAD DATA =================

  Future<void> _loadConversations() async {
    final data = await ApiService.getConversations();

    setState(() {
      conversations = data;
    });
  }

  Future<void> _createNewConversation() async {
    try {
      final result = await ApiService.createConversation();
      
      final newId = result['conversation_id'];
      final newTitle = result['title'];

      setState(() {
        activeConversationId = newId;
        messages = [
          {
            'text':
                'Hai! Aku Glowie, asisten kesehatan kulitmu 😊\n\nAda yang bisa aku bantu tentang kulitmu?',
            'isUser': false,
          }
        ];
        
        conversations.insert(0, {
          'id': newId,
          'title': newTitle,
          'created_at': DateTime.now().toIso8601String(),
        });
      });

      _scrollToBottom();
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal membuat chat baru: $e')),
      );
    }
  }

  Future<void> _openConversation(int conversationId) async {
    final data = await ApiService.getMessages(conversationId);

    setState(() {
      activeConversationId = conversationId;
      messages = data
          .map<Map<String, dynamic>>(
            (m) => {
              'text': m['content'],
              'isUser': m['role'] == 'user',
            },
          )
          .toList();
    });

    _scrollToBottom();
  }

  // ================= CHAT =================

  Future<void> _initChat() async {
    await _loadConversations();

    if (conversations.isEmpty) {
      await _createNewConversation();
    } else {
      _openConversation(conversations.first['id']);
    }
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty || activeConversationId == null) return;

    setState(() {
      messages.add({'text': text, 'isUser': true});
      isLoading = true;
    });

    _controller.clear();
    _scrollToBottom();

    final response = await ApiService.sendChatMessage(
      conversationId: activeConversationId!,
      message: text,
    );

    setState(() {
      isLoading = false;
      messages.add({
        'text': response['reply'] ?? 'Maaf, terjadi kesalahan 😢',
        'isUser': false,
      });
    });

    _scrollToBottom();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E7),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0066CC),
        title: const Text('Glowie 💬'),
        foregroundColor: Colors.white,
      ),

      // ===== SIDEBAR CHAT =====
      drawer: Drawer(
        child: Column(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Color(0xFF0066CC),
              ),
              child: Center(
                child: Text(
                  '💬 Riwayat Chat',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: conversations.length,
                itemBuilder: (context, index) {
                  final c = conversations[index];
                  final isActive = c['id'] == activeConversationId;
                  
                  return ListTile(
                    selected: isActive,
                    selectedTileColor: const Color(0xFFE3F2FD),
                    leading: Icon(
                      Icons.chat_bubble_outline,
                      color: isActive ? const Color(0xFF0066CC) : Colors.grey,
                    ),
                    title: Text(
                      c['title'] ?? 'Chat',
                      style: TextStyle(
                        fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      _openConversation(c['id']);
                    },
                  );
                },
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.add_circle, color: Color(0xFF0066CC)),
              title: const Text(
                'Chat Baru',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onTap: () {
                Navigator.pop(context);
                _createNewConversation();
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),

      body: Column(
        children: [
          // ===== CHAT LIST =====
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: messages.length + (isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == messages.length && isLoading) {
                  return _typingIndicator();
                }

                final msg = messages[index];
                final isUser = msg['isUser'] as bool;

                return Align(
                  alignment:
                      isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: _chatBubble(msg['text'], isUser),
                );
              },
            ),
          ),

          // ===== INPUT =====
          _chatInput(),
        ],
      ),
    );
  }

  // ================= WIDGETS =================

  Widget _typingIndicator() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFE0B2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Color(0xFF0066CC),
            ),
          ),
          SizedBox(width: 8),
          Text('Mengetik...'),
        ],
      ),
    );
  }

  Widget _chatBubble(String text, bool isUser) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(12),
      constraints:
          BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
      decoration: BoxDecoration(
        color: isUser ? const Color(0xFFB3E5FC) : const Color(0xFFFFE0B2),
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(16),
          topRight: const Radius.circular(16),
          bottomLeft: isUser ? const Radius.circular(16) : Radius.zero,
          bottomRight: isUser ? Radius.zero : const Radius.circular(16),
        ),
      ),
      child: Text(text, style: const TextStyle(fontSize: 15)),
    );
  }

  Widget _chatInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: const BoxDecoration(color: Colors.white),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: KeyboardListener(
                focusNode: FocusNode(),
                onKeyEvent: (event) {
                  if (event is KeyDownEvent &&
                      event.logicalKey == LogicalKeyboardKey.enter &&
                      !HardwareKeyboard.instance.isShiftPressed) {
                    _sendMessage();
                  }
                },
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  enabled: !isLoading,
                  decoration: const InputDecoration(
                    hintText: 'Tanya tentang kulitmu...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                    ),
                  ),
                  maxLines: null,
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
            ),
            IconButton(
              onPressed: isLoading ? null : _sendMessage,
              icon: const Icon(Icons.send, color: Color(0xFF0066CC)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}