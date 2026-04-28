package com.example.blooddrop;

import android.content.Intent;
import android.os.Bundle;
import android.widget.Toast;

import androidx.appcompat.app.AppCompatActivity;
import androidx.cardview.widget.CardView;

public class UserChoiceActivity extends AppCompatActivity {

    CardView btnAccepter, btnDonor;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_user_choice);

        btnAccepter = findViewById(R.id.btnAccepter);
        btnDonor = findViewById(R.id.btnDonor);

        btnAccepter.setOnClickListener(v -> {
            Toast.makeText(UserChoiceActivity.this, "Accepter clicked", Toast.LENGTH_SHORT).show();
            Intent intent = new Intent(UserChoiceActivity.this, AccepterAuthActivity.class);
            startActivity(intent);
        });

        btnDonor.setOnClickListener(v -> {
            startActivity(new Intent(UserChoiceActivity.this, UserAuthActivity.class));
        });
    }
}