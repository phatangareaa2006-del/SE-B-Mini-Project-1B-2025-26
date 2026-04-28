package com.example.blooddrop;

import android.content.Intent;
import android.os.Bundle;
import android.widget.TextView;

import androidx.appcompat.app.AppCompatActivity;
import androidx.cardview.widget.CardView;

import com.google.firebase.database.DataSnapshot;
import com.google.firebase.database.DatabaseError;
import com.google.firebase.database.DatabaseReference;
import com.google.firebase.database.FirebaseDatabase;
import com.google.firebase.database.ValueEventListener;

public class AdminChoiceActivity extends AppCompatActivity {

    CardView btnDonors, btnAcceptors, btnVerify;
    TextView tvDonorCount, tvAcceptorCount, tvPendingBadge;
    DatabaseReference dbDonors, dbAcceptors;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_admin_choice);

        btnDonors      = findViewById(R.id.btnDonors);
        btnAcceptors   = findViewById(R.id.btnAcceptors);
        btnVerify      = findViewById(R.id.btnVerify);
        tvDonorCount   = findViewById(R.id.tvDonorCount);
        tvAcceptorCount= findViewById(R.id.tvAcceptorCount);
        tvPendingBadge = findViewById(R.id.tvPendingBadge);

        dbDonors    = FirebaseDatabase.getInstance().getReference("Users");
        dbAcceptors = FirebaseDatabase.getInstance().getReference("Acceptors");

        // Load donor count
        dbDonors.addValueEventListener(new ValueEventListener() {
            @Override
            public void onDataChange(DataSnapshot snapshot) {
                int total   = 0;
                int pending = 0;
                for (DataSnapshot d : snapshot.getChildren()) {
                    total++;
                    String status = d.child("status").getValue(String.class);
                    if ("pending".equalsIgnoreCase(status)) pending++;
                }
                tvDonorCount.setText(String.valueOf(total));
                // ✅ Show pending badge count
                if (tvPendingBadge != null) {
                    tvPendingBadge.setText(pending + " pending");
                }
            }
            @Override public void onCancelled(DatabaseError e) { tvDonorCount.setText("—"); }
        });

        // Load acceptor count
        dbAcceptors.addValueEventListener(new ValueEventListener() {
            @Override
            public void onDataChange(DataSnapshot snapshot) {
                tvAcceptorCount.setText(String.valueOf(snapshot.getChildrenCount()));
            }
            @Override public void onCancelled(DatabaseError e) { tvAcceptorCount.setText("—"); }
        });

        btnDonors.setOnClickListener(v ->
                startActivity(new Intent(this, AdminDonorActivity.class)));

        btnAcceptors.setOnClickListener(v ->
                startActivity(new Intent(this, AdminAcceptorActivity.class)));

        // ✅ New: go to verification screen
        btnVerify.setOnClickListener(v ->
                startActivity(new Intent(this, AdminVerifyActivity.class)));
    }
}