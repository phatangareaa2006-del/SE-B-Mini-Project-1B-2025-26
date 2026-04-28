package com.example.blooddrop;

import android.os.Bundle;
import android.widget.TextView;

import androidx.appcompat.app.AppCompatActivity;

import com.google.firebase.database.DataSnapshot;
import com.google.firebase.database.DatabaseError;
import com.google.firebase.database.DatabaseReference;
import com.google.firebase.database.FirebaseDatabase;
import com.google.firebase.database.ValueEventListener;

public class DonorProfileActivity extends AppCompatActivity {

    TextView tvProfileName, tvProfileBlood, tvProfilePhone,
            tvProfileEmail, tvProfileAddress, tvProfileUsername,
            tvDonationCount, tvLivesSaved, tvFooterMessage;

    DatabaseReference databaseReference, requestsRef;
    String username;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_donor_profile);

        tvProfileName     = findViewById(R.id.tvProfileName);
        tvProfileBlood    = findViewById(R.id.tvProfileBlood);
        tvProfilePhone    = findViewById(R.id.tvProfilePhone);
        tvProfileEmail    = findViewById(R.id.tvProfileEmail);
        tvProfileAddress  = findViewById(R.id.tvProfileAddress);
        tvProfileUsername = findViewById(R.id.tvProfileUsername);
        tvDonationCount   = findViewById(R.id.tvDonationCount);
        tvLivesSaved      = findViewById(R.id.tvLivesSaved);
        tvFooterMessage   = findViewById(R.id.tvFooterMessage);

        username = getIntent().getStringExtra("username");

        if (username != null) {
            tvProfileUsername.setText(username);
        }

        databaseReference = FirebaseDatabase.getInstance().getReference("Users");
        requestsRef       = FirebaseDatabase.getInstance().getReference("BloodRequests");

        loadProfile();
        loadDonationCount();
    }

    private void loadProfile() {
        databaseReference.child(username).get().addOnCompleteListener(task -> {
            if (task.isSuccessful() && task.getResult().exists()) {
                DataSnapshot snapshot = task.getResult();

                String name    = snapshot.child("name").getValue(String.class);
                String phone   = snapshot.child("phone").getValue(String.class);
                String blood   = snapshot.child("blood").getValue(String.class);
                String email   = snapshot.child("email").getValue(String.class);
                String address = snapshot.child("address").getValue(String.class);

                tvProfileName.setText(name != null ? name : "N/A");
                tvProfileBlood.setText(blood != null ? blood : "?");
                tvProfilePhone.setText(phone != null ? phone : "N/A");
                tvProfileEmail.setText(email != null ? email : "N/A");
                tvProfileAddress.setText(address != null ? address : "N/A");
            }
        });
    }

    private void loadDonationCount() {
        // ✅ Count all BloodRequests where donorName == username AND status == "Donated"
        requestsRef.addListenerForSingleValueEvent(new ValueEventListener() {

            @Override
            public void onDataChange(DataSnapshot snapshot) {
                int donationCount = 0;

                for (DataSnapshot data : snapshot.getChildren()) {
                    String donorName = data.child("donorName").getValue(String.class);
                    String status    = data.child("status").getValue(String.class);

                    // ✅ Only count confirmed donations by this donor
                    if (username.equals(donorName) &&
                            "Donated".equalsIgnoreCase(status)) {
                        donationCount++;
                    }
                }

                // Update UI
                tvDonationCount.setText(String.valueOf(donationCount));

                // Each donation saves up to 3 lives
                tvLivesSaved.setText(String.valueOf(donationCount * 3));

                // Update footer message based on count
                if (donationCount == 0) {
                    tvFooterMessage.setText(
                            "You haven't donated yet. Accept a request to save lives!");
                } else if (donationCount == 1) {
                    tvFooterMessage.setText(
                            "You donated once and saved up to 3 lives. Keep going!");
                } else {
                    tvFooterMessage.setText(
                            "Amazing! You have donated " + donationCount +
                                    " times and saved up to " + (donationCount * 3) +
                                    " lives. You are a hero!");
                }
            }

            @Override
            public void onCancelled(DatabaseError error) {
                tvDonationCount.setText("—");
                tvLivesSaved.setText("—");
            }
        });
    }
}