import 'package:flutter/material.dart';
import 'package:cactus/cactus.dart';
import 'screens/getstarted_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const GetStartedScreen(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _isLoading = false;
  bool _isModelReady = false;
  String _statusMessage = 'Model not downloaded';
  double? _downloadProgress;
  
  final CactusLM _lm = CactusLM();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];

  @override
  void initState() {
    super.initState();
    _checkModelStatus();
  }

  @override
  void dispose() {
    _lm.unload();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _checkModelStatus() async {
    final isLoaded = _lm.isLoaded();
    setState(() {
      _isModelReady = isLoaded;
      _statusMessage = isLoaded ? 'Model ready' : 'Model not downloaded';
    });
  }

  Future<void> _downloadAndInitializeModel() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Downloading model...';
      _downloadProgress = null;
    });

    try {
      // Download the Gemma 270M model (smaller and faster)
      await _lm.downloadModel(
        model: "gemma3-270m",
        downloadProcessCallback: (progress, status, isError) {
          if (isError) {
            setState(() {
              _statusMessage = 'Download error: $status';
              _isLoading = false;
            });
          } else {
            setState(() {
              _downloadProgress = progress;
              _statusMessage = '$status ${progress != null ? '(${(progress * 100).toStringAsFixed(1)}%)' : ''}';
            });
          }
        },
      );

      // Initialize the model
      setState(() {
        _statusMessage = 'Initializing model...';
      });
      
      await _lm.initializeModel();

      setState(() {
        _isModelReady = true;
        _isLoading = false;
        _statusMessage = 'Model ready!';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error: $e';
        _isLoading = false;
      });
    }
  }



  Future<void> _sendMessage() async {
    if (!_isModelReady) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please download and initialize the model first.')),
      );
      return;
    }

    final messageText = _messageController.text.trim();
    if (messageText.isEmpty) return;

    // Add user message to chat
    setState(() {
      _messages.add(ChatMessage(content: messageText, role: "user"));
      _isLoading = true;
    });
    
    _messageController.clear();
    
    // Scroll to bottom after adding user message
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

    try {
      // Add empty assistant message that will be updated as we stream
      setState(() {
        _messages.add(ChatMessage(content: '', role: "assistant"));
      });
      
      final assistantMessageIndex = _messages.length - 1;
      String fullResponse = '';
      
      final streamedResult = await _lm.generateCompletionStream(
        messages: _messages.sublist(0, assistantMessageIndex),
      );
      
      // Listen to the stream and update the message
      await for (final chunk in streamedResult.stream) {
        fullResponse += chunk;
        setState(() {
          _messages[assistantMessageIndex] = ChatMessage(content: fullResponse, role: "assistant");
        });
        
        // Auto-scroll as text comes in
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
      }
      
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _messages.add(ChatMessage(content: 'Error: $e', role: "assistant"));
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          // Status bar
          Container(
            padding: const EdgeInsets.all(12),
            color: _isModelReady ? Colors.green[50] : Colors.orange[50],
            child: Row(
              children: [
                Icon(
                  _isModelReady ? Icons.check_circle : Icons.info,
                  color: _isModelReady ? Colors.green : Colors.orange,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _statusMessage,
                    style: TextStyle(
                      fontSize: 12,
                      color: _isModelReady ? Colors.green[900] : Colors.orange[900],
                    ),
                  ),
                ),
                if (!_isModelReady)
                  ElevatedButton.icon(
                    onPressed: _isLoading ? null : _downloadAndInitializeModel,
                    icon: const Icon(Icons.download, size: 16),
                    label: const Text('Download Model', style: TextStyle(fontSize: 12)),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
              ],
            ),
          ),
          if (_downloadProgress != null)
            LinearProgressIndicator(value: _downloadProgress),
          
          // Chat messages
          Expanded(
            child: _messages.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          _isModelReady 
                              ? 'Start chatting with Qwen AI'
                              : 'Download the model to start chatting',
                          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      final isUser = message.role == "user";
                      
                      return Align(
                        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.75,
                          ),
                          decoration: BoxDecoration(
                            color: isUser ? Colors.blue[100] : Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            message.content,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          
          // Loading indicator
          if (_isLoading)
            Container(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  const SizedBox(width: 16),
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 8),
                  Text('Thinking...', style: TextStyle(color: Colors.grey[600])),
                ],
              ),
            ),
          
          // Input area
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    enabled: _isModelReady && !_isLoading,
                    maxLines: null,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: _isModelReady && !_isLoading
                      ? Colors.blue
                      : Colors.grey[300],
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white, size: 20),
                    onPressed: _isModelReady && !_isLoading ? _sendMessage : null,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
