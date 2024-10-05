import 'package:ai_assistant_app/pages/my_loading_circle.dart';
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
    apiKey: 'AIzaSyCRsZhDX_ehdFHDjihenkODPMAlmaLjT_Q',
  );
  String? aiResponse;
  String? myMessage;
  Future<void> _submitMessage() async {
    if (_controller.text == "") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter a message."),
        ),
      );
      return;
    } else {
      FocusScope.of(context).requestFocus(FocusNode());

      setState(() {
        showLoadingCircle(context);
      });
      final promptText = _controller.text;
      final response = await model.generateContent([Content.text(promptText)]);
      aiResponse = response.text.toString();
      myMessage = _controller.text;
      setState(() {
        hideLoadingCircle(context);
        _controller.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(
                height: 30,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.arrow_back_outlined)),
                  Text(
                    "Chat",
                    style: GoogleFonts.poppins(
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                        fontSize: 20),
                  ),
                  Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.menu_outlined)),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              const Divider(),
              const SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    const Expanded(child: Divider()),
                    Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 10),
                        decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(20)),
                        child: Text(
                          "Today",
                          style: GoogleFonts.poppins(
                              color: Colors.grey, fontWeight: FontWeight.w500),
                        )),
                    const Expanded(child: Divider()),
                  ],
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Expanded(
                child: ListView(
                  children: [
                    MyMessage(message: myMessage ?? ""),
                    AiMessage(message: aiResponse ?? ""),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(25)),
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
                                  color: Colors.black, width: 1.5)),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                  color: Colors.black, width: 0.3))),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: _submitMessage,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
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
              const SizedBox(
                height: 25,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
