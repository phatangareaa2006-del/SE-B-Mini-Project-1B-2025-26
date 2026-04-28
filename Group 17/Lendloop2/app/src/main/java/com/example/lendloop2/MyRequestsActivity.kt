package com.example.lendloop2

import android.os.Bundle
import android.view.View
import android.widget.TextView
import androidx.appcompat.app.AppCompatActivity
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.example.lendloop2.adapters.RequestAdapter
import com.example.lendloop2.models.BorrowRequest
import com.example.lendloop2.utils.FirebaseHelper
import com.google.firebase.database.DataSnapshot
import com.google.firebase.database.DatabaseError
import com.google.firebase.database.ValueEventListener

class MyRequestsActivity : AppCompatActivity() {

    private lateinit var recycler: RecyclerView
    private lateinit var tvEmpty: TextView
    private val requestList = mutableListOf<BorrowRequest>()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_my_requests)

        recycler = findViewById(R.id.recyclerMyRequests)
        tvEmpty = findViewById(R.id.tvEmptyRequests)
        recycler.layoutManager = LinearLayoutManager(this)

        val adapter = RequestAdapter(requestList)
        recycler.adapter = adapter

        val userId = FirebaseHelper.auth.currentUser?.uid ?: return

        FirebaseHelper.database.getReference("user_requests").child(userId)
            .addValueEventListener(object : ValueEventListener {
                override fun onDataChange(snapshot: DataSnapshot) {
                    requestList.clear()
                    for (child in snapshot.children) {
                        val req = child.getValue(BorrowRequest::class.java)
                        if (req != null) requestList.add(req)
                    }
                    // Reverse to show newest requests first
                    requestList.sortByDescending { it.requestDate }
                    adapter.notifyDataSetChanged()

                    if (requestList.isEmpty()) {
                        tvEmpty.visibility = View.VISIBLE
                        recycler.visibility = View.GONE
                    } else {
                        tvEmpty.visibility = View.GONE
                        recycler.visibility = View.VISIBLE
                    }
                }

                override fun onCancelled(error: DatabaseError) {}
            })
    }
}
