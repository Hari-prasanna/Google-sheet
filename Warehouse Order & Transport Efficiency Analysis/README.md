# Warehouse Order & Transport Efficiency Analysis

## Overview
Our palletization workstations were experiencing significant delays in completing orders. We needed to understand precisely how much time each order took and, more importantly, why there were delays.
The primary suspicion was that the automated storage machine was slow to retrieve the shipping cartons for an order. We believed the system was getting "clogged" by giving equal weight to less urgent tasks (such as routine stock movements) rather than prioritizing critical order cartons.

## Solution
- Collecting and analyzing the time-based data to give management a clear picture of the bottleneck.
- Data Collection: I queried our database (OLAP) to pull and merge data from three distinct sources: order release times, workstation scan times, and system-wide transport movements.
- Automated Report: I developed a "one-click" Google App Script to automate the entire analysis. This script:
Pulls the raw data from all three sources.
- Calculates key performance indicators (KPIs), such as the initial wait time (from order release to first carton scan) and the total processing time (from first scan to last scan).
- Crucially, for every order, the script also identified and counted all other "active transports" (non-order-related movements) happening at the same time.
- Analysis: The final report compiled this information into a single overview, allowing us to directly compare an order's wait time against the level of "system congestion" at that exact moment.

## Impact
The report provided a clear, data-driven insight: Whenever the number of "active transports" in the warehouse was high, order durations increased significantly.
This analysis proved that the root cause of the delay was a lack of prioritization. Armed with this evidence, management implemented a new prioritization logic in the warehouse control system. This change ensured that retrieving an order's shipping cartons was always treated as a high-priority task, resulting in measurable improvements in order processing speed and workstation efficiency.
