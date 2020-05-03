import 'dart:ui' as UI;

import 'package:firebase_chat_messenger/firebase_chat_messenger.dart';
import 'package:flutter/material.dart';

class ChatInputField extends StatefulWidget {
  const ChatInputField({Key key, this.chatGroupData, this.mySenderId, this.focusNode}) : super(key: key);

  final ChatGroup chatGroupData;
  final String mySenderId;
  final FocusNode focusNode;

  @override
  _ChatInputFieldState createState() => _ChatInputFieldState();
}

class _ChatInputFieldState extends State<ChatInputField> {
  final GlobalKey _textFieldKey = GlobalKey();
  final TextEditingController _textEditingController = TextEditingController();
  final ScrollController _scrollController = ScrollController(keepScrollOffset: false);

  double _baseChatBarHeight = 50;
  int _numberOfLines = 1;

  @override
  void initState() {
    super.initState();
    print('>>> Init Chat input field');

    _textEditingController.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    final textPainter = TextPainter(
      textDirection: UI.TextDirection.ltr,
      text: TextSpan(
        text: _textEditingController.text,
      ),
    );

    final RenderBox renderBoxTextField = _textFieldKey.currentContext.findRenderObject();
    final sizeTextField = renderBoxTextField.size;

    textPainter.layout(
      minWidth: 0,
      maxWidth: sizeTextField.width - 35,
    );

    List<UI.LineMetrics> lines = textPainter.computeLineMetrics();
    setState(() {
      _numberOfLines = lines.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_numberOfLines > 4) _numberOfLines = 4;
    int extraHeight = (_numberOfLines - 1) * 18;

    return Container(
      color: Colors.grey[300],
      height: _baseChatBarHeight + extraHeight,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
            width: 40,
            height: _baseChatBarHeight - 20,
            child: RawMaterialButton(
              fillColor: Colors.grey[500],
              shape: CircleBorder(),
              child: Icon(Icons.add, color: Colors.white),
              onPressed: () {
                print("maxScrollExtent: ${_scrollController.position.maxScrollExtent}");
              },
            ),
          ),
          Expanded(
            child: Container(
              height: (_baseChatBarHeight - 15) + extraHeight,
              margin: const EdgeInsets.symmetric(vertical: 7.5),
              padding: const EdgeInsets.only(right: 10),
              color: Theme.of(context).brightness == Brightness.dark ? Colors.black54 : Colors.grey[300],
              child: Material(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18.0),
                  side: BorderSide(color: Colors.grey),
                ),
                //elevation: 1.0,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    SizedBox(width: 15),
                    Expanded(child: _buildChatTextField(context)),
                    SizedBox(width: 15),
                    // 채팅 전송 버튼.
                    Container(
                      width: 35,
                      height: 35,
                      child: FlatButton(
                        padding: EdgeInsets.zero,
                        color: Colors.grey,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          side: BorderSide(color: Colors.grey),
                        ),
                        child: Icon(Icons.arrow_upward, color: Colors.white, size: 25),
                        onPressed: () {
                          if (_textEditingController.text.length < 1) return;

                          ChatEngine.instance.sendChat(widget.mySenderId, widget.chatGroupData, _textEditingController.text);

                          _textEditingController.clear();
                        },
                      ),
                    ),
                    SizedBox(width: 5)
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatTextField(BuildContext context) {
    return TextField(
      key: _textFieldKey,
      controller: _textEditingController,
      focusNode: widget.focusNode,
      maxLines: 20,
      maxLength: 200,
      decoration: InputDecoration(
        hintText: "채팅 입력하기",
        border: InputBorder.none,
        isDense: true,
        counterText: "",
      ),
    );
  }
}
