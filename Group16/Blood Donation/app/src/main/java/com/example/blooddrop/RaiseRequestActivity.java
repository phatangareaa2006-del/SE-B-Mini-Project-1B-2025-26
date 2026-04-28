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

public class RaiseRequestActivity extends AppCompatActivity {

    RecyclerView recyclerRequests;
    TextView tvRequestSubtitle, tvEmpty;
    DatabaseReference requestsRef;
    BloodRequestAdapter adapter;
    List<BloodRequestModel> requestList;
    String username;

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

        adapter = new BloodRequestAdapter(
                requestList, username, false, 0, "acceptor");
        recyclerRequests.setAdapter(adapter);

        requestsRef = FirebaseDatabase.getInstance().getReference("BloodRequests");
        loadRequests();
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
                    // ✅ Added donorName as 7th argument
                    String donorName = data.child("donorName").getValue(String.class);

                    requestList.add(new BloodRequestModel(
                            key, patient, blood, units, hospital, status, donorName));
                }

                adapter.notifyDataSetChanged();

                if (requestList.isEmpty()) {
                    tvEmpty.setVisibility(View.VISIBLE);
                    recyclerRequests.setVisibility(View.GONE);
                    tvRequestSubtitle.setText("No requests found");
                } else {
                    tvEmpty.setVisibility(View.GONE);
                    recyclerRequests.setVisibility(View.VISIBLE);
                    tvRequestSubtitle.setText(requestList.size() + " requests");
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