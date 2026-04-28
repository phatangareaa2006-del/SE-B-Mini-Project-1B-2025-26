import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_generative_ai/google_generative_ai.dart';

import '../../services/firestore_service.dart';

class NutritionScreen extends StatefulWidget {
  const NutritionScreen({super.key});

  @override
  State<NutritionScreen> createState() => _NutritionScreenState();
}

class _NutritionScreenState extends State<NutritionScreen> {
  final User? currentUser = FirebaseAuth.instance.currentUser;
  final String todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
  
  final int _dailyCalorieGoal = 2000;

  void _showAddMealSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _AddMealSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (currentUser == null) return const Center(child: Text("Please login"));

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("Nutrition Tracker", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirestoreService().streamDailyNutrition(currentUser!.uid, todayStr),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
             return const Center(child: CircularProgressIndicator(color: Colors.greenAccent));
          }

          int totalCals = 0;
          int totalP = 0;
          int totalC = 0;
          int totalF = 0;

          List<QueryDocumentSnapshot> breakfast = [];
          List<QueryDocumentSnapshot> lunch = [];
          List<QueryDocumentSnapshot> dinner = [];
          List<QueryDocumentSnapshot> snacks = [];

          if (snapshot.hasData) {
             for (var doc in snapshot.data!.docs) {
                final d = doc.data() as Map<String, dynamic>;
                totalCals += (d['calories'] as num?)?.toInt() ?? 0;
                totalP += (d['protein'] as num?)?.toInt() ?? 0;
                totalC += (d['carbs'] as num?)?.toInt() ?? 0;
                totalF += (d['fats'] as num?)?.toInt() ?? 0;

                String type = d['mealType'] ?? 'Snacks';
                if (type == 'Breakfast') breakfast.add(doc);
                else if (type == 'Lunch') lunch.add(doc);
                else if (type == 'Dinner') dinner.add(doc);
                else snacks.add(doc);
             }
          }

          double progress = (totalCals / _dailyCalorieGoal).clamp(0.0, 1.0);

