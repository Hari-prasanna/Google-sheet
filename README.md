## ⚡ Google Sheets & Automation Projects

### 1. [Kaizando: Automated Idea Management System](./LUU-kaizando-automation-suite)
* **The Challenge:** An internal "Kaizen" program struggled with language barriers (EN/PL/DE) and slow feedback loops. Managers manually translated entries and checked spreadsheets daily, causing delays.
* **The Solution:** Engineered a full-stack automation pipeline using **Google Apps Script**. The system acts as middleware to:
    * **Translate** inputs automatically to German.
    * **Notify** managers instantly via **Google Chat Webhooks** (JSON Rich Cards).
    * **Engage** employees via monthly HTML gamification emails.
* **Impact:** Reduced manual admin time by **90%**, enabled real-time decision-making, and increased employee participation through automated feedback.
* **Key Skills:** `Google Apps Script`, `REST Webhooks`, `JSON`, `HTML/CSS`, `Automation`.

### 2. [Warehouse Transport Efficiency Analysis](./Warehouse%20Order%20%26%20Transport%20Efficiency%20Analysis)
* **The Challenge:** Palletization workstations faced unexplained delays. Management suspected the automated storage system was "clogging" by prioritizing routine stock movements over urgent customer orders, but lacked data proof.
* **The Solution:** Developed a "one-click" **Google Apps Script** tool to query and merge OLAP data from three sources: Order Release Times, Workstation Scans, and System-Wide Transport Movements. The script calculated "congestion levels" specifically during active order windows.
* **Impact:** Proved a direct correlation between high background traffic and order delays. This led to a **WCS (Warehouse Control System) logic update** that prioritized order retrieval, significantly increasing workstation throughput.
* **Key Skills:** `Google Apps Script`, `OLAP Data Integration`, `Process Mining`, `Root Cause Analysis`.
