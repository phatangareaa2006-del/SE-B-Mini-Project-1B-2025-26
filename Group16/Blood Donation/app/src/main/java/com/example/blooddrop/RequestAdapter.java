package com.example.blooddrop;

import android.app.Activity;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.TextView;

import java.util.ArrayList;

public class RequestAdapter extends ArrayAdapter<String> {

    Activity context;
    ArrayList<String> requests;

    public RequestAdapter(Activity context, ArrayList<String> requests) {
        super(context, android.R.layout.simple_list_item_1, requests);
        this.context = context;
        this.requests = requests;
    }

    public View getView(int position, View view, ViewGroup parent) {

        TextView textView = new TextView(context);
        textView.setPadding(20,20,20,20);
        textView.setTextSize(16);

        textView.setText(requests.get(position));

        return textView;
    }
}