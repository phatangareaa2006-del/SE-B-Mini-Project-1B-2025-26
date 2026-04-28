package com.example.lendloop2

import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import android.text.Editable
import android.text.TextWatcher
import android.widget.EditText
import android.widget.TextView
import com.example.lendloop2.adapters.ItemAdapter
import com.example.lendloop2.models.Item
import com.example.lendloop2.utils.FirebaseHelper
import com.google.firebase.database.*

class ItemListActivity : AppCompatActivity() {

    private lateinit var recyclerItems: RecyclerView
    private lateinit var tvTitle: TextView
    private lateinit var etSearch: EditText

    private val itemList = mutableListOf<Item>()
    private val fullItemList = mutableListOf<Item>()
    private lateinit var adapter: ItemAdapter

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        setContentView(R.layout.activity_item_list)

        recyclerItems = findViewById(R.id.recyclerItems)
        tvTitle = findViewById(R.id.tvTitle)
        etSearch = findViewById(R.id.etSearch)

        val category = intent.getStringExtra("category")

        tvTitle.text = category

        recyclerItems.layoutManager = LinearLayoutManager(this)

        adapter = ItemAdapter(itemList)
        recyclerItems.adapter = adapter

        etSearch.addTextChangedListener(object : TextWatcher {
            override fun beforeTextChanged(s: CharSequence?, start: Int, count: Int, after: Int) {}

            override fun onTextChanged(s: CharSequence?, start: Int, before: Int, count: Int) {
                filterItems(s.toString())
            }

            override fun afterTextChanged(s: Editable?) {}
        })

        FirebaseHelper.itemsRef.addValueEventListener(object : ValueEventListener {

            override fun onDataChange(snapshot: DataSnapshot) {

                fullItemList.clear()

                for (data in snapshot.children) {

                    val item = data.getValue(Item::class.java)

                    if (item != null && !item.isBroken) {
                        val itemCategory = item.category.lowercase()
                        val isMatch = when (category) {
                            "books" -> itemCategory.contains("textbook")
                            "lab" -> itemCategory.contains("lab coat")
                            "graphics" -> itemCategory.contains("graphics")
                            else -> itemCategory == category?.lowercase()
                        }
                        
                        if (isMatch) {
                            fullItemList.add(item)
                        }
                    }
                }

                filterItems(etSearch.text.toString())
            }

            override fun onCancelled(error: DatabaseError) {}
        })
    }

    private fun filterItems(query: String) {
        itemList.clear()
        if (query.trim().isEmpty()) {
            itemList.addAll(fullItemList)
        } else {
            val lowerCaseQuery = query.lowercase().trim()
            for (item in fullItemList) {
                if (item.name.lowercase().contains(lowerCaseQuery)) {
                    itemList.add(item)
                }
            }
        }
        adapter.notifyDataSetChanged()
    }
}