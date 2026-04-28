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

public class AdminAcceptorActivity extends AppCompatActivity {

    RecyclerView recyclerAcceptors;
    TextView tvAcceptorSubtitle, tvEmpty;
    DatabaseReference acceptorsRef;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_admin_acceptor);

        recyclerAcceptors  = findViewById(R.id.recyclerAcceptors);
        tvAcceptorSubtitle = findViewById(R.id.tvAcceptorSubtitle);
        tvEmpty            = findViewById(R.id.tvEmpty);

        recyclerAcceptors.setLayoutManager(new LinearLayoutManager(this));

        acceptorsRef = FirebaseDatabase.getInstance().getReference("Acceptors");

        acceptorsRef.get().addOnCompleteListener(task -> {
            if (task.isSuccessful()) {

                List<AcceptorModel> list = new ArrayList<>();
                List<String> keys        = new ArrayList<>(); // ✅ store Firebase keys

                for (DataSnapshot snapshot : task.getResult().getChildren()) {
                    keys.add(snapshot.getKey()); // ✅ save key for deletion

                    String hospital   = snapshot.child("hospital").getValue(String.class);
                    String speciality = snapshot.child("speciality").getValue(String.class);
                    String phone      = snapshot.child("phone").getValue(String.class);
                    String email      = snapshot.child("email").getValue(String.class);
                    String address    = snapshot.child("address").getValue(String.class);
                    String location   = snapshot.child("location").getValue(String.class);

                    list.add(new AcceptorModel(hospital, speciality, phone, email, address, location));
                }

                if (list.isEmpty()) {
                    tvEmpty.setVisibility(View.VISIBLE);
                    recyclerAcceptors.setVisibility(View.GONE);
                    tvAcceptorSubtitle.setText("No acceptors registered yet");
                } else {
                    tvAcceptorSubtitle.setText(list.size() + " hospitals registered");
                    recyclerAcceptors.setAdapter(new AcceptorAdapter(list, keys));
                }

            } else {
                tvEmpty.setVisibility(View.VISIBLE);
                tvEmpty.setText("Failed to load data");
                recyclerAcceptors.setVisibility(View.GONE);
            }
        });
    }
}