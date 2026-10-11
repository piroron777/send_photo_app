import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Send Photo',
      home: const SendPhotoPage(),
    );
  }
}

class SendPhotoPage extends StatefulWidget {
  const SendPhotoPage({super.key});

  @override
  State<SendPhotoPage> createState() => _SendPhotoPageState();
}

class _SendPhotoPageState extends State<SendPhotoPage> {
  bool _sending = false;
  String _status = '';

  Future<void> _sendPhoto() async {
    final picker = ImagePicker();

    // 背面カメラで撮影
    final image = await picker.pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.rear,
    );

    if (image == null) {
      setState(() {
        _status = 'キャンセルされました';
      });
      return;
    }

    setState(() {
      _sending = true;
      _status = '送信中...';
    });

    final bytes = await image.readAsBytes();

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('http://192.168.2.101:5122/Upload/photo'),
    );

    request.files.add(
      http.MultipartFile.fromBytes(
        'file',
        bytes,
        filename: 'photo.jpg',
      ),
    );

    try {
      final response = await request.send();
      setState(() {
        _sending = false;
        _status = 'ステータスコード: ${response.statusCode}';
      });
    } catch (e) {
      setState(() {
        _sending = false;
        _status = 'エラー: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('写真送信')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _sending ? null : _sendPhoto,
              child: const Text('写真を撮って送信'),
            ),
            const SizedBox(height: 16),
            Text(_status),
          ],
        ),
      ),
    );
  }
}
