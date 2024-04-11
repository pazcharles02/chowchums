import 'package:bubble/bubble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../constants/constants.dart';
import '../models/message.dart';
import '../tcp_bloc/tcp_bloc.dart';

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

  Future<void> uploadChatLog(List<Message> chatToUpdate) async {
    try {
      await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.userId)
            .update({"chatLog.users.$_IDChatting.messages": []});

      for (var messageCounter = 0; messageCounter < chatToUpdate.length; messageCounter++) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.userId)
            .update({"chatLog.users.$_IDChatting.messages":
        FieldValue.arrayUnion([{
          "DateTime": chatToUpdate[messageCounter].timestamp.toString(),
          "Sender": chatToUpdate[messageCounter].sender.index.toString(),
          "message": chatToUpdate[messageCounter].message}])
        });
      }
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
          var chatLogs;
          var chatUsers = [];
          try {
            chatLogs = snapshot.data!.get('chatLog');
            chatUsers = chatLogs["users_list"];
          } catch (e) {
            return Scaffold(
              appBar: AppBar(
                title: Text("No chats, go match with some other users first!"),
              ),
            );
          }
          return Scaffold(
            appBar: AppBar(),
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
                          var imageURL = chatLogs["users"][chatUsers[index]]["profileImageUrl"];
                          return InkWell(
                              onTap: () {
                                _IDChatting = "${chatUsers[index]}";
                                _tcpBloc!.add(
                                    Connect(
                                        host: Constants.chatServerAddress,
                                        port: 8212
                                    )
                                );
                                var initializedMessages = <Message>[];
                                if (chatLogs["users"][_IDChatting]["messages"] != null) {
                                  var dbMessages = chatLogs["users"][_IDChatting]["messages"];
                                  print(dbMessages);
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
                                    Text(chatLogs["users"][chatUsers[index]]["displayName"]),
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
                      AppBar(
                        title: Text("${chatLogs["users"][_IDChatting]["displayName"]}"),
                      ),
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
                          print(tcpState.getMessages());
                          await uploadChatLog(tcpState.getMessages());
                          _tcpBloc!.add(Disconnect());
                          setState(() {

                          });
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

