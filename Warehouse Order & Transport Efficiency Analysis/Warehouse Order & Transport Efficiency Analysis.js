/**
 * @fileoverview
 * Google Apps Script for a 4-step data extraction pipeline.
 * All functions are combined into a single file for documentation.
 * @OnlyCurrentDoc
 */

// ===================================================================
// == 1. MAIN FUNCTIONS & MENU (Original Code.gs)
// ===================================================================

/**
 * Adds a custom menu to the spreadsheet UI when the file is opened.
 */
function onOpen() {
  var ui = SpreadsheetApp.getUi();
  var menu = ui.createMenu('Extract');
  menu.addItem('Step 1-4', 'runAllScripts');
  menu.addSeparator();
  menu.addItem('Step 1: Prepare Data', 'runStep1_PrepareData');
  menu.addItem('Step 2: Run Analysis', 'runStep2_RunAnalysis');
  menu.addItem('Step 3: Archive Results', 'runStep3_ArchiveResults');
  menu.addItem('Step 4: Clean Up', 'runStep4_Cleanup');
  menu.addToUi();
}

/**
 * Runs all four steps of the data pipeline in sequence.
 */
function runAllScripts() {
  runStep1_PrepareData();
  SpreadsheetApp.flush(); // Apply pending changes
  
  runStep2_RunAnalysis();
  SpreadsheetApp.flush();
  
  runStep3_ArchiveResults();
  SpreadsheetApp.flush();
  
  runStep4_Cleanup();
  SpreadsheetApp.flush();
}

// ===================================================================
// == 2. SCRIPT CONFIGURATION (Original Config.gs)
// ===================================================================

/**
 * Central configuration object for all sheet names used in the project.
 * This makes the script maintainable. If a sheet name changes,
 * you only need to update it in this one file.
 */
const CONFIG = {
  SHEET_NAMES: {
    // --- Source Sheets (Data is imported into these) ---
    TRANSPORT_STATISTIK: 'Transport Statistik',
    AENDERUNGEN_AUFTRAGSSTATUS: 'Änderungen des Auftragsstatus',
    AUFTRAGSMONITOR_AP: 'AuftragsmonitorAp',

    // --- Staging/Processing Sheets ---
    TS: 'TS',
    PAL: 'PAL',
    AF: 'AF',
    STEP_2_FORMULAS: 'Step2Formulas',

    // --- Destination/Report Sheets ---
    UEBERSICHT: 'Übersicht',
    UEBERSICHT_JAHR: 'Übersicht Jahr'
  }
};

// ===================================================================
// == 3. STEP 1: PREPARE DATA (Original Mac1)
// ===================================================================

/**
 * STEP 1: Gathers and pre-processes data from source sheets
 * into the 'TS', 'PAL', and 'AF' staging sheets.
 * (Formerly Mac1)
 */
