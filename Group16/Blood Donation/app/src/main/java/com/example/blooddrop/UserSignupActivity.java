package com.example.blooddrop;

import android.content.Intent;
import android.os.Bundle;
import android.widget.Button;
import android.widget.EditText;
import android.widget.Toast;

import androidx.appcompat.app.AppCompatActivity;

import com.google.firebase.database.DatabaseReference;
import com.google.firebase.database.FirebaseDatabase;

public class UserSignupActivity extends AppCompatActivity {

    EditText etUsername, etPassword, etName, etBloodGroup, etPhone;
    Button btnRegister;
    DatabaseReference databaseReference;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_user_signup);

        etUsername = findViewById(R.id.etUsername);
        etPassword = findViewById(R.id.etPassword);
        etName = findViewById(R.id.etName);
        etBloodGroup = findViewById(R.id.etBloodGroup);
        etPhone = findViewById(R.id.etPhone);
        btnRegister = findViewById(R.id.btnSignup);

        databaseReference = FirebaseDatabase.getInstance().getReference("Users");

        btnRegister.setOnClickListener(v -> {

            String username = etUsername.getText().toString().trim();
            String password = etPassword.getText().toString().trim();
            String name = etName.getText().toString().trim();
            String blood = etBloodGroup.getText().toString().trim();
            String mobile = etPhone.getText().toString().trim();

            if (username.isEmpty() || password.isEmpty() ||
                    name.isEmpty() || blood.isEmpty() || mobile.isEmpty()) {

                Toast.makeText(UserSignupActivity.this,
                        "Please fill all fields",
                        Toast.LENGTH_SHORT).show();
                return;
            }

            // 🔥 Check if username exists
            databaseReference.child(username).get().addOnCompleteListener(task -> {

                if (task.isSuccessful()) {

                    if (task.getResult().exists()) {

                        Toast.makeText(UserSignupActivity.this,
                                "Username already exists ❌",
                                Toast.LENGTH_SHORT).show();

                    } else {

                        // 🔥 Save user
                        databaseReference.child(username).child("username").setValue(username);
                        databaseReference.child(username).child("password").setValue(password);
                        databaseReference.child(username).child("name").setValue(name);
                        databaseReference.child(username).child("bloodGroup").setValue(blood);
                        databaseReference.child(username).child("mobile").setValue(mobile);

                        Toast.makeText(UserSignupActivity.this,
                                "Signup Successful 🩸🔥",
                                Toast.LENGTH_SHORT).show();

                        // 🔥 Open Donor Dashboard
                        Intent intent = new Intent(UserSignupActivity.this, DonorDashboardActivity.class);
                        intent.putExtra("username", username);
                        startActivity(intent);
                        finish();
                    }

                } else {
                    Toast.makeText(UserSignupActivity.this,
                            "Database Error",
                            Toast.LENGTH_SHORT).show();
                }

            });

        });
    }
}