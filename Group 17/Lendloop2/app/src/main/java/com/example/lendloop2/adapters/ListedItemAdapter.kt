package com.example.lendloop2.adapters

import android.graphics.Color
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.Button
import android.widget.LinearLayout
import android.widget.TextView
import androidx.recyclerview.widget.RecyclerView
import com.example.lendloop2.R
import com.example.lendloop2.models.BorrowRequest
import com.example.lendloop2.models.Item
import com.example.lendloop2.utils.FirebaseHelper
import com.google.firebase.database.DataSnapshot
import com.google.firebase.database.DatabaseError
import com.google.firebase.database.ValueEventListener

class ListedItemAdapter(
    private val items: MutableList<Item>,
    private val onDelete: (Item) -> Unit
) : RecyclerView.Adapter<ListedItemAdapter.ViewHolder>() {

    private val expandedStates = mutableMapOf<String, Boolean>()

    inner class ViewHolder(view: View) : RecyclerView.ViewHolder(view) {
        val tvName: TextView = view.findViewById(R.id.tvListedItemName)
        val tvCategory: TextView = view.findViewById(R.id.tvListedItemCategory)
        val tvStatus: TextView = view.findViewById(R.id.tvListedItemStatus)
        val tvDesc: TextView = view.findViewById(R.id.tvListedItemDesc)
        val tvContact: TextView = view.findViewById(R.id.tvListedItemContact)
        val tvRequestCount: TextView = view.findViewById(R.id.tvRequestCount)
        val tvExpandArrow: TextView = view.findViewById(R.id.tvExpandArrow)
        val llRequestsToggle: LinearLayout = view.findViewById(R.id.llRequestsToggle)
        val llRequestsContainer: LinearLayout = view.findViewById(R.id.llRequestsContainer)
        val btnDelete: Button = view.findViewById(R.id.btnDeleteListedItem)
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): ViewHolder {
        val view = LayoutInflater.from(parent.context)
            .inflate(R.layout.item_listed, parent, false)
        return ViewHolder(view)
    }

    override fun onBindViewHolder(holder: ViewHolder, position: Int) {
        val item = items[position]

        holder.tvName.text = item.name
        holder.tvCategory.text = item.category
        holder.tvDesc.text = if (item.description.isNotEmpty()) item.description else "No description"
        holder.tvContact.text = "📞 ${item.ownerContact}"

        if (item.available) {
            holder.tvStatus.text = "Available"
            holder.tvStatus.setBackgroundColor(Color.parseColor("#388E3C"))
        } else {
            holder.tvStatus.text = "Not Available"
            holder.tvStatus.setBackgroundColor(Color.parseColor("#F57C00"))
        }

        loadRequests(item, holder)

        val isExpanded = expandedStates[item.itemId] ?: false
        holder.llRequestsContainer.visibility = if (isExpanded) View.VISIBLE else View.GONE
        holder.tvExpandArrow.text = if (isExpanded) "▲" else "▼"

        holder.llRequestsToggle.setOnClickListener {
            val newState = !(expandedStates[item.itemId] ?: false)
            expandedStates[item.itemId] = newState
            holder.llRequestsContainer.visibility = if (newState) View.VISIBLE else View.GONE
            holder.tvExpandArrow.text = if (newState) "▲" else "▼"
        }

        holder.btnDelete.setOnClickListener { onDelete(item) }
    }

    private fun loadRequests(item: Item, holder: ViewHolder) {
        val uid = FirebaseHelper.auth.currentUser?.uid ?: return
        FirebaseHelper.borrowRequestsRef.child(uid).child(item.itemId)
            .addListenerForSingleValueEvent(object : ValueEventListener {
                override fun onDataChange(snapshot: DataSnapshot) {
                    val requests = mutableListOf<BorrowRequest>()
                    for (child in snapshot.children) {
                        val req = child.getValue(BorrowRequest::class.java)
                        if (req != null) requests.add(req)
                    }

                    holder.tvRequestCount.text = "🔔 Borrow Requests (${requests.size})"
                    holder.llRequestsContainer.removeAllViews()
                    val inflater = LayoutInflater.from(holder.itemView.context)

                    if (requests.isEmpty()) {
                        val emptyView = TextView(holder.itemView.context).apply {
                            text = "No borrow requests yet."
                            textSize = 13f
                            setTextColor(Color.parseColor("#AAAAAA"))
                            setPadding(8, 8, 8, 8)
                        }
                        holder.llRequestsContainer.addView(emptyView)
                    } else {
                        for (req in requests) {
                            val reqView = inflater.inflate(R.layout.item_borrow_request, holder.llRequestsContainer, false)
                            reqView.findViewById<TextView>(R.id.tvRequestName).text = req.requesterName
                            reqView.findViewById<TextView>(R.id.tvRequestContact).text = req.requesterContact
                            reqView.findViewById<TextView>(R.id.tvRequestEmail).text = req.requesterEmail
                            reqView.findViewById<TextView>(R.id.tvRequestDate).text = "Requested on: ${req.requestDate}"

                            val tvStatus = reqView.findViewById<TextView>(R.id.tvRequestStatus)
                            tvStatus.text = req.status
                            when (req.status) {
                                "Approved" -> tvStatus.setBackgroundColor(Color.parseColor("#388E3C"))
                                "Rejected" -> tvStatus.setBackgroundColor(Color.parseColor("#D32F2F"))
                                "Returned" -> tvStatus.setBackgroundColor(Color.parseColor("#1565C0"))
                                "Returning" -> tvStatus.setBackgroundColor(Color.parseColor("#FF9800")) // Orange
                                "Broken" -> tvStatus.setBackgroundColor(Color.parseColor("#424242"))
                                else -> tvStatus.setBackgroundColor(Color.parseColor("#F57C00"))
                            }

                            val llApproveReject = reqView.findViewById<LinearLayout>(R.id.llApproveRejectButtons)
                            val llResolve = reqView.findViewById<LinearLayout>(R.id.llResolveRequest)
                            val btnMarkReturned = reqView.findViewById<Button>(R.id.btnMarkReturned)
                            val btnMarkBroken = reqView.findViewById<Button>(R.id.btnMarkBroken)
                            val etFine = reqView.findViewById<android.widget.EditText>(R.id.etRequestFine)

                            when (req.status) {
                                "Approved", "Returning" -> {
                                    llApproveReject.visibility = View.GONE
                                    llResolve.visibility = View.VISIBLE
                                    
                                    if (req.status == "Returning") {
                                        btnMarkReturned.text = "✅ Confirm Return"
                                    } else {
                                        btnMarkReturned.text = "✅ Mark as Returned"
                                    }

                                    btnMarkReturned.setOnClickListener {
                                        val fine = etFine.text.toString().toIntOrNull() ?: 0
                                        markItemReturned(uid, item.itemId, req.requestId, req.requesterId, fine, item, holder)
                                    }
                                    
                                    btnMarkBroken.setOnClickListener {
                                        val fine = etFine.text.toString().toIntOrNull() ?: 0
                                        markItemBroken(uid, item.itemId, req.requestId, req.requesterId, fine, item, holder)
                                    }
                                }
                                "Returned", "Rejected", "Broken" -> {
                                    llApproveReject.visibility = View.GONE
                                    llResolve.visibility = View.GONE
                                }
                                else -> {
                                    llApproveReject.visibility = View.VISIBLE
                                    llResolve.visibility = View.GONE
                                    reqView.findViewById<Button>(R.id.btnApproveRequest).setOnClickListener {
                                        updateRequestStatus(uid, item.itemId, req.requestId, "Approved")
                                        loadRequests(item, holder)
                                    }
                                    reqView.findViewById<Button>(R.id.btnRejectRequest).setOnClickListener {
                                        updateRequestStatus(uid, item.itemId, req.requestId, "Rejected")
                                        loadRequests(item, holder)
                                    }
                                }
                            }
                            holder.llRequestsContainer.addView(reqView)
                        }
                    }
                }
                override fun onCancelled(error: DatabaseError) {}
            })
    }

    private fun markItemReturned(ownerId: String, itemId: String, requestId: String, requesterId: String, fine: Int, item: Item, holder: ViewHolder) {
        // 1. Update owner's request status
        FirebaseHelper.borrowRequestsRef.child(ownerId).child(itemId).child(requestId)
            .child("status").setValue("Returned")
        
        // 2. Update borrower's request status and fine
        val borrowerRef = FirebaseHelper.database.getReference("user_requests").child(requesterId).child(requestId)
        borrowerRef.child("status").setValue("Returned")
        borrowerRef.child("fine").setValue(fine)

        // 3. Clear borrower ID and set fine
        FirebaseHelper.itemsRef.child(itemId).child("borrowedBy").setValue("")
        FirebaseHelper.itemsRef.child(itemId).child("fine").setValue(fine)
        if (fine > 0) {
            FirebaseHelper.itemsRef.child(itemId).child("remark").setValue("Fine applied after return.")
        }

        // 4. Make the item available again
        FirebaseHelper.itemsRef.child(itemId).child("available").setValue(true)
        
        loadRequests(item, holder)
    }

    private fun markItemBroken(ownerId: String, itemId: String, requestId: String, requesterId: String, fine: Int, item: Item, holder: ViewHolder) {
        // 1. Update status in both places
        FirebaseHelper.borrowRequestsRef.child(ownerId).child(itemId).child(requestId)
            .child("status").setValue("Broken")
        
        val borrowerRef = FirebaseHelper.database.getReference("user_requests").child(requesterId).child(requestId)
        borrowerRef.child("status").setValue("Broken")
        borrowerRef.child("fine").setValue(fine)

        // 2. Keep borrower ID (accountability) and set fine
        FirebaseHelper.itemsRef.child(itemId).child("fine").setValue(fine)
        FirebaseHelper.itemsRef.child(itemId).child("remark").setValue("Item marked as Broken/Damaged by owner.")

        // 3. Keep as NOT available and mark as Broken
        FirebaseHelper.itemsRef.child(itemId).child("available").setValue(false)
        FirebaseHelper.itemsRef.child(itemId).child("isBroken").setValue(true)

        loadRequests(item, holder)
    }

    private fun updateRequestStatus(ownerId: String, itemId: String, requestId: String, status: String) {
        // 1. Update owner's request status
        FirebaseHelper.borrowRequestsRef.child(ownerId).child(itemId).child(requestId)
            .child("status").setValue(status)

        // 2. Fetch the request to identify the borrower
        FirebaseHelper.borrowRequestsRef.child(ownerId).child(itemId).child(requestId)
            .addListenerForSingleValueEvent(object : ValueEventListener {
                override fun onDataChange(snapshot: DataSnapshot) {
                    val req = snapshot.getValue(BorrowRequest::class.java) ?: return
                    
                    // 3. Update borrower's request status
                    FirebaseHelper.database.getReference("user_requests").child(req.requesterId).child(requestId)
                        .child("status").setValue(status)

                    if (status == "Approved") {
                        // 4. Mark item as unavailable
                        FirebaseHelper.itemsRef.child(itemId).child("available").setValue(false)
                        FirebaseHelper.itemsRef.child(itemId).child("borrowedBy").setValue(req.requesterId)
                    }
                }
                override fun onCancelled(error: DatabaseError) {}
            })

            FirebaseHelper.borrowRequestsRef.child(ownerId).child(itemId)
                .get().addOnSuccessListener { snapshot ->
                    for (child in snapshot.children) {
                        val otherRequestId = child.key ?: continue
                        if (otherRequestId == requestId) continue
                        val currentStatus = child.child("status").getValue(String::class.java)
                        if (currentStatus == "Pending") {
                            FirebaseHelper.borrowRequestsRef.child(ownerId).child(itemId).child(otherRequestId)
                                .child("status").setValue("Rejected")
                        }
                    }
                }
    }

    override fun getItemCount() = items.size

    fun setItems(newItems: List<Item>) {
        items.clear()
        items.addAll(newItems)
        notifyDataSetChanged()
    }
}
