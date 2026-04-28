package com.example.lendloop2.models

data class Item(
    var itemId: String = "",
    var name: String = "",
    var category: String = "",
    var imageUrl: String = "",
    var available: Boolean = true,
    var borrowedBy: String = "",
    var fine: Int = 0,
    var remark: String = "",
    var ownerId: String = "",
    var ownerName: String = "",
    var ownerContact: String = "",
    var description: String = "",
    var isUserListed: Boolean = false,
    var isBroken: Boolean = false
)