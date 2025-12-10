import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;

  // Choose your API provider: 'gemini' or 'groq'
  final String _apiProvider = 'groq'; // Change to 'groq' for faster responses

  // API Keys
  final String _geminiApiKey = 'AIzaSyBhsqFUN3cywoboKNUBtYr8XCfnzR3XceI'; // Get from: https://aistudio.google.com/app/apikey
  final String _groqApiKey = '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'; // Get from: https://console.groq.com/keys

  // Conversation history for context
  final List<Map<String, String>> _conversationHistory = [];

  @override
  void initState() {
    super.initState();
    _messages.add(ChatMessage(
      text: "Hello! I'm your Nanavati Hospital medical assistant. I can help you with:\n\n• Medical queries and symptoms\n• Pharmacy and medication information\n• Hospital services and facilities\n• Appointment booking guidance\n• General health advice\n\nHow can I assist you today?",
      isUser: false,
      timestamp: DateTime.now(),
    ));
  }

  Future<void> _sendMessage(String message) async {
    if (message.trim().isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(
        text: message,
        isUser: true,
        timestamp: DateTime.now(),
      ));
      _isLoading = true;
    });

    _messageController.clear();
    _scrollToBottom();

    try {
      String response;
      if (_apiProvider == 'groq') {
        response = await _getGroqResponse(message);
      } else {
        response = await _getGeminiResponse(message);
      }

      setState(() {
        _messages.add(ChatMessage(
          text: response,
          isUser: false,
          timestamp: DateTime.now(),
        ));
        _isLoading = false;
      });

      _conversationHistory.add({'user': message});
      _conversationHistory.add({'assistant': response});
    } catch (e) {
      print('Error in _sendMessage: $e');
      setState(() {
        _messages.add(ChatMessage(
          text: "I apologize, but I'm having trouble connecting right now. Please try again in a moment or contact our support team at +91-22-6789-8888.",
          isUser: false,
          timestamp: DateTime.now(),
        ));
        _isLoading = false;
      });
    }

    _scrollToBottom();
  }

  // GROQ API Implementation (SUPER FAST! ⚡)
  Future<String> _getGroqResponse(String userMessage) async {
    try {
      if (_groqApiKey.isEmpty || _groqApiKey == 'YOUR_GROQ_API_KEY_HERE') {
        return '⚠️ Please add your Groq API key\n\nGet it free from: https://console.groq.com/keys\n\nGroq is SUPER FAST and has generous free limits!';
      }

      final url = Uri.parse('https://api.groq.com/openai/v1/chat/completions');

      String systemPrompt = '''You are a helpful medical assistant for Nanavati Hospital in Mumbai, India. Your role is to:

1. Answer general medical queries and provide health information
2. Help with pharmacy and medication-related questions
3. Provide information about Nanavati Hospital services
4. Guide patients on appointment booking
5. Offer general health advice and preventive care tips

IMPORTANT GUIDELINES:
- Always be empathetic, professional, and reassuring
- For serious symptoms, always advise consulting a doctor immediately
- Never provide specific diagnoses - only general information
- Keep responses concise (2-3 paragraphs maximum)

Hospital Information:
- Location: S.V. Road, Vile Parle West, Mumbai
- Emergency: 24/7 - Call +91-22-6789-8888
- Key Departments: Cardiology, Neurology, Orthopedics, Oncology, Pediatrics
- Pharmacy: Open 24/7''';

      // Build messages array with conversation history
      List<Map<String, String>> messages = [
        {'role': 'system', 'content': systemPrompt}
      ];

      // Add recent conversation (last 4 messages)
      int startIndex = _conversationHistory.length > 4
          ? _conversationHistory.length - 4
          : 0;

      for (int i = startIndex; i < _conversationHistory.length; i++) {
        final msg = _conversationHistory[i];
        if (msg.containsKey('user')) {
          messages.add({'role': 'user', 'content': msg['user']!});
        } else if (msg.containsKey('assistant')) {
          messages.add({'role': 'assistant', 'content': msg['assistant']!});
        }
      }

      // Add current message
      messages.add({'role': 'user', 'content': userMessage});

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_groqApiKey',
        },
        body: jsonEncode({
          'model': 'llama-3.3-70b-versatile', // Fast and accurate model
          'messages': messages,
          'temperature': 0.7,
          'max_tokens': 800,
          'top_p': 0.9,
        }),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Request timeout');
        },
      );

      print('Groq Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text = data['choices'][0]['message']['content'];
        return text.trim();
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception('Groq API Error: ${errorBody['error']['message']}');
      }
    } catch (e) {
      print('Groq Error: $e');
      if (e.toString().contains('SocketException')) {
        return '❌ No internet connection. Please check your network.';
      }
      throw Exception('Network error');
    }
  }

  // GEMINI API Implementation (Original)
  Future<String> _getGeminiResponse(String userMessage) async {
    try {
      if (_geminiApiKey.isEmpty || _geminiApiKey == 'AIzaSyBhsqFUN3cywoboKNUBtYr8XCfnzR3XceI') {
        return '⚠️ Please add your Gemini API key\n\nGet it free from: https://aistudio.google.com/app/apikey';
      }

      final url = Uri.parse(
          'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$_geminiApiKey'
      );

      String contextPrompt = '''You are a helpful medical assistant for Nanavati Hospital in Mumbai, India. Your role is to:

1. Answer general medical queries and provide health information
2. Help with pharmacy and medication-related questions
3. Provide information about Nanavati Hospital services, departments, and facilities
4. Guide patients on appointment booking and procedures
5. Offer general health advice and preventive care tips

IMPORTANT GUIDELINES:
- Always be empathetic, professional, and reassuring
- For serious symptoms, always advise consulting a doctor immediately
- Never provide specific diagnoses - only general information
- Remind users that your advice doesn't replace professional medical consultation
- Be culturally sensitive and respectful
- Provide information about Nanavati Hospital's services when relevant
- Use Indian context (medications available in India, local health practices)
- Keep responses concise and helpful (2-3 paragraphs maximum)

Hospital Information:
- Location: S.V. Road, Vile Parle West, Mumbai
- Emergency: 24/7 available - Call +91-22-6789-8888
- Key Departments: Cardiology, Neurology, Orthopedics, Oncology, Pediatrics, Emergency Medicine
- Services: Diagnostics, Blood Bank, Pharmacy, Radiology, ICU, Operation Theaters
- Visiting Hours: 4 PM - 7 PM daily
- Pharmacy: Open 24/7

''';

      if (_conversationHistory.isNotEmpty) {
        contextPrompt += '\nRecent Conversation:\n';
        int startIndex = _conversationHistory.length > 4
            ? _conversationHistory.length - 4
            : 0;
        for (int i = startIndex; i < _conversationHistory.length; i++) {
          final msg = _conversationHistory[i];
          if (msg.containsKey('user')) {
            contextPrompt += 'User: ${msg['user']}\n';
          } else if (msg.containsKey('assistant')) {
            contextPrompt += 'Assistant: ${msg['assistant']}\n';
          }
        }
      }

      contextPrompt += '\nCurrent User Question: $userMessage\n\nProvide a helpful, concise response:';

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': contextPrompt}
              ]
            }
          ],
          'generationConfig': {
            'temperature': 0.7,
            'topK': 40,
            'topP': 0.95,
            'maxOutputTokens': 800,
          },
          'safetySettings': [
            {
              'category': 'HARM_CATEGORY_HARASSMENT',
              'threshold': 'BLOCK_MEDIUM_AND_ABOVE'
            },
            {
              'category': 'HARM_CATEGORY_HATE_SPEECH',
              'threshold': 'BLOCK_MEDIUM_AND_ABOVE'
            },
            {
              'category': 'HARM_CATEGORY_SEXUALLY_EXPLICIT',
              'threshold': 'BLOCK_MEDIUM_AND_ABOVE'
            },
            {
              'category': 'HARM_CATEGORY_DANGEROUS_CONTENT',
              'threshold': 'BLOCK_MEDIUM_AND_ABOVE'
            }
          ]
        }),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Request timeout');
        },
      );

      print('Gemini Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['candidates'] != null && data['candidates'].isNotEmpty) {
          final text = data['candidates'][0]['content']['parts'][0]['text'];
          return text.trim();
        } else {
          throw Exception('No response generated');
        }
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception('Gemini API Error: ${errorBody['error']['message']}');
      }
    } catch (e) {
      print('Gemini Error: $e');
      if (e.toString().contains('SocketException')) {
        return '❌ No internet connection. Please check your network.';
      }
      throw Exception('Network error');
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2563EB),
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.smart_toy,
                color: Color(0xFF2563EB),
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Medical Assistant",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  _apiProvider == 'groq' ? 'Powered by Groq ⚡' : 'Powered by Gemini AI',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline, color: Colors.white),
            onPressed: _showInfoDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          // Quick Action Chips
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.white,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildQuickActionChip("Book Appointment", Icons.calendar_today),
                  const SizedBox(width: 8),
                  _buildQuickActionChip("Emergency Help", Icons.emergency),
                  const SizedBox(width: 8),
                  _buildQuickActionChip("Find Doctor", Icons.person_search),
                  const SizedBox(width: 8),
                  _buildQuickActionChip("Pharmacy", Icons.medication),
                  const SizedBox(width: 8),
                  _buildQuickActionChip("Lab Reports", Icons.biotech),
                ],
              ),
            ),
          ),

          // Messages List
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return _buildMessageBubble(_messages[index]);
              },
            ),
          ),

          // Loading Indicator
          if (_isLoading)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  const SizedBox(width: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.grey[600]!),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "Thinking...",
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          // Input Area
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: TextField(
                        controller: _messageController,
                        decoration: const InputDecoration(
                          hintText: "Type your message...",
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                        ),
                        maxLines: null,
                        textCapitalization: TextCapitalization.sentences,
                        onSubmitted: _sendMessage,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF2563EB).withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white),
                      onPressed: () => _sendMessage(_messageController.text),
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

  Widget _buildQuickActionChip(String label, IconData icon) {
    return GestureDetector(
      onTap: () {
        _messageController.text = "I need help with: $label";
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF2563EB).withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: const Color(0xFF2563EB)),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF2563EB),
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment:
        message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Color(0xFF2563EB),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.smart_toy,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: message.isUser
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: message.isUser
                        ? const Color(0xFF2563EB)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    message.text,
                    style: TextStyle(
                      color: message.isUser ? Colors.white : Colors.black87,
                      fontSize: 15,
                      height: 1.4,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatTime(message.timestamp),
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          if (message.isUser) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person,
                color: Colors.grey,
                size: 20,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    return "${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}";
  }

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF2563EB).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.info_outline,
                color: Color(0xFF2563EB),
              ),
            ),
            const SizedBox(width: 12),
            const Text("About Medical Assistant"),
          ],
        ),
        content: Text(
          "This AI-powered chatbot can help you with:\n\n"
              "• General medical information\n"
              "• Symptom guidance\n"
              "• Medication queries\n"
              "• Hospital services\n"
              "• Appointment assistance\n"
              "• Lab report queries\n\n"
              "⚡ Using: ${_apiProvider == 'groq' ? 'Groq (Super Fast)' : 'Google Gemini'}\n\n"
              "⚠️ Important: This chatbot provides general information only and does not replace professional medical advice. For emergencies, call our 24/7 helpline at +91-22-6789-8888 or visit the emergency department.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Got it",
              style: TextStyle(
                color: Color(0xFF2563EB),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}