function runStep1_PrepareData() {
  const spreadsheet = SpreadsheetApp.getActive();
  const SHEETS = CONFIG.SHEET_NAMES; // Get sheet names from config

  // --- TS Sheet Setup ---
  const sheet1 = spreadsheet.getSheetByName(SHEETS.TS);
  sheet1.getRange('A1').setFormula(`=QUERY('${SHEETS.TRANSPORT_STATISTIK}'!A1:G, "SELECT A, G WHERE B LIKE 'Versand%' AND C = 'Transportrequest erledigt' AND F LIKE 'PALAP%' ORDER BY G")`);
  sheet1.getRange('F1').setFormula(`=QUERY('${SHEETS.TRANSPORT_STATISTIK}'!A1:G, "SELECT A, G WHERE B LIKE 'Versand%' AND C = 'Transportrequest erstellt' ORDER BY G")`);
  sheet1.getRange('C2').setFormula('=ARRAYFORMULA(IF(B2:B="",,TIMEVALUE(RIGHT(B2:B,8))))');
  sheet1.getRange('C:C').setNumberFormat('HH:mm:ss');
  sheet1.getRange('H2').setFormula('=ARRAYFORMULA(IF(F2:F="",,TIMEVALUE(RIGHT(G2:G,8))))');
  sheet1.getRange('H:H').setNumberFormat('HH:mm:ss');

  // --- PAL Sheet Setup ---
  const palSheet = spreadsheet.getSheetByName(SHEETS.PAL);
  palSheet.getRange('A1').setFormula(`=QUERY('${SHEETS.AENDERUNGEN_AUFTRAGSSTATUS}'!A1:F, "SELECT F, A, D WHERE B = 'Finalisierung gestartet' AND C = 'OUTLET'")`);
  palSheet.getRange('D2').setFormula(`=ARRAYFORMULA(IF(B2:B="",,XLOOKUP(B2:B&"Finalisierung gestartet",ARRAYFORMULA('${SHEETS.AENDERUNGEN_AUFTRAGSSTATUS}'!A2:A&'${SHEETS.AENDERUNGEN_AUFTRAGSSTATUS}'!B2:B),'${SHEETS.AENDERUNGEN_AUFTRAGSSTATUS}'!E2:E,,)))`);
  palSheet.getRange('D1').setValue('colli anzhal');

  // --- AF Sheet Setup ---
  const afSheet = spreadsheet.getSheetByName(SHEETS.AF);
  afSheet.getRange('A1').setFormula(`=QUERY('${SHEETS.AUFTRAGSMONITOR_AP}'!A1:Y, "SELECT A, C, F, X WHERE S = 'OUTLET' AND C LIKE '4%' AND B <> 'Deleted' ORDER BY G DESC")`);
  afSheet.getRange('G2').setFormula(`=Arrayformula(if(A2:A="",,XLOOKUP(A2:A,${SHEETS.PAL}!B2:B,${SHEETS.PAL}!D2:D,,)))`);
  afSheet.getRange('H2').setFormula(`=Arrayformula(if(A2:A="",,XLOOKUP(B2:B,${SHEETS.TS}!F2:F,${SHEETS.TS}!H2:H,,)))`);
  afSheet.getRange('I2').setFormula(`=Arrayformula(if(A2:A="",,XLOOKUP(B2:B,${SHEETS.TS}!A2:A,${SHEETS.TS}!C2:C,,)))`);
  afSheet.getRange('J2').setFormula('=ARRAYFORMULA(if(H2:H="",,TIMEVALUE(H2:H)))');
  afSheet.getRange('H2:H').setNumberFormat('HH:mm:ss');
  afSheet.getRange('I2:I').setNumberFormat('HH:mm:ss');
  afSheet.getRange('E2').setFormula('=ARRAYFORMULA(IF(A2:A="",,(DATE(MID(C2:C,7,4),MID(C2:C,4,2),LEFT(C2:C,2)))))');
  afSheet.getRange('E:E').setNumberFormat('dd/MM/yyyy');
  afSheet.getRange('F2').setFormula('=ARRAYFORMULA(IF(A2:A="",,WEEKNUM(E2:E)))');
  afSheet.getRange('E1').setValue('date');
  afSheet.getRange('F1').setValue('week');
  afSheet.getRange('G1').setValue('Colli');
  afSheet.getRange('H1').setValue('Freigegeben');
  afSheet.getRange('I1').setValue('Ended');
  afSheet.getRange('J1').setValue('sort');
}

// ===================================================================
// == 4. STEP 2: RUN ANALYSIS (Original Mac2)
// ===================================================================

/**
 * STEP 2: Runs complex analysis formulas on the 'Step2Formulas' sheet.
 * (Formerly Mac2)
 */
