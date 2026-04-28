package com.example.lendloop2.adapters

import android.graphics.Color
import android.graphics.drawable.GradientDrawable
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.TextView
import androidx.recyclerview.widget.RecyclerView
import com.example.lendloop2.R
import com.example.lendloop2.models.BorrowRequest

class RequestAdapter(private val requests: List<BorrowRequest>) : 
    RecyclerView.Adapter<RequestAdapter.ViewHolder>() {

    class ViewHolder(view: View) : RecyclerView.ViewHolder(view) {
        val tvItemName: TextView = view.findViewById(R.id.tvReqItemName)
        val tvStatus: TextView = view.findViewById(R.id.tvReqStatusBadge)
        val tvDate: TextView = view.findViewById(R.id.tvReqDate)
        val llFine: View = view.findViewById(R.id.llFineInfo)
        val tvFine: TextView = view.findViewById(R.id.tvReqFineAmount)
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): ViewHolder {
        val view = LayoutInflater.from(parent.context).inflate(R.layout.item_request_card, parent, false)
        return ViewHolder(view)
    }

    override fun onBindViewHolder(holder: ViewHolder, position: Int) {
        val req = requests[position]
        holder.tvItemName.text = req.itemName
        holder.tvDate.text = "Requested on: ${req.requestDate}"
        holder.tvStatus.text = req.status

        // Set status color
        val color = when (req.status) {
            "Approved" -> "#388E3C"
            "Rejected" -> "#D32F2F"
            "Returned" -> "#1565C0"
            "Returning"-> "#FF9800"
            "Broken"   -> "#424242"
            else        -> "#F57C00" // Pending
        }
        
        val background = holder.tvStatus.background as GradientDrawable
        background.setColor(Color.parseColor(color))

        if (req.fine > 0) {
            holder.llFine.visibility = View.VISIBLE
            holder.tvFine.text = "₹${req.fine}"
        } else {
            holder.llFine.visibility = View.GONE
        }
    }

    override fun getItemCount() = requests.size
}
