import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/wave_clipper.dart';
import '../providers/theme_provider.dart';
import 'faq_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  final List<String> themes = const ["Light", "Dark", "System", "Blue", "Pink"];

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final themeItemWidth = (screenWidth - 200) / 5;
    
    return Scaffold(
      body: Stack(
        children: [
          Container(color: themeProvider.backgroundColor),
          ClipPath(
            clipper: WaveClipper(),
            child: Container(color: themeProvider.accentColor),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Settings',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: themeProvider.textColor,
                    ),
                  ),
                  const SizedBox(height: 30),
                  _buildSettingsSection(context, themeProvider, themeItemWidth),
                  const SizedBox(height: 30),
                  _buildOtherSection(context, themeProvider),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(BuildContext context, ThemeProvider themeProvider, double themeItemWidth) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Application Settings',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: themeProvider.textColor,
          ),
        ),
        const SizedBox(height: 15),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: themeProvider.backgroundColor,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: themeProvider.textColor.withOpacity(0.1),
                blurRadius: 5,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              Text(
                'Theme',
                style: TextStyle(
                  fontSize: 16,
                  color: themeProvider.textColor,
                ),
              ),
              const Spacer(),
              PopupMenuButton<int>(
                offset: const Offset(0, 40),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                color: themeProvider.backgroundColor,
                elevation: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: themeProvider.accentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: themeProvider.accentColor.withOpacity(0.5),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        themes[themeProvider.selectedTheme],
                        style: TextStyle(
                          color: themeProvider.accentColor,
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.arrow_drop_down,
                        color: themeProvider.accentColor,
                      ),
                    ],
                  ),
                ),
                itemBuilder: (context) => [
                  for (int i = 0; i < themes.length; i++)
                    PopupMenuItem<int>(
                      value: i,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: themeProvider.selectedTheme == i
                              ? themeProvider.accentColor.withOpacity(0.1)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Text(
                              themes[i],
                              style: TextStyle(
                                color: themeProvider.selectedTheme == i
                                    ? themeProvider.accentColor
                                    : themeProvider.textColor,
                                fontWeight: themeProvider.selectedTheme == i
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                            ),
                            const Spacer(),
                            if (themeProvider.selectedTheme == i)
                              Icon(
                                Icons.check,
                                color: themeProvider.accentColor,
                                size: 18,
                              ),
                          ],
                        ),
                      ),
                    ),
                ],
                onSelected: (value) {
                  themeProvider.setTheme(value);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _pickImage(BuildContext context, ThemeProvider themeProvider) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      
      if (image != null) {
        // 复制图片到应用目录
        final directory = await getApplicationDocumentsDirectory();
        final String path = directory.path;
        final String fileName = DateTime.now().millisecondsSinceEpoch.toString() + '.jpg';
        final File newImage = await File(image.path).copy('$path/$fileName');
        
        // 保存新图片路径
        await themeProvider.setBackgroundImage(newImage.path);
      }
    } catch (e) {
      // 显示错误提示
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to set background image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildOtherSection(BuildContext context, ThemeProvider themeProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Other',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: themeProvider.textColor,
          ),
        ),
        const SizedBox(height: 15),
        _buildOptionButton(
          title: 'FAQ',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const FAQScreen()),
            );
          },
          textColor: themeProvider.textColor,
          backgroundColor: themeProvider.backgroundColor,
        ),
        const SizedBox(height: 10),
        _buildOptionButton(
          title: 'Contact us',
          onTap: () {
            showGeneralDialog(
              context: context,
              pageBuilder: (context, animation, secondaryAnimation) {
                return Container(); // 这个不会被显示
              },
              transitionBuilder: (context, animation, secondaryAnimation, child) {
                final curvedAnimation = CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutCubic,
                );

                return AnimatedBuilder(
                  animation: curvedAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: animation.value,
                      child: Opacity(
                        opacity: animation.value,
                        child: AlertDialog(
                          backgroundColor: themeProvider.backgroundColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          title: Text(
                            'Contact us',
                            style: TextStyle(
                              color: themeProvider.textColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          content: TweenAnimationBuilder<double>(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOutCubic,
                            tween: Tween(begin: 0, end: 1),
                            builder: (context, value, child) {
                              return Opacity(
                                opacity: value,
                                child: Transform.translate(
                                  offset: Offset(0, 20 * (1 - value)),
                                  child: child,
                                ),
                              );
                            },
                            child: Text(
                              'email: Kayano04@outlook.jp',
                              style: TextStyle(
                                color: themeProvider.textColor.withOpacity(0.8),
                              ),
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text(
                                'OK',
                                style: TextStyle(
                                  color: themeProvider.accentColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              transitionDuration: const Duration(milliseconds: 400),
              barrierDismissible: true,
              barrierLabel: '',
              barrierColor: Colors.black54,
            );
          },
          textColor: themeProvider.textColor,
          backgroundColor: themeProvider.backgroundColor,
        ),
      ],
    );
  }

  Widget _buildOptionButton({
    required String title,
    required VoidCallback onTap,
    required Color textColor,
    required Color backgroundColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: textColor.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(15),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    color: textColor,
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.chevron_right,
                  color: textColor.withOpacity(0.7),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 