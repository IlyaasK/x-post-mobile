import 'dart:io';
import 'package:flutter/material.dart';
import 'package:bubble/bubble.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pasteboard/pasteboard.dart';
import 'package:path_provider/path_provider.dart';
import '../services/x_service.dart';
import '../services/history_service.dart';
import '../models/message.dart';
import 'setup_screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}



class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  List<Message> _messages = [];
  final XService _xService = XService();
  final HistoryService _historyService = HistoryService();
  final ScrollController _scrollController = ScrollController();
  final List<File> _selectedMedia = [];
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final messages = await _historyService.loadMessages();
    setState(() {
      _messages = messages;
    });
    // Scroll to bottom after loading
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image != null) {
        setState(() {
          _selectedMedia.add(File(image.path));
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  Future<void> _pasteImage() async {
    try {
      final bytes = await Pasteboard.image;
      if (bytes != null) {
        final tempDir = await getTemporaryDirectory();
        final file = File('${tempDir.path}/pasted_${DateTime.now().millisecondsSinceEpoch}.png');
        await file.writeAsBytes(bytes);
        setState(() {
          _selectedMedia.add(file);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No image in clipboard')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error pasting image: $e')),
      );
    }
  }

  void _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty && _selectedMedia.isEmpty) return;

    if (_isUploading) return;

    setState(() => _isUploading = true);

    final newMessage = Message(
      text: text,
      timestamp: DateTime.now(),
      isSent: false,
      imagePaths: _selectedMedia.map((f) => f.path).toList(),
    );

    setState(() {
      _messages.add(newMessage);
      _controller.clear();
      _selectedMedia.clear(); // Clear immediately from UI input, but kept in message
    });
    
    _scrollToBottom();
    _historyService.saveMessages(_messages);

    try {
      List<String> mediaIds = [];
      if (newMessage.imagePaths.isNotEmpty) {
        for (var path in newMessage.imagePaths) {
          final id = await _xService.uploadMedia(File(path));
          mediaIds.add(id);
        }
      }

      await _xService.postTweet(text, mediaIds: mediaIds);
      
      setState(() {
        newMessage.isSent = true;
      });
      _historyService.saveMessages(_messages);
    } catch (e) {
      setState(() {
        newMessage.isError = true;
      });
      _historyService.saveMessages(_messages);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to post: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('x-chat'),
        backgroundColor: const Color(0xFF1E1E1E),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const SetupScreen()),
              );
            },
          ),
        ],
      ),
      body: Container(
        color: const Color(0xFF121212), // Signal Dark BG
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final msg = _messages[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                    child: Bubble(
                      alignment: Alignment.topRight,
                      nip: BubbleNip.rightTop,
                      color: const Color(0xFF2C6BED), // Signal Blue
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (msg.imagePaths.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Column(
                                children: msg.imagePaths.map((path) {
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 4.0),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.file(File(path), height: 150, fit: BoxFit.cover),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          if (msg.text.isNotEmpty)
                            Text(
                              msg.text,
                              style: const TextStyle(fontSize: 16, color: Colors.white),
                            ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                DateFormat('HH:mm').format(msg.timestamp),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white.withOpacity(0.7),
                                ),
                              ),
                              const SizedBox(width: 4),
                              if (msg.isError)
                                const Icon(Icons.error, size: 16, color: Colors.redAccent)
                              else
                                Icon(
                                  Icons.done_all,
                                  size: 16,
                                  color: msg.isSent ? Colors.white : Colors.white54,
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            _buildInputArea(),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      color: const Color(0xFF1E1E1E),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_selectedMedia.isNotEmpty)
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _selectedMedia.length,
                itemBuilder: (context, index) {
                  return Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Image.file(_selectedMedia[index]),
                      ),
                      Positioned(
                        right: 0,
                        top: 0,
                        child: IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () {
                            setState(() {
                              _selectedMedia.removeAt(index);
                            });
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.attach_file, color: Colors.grey), // Pin icon
                onPressed: () => _pickImage(ImageSource.gallery),
              ),
              IconButton(
                icon: const Icon(Icons.camera_alt, color: Colors.grey),
                onPressed: () => _pickImage(ImageSource.camera),
              ),
              IconButton(
                icon: const Icon(Icons.content_paste, color: Colors.grey),
                onPressed: _pasteImage,
              ),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF333333),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: TextField(
                    controller: _controller,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: 'Type a message',
                      hintStyle: TextStyle(color: Colors.grey),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                    minLines: 1,
                    maxLines: 5,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              FloatingActionButton(
                onPressed: _isUploading ? null : _sendMessage,
                backgroundColor: const Color(0xFF2C6BED),
                mini: true,
                child: _isUploading 
                  ? const Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Icon(Icons.send, color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
