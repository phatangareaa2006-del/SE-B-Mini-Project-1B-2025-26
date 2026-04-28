package com.example.blooddrop;

import android.content.Intent;
import android.os.Bundle;
import android.widget.TextView;

import androidx.appcompat.app.AppCompatActivity;
import androidx.cardview.widget.CardView;

public class DonorDashboardActivity extends AppCompatActivity {

    // ✅ Changed from Button to CardView to match redesigned XML
    CardView btnRequests, btnProfile;
    TextView tvUsername;
    String username;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_donor_dashboard);

        btnRequests = findViewById(R.id.btnRequests);
        btnProfile  = findViewById(R.id.btnProfile);
        tvUsername  = findViewById(R.id.tvUsername);

        username = getIntent().getStringExtra("username");

        // ✅ Show welcome message with username
        if (username != null) {
            tvUsername.setText("Welcome, " + username);
        }

        btnRequests.setOnClickListener(v -> {
            Intent intent = new Intent(DonorDashboardActivity.this, DonorRequestsActivity.class);
            intent.putExtra("username", username);
            startActivity(intent);
        });

        btnProfile.setOnClickListener(v -> {
            Intent intent = new Intent(DonorDashboardActivity.this, DonorProfileActivity.class);
            intent.putExtra("username", username);
            startActivity(intent);
        });
    }
}