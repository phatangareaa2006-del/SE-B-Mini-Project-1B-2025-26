package com.example.blooddrop;

import android.content.Intent;
import android.os.Bundle;
import android.widget.Toast;

import androidx.appcompat.app.AppCompatActivity;

import com.google.android.material.button.MaterialButton;
import com.google.android.material.textfield.TextInputEditText;
import com.google.firebase.database.DatabaseReference;
import com.google.firebase.database.FirebaseDatabase;

import java.util.HashMap;

public class Step4Activity extends AppCompatActivity {

    TextInputEditText etUsername, etPassword;
    MaterialButton btnFinish;

    String name, gender, phone, blood, email, address;
    String aadharBase64, healthBase64;

    DatabaseReference usersRef;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_step4);

        // ✅ Get all data from previous steps
        name          = getIntent().getStringExtra("name");
        gender        = getIntent().getStringExtra("gender");
        phone         = getIntent().getStringExtra("phone");
        blood         = getIntent().getStringExtra("blood");
        email         = getIntent().getStringExtra("email");
        address       = getIntent().getStringExtra("address");
        aadharBase64  = getIntent().getStringExtra("aadharBase64");
        healthBase64  = getIntent().getStringExtra("healthBase64");

        etUsername = findViewById(R.id.etUsername);
        etPassword = findViewById(R.id.etPassword);
        btnFinish  = findViewById(R.id.btnFinish);

        usersRef = FirebaseDatabase.getInstance().getReference("Users");

        btnFinish.setOnClickListener(v -> {
            String username = etUsername.getText().toString().trim();
            String password = etPassword.getText().toString().trim();

            if (username.isEmpty() || password.isEmpty()) {
                Toast.makeText(this, "Fill all fields", Toast.LENGTH_SHORT).show();
                return;
            }

            if (password.length() < 6) {
                etPassword.setError("Password must be at least 6 characters");
                etPassword.requestFocus();
                return;
            }

            btnFinish.setEnabled(false);
            btnFinish.setText("Submitting...");

            // ✅ Check username doesn't already exist
            usersRef.child(username).get().addOnCompleteListener(task -> {
                if (task.isSuccessful() && task.getResult().exists()) {
                    btnFinish.setEnabled(true);
                    btnFinish.setText("Submit for Approval");
                    Toast.makeText(this, "Username already taken",
                            Toast.LENGTH_SHORT).show();
                    return;
                }

                // ✅ Save everything to Realtime Database
                HashMap<String, Object> userMap = new HashMap<>();
                userMap.put("name",         name);
                userMap.put("gender",       gender);
                userMap.put("phone",        phone);
                userMap.put("blood",        blood);
                userMap.put("email",        email);
                userMap.put("address",      address);
                userMap.put("username",     username);
                userMap.put("password",     password);
                userMap.put("status",       "pending");

                // ✅ Store Base64 images directly in Realtime Database
                if (aadharBase64 != null)
                    userMap.put("aadharBase64", aadharBase64);
                if (healthBase64 != null)
                    userMap.put("healthBase64", healthBase64);

                usersRef.child(username).setValue(userMap)
                        .addOnCompleteListener(saveTask -> {
                            if (saveTask.isSuccessful()) {
                                Toast.makeText(this,
                                        "Submitted! Please wait for admin approval.",
                                        Toast.LENGTH_LONG).show();
                                startActivity(new Intent(this, MainActivity.class));
                                finish();
                            } else {
                                btnFinish.setEnabled(true);
                                btnFinish.setText("Submit for Approval");
                                Toast.makeText(this,
                                        "Registration failed. Try again.",
                                        Toast.LENGTH_SHORT).show();
                            }
                        });
            });
        });
    }
}