function runStep2_RunAnalysis() {
  const spreadsheet = SpreadsheetApp.getActive();
  const SHEETS = CONFIG.SHEET_NAMES;
  const sheet = spreadsheet.getSheetByName(SHEETS.STEP_2_FORMULAS);
  
  // Note: Formulas referencing other sheets must be constructed with sheet names
  const TRANSPORT_STATISTIK_NAME = `'${SHEETS.TRANSPORT_STATISTIK}'`;
  const AF_NAME = SHEETS.AF;
  const PAL_NAME = SHEETS.PAL;

  sheet.getRange('A3').setFormula(`=UNIQUE(QUERY(${AF_NAME}!A2:J, "SELECT F,E,A,D WHERE G > 16 ORDER BY E,J"))`);
  SpreadsheetApp.flush();
  
  sheet.getRange('F3').setFormula(`=IF($C$3:$C="",,MAXIFS(${AF_NAME}!$I$2:$I, ${AF_NAME}!$A$2:$A, C3:C))`);
  sheet.getRange('F:F').setNumberFormat('HH:mm:ss');
  sheet.getRange('F3').autoFill(sheet.getRange('F3:F100'), SpreadsheetApp.AutoFillSeries.DEFAULTSERIES);
  
  sheet.getRange('E3').setFormula(`=IF($C$3:$C="",,MAXIFS(${AF_NAME}!$H$2:$H, ${AF_NAME}!$A$2:$A, C3:C))`);
  sheet.getRange('E:E').setNumberFormat('HH:mm:ss');
  sheet.getRange('E3').autoFill(sheet.getRange('E3:E100'), SpreadsheetApp.AutoFillSeries.DEFAULT_SERIES);

  // --- Complex COUNTUNIQUEIFS formulas ---
  sheet.getRange('S3').setFormula(`=IF(B3:B="",,COUNTUNIQUEIFS(${TRANSPORT_STATISTIK_NAME}!$A$2:$A, ${TRANSPORT_STATISTIK_NAME}!$I$2:$I, ">" & E3, ${TRANSPORT_STATISTIK_NAME}!$I$2:$I, "<" & F3,${TRANSPORT_STATISTIK_NAME}!$E$2:$E,"AKL_G",'${TRANSPORT_STATISTIK_NAME}'!$B$2:$B,"Outletbehälter",${TRANSPORT_STATISTIK_NAME}!$C$2:$C,"Transportrequest gestartet",${TRANSPORT_STATISTIK_NAME}!$F$2:$F,"ZU",${TRANSPORT_STATISTIK_NAME}!$H$2:$H,B3))`);
  sheet.getRange('S3').autoFill(sheet.getRange('S3:S100'), SpreadsheetApp.AutoFillSeries.DEFAULTSERIES);
  
  sheet.getRange('T3').setFormula(`=IF(B3:B="",,COUNTUNIQUEIFS(${TRANSPORT_STATISTIK_NAME}!$A$2:$A, ${TRANSPORT_STATISTIK_NAME}!$I$2:$I, ">" & E3, ${TRANSPORT_STATISTIK_NAME}!$I$2:$I, "<" & F3,${TRANSPORT_STATISTIK_NAME}!$E$2:$E,"PALL",${TRANSPORT_STATISTIK_NAME}!$B$2:$B,"Outletbehälter",${TRANSPORT_STATISTIK_NAME}!$C$2:$C,"Transportrequest gestartet",${TRANSPORT_STATISTIK_NAME}!$F$2:$F,"VD",${TRANSPORT_STATISTIK_NAME}!$H$2:$H,B3))`);
  sheet.getRange('T3').autoFill(sheet.getRange('T3:T100'), SpreadsheetApp.AutoFillSeries.DEFAULT_SERIES);
  
  sheet.getRange('U3').setFormula(`=IF(B3:B="",,COUNTUNIQUEIFS(${TRANSPORT_STATISTIK_NAME}!$A$2:$A, ${TRANSPORT_STATISTIK_NAME}!$I$2:$I, ">" & E3, ${TRANSPORT_STATISTIK_NAME}!$I$2:$I, "<" & F3,${TRANSPORT_STATISTIK_NAME}!$B$2:$B,"Outletbehälter",${TRANSPORT_STATISTIK_NAME}!$C$2:$C,"Transportrequest gestartet",${TRANSPORT_STATISTIK_NAME}!$E$2:$E,"AKL",${TRANSPORT_STATISTIK_NAME}!$F$2:$F,"PALLPZU",${TRANSPORT_STATISTIK_NAME}!$H$2:$H,B3))`);
  sheet.getRange('U3').autoFill(sheet.getRange('U3:U100'), SpreadsheetApp.AutoFillSeries.DEFAULTSERIES);
  
  sheet.getRange('V3').setFormula(`=IF(B3:B="",,COUNTUNIQUEIFS(${TRANSPORT_STATISTIK_NAME}!$A$2:$A, ${TRANSPORT_STATISTIK_NAME}!$I$2:$I, ">" & E3, ${TRANSPORT_STATISTIK_NAME}!$I$2:$I, "<" & F3,${TRANSPORT_STATISTIK_NAME}!$B$2:$B,"Outletbehälter",${TRANSPORT_STATISTIK_NAME}!$C$2:$C,"Transportrequest gestartet",${TRANSPORT_STATISTIK_NAME}!$E$2:$E,"AKL G",${TRANSPORT_STATISTIK_NAME}!$F$2:$F,"OL",${TRANSPORT_STATISTIK_NAME}!$H$2:$H,B3))`);
  sheet.getRange('V3').autoFill(sheet.getRange('V3:V100'), SpreadsheetApp.AutoFillSeries.DEFAULT_SERIES);
  
  sheet.getRange('W3').setFormula(`=IF(B3:B="",,COUNTUNIQUEIFS(${TRANSPORT_STATISTIK_NAME}!$A$2:$A, ${TRANSPORT_STATISTIK_NAME}!$I$2:$I, ">" & E3, ${TRANSPORT_STATISTIK_NAME}!$I$2:$I, "<" & F3,${TRANSPORT_STATISTIK_NAME}!$B$2:$B,"Outletbehälter",${TRANSPORT_STATISTIK_NAME}!$C$2:$C,"Transportrequest gestartet",${TRANSPORT_STATISTIK_NAME}!$E$2:$E,"GS",${TRANSPORT_STATISTIK_NAME}!$F$2:$F,"AKL",${TRANSPORT_STATISTIK_NAME}!$H$2:$H,B3))`);
  sheet.getRange('W3').autoFill(sheet.getRange('W3:W100'), SpreadsheetApp.AutoFillSeries.DEFAULTSERIES);
  
  sheet.getRange('X3').setFormula(`=If(B3:B="",,COUNTUNIQUEIFS(${TRANSPORT_STATISTIK_NAME}!$A$2:$A, ${TRANSPORT_STATISTIK_NAME}!$I$2:$I, ">" & E3,${TRANSPORT_STATISTIK_NAME}!$I$2:$I, "<" & F3,${TRANSPORT_STATISTIK_NAME}!$B$2:$B,"Outletbehälter",${TRANSPORT_STATISTIK_NAME}!$C$2:$C,"Transportrequest gestartet",${TRANSPORT_STATISTIK_NAME}!$F$2:$F,"AKL",${TRANSPORT_STATISTIK_NAME}!$H$2:$H,B3))`);
  sheet.getRange('X3').autoFill(sheet.getRange('X3:X100'), SpreadsheetApp.AutoFillSeries.DEFAULTSERIES);
  
  sheet.getRange('Y3').setFormula(`=IF(B3:B="",,COUNTUNIQUEIFS(${TRANSPORT_STATISTIK_NAME}!$A$2:$A, ${TRANSPORT_STATISTIK_NAME}!$I$2:$I, ">=" & E3, ${TRANSPORT_STATISTIK_NAME}!$I$2:$I, "<=" & F3,${TRANSPORT_STATISTIK_NAME}!$E$2:$E,"AKL G",${TRANSPORT_STATISTIK_NAME}!$B$2:$B,"Outletbehälter",${TRANSPORT_STATISTIK_NAME}!$C$2:$C,"Transportrequest gestartet",${TRANSPORT_STATISTIK_NAME}!$H$2:$H,B3))`);
  sheet.getRange('Y3').autoFill(sheet.getRange('Y3:Y100'), SpreadsheetApp.AutoFillSeries.DEFAULTSERIES);
  
  sheet.getRange('Z3').setFormula(`=IF(B3:B="",,COUNTUNIQUEIFS(${TRANSPORT_STATISTIK_NAME}!$A$2:$A, ${TRANSPORT_STATISTIK_NAME}!$I$2:$I, ">=" & E3, ${TRANSPORT_STATISTIK_NAME}!$I$2:$I, "<=" & F3,${TRANSPORT_STATISTIK_NAME}!$E$2:$E,"AKL",${TRANSPORT_STATISTIK_NAME}!$B$2:$B,"Versandkarton",${TRANSPORT_STATISTIK_NAME}!$C$2:$C,"Transportrequest gestartet",${TRANSPORT_STATISTIK_NAME}!$H$2:$H,B3))`);
  sheet.getRange('Z3').autoFill(sheet.getRange('Z3:Z100'), SpreadsheetApp.AutoFillSeries.DEFAULTSERIES);
  
  sheet.getRange('AA3').setFormula(`=IF(B3:B="",,COUNTUNIQUEIFS(${TRANSPORT_STATISTIK_NAME}!$A$2:$A, ${TRANSPORT_STATISTIK_NAME}!$I$2:$I, ">=" & E3, ${TRANSPORT_STATISTIK_NAME}!$I$2:$I, "<=" & F3,${TRANSPORT_STATISTIK_NAME}!$E$2:$E,"AKL G",${TRANSPORT_STATISTIK_NAME}!$C$2:$C,"Transportrequest gestartet",${TRANSPORT_STATISTIK_NAME}!$H$2:$H,B3))`);
  sheet.getRange('AA3').autoFill(sheet.getRange('AA3:AA100'), SpreadsheetApp.AutoFillSeries.DEFAULTSERIES);

  // --- Final Calculation Columns ---
  sheet.getRange('G3').setFormula('=ARRAYFORMULA(IF(C3:C="",,F3:F-E3:E))');
  sheet.getRange('G:G').setNumberFormat('HH:mm:ss');
  
  sheet.getRange('H3').setFormula(`=ARRAYFORMULA(IF(C3:C="",,XLOOKUP(C3:C,${AF_NAME}!A2:A,${AF_NAME}!G2:G,,)))`);
  sheet.getRange('I3').setFormula('=ARRAYFORMULA(IF(C3:C="",,G3:G/H3:H))');
  sheet.getRange('I:I').setNumberFormat('HH:mm:ss');
  
  sheet.getRange('J3').setFormula('=ARRAYFORMULA(IF(C3:C="",,H3:H/(HOUR(G3:G) * 60 + MINUTE(G3:G) + SECOND(G3:G) / 60)))');
  sheet.getRange('J:J').setNumberFormat('0.0');
  
  sheet.getRange('K3').setFormula(`=ARRAYFORMULA(IF(C3:C="",,XLOOKUP(C3:C,${PAL_NAME}!B2:B,${PAL_NAME}!C2:C,,)))`);
  sheet.getRange('L3').setFormula('=ARRAYFORMULA(IF(C3:C="",,G3:G/K3:K))');
  sheet.getRange('L:L').setNumberFormat('HH:mm:ss');
  
  sheet.getRange('R3').setFormula('=IF(C3:C="",,IF(AND(E3:E>=TIME(6,0,0),E3:E<=TIME(14,45,0)),1,2))');
  sheet.getRange('R3').autoFill(sheet.getRange('R3:R100'), SpreadsheetApp.AutoFillSeries.DEFAULT_SERIES);
}