          return Stack(
            children: [
              SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                     _buildDailyRing(totalCals, progress),
                     const SizedBox(height: 32),
                     _buildMacroRow(totalP, totalC, totalF),
                     const SizedBox(height: 40),
                     
                     _buildMealSection("Breakfast", breakfast, Icons.bakery_dining),
                     _buildMealSection("Lunch", lunch, Icons.lunch_dining),
                     _buildMealSection("Dinner", dinner, Icons.dinner_dining),
                     _buildMealSection("Snacks", snacks, Icons.icecream),
                     
                     const SizedBox(height: 100),
                  ],
                ),
              ),
              Positioned(
                bottom: 20, right: 20,
                child: FloatingActionButton.extended(
                  backgroundColor: Colors.greenAccent[700],
                  onPressed: _showAddMealSheet,
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text("Log Meal", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ).animate().scale(curve: Curves.easeOutBack, duration: 600.ms),
              )
            ],
          );
        }
      ),
    );
  }

  Widget _buildDailyRing(int totalCals, double progress) {
     return Center(
       child: SizedBox(
         width: 200, height: 200,
         child: Stack(
           fit: StackFit.expand,
           children: [
             TweenAnimationBuilder<double>(
               tween: Tween<double>(begin: 0, end: progress),
               duration: const Duration(seconds: 2),
               curve: Curves.easeOutCubic,
               builder: (context, val, _) {
                 return CircularProgressIndicator(
                   value: val,
                   strokeWidth: 16,
                   backgroundColor: Colors.white.withOpacity(0.05),
                   color: val > 0.95 ? Colors.redAccent : Colors.greenAccent[700],
                 );
               }
             ),
             Column(
               mainAxisAlignment: MainAxisAlignment.center,
               children: [
                 Text("$totalCals", style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold)),
                 Text("/ $_dailyCalorieGoal kcal", style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 16)),
               ],
             )
           ],
         ),
       ).animate().scale(delay: 200.ms, begin: const Offset(0.8,0.8), end: const Offset(1,1), curve: Curves.easeOutBack),
     );
  }

  Widget _buildMacroRow(int p, int c, int f) {
     return Row(
       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
       children: [
         _macroPill("Protein", "${p}g", Colors.blueAccent),
         _macroPill("Carbs", "${c}g", Colors.amber),
         _macroPill("Fats", "${f}g", Colors.redAccent),
       ],
     ).animate().fadeIn(delay: 500.ms);
  }

  Widget _macroPill(String title, String val, Color color) {
     return Column(
       children: [
         Container(
           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
           decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(20), border: Border.all(color: color.withOpacity(0.5))),
           child: Text(val, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16)),
         ),
         const SizedBox(height: 8),
         Text(title, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12)),
       ],
     );
  }

  Widget _buildMealSection(String title, List<QueryDocumentSnapshot> docs, IconData icon) {
     int sectionCals = 0;
     for(var d in docs) sectionCals += (d['calories'] as num?)?.toInt() ?? 0;

     return Container(
       margin: const EdgeInsets.only(bottom: 24),
       child: Column(
         crossAxisAlignment: CrossAxisAlignment.start,
         children: [
            Row(
              children: [
                 Icon(icon, color: Colors.greenAccent, size: 20),
                 const SizedBox(width: 8),
                 Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                 const Spacer(),
                 Text("$sectionCals kcal", style: const TextStyle(color: Colors.white54, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            if (docs.isEmpty) 
               Padding(
                 padding: const EdgeInsets.only(left: 28.0),
                 child: Text("No meals logged yet.", style: TextStyle(color: Colors.white.withOpacity(0.3))),
               )
            else
               ...docs.map((doc) {
                  final d = doc.data() as Map<String, dynamic>;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(12)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                         Expanded(
                           child: Column(
                             crossAxisAlignment: CrossAxisAlignment.start,
                             children: [
                               Builder(
                                 builder: (context) {
                                   String dName = d['mealName']?.toString() ?? '';
                                   if ((dName.isEmpty || dName == 'null') && d['foodItems'] is List) {
                                      List<dynamic> iList = d['foodItems'];
                                      List<String> names = iList.map((e) => (e is Map ? e['name']?.toString() ?? '' : '')).where((e) => e.isNotEmpty).toList();
                                      dName = names.join(', ');
                                   }
                                   if (dName.isEmpty || dName == 'null') dName = "Custom Meal";
                                   return Text(dName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold));
                                 }
                               ),
                               const SizedBox(height: 4),
                               Text("P: ${d['protein']}g • C: ${d['carbs']}g • F: ${d['fats']}g", style: const TextStyle(color: Colors.white54, fontSize: 12)),
                             ],
                           )
                         ),
                         Text("${d['calories']} kcal", style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold)),
                      ],
                    )
                  );
               })
         ],
       ),
     ).animate().slideX(begin: 0.1, end: 0, duration: 400.ms);
  }
}

class _AddMealSheet extends StatefulWidget {
  const _AddMealSheet();

  @override
  State<_AddMealSheet> createState() => _AddMealSheetState();
}

class _AddMealSheetState extends State<_AddMealSheet> {
  final _nameCtrl = TextEditingController();
  final _calCtrl = TextEditingController();
  final _pCtrl = TextEditingController();
  final _cCtrl = TextEditingController();
  final _fCtrl = TextEditingController();
  
  String _mealType = 'Breakfast';
  bool _isFetching = false;

  static const String _geminiApiKey = 'AIzaSyAFzv6y-xQXvFcuVSzJ8qXWiiS8PM7ekcQ';

