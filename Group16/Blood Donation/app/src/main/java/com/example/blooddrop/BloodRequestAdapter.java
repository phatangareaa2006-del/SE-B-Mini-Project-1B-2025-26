package com.example.blooddrop;

import android.app.AlertDialog;
import android.content.Context;
import android.content.Intent;
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

public class BloodRequestAdapter extends RecyclerView.Adapter<BloodRequestAdapter.ViewHolder> {

    private List<BloodRequestModel> list;
    private String username;       // logged in donor's username
    private boolean canDonate;
    private long nextDonationTime;
    private String mode;           // "donor" or "acceptor"

    public BloodRequestAdapter(List<BloodRequestModel> list, String username,
                               boolean canDonate, long nextDonationTime, String mode) {
        this.list             = list;
        this.username         = username;
        this.canDonate        = canDonate;
        this.nextDonationTime = nextDonationTime;
        this.mode             = mode;
    }

    public void updateCooldown(boolean canDonate, long nextDonationTime) {
        this.canDonate        = canDonate;
        this.nextDonationTime = nextDonationTime;
        notifyDataSetChanged();
    }

    @NonNull
    @Override
    public ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        View view = LayoutInflater.from(parent.getContext())
                .inflate(R.layout.item_blood_request, parent, false);
        return new ViewHolder(view);
    }

    @Override
    public void onBindViewHolder(@NonNull ViewHolder holder, int position) {
        BloodRequestModel r = list.get(position);
        Context ctx = holder.itemView.getContext();

        holder.tvPatient.setText(r.patient != null ? r.patient : "N/A");
        holder.tvBlood.setText(r.blood != null ? r.blood : "?");
        holder.tvUnits.setText(r.units != null ? r.units : "?");
        holder.tvHospital.setText(r.hospital != null ? r.hospital : "N/A");
        holder.tvStatus.setText(r.status != null ? r.status : "Pending");

        // Reset all buttons
        holder.btnAccept.setVisibility(View.GONE);
        holder.btnBloodDonated.setVisibility(View.GONE);
        holder.btnCertificate.setVisibility(View.GONE);

        // Status color
        if ("Donated".equalsIgnoreCase(r.status)) {
            holder.tvStatus.setTextColor(0xFF4CAF50);
        } else if ("Accepted".equalsIgnoreCase(r.status)) {
            holder.tvStatus.setTextColor(0xFF1565C0);
        } else {
            holder.tvStatus.setTextColor(0xFFD70404);
        }

        if ("donor".equals(mode)) {
            // ────── DONOR MODE ──────

            if ("Donated".equalsIgnoreCase(r.status)) {

                // ✅ Only show certificate to the donor who accepted this request
                if (username != null && username.equals(r.donorName)) {
                    holder.btnCertificate.setVisibility(View.VISIBLE);
                    holder.btnCertificate.setOnClickListener(v -> {
                        Intent intent = new Intent(ctx, CertificateActivity.class);
                        intent.putExtra("donorName", username);
                        intent.putExtra("patient",  r.patient);
                        intent.putExtra("blood",    r.blood);
                        intent.putExtra("units",    r.units);
                        intent.putExtra("hospital", r.hospital);
                        ctx.startActivity(intent);
                    });
                } else {
                    // Another donor — just show donated status, no certificate
                    holder.btnAccept.setVisibility(View.VISIBLE);
                    holder.btnAccept.setText("Donated");
                    holder.btnAccept.setEnabled(false);
                    holder.btnAccept.setAlpha(0.5f);
                }

            } else if ("Accepted".equalsIgnoreCase(r.status)) {

                // ✅ Only show "Accepted ✓" to the donor who accepted it
                if (username != null && username.equals(r.donorName)) {
                    holder.btnAccept.setVisibility(View.VISIBLE);
                    holder.btnAccept.setText("Accepted by You ✓");
                    holder.btnAccept.setEnabled(false);
                    holder.btnAccept.setAlpha(0.6f);
                } else {
                    // Another donor already accepted — hide from others
                    holder.btnAccept.setVisibility(View.VISIBLE);
                    holder.btnAccept.setText("Already Taken");
                    holder.btnAccept.setEnabled(false);
                    holder.btnAccept.setAlpha(0.4f);
                }

            } else {
                // Pending — show Accept button to all donors
                holder.btnAccept.setVisibility(View.VISIBLE);
                holder.btnAccept.setText("Accept Request");
                holder.btnAccept.setEnabled(true);
                holder.btnAccept.setAlpha(1f);

                holder.btnAccept.setOnClickListener(v -> {

                    // Cooldown check
                    if (!canDonate) {
                        long daysLeft = (nextDonationTime - System.currentTimeMillis())
                                / (1000L * 60 * 60 * 24);
                        new AlertDialog.Builder(ctx)
                                .setTitle("Cannot Donate Yet")
                                .setMessage(
                                        "You have recently donated blood.\n\n" +
                                                "For your health and safety, you must wait " +
                                                "90 days between donations.\n\n" +
                                                "You can donate again in " + daysLeft + " day(s)."
                                )
                                .setPositiveButton("OK", null)
                                .setIcon(android.R.drawable.ic_dialog_alert)
                                .show();
                        return;
                    }

                    // Confirm accept
                    new AlertDialog.Builder(ctx)
                            .setTitle("Accept Request?")
                            .setMessage(
                                    "Patient: " + r.patient + "\n" +
                                            "Blood Group: " + r.blood + "\n" +
                                            "Hospital: " + r.hospital + "\n\n" +
                                            "Are you sure you want to accept this request?"
                            )
                            .setPositiveButton("Yes, Accept", (dialog, which) -> {
                                DatabaseReference requestRef = FirebaseDatabase.getInstance()
                                        .getReference("BloodRequests").child(r.key);
                                requestRef.child("status").setValue("Accepted");

                                // ✅ Save THIS donor's username against the request
                                requestRef.child("donorName").setValue(username);

                                long now = System.currentTimeMillis();
                                FirebaseDatabase.getInstance()
                                        .getReference("Users").child(username)
                                        .child("lastDonation").setValue(now);

                                r.status         = "Accepted";
                                r.donorName      = username;
                                canDonate        = false;
                                nextDonationTime = now + (90L * 24 * 60 * 60 * 1000);
                                notifyItemChanged(position);

                                Toast.makeText(ctx,
                                        "Request Accepted! Thank you for saving a life!",
                                        Toast.LENGTH_LONG).show();
                            })
                            .setNegativeButton("Cancel", null)
                            .show();
                });
            }

        } else if ("acceptor".equals(mode)) {
            // ────── ACCEPTOR MODE ──────
            if ("Donated".equalsIgnoreCase(r.status)) {
                holder.btnBloodDonated.setVisibility(View.VISIBLE);
                holder.btnBloodDonated.setText("Donation Confirmed");
                holder.btnBloodDonated.setEnabled(false);
                holder.btnBloodDonated.setAlpha(0.6f);

            } else if ("Accepted".equalsIgnoreCase(r.status)) {
                holder.btnBloodDonated.setVisibility(View.VISIBLE);
                holder.btnBloodDonated.setOnClickListener(v -> {
                    new AlertDialog.Builder(ctx)
                            .setTitle("Confirm Blood Donated?")
                            .setMessage(
                                    "Confirm that donor " +
                                            (r.donorName != null ? r.donorName : "unknown") +
                                            " has physically donated blood for:\n\n" +
                                            "Patient: " + r.patient + "\n" +
                                            "Blood Group: " + r.blood + "\n" +
                                            "Hospital: " + r.hospital + "\n\n" +
                                            "This will generate a certificate for the donor."
                            )
                            .setPositiveButton("Yes, Confirm", (dialog, which) -> {
                                FirebaseDatabase.getInstance()
                                        .getReference("BloodRequests")
                                        .child(r.key).child("status").setValue("Donated");
                                r.status = "Donated";
                                notifyItemChanged(position);
                                Toast.makeText(ctx,
                                        "Donation confirmed! Donor can now get certificate.",
                                        Toast.LENGTH_LONG).show();
                            })
                            .setNegativeButton("Cancel", null)
                            .show();
                });

            } else {
                holder.btnAccept.setVisibility(View.VISIBLE);
                holder.btnAccept.setText("Awaiting Donor");
                holder.btnAccept.setEnabled(false);
                holder.btnAccept.setAlpha(0.4f);
            }
        }
    }

    @Override
    public int getItemCount() { return list.size(); }

    public static class ViewHolder extends RecyclerView.ViewHolder {
        TextView tvPatient, tvBlood, tvUnits, tvHospital, tvStatus;
        MaterialButton btnAccept, btnBloodDonated, btnCertificate;

        public ViewHolder(@NonNull View itemView) {
            super(itemView);
            tvPatient       = itemView.findViewById(R.id.tvPatient);
            tvBlood         = itemView.findViewById(R.id.tvBlood);
            tvUnits         = itemView.findViewById(R.id.tvUnits);
            tvHospital      = itemView.findViewById(R.id.tvHospital);
            tvStatus        = itemView.findViewById(R.id.tvStatus);
            btnAccept       = itemView.findViewById(R.id.btnAccept);
            btnBloodDonated = itemView.findViewById(R.id.btnBloodDonated);
            btnCertificate  = itemView.findViewById(R.id.btnCertificate);
        }
    }
}