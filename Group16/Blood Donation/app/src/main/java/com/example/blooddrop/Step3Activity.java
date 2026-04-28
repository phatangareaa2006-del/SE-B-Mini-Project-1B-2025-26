package com.example.blooddrop;

import android.content.Intent;
import android.database.Cursor;
import android.net.Uri;
import android.os.Bundle;
import android.provider.OpenableColumns;
import android.util.Base64;
import android.widget.LinearLayout;
import android.widget.Toast;

import androidx.appcompat.app.AppCompatActivity;

import com.google.android.material.button.MaterialButton;
import com.google.android.material.textfield.TextInputEditText;

import java.io.ByteArrayOutputStream;
import java.io.InputStream;

public class Step3Activity extends AppCompatActivity {

    TextInputEditText etEmail, etAddress;
    LinearLayout btnUploadAadhar, btnUploadHealth;
    MaterialButton btnNext;

    Uri aadharUri, healthUri;
    String name, gender, phone, blood;

    // ✅ Max file size = 500KB (Firebase Realtime DB node limit safety)
    private static final long MAX_FILE_SIZE_BYTES = 500 * 1024; // 500 KB

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_step3);

        name   = getIntent().getStringExtra("name");
        gender = getIntent().getStringExtra("gender");
        phone  = getIntent().getStringExtra("phone");
        blood  = getIntent().getStringExtra("blood");

        etEmail         = findViewById(R.id.etEmail);
        etAddress       = findViewById(R.id.etAddress);
        btnUploadAadhar = findViewById(R.id.btnUploadAadhar);
        btnUploadHealth = findViewById(R.id.btnUploadHealth);
        btnNext         = findViewById(R.id.btnNext);

        btnUploadAadhar.setOnClickListener(v -> openFilePicker(100));
        btnUploadHealth.setOnClickListener(v -> openFilePicker(200));

        btnNext.setOnClickListener(v -> {
            String email   = etEmail.getText().toString().trim();
            String address = etAddress.getText().toString().trim();

            if (email.isEmpty()) {
                etEmail.setError("Email is required");
                etEmail.requestFocus();
                return;
            }
            if (!email.toLowerCase().endsWith("@gmail.com")) {
                etEmail.setError("Only Gmail allowed (e.g. name@gmail.com)");
                etEmail.requestFocus();
                return;
            }
            if (address.isEmpty()) {
                etAddress.setError("Address is required");
                etAddress.requestFocus();
                return;
            }
            if (aadharUri == null) {
                Toast.makeText(this, "Please upload your Aadhar card",
                        Toast.LENGTH_SHORT).show();
                return;
            }
            if (healthUri == null) {
                Toast.makeText(this, "Please upload your Health Certificate",
                        Toast.LENGTH_SHORT).show();
                return;
            }

            // ✅ Check Aadhar file size BEFORE processing
            long aadharSize = getFileSize(aadharUri);
            if (aadharSize > MAX_FILE_SIZE_BYTES) {
                long sizeKB = aadharSize / 1024;
                Toast.makeText(this,
                        "Aadhar image is too large (" + sizeKB + " KB).\n" +
                                "Maximum allowed size is 500 KB.\n" +
                                "Please compress the image and try again.",
                        Toast.LENGTH_LONG).show();
                return;
            }

            // ✅ Check Health cert file size BEFORE processing
            long healthSize = getFileSize(healthUri);
            if (healthSize > MAX_FILE_SIZE_BYTES) {
                long sizeKB = healthSize / 1024;
                Toast.makeText(this,
                        "Health Certificate is too large (" + sizeKB + " KB).\n" +
                                "Maximum allowed size is 500 KB.\n" +
                                "Please compress the image and try again.",
                        Toast.LENGTH_LONG).show();
                return;
            }

            btnNext.setEnabled(false);
            btnNext.setText("Processing...");

            try {
                String aadharBase64 = convertToBase64(aadharUri);
                String healthBase64 = convertToBase64(healthUri);

                if (aadharBase64 == null || healthBase64 == null) {
                    btnNext.setEnabled(true);
                    btnNext.setText("Next");
                    Toast.makeText(this, "Failed to read files. Try again.",
                            Toast.LENGTH_SHORT).show();
                    return;
                }

                btnNext.setEnabled(true);
                btnNext.setText("Next");

                Intent intent = new Intent(this, Step4Activity.class);
                intent.putExtra("name",         name);
                intent.putExtra("gender",       gender);
                intent.putExtra("phone",        phone);
                intent.putExtra("blood",        blood);
                intent.putExtra("email",        email);
                intent.putExtra("address",      address);
                intent.putExtra("aadharBase64", aadharBase64);
                intent.putExtra("healthBase64", healthBase64);
                startActivity(intent);

            } catch (Exception e) {
                btnNext.setEnabled(true);
                btnNext.setText("Next");
                Toast.makeText(this, "Error: " + e.getMessage(),
                        Toast.LENGTH_SHORT).show();
            }
        });
    }

    // ✅ Get file size in bytes without reading the whole file
    private long getFileSize(Uri uri) {
        long size = -1;
        try {
            // Try using ContentResolver query first (most reliable)
            Cursor cursor = getContentResolver().query(
                    uri, null, null, null, null);
            if (cursor != null) {
                int sizeIndex = cursor.getColumnIndex(OpenableColumns.SIZE);
                cursor.moveToFirst();
                if (sizeIndex != -1) {
                    size = cursor.getLong(sizeIndex);
                }
                cursor.close();
            }

            // Fallback: open stream and count bytes
            if (size <= 0) {
                InputStream is = getContentResolver().openInputStream(uri);
                if (is != null) {
                    size = is.available();
                    is.close();
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return size;
    }

    // ✅ Convert file URI to Base64 string
    private String convertToBase64(Uri uri) {
        try {
            InputStream inputStream = getContentResolver().openInputStream(uri);
            ByteArrayOutputStream byteArrayOutputStream = new ByteArrayOutputStream();
            byte[] buffer = new byte[1024];
            int bytesRead;
            while ((bytesRead = inputStream.read(buffer)) != -1) {
                byteArrayOutputStream.write(buffer, 0, bytesRead);
            }
            byte[] bytes = byteArrayOutputStream.toByteArray();
            inputStream.close();
            return Base64.encodeToString(bytes, Base64.DEFAULT);
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }

    private void openFilePicker(int requestCode) {
        Intent intent = new Intent(Intent.ACTION_GET_CONTENT);
        intent.setType("image/*");
        startActivityForResult(intent, requestCode);
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        if (resultCode == RESULT_OK && data != null) {
            if (requestCode == 100) {
                aadharUri = data.getData();

                // ✅ Show size warning immediately after selection
                long size = getFileSize(aadharUri);
                if (size > MAX_FILE_SIZE_BYTES) {
                    Toast.makeText(this,
                            "Warning: Aadhar image is " + (size / 1024) + " KB. " +
                                    "Max allowed is 500 KB. Please choose a smaller image.",
                            Toast.LENGTH_LONG).show();
                } else {
                    Toast.makeText(this, "Aadhar selected (" + (size / 1024) + " KB)",
                            Toast.LENGTH_SHORT).show();
                }

            } else if (requestCode == 200) {
                healthUri = data.getData();

                // ✅ Show size warning immediately after selection
                long size = getFileSize(healthUri);
                if (size > MAX_FILE_SIZE_BYTES) {
                    Toast.makeText(this,
                            "Warning: Health Certificate is " + (size / 1024) + " KB. " +
                                    "Max allowed is 500 KB. Please choose a smaller image.",
                            Toast.LENGTH_LONG).show();
                } else {
                    Toast.makeText(this,
                            "Health Certificate selected (" + (size / 1024) + " KB)",
                            Toast.LENGTH_SHORT).show();
                }
            }
        }
    }
}