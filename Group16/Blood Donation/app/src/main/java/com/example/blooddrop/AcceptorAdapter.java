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

public class AcceptorAdapter extends RecyclerView.Adapter<AcceptorAdapter.ViewHolder> {

    private List<AcceptorModel> list;
    private List<String> keys; // Firebase node keys for deletion

    public AcceptorAdapter(List<AcceptorModel> list, List<String> keys) {
        this.list = list;
        this.keys = keys;
    }

    @NonNull
    @Override
    public ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        View view = LayoutInflater.from(parent.getContext())
                .inflate(R.layout.item_acceptor, parent, false);
        return new ViewHolder(view);
    }

    @Override
    public void onBindViewHolder(@NonNull ViewHolder holder, int position) {
        AcceptorModel a = list.get(position);
        holder.tvHospital.setText(a.hospital != null ? a.hospital : "N/A");
        holder.tvSpeciality.setText(a.speciality != null ? a.speciality : "N/A");
        holder.tvPhone.setText(a.phone != null ? a.phone : "N/A");
        holder.tvEmail.setText(a.email != null ? a.email : "N/A");
        holder.tvAddress.setText(a.address != null ? a.address : "N/A");
        holder.tvLocation.setText(a.location != null ? a.location : "N/A");

        // Delete with confirmation dialog
        holder.btnDelete.setOnClickListener(v -> {
            new AlertDialog.Builder(v.getContext())
                    .setTitle("Delete Acceptor")
                    .setMessage("Are you sure you want to delete " + a.hospital + "?")
                    .setPositiveButton("Delete", (dialog, which) -> {
                        String key = keys.get(holder.getAdapterPosition());
                        DatabaseReference ref = FirebaseDatabase.getInstance()
                                .getReference("Acceptors").child(key);
                        ref.removeValue().addOnCompleteListener(task -> {
                            if (task.isSuccessful()) {
                                int pos = holder.getAdapterPosition();
                                list.remove(pos);
                                keys.remove(pos);
                                notifyItemRemoved(pos);
                                notifyItemRangeChanged(pos, list.size());
                                Toast.makeText(v.getContext(),
                                        "Acceptor deleted", Toast.LENGTH_SHORT).show();
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
        TextView tvHospital, tvSpeciality, tvPhone, tvEmail, tvAddress, tvLocation;
        MaterialButton btnDelete;

        public ViewHolder(@NonNull View itemView) {
            super(itemView);
            tvHospital   = itemView.findViewById(R.id.tvHospital);
            tvSpeciality = itemView.findViewById(R.id.tvSpeciality);
            tvPhone      = itemView.findViewById(R.id.tvPhone);
            tvEmail      = itemView.findViewById(R.id.tvEmail);
            tvAddress    = itemView.findViewById(R.id.tvAddress);
            tvLocation   = itemView.findViewById(R.id.tvLocation);
            btnDelete    = itemView.findViewById(R.id.btnDelete);
        }
    }
}