  void _autoCalculate() async {
     if (_nameCtrl.text.isEmpty) return;
     
     if (_geminiApiKey == 'YOUR_GEMINI_API_KEY') {
       if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(content: Text('Please add your Gemini API Key in the code first!')),
         );
       }
       return;
     }

     setState(() => _isFetching = true);
     
     final bestMatch = await _searchFoodWithGemini(_nameCtrl.text);
     if (bestMatch != null) {
        _calCtrl.text = bestMatch['calories'].toString();
        _pCtrl.text = bestMatch['protein'].toString();
        _cCtrl.text = bestMatch['carbs'].toString();
        _fCtrl.text = bestMatch['fats'].toString();
     } else {
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
             const SnackBar(content: Text('Could not estimate nutrients. Please try another name or enter manually.')),
           );
        }
     }
     if (mounted) setState(() => _isFetching = false);
  }

  Future<Map<String, dynamic>?> _searchFoodWithGemini(String foodName) async {
    if (foodName.isEmpty) return null;
    try {
      final model = GenerativeModel(model: 'gemini-2.5-flash', apiKey: _geminiApiKey);
      final prompt = 'Provide the estimated nutritional value indicating the typical serving size of "$foodName". '
          'Return ONLY a valid JSON object with EXACTLY these four integer keys representing macronutrients in grams and total calories: '
          '"calories", "protein", "carbs", "fats". Do not include any other text or markdown formatting.';
      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);
      
      if (response.text != null) {
        String resText = response.text!.trim();
        // Remove potential markdown code blocks
        resText = resText.replaceAll('```json', '').replaceAll('```', '');
        final data = json.decode(resText);
        return {
           'calories': (data['calories'] as num?)?.round() ?? 0,
           'protein': (data['protein'] as num?)?.round() ?? 0,
           'carbs': (data['carbs'] as num?)?.round() ?? 0,
           'fats': (data['fats'] as num?)?.round() ?? 0,
        };
      }
    } catch (e) {
      debugPrint("Error fetching Gemini data: $e");
    }
    return null;
  }

  void _submit() async {
     final currentUser = FirebaseAuth.instance.currentUser;
     if (currentUser == null || _nameCtrl.text.isEmpty || _calCtrl.text.isEmpty) return;

     await FirestoreService().addNutritionLog(currentUser.uid, {
        'mealName': _nameCtrl.text,
        'calories': int.tryParse(_calCtrl.text) ?? 0,
        'protein': int.tryParse(_pCtrl.text) ?? 0,
        'carbs': int.tryParse(_cCtrl.text) ?? 0,
        'fats': int.tryParse(_fCtrl.text) ?? 0,
        'mealType': _mealType,
        'dateStamp': DateFormat('yyyy-MM-dd').format(DateTime.now()),
     });

     if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
       padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 24, right: 24, top: 24),
       decoration: const BoxDecoration(
         color: Color(0xFF1D2B64),
         borderRadius: BorderRadius.vertical(top: Radius.circular(24))
       ),
       child: SingleChildScrollView(
         child: Column(
           mainAxisSize: MainAxisSize.min,
           crossAxisAlignment: CrossAxisAlignment.start,
           children: [
             const Text("Log Meal", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
             const SizedBox(height: 20),
             
             DropdownButtonFormField<String>(
               value: _mealType,
               dropdownColor: const Color(0xFF0A0E21),
               style: const TextStyle(color: Colors.white),
               decoration: const InputDecoration(labelText: "Meal Type", labelStyle: TextStyle(color: Colors.white54), prefixIcon: Icon(Icons.category, color: Colors.greenAccent)),
               items: ['Breakfast', 'Lunch', 'Dinner', 'Snacks'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
               onChanged: (v) => setState(() => _mealType = v!),
             ),
             const SizedBox(height: 16),
             TextField(
               controller: _nameCtrl,
               style: const TextStyle(color: Colors.white),
               decoration: InputDecoration(
                 labelText: "Meal Name",
                 labelStyle: const TextStyle(color: Colors.white54),
                 hintText: "e.g., Poha, Banana",
                 hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                 prefixIcon: const Icon(Icons.fastfood, color: Colors.amber),
                 suffixIcon: _isFetching 
                    ? const Padding(padding: EdgeInsets.all(12), child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.blueAccent)))
                    : IconButton(
                        icon: const Icon(Icons.auto_awesome, color: Colors.blueAccent),
                        onPressed: _autoCalculate,
                        tooltip: "Auto Calculate",
                      )
               ),
               onSubmitted: (_) => _autoCalculate(),
             ),
             const SizedBox(height: 16),
             TextField(controller: _calCtrl, keyboardType: TextInputType.number, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: "Calories (kcal)", labelStyle: TextStyle(color: Colors.white54), prefixIcon: Icon(Icons.local_fire_department, color: Colors.orange))),
             const SizedBox(height: 16),
             Row(
               children: [
                 Expanded(child: TextField(controller: _pCtrl, keyboardType: TextInputType.number, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: "Protein (g)"))),
                 const SizedBox(width: 8),
                 Expanded(child: TextField(controller: _cCtrl, keyboardType: TextInputType.number, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: "Carbs (g)"))),
                 const SizedBox(width: 8),
                 Expanded(child: TextField(controller: _fCtrl, keyboardType: TextInputType.number, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: "Fats (g)"))),
               ]
             ),
             const SizedBox(height: 32),
             SizedBox(
               width: double.infinity, height: 50,
               child: ElevatedButton(
                 onPressed: _submit,
                 style: ElevatedButton.styleFrom(backgroundColor: Colors.greenAccent[700], shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                 child: const Text("Save Meal", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
               )
             ),
             const SizedBox(height: 24),
           ],
         )
       )
    );
  }
}
