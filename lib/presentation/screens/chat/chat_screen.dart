import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/contact.dart';
import '../../../services/search/smart_search_service.dart';
import '../../widgets/contact/contact_card.dart';

// Model for chat messages
class ChatItem {
  final bool isUser;
  final String? text;
  final List<Contact>? contacts;

  ChatItem({required this.isUser, this.text, this.contacts});
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
      // Use the new Smart Search Service
      final searchService = Provider.of<SmartSearchService>(context, listen: false);
      final results = await searchService.search(text);

      setState(() {
        if (results.isEmpty) {
          _messages.add(ChatItem(
            isUser: false, 
            text: "I searched your network but couldn't find anyone matching that."
          ));
        } else {
          // Add a summary text + the contact cards
          _messages.add(ChatItem(
            isUser: false, 
            text: "Found ${results.length} matching contacts:",
            contacts: results,
          ));
        }
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
                  return _buildMessageItem(_messages[index]);
                },
              ),
        ),
        
        // Input Area
        if (_isThinking) 
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 2)),
                SizedBox(width: 8),
                Text("Analyzing network...", style: TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
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

  Widget _buildMessageItem(ChatItem item) {
    if (item.isUser) {
      // User Message (Right Bubble)
      return Align(
        alignment: Alignment.centerRight,
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(16).copyWith(bottomRight: Radius.zero),
          ),
          child: Text(
            item.text ?? "",
            style: const TextStyle(color: Colors.white),
          ),
        ),
      );
    } else {
      // AI Message (Left Bubble + Cards)
      return Align(
        alignment: Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          width: MediaQuery.of(context).size.width * 0.85,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // AI Text Response
              if (item.text != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(16).copyWith(bottomLeft: Radius.zero),
                  ),
                  child: Text(item.text!, style: const TextStyle(color: Colors.black87)),
                ),
              
              // Result Cards
              if (item.contacts != null && item.contacts!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Column(
                    children: item.contacts!.map((c) => 
                      ContactCard(
                        contact: c, 
                        onTap: () {
                          // TODO: Navigate to detail
                          debugPrint("Tapped ${c.name}");
                        },
                      )
                    ).toList(),
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
          Icon(Icons.auto_awesome, size: 48, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text("Chat with your Network", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            alignment: WrapAlignment.center,
            children: [
              _suggestionChip("Who did I meet in Denver?"),
              _suggestionChip("List investors I know"),
              _suggestionChip("Who works at Google?"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _suggestionChip(String label) {
    return ActionChip(
      label: Text(label),
      backgroundColor: Colors.white,
      side: BorderSide(color: Colors.grey.shade200),
      onPressed: () {
        _controller.text = label;
        _sendMessage();
      },
    );
  }
}