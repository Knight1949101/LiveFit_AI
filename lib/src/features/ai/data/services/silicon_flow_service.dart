import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/config/app_secrets.dart';
import '../../../../core/services/log_service.dart';
import '../../domain/models/chat_message.dart';
import '../../domain/services/ai_service.dart';

class SiliconFlowService implements AiService {
  static const String _baseUrl = 'https://api.siliconflow.cn/v1';
  // 使用 Qwen2.5-7B-Instruct 作为默认模型，因为它通常比较稳定且便宜
  // 用户可以在此处更改为 'deepseek-ai/DeepSeek-V3' 等其他模型
  static const String _model = 'deepseek-ai/DeepSeek-V3'; 

  @override
  Future<String> sendMessage(List<ChatMessage> history, String message) async {
    final messages = _buildMessages(history, message);

    try {
      log.info('Sending request to SiliconFlow API...');
      final response = await http.post(
        Uri.parse('$_baseUrl/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${AppSecrets.siliconFlowToken}',
        },
        body: jsonEncode({
          'model': _model,
          'messages': messages,
          'stream': false,
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        if (data['choices'] != null && (data['choices'] as List).isNotEmpty) {
           final content = data['choices'][0]['message']['content'] as String;
           return content;
        } else {
           throw Exception('Empty response choices');
        }
      } else {
        log.error('API Error: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to get response: ${response.statusCode}');
      }
    } catch (e) {
      log.error('Exception during AI request: $e');
      throw Exception('Error communicating with AI: $e');
    }
  }

  @override
  Stream<String> streamMessage(List<ChatMessage> history, String message) async* {
    // 暂时回退到非流式调用，但在 Stream 中返回
    // 未来可在此处实现 SSE 解析
    try {
      final content = await sendMessage(history, message);
      yield content;
    } catch (e) {
      yield 'Error: $e';
    }
  }

  List<Map<String, String>> _buildMessages(List<ChatMessage> history, String currentMessage) {
    final List<Map<String, String>> messages = [];
    
    // System Prompt
    messages.add({
      'role': 'system',
      'content': '你是 LifeFit AI，一个专业的日程管理和健身助手。请用中文回答用户的问题，语气亲切自然，专注于帮助用户规划日程和提供运动建议。',
    });

    // History (限制最近 10 条以节省 Token)
    final recentHistory = history.length > 10 
        ? history.sublist(history.length - 10) 
        : history;

    for (var msg in recentHistory) {
      messages.add({
        'role': msg.type == MessageType.user ? 'user' : 'assistant',
        'content': msg.content,
      });
    }

    // Current Message
    messages.add({
      'role': 'user',
      'content': currentMessage,
    });

    return messages;
  }
}
