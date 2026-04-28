package com.example.lendloop2

import android.content.Intent
import android.os.Bundle
import android.view.View
import android.widget.TextView
import androidx.appcompat.app.AppCompatActivity
import com.example.lendloop2.models.Item
import com.example.lendloop2.utils.FirebaseHelper
import com.google.firebase.database.DataSnapshot
import com.google.firebase.database.DatabaseError
import com.google.firebase.database.ValueEventListener
import java.util.UUID

class DashboardActivity : AppCompatActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        setContentView(R.layout.activity_dashboard)

        setupDefaultLibrary()

        val tvWelcome = findViewById<TextView>(R.id.tvWelcome)
        val userId = FirebaseHelper.auth.currentUser?.uid
        if (userId != null) {
            FirebaseHelper.usersRef.child(userId).addListenerForSingleValueEvent(object : ValueEventListener {
                override fun onDataChange(snapshot: DataSnapshot) {
                    val user = snapshot.getValue(com.example.lendloop2.models.User::class.java)
                    if (user != null) {
                        // Extract first name only for a cleaner UI
                    val firstName = user.name.split(" ").firstOrNull { it.isNotEmpty() } ?: "there"
                        tvWelcome.text = "Welcome back, $firstName! 👋"
                    }
                }
                override fun onCancelled(error: DatabaseError) {}
            })
        }

        val cardBooks = findViewById<View>(R.id.cardBooks)
        val cardLab = findViewById<View>(R.id.cardLab)
        val cardGraphics = findViewById<View>(R.id.cardGraphics)
        val cardProfile = findViewById<View>(R.id.cardProfile)

        // Books
        cardBooks.setOnClickListener {
            openItems("books")
        }

        // Lab Coat
        cardLab.setOnClickListener {
            openItems("lab")
        }

        // Graphics Kit
        cardGraphics.setOnClickListener {
            openItems("graphics")
        }

        // Profile
        cardProfile.setOnClickListener {
            startActivity(Intent(this, ProfileActivity::class.java))
        }

        // My Requests
        findViewById<View>(R.id.cardMyRequests).setOnClickListener {
            startActivity(Intent(this, MyRequestsActivity::class.java))
        }



        // Add Item FAB Security Lock
        val fabAddItem = findViewById<com.google.android.material.floatingactionbutton.FloatingActionButton>(R.id.fabAddItem)
        
        val currentUserEmail = FirebaseHelper.auth.currentUser?.email ?: ""
        if (currentUserEmail == "admin@lendloop.com") {
            fabAddItem.visibility = View.VISIBLE
            fabAddItem.setOnClickListener {
                startActivity(Intent(this, AddItemActivity::class.java))
            }
        } else {
            fabAddItem.setOnClickListener {
                startActivity(Intent(this, UserLendItemActivity::class.java))
            }
        }
    }

    private fun openItems(category: String) {
        val intent = Intent(this, ItemListActivity::class.java)
        intent.putExtra("category", category)
        startActivity(intent)
    }

    private fun setupDefaultLibrary() {
        FirebaseHelper.itemsRef.addListenerForSingleValueEvent(object : ValueEventListener {
            override fun onDataChange(snapshot: DataSnapshot) {
                if (!snapshot.exists() || snapshot.childrenCount == 0L) {
                    val defaultItems = mutableListOf<Item>()
                    val years = listOf("FE", "SE", "TE", "BE")
                    val branches = listOf("Computer", "IT", "Mechanical", "Civil")

                    for (year in years) {
                        for (branch in branches) {
                            defaultItems.add(Item(UUID.randomUUID().toString(), "$year $branch Textbook", "$year Textbooks", "", true))
                        }
                    }

                    defaultItems.add(Item(UUID.randomUUID().toString(), "Chemistry Lab Coat", "Lab Coat", "", true))
                    defaultItems.add(Item(UUID.randomUUID().toString(), "Standard Graphics Kit", "Graphics Kit", "", true))
                    
                    for (item in defaultItems) {
                        FirebaseHelper.itemsRef.child(item.itemId).setValue(item)
                    }
                }
            }

            override fun onCancelled(error: DatabaseError) {}
        })
    }
}