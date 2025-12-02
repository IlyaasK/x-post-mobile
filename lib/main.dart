import 'package:flutter/material.dart';
import 'services/storage_service.dart';
import 'screens/chat_screen.dart';
import 'screens/setup_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    final storage = StorageService();
    final hasKeys = await storage.containsKey(key: 'CONSUMER_KEY') &&
                    await storage.containsKey(key: 'ACCESS_TOKEN');

    runApp(MyApp(startScreen: hasKeys ? const ChatScreen() : const SetupScreen()));
  } catch (e, stack) {
    print("Initialization Error: $e");
    print(stack);
    runApp(ErrorApp(error: e.toString()));
  }
}

class ErrorApp extends StatelessWidget {
  final String error;
  const ErrorApp({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text("Failed to initialize:\n$error", style: const TextStyle(color: Colors.red)),
          ),
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  final Widget startScreen;

  const MyApp({super.key, required this.startScreen});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'x-chat',
      theme: ThemeData.dark().copyWith(
        primaryColor: const Color(0xFF2C6BED),
        scaffoldBackgroundColor: const Color(0xFF121212),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF2C6BED),
          secondary: Color(0xFF2C6BED),
          surface: Color(0xFF1E1E1E),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E1E1E),
          elevation: 0,
        ),
        useMaterial3: true,
      ),
      home: startScreen,
      debugShowCheckedModeBanner: false,
    );
  }
}
