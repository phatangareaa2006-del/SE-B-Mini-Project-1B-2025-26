package com.example.blooddrop;

import android.app.AlertDialog;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.os.Bundle;
import android.util.Base64;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.ImageView;
import android.widget.TextView;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.google.android.material.button.MaterialButton;
import com.google.firebase.database.DataSnapshot;
import com.google.firebase.database.DatabaseError;
import com.google.firebase.database.DatabaseReference;
import com.google.firebase.database.FirebaseDatabase;
import com.google.firebase.database.ValueEventListener;

import java.util.ArrayList;
import java.util.List;

public class AdminVerifyActivity extends AppCompatActivity {

    RecyclerView recyclerPending;
    TextView tvPendingCount, tvEmpty;
    DatabaseReference usersRef;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_admin_verify);

        recyclerPending = findViewById(R.id.recyclerPending);
        tvPendingCount  = findViewById(R.id.tvPendingCount);
        tvEmpty         = findViewById(R.id.tvEmpty);

        recyclerPending.setLayoutManager(new LinearLayoutManager(this));
        usersRef = FirebaseDatabase.getInstance().getReference("Users");

        loadPendingUsers();
    }

    private void loadPendingUsers() {
        usersRef.addValueEventListener(new ValueEventListener() {

            @Override
            public void onDataChange(DataSnapshot snapshot) {
                List<DataSnapshot> pendingList = new ArrayList<>();
                for (DataSnapshot data : snapshot.getChildren()) {
                    String status = data.child("status").getValue(String.class);
                    if ("pending".equalsIgnoreCase(status)) {
                        pendingList.add(data);
                    }
                }

                if (pendingList.isEmpty()) {
                    tvEmpty.setVisibility(View.VISIBLE);
                    recyclerPending.setVisibility(View.GONE);
                    tvPendingCount.setText("No pending verifications");
                } else {
                    tvEmpty.setVisibility(View.GONE);
                    recyclerPending.setVisibility(View.VISIBLE);
                    tvPendingCount.setText(pendingList.size() + " pending verification(s)");
                    recyclerPending.setAdapter(new PendingAdapter(pendingList));
                }
            }

            @Override
            public void onCancelled(DatabaseError error) {
                Toast.makeText(AdminVerifyActivity.this,
                        "Failed to load", Toast.LENGTH_SHORT).show();
            }
        });
    }

    // ✅ Convert Base64 string back to Bitmap for display
    private Bitmap base64ToBitmap(String base64) {
        try {
            byte[] bytes = Base64.decode(base64, Base64.DEFAULT);
            return BitmapFactory.decodeByteArray(bytes, 0, bytes.length);
        } catch (Exception e) {
            return null;
        }
    }

    // ✅ Show image in a dialog
    private void showImageDialog(String title, String base64) {
        if (base64 == null) {
            Toast.makeText(this, "Document not uploaded", Toast.LENGTH_SHORT).show();
            return;
        }

        Bitmap bitmap = base64ToBitmap(base64);
        if (bitmap == null) {
            Toast.makeText(this, "Could not load image", Toast.LENGTH_SHORT).show();
            return;
        }

        ImageView imageView = new ImageView(this);
        imageView.setImageBitmap(bitmap);
        imageView.setAdjustViewBounds(true);
        imageView.setPadding(16, 16, 16, 16);

        new AlertDialog.Builder(this)
                .setTitle(title)
                .setView(imageView)
                .setPositiveButton("Close", null)
                .show();
    }

    class PendingAdapter extends RecyclerView.Adapter<PendingAdapter.VH> {

        List<DataSnapshot> list;

        PendingAdapter(List<DataSnapshot> list) { this.list = list; }

        @NonNull
        @Override
        public VH onCreateViewHolder(@NonNull android.view.ViewGroup parent, int viewType) {
            View v = LayoutInflater.from(parent.getContext())
                    .inflate(R.layout.item_pending_user, parent, false);
            return new VH(v);
        }

        @Override
        public void onBindViewHolder(@NonNull VH holder, int position) {
            DataSnapshot data = list.get(position);

            String username     = data.getKey();
            String name         = data.child("name").getValue(String.class);
            String phone        = data.child("phone").getValue(String.class);
            String email        = data.child("email").getValue(String.class);
            String blood        = data.child("blood").getValue(String.class);
            String aadharBase64 = data.child("aadharBase64").getValue(String.class);
            String healthBase64 = data.child("healthBase64").getValue(String.class);

            holder.tvUserName.setText(name != null ? name : username);
            holder.tvUserPhone.setText(phone != null ? phone : "N/A");
            holder.tvUserEmail.setText(email != null ? email : "N/A");
            holder.tvBloodBadge.setText(blood != null ? blood : "?");

            // ✅ View documents dialog — shows image inline
            holder.btnViewReport.setOnClickListener(v -> {
                String[] options = {"View Aadhar Card", "View Health Certificate"};
                new AlertDialog.Builder(AdminVerifyActivity.this)
                        .setTitle("View Documents")
                        .setItems(options, (dialog, which) -> {
                            if (which == 0) {
                                showImageDialog("Aadhar Card", aadharBase64);
                            } else {
                                showImageDialog("Health Certificate", healthBase64);
                            }
                        })
                        .show();
            });

            // ✅ Approve
            holder.btnApprove.setOnClickListener(v ->
                    new AlertDialog.Builder(AdminVerifyActivity.this)
                            .setTitle("Approve Donor?")
                            .setMessage("Approve " + (name != null ? name : username) +
                                    "?\nThey will be able to login.")
                            .setPositiveButton("Approve", (d, w) ->
                                    usersRef.child(username).child("status").setValue("approved")
                                            .addOnSuccessListener(unused ->
                                                    Toast.makeText(AdminVerifyActivity.this,
                                                            "Approved!", Toast.LENGTH_SHORT).show()
                                            )
                            )
                            .setNegativeButton("Cancel", null)
                            .show()
            );

            // ✅ Reject
            holder.btnReject.setOnClickListener(v ->
                    new AlertDialog.Builder(AdminVerifyActivity.this)
                            .setTitle("Reject Donor?")
                            .setMessage("Reject " + (name != null ? name : username) +
                                    "?\nThey will NOT be able to login.")
                            .setPositiveButton("Reject", (d, w) ->
                                    usersRef.child(username).child("status").setValue("rejected")
                                            .addOnSuccessListener(unused ->
                                                    Toast.makeText(AdminVerifyActivity.this,
                                                            "Rejected.", Toast.LENGTH_SHORT).show()
                                            )
                            )
                            .setNegativeButton("Cancel", null)
                            .show()
            );
        }

        @Override
        public int getItemCount() { return list.size(); }

        class VH extends RecyclerView.ViewHolder {
            TextView tvUserName, tvUserPhone, tvUserEmail, tvBloodBadge;
            MaterialButton btnViewReport, btnApprove, btnReject;

            VH(View v) {
                super(v);
                tvUserName    = v.findViewById(R.id.tvUserName);
                tvUserPhone   = v.findViewById(R.id.tvUserPhone);
                tvUserEmail   = v.findViewById(R.id.tvUserEmail);
                tvBloodBadge  = v.findViewById(R.id.tvBloodBadge);
                btnViewReport = v.findViewById(R.id.btnViewReport);
                btnApprove    = v.findViewById(R.id.btnApprove);
                btnReject     = v.findViewById(R.id.btnReject);
            }
        }
    }
}