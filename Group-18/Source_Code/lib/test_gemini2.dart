import 'dart:convert';
import 'dart:io';

import 'package:google_generative_ai/google_generative_ai.dart';

void main() async {
  const _geminiApiKey = 'AIzaSyAFzv6y-xQXvFcuVSzJ8qXWiiS8PM7ekcQ';
  try {
    final model = GenerativeModel(model: 'gemini-2.5-flash', apiKey: _geminiApiKey);
    final foodName = "Apple"; // test food
    final prompt = 'Provide the estimated nutritional value indicating the typical serving size of "$foodName". '
        'Return ONLY a valid JSON object with EXACTLY these four integer keys representing macronutrients in grams and total calories: '
        '"calories", "protein", "carbs", "fats". Do not include any other text or markdown formatting.';
    final content = [Content.text(prompt)];
    
    print("Sending request to gemini-pro...");
    final response = await model.generateContent(content);
    if (response.text != null) {
      String resText = response.text!.trim();
      print("RAW RESPONSE:");
      print(resText);
      resText = resText.replaceAll('```json', '').replaceAll('```', '');
      print("CLEANED RESPONSE:");
      print(resText);
      final data = json.decode(resText);
      print("PARSED JSON:");
      print(data);
    } else {
      print("response.text is NULL");
    }
  } catch (e) {
    print("Error: $e");
  }
  exit(0);
}
