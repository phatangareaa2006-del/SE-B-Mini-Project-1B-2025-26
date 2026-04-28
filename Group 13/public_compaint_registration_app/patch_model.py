import re
import os

print("Applying model updates...")

file = "lib/models/complaint_model.dart"
with open(file, "r", encoding="utf-8") as f:
    text = f.read()

if "final int upvotes;" not in text:
    text = re.sub(
        r"final String priority;\n  final String status;",
        "final String priority;\n  final String status;\n  final int upvotes;\n  final List<String> upvotedBy;",
        text
    )
    text = re.sub(
        r"this\.status = 'Pending',",
        "this.status = 'Pending',\n    this.upvotes = 0,\n    this.upvotedBy = const [],",
        text
    )
    text = re.sub(
        r"status: data\['status'\] \?\? 'Pending',",
        "status: data['status'] ?? 'Pending',\n      upvotes: data['upvotes'] ?? 0,\n      upvotedBy: List<String>.from(data['upvotedBy'] ?? []),",
        text
    )
    text = re.sub(
        r"'status': status,\n      'createdAt':",
        "'status': status,\n      'upvotes': upvotes,\n      'upvotedBy': upvotedBy,\n      'createdAt':",
        text
    )

with open(file, "w", encoding="utf-8") as f:
    f.write(text)

file2 = "lib/services/firebase_service.dart"
with open(file2, "r", encoding="utf-8") as f:
    text = f.read()

vote_method = '''
  // ─── UPVOTES ─────────────────────────────────────────────────────────────

  Future<void> toggleUpvote(String docId, String uid) async {
    final docRef = _db.collection('complaints').doc(docId);
    return _db.runTransaction((transaction) async {
      final snap = await transaction.get(docRef);
      if (!snap.exists) return;
      final data = snap.data()!;
      List<String> upvotedBy = List<String>.from(data['upvotedBy'] ?? []);
      int upvotes = data['upvotes'] ?? 0;
      
      if (upvotedBy.contains(uid)) {
        upvotedBy.remove(uid);
        upvotes -= 1;
      } else {
        upvotedBy.add(uid);
        upvotes += 1;
      }
      
      transaction.update(docRef, {
        'upvotes': upvotes < 0 ? 0 : upvotes,
        'upvotedBy': upvotedBy,
      });
    });
  }
'''

if "toggleUpvote" not in text:
    text = text.replace(
        "// ─── ADMIN ",
        vote_method + "\n// ─── ADMIN "
    )
    with open(file2, "w", encoding="utf-8") as f:
        f.write(text)

print("Done patches.")
