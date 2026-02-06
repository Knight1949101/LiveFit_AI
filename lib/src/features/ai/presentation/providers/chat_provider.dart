import 'package:flutter/material.dart';
import '../../domain/models/chat_message.dart';
import '../../domain/services/ai_service.dart';

class ChatProvider extends ChangeNotifier {
  final AiService _aiService;
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;

  ChatProvider(this._aiService);

  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get isLoading => _isLoading;

  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty) return;

    final userMessage = ChatMessage.user(content);
    _messages.add(userMessage);
    _isLoading = true;
    notifyListeners();

    try {
      // 传递历史消息给 Service (不包括刚刚添加的当前消息，因为 Service 内部会构建)
      // 或者 Service 接口设计是传 History + Current Message
      // 根据之前的实现: sendMessage(List<ChatMessage> history, String message)
      // history 应该是之前的消息
      final history = _messages.sublist(0, _messages.length - 1);
      final response = await _aiService.sendMessage(history, content);
      
      final aiMessage = ChatMessage.ai(response);
      _messages.add(aiMessage);
    } catch (e) {
      final errorMessage = ChatMessage.ai('抱歉，我暂时无法回答。请检查网络或 Token 设置。\n错误详情: $e', isError: true);
      _messages.add(errorMessage);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  void clearHistory() {
    _messages.clear();
    notifyListeners();
  }
}
