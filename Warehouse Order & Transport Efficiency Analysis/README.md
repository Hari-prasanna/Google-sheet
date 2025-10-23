**Warehouse Congestion & Order Delay Analysis**

This repository contains a Google Apps Script project designed to analyze and identify bottlenecks in a warehouse palletization workstation.

It automatically pulls data from multiple sources, calculates order processing times, and correlates them with overall system congestion (i.e., other active transports) to provide clear, data-driven insights for management.

The Challenge 🎯

Our palletization workstations were experiencing significant delays in completing orders. We needed to understand exactly how much time each order took and, more importantly, why there were delays.

The primary suspicion was that the automated storage machine (AKL) was slow to retrieve an order's shipping cartons. We believed the system was getting "clogged" by giving equal importance to less urgent tasks (like routine stock movements) instead of prioritizing critical order cartons.

The Solution 🛠️

I built this "one-click" Google App Script to automate the entire analysis and provide management with a clear picture of the bottleneck.

Automated Data Collection: The script pulls and merges raw data from three distinct sources: order release times (AuftragsmonitorAp), workstation scan times (Änderungen des Auftragsstatus), and system-wide transport movements (Transport Statistik).

KPI Calculation: It automatically calculates key performance indicators (KPIs) for each order, such as:

Initial Wait Time: From order release (Freigegeben) to the first carton scan.

Total Processing Time: From the first scan to the final scan (Ended).

Congestion Analysis: Crucially, for every order's time window, the script also identifies and counts all other "active transports" (non-order-related movements) happening at the same time. This acts as a "system congestion" score.

Final Report: The script compiles this information into a single overview (Übersicht sheet), allowing us to directly compare an order's wait time against the level of system congestion at that exact moment.

The Impact ✨

The report provided a clear, data-driven insight: Whenever the number of "active transports" in the warehouse was high, order durations increased significantly.

This analysis proved that the root cause of the delay was a lack of prioritization in the warehouse control system. Armed with this evidence, management was able to implement a new prioritization logic. This change ensured that retrieving an order's shipping cartons was always treated as a high-priority task, leading to a measurable improvement in order processing speed and workstation efficiency.

Technical Breakdown

The script is organized into a 4-step pipeline, all accessible from the "Extract" menu in the Google Sheet.

Step 1: Prepare Data (runStep1_PrepareData)

Pulls data from the three source sheets using QUERY formulas.

Stages the pre-processed data in the TS, PAL, and AF sheets.

Calculates initial timestamps and week numbers.

Step 2: Run Analysis (runStep2_RunAnalysis)

This is the core of the analysis, performed in the Step2Formulas sheet.

It calculates the start (E3:E) and end (F3:F) times for each order.

It runs a series of complex COUNTUNIQUEIFS formulas (columns S to AA) to count all other "active transports" that occurred within each order's time window.

Step 3: Archive Results (runStep3_ArchiveResults)

Intelligently copies only new, unique order data from the Step2Formulas sheet to the persistent Übersicht (Overview) sheet.

This builds a historical log of performance over time.

Step 4: Clean Up (runStep4_Cleanup)

Clears all data from the source (Transport Statistik, etc.) and staging (AF, TS, PAL, etc.) sheets.

This prepares the spreadsheet for the next data import.

Setup & Sheet Requirements

This script is designed to run within a single Google Sheet. For the script to function, your spreadsheet must contain the following tabs with these exact names:

Source Sheets (Import data here)

Transport Statistik

Änderungen des Auftragsstatus

AuftragsmonitorAp

Staging Sheets (Script works here)

TS

PAL

AF

Step2Formulas

Destination Sheets (View results here)

Übersicht

Übersicht Jahr

(Note: These names can be changed in the CONFIG object at the top of the script.)
