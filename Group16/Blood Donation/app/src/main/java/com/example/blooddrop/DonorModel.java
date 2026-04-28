package com.example.blooddrop;

public class DonorModel {
    public String name, blood, phone, email, address, gender;

    public DonorModel() {}

    public DonorModel(String name, String blood, String phone,
                      String email, String address, String gender) {
        this.name    = name;
        this.blood   = blood;
        this.phone   = phone;
        this.email   = email;
        this.address = address;
        this.gender  = gender;
    }
}