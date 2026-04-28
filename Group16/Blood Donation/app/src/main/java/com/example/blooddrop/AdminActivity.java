package com.example.blooddrop;

import android.os.Bundle;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.LinearLayout;
import android.widget.TextView;
import android.widget.Toast;

import androidx.appcompat.app.AppCompatActivity;

import com.google.firebase.database.DataSnapshot;
import com.google.firebase.database.DatabaseReference;
import com.google.firebase.database.FirebaseDatabase;

public class AdminActivity extends AppCompatActivity {

    LinearLayout layoutContainer;
    DatabaseReference donorsRef, acceptorsRef;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_admin_dashboard);

        layoutContainer = findViewById(R.id.layoutContainer);

        donorsRef = FirebaseDatabase.getInstance().getReference("Users");
        acceptorsRef = FirebaseDatabase.getInstance().getReference("Acceptors");

        loadDonors();
        loadAcceptors();
    }

    private void loadDonors() {

        donorsRef.get().addOnCompleteListener(task -> {

            if (task.isSuccessful() && task.getResult().exists()) {

                for (DataSnapshot snapshot : task.getResult().getChildren()) {

                    String key = snapshot.getKey();

                    String name = getValue(snapshot, "name");
                    String blood = getValue(snapshot, "blood");
                    String phone = getValue(snapshot, "phone");
                    String address = getValue(snapshot, "address");
                    String email = getValue(snapshot, "email");
                    String gender = getValue(snapshot, "gender");

                    TextView tv = new TextView(this);
                    tv.setLayoutParams(new LinearLayout.LayoutParams(
                            ViewGroup.LayoutParams.MATCH_PARENT,
                            ViewGroup.LayoutParams.WRAP_CONTENT
                    ));

                    tv.setText(
                            "🩸 DONOR\n" +
                                    "Name: " + name +
                                    "\nBlood: " + blood +
                                    "\nPhone: " + phone +
                                    "\nAddress: " + address +
                                    "\nEmail: " + email +
                                    "\nGender: " + gender +
                                    "\n-----------------------"
                    );

                    Button deleteBtn = new Button(this);
                    deleteBtn.setText("Delete Donor");

                    deleteBtn.setOnClickListener(v -> {
                        donorsRef.child(key).removeValue();
                        Toast.makeText(this, "Donor Deleted", Toast.LENGTH_SHORT).show();
                        recreate();
                    });

                    layoutContainer.addView(tv);
                    layoutContainer.addView(deleteBtn);
                }

            } else {
                Toast.makeText(this, "No Donors Found", Toast.LENGTH_SHORT).show();
            }
        });
    }

    private void loadAcceptors() {

        acceptorsRef.get().addOnCompleteListener(task -> {

            if (task.isSuccessful() && task.getResult().exists()) {

                for (DataSnapshot snapshot : task.getResult().getChildren()) {

                    String key = snapshot.getKey();

                    String hospital = getValue(snapshot, "hospital");
                    String speciality = getValue(snapshot, "speciality");
                    String phone = getValue(snapshot, "phone");
                    String email = getValue(snapshot, "email");
                    String address = getValue(snapshot, "address");
                    String location = getValue(snapshot, "location");

                    TextView tv = new TextView(this);
                    tv.setLayoutParams(new LinearLayout.LayoutParams(
                            ViewGroup.LayoutParams.MATCH_PARENT,
                            ViewGroup.LayoutParams.WRAP_CONTENT
                    ));

                    tv.setText(
                            "🏥 ACCEPTOR\n" +
                                    "Hospital: " + hospital +
                                    "\nSpeciality: " + speciality +
                                    "\nPhone: " + phone +
                                    "\nEmail: " + email +
                                    "\nAddress: " + address +
                                    "\nLocation: " + location +
                                    "\n-----------------------"
                    );

                    Button deleteBtn = new Button(this);
                    deleteBtn.setText("Delete Acceptor");

                    deleteBtn.setOnClickListener(v -> {
                        acceptorsRef.child(key).removeValue();
                        Toast.makeText(this, "Acceptor Deleted", Toast.LENGTH_SHORT).show();
                        recreate();
                    });

                    layoutContainer.addView(tv);
                    layoutContainer.addView(deleteBtn);
                }

            } else {
                Toast.makeText(this, "No Acceptors Found", Toast.LENGTH_SHORT).show();
            }
        });
    }

    private String getValue(DataSnapshot snapshot, String key) {
        String value = snapshot.child(key).getValue(String.class);
        return value != null ? value : "Not Available";
    }
}