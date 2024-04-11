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
              title: Text("Welcome to your chats, $displayName!"),
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

            // body: ListView.builder(
            //     itemBuilder: (BuildContext context, int index) {
            //       return GestureDetector(
            //           child: Column(
            //             mainAxisAlignment: MainAxisAlignment.center,
            //             children: [
            //               Text("${chatLogs[0]["users"][0]["${chatUsers[index]}"]}")
            //             ],
            //           ),
            //           onTap: () =>
            // ScaffoldMessenger
            //     .of(context)
            //     .showSnackBar(SnackBar(content:
            // ElevatedButton(child:
            //     Text('Connect'),
            // onPressed: isValidHost(_hostEditingController!.text) && isValidPort(_portEditingController!.text)
            //   ? () {
            //   onPressed: () {
            //     _tcpBloc!.add(
            //       Connect(
            //         host: Constants.chatServerAddress,
            //         // port: int.parse(_portEditingController!.text)
            //         port: 8212
            //       )
            // );
            // _tcpBloc!.add(
            //   AddName(
            //     name: _nameChattingController!.text
            //   )
            // );
            // print("Connecting to: ${Constants.chatServerAddress}");
            // print("sending nickname to server");
            // _tcpBloc!.add(
            //     ConnectHost(
            //         message: "/nick  $displayName"
            //     )
            // );
            // print("nick: $displayName");

            // }
            // ),
            // ))
            // );
            //                 },
            //                 itemCount: chatUsers.length));
            //       }
            //     },
            //   );
            // }

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
                          return Card(
                            margin: EdgeInsets.all(10.0),
                            child: Column(
                              children: [

                                Text(chatUsers[index]),
                              ]
                            )
                            );
                          // return Column(
                          //   children: [
                          //     GestureDetector(
                          //       onTap: () {
                          //             _tcpBloc!.add(
                          //                 Connect(
                          //                     host: Constants.chatServerAddress,
                          //                     // port: int.parse(_portEditingController!.text)
                          //                     port: 8212
                          //                 )
                          //             );
                          //             print("Connecting to: ${Constants
                          //                 .chatServerAddress}");
                          //             print("sending nickname to server");
                          //             _tcpBloc!.add(
                          //                 ConnectHost(
                          //                     message: "/nick  $displayName"
                          //                 )
                          //             );
                          //             print("nick: $displayName");
                          //           },
                          //       child:
                          //         FractionallySizedBox(
                          //           widthFactor: 1,
                          //           heightFactor: 0.18,
                          //           child: Container(
                          //               child: Text("${chatLogs[0]["users"][0]["${chatUsers[index]}"]}")
                          //           ),
                          //         ),
                          //     )
                          //   ],
                          // );


                        }
                        // TextFormField(
                        //   controller: _hostEditingController,
                        //   autovalidateMode : AutovalidateMode.always,
                        //   validator: (str) => isValidHost(str) ? null : 'Invalid hostname',
                        //   decoration: InputDecoration(
                        //     helperText: 'The ip address or hostname of the TCP server',
                        //     hintText: 'Enter the address here, e. g. 10.0.2.2',
                        //   ),
                        // ),
                        // TextFormField(
                        //   controller: _nameChattingController,
                        //   decoration: InputDecoration(
                        //     helperText: 'The name of the user you\'d like to chat with',
                        //     hintText: 'Enter the name here, e. g. Andy',
                        //   ),
                        // ),
                        // TextFormField(
                        //   controller: _portEditingController,
                        //   autovalidateMode : AutovalidateMode.always,
                        //   validator: (str) => isValidPort(str) ? null : 'Invalid port',
                        //   decoration: InputDecoration(
                        //     helperText: 'The port the TCP server is listening on',
                        //     hintText: 'Enter the port here, e. g. 8000',
                        //   ),
                        // ),
                        // TextFormField(
                        //   controller: _nickEditingController,
                        //   decoration: InputDecoration(
                        //     helperText: 'The nickname of the client joining the TCP server',
                        //     hintText: 'Enter the nickname here, e. g. Tejinder',
                        //   ),
                        // ),
                        // ElevatedButton(
                        //     child: Text('Connect'),
                        //     // onPressed: isValidHost(_hostEditingController!.text) && isValidPort(_portEditingController!.text)
                        //     //   ? () {
                        //     onPressed: () {
                        //       _tcpBloc!.add(
                        //           Connect(
                        //               host: Constants.chatServerAddress,
                        //               // port: int.parse(_portEditingController!.text)
                        //               port: 8212
                        //           )
                        //       );
                        //       // _tcpBloc!.add(
                        //       //   AddName(
                        //       //     name: _nameChattingController!.text
                        //       //   )
                        //       // );
                        //       print("Connecting to: ${Constants
                        //           .chatServerAddress}");
                        //       print("sending nickname to server");
                        //       _tcpBloc!.add(
                        //           ConnectHost(
                        //               message: "/nick  $displayName"
                        //           )
                        //       );
                        //       print("nick: $displayName");
                        //     }
                        // ),
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

class CardList extends StatelessWidget {
  final List<String> listData;

  CardList({required this.listData});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(10.0),
      child: Column(
        children: [
          ListTile(
            title: Text('List ${listData[0]}'),
          ),
          Divider(),
          ListView.builder(
            itemCount: listData.length,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(listData[index]),
              );
            },
          ),
        ],
      ),
    );
  }
}