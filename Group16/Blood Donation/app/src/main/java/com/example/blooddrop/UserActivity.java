package com.example.blooddrop;

import android.content.Intent;
import android.os.Bundle;
import android.widget.Toast;

import androidx.appcompat.app.AppCompatActivity;

import com.google.android.material.button.MaterialButton;
import com.google.android.material.textfield.TextInputEditText;
import com.google.firebase.database.DataSnapshot;
import com.google.firebase.database.DatabaseError;
import com.google.firebase.database.DatabaseReference;
import com.google.firebase.database.FirebaseDatabase;
import com.google.firebase.database.ValueEventListener;

public class UserActivity extends AppCompatActivity {

    TextInputEditText etUsername, etPassword;
    MaterialButton btnLogin;
    DatabaseReference databaseReference;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_user_login);

        etUsername = findViewById(R.id.etUsername);
        etPassword = findViewById(R.id.etPassword);
        btnLogin   = findViewById(R.id.btnLogin);

        databaseReference = FirebaseDatabase.getInstance().getReference("Users");

        btnLogin.setOnClickListener(v -> {
            String username = etUsername.getText().toString().trim();
            String password = etPassword.getText().toString().trim();

            if (username.isEmpty() || password.isEmpty()) {
                Toast.makeText(this, "Please fill all fields",
                        Toast.LENGTH_SHORT).show();
                return;
            }

            databaseReference.child(username)
                    .addListenerForSingleValueEvent(new ValueEventListener() {

                        @Override
                        public void onDataChange(DataSnapshot snapshot) {
                            if (snapshot.exists()) {
                                String dbPassword = snapshot.child("password")
                                        .getValue(String.class);
                                // ✅ Check approval status
                                String status = snapshot.child("status")
                                        .getValue(String.class);

                                if (dbPassword != null && dbPassword.equals(password)) {

                                    if ("pending".equalsIgnoreCase(status)) {
                                        // ✅ Blocked — pending approval
                                        Toast.makeText(UserActivity.this,
                                                "Your account is pending admin approval. Please wait.",
                                                Toast.LENGTH_LONG).show();

                                    } else if ("rejected".equalsIgnoreCase(status)) {
                                        // ✅ Blocked — rejected
                                        Toast.makeText(UserActivity.this,
                                                "Your account was rejected. Contact admin for details.",
                                                Toast.LENGTH_LONG).show();

                                    } else if ("approved".equalsIgnoreCase(status)) {
                                        // ✅ Approved — allow login
                                        Toast.makeText(UserActivity.this,
                                                "Login Successful!",
                                                Toast.LENGTH_SHORT).show();
                                        Intent intent = new Intent(
                                                UserActivity.this,
                                                DonorDashboardActivity.class);
                                        intent.putExtra("username", username);
                                        startActivity(intent);
                                        finish();

                                    } else {
                                        // ✅ No status set — treat as pending
                                        Toast.makeText(UserActivity.this,
                                                "Your account is under review.",
                                                Toast.LENGTH_LONG).show();
                                    }

                                } else {
                                    Toast.makeText(UserActivity.this,
                                            "Invalid Password", Toast.LENGTH_SHORT).show();
                                }

                            } else {
                                Toast.makeText(UserActivity.this,
                                        "User not found", Toast.LENGTH_SHORT).show();
                            }
                        }

                        @Override
                        public void onCancelled(DatabaseError error) {
                            Toast.makeText(UserActivity.this,
                                    "Database Error", Toast.LENGTH_SHORT).show();
                        }
                    });
        });
    }
}