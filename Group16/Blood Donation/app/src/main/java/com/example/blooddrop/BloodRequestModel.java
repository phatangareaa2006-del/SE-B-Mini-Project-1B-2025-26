package com.example.blooddrop;

public class BloodRequestModel {
    public String key, patient, blood, units, hospital, status, donorName;

    public BloodRequestModel() {}

    public BloodRequestModel(String key, String patient, String blood,
                             String units, String hospital, String status,
                             String donorName) {
        this.key       = key;
        this.patient   = patient;
        this.blood     = blood;
        this.units     = units;
        this.hospital  = hospital;
        this.status    = status;
        this.donorName = donorName; // ✅ who accepted this request
    }
}