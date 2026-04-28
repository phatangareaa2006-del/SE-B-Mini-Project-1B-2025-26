package com.example.lendloop2.models

data class BorrowRequest(
    var requestId: String = "",
    var itemId: String = "",
    var itemName: String = "",
    var ownerId: String = "",
    var requesterId: String = "",
    var requesterName: String = "",
    var requesterContact: String = "",
    var requesterEmail: String = "",
    var requestDate: String = "",
    var status: String = "Pending",   // Pending / Approved / Rejected / Returning / Returned / Broken
    var fine: Int = 0
)
