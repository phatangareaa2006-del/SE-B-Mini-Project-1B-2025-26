package com.example.lendloop2

import androidx.appcompat.app.AppCompatActivity
import android.os.Bundle
import android.widget.*
import com.bumptech.glide.Glide
import com.example.lendloop2.models.Item
import com.example.lendloop2.models.BorrowRequest
import com.example.lendloop2.models.User
import com.example.lendloop2.utils.FirebaseHelper
import com.google.firebase.database.DataSnapshot
import com.google.firebase.database.DatabaseError
import com.google.firebase.database.ValueEventListener
import java.util.UUID
import java.util.Locale
import java.util.Date

class ItemDetailActivity : AppCompatActivity() {

    lateinit var btnBorrow: Button
    lateinit var btnAddFine: Button
    lateinit var etFine: EditText
    lateinit var etRemark: EditText
    lateinit var itemImage: ImageView
    lateinit var tvItemName: TextView
    lateinit var tvCategory: TextView
    lateinit var tvBorrowedBy: TextView
    lateinit var tvFineDisplay: TextView
    lateinit var tvOwnerInfo: TextView

    var item: Item? = null
    var currentUserUid: String = ""
    var currentUserEmail: String = ""
    var itemId: String = ""

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_item_detail)

        btnBorrow = findViewById(R.id.btnBorrow)
        btnAddFine = findViewById(R.id.btnAddFine)
        etFine = findViewById(R.id.etFine)
        etRemark = findViewById(R.id.etRemark)
        itemImage = findViewById(R.id.itemImage)
        tvItemName = findViewById(R.id.tvItemName)
        tvCategory = findViewById(R.id.tvCategory)
        tvBorrowedBy = findViewById(R.id.tvBorrowedBy)
        tvFineDisplay = findViewById(R.id.tvFineDisplay)
        tvOwnerInfo = findViewById(R.id.tvOwnerInfo)

        itemId = intent.getStringExtra("itemId") ?: ""

        if (itemId.isNotEmpty()) {
            fetchItemDetails()
        }

        currentUserUid = FirebaseHelper.auth.currentUser?.uid ?: ""
        currentUserEmail = FirebaseHelper.auth.currentUser?.email ?: ""

        // Hidden by default, shown in fetchItemDetails if user is owner/admin
        etFine.visibility = android.view.View.GONE
        etRemark.visibility = android.view.View.GONE
        btnAddFine.visibility = android.view.View.GONE

        btnBorrow.setOnClickListener {
            val currentItem = item ?: return@setOnClickListener
            if (currentUserUid.isEmpty()) {
                Toast.makeText(this, "Please log in again.", Toast.LENGTH_SHORT).show()
                return@setOnClickListener
            }

            if (currentItem.isUserListed) {
                if (currentItem.ownerId == currentUserUid) {
                    Toast.makeText(this, "This is your item!", Toast.LENGTH_SHORT).show()
                } else if (btnBorrow.text == "Request to Borrow") {
                    sendBorrowRequest(currentItem)
                }
            } else {
                // Library Borrow Logic
                if (btnBorrow.text.toString() == "Borrow Item") {
                    if (currentUserUid.isEmpty()) {
                        Toast.makeText(this, "Please log in again.", Toast.LENGTH_SHORT).show()
                    } else {
                        FirebaseHelper.itemsRef.child(itemId).child("available").setValue(false)
                        FirebaseHelper.itemsRef.child(itemId).child("borrowedBy").setValue(currentUserUid)
                        Toast.makeText(this, "Item Borrowed", Toast.LENGTH_SHORT).show()
                    }
                } else if (btnBorrow.text.toString() == "Return Item") {
                    FirebaseHelper.itemsRef.child(itemId).child("available").setValue(true)
                    FirebaseHelper.itemsRef.child(itemId).child("borrowedBy").setValue("")
                    FirebaseHelper.itemsRef.child(itemId).child("fine").setValue(0)
                    FirebaseHelper.itemsRef.child(itemId).child("remark").setValue("")
                    Toast.makeText(this, "Item Returned", Toast.LENGTH_SHORT).show()
                }
            }
        }

        btnAddFine.setOnClickListener {
            val currentItem = item ?: return@setOnClickListener
            if (currentUserEmail == "admin@lendloop.com" || currentItem.ownerId == currentUserUid) {
                val fine = etFine.text.toString().toIntOrNull() ?: 0
                val remark = etRemark.text.toString()

                FirebaseHelper.itemsRef.child(itemId).child("fine").setValue(fine)
                FirebaseHelper.itemsRef.child(itemId).child("remark").setValue(remark)

                Toast.makeText(this, "Fine Added", Toast.LENGTH_SHORT).show()
            }
        }
    }

    private fun sendBorrowRequest(item: Item) {
        FirebaseHelper.usersRef.child(currentUserUid).addListenerForSingleValueEvent(object : ValueEventListener {
            override fun onDataChange(snapshot: DataSnapshot) {
                val user = snapshot.getValue(User::class.java) ?: return
                val requestId = UUID.randomUUID().toString()
                val request = BorrowRequest(
                    requestId = requestId,
                    itemId = item.itemId,
                    itemName = item.name,
                    ownerId = item.ownerId,
                    requesterId = currentUserUid,
                    requesterName = user.name,
                    requesterContact = user.branch,
                    requesterEmail = user.email,
                    requestDate = java.text.SimpleDateFormat("dd/MM HH:mm", Locale.getDefault()).format(Date()),
                    status = "Pending"
                )

                val ownerRef = FirebaseHelper.borrowRequestsRef.child(item.ownerId).child(item.itemId).child(requestId)
                val requesterRef = FirebaseHelper.database.getReference("user_requests").child(currentUserUid).child(requestId)

                // Double-write for both owner and borrower visibility
                ownerRef.setValue(request)
                requesterRef.setValue(request)
                    .addOnSuccessListener {
                        Toast.makeText(this@ItemDetailActivity, "✅ Request sent to owner!", Toast.LENGTH_SHORT).show()
                        btnBorrow.text = "Request Pending"
                        btnBorrow.isEnabled = false
                        btnBorrow.setBackgroundColor(android.graphics.Color.GRAY)
                    }
            }
            override fun onCancelled(error: DatabaseError) {}
        })
    }

    private fun fetchItemDetails() {
        FirebaseHelper.itemsRef.child(itemId).addValueEventListener(object : ValueEventListener {
            override fun onDataChange(snapshot: DataSnapshot) {
                val fetchedItem = snapshot.getValue(Item::class.java)
                if (fetchedItem != null) {
                    item = fetchedItem
                    tvItemName.text = fetchedItem.name
                    tvCategory.text = fetchedItem.category

                    if (currentUserEmail == "admin@lendloop.com" || fetchedItem.ownerId == currentUserUid) {
                        etFine.visibility = android.view.View.VISIBLE
                        etRemark.visibility = android.view.View.VISIBLE
                        btnAddFine.visibility = android.view.View.VISIBLE
                    }

                    if (fetchedItem.imageUrl.isNotEmpty()) {
                        Glide.with(this@ItemDetailActivity)
                            .load(fetchedItem.imageUrl)
                            .placeholder(R.drawable.book)
                            .error(R.drawable.book)
                            .into(itemImage)
                    } else {
                        val drawableRes = when {
                            fetchedItem.name.contains("Graphics") -> R.drawable.graphics_kit
                            fetchedItem.name.contains("Lab Coat") -> R.drawable.lab_coat
                            fetchedItem.name.contains("Computer", ignoreCase = true) -> R.drawable.prog_book
                            fetchedItem.name.contains("IT") -> R.drawable.network_book
                            fetchedItem.name.contains("Mechanical", ignoreCase = true) -> R.drawable.physics_book
                            fetchedItem.name.contains("Civil", ignoreCase = true) -> R.drawable.ai_book
                            else -> R.drawable.book
                        }
                        itemImage.setImageResource(drawableRes)
                    }

                    itemImage.clearColorFilter()

                    if (fetchedItem.fine > 0) {
                        tvFineDisplay.visibility = android.view.View.VISIBLE
                        tvFineDisplay.text = "Fine Pending: ₹${fetchedItem.fine}"
                    } else {
                        tvFineDisplay.visibility = android.view.View.GONE
                    }

                    if (fetchedItem.isUserListed && fetchedItem.ownerName.isNotEmpty()) {
                        tvOwnerInfo.visibility = android.view.View.VISIBLE
                        tvOwnerInfo.text = "Owned by: ${fetchedItem.ownerName}\nContact: ${fetchedItem.ownerContact}"
                    } else {
                        tvOwnerInfo.visibility = android.view.View.GONE
                    }

                    if (fetchedItem.available) {
                        btnBorrow.isEnabled = true
                        if (fetchedItem.isUserListed) {
                            if (fetchedItem.ownerId == currentUserUid) {
                                btnBorrow.text = "You are the Owner"
                                btnBorrow.isEnabled = false
                                btnBorrow.setBackgroundColor(android.graphics.Color.GRAY)
                            } else {
                                checkExistingRequest(fetchedItem)
                            }
                        } else {
                            btnBorrow.text = "Borrow Item"
                            btnBorrow.setBackgroundColor(android.graphics.Color.parseColor("#7E57C2"))
                        }
                        tvBorrowedBy.visibility = android.view.View.GONE
                    } else {
                        if (fetchedItem.borrowedBy == currentUserUid) {
                            tvBorrowedBy.visibility = android.view.View.VISIBLE
                            tvBorrowedBy.text = "Borrowed by You"
                            
                            if (!fetchedItem.isUserListed || currentUserEmail == "admin@lendloop.com") {
                                // Allow direct return for Library items OR if admin
                                btnBorrow.isEnabled = true
                                btnBorrow.text = "Return Item"
                                btnBorrow.setBackgroundColor(android.graphics.Color.parseColor("#388E3C"))
                            } else {
                                // Peer-to-peer item: Student can "Request Return"
                                btnBorrow.isEnabled = true
                                btnBorrow.text = "Mark as Returned"
                                btnBorrow.setBackgroundColor(android.graphics.Color.parseColor("#1565C0"))
                                btnBorrow.setOnClickListener {
                                    markAsReturnedRequest(fetchedItem)
                                }
                            }
                        } else {
                            btnBorrow.isEnabled = false
                            btnBorrow.text = "Currently Borrowed"
                            btnBorrow.setBackgroundColor(android.graphics.Color.GRAY)
                            
                            if (fetchedItem.borrowedBy.isNotEmpty() && currentUserEmail == "admin@lendloop.com") {
                                FirebaseHelper.usersRef.child(fetchedItem.borrowedBy).addListenerForSingleValueEvent(object : ValueEventListener {
                                    override fun onDataChange(userSnapshot: DataSnapshot) {
                                        val user = userSnapshot.getValue(User::class.java)
                                        if (user != null) {
                                            tvBorrowedBy.visibility = android.view.View.VISIBLE
                                            tvBorrowedBy.text = "Borrowed By: ${user.name} (${user.branch})"
                                        }
                                    }
                                    override fun onCancelled(error: DatabaseError) {}
                                })
                            } else {
                                tvBorrowedBy.visibility = android.view.View.GONE
                            }
                        }
                    }
                }
            }

            override fun onCancelled(error: DatabaseError) {
                Toast.makeText(this@ItemDetailActivity, "Failed to load data", Toast.LENGTH_SHORT).show()
            }
        })
    }

    private fun checkExistingRequest(item: Item) {
        FirebaseHelper.borrowRequestsRef.child(item.ownerId).child(item.itemId)
            .orderByChild("requesterId").equalTo(currentUserUid)
            .addListenerForSingleValueEvent(object : ValueEventListener {
                override fun onDataChange(snapshot: DataSnapshot) {
                    var status = ""
                    for (child in snapshot.children) {
                        status = child.child("status").getValue(String::class.java) ?: ""
                        if (status == "Pending") break
                    }

                    if (status == "Pending") {
                        btnBorrow.text = "Request Pending"
                        btnBorrow.isEnabled = false
                        btnBorrow.setBackgroundColor(android.graphics.Color.GRAY)
                    } else {
                        btnBorrow.text = "Request to Borrow"
                        btnBorrow.setBackgroundColor(android.graphics.Color.parseColor("#1565C0"))
                    }
                }
                override fun onCancelled(error: DatabaseError) {}
            })
    }

    private fun markAsReturnedRequest(item: Item) {
        FirebaseHelper.borrowRequestsRef.child(item.ownerId).child(item.itemId)
            .orderByChild("requesterId").equalTo(currentUserUid)
            .addListenerForSingleValueEvent(object : ValueEventListener {
                override fun onDataChange(snapshot: DataSnapshot) {
                    var requestId = ""
                    for (child in snapshot.children) {
                        val status = child.child("status").getValue(String::class.java)
                        if (status == "Approved") {
                            requestId = child.key ?: ""
                            break
                        }
                    }

                    if (requestId.isNotEmpty()) {
                        // 1. Update owner's request status
                        FirebaseHelper.borrowRequestsRef.child(item.ownerId).child(item.itemId).child(requestId)
                            .child("status").setValue("Returning")
                        
                        // 2. Update borrower's request status
                        FirebaseHelper.database.getReference("user_requests").child(currentUserUid).child(requestId)
                            .child("status").setValue("Returning")
                            .addOnSuccessListener {
                                Toast.makeText(this@ItemDetailActivity, "Return request sent to owner!", Toast.LENGTH_SHORT).show()
                                btnBorrow.text = "Return Pending"
                                btnBorrow.isEnabled = false
                                btnBorrow.setBackgroundColor(android.graphics.Color.GRAY)
                            }
                    }
                }
                override fun onCancelled(error: DatabaseError) {}
            })
    }
}