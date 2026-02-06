import '../models/chat_message.dart';

abstract class AiService {
  /// 发送消息并获取回复
  Future<String> sendMessage(List<ChatMessage> history, String message);
  
  /// 发送消息并获取流式回复（可选实现）
  Stream<String> streamMessage(List<ChatMessage> history, String message);
}
