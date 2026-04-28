package com.example.blooddrop;

import android.os.Bundle;
import android.view.View;
import android.widget.TextView;

import androidx.appcompat.app.AppCompatActivity;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.google.firebase.database.DataSnapshot;
import com.google.firebase.database.DatabaseReference;
import com.google.firebase.database.FirebaseDatabase;

import java.util.ArrayList;
import java.util.List;

public class AdminDonorActivity extends AppCompatActivity {

    RecyclerView recyclerDonors;
    TextView tvDonorSubtitle, tvEmpty;
    DatabaseReference donorsRef;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_admin_donor);

        recyclerDonors  = findViewById(R.id.recyclerDonors);
        tvDonorSubtitle = findViewById(R.id.tvDonorSubtitle);
        tvEmpty         = findViewById(R.id.tvEmpty);

        recyclerDonors.setLayoutManager(new LinearLayoutManager(this));

        donorsRef = FirebaseDatabase.getInstance().getReference("Users");

        donorsRef.get().addOnCompleteListener(task -> {
            if (task.isSuccessful()) {

                List<DonorModel> list = new ArrayList<>();
                List<String> keys     = new ArrayList<>(); // ✅ store Firebase keys

                for (DataSnapshot snapshot : task.getResult().getChildren()) {
                    keys.add(snapshot.getKey()); // ✅ save key for deletion

                    String name    = snapshot.child("name").getValue(String.class);
                    String blood   = snapshot.child("blood").getValue(String.class);
                    String phone   = snapshot.child("phone").getValue(String.class);
                    String email   = snapshot.child("email").getValue(String.class);
                    String address = snapshot.child("address").getValue(String.class);
                    String gender  = snapshot.child("gender").getValue(String.class);

                    list.add(new DonorModel(name, blood, phone, email, address, gender));
                }

                if (list.isEmpty()) {
                    tvEmpty.setVisibility(View.VISIBLE);
                    recyclerDonors.setVisibility(View.GONE);
                    tvDonorSubtitle.setText("No donors registered yet");
                } else {
                    tvDonorSubtitle.setText(list.size() + " donors registered");
                    recyclerDonors.setAdapter(new DonorAdapter(list, keys));
                }

            } else {
                tvEmpty.setVisibility(View.VISIBLE);
                tvEmpty.setText("Failed to load data");
                recyclerDonors.setVisibility(View.GONE);
            }
        });
    }
}