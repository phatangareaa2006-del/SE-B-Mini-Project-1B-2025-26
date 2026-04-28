import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

void main() async {
  const _geminiApiKey = 'AIzaSyAFzv6y-xQXvFcuVSzJ8qXWiiS8PM7ekcQ';
  final url = Uri.parse('https://generativelanguage.googleapis.com/v1beta/models?key=\$_geminiApiKey');
  
  final response = await http.get(url);
  if (response.statusCode == 200) {
    print("MODELS:");
    final data = json.decode(response.body);
    for (var m in data['models']) {
       if (m['supportedGenerationMethods'].contains('generateContent')) {
          print(m['name']);
       }
    }
  } else {
    print("Error \${response.statusCode}: \${response.body}");
  }
  exit(0);
}
