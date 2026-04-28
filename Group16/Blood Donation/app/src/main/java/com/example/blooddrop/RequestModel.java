package com.example.blooddrop;

public class RequestModel {

    public String requestId;
    public String bloodGroup;
    public String units;
    public String location;
    public String status;

    public RequestModel() { }

    public RequestModel(String requestId, String bloodGroup,
                        String units, String location, String status) {

        this.requestId = requestId;
        this.bloodGroup = bloodGroup;
        this.units = units;
        this.location = location;
        this.status = status;
    }
}