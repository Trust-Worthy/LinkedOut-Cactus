import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/contact.dart';
import '../../../services/search/advanced_search_service.dart'; // Use Advanced Service
import '../../widgets/contact/contact_card.dart';

// Updated Model for chat messages
class ChatItem {
  final bool isUser;
  final String? text;
  // Instead of simple list, we hold the full result object
  final AdvancedSearchResult? result;

  ChatItem({required this.isUser, this.text, this.result});
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
      // Switch to AdvancedSearchService
      final searchService = Provider.of<AdvancedSearchService>(context, listen: false);
      final result = await searchService.executeAdvancedQuery(text);

      setState(() {
        _messages.add(ChatItem(
          isUser: false, 
          result: result, // Pass the rich result object
        ));
      });
    } catch (e) {
      setState(() {
        _messages.add(ChatItem(isUser: false, text: "Error processing query: $e"));
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Row(
                children: [
                  const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.blue)),
                  const SizedBox(width: 12),
                  Text("Thinking...", style: TextStyle(color: Colors.grey[500], fontSize: 14)),
                ],
              ),
            ),

          // Input Area
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              border: Border(top: BorderSide(color: Colors.grey[800]!, width: 0.5)),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(color: Colors.grey[850], borderRadius: BorderRadius.circular(24)),
                      child: TextField(
                        controller: _controller,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Ask complex queries...',
                          hintStyle: TextStyle(color: Colors.grey[600]),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        ),
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: const BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
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
      return Align(
        alignment: Alignment.centerRight,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(20).copyWith(bottomRight: const Radius.circular(4)),
          ),
          child: Text(item.text ?? "", style: const TextStyle(color: Colors.white, fontSize: 15)),
        ),
      );
    } else {
      // AI Response
      final result = item.result;
      final text = item.text ?? result?.summary ?? "No response";
      final contacts = result?.contacts;

      return Align(
        alignment: Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          width: MediaQuery.of(context).size.width * 0.9,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Summary Text Bubble
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(20).copyWith(bottomLeft: const Radius.circular(4)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(text, style: const TextStyle(color: Colors.white, fontSize: 15)),
                    // Show reasoning if available
                    if (result != null && result.parameters.hasAbstractConcept)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          "Filtered by: ${result.parameters.abstractConcept}",
                          style: TextStyle(color: Colors.blue.shade200, fontSize: 12, fontStyle: FontStyle.italic),
                        ),
                      ),
                  ],
                ),
              ),
              
              // Contact Cards
              if (contacts != null && contacts.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: Column(
                    children: contacts.map((c) {
                      // Check if we have a specific match score/reason
                      String? matchReason;
                      if (result?.scoredContacts != null) {
                        final match = result!.scoredContacts!.firstWhere(
                          (sc) => sc.contact.id == c.id, 
                          orElse: () => ContactWithScore(contact: c, score: 0, reason: "")
                        );
                        if (match.reason.isNotEmpty) matchReason = "${(match.score * 100).toInt()}% Match";
                      }

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Stack(
                          children: [
                            ContactCard(
                              contact: c, 
                              onTap: () {
                                // Navigation handled inside card or here
                              },
                            ),
                            if (matchReason != null)
                              Positioned(
                                right: 12,
                                top: 12,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(4)),
                                  child: Text(matchReason, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                                ),
                              ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
            ],
          ),
        ),
      );
    }
  }

  Widget _buildEmptyState() {
    return Center(child: Text("Ask me anything...", style: TextStyle(color: Colors.grey[600])));
  }
}