// ===================================================================
// == 5. STEP 3: ARCHIVE RESULTS (Original Mac3)
// ===================================================================

/**
 * STEP 3: Copies unique results from the staging 'Step2Formulas'
 * sheet to the persistent 'Übersicht' (Overview) sheet.
 * (Formerly Mac3)
 */
function runStep3_ArchiveResults() {
  const spreadsheet = SpreadsheetApp.getActive();
  const SHEETS = CONFIG.SHEET_NAMES;
  
  const sourceSheet = spreadsheet.getSheetByName(SHEETS.STEP_2_FORMULAS);
  const targetSheet = spreadsheet.getSheetByName(SHEETS.UEBERSICHT);

  const sourceData = sourceSheet.getDataRange().getValues();
  const targetData = [];

  // Get existing keys from the target sheet to prevent duplicates
  const existingValues = targetSheet.getRange('C:C').getValues().flat().filter(String);
  const uniqueValuesSet = new Set(existingValues);

  // Start from row 1 (index 0) to check headers, or 2 to skip headers
  // Your original script checks all sourceData, so we start at i = 0
  for (var i = 0; i < sourceData.length; i++) {
    var cValue = sourceData[i][2]; // Column C is the key
    
    // Check if row is not empty and the key is not already in the target sheet
    if (sourceData[i].join('').length > 0 && !uniqueValuesSet.has(cValue)) {
      targetData.push(sourceData[i]);
      uniqueValuesSet.add(cValue); // Add new key to set to prevent duplicates within this run
    }
  }

  // If there is new data to add, append it to the target sheet
  if (targetData.length > 0) {
    const targetRange = targetSheet.getRange(targetSheet.getLastRow() + 1, 1, targetData.length, targetData[0].length);
    targetRange.setValues(targetData);
  }

  // Apply number formatting to the target sheet
  targetSheet.getRange('G:G').setNumberFormat('HH:mm:ss');
  targetSheet.getRange('I:I').setNumberFormat('HH:mm:ss');
  targetSheet.getRange('J:J').setNumberFormat('0.0');
  targetSheet.getRange('L:L').setNumberFormat('HH:mm:ss');
}

