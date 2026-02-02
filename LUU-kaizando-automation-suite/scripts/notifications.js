/**
 * MODULE: Notification Engine
 * PURPOSE: Monitors the sheet for new entries and sends "Rich Card" notifications to Google Chat via Webhook.
 */

function sendTranslatedNotification() {
  // 1. CONFIGURATION
  // Note: In a production environment, keep secrets like Webhook URLs in Script Properties.
  var webhookUrl = "https://chat.googleapis.com/v1/spaces/AAQAsrFtQ9g/messages?key=AIzaSyDdI0hCZtE6vySjMm-WEfRq3CPzqKqqsHI&token=DzTeAWNh1aWaEwPwtJ86Z6ZQvEp7R3TdZZ5xALQCe5I";
  
  var ss = SpreadsheetApp.getActiveSpreadsheet();
  var sheet = ss.getSheetByName("Translated_Master_Response_sheet");
  
  var spreadsheetId = ss.getId();
  var sheetId = sheet.getSheetId(); 
  
  var lastRow = sheet.getLastRow();
  if (lastRow < 3) return; 
  
  var startRow = 3;
  // Get all data up to column 25 (Column Y) where the Status is stored
  var range = sheet.getRange(startRow, 1, lastRow - startRow + 1, 25); 
  var data = range.getValues();

  // 2. LOOP THROUGH ROWS
  for (var i = 0; i < data.length; i++) {
    var rowData = data[i];
    var currentRowNumber = i + startRow;

    // Extract Column Data (Indices are 0-based)
    var senderName = rowData[2];  
    var department = rowData[4];  
    var problem    = rowData[5];  
    var solution   = rowData[6];  
    var rawID      = rowData[9];  
    var status     = rowData[24]; // Column Y

    var ticketNum = parseInt(rawID);
    
    // 3. CHECK CONDITIONS: Valid ID, Status is empty, Numeric ID > 65
    if (ticketNum >= 65 && status === "" && !isNaN(ticketNum)) {

      var formattedID = "LUU-" + ("000" + ticketNum).slice(-3);
      var date = Utilities.formatDate(new Date(), Session.getScriptTimeZone(), "dd/MM/yyyy");
      var rowUrl = "https://docs.google.com/spreadsheets/d/" + spreadsheetId + "/edit#gid=" + sheetId + "&range=J" + currentRowNumber;

      // --- 4. CREATE THE CARD PAYLOAD (Google Chat Card V2) ---
      var payload = {
        "cardsV2": [{
          "cardId": "unique-card-id-" + ticketNum,
          "card": {
            "header": {
              "title": "Neue Kaizando Idee 💡",
              "subtitle": "🗓️ " + date + " | Task Nr: " + formattedID
            },
            "sections": [
              {
                "widgets": [
                  {
                    "decoratedText": {
                      "topLabel": "Von",
                      "text": "<b>" + senderName + "</b> (" + department + ")",
                      "startIcon": {
                        "knownIcon": "PERSON"
                      }
                    }
                  },
                  { "divider": {} }, 
                  {
                    "textParagraph": {
                      "text": "<b>Problem:</b><br>" + problem
                    }
                  },
                  {
                    "textParagraph": {
                      "text": "<b>Vorgeschlagene Lösung:</b><br>" + solution
                    }
                  },
                  { "divider": {} },
                  {
                    "buttonList": {
                      "buttons": [
                        {
                          "text": "🔗 Öffnen " + formattedID,
                          "onClick": {
                            "openLink": {
                              "url": rowUrl
                            }
                          }
                        }
                      ]
                    }
                  }
                ]
              }
            ]
          }
        }]
      };

      var options = {
        "method": "post",
        "contentType": "application/json",
        "payload": JSON.stringify(payload)
      };

      try {
        // Send to Google Chat
        UrlFetchApp.fetch(webhookUrl, options);
        
        // Mark as Sent in the spreadsheet to prevent duplicate notifications
        sheet.getRange(currentRowNumber, 25).setValue("Sent");
        console.log("✅ Message sent for " + formattedID);
        Utilities.sleep(500); 

      } catch(error) {
        console.log("❌ Error sending chat for " + formattedID + ": " + error);
      }
    }
  }
}