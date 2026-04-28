package com.example.blooddrop;

import android.app.AlertDialog;
import android.content.Intent;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.LinearLayout;
import android.widget.TextView;
import android.widget.Toast;

import androidx.appcompat.app.AppCompatActivity;

import com.google.android.material.button.MaterialButton;
import com.google.android.material.textfield.TextInputEditText;
import com.google.firebase.database.DataSnapshot;
import com.google.firebase.database.DatabaseError;
import com.google.firebase.database.DatabaseReference;
import com.google.firebase.database.FirebaseDatabase;
import com.google.firebase.database.ValueEventListener;

public class AcceptorDashboardActivity extends AppCompatActivity {

    TextInputEditText etPatientName, etBloodGroup, etUnits, etHospital;
    MaterialButton btnRequest;
    LinearLayout requestList;
    TextView tvHistoryCount;
    DatabaseReference requestRef;
    String username;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_acceptor_dashboard);

        etPatientName  = findViewById(R.id.etPatientName);
        etBloodGroup   = findViewById(R.id.etBloodGroup);
        etUnits        = findViewById(R.id.etUnits);
        etHospital     = findViewById(R.id.etHospital);
        btnRequest     = findViewById(R.id.btnRequest);
        requestList    = findViewById(R.id.requestList);
        tvHistoryCount = findViewById(R.id.tvHistoryCount);

        username   = getIntent().getStringExtra("username");
        requestRef = FirebaseDatabase.getInstance().getReference("BloodRequests");

        btnRequest.setOnClickListener(v -> raiseRequest());
        loadRequests();
    }

    private void raiseRequest() {
        String patient  = etPatientName.getText().toString().trim();
        String blood    = etBloodGroup.getText().toString().trim();
        String units    = etUnits.getText().toString().trim();
        String hospital = etHospital.getText().toString().trim();

        if (TextUtils.isEmpty(patient) || TextUtils.isEmpty(blood) ||
                TextUtils.isEmpty(units)   || TextUtils.isEmpty(hospital)) {
            Toast.makeText(this, "Fill all fields", Toast.LENGTH_SHORT).show();
            return;
        }

        String id = requestRef.push().getKey();
        requestRef.child(id).child("patient").setValue(patient);
        requestRef.child(id).child("blood").setValue(blood);
        requestRef.child(id).child("units").setValue(units);
        requestRef.child(id).child("hospital").setValue(hospital);
        requestRef.child(id).child("status").setValue("Pending");

        Toast.makeText(this, "Request Created!", Toast.LENGTH_SHORT).show();

        etPatientName.setText("");
        etBloodGroup.setText("");
        etUnits.setText("");
        etHospital.setText("");
    }

    private void loadRequests() {
        requestRef.addValueEventListener(new ValueEventListener() {

            @Override
            public void onDataChange(DataSnapshot snapshot) {
                requestList.removeAllViews();
                int count = 0;

                for (DataSnapshot data : snapshot.getChildren()) {
                    final String key      = data.getKey();
                    final String patient  = data.child("patient").getValue(String.class);
                    final String blood    = data.child("blood").getValue(String.class);
                    final String units    = data.child("units").getValue(String.class);
                    final String hospital = data.child("hospital").getValue(String.class);
                    final String status   = data.child("status").getValue(String.class);
                    final String donor    = data.child("donorName").getValue(String.class);

                    // ✅ Use item_blood_request layout so buttons show up
                    View card = LayoutInflater.from(AcceptorDashboardActivity.this)
                            .inflate(R.layout.item_blood_request, requestList, false);

                    TextView tvPatient  = card.findViewById(R.id.tvPatient);
                    TextView tvBlood    = card.findViewById(R.id.tvBlood);
                    TextView tvUnits    = card.findViewById(R.id.tvUnits);
                    TextView tvHospital = card.findViewById(R.id.tvHospital);
                    TextView tvStatus   = card.findViewById(R.id.tvStatus);

                    MaterialButton btnAccept       = card.findViewById(R.id.btnAccept);
                    MaterialButton btnBloodDonated = card.findViewById(R.id.btnBloodDonated);
                    MaterialButton btnCertificate  = card.findViewById(R.id.btnCertificate);

                    tvPatient.setText(patient != null ? patient : "N/A");
                    tvBlood.setText(blood != null ? blood : "?");
                    tvUnits.setText(units != null ? units : "0");
                    tvHospital.setText(hospital != null ? hospital : "N/A");
                    tvStatus.setText(status != null ? status : "Pending");

                    // Hide all buttons first
                    btnAccept.setVisibility(View.GONE);
                    btnBloodDonated.setVisibility(View.GONE);
                    btnCertificate.setVisibility(View.GONE);

                    // ✅ Status color
                    if ("Donated".equalsIgnoreCase(status)) {
                        tvStatus.setTextColor(0xFF4CAF50); // green

                        // Show confirmation disabled
                        btnBloodDonated.setVisibility(View.VISIBLE);
                        btnBloodDonated.setText("Donation Confirmed");
                        btnBloodDonated.setEnabled(false);
                        btnBloodDonated.setAlpha(0.6f);

                    } else if ("Accepted".equalsIgnoreCase(status)) {
                        tvStatus.setTextColor(0xFF1565C0); // blue

                        // ✅ Show Confirm Blood Donated button
                        btnBloodDonated.setVisibility(View.VISIBLE);
                        btnBloodDonated.setOnClickListener(v -> {
                            new AlertDialog.Builder(AcceptorDashboardActivity.this)
                                    .setTitle("Confirm Blood Donated?")
                                    .setMessage(
                                            "Confirm that the donor has physically donated blood for:\n\n" +
                                                    "Patient: " + patient + "\n" +
                                                    "Blood Group: " + blood + "\n" +
                                                    "Hospital: " + hospital + "\n\n" +
                                                    "This will generate a certificate for the donor."
                                    )
                                    .setPositiveButton("Yes, Confirm", (dialog, which) -> {
                                        requestRef.child(key).child("status").setValue("Donated");
                                        Toast.makeText(AcceptorDashboardActivity.this,
                                                "Donation confirmed! Donor can now get certificate.",
                                                Toast.LENGTH_LONG).show();
                                    })
                                    .setNegativeButton("Cancel", null)
                                    .show();
                        });

                    } else {
                        // Pending
                        tvStatus.setTextColor(0xFFD70404); // red
                        btnAccept.setVisibility(View.VISIBLE);
                        btnAccept.setText("Awaiting Donor");
                        btnAccept.setEnabled(false);
                        btnAccept.setAlpha(0.4f);
                    }

                    requestList.addView(card);
                    count++;
                }

                tvHistoryCount.setText(String.valueOf(count));
            }

            @Override
            public void onCancelled(DatabaseError error) {
                Toast.makeText(AcceptorDashboardActivity.this,
                        "Failed to load requests", Toast.LENGTH_SHORT).show();
            }
        });
    }
}