// ===================================================================
// == 6. STEP 4: CLEAN UP (Original Mac4)
// ===================================================================

/**
 * STEP 4: Clears all staging and source data sheets to prepare for
 * the next data import.
 * (Formerly Mac4)
 */
function runStep4_Cleanup() {
  const spreadsheet = SpreadsheetApp.getActive();
  const SHEETS = CONFIG.SHEET_NAMES;

  // Clear all content from staging sheets
  spreadsheet.getSheetByName(SHEETS.TS).clearContents();
  spreadsheet.getSheetByName(SHEETS.AF).clearContents();
  spreadsheet.getSheetByName(SHEETS.PAL).clearContents();
  spreadsheet.getSheetByName(SHEETS.STEP_2_FORMULAS).clearContents();
  
  // Clear content from source data sheets
  spreadsheet.getSheetByName(SHEETS.AENDERUNGEN_AUFTRAGSSTATUS).clearContents();
  spreadsheet.getSheetByName(SHEETS.AUFTRAGSMONITOR_AP).clearContents();
  spreadsheet.getSheetByName(SHEETS.TRANSPORT_STATISTIK).getRange("A:G").clearContent();

  // Set the active sheet to the yearly overview
  const finalSheet = spreadsheet.getSheetByName(SHEETS.UEBERSICHT_JAHR);
  spreadsheet.setActiveSheet(finalSheet);
}

