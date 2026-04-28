package com.example.lendloop2

import androidx.appcompat.app.AppCompatActivity
import android.os.Bundle

import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.example.lendloop2.adapters.ItemAdapter
import com.example.lendloop2.models.Item
import com.example.lendloop2.utils.FirebaseHelper
import com.google.firebase.database.DataSnapshot
import com.google.firebase.database.DatabaseError
import com.google.firebase.database.ValueEventListener
import android.view.View
import android.widget.TextView

class BorrowedItemsActivity : AppCompatActivity() {

    private lateinit var recyclerBorrowed: RecyclerView
    private lateinit var tvEmptyState: TextView
    private val itemList = mutableListOf<Item>()

    override fun onCreate(savedInstanceState: Bundle?) {

        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_borrowed_items)

        recyclerBorrowed = findViewById(R.id.recyclerBorrowed)
        tvEmptyState = findViewById(R.id.tvEmptyState)
        recyclerBorrowed.layoutManager = LinearLayoutManager(this)

        val adapter = ItemAdapter(itemList)
        recyclerBorrowed.adapter = adapter

        val currentUserId = FirebaseHelper.auth.currentUser?.uid
        if (currentUserId != null) {
            FirebaseHelper.itemsRef.addValueEventListener(object : ValueEventListener {
                override fun onDataChange(snapshot: DataSnapshot) {
                    itemList.clear()
                    for (data in snapshot.children) {
                        val item = data.getValue(Item::class.java)
                        if (item != null && item.borrowedBy == currentUserId) {
                            itemList.add(item)
                        }
                    }
                    adapter.notifyDataSetChanged()
                    
                    if (itemList.isEmpty()) {
                        tvEmptyState.visibility = View.VISIBLE
                        recyclerBorrowed.visibility = View.GONE
                    } else {
                        tvEmptyState.visibility = View.GONE
                        recyclerBorrowed.visibility = View.VISIBLE
                    }
                }

                override fun onCancelled(error: DatabaseError) {}
            })
        }
    }
}