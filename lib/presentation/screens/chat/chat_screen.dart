import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/contact.dart';
import '../../../services/search/vector_search_service.dart'; // Use updated service
import '../../widgets/contact/contact_card.dart';

// Chat Item Model
class ChatItem {
  final bool isUser;
  final String? text;
  final List<Contact>? contacts;
  final bool isRAG; // Flag to show special styling

  ChatItem({
    required this.isUser, 
    this.text, 
    this.contacts,
    this.isRAG = false,
  });
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<ChatItem> _messages = [];
  bool _isThinking = false;

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(ChatItem(isUser: true, text: text));
      _isThinking = true;
      _controller.clear();
    });

    try {
      final searchService = Provider.of<VectorSearchService>(context, listen: false);
      
      // --- USE RAG ---
      final ragResponse = await searchService.queryWithRAG(text);

      setState(() {
        _messages.add(ChatItem(
          isUser: false, 
          text: ragResponse.narrative, // The AI's written answer
          contacts: ragResponse.sources, // The source cards
          isRAG: true,
        ));
      });
    } catch (e) {
      setState(() {
        _messages.add(ChatItem(isUser: false, text: "Error: $e"));
      });
    } finally {
      setState(() => _isThinking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text('AI Assistant', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty 
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) => _buildMessageItem(_messages[index]),
                ),
          ),
          
          if (_isThinking) 
            const Padding(
              padding: EdgeInsets.all(12),
              child: LinearProgressIndicator(color: Colors.blue, backgroundColor: Colors.grey),
            ),

          // Input Area
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              border: Border(top: BorderSide(color: Colors.grey[800]!, width: 0.5)),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Ask complex questions...',
                        hintStyle: TextStyle(color: Colors.grey[600]),
                        border: InputBorder.none,
                        filled: true,
                        fillColor: Colors.grey[850],
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.send, color: Colors.blue),
                    onPressed: _isThinking ? null : _sendMessage,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageItem(ChatItem item) {
    if (item.isUser) {
      return Align(
        alignment: Alignment.centerRight,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.circular(20).copyWith(bottomRight: Radius.zero)),
          child: Text(item.text ?? "", style: const TextStyle(color: Colors.white)),
        ),
      );
    } else {
      return Align(
        alignment: Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          width: MediaQuery.of(context).size.width * 0.9,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // The AI Narrative Bubble
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(20).copyWith(bottomLeft: Radius.zero),
                ),
                child: Text(item.text ?? "", style: const TextStyle(color: Colors.white, height: 1.4)),
              ),
              
              // The "Sources" (Contact Cards)
              if (item.contacts != null && item.contacts!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 12.0, left: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Sources:", style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      ...item.contacts!.map((c) => Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: ContactCard(contact: c, onTap: () {}),
                      )),
                    ],
                  ),
                ),
            ],
          ),
        ),
      );
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.auto_awesome, size: 64, color: Colors.grey[800]),
          const SizedBox(height: 16),
          Text("AI Knowledge Base", style: TextStyle(color: Colors.grey[500], fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text("Ask me anything about your network.", style: TextStyle(color: Colors.grey[600])),
        ],
      ),
    );
  }
}