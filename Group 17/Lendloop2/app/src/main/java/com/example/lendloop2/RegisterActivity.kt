package com.example.lendloop2

import android.content.Intent
import androidx.appcompat.app.AppCompatActivity
import android.os.Bundle
import android.widget.*
import com.example.lendloop2.models.User
import com.example.lendloop2.utils.FirebaseHelper

class RegisterActivity : AppCompatActivity() {

    lateinit var etName:EditText
    lateinit var etEmail:EditText
    lateinit var etPassword:EditText
    lateinit var spinnerBranch:Spinner
    lateinit var spinnerYear:Spinner
    lateinit var btnRegister:Button

    override fun onCreate(savedInstanceState: Bundle?) {

        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_register)

        etName = findViewById(R.id.etName)
        etEmail = findViewById(R.id.etEmail)
        etPassword = findViewById(R.id.etPassword)
        spinnerBranch = findViewById(R.id.spinnerBranch)
        spinnerYear = findViewById(R.id.spinnerYear)
        btnRegister = findViewById(R.id.btnRegister)

        val branches = arrayOf("Computer Engineering", "IT", "Mechanical", "Civil")
        val branchAdapter = ArrayAdapter(this, android.R.layout.simple_spinner_dropdown_item, branches)
        spinnerBranch.adapter = branchAdapter

        val years = arrayOf("FE", "SE", "TE", "BE")
        val yearAdapter = ArrayAdapter(this, android.R.layout.simple_spinner_dropdown_item, years)
        spinnerYear.adapter = yearAdapter

        btnRegister.setOnClickListener {

            val name = etName.text.toString().trim()
            val email = etEmail.text.toString().trim()
            val password = etPassword.text.toString()
            val branch = spinnerBranch.selectedItem.toString()
            val year = spinnerYear.selectedItem.toString()

            if (name.isEmpty()) {
                etName.error = "Name is required"
                return@setOnClickListener
            }
            if (email.isEmpty()) {
                etEmail.error = "Email is required"
                return@setOnClickListener
            }
            if (password.length < 6) {
                etPassword.error = "Password must be at least 6 characters"
                return@setOnClickListener
            }

            FirebaseHelper.auth.createUserWithEmailAndPassword(email, password)

                .addOnSuccessListener {

                    val userId = FirebaseHelper.auth.currentUser!!.uid

                    val user = User(
                        userId,
                        name,
                        email,
                        branch,
                        year
                    )

                    FirebaseHelper.usersRef.child(userId).setValue(user)

                    Toast.makeText(this, "Account Created", Toast.LENGTH_SHORT).show()

                    startActivity(Intent(this, LoginActivity::class.java))

                }

                .addOnFailureListener { exception ->

                    Toast.makeText(this, "Registration Failed: ${exception.message}", Toast.LENGTH_LONG).show()

                }

        }

    }
}