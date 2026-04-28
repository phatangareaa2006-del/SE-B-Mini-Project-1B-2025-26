package com.example.lendloop2

import android.app.Activity
import android.net.Uri
import androidx.appcompat.app.AppCompatActivity
import android.os.Bundle
import android.widget.*
import androidx.activity.result.contract.ActivityResultContracts
import com.example.lendloop2.models.Item
import com.example.lendloop2.utils.FirebaseHelper
import java.util.*

class AddItemActivity : AppCompatActivity() {

    lateinit var itemImage:ImageView
    lateinit var btnUploadImage:Button
    lateinit var btnAddItem:Button
    lateinit var etItemName:EditText
    lateinit var spinnerCategory:Spinner

    var imageUri:Uri?=null

    private val pickImageLauncher = registerForActivityResult(ActivityResultContracts.GetContent()) { uri: Uri? ->
        if (uri != null) {
            imageUri = uri
            itemImage.setImageURI(imageUri)
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {

        super.onCreate(savedInstanceState)

        setContentView(R.layout.activity_add_item)

        itemImage=findViewById(R.id.itemImage)
        btnUploadImage=findViewById(R.id.btnUploadImage)
        btnAddItem=findViewById(R.id.btnAddItem)
        etItemName=findViewById(R.id.etItemName)
        spinnerCategory=findViewById(R.id.spinnerCategory)

        val categories=arrayOf(
            "FE Textbooks",
            "SE Textbooks",
            "TE Textbooks",
            "BE Textbooks",
            "Graphics Kit",
            "Lab Coat"
        )

        val adapter=ArrayAdapter(
            this,
            android.R.layout.simple_spinner_dropdown_item,
            categories
        )

        spinnerCategory.adapter=adapter

        btnUploadImage.setOnClickListener {
            pickImageLauncher.launch("image/*")
        }

        btnAddItem.setOnClickListener {
            val itemName = etItemName.text.toString().trim()
            val category = spinnerCategory.selectedItem.toString()

            if (itemName.isEmpty()) {
                etItemName.error = "Item name is required"
                return@setOnClickListener
            }

            val itemId = UUID.randomUUID().toString()
            
            if (imageUri != null) {
                // Upload image first
                val storageRef = FirebaseHelper.storage.getReference("item_images").child("$itemId.jpg")
                storageRef.putFile(imageUri!!)
                    .addOnSuccessListener {
                        storageRef.downloadUrl.addOnSuccessListener { uri ->
                            saveItem(itemId, itemName, category, uri.toString())
                        }
                    }
                    .addOnFailureListener {
                        Toast.makeText(this, "Failed to upload image", Toast.LENGTH_SHORT).show()
                        saveItem(itemId, itemName, category, "")
                    }
            } else {
                saveItem(itemId, itemName, category, "")
            }
        }
    }

    private fun saveItem(itemId: String, name: String, category: String, imageUrl: String) {
        val item = Item(
            itemId = itemId,
            name = name,
            category = category,
            imageUrl = imageUrl,
            available = true
        )

        FirebaseHelper.itemsRef.child(itemId).setValue(item)
            .addOnSuccessListener {
                Toast.makeText(this, "Item Added Successfully", Toast.LENGTH_SHORT).show()
                finish()
            }
            .addOnFailureListener {
                Toast.makeText(this, "Failed to add item", Toast.LENGTH_SHORT).show()
            }
    }

}