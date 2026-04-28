package com.example.blooddrop;

import android.os.Bundle;
import android.view.View;
import android.widget.TextView;

import androidx.appcompat.app.AppCompatActivity;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.google.firebase.database.DataSnapshot;
import com.google.firebase.database.DatabaseError;
import com.google.firebase.database.DatabaseReference;
import com.google.firebase.database.FirebaseDatabase;
import com.google.firebase.database.ValueEventListener;

import java.util.ArrayList;
import java.util.List;

public class DonorRequestsActivity extends AppCompatActivity {

    RecyclerView recyclerRequests;
    TextView tvRequestSubtitle, tvEmpty;
    DatabaseReference requestsRef, usersRef;
    BloodRequestAdapter adapter;
    List<BloodRequestModel> requestList;
    String username;
    String donorBloodGroup; // ✅ donor's own blood group fetched from Firebase

    private static final long THREE_MONTHS_MS = 90L * 24 * 60 * 60 * 1000;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_donor_requests);

        recyclerRequests  = findViewById(R.id.recyclerRequests);
        tvRequestSubtitle = findViewById(R.id.tvRequestSubtitle);
        tvEmpty           = findViewById(R.id.tvEmpty);

        username    = getIntent().getStringExtra("username");
        requestList = new ArrayList<>();

        recyclerRequests.setLayoutManager(new LinearLayoutManager(this));

        requestsRef = FirebaseDatabase.getInstance().getReference("BloodRequests");
        usersRef    = FirebaseDatabase.getInstance().getReference("Users");

        // ✅ Step 1: Fetch donor's blood group first, then check cooldown, then load
        fetchBloodGroupThenLoad();
    }

    private void fetchBloodGroupThenLoad() {
        usersRef.child(username).get().addOnCompleteListener(task -> {

            if (task.isSuccessful() && task.getResult().exists()) {
                donorBloodGroup = task.getResult()
                        .child("blood").getValue(String.class);
            }

            // ✅ Show which blood group is being filtered
            if (donorBloodGroup != null) {
                tvRequestSubtitle.setText(
                        "Showing requests for blood group: " + donorBloodGroup);
            }

            checkCooldownThenLoad();
        });
    }

    private void checkCooldownThenLoad() {
        usersRef.child(username).child("lastDonation")
                .get().addOnCompleteListener(task -> {

                    boolean canDonate     = true;
                    long nextDonationTime = 0;

                    if (task.isSuccessful() && task.getResult().exists()) {
                        Long lastDonation = task.getResult().getValue(Long.class);
                        if (lastDonation != null) {
                            long timeSince = System.currentTimeMillis() - lastDonation;
                            if (timeSince < THREE_MONTHS_MS) {
                                canDonate        = false;
                                nextDonationTime = lastDonation + THREE_MONTHS_MS;
                                long daysLeft    = (nextDonationTime - System.currentTimeMillis())
                                        / (1000 * 60 * 60 * 24);
                                tvRequestSubtitle.setText(
                                        "You can donate again in " + daysLeft + " days");
                            }
                        }
                    }

                    final boolean finalCanDonate     = canDonate;
                    final long finalNextDonationTime = nextDonationTime;

                    adapter = new BloodRequestAdapter(
                            requestList, username,
                            finalCanDonate, finalNextDonationTime, "donor");
                    recyclerRequests.setAdapter(adapter);

                    loadRequests();
                });
    }

    private void loadRequests() {
        requestsRef.addValueEventListener(new ValueEventListener() {

            @Override
            public void onDataChange(DataSnapshot snapshot) {
                requestList.clear();

                for (DataSnapshot data : snapshot.getChildren()) {
                    String key       = data.getKey();
                    String patient   = data.child("patient").getValue(String.class);
                    String blood     = data.child("blood").getValue(String.class);
                    String units     = data.child("units").getValue(String.class);
                    String hospital  = data.child("hospital").getValue(String.class);
                    String status    = data.child("status").getValue(String.class);
                    String donorName = data.child("donorName").getValue(String.class);

                    // ✅ Filter: only add if blood group matches donor's blood group
                    // If donorBloodGroup is null (not set), show all requests
                    if (donorBloodGroup == null ||
                            donorBloodGroup.trim().equalsIgnoreCase(
                                    blood != null ? blood.trim() : "")) {

                        requestList.add(new BloodRequestModel(
                                key, patient, blood, units,
                                hospital, status, donorName));
                    }
                }

                adapter.notifyDataSetChanged();

                if (requestList.isEmpty()) {
                    tvEmpty.setVisibility(View.VISIBLE);
                    recyclerRequests.setVisibility(View.GONE);
                    tvEmpty.setText(donorBloodGroup != null
                            ? "No requests for blood group " + donorBloodGroup
                            : "No requests available");
                } else {
                    tvEmpty.setVisibility(View.GONE);
                    recyclerRequests.setVisibility(View.VISIBLE);
                    tvRequestSubtitle.setText(
                            requestList.size() + " request(s) for " + donorBloodGroup);
                }
            }

            @Override
            public void onCancelled(DatabaseError error) {
                tvEmpty.setVisibility(View.VISIBLE);
                tvEmpty.setText("Failed to load requests");
            }
        });
    }
}