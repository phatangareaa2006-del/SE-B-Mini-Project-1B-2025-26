package com.example.lendloop2

import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity
import android.net.Uri
import android.widget.*
import com.example.lendloop2.models.Item
import com.example.lendloop2.utils.FirebaseHelper
import com.example.lendloop2.models.User
import com.google.android.material.switchmaterial.SwitchMaterial
import com.google.android.material.textfield.TextInputEditText
import com.google.firebase.database.DataSnapshot
import com.google.firebase.database.DatabaseError
import com.google.firebase.database.ValueEventListener
import android.content.Intent
import androidx.activity.result.contract.ActivityResultContracts
import java.util.UUID

class UserLendItemActivity : AppCompatActivity() {

    private lateinit var etItemName: TextInputEditText
    private lateinit var etDescription: TextInputEditText
    private lateinit var etContact: TextInputEditText
    private lateinit var spinnerCategory: Spinner
    private lateinit var switchAvailable: SwitchMaterial
    private lateinit var btnPostItem: Button
    private lateinit var btnMyListedItems: Button
    private lateinit var ivItemPreview: ImageView
    private lateinit var btnChooseImage: Button
    private var imageUri: Uri? = null

    private var currentUserName: String = ""

    private val pickImageLauncher = registerForActivityResult(ActivityResultContracts.GetContent()) { uri: Uri? ->
        if (uri != null) {
            imageUri = uri
            ivItemPreview.setImageURI(imageUri)
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_user_lend_item)

        etItemName = findViewById(R.id.etLendItemName)
        etDescription = findViewById(R.id.etLendDescription)
        etContact = findViewById(R.id.etLendContact)
        spinnerCategory = findViewById(R.id.spinnerLendCategory)
        switchAvailable = findViewById(R.id.switchAvailable)
        btnPostItem = findViewById(R.id.btnPostItem)
        btnMyListedItems = findViewById(R.id.btnMyListedItems)
        ivItemPreview = findViewById(R.id.ivLendItemPreview)
        btnChooseImage = findViewById(R.id.btnLendUploadImage)

        // Setup category spinner
        val categories = arrayOf(
            "Textbooks",
            "Lab Equipment",
            "Graphics Kit",
            "Lab Coat",
            "Calculator",
            "Drawing Instruments",
            "Electronics",
            "Sports Equipment",
            "Other"
        )
        spinnerCategory.adapter = ArrayAdapter(
            this,
            android.R.layout.simple_spinner_dropdown_item,
            categories
        )

        // Image picker
        btnChooseImage.setOnClickListener {
            pickImageLauncher.launch("image/*")
        }

        // Load current user name from Firebase
        val currentUser = FirebaseHelper.auth.currentUser
        if (currentUser != null) {
            FirebaseHelper.usersRef.child(currentUser.uid)
                .addListenerForSingleValueEvent(object : ValueEventListener {
                    override fun onDataChange(snapshot: DataSnapshot) {
                        val user = snapshot.getValue(User::class.java)
                        currentUserName = user?.name ?: ""
                    }
                    override fun onCancelled(error: DatabaseError) {}
                })
        }

        btnPostItem.setOnClickListener {
            val name = etItemName.text.toString().trim()
            val description = etDescription.text.toString().trim()
            val contact = etContact.text.toString().trim()
            val category = spinnerCategory.selectedItem.toString()
            val available = switchAvailable.isChecked

            if (name.isEmpty()) {
                etItemName.error = "Item name is required"
                return@setOnClickListener
            }
            if (contact.isEmpty()) {
                etContact.error = "Contact number is required"
                return@setOnClickListener
            }

            val currentUid = FirebaseHelper.auth.currentUser?.uid ?: return@setOnClickListener
            val itemId = UUID.randomUUID().toString()

            val pickedUri = imageUri
            if (pickedUri != null) {
                // Upload image first
                val storageRef = FirebaseHelper.storage.getReference("user_item_images").child("$itemId.jpg")
                storageRef.putFile(pickedUri)
                    .addOnSuccessListener {
                        storageRef.downloadUrl.addOnSuccessListener { uri ->
                            saveUserItem(itemId, name, category, description, available, currentUid, contact, uri.toString())
                        }
                    }
                    .addOnFailureListener {
                        Toast.makeText(this, "Failed to upload image. Posting without it.", Toast.LENGTH_SHORT).show()
                        saveUserItem(itemId, name, category, description, available, currentUid, contact, "")
                    }
            } else {
                saveUserItem(itemId, name, category, description, available, currentUid, contact, "")
            }
        }

        btnMyListedItems.setOnClickListener {
            startActivity(Intent(this, MyListedItemsActivity::class.java))
        }
    }

    private fun saveUserItem(
        itemId: String, name: String, category: String, description: String,
        available: Boolean, currentUid: String, contact: String, imageUrl: String
    ) {
        val item = Item(
            itemId = itemId,
            name = name,
            category = category,
            imageUrl = imageUrl,
            description = description,
            available = available,
            ownerId = currentUid,
            ownerName = currentUserName,
            ownerContact = contact,
            isUserListed = true
        )

        FirebaseHelper.itemsRef.child(itemId).setValue(item)
            .addOnSuccessListener {
                Toast.makeText(this, "✅ Item posted for lending!", Toast.LENGTH_SHORT).show()
                // Clear fields
                etItemName.text?.clear()
                etDescription.text?.clear()
                etContact.text?.clear()
                ivItemPreview.setImageResource(R.drawable.book) // Reset preview
                imageUri = null
            }
            .addOnFailureListener {
                Toast.makeText(this, "Failed to post item. Try again.", Toast.LENGTH_SHORT).show()
            }
    }

}
