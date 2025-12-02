import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import 'chat_screen.dart';

class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _storage = StorageService();
  
  final _consumerKeyController = TextEditingController();
  final _consumerSecretController = TextEditingController();
  final _accessTokenController = TextEditingController();
  final _accessTokenSecretController = TextEditingController();

  bool _isLoading = false;

  Future<void> _saveKeys() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await _storage.write(key: 'CONSUMER_KEY', value: _consumerKeyController.text.trim());
      await _storage.write(key: 'CONSUMER_SECRET', value: _consumerSecretController.text.trim());
      await _storage.write(key: 'ACCESS_TOKEN', value: _accessTokenController.text.trim());
      await _storage.write(key: 'ACCESS_TOKEN_SECRET', value: _accessTokenSecretController.text.trim());

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const ChatScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving keys: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Setup x-chat')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Text(
                'Enter your X API Keys',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Keys are stored securely if possible, or locally if not.',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 20),
              _buildTextField('Consumer Key', _consumerKeyController),
              _buildTextField('Consumer Secret', _consumerSecretController, obscure: true),
              _buildTextField('Access Token', _accessTokenController),
              _buildTextField('Access Token Secret', _accessTokenSecretController, obscure: true),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading ? null : _saveKeys,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Save & Continue'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool obscure = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        obscureText: obscure,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter $label';
          }
          return null;
        },
      ),
    );
  }
}
