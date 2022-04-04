import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FuckRemoteControl',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const RemotePage(title: '废柴控制器'),
    );
  }
}

class RemotePage extends StatefulWidget {
  const RemotePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<RemotePage> createState() => _RemotePageState();
}

class _RemotePageState extends State<RemotePage> {
  final _iconSize = 50.0;
  final _iconPadding = 10.0;
  final _controller = TextEditingController();
  var _baseUrl = '';
  final _dio = Dio();

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((prefs) {
      var remoteUrl = prefs.getString('remote') ?? '';
      _baseUrl = remoteUrl;
      _controller.value = TextEditingValue(text: remoteUrl);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 28.0, vertical: 10.0),
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'remote server eg. http://192.168.1.100:7389',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: (text) async {
                var prefs = await SharedPreferences.getInstance();
                prefs.setString('remote', text);
                _baseUrl = text;
              },
            ),
          ),
          Row(
            children: [
              _buildIcon(Icons.skip_previous, onPressed: () async {
                try {
                  await request(Cmd.Previous);
                } catch (e) {
                  showErr(e.toString());
                }
              }),
              _buildIcon(Icons.play_arrow, onPressed: () async {
                try {
                  await request(Cmd.PlayPause);
                } catch (e) {
                  showErr(e.toString());
                }
              }),
              _buildIcon(Icons.skip_next, onPressed: () async {
                try {
                  await request(Cmd.Next);
                } catch (e) {
                  showErr(e.toString());
                }
              }),
              _buildIcon(Icons.stop, onPressed: () async {
                try {
                  await request(Cmd.Stop);
                } catch (e) {
                  showErr(e.toString());
                }
              }),
              _buildIcon(Icons.add_box, onPressed: () async {
                try {
                  await request(Cmd.VolumeUp);
                } catch (e) {
                  showErr(e.toString());
                }
              }),
              _buildIcon(Icons.indeterminate_check_box, onPressed: () async {
                try {
                  await request(Cmd.VolumeDown);
                } catch (e) {
                  showErr(e.toString());
                }
              })
            ],
            mainAxisAlignment: MainAxisAlignment.center,
          ),
        ],
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
      ),
    );
  }

  Widget _buildIcon(IconData iconData, {VoidCallback? onPressed}) {
    return Padding(
      padding: EdgeInsets.all(_iconPadding),
      child: IconButton(
        onPressed: onPressed,
        iconSize: _iconSize,
        icon: Icon(
          iconData,
        ),
      ),
    );
  }

  Future<void> request(Cmd cmd) async {
    await _dio.get('$_baseUrl/media', queryParameters: {'cmd': cmd.name});
  }

  void showErr(String msg) {
    AwesomeDialog(
      context: context,
      animType: AnimType.SCALE,
      headerAnimationLoop: false,
      dialogType: DialogType.INFO,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            msg,
            style: const TextStyle(fontSize: 18),
          ),
        ),
      ),
    ).show();
  }
}

enum Cmd {
  PlayPause,
  Stop,
  Next,
  Previous,
  VolumeUp,
  VolumeDown,
  VolumeMute,
}
