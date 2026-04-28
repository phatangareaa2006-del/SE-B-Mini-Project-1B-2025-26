package com.example.blooddrop;

import android.content.Intent;
import android.os.Bundle;
import android.widget.TextView;
import android.widget.Toast;

import androidx.appcompat.app.AppCompatActivity;

import com.google.android.material.button.MaterialButton;
import com.google.android.material.textfield.TextInputEditText;
import com.google.firebase.database.DatabaseReference;
import com.google.firebase.database.FirebaseDatabase;

import java.util.HashMap;

public class AccepterSignupActivity extends AppCompatActivity {

    TextInputEditText etHospital, etSpeciality, etContact,
            etPhone, etEmail, etAddress, etLocation,
            etUsername, etPassword;

    MaterialButton btnSignup;
    TextView tvLogin; // ✅ Login redirect
    DatabaseReference databaseReference;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_accepter_signup);

        etHospital   = findViewById(R.id.etHospital);
        etSpeciality = findViewById(R.id.etSpeciality);
        etContact    = findViewById(R.id.etContact);
        etPhone      = findViewById(R.id.etPhone);
        etEmail      = findViewById(R.id.etEmail);
        etAddress    = findViewById(R.id.etAddress);
        etLocation   = findViewById(R.id.etLocation);
        etUsername   = findViewById(R.id.etUsername);
        etPassword   = findViewById(R.id.etPassword);
        btnSignup    = findViewById(R.id.btnSignup);
        tvLogin      = findViewById(R.id.tvLogin); // ✅

        databaseReference = FirebaseDatabase.getInstance().getReference("Acceptors");

        String usernameFromPrevious = getIntent().getStringExtra("username");
        String passwordFromPrevious = getIntent().getStringExtra("password");

        if (usernameFromPrevious != null) etUsername.setText(usernameFromPrevious);
        if (passwordFromPrevious != null) etPassword.setText(passwordFromPrevious);

        btnSignup.setOnClickListener(v -> registerUser());

        // ✅ Login redirect — goes to acceptor login screen
        tvLogin.setOnClickListener(v ->
                startActivity(new Intent(AccepterSignupActivity.this,
                        AccepterAuthActivity.class))
        );
    }

    private void registerUser() {
        String hospital   = etHospital.getText().toString().trim();
        String speciality = etSpeciality.getText().toString().trim();
        String contact    = etContact.getText().toString().trim();
        String phone      = etPhone.getText().toString().trim();
        String email      = etEmail.getText().toString().trim();
        String address    = etAddress.getText().toString().trim();
        String location   = etLocation.getText().toString().trim();
        String username   = etUsername.getText().toString().trim();
        String password   = etPassword.getText().toString().trim();

        if (hospital.isEmpty() || speciality.isEmpty() || contact.isEmpty()
                || phone.isEmpty() || email.isEmpty() || address.isEmpty()
                || location.isEmpty() || username.isEmpty() || password.isEmpty()) {
            Toast.makeText(this, "Please fill all fields", Toast.LENGTH_SHORT).show();
            return;
        }

        if (!phone.matches("[6-9]\\d{9}")) {
            etPhone.setError("Enter a valid Indian phone number (starts with 6-9)");
            etPhone.requestFocus();
            return;
        }

        if (!email.toLowerCase().endsWith("@gmail.com")) {
            etEmail.setError("Only Gmail allowed (e.g. name@gmail.com)");
            etEmail.requestFocus();
            return;
        }

        databaseReference.child(username).get().addOnCompleteListener(task -> {
            if (task.isSuccessful()) {
                if (task.getResult().exists()) {
                    Toast.makeText(this,
                            "Username already exists", Toast.LENGTH_SHORT).show();
                } else {
                    HashMap<String, Object> userMap = new HashMap<>();
                    userMap.put("hospital",      hospital);
                    userMap.put("speciality",    speciality);
                    userMap.put("contactPerson", contact);
                    userMap.put("phone",         phone);
                    userMap.put("email",         email);
                    userMap.put("address",       address);
                    userMap.put("location",      location);
                    userMap.put("username",      username);
                    userMap.put("password",      password);

                    databaseReference.child(username).setValue(userMap)
                            .addOnCompleteListener(saveTask -> {
                                if (saveTask.isSuccessful()) {
                                    Toast.makeText(this,
                                            "Signup Successful!",
                                            Toast.LENGTH_SHORT).show();
                                    startActivity(new Intent(
                                            AccepterSignupActivity.this,
                                            AcceptorDashboardActivity.class));
                                    finish();
                                } else {
                                    Toast.makeText(this,
                                            "Signup Failed", Toast.LENGTH_SHORT).show();
                                }
                            });
                }
            } else {
                Toast.makeText(this, "Database Error", Toast.LENGTH_SHORT).show();
            }
        });
    }
}