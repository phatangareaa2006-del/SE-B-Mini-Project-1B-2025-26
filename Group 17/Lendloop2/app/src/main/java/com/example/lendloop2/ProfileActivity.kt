package com.example.lendloop2

import androidx.appcompat.app.AppCompatActivity
import android.os.Bundle

import android.content.Intent
import com.example.lendloop2.models.User
import com.example.lendloop2.utils.FirebaseHelper
import com.google.firebase.database.DataSnapshot
import com.google.firebase.database.DatabaseError
import com.google.firebase.database.ValueEventListener
import android.widget.Button
import android.widget.TextView
import android.widget.Toast

class ProfileActivity : AppCompatActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {

        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_profile)

        val tvName = findViewById<TextView>(R.id.tvName)
        val tvEmail = findViewById<TextView>(R.id.tvEmail)
        val tvBranch = findViewById<TextView>(R.id.tvBranch)
        val tvYear = findViewById<TextView>(R.id.tvYear)

        val btnMyBorrowedItems = findViewById<Button>(R.id.btnMyBorrowedItems)
        val btnLogout = findViewById<Button>(R.id.btnLogout)
        val btnLendItem = findViewById<Button>(R.id.btnLendItem)

        val currentUser = FirebaseHelper.auth.currentUser
        if (currentUser != null) {
            FirebaseHelper.usersRef.child(currentUser.uid).addListenerForSingleValueEvent(object : ValueEventListener {
                override fun onDataChange(snapshot: DataSnapshot) {
                    val user = snapshot.getValue(User::class.java)
                    if (user != null) {
                        tvName.text = "Name: ${user.name}"
                        tvEmail.text = "Email: ${user.email}"
                        tvBranch.text = "Branch: ${user.branch}"
                        tvYear.text = "Year: ${user.classYear}"
                    } else {
                        tvName.text = "Name: User Not Found in Database"
                        tvEmail.text = "Email: Did you use the Register screen?"
                        tvBranch.text = "Branch: Unknown"
                        tvYear.text = "Year: Unknown"
                    }
                }

                override fun onCancelled(error: DatabaseError) {
                    Toast.makeText(this@ProfileActivity, "Failed to load profile", Toast.LENGTH_SHORT).show()
                }
            })
        }

        btnMyBorrowedItems.setOnClickListener {
            startActivity(Intent(this, BorrowedItemsActivity::class.java))
        }

        btnLendItem.setOnClickListener {
            startActivity(Intent(this, UserLendItemActivity::class.java))
        }

        btnLogout.setOnClickListener {
            FirebaseHelper.auth.signOut()
            val intent = Intent(this, LoginActivity::class.java)
            intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK
            startActivity(intent)
            finish()
        }
    }
}