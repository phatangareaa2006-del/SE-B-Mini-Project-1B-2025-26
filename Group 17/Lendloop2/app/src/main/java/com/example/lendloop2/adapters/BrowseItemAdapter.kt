package com.example.lendloop2.adapters

import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.Button
import android.widget.ImageView
import android.widget.TextView
import androidx.recyclerview.widget.RecyclerView
import com.bumptech.glide.Glide
import com.example.lendloop2.R
import com.example.lendloop2.models.Item

class BrowseItemAdapter(
    private val items: MutableList<Item>,
    private val currentUserId: String,
    private val onRequest: (Item) -> Unit
) : RecyclerView.Adapter<BrowseItemAdapter.ViewHolder>() {

    inner class ViewHolder(view: View) : RecyclerView.ViewHolder(view) {
        val ivItemImage: ImageView = view.findViewById(R.id.ivBrowseItemImage)
        val tvName: TextView = view.findViewById(R.id.tvBrowseItemName)
        val tvCategory: TextView = view.findViewById(R.id.tvBrowseItemCategory)
        val tvStatus: TextView = view.findViewById(R.id.tvBrowseItemStatus)
        val tvDesc: TextView = view.findViewById(R.id.tvBrowseItemDesc)
        val tvOwnerName: TextView = view.findViewById(R.id.tvBrowseOwnerName)
        val tvOwnerContact: TextView = view.findViewById(R.id.tvBrowseOwnerContact)
        val btnRequest: Button = view.findViewById(R.id.btnRequestBorrow)
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): ViewHolder {
        val view = LayoutInflater.from(parent.context)
            .inflate(R.layout.item_browse, parent, false)
        return ViewHolder(view)
    }

    override fun onBindViewHolder(holder: ViewHolder, position: Int) {
        val item = items[position]

        if (item.imageUrl.isNotEmpty()) {
            holder.ivItemImage.visibility = View.VISIBLE
            Glide.with(holder.itemView.context)
                .load(item.imageUrl)
                .placeholder(R.drawable.book)
                .error(R.drawable.book)
                .into(holder.ivItemImage)
        } else {
            holder.ivItemImage.visibility = View.GONE
        }

        holder.tvName.text = item.name
        holder.tvCategory.text = item.category
        holder.tvDesc.text = if (item.description.isNotEmpty()) item.description else "No description"
        holder.tvOwnerName.text = item.ownerName
        holder.tvOwnerContact.text = "📞 ${item.ownerContact}"

        if (item.available) {
            holder.tvStatus.text = "Available"
            holder.tvStatus.setBackgroundColor(android.graphics.Color.parseColor("#388E3C"))
        } else {
            holder.tvStatus.text = "Not Available"
            holder.tvStatus.setBackgroundColor(android.graphics.Color.parseColor("#F57C00"))
        }

        // Hide request button for your own items
        if (item.ownerId == currentUserId) {
            holder.btnRequest.text = "Your Item"
            holder.btnRequest.isEnabled = false
            holder.btnRequest.alpha = 0.5f
        } else {
            holder.btnRequest.text = "Request"
            holder.btnRequest.isEnabled = item.available
            holder.btnRequest.alpha = if (item.available) 1f else 0.5f
            holder.btnRequest.setOnClickListener { onRequest(item) }
        }
    }

    override fun getItemCount() = items.size

    fun setItems(newItems: List<Item>) {
        items.clear()
        items.addAll(newItems)
        notifyDataSetChanged()
    }
}
