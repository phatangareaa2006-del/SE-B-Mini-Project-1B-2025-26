package com.example.blooddrop;

public class Donor {

    public String userId;
    public String name;
    public String gender;
    public String phone;
    public String blood;
    public String email;
    public String address;
    public String username;
    public String password;

    // 🔥 Required empty constructor for Firebase
    public Donor() {
    }

    public Donor(String userId,
                 String name,
                 String gender,
                 String phone,
                 String blood,
                 String email,
                 String address,
                 String username,
                 String password) {

        this.userId = userId;
        this.name = name;
        this.gender = gender;
        this.phone = phone;
        this.blood = blood;
        this.email = email;
        this.address = address;
        this.username = username;
        this.password = password;
    }
}