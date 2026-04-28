package com.example.blooddrop;

import android.content.Intent;
import android.os.Bundle;
import android.widget.Button;
import androidx.appcompat.app.AppCompatActivity;

public class MainActivity extends AppCompatActivity {

    Button btnUser, btnAdmin;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        btnUser = findViewById(R.id.btnUser);
        btnAdmin = findViewById(R.id.btnAdmin);

        // 🩸 USER → Open UserChoiceActivity
        btnUser.setOnClickListener(v -> {
            startActivity(new Intent(MainActivity.this,
                    UserChoiceActivity.class));
        });

        // 🔐 ADMIN → Open AdminLoginActivity
        btnAdmin.setOnClickListener(v -> {
            startActivity(new Intent(MainActivity.this,
                    AdminLoginActivity.class));
        });
    }
}