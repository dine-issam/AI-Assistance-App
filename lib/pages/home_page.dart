import 'package:ai_assistant_app/database/chatstorage.dart';
import 'package:ai_assistant_app/utils/ai_message.dart';

import 'package:ai_assistant_app/utils/my_message.dart';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _controller = TextEditingController();

  final model = GenerativeModel(
    model: 'gemini-1.5-flash',
    apiKey: 'YOUR-API',
  );
  List<Map<String, String>> chatMessages = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    List<Map<String, String>> loadedMessages = await ChatStorage.loadMessages();
    setState(() {
      chatMessages = loadedMessages;
    });
  }

  Future<void> _submitMessage() async {
    if (_controller.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter a message."),
        ),
      );
      return;
    }

    FocusScope.of(context).requestFocus(FocusNode());

    // Show loading indicator
    setState(() {
      isLoading = true;
    });

    final promptText = _controller.text;
    final response = await model.generateContent([Content.text(promptText)]);
    final aiResponse = response.text.toString();
    final myMessage = _controller.text;
    print(aiResponse);

    // Save messages to local chat history
    chatMessages.add({"user": myMessage});
    chatMessages.add({"ai": aiResponse});
    await ChatStorage.saveMessages(chatMessages);

    setState(() {
      isLoading = false;
      _controller.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.arrow_back_outlined),
                  ),
                  Text(
                    "Chat",
                    style: GoogleFonts.poppins(
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                      fontSize: 20,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.menu_outlined),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Divider(),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    const Expanded(child: Divider()),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        "Today",
                        style: GoogleFonts.poppins(
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: chatMessages.length,
                  itemBuilder: (context, index) {
                    final message = chatMessages[index];
                    final isUserMessage = message.containsKey('user');
                    // Check if the AI message contains code block by detecting '''java and '''
                    if (!isUserMessage &&
                        message['ai']!.contains("```java") &&
                        message['ai']!.contains("```")) {
                      // Extract the text and code parts
                      final startIndex = message['ai']!.indexOf("```java");
                      final endIndex = message['ai']!
                          .indexOf("```", startIndex + 7); // Skip past '''java
                      final textPart =
                          message['ai']!.substring(0, startIndex).trim();
                      final codePart = message['ai']!
                          .substring(startIndex + 7, endIndex)
                          .trim(); // Extract code block

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Display regular text message
                          if (textPart.isNotEmpty) AiMessage(message: textPart),

                          // Display code block in a container with custom styling
                          Container(
                            padding: const EdgeInsets.all(10),
                            margin: const EdgeInsets.symmetric(vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.grey[
                                  200], // Light background for the code block
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: Colors.blueAccent,
                                  width: 1), // Optional border
                            ),
                            child: Text(
                              codePart,
                              style: GoogleFonts.robotoMono(
                                fontSize: 14,
                                color:
                                    Colors.black, // Darker text color for code
                              ),
                            ),
                          ),

                          // Display any text after the code block (if exists)
                          if (message['ai']!.length > endIndex + 3)
                            AiMessage(
                                message: message['ai']!
                                    .substring(endIndex + 3)
                                    .trim()),
                        ],
                      );
                    } else if (isUserMessage) {
                      return MyMessage(message: message['user']!);
                    } else {
                      return AiMessage(message: message['ai']!);
                    }
                  },
                ),
              ),

              // Custom loading widget while waiting for AI response
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: "Ask me anything ...",
                        hintStyle: GoogleFonts.poppins(
                          color: Colors.black,
                          fontSize: 14,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Colors.black,
                            width: 1.5,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Colors.black,
                            width: 0.3,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: _submitMessage,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              "Send",
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 25),
            ],
          ),
        ),
      ),
    );
  }
}
