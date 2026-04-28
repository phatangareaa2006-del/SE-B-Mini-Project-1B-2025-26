package com.example.blooddrop;

import android.content.Intent;
import android.os.Bundle;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.EditText;
import android.widget.Spinner;
import android.widget.Toast;

import androidx.appcompat.app.AppCompatActivity;

public class Step1Activity extends AppCompatActivity {

    EditText etName;
    Spinner spGender;
    Button btnNext;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_step1);

        etName = findViewById(R.id.etName);
        spGender = findViewById(R.id.spGender);
        btnNext = findViewById(R.id.btnNext);

        String[] genderOptions = {"Male", "Female", "Other"};

        ArrayAdapter<String> adapter = new ArrayAdapter<String>(
                this,
                android.R.layout.simple_spinner_item,
                genderOptions
        ) {
            @Override
            public android.view.View getView(int position, android.view.View convertView, android.view.ViewGroup parent) {
                android.view.View view = super.getView(position, convertView, parent);
                android.widget.TextView text = (android.widget.TextView) view;
                text.setTextColor(android.graphics.Color.BLACK);
                return view;
            }

            @Override
            public android.view.View getDropDownView(int position, android.view.View convertView, android.view.ViewGroup parent) {
                android.view.View view = super.getDropDownView(position, convertView, parent);
                android.widget.TextView text = (android.widget.TextView) view;
                text.setTextColor(android.graphics.Color.BLACK);
                text.setBackgroundColor(android.graphics.Color.WHITE);
                return view;
            }
        };

        adapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
        spGender.setAdapter(adapter);

        btnNext.setOnClickListener(v -> {

            String name = etName.getText().toString().trim();
            String gender = spGender.getSelectedItem().toString();

            if (name.isEmpty()) {
                Toast.makeText(this, "Enter Name", Toast.LENGTH_SHORT).show();
            } else {
                Intent intent = new Intent(Step1Activity.this, Step2Activity.class);
                intent.putExtra("name", name);
                intent.putExtra("gender", gender);
                startActivity(intent);
            }
        });
    }
}