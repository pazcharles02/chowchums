part of 'tcp_bloc.dart';


@immutable
abstract class TcpEvent {}

/// Represents a request for a connection to a server.
class Connect extends TcpEvent {
  /// The host of the server to connect to.
  final dynamic host;
  /// The port of the server to connect to.
  final int port;

  Connect({required this.host, required this.port})
      : assert(host != null);

  @override
  String toString() => '''Connect {
    host: $host,
    port: $port
  }''';
}
//
// class AddName extends TcpEvent {
//   final dynamic name;
//
//   AddName({required this.name})
//     : assert(name != null);
//
//   @override
//   String toString() => '''AddName {
//     name: $name
//   }''';
// }

/// Represents a request to disconnect from the server or abort the current connection request.
class Disconnect extends TcpEvent {
  @override
  String toString() => 'Disconnect { }';
}

/// Represents a socket error.
class ErrorOccured extends TcpEvent {
  @override
  String toString() => '''ErrorOccured { }''';
}

/// Represents the event of an incoming message from the TCP server.
class MessageReceived extends TcpEvent {
  final Message message;

  MessageReceived({required this.message});

  @override
  String toString() => '''MessageReceived {
    message: $message,
  }''';
}

/// Represents a request to send a message to the TCP server.
class SendMessage extends TcpEvent {
  /// The message to be sent to the TCP server.
  final String message;
  final int nickLength;

  SendMessage({required this.message, required this.nickLength});

  @override
  String toString() => 'SendMessage { }';
}

class ConnectHost extends TcpEvent {
  /// The message to be sent to the TCP server.
  final String message;

  ConnectHost({required this.message});

  @override
  String toString() => 'ConnectHost { }';
}