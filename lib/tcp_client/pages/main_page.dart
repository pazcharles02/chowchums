import 'package:bubble/bubble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../constants/constants.dart';
import '../models/message.dart';
import '../tcp_bloc/tcp_bloc.dart';
import 'about_page.dart';
// import '../models/message.dart';
// import '../utils/validators.dart';
// import 'package:bubble/bubble.dart';
// import 'package:chowchums/constants/constants.dart';

class MainPage extends StatefulWidget {
  final String userId;
  const MainPage({Key? key, required this.userId}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  TcpBloc? _tcpBloc;
  TextEditingController? _nameChattingController;
  // TextEditingController? _nickEditingController;

  // TextEditingController? _hostEditingController;
  // TextEditingController? _portEditingController;
  TextEditingController? _chatTextEditingController;

  @override
  void initState() {
    super.initState();
    _tcpBloc = BlocProvider.of<TcpBloc>(context);

    // _nameChattingController = TextEditingController(text: "Andy");
    // _hostEditingController = new TextEditingController(text: '127.0.0.1');
    // _portEditingController = new TextEditingController(text: '6666');
    // _nickEditingController = TextEditingController(text: 'John');
    _chatTextEditingController = TextEditingController(text: '');

    _chatTextEditingController!.addListener(() {
      setState(() {

      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users')
          .doc(widget.userId)
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Text('Error fetching data');
        } else {
          final displayName = snapshot.data!.get('displayName');
          var chatLogs = snapshot.data!.get('chatLog');
          var chatUsers = chatLogs[0]["users_list"];
          return Scaffold(
            appBar: AppBar(
              title: Text("Chats of $displayName!"),
              actions: [
                IconButton(
                  icon: const Icon(Icons.info_outline),
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (BuildContext context) {
                          return const AboutPage();
                        }
                    ));
                  },
                )
              ],
            ),
            body: BlocConsumer<TcpBloc, TcpState>(
              bloc: _tcpBloc,
              listener: (BuildContext context, TcpState tcpState) {
                if (tcpState.connectionState ==
                    SocketConnectionState.Connected) {
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar();
                } else
                if (tcpState.connectionState == SocketConnectionState.Failed) {
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(
                      SnackBar(
                        content: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Connection failed"),
                            Icon(Icons.error)
                          ],
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                }
              },
              builder: (context, tcpState) {
                if (tcpState.connectionState == SocketConnectionState.None ||
                    tcpState.connectionState == SocketConnectionState.Failed) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8.0),
                    child: ListView.builder(
                        itemCount: chatUsers.length,
                        shrinkWrap: true,
                        itemBuilder: (BuildContext context, int index) {
                          var imageURL = chatLogs[0]["users"][0][chatUsers[index]]["profileImageUrl"];
                          return InkWell(
                            onTap: () {
                              _tcpBloc!.add(
                                  Connect(
                                      host: Constants.chatServerAddress,
                                      // port: int.parse(_portEditingController!.text)
                                      port: 8212
                                  )
                              );
                              print("Connecting to: ${Constants
                                  .chatServerAddress}");
                              print("sending nickname to server");
                              _tcpBloc!.add(
                                  ConnectHost(
                                      message: "/nick  ${widget.userId}"
                                  )
                              );
                              print("nick: ${widget.userId}");
                            },
                            child: Card(
                              margin: EdgeInsets.all(7.5),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 100,
                                    height: 100,
                                    child: imageURL != null
                                        ? Image.network(imageURL, fit: BoxFit.cover)
                                        : Image.asset('assets/images/default_picture.png',
                                        fit: BoxFit.cover),
                                  ),
                                  const Padding(
                                      padding: EdgeInsets.only(left: 5.0)
                                  ),
                                  Text(chatLogs[0]["users"][0][chatUsers[index]]["displayName"]),
                                ],
                              ),
                            )
                          );
                        }
                    ),
                  );
                } else if (tcpState.connectionState ==
                    SocketConnectionState.Connecting) {
                  return Center(
                    child: Column(
                      children: <Widget>[
                        CircularProgressIndicator(),
                        Text('Connecting...'),
                        ElevatedButton(
                          child: Text('Abort'),
                          onPressed: () {
                            _tcpBloc!.add(Disconnect());
                          },
                        )
                      ],
                    ),
                  );
                } else if (tcpState.connectionState ==
                    SocketConnectionState.Connected) {
                  print("adding messages to initial state");

                  return Column(
                    children: [
                      Expanded(
                        child: Container(
                          child: ListView.builder(
                              itemCount: tcpState.messages.length,
                              itemBuilder: (context, idx) {
                                Message m = tcpState.messages[idx];
                                return Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Bubble(
                                    child: Text(m.message),
                                    alignment: m.sender == Sender.Client
                                        ? Alignment.centerRight
                                        : Alignment.centerLeft,
                                  ),
                                );
                              }
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                decoration: InputDecoration(
                                    hintText: 'Message'
                                ),
                                controller: _chatTextEditingController,
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.send),
                              onPressed: _chatTextEditingController!.text
                                  .isEmpty
                                  ? null
                                  : () {
                                _tcpBloc!.add(SendMessage(
                                    message: "/msg ${_nameChattingController!
                                        .text} ${_chatTextEditingController!
                                        .text}",
                                    nickLength: _nameChattingController!.text
                                        .length));
                                _chatTextEditingController!.text = '';
                              },
                            )
                          ],
                        ),
                      ),
                      ElevatedButton(
                        child: Text('Disconnect'),
                        onPressed: () {
                          _tcpBloc!.add(Disconnect());
                        },
                      ),
                    ],
                  );
                } else {
                  return Container();
                }
              },
            ),
          );
        }
      }
    );
}}