import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../services/search/vector_search_service.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = []; // {role: "user"|"ai", text: "..."}
  bool _isThinking = false;

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({"role": "user", "text": text});
      _isThinking = true;
      _controller.clear();
    });

    try {
      final searchService = Provider.of<VectorSearchService>(context, listen: false);
      // This performs the RAG lookup
      final response = await searchService.askYourNetwork(text);

      setState(() {
        _messages.add({"role": "ai", "text": response});
      });
    } catch (e) {
      setState(() {
        _messages.add({"role": "ai", "text": "I had trouble accessing your network memory. Error: $e"});
      });
    } finally {
      setState(() => _isThinking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Chat History
        Expanded(
          child: _messages.isEmpty 
            ? _buildEmptyState()
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final msg = _messages[index];
                  final isUser = msg['role'] == 'user';
                  return Align(
                    alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
                      decoration: BoxDecoration(
                        color: isUser ? Colors.black : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        msg['text']!,
                        style: TextStyle(color: isUser ? Colors.white : Colors.black87),
                      ),
                    ),
                  );
                },
              ),
        ),
        
        // Input Area
        if (_isThinking) 
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text("Thinking...", style: TextStyle(color: Colors.grey, fontSize: 12)),
          ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: Colors.grey.shade200)),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: "Ask about your network...",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  ),
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: _isThinking ? null : _sendMessage,
                icon: const Icon(Icons.send_rounded),
                color: Colors.black,
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.auto_awesome, size: 48, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text("Chat with your Network", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey.shade700)),
          const SizedBox(height: 8),
          const Text("Try asking:", style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 16),
          _suggestionChip("Who did I meet in Denver?"),
          _suggestionChip("Who knows about VCs?"),
          _suggestionChip("Last person I met?"),
        ],
      ),
    );
  }

  Widget _suggestionChip(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: ActionChip(
        label: Text(label),
        backgroundColor: Colors.white,
        side: BorderSide(color: Colors.grey.shade200),
        onPressed: () {
          _controller.text = label;
          _sendMessage();
        },
      ),
    );
  }
}