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
      // Use the Smart Search Service (Router Agent)
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
    return Scaffold(
      backgroundColor: Colors.black, // Friend's Dark Background
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          'AI Assistant',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
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
          
          // Thinking Indicator
          if (_isThinking) 
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.blue)),
                  const SizedBox(width: 12),
                  Text("Analyzing network...", style: TextStyle(color: Colors.grey[500], fontSize: 14)),
                ],
              ),
            ),

          // Input Area (Friend's Design)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              border: Border(
                top: BorderSide(color: Colors.grey[800]!, width: 0.5),
              ),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[850],
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: TextField(
                        controller: _controller,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Ask about your contacts...',
                          hintStyle: TextStyle(color: Colors.grey[600]),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                        ),
                        maxLines: null,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: const BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_upward, color: Colors.white),
                      onPressed: _isThinking ? null : _sendMessage,
                    ),
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
      // User Message (Right Bubble - Blue)
      return Align(
        alignment: Alignment.centerRight,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75,
          ),
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(20).copyWith(bottomRight: const Radius.circular(4)),
          ),
          child: Text(
            item.text ?? "",
            style: const TextStyle(color: Colors.white, fontSize: 15),
          ),
        ),
      );
    } else {
      // AI Message (Left Bubble - Grey + Cards)
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
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[900], // Friend's Dark Grey
                    borderRadius: BorderRadius.circular(20).copyWith(bottomLeft: const Radius.circular(4)),
                  ),
                  child: Text(item.text!, style: const TextStyle(color: Colors.white, fontSize: 15)),
                ),
              
              // Result Cards
              if (item.contacts != null && item.contacts!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: Column(
                    children: item.contacts!.map((c) => 
                      // We wrap the ContactCard to fit the dark theme context better
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: ContactCard(
                          contact: c, 
                          onTap: () {
                            // TODO: Navigate to detail
                          },
                        ),
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
          Icon(
            Icons.auto_awesome,
            size: 80,
            color: Colors.grey[700],
          ),
          const SizedBox(height: 16),
          Text(
            'Ask me about your contacts',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'I can help you search, filter, and manage your professional connections',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(height: 32),
          // Suggestion Chips (Styled for Dark Mode)
          Wrap(
            spacing: 8,
            runSpacing: 8,
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
      label: Text(label, style: const TextStyle(color: Colors.white)),
      backgroundColor: Colors.grey[900],
      side: BorderSide(color: Colors.grey[800]!),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      onPressed: () {
        _controller.text = label;
        _sendMessage();
      },
    );
  }
}