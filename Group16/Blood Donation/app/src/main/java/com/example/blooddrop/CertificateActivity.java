package com.example.blooddrop;

import android.os.Bundle;
import android.print.PrintAttributes;
import android.print.PrintDocumentAdapter;
import android.print.PrintManager;
import android.webkit.WebView;
import android.webkit.WebViewClient;

import androidx.appcompat.app.AppCompatActivity;

import com.google.android.material.button.MaterialButton;

import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Locale;

public class CertificateActivity extends AppCompatActivity {

    WebView webViewCertificate;
    MaterialButton btnPrint;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_certificate);

        webViewCertificate = findViewById(R.id.webViewCertificate);
        btnPrint           = findViewById(R.id.btnPrint);

        // Get data from intent
        String donorName = getIntent().getStringExtra("donorName");
        String patient   = getIntent().getStringExtra("patient");
        String blood     = getIntent().getStringExtra("blood");
        String units     = getIntent().getStringExtra("units");
        String hospital  = getIntent().getStringExtra("hospital");

        // Format today's date
        String date = new SimpleDateFormat("dd MMMM yyyy", Locale.getDefault())
                .format(new Date());

        // Generate certificate HTML
        String html = buildCertificateHtml(donorName, patient, blood, units, hospital, date);

        webViewCertificate.getSettings().setJavaScriptEnabled(true);
        webViewCertificate.loadDataWithBaseURL(null, html, "text/html", "UTF-8", null);

        // Print / Save as PDF
        btnPrint.setOnClickListener(v -> {
            webViewCertificate.setWebViewClient(new WebViewClient() {
                @Override
                public void onPageFinished(WebView view, String url) {
                    PrintManager printManager =
                            (PrintManager) getSystemService(PRINT_SERVICE);
                    PrintDocumentAdapter printAdapter =
                            webViewCertificate.createPrintDocumentAdapter(
                                    "BloodDrop_Certificate_" + donorName);
                    PrintAttributes.Builder builder = new PrintAttributes.Builder();
                    builder.setMediaSize(PrintAttributes.MediaSize.ISO_A4);
                    printManager.print("BloodDrop Certificate",
                            printAdapter, builder.build());
                }
            });
            webViewCertificate.loadDataWithBaseURL(null,
                    buildCertificateHtml(donorName, patient, blood, units, hospital, date),
                    "text/html", "UTF-8", null);
        });
    }

    private String buildCertificateHtml(String donorName, String patient,
                                        String blood, String units,
                                        String hospital, String date) {
        return "<!DOCTYPE html><html><head>" +
                "<meta charset='UTF-8'>" +
                "<meta name='viewport' content='width=device-width, initial-scale=1.0'>" +
                "<style>" +
                "  * { margin: 0; padding: 0; box-sizing: border-box; }" +
                "  body { font-family: Georgia, serif; background: #fff; padding: 20px; }" +
                "  .cert { border: 8px double #D70404; padding: 30px; border-radius: 12px; " +
                "          max-width: 680px; margin: auto; background: #fff; }" +
                "  .header { text-align: center; margin-bottom: 24px; }" +
                "  .logo { font-size: 48px; }" +
                "  .org { font-size: 28px; font-weight: bold; color: #D70404; " +
                "          letter-spacing: 3px; margin-top: 8px; }" +
                "  .subtitle { font-size: 13px; color: #888; letter-spacing: 1px; margin-top: 4px; }" +
                "  .divider { border: none; border-top: 2px solid #D70404; " +
                "              margin: 16px 0; opacity: 0.4; }" +
                "  .title { text-align: center; font-size: 22px; font-weight: bold; " +
                "            color: #1A1A1A; margin: 16px 0 8px; text-transform: uppercase; " +
                "            letter-spacing: 2px; }" +
                "  .presented { text-align: center; color: #555; font-size: 14px; margin-bottom: 4px; }" +
                "  .donor-name { text-align: center; font-size: 32px; font-weight: bold; " +
                "                 color: #D70404; margin: 8px 0 4px; font-style: italic; }" +
                "  .desc { text-align: center; color: #444; font-size: 14px; " +
                "           line-height: 1.7; margin: 12px 0 20px; }" +
                "  .details { background: #FFF5F5; border-radius: 10px; " +
                "              padding: 16px 20px; margin: 16px 0; }" +
                "  .detail-row { display: flex; justify-content: space-between; " +
                "                 padding: 6px 0; border-bottom: 1px solid #FFE0E0; " +
                "                 font-size: 14px; }" +
                "  .detail-row:last-child { border-bottom: none; }" +
                "  .detail-label { color: #888; }" +
                "  .detail-value { font-weight: bold; color: #1A1A1A; }" +
                "  .blood-badge { display: inline-block; background: #D70404; color: #fff; " +
                "                  padding: 2px 12px; border-radius: 20px; font-weight: bold; }" +
                "  .footer { text-align: center; margin-top: 24px; }" +
                "  .signature-line { display: inline-block; width: 180px; " +
                "                     border-top: 2px solid #333; padding-top: 6px; " +
                "                     font-size: 12px; color: #555; }" +
                "  .date-text { color: #888; font-size: 12px; margin-top: 16px; }" +
                "  .badge { text-align: center; margin-top: 16px; }" +
                "  .badge span { background: #D70404; color: #fff; padding: 6px 20px; " +
                "                 border-radius: 20px; font-size: 12px; letter-spacing: 1px; }" +
                "</style></head><body>" +
                "<div class='cert'>" +
                "  <div class='header'>" +
                "    <div class='logo'>🩸</div>" +
                "    <div class='org'>BLOODDROP</div>" +
                "    <div class='subtitle'>BLOOD DONATION NETWORK</div>" +
                "  </div>" +
                "  <hr class='divider'>" +
                "  <div class='title'>Certificate of Blood Donation</div>" +
                "  <p class='presented'>This certificate is proudly presented to</p>" +
                "  <div class='donor-name'>" + donorName + "</div>" +
                "  <p class='desc'>In recognition of their selfless act of donating blood<br>" +
                "  and contributing to saving a precious human life.</p>" +
                "  <div class='details'>" +
                "    <div class='detail-row'>" +
                "      <span class='detail-label'>Patient Name</span>" +
                "      <span class='detail-value'>" + patient + "</span>" +
                "    </div>" +
                "    <div class='detail-row'>" +
                "      <span class='detail-label'>Blood Group</span>" +
                "      <span class='detail-value'><span class='blood-badge'>" + blood + "</span></span>" +
                "    </div>" +
                "    <div class='detail-row'>" +
                "      <span class='detail-label'>Units Donated</span>" +
                "      <span class='detail-value'>" + units + " unit(s)</span>" +
                "    </div>" +
                "    <div class='detail-row'>" +
                "      <span class='detail-label'>Hospital</span>" +
                "      <span class='detail-value'>" + hospital + "</span>" +
                "    </div>" +
                "    <div class='detail-row'>" +
                "      <span class='detail-label'>Date of Donation</span>" +
                "      <span class='detail-value'>" + date + "</span>" +
                "    </div>" +
                "  </div>" +
                "  <div class='footer'>" +
                "    <span class='signature-line'>Authorized Signature</span>" +
                "  </div>" +
                "  <p class='date-text'>Issued on: " + date + "</p>" +
                "  <div class='badge'><span>VERIFIED DONOR</span></div>" +
                "</div></body></html>";
    }
}