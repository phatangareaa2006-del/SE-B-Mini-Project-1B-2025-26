package com.example.lendloop2.adapters

import android.view.LayoutInflater
import android.view.ViewGroup
import androidx.recyclerview.widget.RecyclerView
import com.bumptech.glide.Glide
import com.example.lendloop2.databinding.ItemResourceBinding
import com.example.lendloop2.models.Item
import com.example.lendloop2.R

class ItemAdapter(
    private val itemList: List<Item>
) : RecyclerView.Adapter<ItemAdapter.ItemViewHolder>() {

    class ItemViewHolder(val binding: ItemResourceBinding) :
        RecyclerView.ViewHolder(binding.root)

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): ItemViewHolder {

        val binding = ItemResourceBinding.inflate(
            LayoutInflater.from(parent.context),
            parent,
            false
        )

        return ItemViewHolder(binding)
    }

    override fun onBindViewHolder(holder: ItemViewHolder, position: Int) {

        val item = itemList[position]

        holder.binding.tvItemName.text = item.name
        holder.binding.tvCategory.text = item.category

        if (item.imageUrl.isNotEmpty()) {
            Glide.with(holder.itemView.context)
                .load(item.imageUrl)
                .placeholder(R.drawable.book)
                .error(R.drawable.book)
                .into(holder.binding.itemImage)
        } else {
            // Fallback to local resources for default items
            if (item.name.contains("Graphics")) {
                holder.binding.itemImage.setImageResource(R.drawable.graphics_kit)
            } else if (item.name.contains("Lab Coat")) {
                holder.binding.itemImage.setImageResource(R.drawable.lab_coat)
            } else if (item.name.contains("Computer", ignoreCase = true)) {
                holder.binding.itemImage.setImageResource(R.drawable.prog_book)
            } else if (item.name.contains("IT")) {
                holder.binding.itemImage.setImageResource(R.drawable.network_book)
            } else if (item.name.contains("Mechanical", ignoreCase = true)) {
                holder.binding.itemImage.setImageResource(R.drawable.physics_book)
            } else if (item.name.contains("Civil", ignoreCase = true)) {
                holder.binding.itemImage.setImageResource(R.drawable.ai_book)
            } else {
                holder.binding.itemImage.setImageResource(R.drawable.book)
            }
        }

        // Clear existing filter before recycling
        holder.binding.itemImage.clearColorFilter()

        // Manage Availability Badge
        if (item.available) {
            holder.binding.tvAvailability.text = "Available"
            holder.binding.tvAvailability.setTextColor(android.graphics.Color.parseColor("#2E7D32"))
        } else {
            holder.binding.tvAvailability.text = "Unavailable"
            holder.binding.tvAvailability.setTextColor(android.graphics.Color.parseColor("#D32F2F"))
        }

        if (item.isUserListed && item.ownerName.isNotEmpty()) {
            holder.binding.tvOwner.visibility = android.view.View.VISIBLE
            holder.binding.tvOwner.text = "Owner: ${item.ownerName}"
        } else {
            holder.binding.tvOwner.visibility = android.view.View.GONE
        }

        holder.itemView.setOnClickListener {
            val intent = android.content.Intent(holder.itemView.context, com.example.lendloop2.ItemDetailActivity::class.java)
            intent.putExtra("itemId", item.itemId)
            holder.itemView.context.startActivity(intent)
        }
    }

    override fun getItemCount(): Int {

        return itemList.size

    }
}