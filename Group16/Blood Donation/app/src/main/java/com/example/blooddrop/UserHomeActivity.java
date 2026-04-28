package com.example.blooddrop;

import android.os.Bundle;
import android.widget.ArrayAdapter;
import android.widget.ListView;

import androidx.appcompat.app.AppCompatActivity;

import com.google.firebase.database.DataSnapshot;
import com.google.firebase.database.DatabaseReference;
import com.google.firebase.database.FirebaseDatabase;

import java.util.ArrayList;

public class UserHomeActivity extends AppCompatActivity {

    ListView listView;
    ArrayList<String> donorList;

    DatabaseReference databaseReference;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_user_home);

        listView = findViewById(R.id.listViewDonors);
        donorList = new ArrayList<>();

        databaseReference = FirebaseDatabase
                .getInstance()
                .getReference("Donors");

        databaseReference.get().addOnCompleteListener(task -> {

            if (task.isSuccessful()) {

                for (DataSnapshot snapshot : task.getResult().getChildren()) {

                    String name = snapshot.child("name").getValue(String.class);
                    String blood = snapshot.child("blood").getValue(String.class);
                    String phone = snapshot.child("phone").getValue(String.class);

                    donorList.add(
                            "Name: " + name +
                                    "\nBlood: " + blood +
                                    "\nPhone: " + phone
                    );
                }

                ArrayAdapter<String> adapter =
                        new ArrayAdapter<>(
                                this,
                                android.R.layout.simple_list_item_1,
                                donorList
                        );

                listView.setAdapter(adapter);
            }
        });
    }
}