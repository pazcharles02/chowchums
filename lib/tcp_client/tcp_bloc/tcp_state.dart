part of 'tcp_bloc.dart';

enum SocketConnectionState {
  Connecting,
  Disconnecting,
  Connected,
  Failed,
  None
}

@immutable
class TcpState {
  final SocketConnectionState connectionState;
  final List<Message> messages;

  const TcpState({
    required this.connectionState,
    required this.messages,
  });

  factory TcpState.initial() {
    return const TcpState(
        connectionState: SocketConnectionState.None,
        messages: <Message>[]
    );
  }

  TcpState copywith({
    SocketConnectionState? connectionState,
    List<Message>? messages,
  }) {
    return TcpState(
      connectionState: connectionState ?? this.connectionState,
      messages: messages ?? this.messages,
    );
  }

  TcpState copyWithNewMessage({required Message message}) {
    return TcpState(
      connectionState: connectionState,
      messages: List.from(messages)..add(message),
    );
  }

  TcpState initializeMessages({required List<Message> messages}) {
    return TcpState(
      connectionState: connectionState,
      messages: messages,
    );
  }

  // String messagesToString() {
  //   var messagesAsString = "[";
  //   for (var messageCounter = 0; messageCounter < messages.length; messageCounter++) {
  //     messagesAsString += "{";
  //     messagesAsString += "DateTime: ${messages[messageCounter].timestamp.toString()}, ";
  //     messagesAsString += "Sender: ${messages[messageCounter].sender.index}, ";
  //     messagesAsString += "message: ${messages[messageCounter].message}}";
  //     if (messages.length - messageCounter > 1) {
  //       messagesAsString += ", ";
  //     }
  //   }
  //   messagesAsString += "]";
  //   return messagesAsString;
  // }
  //
  List<Message> getMessages() {
    return messages;
  }
  // [{Sender: 0, message: hi!, DateTime: 2024-04-08 01:46:05.865433}, {Sender: 1, message: bye!, DateTime: 2024-04-08 02:46:05.865433}]
}