import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chowchums/tcp_client/pages/main_page.dart';
import 'tcp_bloc/tcp_bloc.dart';

class ChatPage extends StatefulWidget {
  final String userId;
  const ChatPage({Key? key, required this.userId}) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<TcpBloc>(create: (context) => TcpBloc()),
      ],
      child: MaterialApp(
        home: MainPage(userId: widget.userId),
      ),
    );
  }
}