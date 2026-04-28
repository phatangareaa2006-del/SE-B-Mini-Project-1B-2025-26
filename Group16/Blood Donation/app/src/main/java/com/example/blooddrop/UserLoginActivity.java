package com.example.blooddrop;

import android.content.Intent;
import android.os.Bundle;
import android.widget.Button;
import android.widget.EditText;
import android.widget.Toast;

import androidx.appcompat.app.AppCompatActivity;

import com.google.firebase.database.DataSnapshot;
import com.google.firebase.database.DatabaseError;
import com.google.firebase.database.DatabaseReference;
import com.google.firebase.database.FirebaseDatabase;
import com.google.firebase.database.ValueEventListener;

public class UserLoginActivity extends AppCompatActivity {

    EditText etUsername, etPassword;
    Button btnUserLogin;
    DatabaseReference databaseReference;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_user_login);

        // Connect XML IDs (MUST be inside onCreate)
        etUsername = findViewById(R.id.etUsername);
        etPassword = findViewById(R.id.etPassword);
        btnUserLogin = findViewById(R.id.btnUserLogin);

        // Firebase reference
        databaseReference = FirebaseDatabase.getInstance().getReference("Users");

        btnUserLogin.setOnClickListener(v -> {

            String username = etUsername.getText().toString().trim();
            String password = etPassword.getText().toString().trim();

            if (username.isEmpty() || password.isEmpty()) {
                Toast.makeText(UserLoginActivity.this,
                        "Please fill all fields",
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

                                if (dbPassword != null && dbPassword.equals(password)) {

                                    Toast.makeText(UserLoginActivity.this,
                                            "Login Successful 🩸🔥",
                                            Toast.LENGTH_SHORT).show();

                                    Intent intent = new Intent(
                                            UserLoginActivity.this,
                                            DonorDashboardActivity.class);

                                    intent.putExtra("userId", snapshot.getKey());
                                    startActivity(intent);
                                    finish();

                                } else {
                                    Toast.makeText(UserLoginActivity.this,
                                            "Invalid Password",
                                            Toast.LENGTH_SHORT).show();
                                }

                            } else {
                                Toast.makeText(UserLoginActivity.this,
                                        "User not found",
                                        Toast.LENGTH_SHORT).show();
                            }
                        }

                        @Override
                        public void onCancelled(DatabaseError error) {
                            Toast.makeText(UserLoginActivity.this,
                                    "Database Error: " + error.getMessage(),
                                    Toast.LENGTH_SHORT).show();
                        }
                    });
        });
    }
}