abstract class Constants {
  static const String chatServerAddress = String.fromEnvironment(
    'CHOWCHUMS_CHAT_SERVER_IP',
    defaultValue: ''
  );
}