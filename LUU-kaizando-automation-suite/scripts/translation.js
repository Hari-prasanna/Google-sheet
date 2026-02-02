/**
 * MODULE: Translation Middleware
 * PURPOSE: Translates 'Problem' and 'Solution' columns from Source (EN/PL) to Target (DE).
 * TRIGGER: Runs on form submission or time-based trigger.
 */

function translateOverviewColumns() {
  // 1. WAIT FOR FORMULAS TO PULL DATA
  Utilities.sleep(2000);

  var sheet = SpreadsheetApp.getActiveSpreadsheet().getSheetByName('Help');
  var lastRow = sheet.getLastRow();

  if (lastRow < 2) return;

  var range = sheet.getRange(2, 6, lastRow - 1, 4);
  var data = range.getValues();
  
  var updates = [];
  var hasUpdates = false;

  for (var i = 0; i < data.length; i++) {
    var sourceProb = data[i][0]; // Col F (Original Problem)
    var sourceSol  = data[i][1]; // Col G (Original Solution)
    var targetProb = data[i][2]; // Col H (Translated Problem)
    var targetSol  = data[i][3]; // Col I (Translated Solution)

    // Check if target is empty but source exists
    if (targetProb === "" && sourceProb !== "") {
      var transProb = "";
      var transSol = "";

      try {
        // 2. CALL GOOGLE TRANSLATE API
        if (sourceProb !== "") transProb = LanguageApp.translate(sourceProb, "", "de");
        if (sourceSol !== "")  transSol = LanguageApp.translate(sourceSol, "", "de");
        
        updates.push([transProb, transSol]);
        hasUpdates = true;
        
      } catch (e) {
        console.error("Row " + (i + 2) + " error: " + e);
        updates.push(["Error", "Error"]); 
      }
    } else {
      // Keep existing data if no translation needed
      updates.push([targetProb, targetSol]);
    }
  }

  // 3. WRITE TRANSLATIONS & TRIGGER CHAT
  if (hasUpdates) {
    // Write the translations back to the 'Help' sheet
    sheet.getRange(2, 8, updates.length, 2).setValues(updates);
    console.log("Translation complete. Updated " + updates.length + " rows.");
    
    // A. FLUSH: Force the sheet to update. 
    // This ensures 'Translated_Master_Response_sheet' sees the new data in 'Help'
    SpreadsheetApp.flush(); 
    
    // B. SLEEP: Give VLOOKUP formulas time to propagate
    Utilities.sleep(1000);

    // C. SEND THE CHAT NOTIFICATION
    // Calls the function defined in notifications.js
    sendTranslatedNotification();
  }
}