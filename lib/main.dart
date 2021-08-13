import 'package:flutter/material.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

void main() async {
  final client = StreamChatClient(
    'b67pax5b2wdq',
    logLevel: Level.INFO,
  );

  await client.connectUser(
    User(id: 'tutorial-flutter'),
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoidHV0b3JpYWwtZmx1dHRlciJ9.S-MJpoSwDiqyXpUURgO5wVqJ4vKlIVFLSEyrFYCOE1c',
  );

  runApp(
    MyApp(
      client: client,
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({
    Key? key,
    required this.client,
  }) : super(key: key);

  final StreamChatClient client;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      builder: (context, child) => StreamChat(
        client: client,
        child: child,
      ),
      home: const ChannelListPage(),
    );
  }
}

class ChannelListPage extends StatelessWidget {
  const ChannelListPage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ChannelsBloc(
        child: ChannelListView(
          filter: Filter.in_(
            'members',
            [StreamChat.of(context).user!.id],
          ),
          channelPreviewBuilder: _channelPreviewBuilder,
          sort: [SortOption('last_message_at')],
          pagination: const PaginationParams(
            limit: 20,
          ),
          channelWidget: const ChannelPage(),
        ),
      ),
    );
  }

  Widget _channelPreviewBuilder(BuildContext context, Channel channel) {
    final lastMessage = channel.state?.messages.reversed.firstWhere(
      (message) => !message.isDeleted,
    );

    final subtitle = lastMessage == null ? 'nothing yet' : lastMessage.text!;
    final opacity = (channel.state?.unreadCount ?? 0) > 0 ? 1.0 : 0.5;

    return ListTile(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => StreamChannel(
              channel: channel,
              child: const ChannelPage(),
            ),
          ),
        );
      },
      leading: ChannelAvatar(
        channel: channel,
      ),
      title: ChannelName(
        textStyle:
            StreamChatTheme.of(context).channelPreviewTheme.title!.copyWith(
                  color: StreamChatTheme.of(context)
                      .colorTheme
                      .textHighEmphasis
                      .withOpacity(opacity),
                ),
      ),
      subtitle: Text(subtitle),
      trailing: channel.state!.unreadCount > 0
          ? CircleAvatar(
              radius: 10,
              child: Text(channel.state!.unreadCount.toString()),
            )
          : const SizedBox(),
    );
  }
}

class ChannelPage extends StatelessWidget {
  const ChannelPage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const ChannelHeader(),
      body: Column(
        children: <Widget>[
          Expanded(
            child: MessageListView(
              threadBuilder: (_, parentMessage) => ThreadPage(
                parent: parentMessage,
              ),
            ),
          ),
          const MessageInput(),
        ],
      ),
    );
  }
}

class ThreadPage extends StatelessWidget {
  const ThreadPage({
    Key? key,
    this.parent,
  }) : super(key: key);

  final Message? parent;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ThreadHeader(
        parent: parent!,
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: MessageListView(
              parentMessage: parent,
            ),
          ),
          MessageInput(
            parentMessage: parent,
          ),
        ],
      ),
    );
  }
}

