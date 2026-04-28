package com.example.blooddrop;

import android.app.AlertDialog;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import com.google.android.material.button.MaterialButton;
import com.google.firebase.database.DatabaseReference;
import com.google.firebase.database.FirebaseDatabase;

import java.util.List;

public class DonorAdapter extends RecyclerView.Adapter<DonorAdapter.ViewHolder> {

    private List<DonorModel> list;
    private List<String> keys; // Firebase node keys for deletion

    public DonorAdapter(List<DonorModel> list, List<String> keys) {
        this.list = list;
        this.keys = keys;
    }

    @NonNull
    @Override
    public ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        View view = LayoutInflater.from(parent.getContext())
                .inflate(R.layout.item_donor, parent, false);
        return new ViewHolder(view);
    }

    @Override
    public void onBindViewHolder(@NonNull ViewHolder holder, int position) {
        DonorModel d = list.get(position);
        holder.tvName.setText(d.name != null ? d.name : "N/A");
        holder.tvBlood.setText(d.blood != null ? d.blood : "?");
        holder.tvPhone.setText(d.phone != null ? d.phone : "N/A");
        holder.tvEmail.setText(d.email != null ? d.email : "N/A");
        holder.tvAddress.setText(d.address != null ? d.address : "N/A");
        holder.tvGender.setText(d.gender != null ? d.gender : "N/A");

        // Delete with confirmation dialog
        holder.btnDelete.setOnClickListener(v -> {
            new AlertDialog.Builder(v.getContext())
                    .setTitle("Delete Donor")
                    .setMessage("Are you sure you want to delete " + d.name + "?")
                    .setPositiveButton("Delete", (dialog, which) -> {
                        String key = keys.get(holder.getAdapterPosition());
                        DatabaseReference ref = FirebaseDatabase.getInstance()
                                .getReference("Users").child(key);
                        ref.removeValue().addOnCompleteListener(task -> {
                            if (task.isSuccessful()) {
                                int pos = holder.getAdapterPosition();
                                list.remove(pos);
                                keys.remove(pos);
                                notifyItemRemoved(pos);
                                notifyItemRangeChanged(pos, list.size());
                                Toast.makeText(v.getContext(),
                                        "Donor deleted", Toast.LENGTH_SHORT).show();
                            } else {
                                Toast.makeText(v.getContext(),
                                        "Failed to delete", Toast.LENGTH_SHORT).show();
                            }
                        });
                    })
                    .setNegativeButton("Cancel", null)
                    .show();
        });
    }

    @Override
    public int getItemCount() {
        return list.size();
    }

    public static class ViewHolder extends RecyclerView.ViewHolder {
        TextView tvName, tvBlood, tvPhone, tvEmail, tvAddress, tvGender;
        MaterialButton btnDelete;

        public ViewHolder(@NonNull View itemView) {
            super(itemView);
            tvName    = itemView.findViewById(R.id.tvName);
            tvBlood   = itemView.findViewById(R.id.tvBlood);
            tvPhone   = itemView.findViewById(R.id.tvPhone);
            tvEmail   = itemView.findViewById(R.id.tvEmail);
            tvAddress = itemView.findViewById(R.id.tvAddress);
            tvGender  = itemView.findViewById(R.id.tvGender);
            btnDelete = itemView.findViewById(R.id.btnDelete);
        }
    }
}