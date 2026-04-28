package com.example.safewave;

import androidx.appcompat.app.AppCompatActivity;
import androidx.core.app.ActivityCompat;

import android.Manifest;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.pm.PackageManager;
import android.location.Address;
import android.location.Geocoder;
import android.location.Location;
import android.net.Uri;
import android.os.Bundle;
import android.widget.*;

import com.google.android.gms.location.FusedLocationProviderClient;
import com.google.android.gms.location.LocationServices;
import com.google.android.gms.location.Priority;

import org.json.JSONArray;
import org.json.JSONException;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;

public class MainActivity extends AppCompatActivity {

    EditText editName, editPhone;
    Button btnSave, btnSOS, btnView;
    TableLayout tableLayout;

    ArrayList<String[]> contactList = new ArrayList<>();
    SharedPreferences sp;

    FusedLocationProviderClient fusedLocationClient;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        editName = findViewById(R.id.editName);
        editPhone = findViewById(R.id.editPhone);
        btnSave = findViewById(R.id.btnSave);
        btnSOS = findViewById(R.id.btnSOS);
        btnView = findViewById(R.id.btnView);
        tableLayout = findViewById(R.id.tableLayout);

        sp = getSharedPreferences("contacts", MODE_PRIVATE);
        fusedLocationClient = LocationServices.getFusedLocationProviderClient(this);

        ActivityCompat.requestPermissions(this,
                new String[]{Manifest.permission.ACCESS_FINE_LOCATION}, 1);

        loadContacts();

        // 🔥 SAVE WITH POPUP
        btnSave.setOnClickListener(v -> {

            String name = editName.getText().toString().trim();
            String number = editPhone.getText().toString().trim();

            if(name.isEmpty() || number.isEmpty()){
                Toast.makeText(this,"Enter details",Toast.LENGTH_SHORT).show();
                return;
            }

            new android.app.AlertDialog.Builder(this)
                    .setTitle("Confirm Save")
                    .setMessage("Do you want to save this contact?")
                    .setPositiveButton("YES", (dialog, which) -> {

                        contactList.add(new String[]{name, number});
                        saveContacts();

                        editName.setText("");
                        editPhone.setText("");

                        Toast.makeText(this,"Contact Saved",Toast.LENGTH_SHORT).show();
                    })
                    .setNegativeButton("NO", null)
                    .show();
        });

        // VIEW
        btnView.setOnClickListener(v -> {
            tableLayout.setVisibility(TextView.VISIBLE);
            displayContacts();
        });

        // SOS
        btnSOS.setOnClickListener(v -> sendSOS());
    }

    // 🔥 SOS FUNCTION
    private void sendSOS(){

        if(contactList.isEmpty()){
            Toast.makeText(this,"No contacts",Toast.LENGTH_SHORT).show();
            return;
        }

        if (ActivityCompat.checkSelfPermission(this,
                Manifest.permission.ACCESS_FINE_LOCATION)
                != PackageManager.PERMISSION_GRANTED) {

            Toast.makeText(this,"Location permission needed",Toast.LENGTH_SHORT).show();
            return;
        }

        fusedLocationClient.getCurrentLocation(Priority.PRIORITY_HIGH_ACCURACY, null)
                .addOnSuccessListener(location -> {

                    String msg = "⚠️ Emergency! Help needed!";

                    if(location != null){
                        msg += "\nLocation: " + getAddress(location);
                    }

                    openSMS(msg);
                });
    }

    // 🔥 MULTIPLE CONTACT SMS
    private void openSMS(String msg){

        StringBuilder numbers = new StringBuilder();

        for(int i=0; i<contactList.size(); i++){
            numbers.append(contactList.get(i)[1]);

            if(i != contactList.size()-1){
                numbers.append(";");
            }
        }

        Uri uri = Uri.parse("smsto:" + numbers.toString());

        Intent intent = new Intent(Intent.ACTION_SENDTO, uri);
        intent.putExtra("sms_body", msg);

        startActivity(intent);
    }

    // 🔥 ADDRESS
    private String getAddress(Location location){

        Geocoder geocoder = new Geocoder(this, Locale.getDefault());

        try {
            List<Address> list = geocoder.getFromLocation(
                    location.getLatitude(),
                    location.getLongitude(),
                    1
            );

            if(list != null && list.size() > 0){
                return list.get(0).getAddressLine(0);
            }

        } catch (IOException e){
            e.printStackTrace();
        }

        return "Address not found";
    }

    // SAVE CONTACTS
    private void saveContacts() {

        JSONArray arr = new JSONArray();

        for(String[] c : contactList){
            JSONArray obj = new JSONArray();
            obj.put(c[0]);
            obj.put(c[1]);
            arr.put(obj);
        }

        sp.edit().putString("list", arr.toString()).apply();
    }

    // LOAD CONTACTS
    private void loadContacts() {

        String data = sp.getString("list", null);

        if(data != null){
            try {
                JSONArray arr = new JSONArray(data);
                for(int i=0;i<arr.length();i++){
                    JSONArray obj = arr.getJSONArray(i);
                    contactList.add(new String[]{
                            obj.getString(0),
                            obj.getString(1)
                    });
                }
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }
    }

    // 🔥 DISPLAY WITH LONG PRESS DELETE
    private void displayContacts() {

        tableLayout.removeViews(1,
                Math.max(0, tableLayout.getChildCount()-1));

        for(int i=0;i<contactList.size();i++){

            int index = i;

            TableRow row = new TableRow(this);

            TextView name = new TextView(this);
            name.setText(contactList.get(i)[0]);
            name.setPadding(10,10,10,10);

            TextView phone = new TextView(this);
            phone.setText(contactList.get(i)[1]);
            phone.setPadding(10,10,10,10);

            row.addView(name);
            row.addView(phone);

            // 🔥 LONG PRESS DELETE
            row.setOnLongClickListener(v -> {

                new android.app.AlertDialog.Builder(this)
                        .setTitle("Delete Contact")
                        .setMessage("Do you want to delete this contact?")
                        .setPositiveButton("YES", (dialog, which) -> {

                            contactList.remove(index);
                            saveContacts();
                            displayContacts();

                            Toast.makeText(this,"Deleted",Toast.LENGTH_SHORT).show();
                        })
                        .setNegativeButton("NO", null)
                        .show();

                return true;
            });

            tableLayout.addView(row);
        }
    }
}