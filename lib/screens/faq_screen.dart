import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/wave_clipper.dart';
import '../providers/theme_provider.dart';

class FAQScreen extends StatelessWidget {
  const FAQScreen({super.key});

  final List<FAQ> faqs = const [
    FAQ(
      question: "Which languages are supported for search?",
      answer: "Search by kana only supported (Japanese Kanji is also supported).",
    ),
    FAQ(
      question: "Whether more platforms will be supported in the future?",
      answer: "There are plans for that in the future.",
    ),
    FAQ(
      question: "Will dictionaries be added in the future?",
      answer: "Yes, the database will be continuously updated in the form of cold updates, please update the software in time to obtain the latest data.",
    ),
    FAQ(
      question: "Why does the search history keep recording every different type?",
      answer: "Because it is constantly through the input field of keyword search results that meet the conditions",
    ),
    FAQ(
      question: "软件的布局和风格是否不太符合正常审美？",
      answer: "不是兄弟，你懂设计吗？",
    ),
    FAQ(
      question: "Why are there two examples of a word that are exactly the same?",
      answer: "This was caused by an earlier bug code used to clean up Python scripts in the specified Json format. The issue of duplicate examples is currently being fixed and will be addressed in a future cold update.",
    ),
    FAQ(
      question: "Why does it look bad to choose a blue or pink theme in dark mode?",
      answer: "This is a hidden bug that was never properly fixed before the 1.0.0 release, and will be progressively fixed in a future cold update.",
    ),
    FAQ(
      question: "Why is there always an interruption when using pinyin to type Chinese, leading to the normal input of Chinese?",
      answer: "This is a very strange bug, currently looking for a solution, it is recommended to use pseudonyms (as mentioned in the first question).",
    ),
    FAQ(
      question: "Why is software storage taking up so much space?",
      answer: "I'm sorry for taking up so much storage space. Next, I will explain the reason for this phenomenon: the software is offline, you do not need to connect to the Internet to use the software, so the word data of the software is completely stored locally, which causes a large amount of storage space.",
    ),
    FAQ(
      question: "Why does searching for a word yield multiple matching results?",
      answer: "This is because the word data of the software comes from multiple dictionaries, and there may be repeated words in each dictionary. I am deeply sorry for this.",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return Scaffold(
      body: Stack(
        children: [
          Container(color: themeProvider.backgroundColor),
          ClipPath(
            clipper: WaveClipper(),
            child: Container(color: themeProvider.accentColor),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back, color: themeProvider.textColor),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      Text(
                        'Settings',
                        style: TextStyle(
                          color: themeProvider.textColor,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.only(
                      left: 16,
                      right: 16,
                      bottom: 100,
                    ),
                    itemCount: faqs.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 25),
                        child: FAQItem(
                          faq: faqs[index],
                          themeProvider: themeProvider,
                        ),
                      );
                    },
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

class FAQItem extends StatelessWidget {
  final FAQ faq;
  final ThemeProvider themeProvider;

  const FAQItem({
    super.key,
    required this.faq,
    required this.themeProvider,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: themeProvider.backgroundColor,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: themeProvider.accentColor, width: 2),
        boxShadow: [
          BoxShadow(
            color: themeProvider.textColor.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            faq.question,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: themeProvider.textColor,
            ),
          ),
          const SizedBox(height: 15),
          Text(
            faq.answer,
            style: TextStyle(
              fontSize: 14,
              color: themeProvider.textColor.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}

class FAQ {
  final String question;
  final String answer;

  const FAQ({
    required this.question,
    required this.answer,
  });
} 