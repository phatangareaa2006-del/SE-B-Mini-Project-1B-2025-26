package com.example.lendloop2.utils

import com.google.firebase.auth.FirebaseAuth
import com.google.firebase.database.FirebaseDatabase
import com.google.firebase.storage.FirebaseStorage

object FirebaseHelper {

    val auth = FirebaseAuth.getInstance()

    val database = FirebaseDatabase.getInstance()

    val usersRef = database.getReference("users")

    val itemsRef = database.getReference("items")

    val finesRef = database.getReference("fines")

    val userItemsRef = database.getReference("user_items")

    val borrowRequestsRef = database.getReference("borrow_requests")

    val storage = FirebaseStorage.getInstance()

}