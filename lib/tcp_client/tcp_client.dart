import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chowchums/tcp_client/pages/main_page.dart';
import 'tcp_bloc/tcp_bloc.dart';

class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);

  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<TcpBloc>(create: (context) => TcpBloc()),
      ],
      child: const MaterialApp(
        home: MainPage(),
      ),
    );
  }
}