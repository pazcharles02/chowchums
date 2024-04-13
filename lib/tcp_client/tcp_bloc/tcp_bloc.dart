import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:flutter/foundation.dart';
import 'package:chowchums/tcp_client/models/message.dart';

part 'tcp_event.dart';
part 'tcp_state.dart';

class TcpBloc extends Bloc<TcpEvent, TcpState> {
  Socket? _socket;
  StreamSubscription? _socketStreamSub;
  ConnectionTask<Socket>? _socketConnectionTask;

  TcpBloc() : super(TcpState.initial());

  @override
  Stream<TcpState> mapEventToState(
      TcpEvent event,
      ) async* {
    if (event is Connect) {
      yield* _mapConnectToState(event);
    } else if (event is Disconnect) {
      yield* _mapDisconnectToState();
    } else if (event is ErrorOccured) {
      yield* _mapErrorToState();
    } else if (event is MessageReceived) {
      if (event.message.message.length > 2) {
        yield state.copyWithNewMessage(message: Message(
          timestamp: event.message.timestamp,
          sender: event.message.sender,
          message: event.message.message.substring(30)
        ));
      }
    } else if (event is SendMessage) {
      yield* _mapSendMessageToState(event);
    } else if (event is ConnectHost) {
      yield* _connectHost(event);
    } else if (event is InitializeMessages) {
      yield* _initializeMessages(event);
    }
  }

  Stream<TcpState> _mapConnectToState(Connect event) async* {
    yield state.copywith(connectionState: SocketConnectionState.connecting);
    try {
      _socketConnectionTask = await Socket.startConnect(event.host, event.port);
      _socket = await _socketConnectionTask!.socket;

      _socketStreamSub = _socket!.asBroadcastStream().listen((event) {
        add(
            MessageReceived(
                message: Message(
                  message: String.fromCharCodes(event),
                  timestamp: DateTime.now(),
                  sender: Sender.server,
                )
            )
        );
      });
      // _socket!.handleError(() {
      //   this.add(ErrorOccured());
      // });

      yield state.copywith(connectionState: SocketConnectionState.connected);
    } catch (err) {
      yield state.copywith(connectionState: SocketConnectionState.failed);
    }
  }

  Stream<TcpState> _mapDisconnectToState() async* {
    try {
      yield state.copywith(connectionState: SocketConnectionState.disconnecting);
      _socketConnectionTask?.cancel();
      await _socketStreamSub?.cancel();
      await _socket?.close();
    } catch (ex) {
      print(ex);
    }
    yield state.copywith(connectionState: SocketConnectionState.none, messages: []);
  }

  Stream<TcpState> _mapErrorToState() async* {
    yield state.copywith(connectionState: SocketConnectionState.failed);
    await _socketStreamSub?.cancel();
    await _socket?.close();
  }

  Stream<TcpState> _mapSendMessageToState(SendMessage event) async* {
    if (_socket != null) {
      yield state.copyWithNewMessage(message: Message(
        message: event.message.substring(5 + event.nickLength),
        timestamp: DateTime.now(),
        sender: Sender.client,
      ));
      _socket!.writeln(event.message);
    }
  }

  Stream<TcpState> _connectHost(ConnectHost event) async* {
    if (_socket != null) {
      _socket!.writeln(event.message);
    }
  }

  Stream<TcpState> _initializeMessages(InitializeMessages event) async* {
    yield state.initializeMessages(messages: event.initializedMessages);
  }

  @override
  Future<void> close() {
    _socketStreamSub?.cancel();
    _socket?.close();
    return super.close();
  }
}