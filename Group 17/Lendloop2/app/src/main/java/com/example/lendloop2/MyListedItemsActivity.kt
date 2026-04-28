package com.example.lendloop2

import androidx.appcompat.app.AppCompatActivity
import android.os.Bundle
import android.view.View
import android.widget.TextView
import android.widget.Toast
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.example.lendloop2.adapters.ListedItemAdapter
import com.example.lendloop2.models.Item
import com.example.lendloop2.utils.FirebaseHelper
import com.google.firebase.database.DataSnapshot
import com.google.firebase.database.DatabaseError
import com.google.firebase.database.ValueEventListener

class MyListedItemsActivity : AppCompatActivity() {

    private lateinit var recyclerView: RecyclerView
    private lateinit var tvEmpty: TextView
    private lateinit var adapter: ListedItemAdapter
    private val itemList = mutableListOf<Item>()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_my_listed_items)

        recyclerView = findViewById(R.id.rvMyListedItems)
        tvEmpty = findViewById(R.id.tvEmptyMyItems)

        adapter = ListedItemAdapter(itemList) { item ->
            deleteItem(item)
        }
        recyclerView.layoutManager = LinearLayoutManager(this)
        recyclerView.adapter = adapter

        loadMyItems()
    }

    private fun loadMyItems() {
        val uid = FirebaseHelper.auth.currentUser?.uid ?: return

        FirebaseHelper.itemsRef.orderByChild("ownerId").equalTo(uid)
            .addValueEventListener(object : ValueEventListener {
                override fun onDataChange(snapshot: DataSnapshot) {
                    val items = mutableListOf<Item>()
                    for (child in snapshot.children) {
                        val item = child.getValue(Item::class.java)
                        if (item != null) items.add(item)
                    }
                    adapter.setItems(items)
                    tvEmpty.visibility = if (items.isEmpty()) View.VISIBLE else View.GONE
                    recyclerView.visibility = if (items.isEmpty()) View.GONE else View.VISIBLE
                }

                override fun onCancelled(error: DatabaseError) {
                    Toast.makeText(
                        this@MyListedItemsActivity,
                        "Failed to load items",
                        Toast.LENGTH_SHORT
                    ).show()
                }
            })
    }

    private fun deleteItem(item: Item) {
        FirebaseHelper.itemsRef.child(item.itemId).removeValue()
            .addOnSuccessListener {
                Toast.makeText(this, "Item removed", Toast.LENGTH_SHORT).show()
            }
    }
}
