import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/ai_service.dart';
import '../config/liquid_glass_theme.dart';
import '../widgets/animated_orb_background.dart';
import '../widgets/glass_container.dart';

/// AI Job Coach Chat Screen — Apple Liquid Glass design.
class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  final TextEditingController _controller    = TextEditingController();
  final ScrollController       _scrollController = ScrollController();
  final List<Map<String, dynamic>> _messages = [];
  bool _isLoading = false;
  List<String> _suggestions = [];

  @override
  void initState() {
    super.initState();
    _messages.add({
      'role': 'assistant',
      'content': '''👋 Hi! I'm **JobBot**, your AI Job Search Coach!

I can help you with:
• 📝 **Interview preparation** — questions, answers, and tips
• 📄 **Resume & cover letter** advice
• 💰 **Salary negotiation** strategies
• 🎯 **Job search tactics** and planning
• 📊 **Career path** guidance

What would you like help with today?''',
    });
    _suggestions = [
      'How do I prepare for a technical interview?',
      'What salary should I ask for?',
      'How can I improve my resume?',
    ];
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage(String message) async {
    if (message.trim().isEmpty) return;

    final token = context.read<AuthProvider>().token;
    if (token.isEmpty) return;

    setState(() {
      _messages.add({'role': 'user', 'content': message});
      _isLoading = true;
      _suggestions = [];
      _controller.clear();
    });
    _scrollToBottom();

    try {
      final service = AiService(token);
      final history = _messages
          .where((m) => m['role'] != 'system')
          .take(_messages.length - 1)
          .map((m) => {'role': m['role'] as String, 'content': m['content'] as String})
          .toList();

      final result = await service.chat(message: message, history: history);

      setState(() {
        _messages.add({
          'role': 'assistant',
          'content': result['reply'] ?? 'Sorry, I could not generate a response.',
        });
        _suggestions = List<String>.from(result['suggestions'] ?? []);
        _isLoading = false;
      });
      _scrollToBottom();
    } catch (e) {
      setState(() {
        _messages.add({
          'role': 'assistant',
          'content': '❌ Sorry, I encountered an error. Please try again.\n\n_${e.toString().replaceFirst('Exception: ', '')}_',
        });
        _isLoading = false;
      });
      _scrollToBottom();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LiquidGlass.bgDeep,
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              decoration: BoxDecoration(
                color: LiquidGlass.bgDeep.withValues(alpha: 0.75),
                border: Border(
                  bottom: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 36, height: 36,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.07),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
                          ),
                          child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 14),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Bot avatar
                      Container(
                        width: 38, height: 38,
                        decoration: BoxDecoration(
                          gradient: LiquidGlass.primaryGradient,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: LiquidGlass.glowShadow(LiquidGlass.accentPrimary, blur: 12),
                        ),
                        child: const Icon(Icons.smart_toy, color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'JobBot',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          ShaderMask(
                            shaderCallback: (b) => LiquidGlass.primaryGradient.createShader(b),
                            child: const Text(
                              'AI Job Coach',
                              style: TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      IconButton(
                        icon: Icon(Icons.refresh, color: Colors.white.withValues(alpha: 0.5)),
                        tooltip: 'Clear conversation',
                        onPressed: () {
                          setState(() {
                            _messages.clear();
                            _messages.add({
                              'role': 'assistant',
                              'content': '🔄 Conversation cleared! How can I help you today?',
                            });
                            _suggestions = [
                              'How do I prepare for a technical interview?',
                              'What salary should I ask for?',
                              'Help me write a cover letter',
                            ];
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          const Positioned.fill(child: AnimatedOrbBackground()),

          Column(
            children: [
              const SizedBox(height: 80), // app bar height

              // ── Messages ──
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  itemCount: _messages.length + (_isLoading ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == _messages.length) {
                      return _buildLoadingBubble();
                    }
                    final msg = _messages[index];
                    return _buildMessageBubble(
                      content: msg['content'] as String,
                      isUser: msg['role'] == 'user',
                    );
                  },
                ),
              ),

              // ── Suggestions ──
              if (_suggestions.isNotEmpty && !_isLoading)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Suggested:',
                        style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.4)),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: _suggestions.map((s) {
                          return GestureDetector(
                            onTap: () => _sendMessage(s),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                              decoration: BoxDecoration(
                                color: LiquidGlass.accentPrimary.withValues(alpha: 0.10),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: LiquidGlass.accentPrimary.withValues(alpha: 0.3)),
                              ),
                              child: Text(
                                s,
                                style: const TextStyle(fontSize: 12, color: Color(0xFF9D8FFF)),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),

              // ── Input area ──
              ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                    decoration: BoxDecoration(
                      color: LiquidGlass.bgDeep.withValues(alpha: 0.8),
                      border: Border(
                        top: BorderSide(color: Colors.white.withValues(alpha: 0.07)),
                      ),
                    ),
                    child: SafeArea(
                      top: false,
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.07),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: LiquidGlass.accentPrimary.withValues(alpha: 0.25),
                                ),
                              ),
                              child: TextField(
                                controller: _controller,
                                style: const TextStyle(color: Colors.white, fontSize: 14),
                                maxLines: null,
                                textInputAction: TextInputAction.send,
                                onSubmitted: _sendMessage,
                                decoration: InputDecoration(
                                  hintText: 'Ask me anything about your job search...',
                                  hintStyle: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.3),
                                    fontSize: 13,
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          GestureDetector(
                            onTap: _isLoading ? null : () => _sendMessage(_controller.text),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 46, height: 46,
                              decoration: BoxDecoration(
                                gradient: _isLoading ? null : LiquidGlass.primaryGradient,
                                color: _isLoading ? Colors.white.withValues(alpha: 0.07) : null,
                                borderRadius: BorderRadius.circular(23),
                                boxShadow: _isLoading
                                    ? null
                                    : LiquidGlass.glowShadow(LiquidGlass.accentPrimary, blur: 16),
                              ),
                              child: Icon(
                                _isLoading ? Icons.hourglass_empty : Icons.send_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble({required String content, required bool isUser}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            Container(
              width: 32, height: 32,
              decoration: BoxDecoration(
                gradient: LiquidGlass.primaryGradient,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.smart_toy, color: Colors.white, size: 16),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft:     const Radius.circular(18),
                topRight:    const Radius.circular(18),
                bottomLeft:  Radius.circular(isUser ? 18 : 4),
                bottomRight: Radius.circular(isUser ? 4 : 18),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: isUser
                        ? LiquidGlass.primaryGradient
                        : null,
                    color: isUser ? null : Colors.white.withValues(alpha: 0.07),
                    borderRadius: BorderRadius.only(
                      topLeft:     const Radius.circular(18),
                      topRight:    const Radius.circular(18),
                      bottomLeft:  Radius.circular(isUser ? 18 : 4),
                      bottomRight: Radius.circular(isUser ? 4 : 18),
                    ),
                    border: isUser
                        ? null
                        : Border.all(color: Colors.white.withValues(alpha: 0.10)),
                    boxShadow: isUser
                        ? LiquidGlass.glowShadow(LiquidGlass.accentPrimary, intensity: 0.25, blur: 16)
                        : null,
                  ),
                  child: _buildMessageContent(content),
                ),
              ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 8),
            Container(
              width: 32, height: 32,
              decoration: BoxDecoration(
                color: LiquidGlass.accentPrimary.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.person, color: Colors.white70, size: 16),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMessageContent(String content) {
    final lines = content.split('\n');
    final spans = <InlineSpan>[];

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      if (i > 0) spans.add(const TextSpan(text: '\n'));

      if (line.startsWith('•') || line.startsWith('-')) {
        spans.add(TextSpan(
          text: line,
          style: const TextStyle(color: Colors.white, height: 1.5),
        ));
      } else {
        final parts = line.split('**');
        for (int j = 0; j < parts.length; j++) {
          spans.add(TextSpan(
            text: parts[j],
            style: TextStyle(
              color: Colors.white,
              fontWeight: j.isOdd ? FontWeight.bold : FontWeight.normal,
              height: 1.5,
            ),
          ));
        }
      }
    }

    return RichText(
      text: TextSpan(
        style: const TextStyle(fontSize: 14, color: Colors.white, height: 1.5),
        children: spans,
      ),
    );
  }

  Widget _buildLoadingBubble() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(
              gradient: LiquidGlass.primaryGradient,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.smart_toy, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 8),
          GlassContainer(
            borderRadius: 18,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            blurSigma: 10,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDot(0),
                const SizedBox(width: 5),
                _buildDot(1),
                const SizedBox(width: 5),
                _buildDot(2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 600 + index * 200),
      builder: (context, value, child) {
        return Container(
          width: 8, height: 8,
          decoration: BoxDecoration(
            color: Color.lerp(
              LiquidGlass.accentPrimary.withValues(alpha: 0.3),
              LiquidGlass.accentPrimary,
              value,
            ),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      },
    );
  }
}
