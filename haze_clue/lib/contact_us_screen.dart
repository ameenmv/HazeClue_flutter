import 'package:flutter/material.dart';
import 'api_service.dart';
import 'glass_widgets.dart';

class ContactUsScreen extends StatefulWidget {
  const ContactUsScreen({super.key});

  @override
  State<ContactUsScreen> createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen> {
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  bool _isLoading = false;

  Future<void> _submitTicket() async {
    if (_subjectController.text.isEmpty || _messageController.text.isEmpty) return;
    setState(() => _isLoading = true);
    try {
      await ApiService.submitSupportTicket(_subjectController.text, _messageController.text);
      if (!mounted) return;
      showGlassToast(context, 'Message sent successfully!', isError: false);
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      showGlassToast(context, e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).colorScheme.onSurface;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Contact Us",
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: AnimatedBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                // --- Send Us a Message Card ---
                GlassCard(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Text(
                            "Send us a message",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        GlassTextField(
                          label: "Subject",
                          hint: "Message Subject",
                          controller: _subjectController,
                          icon: Icons.subject,
                        ),
                        const SizedBox(height: 16),
                        GlassTextField(
                          label: "Message",
                          hint: "How can we help you today?",
                          controller: _messageController,
                          icon: Icons.message_outlined,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // --- Send Message Button ---
                _isLoading 
                  ? Center(child: CircularProgressIndicator(color: textColor)) 
                  : GlassButton(
                      text: "Send Message",
                      onPressed: _submitTicket,
                    ),
                const SizedBox(height: 32),

                // --- Reach Out Directly Card ---
                GlassCard(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Reach Out Directly",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: textColor.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.mail_outline, color: Color(0xFF8B5CF6), size: 20),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: RichText(
                                text: TextSpan(
                                  style: TextStyle(color: textColor, fontSize: 14),
                                  children: const [
                                    TextSpan(
                                      text: "Email: ",
                                      style: TextStyle(fontWeight: FontWeight.w600),
                                    ),
                                    TextSpan(text: "support@"),
                                    TextSpan(
                                      text: "HazeClue",
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    TextSpan(text: ".com"),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: textColor.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.access_time, color: Color(0xFF8B5CF6), size: 20),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: RichText(
                                text: TextSpan(
                                  style: TextStyle(color: textColor, fontSize: 14),
                                  children: const [
                                    TextSpan(
                                      text: "Hours:  ",
                                      style: TextStyle(fontWeight: FontWeight.w600),
                                    ),
                                    TextSpan(text: "Mon-Fri, 9 AM - 5 PM (EST)"),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
