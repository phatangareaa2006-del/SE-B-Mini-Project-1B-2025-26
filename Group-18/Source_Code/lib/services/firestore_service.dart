import 'package:cloud_firestore/cloud_firestore.dart';
import 'notification_service.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Stream for latest vitals
  Stream<DocumentSnapshot> streamLatestVitals(String userId) {
    return _db.collection('users').doc(userId).collection('vitals').doc('latest').snapshots();
  }

  // Stream for active (unread) alerts (Used in Dashboard Badge)
  Stream<QuerySnapshot> streamActiveAlerts(String userId) {
    return _db.collection('users').doc(userId).collection('alerts')
        .where('isRead', isEqualTo: false)
        .snapshots();
  }

  // Stream for all alerts mapping into UI list
  Stream<QuerySnapshot> streamAllAlerts(String userId) {
    return _db.collection('users').doc(userId).collection('alerts')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // Stream for parsing historical graphs natively per tab
  Stream<QuerySnapshot> streamVitalHistory(String userId, String type) {
    return _db.collection('users').doc(userId).collection('vitals')
        .doc(type).collection('readings')
        .orderBy('timestamp', descending: true)
        .limit(7)
        .snapshots();
  }

  // Dual-Write and Alert Checker 
  Future<void> addVitalReading({
    required String userId,
    required String type, // e.g., 'bp', 'heartRate', 'bloodSugar', 'spO2', 'temperature_c'
    required double value,
    double? value2,       // specifically for diastolic if type == 'bp'
    required String unit,
    String? note,
  }) async {
    final timestamp = FieldValue.serverTimestamp();
    
    // 1. Save to Historical Array
    await _db.collection('users').doc(userId).collection('vitals')
        .doc(type).collection('readings').add({
      'value': value,
      if (value2 != null) 'value2': value2,
      'unit': unit,
      'note': note,
      'timestamp': timestamp,
    });

    // 2. Dual-Write to Dashboard 'latest' node
    await _db.collection('users').doc(userId).collection('vitals').doc('latest').set({
      type: value,
      if (type == 'bp' && value2 != null) 'systolic': value,
      if (type == 'bp' && value2 != null) 'diastolic': value2,
      'lastUpdated': timestamp,
    }, SetOptions(merge: true));

    // 3. Automated Threshold Alerts
    String? alertLevel;
    String? alertMessage;
    String? alertValue;

    if (type == 'bp' && value2 != null) {
      alertValue = "${value.toInt()}/${value2.toInt()} $unit";
      if (value > 140 || value2 > 90) {
        alertLevel = 'critical';
        alertMessage = 'High Blood Pressure detected. Seek medical attention.';
      } else if (value >= 130) {
        alertLevel = 'warning';
        alertMessage = 'Elevated Blood Pressure.';
      }
    } else if (type == 'bloodSugar') {
      alertValue = "${value.toInt()} $unit";
      if (value > 180) {
        alertLevel = 'critical';
        alertMessage = 'High Blood Sugar detected.';
      }
    } else if (type == 'heartRate') {
      alertValue = "${value.toInt()} $unit";
      if (value < 50 || value > 120) {
        alertLevel = 'critical';
        alertMessage = 'Abnormal Heart Rate detected.';
      }
    } else if (type == 'spO2') {
       alertValue = "${value.toInt()}%";
       if (value < 95 && value > 0) {
         alertLevel = 'critical';
         alertMessage = 'Low Oxygen Saturation detected.';
       }
    }

    if (alertLevel != null && alertMessage != null) {
      await _db.collection('users').doc(userId).collection('alerts').add({
        'type': type,
        'severity': alertLevel,
        'value': alertValue,
        'message': alertMessage,
        'timestamp': timestamp,
        'isRead': false,
      });

      if (alertLevel == 'critical') {
        await _db.collection('users').doc(userId).collection('vitals').doc('latest').set({
          'hasEmergency': true,
        }, SetOptions(merge: true));

        await NotificationService().showNotification(
          title: 'Critical Health Alert',
          body: "$alertMessage : $alertValue",
        );
      }
    } else {
       // Clear Emergency UI if values return to normal
       await _db.collection('users').doc(userId).collection('vitals').doc('latest').set({
          'hasEmergency': false,
       }, SetOptions(merge: true));
    }
  }
  // --- MEDICINE LOGIC ---
  Future<void> addMedicine({
    required String userId,
    required String name,
    required String dosage,
    required String frequency,
    required List<String> times,
    required String instructions,
    required String colorHex,
  }) async {
    final timestamp = FieldValue.serverTimestamp();
    
    DocumentReference docRef = await _db.collection('users').doc(userId).collection('medicines').add({
      'name': name,
      'dosage': dosage,
      'frequency': frequency,
      'times': times,
      'instructions': instructions,
      'color': colorHex,
      'createdAt': timestamp,
    });

    for (String time in times) {
       int notifId = (docRef.id + time).hashCode; 
       await NotificationService().scheduleMedicineReminder(
         id: notifId,
         title: "Time for $name",
         body: "$dosage - $instructions",
         timeString: time,
       );
    }
  }

  Stream<QuerySnapshot> streamMedicines(String userId) {
    return _db.collection('users').doc(userId).collection('medicines')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Future<void> logMedicineTaken({
    required String userId,
    required String medicineId,
    required String status,
    required String dateStamp, 
  }) async {
    await _db.collection('users').doc(userId).collection('medicine_logs').add({
       'medicineId': medicineId,
       'status': status,
       'date': dateStamp,
       'takenAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot> streamTodayMedicineLogs(String userId, String dateStamp) {
    return _db.collection('users').doc(userId).collection('medicine_logs')
        .where('date', isEqualTo: dateStamp)
        .snapshots();
  }

  Stream<QuerySnapshot> streamWeeklyMedicineLogs(String userId) {
    return _db.collection('users').doc(userId).collection('medicine_logs')
        .orderBy('date', descending: true)
        .snapshots();
  }

  // --- ALERTS MODULE ---
  Future<void> markAlertAsRead(String userId, String alertId) async {
    await _db.collection('users').doc(userId).collection('alerts').doc(alertId).update({
      'isRead': true,
    });
  }

  Future<void> purgeOldAlerts(String userId) async {
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    final snapshot = await _db.collection('users').doc(userId).collection('alerts')
        .where('timestamp', isLessThan: Timestamp.fromDate(thirtyDaysAgo))
        .get();
        
    for (var doc in snapshot.docs) {
       await doc.reference.delete();
    }
  }

  // --- ALARM CLOCK MODULE ---
  Future<String> addPillAlarm(String userId, Map<String, dynamic> data) async {
    data['createdAt'] = FieldValue.serverTimestamp();
    DocumentReference ref = await _db.collection('users').doc(userId).collection('alarms').add(data);
    return ref.id;
  }

  Stream<QuerySnapshot> streamPillAlarms(String userId) {
    return _db.collection('users').doc(userId).collection('alarms')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Future<void> togglePillAlarm(String userId, String alarmId, bool isActive) async {
    await _db.collection('users').doc(userId).collection('alarms').doc(alarmId).update({
      'isActive': isActive,
    });
  }

  Future<void> deletePillAlarm(String userId, String alarmId) async {
    await _db.collection('users').doc(userId).collection('alarms').doc(alarmId).delete();
  }

  // --- REPORTS ENGINE FETCHES ---
  Future<Map<String, dynamic>> fetchUserProfile(String userId) async {
    final doc = await _db.collection('users').doc(userId).get();
    return doc.data() ?? {};
  }

  Future<List<Map<String,dynamic>>> fetchRangedVitals(String userId, DateTime start, DateTime end) async {
    List<Map<String,dynamic>> aggregatedVitals = [];
    final types = ['bp', 'heartRate', 'bloodSugar', 'spO2', 'temperature_c'];
    
    for (String type in types) {
       final snapshot = await _db.collection('users').doc(userId).collection('vitals')
          .doc(type).collection('readings')
          .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
          .where('timestamp', isLessThanOrEqualTo: Timestamp.fromDate(end))
          .get();
          
       for (var doc in snapshot.docs) {
          final data = doc.data();
          data['metricType'] = type;
          aggregatedVitals.add(data);
       }
    }
    aggregatedVitals.sort((a,b) => (b['timestamp'] as Timestamp).compareTo(a['timestamp'] as Timestamp));
    return aggregatedVitals;
  }

  Future<List<Map<String,dynamic>>> fetchRangedMedicineLogs(String userId, DateTime start, DateTime end) async {
    final snapshot = await _db.collection('users').doc(userId).collection('medicine_logs')
          .where('takenAt', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
          .where('takenAt', isLessThanOrEqualTo: Timestamp.fromDate(end))
          .get();
          
    final medsSnapshot = await _db.collection('users').doc(userId).collection('medicines').get();
    Map<String, Map<String,dynamic>> definitions = {};
    for (var doc in medsSnapshot.docs) definitions[doc.id] = doc.data();

    List<Map<String,dynamic>> results = [];
    for (var doc in snapshot.docs) {
        final data = doc.data();
        String pureMedId = data['medicineId'].toString().split('_')[0]; 
        data['medicineDetails'] = definitions[pureMedId] ?? {};
        results.add(data);
    }
    return results;
  }

  Future<List<Map<String,dynamic>>> fetchRangedAlerts(String userId, DateTime start, DateTime end) async {
    final snapshot = await _db.collection('users').doc(userId).collection('alerts')
          .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
          .where('timestamp', isLessThanOrEqualTo: Timestamp.fromDate(end))
          .orderBy('timestamp', descending: true)
          .get();
          
    return snapshot.docs.map((e) => e.data()).toList();
  }

  Future<List<Map<String,dynamic>>> fetchRangedSleepLogs(String userId, DateTime start, DateTime end) async {
    final snapshot = await _db.collection('users').doc(userId).collection('sleep')
          .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
          .where('timestamp', isLessThanOrEqualTo: Timestamp.fromDate(end))
          .get();
    return snapshot.docs.map((e) => e.data()).toList();
  }

  Future<List<Map<String,dynamic>>> fetchRangedNutritionLogs(String userId, DateTime start, DateTime end) async {
    final snapshot = await _db.collection('users').doc(userId).collection('nutrition')
          .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
          .where('timestamp', isLessThanOrEqualTo: Timestamp.fromDate(end))
          .get();
    return snapshot.docs.map((e) => e.data()).toList();
  }

  Future<List<Map<String,dynamic>>> fetchRangedActivityLogs(String userId, DateTime start, DateTime end) async {
    final snapshot = await _db.collection('users').doc(userId).collection('activity')
          .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
          .where('timestamp', isLessThanOrEqualTo: Timestamp.fromDate(end))
          .get();
    return snapshot.docs.map((e) => e.data()).toList();
  }

  // --- SLEEP MODULE ---
  Future<void> addSleepLog(String userId, Map<String, dynamic> data) async {
    data['timestamp'] = FieldValue.serverTimestamp();
    await _db.collection('users').doc(userId).collection('sleep').add(data);
  }

  Stream<QuerySnapshot> streamSleepLogs(String userId) {
    return _db.collection('users').doc(userId).collection('sleep')
        .orderBy('timestamp', descending: true)
        .limit(7)
        .snapshots();
  }

  // --- NUTRITION MODULE ---
  Future<void> addNutritionLog(String userId, Map<String, dynamic> data) async {
    data['timestamp'] = FieldValue.serverTimestamp();
    await _db.collection('users').doc(userId).collection('nutrition').add(data);
  }

  Stream<QuerySnapshot> streamDailyNutrition(String userId, String dateStamp) {
    return _db.collection('users').doc(userId).collection('nutrition')
        .where('dateStamp', isEqualTo: dateStamp)
        .snapshots();
  }

  // --- ACTIVITY MODULE ---
  Future<void> addActivityLog(String userId, String dateId, Map<String, dynamic> data) async {
    data['timestamp'] = FieldValue.serverTimestamp();
    await _db.collection('users').doc(userId).collection('activity').doc(dateId).set(data, SetOptions(merge: true));
  }

  Stream<QuerySnapshot> streamWeeklyActivity(String userId) {
    return _db.collection('users').doc(userId).collection('activity')
        .orderBy('timestamp', descending: true)
        .limit(7)
        .snapshots();
  }
  
  // --- PROFILE OVERRIDES ---
  Future<void> updateProfile(String userId, Map<String, dynamic> data) async {
    await _db.collection('users').doc(userId).set(data, SetOptions(merge: true));
  }
}
