import 'package:bubble/bubble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../constants/constants.dart';
import '../models/message.dart';
import '../tcp_bloc/tcp_bloc.dart';
import 'about_page.dart';

class MainPage extends StatefulWidget {
  final String userId;
  const MainPage({Key? key, required this.userId}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  TcpBloc? _tcpBloc;
  String? _IDChatting;
  TextEditingController? _chatTextEditingController;

  @override
  void initState() {
    super.initState();
    _tcpBloc = BlocProvider.of<TcpBloc>(context);
    _chatTextEditingController = TextEditingController(text: '');
  }

  Future<void> _uploadChatLog(String chatLog) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .update({"chatLog": chatLog});
    } catch (e) {
      print("Error uploading chat logs: $e");
    }
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
          return const Text('Error fetching data');
        } else {
          final displayName = snapshot.data!.get('displayName');
          var chatLogs;
          try {
            chatLogs = snapshot.data!.get('chatLog');
          } catch (e) {
            return Scaffold(
              appBar: AppBar(
                title: Text("No chats, go match with some other users first!"),
              ),
            );
          }
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
                      .hideCurrentSnackBar();
                } else
                if (tcpState.connectionState == SocketConnectionState.Failed) {
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(
                      const SnackBar(
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
                                _IDChatting = "${chatUsers[index]}";
                                _tcpBloc!.add(
                                    Connect(
                                        host: Constants.chatServerAddress,
                                        // port: int.parse(_portEditingController!.text)
                                        port: 8212
                                    )
                                );
                                // print("Connecting to: ${Constants
                                //     .chatServerAddress}");
                                // print("sending nickname to server");
                                var initializedMessages = <Message>[];
                                if (chatLogs[0]["users"][0][_IDChatting]["messages"] != null) {
                                  var dbMessages = chatLogs[0]["users"][0][_IDChatting]["messages"];
                                  for (var message_counter = 0; message_counter < dbMessages.length; message_counter++) {
                                    var sender = Sender.Client;
                                    if (int.parse(dbMessages[message_counter]["Sender"].toString()) == 1) {
                                      sender = Sender.Server;
                                    }
                                    initializedMessages.add(Message(
                                      timestamp: DateTime.parse(dbMessages[message_counter]["DateTime"].toString()),
                                      sender: sender,
                                      message: dbMessages[message_counter]["message"].toString(),
                                    ));
                                  }
                                }
                                _tcpBloc!.add(InitializeMessages(initializedMessages: initializedMessages));
                                _tcpBloc!.add(
                                    ConnectHost(
                                        message: "/nick  ${widget.userId}"
                                    )
                                );
                                // print("nick: ${widget.userId}");
                              },
                              child: Card(
                                margin: const EdgeInsets.all(7.5),
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
                    child: ListView(
                      children: <Widget>[
                        const CircularProgressIndicator(),
                        const Text('Connecting...'),
                        ElevatedButton(
                          child: const Text('Abort'),
                          onPressed: () {
                            _tcpBloc!.add(Disconnect());
                          },
                        )
                      ],
                    ),
                  );
                } else if (tcpState.connectionState ==
                    SocketConnectionState.Connected) {
                  // print("adding messages to initial state");
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
                                    alignment: m.sender == Sender.Client
                                        ? Alignment.centerRight
                                        : Alignment.centerLeft,
                                    child: Text(m.message),
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
                                  controller: _chatTextEditingController,
                                )
                            ),
                            IconButton(
                              icon: const Icon(Icons.send),
                              onPressed:
                                // _chatTextEditingController!.text
                                //   .isEmpty
                                //   ? () {}
                                //   : () {
                                () {
                                if (_chatTextEditingController!.text != "") {
                                  _tcpBloc!.add(SendMessage(
                                      message: "/msg $_IDChatting ${_chatTextEditingController!
                                          .text}",
                                      nickLength: _IDChatting
                                      !.length));
                                  _chatTextEditingController!.text = '';
                                }
                              },
                            )
                          ],
                        ),
                      ),
                      ElevatedButton(
                        child: const Text('Disconnect'),
                        onPressed: () async {
                          // chatLogs[0]["users"][0][_IDChatting]["messages"]
                          // _uploadChatLog(chatLogs);
                          await _uploadChatLog(tcpState.messagesToString());
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

