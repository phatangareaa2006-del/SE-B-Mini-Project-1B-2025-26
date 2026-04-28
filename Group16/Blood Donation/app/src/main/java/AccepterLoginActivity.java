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

public class AccepterLoginActivity extends AppCompatActivity {

    EditText etUsername, etPassword;
    Button btnLogin;

    DatabaseReference databaseReference;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_accepter_login);

        etUsername = findViewById(R.id.etUsername);
        etPassword = findViewById(R.id.etPassword);
        btnLogin = findViewById(R.id.btnLogin);

        // 🔥 Same Firebase node
        databaseReference = FirebaseDatabase.getInstance()
                .getReference("Acceptors");

        btnLogin.setOnClickListener(v -> {

            String username = etUsername.getText().toString().trim();
            String password = etPassword.getText().toString().trim();

            if (username.isEmpty() || password.isEmpty()) {
                Toast.makeText(this,
                        "Fill all fields",
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

                                if (password.equals(dbPassword)) {

                                    Toast.makeText(AccepterLoginActivity.this,
                                            "Login Successful 🔥",
                                            Toast.LENGTH_SHORT).show();

                                    startActivity(new Intent(
                                            AccepterLoginActivity.this,
                                            AcceptorDashboardActivity.class));

                                    finish();

                                } else {
                                    Toast.makeText(AccepterLoginActivity.this,
                                            "Invalid Password",
                                            Toast.LENGTH_SHORT).show();
                                }

                            } else {
                                Toast.makeText(AccepterLoginActivity.this,
                                        "User not found",
                                        Toast.LENGTH_SHORT).show();
                            }
                        }

                        @Override
                        public void onCancelled(DatabaseError error) {
                            Toast.makeText(AccepterLoginActivity.this,
                                    "Database Error",
                                    Toast.LENGTH_SHORT).show();
                        }
                    });
        });
    }
}