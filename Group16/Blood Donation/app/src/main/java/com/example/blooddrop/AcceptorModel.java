package com.example.blooddrop;

public class AcceptorModel {
    public String hospital, speciality, phone, email, address, location;

    public AcceptorModel() {}

    public AcceptorModel(String hospital, String speciality, String phone,
                         String email, String address, String location) {
        this.hospital   = hospital;
        this.speciality = speciality;
        this.phone      = phone;
        this.email      = email;
        this.address    = address;
        this.location   = location;
    }
}