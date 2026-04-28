package com.example.lendloop2

import androidx.appcompat.app.AppCompatActivity
import android.os.Bundle
import android.view.View
import android.widget.TextView
import android.widget.Toast
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.example.lendloop2.adapters.BrowseItemAdapter
import com.example.lendloop2.models.BorrowRequest
import com.example.lendloop2.models.Item
import com.example.lendloop2.models.User
import com.example.lendloop2.utils.FirebaseHelper
import com.google.firebase.database.DataSnapshot
import com.google.firebase.database.DatabaseError
import com.google.firebase.database.ValueEventListener
import java.text.SimpleDateFormat
import java.util.*

class BrowseUserItemsActivity : AppCompatActivity() {

    private lateinit var recyclerView: RecyclerView
    private lateinit var tvEmpty: TextView
    private lateinit var adapter: BrowseItemAdapter
    private val allItems = mutableListOf<Item>()

    private var currentUser: User? = null
    private val currentUid get() = FirebaseHelper.auth.currentUser?.uid ?: ""

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_browse_user_items)

        recyclerView = findViewById(R.id.rvBrowseItems)
        tvEmpty = findViewById(R.id.tvBrowseEmpty)

        adapter = BrowseItemAdapter(allItems, currentUid) { item ->
            sendBorrowRequest(item)
        }
        recyclerView.layoutManager = LinearLayoutManager(this)
        recyclerView.adapter = adapter

        // Load current user profile first, then load items
        loadCurrentUser()
    }

    private fun loadCurrentUser() {
        if (currentUid.isEmpty()) return
        FirebaseHelper.usersRef.child(currentUid)
            .addListenerForSingleValueEvent(object : ValueEventListener {
                override fun onDataChange(snapshot: DataSnapshot) {
                    currentUser = snapshot.getValue(User::class.java)
                    loadAllUserItems()
                }
                override fun onCancelled(error: DatabaseError) {
                    loadAllUserItems()
                }
            })
    }

    private fun loadAllUserItems() {
        // user_items/{ownerId}/{itemId}
        FirebaseHelper.userItemsRef.addValueEventListener(object : ValueEventListener {
            override fun onDataChange(snapshot: DataSnapshot) {
                val items = mutableListOf<Item>()
                for (ownerSnap in snapshot.children) {
                    for (itemSnap in ownerSnap.children) {
                        val item = itemSnap.getValue(Item::class.java)
                        if (item != null) items.add(item)
                    }
                }
                adapter.setItems(items)
                tvEmpty.visibility = if (items.isEmpty()) View.VISIBLE else View.GONE
                recyclerView.visibility = if (items.isEmpty()) View.GONE else View.VISIBLE
            }

            override fun onCancelled(error: DatabaseError) {
                Toast.makeText(this@BrowseUserItemsActivity, "Failed to load items", Toast.LENGTH_SHORT).show()
            }
        })
    }

    private fun sendBorrowRequest(item: Item) {
        val user = currentUser
        if (user == null) {
            Toast.makeText(this, "Could not load your profile. Try again.", Toast.LENGTH_SHORT).show()
            return
        }

        val requestId = UUID.randomUUID().toString()
        val dateStr = SimpleDateFormat("dd MMM yyyy, hh:mm a", Locale.getDefault()).format(Date())

        val request = BorrowRequest(
            requestId = requestId,
            itemId = item.itemId,
            itemName = item.name,
            ownerId = item.ownerId,
            requesterId = currentUid,
            requesterName = user.name,
            requesterContact = user.email,   // will be overridden if phone available
            requesterEmail = user.email,
            requestDate = dateStr,
            status = "Pending"
        )

        // Save under borrow_requests/{ownerId}/{itemId}/{requestId}
        FirebaseHelper.borrowRequestsRef
            .child(item.ownerId)
            .child(item.itemId)
            .child(requestId)
            .setValue(request)
            .addOnSuccessListener {
                Toast.makeText(this, "✅ Borrow request sent to ${item.ownerName}!", Toast.LENGTH_SHORT).show()
            }
            .addOnFailureListener {
                Toast.makeText(this, "Failed to send request. Try again.", Toast.LENGTH_SHORT).show()
            }
    }
}
