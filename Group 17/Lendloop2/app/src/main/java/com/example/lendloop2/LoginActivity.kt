package com.example.lendloop2

import android.content.Intent
import androidx.appcompat.app.AppCompatActivity
import android.os.Bundle
import android.widget.*
import com.example.lendloop2.utils.FirebaseHelper

class LoginActivity : AppCompatActivity() {

    lateinit var etEmail:EditText
    lateinit var etPassword:EditText
    lateinit var btnLogin:Button
    lateinit var tvRegister:TextView

    override fun onCreate(savedInstanceState: Bundle?) {

        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_login)

        etEmail = findViewById(R.id.etEmail)
        etPassword = findViewById(R.id.etPassword)
        btnLogin = findViewById(R.id.btnLogin)
        tvRegister = findViewById(R.id.tvRegister)

        btnLogin.setOnClickListener {

            val email = etEmail.text.toString().trim()
            val password = etPassword.text.toString()

            FirebaseHelper.auth.signInWithEmailAndPassword(email, password)
                .addOnSuccessListener {

                    Toast.makeText(this, "Login Success", Toast.LENGTH_SHORT).show()

                    val intent = Intent(this@LoginActivity, DashboardActivity::class.java)
                    startActivity(intent)
                    finish()
                }
                .addOnFailureListener { exception ->
                    Toast.makeText(this, "Login Failed: ${exception.message}", Toast.LENGTH_LONG).show()
                }
        }

        tvRegister.setOnClickListener {

            startActivity(Intent(this,RegisterActivity::class.java))

        }

    }

}