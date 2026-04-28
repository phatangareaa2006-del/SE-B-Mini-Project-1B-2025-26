package com.example.blooddrop;

import android.content.Intent;
import android.os.Bundle;
import android.widget.ArrayAdapter;
import android.widget.Spinner;
import android.widget.Toast;

import androidx.appcompat.app.AppCompatActivity;

import com.google.android.material.button.MaterialButton;
import com.google.android.material.textfield.TextInputEditText;

public class Step2Activity extends AppCompatActivity {

    TextInputEditText etPhone;
    Spinner spinnerBlood;
    MaterialButton btnNext;

    String name, gender;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_step2);

        name   = getIntent().getStringExtra("name");
        gender = getIntent().getStringExtra("gender");

        etPhone      = findViewById(R.id.etPhone);
        etPhone.setFilters(new android.text.InputFilter[]{ new android.text.InputFilter.LengthFilter(10) });
        spinnerBlood = findViewById(R.id.spinnerBlood);
        btnNext      = findViewById(R.id.btnNext);

        String[] bloodGroups = {
                "Select Blood Group",
                "A+","A-","B+","B-",
                "O+","O-","AB+","AB-"
        };

        ArrayAdapter<String> adapter = new ArrayAdapter<String>(
                this, android.R.layout.simple_spinner_item, bloodGroups) {
            @Override
            public android.view.View getView(int position, android.view.View convertView,
                                             android.view.ViewGroup parent) {
                android.view.View view = super.getView(position, convertView, parent);
                ((android.widget.TextView) view).setTextColor(android.graphics.Color.BLACK);
                return view;
            }

            @Override
            public android.view.View getDropDownView(int position, android.view.View convertView,
                                                     android.view.ViewGroup parent) {
                android.view.View view = super.getDropDownView(position, convertView, parent);
                android.widget.TextView text = (android.widget.TextView) view;
                text.setTextColor(android.graphics.Color.BLACK);
                text.setBackgroundColor(android.graphics.Color.WHITE);
                return view;
            }
        };

        adapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
        spinnerBlood.setAdapter(adapter);

        btnNext.setOnClickListener(v -> {
            String phone = etPhone.getText().toString().trim();
            String blood = spinnerBlood.getSelectedItem().toString();

            // ✅ Phone empty check
            if (phone.isEmpty()) {
                etPhone.setError("Phone number is required");
                etPhone.requestFocus();
                return;
            }

            // ✅ Exactly 10 digits
            if (!phone.matches("[6-9]\\d{9}")) {
                etPhone.setError("Enter a valid Indian phone number (starts with 6-9)");
                etPhone.requestFocus();
                return;
            }

            // ✅ Blood group check
            if (blood.equals("Select Blood Group")) {
                Toast.makeText(this, "Please select a blood group",
                        Toast.LENGTH_SHORT).show();
                return;
            }

            Intent intent = new Intent(Step2Activity.this, Step3Activity.class);
            intent.putExtra("name",   name);
            intent.putExtra("gender", gender);
            intent.putExtra("phone",  phone);
            intent.putExtra("blood",  blood);
            startActivity(intent);
        });
    }
}