package com.example.blooddrop;

import android.content.Intent;
import android.os.Bundle;
import android.widget.Button;
import androidx.appcompat.app.AppCompatActivity;

public class UserAuthActivity extends AppCompatActivity {

    Button btnLogin, btnSignup;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_user_auth);

        btnLogin = findViewById(R.id.btnLogin);
        btnSignup = findViewById(R.id.btnSignup);

        // 🔐 LOGIN → Open Login Page
        btnLogin.setOnClickListener(v ->
                startActivity(new Intent(UserAuthActivity.this,
                        UserActivity.class))
        );

        // 📝 SIGNUP → Start Registration Flow
        btnSignup.setOnClickListener(v ->
                startActivity(new Intent(UserAuthActivity.this,
                        Step1Activity.class))
        );
    }
}