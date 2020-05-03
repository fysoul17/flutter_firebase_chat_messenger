import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:firebase_chat_messenger/firebase_chat_messenger.dart';
import 'package:bubble/bubble.dart';
import 'package:intl/intl.dart';

class ChatView extends StatefulWidget {
  const ChatView({
    Key key,
    this.chatGroupData,
    this.mySenderId,
    this.chatBubbleMaxWidth,
  }) : super(key: key);

  final ChatGroup chatGroupData;
  final String mySenderId;
  final double chatBubbleMaxWidth;

  @override
  _ChatViewState createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  ScrollController _scrollController;
  int _prevListCount = 0;

  @override
  void initState() {
    print("[[[[ Init ]]]] Chat View");

    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_handleScrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_handleScrollListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print("[[[[ Build ]]]] Chat View");

    TextStyle defaultTextStyle = Theme.of(context).textTheme.body1;

    const BubbleStyle styleSomebody = BubbleStyle(
      nip: BubbleNip.leftTop,
      color: Colors.white,
      elevation: 2,
      margin: const BubbleEdges.only(top: 10.0, right: 0.0),
      padding: const BubbleEdges.all(8),
      alignment: Alignment.topLeft,
    );

    const BubbleStyle styleMe = BubbleStyle(
      nip: BubbleNip.rightTop,
      color: Color.fromARGB(255, 225, 255, 199),
      elevation: 2,
      margin: const BubbleEdges.only(top: 10.0, left: 0.0),
      padding: const BubbleEdges.all(8),
      alignment: Alignment.topRight,
    );

    return ChatMessages(
      groupId: widget.chatGroupData.id,
      builder: (context, messages, child) {
        if (messages == null) {
          return Container();
        } else {
          if (messages.length < 1) {
            return Container();
          } else {
            List<ChatMessage> chats = messages.reversed.toList();

            Widget listView = ListView(
              reverse: true,
              shrinkWrap: true,
              controller: _scrollController,
              padding: EdgeInsets.all(8.0),
              children: [
                // Bubble(
                //   alignment: Alignment.center,
                //   color: Color.fromARGB(255, 212, 234, 244),
                //   elevation: 2,
                //   margin: BubbleEdges.only(top: 8.0),
                //   child: Text('TODAY', style: TextStyle(fontSize: 13)),
                // ),
                if (chats.length > 0)
                  ...List.generate(chats.length, (index) {
                    bool isMyMsg = chats[index].senderId == widget.mySenderId;

                    Widget infoWidget;
                    if (chats[index].sendAt == null) {
                      infoWidget = Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: SizedBox(
                            width: 10,
                            height: 10,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            )),
                      );
                    } else {
                      String dateString = DateFormat("jm").format(chats[index].sendAt.toDate());
                      int readCount = widget.chatGroupData.participantsData.length - chats[index].readParticipants.length;
                      infoWidget = Column(
                        crossAxisAlignment: isMyMsg ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                        children: <Widget>[
                          if (readCount > 0)
                            Text(
                              "$readCount",
                              style: defaultTextStyle.copyWith(fontSize: 13, color: Colors.blueAccent),
                            ),
                          Text(
                            dateString,
                            style: defaultTextStyle.copyWith(fontSize: 11),
                          ),
                        ],
                      );
                    }

                    Widget bubble = Bubble(
                      style: isMyMsg ? styleMe : styleSomebody,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: widget.chatBubbleMaxWidth),
                        child: Text(
                          chats[index].message,
                          style: defaultTextStyle.copyWith(fontSize: 16),
                        ),
                      ),
                    );

                    return Row(
                      mainAxisAlignment: isMyMsg ? MainAxisAlignment.end : MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        if (isMyMsg) infoWidget,
                        bubble,
                        if (!isMyMsg) infoWidget,
                      ],
                    );
                  }),
              ],
            );

            // 현재 위치가 가장 하단이 아닐 경우에 스크롤 위치 유지를 위함. (+ 메시지가 추가 됐을 경우만)
            if (_scrollController.hasClients && _scrollController.offset != 0 && _prevListCount != chats.length) {
              _scrollController.jumpTo(_scrollController.offset + 45);
              _prevListCount = chats.length;
            }

            return Align(alignment: Alignment.topCenter, child: listView);
          }
        }
      },
    );
  }

  _handleScrollListener() {
    //print("pixels: ${widget.scrollController.position.pixels}");
    //print("maxScrollExtent: ${widget.scrollController.position.maxScrollExtent}");
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      //_loadPrevChats();
    }
  }
}
