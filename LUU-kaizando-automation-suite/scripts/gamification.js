/**
 * MODULE: Gamification Engine
 * PURPOSE: Sends a monthly email to participants with their current Kaizando point balance.
 * FEATURES: HTML formatting, Name extraction from email string, Multi-language greeting.
 */

function sendMonthlyPointReminders() {
  
  // --- CONFIGURATION ---
  var yourLink = "https://forms.gle/1oGjfqyeEVRQ4tkW7"; 
  var sheetName = "Scoreboard"; 
  // ---------------------

  // 1. Access the correct sheet
  var spreadsheet = SpreadsheetApp.getActiveSpreadsheet();
  var sheet = spreadsheet.getSheetByName(sheetName);

  if (!sheet) {
    Logger.log("Error: Sheet named '" + sheetName + "' was not found.");
    return;
  }

  // 2. Get all the data from the sheet
  var dataRange = sheet.getDataRange();
  var data = dataRange.getValues();

  // 3. Define the email subject
  var subject = "Dein monatliches Kaizando-Punkte-Update / Your Monthly Kaizando Points Update";
  var blueStyle = "color: #0000FF;"; // CSS Style for highlighting

  // 4. LOOP THROUGH USERS (Start at row 1 to skip header)
  for (var i = 1; i < data.length; i++) {
    var row = data[i];
    var emailAddress = row[1]; // Column B
    var points = row[5];       // Column F

    // Only send if email exists AND points > 0
    if (emailAddress && emailAddress.trim() !== "" && parseFloat(points) > 0) {
      
      // 5. EXTRACT FIRST NAME LOGIC
      var firstName = ""; 
      try {
        var namePart = emailAddress.split('@')[0]; 
        var firstNameRaw = namePart.split('.')[0]; 
        if (firstNameRaw) {
          firstName = firstNameRaw.charAt(0).toUpperCase() + firstNameRaw.slice(1); 
        }
      } catch (e) {
        Logger.log("Could not parse name for: " + emailAddress);
      }

      // 6. HTML EMAIL TEMPLATE (Cleaned to remove Hidden Unicode Warning)
      var emailBody = `
        <p><b>[DE] Deutsch</b></p>
        <p>Hallo ${firstName}👋,</p>
        <p>vielen Dank für dein Engagement und deine wertvollen Beiträge zu unserem <span style="${blueStyle}">Kaizando-Prozess</span>. Jede Idee hilft uns bei der kontinuierlichen Verbesserung unserer Abläufe am Standort.</p>
        <p>Dein aktuelles Prämienguthaben beträgt <b>${points} Punkte.</b></p>
        <p>Du kannst deine gesammelten Punkte jederzeit gegen Goodies aus unserem Kreativshop einlösen. Die Ausgabe findet jeden Freitag zwischen <b>12:45 und 13:45</b> Uhr in Simones Büro statt.</p>
        <p>Wir freuen uns auf deine nächsten Ideen. (<a href="${yourLink}">Link zum Formular</a>)</p>

        <br>
        <div style="border-top: 2.5px dashed #000; margin: 4px 0;"></div>
        <br>

        <p><b>[PL] Polski</b></p>
        <p>Cześć ${firstName}👋,</p>
        <p>dziękujemy za Twoje zaangażowanie i cenny wkład w nasz <span style="${blueStyle}">proces Kaizando</span>. Każdy pomysł pomaga nam w ciągłym doskonaleniu naszych procesów w tej lokalizacji.</p>
        <p>Twoje obecne saldo punktów premium wynosi <b>${points} punktów.</b></p>
        <p>Zebrane punkty możesz w każdej chwili wymienić na upominki z naszego sklepu kreatywnego. Odbiór odbywa się w każdy piątek w godzinach <b>12:45-13:45</b> w biurze Simone.</p>
        <p>Czekamy na Twoje kolejne pomysly. (<a href="${yourLink}">Link do formularza</a>)</p>

        <br>
        <div style="border-top: 2.5px dashed #000; margin: 4px 0;"></div>
        <br>

        <p><b>[EN] English</b></p>
        <p>Hello ${firstName}👋,</p>
        <p>thank you for your commitment and your valuable contributions to our <span style="${blueStyle}">Kaizando process</span>. Every idea helps us to continuously improve our processes at the site.</p>
        <p>Your current reward balance is <b>${points} points.</b></p>
        <p>You can redeem your collected points for goodies from our creative shop at any time. The pick-up takes place every Friday between <b>12:45 and 13:45</b> in Simone's office.</p>
        <p>We look forward to your next ideas. (<a href="${yourLink}">link to the form</a>)</p>

        <br>
        <div style="border-top: 2.5px dashed #000; margin: 4px 0;"></div>
        <br>
        <br>
        <br>
        Liebe Grüße,<br>LUU team
      `;

      // 7. SEND EMAIL
      try {
        GmailApp.sendEmail(emailAddress, subject, "Your email client does not support HTML.", { 
          htmlBody: emailBody, 
          noReply: true
        });
        
        Logger.log("HTML Email sent to: " + emailAddress);
      
      } catch (e) {
        Logger.log("Error sending email to: " + emailAddress + ". Error: " + e);
      }
    } else if (emailAddress && emailAddress.trim() !== "") {
      Logger.log("Skipped: " + emailAddress + " (Points: " + points + ")");
    }
  }
}
