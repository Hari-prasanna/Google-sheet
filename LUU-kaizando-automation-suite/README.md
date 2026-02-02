# Kaizando: Automated Continuous Improvement System 🚀

![Google Apps Script](https://img.shields.io/badge/Tech-Google_Apps_Script-blue) ![Integration](https://img.shields.io/badge/Integration-Google_Chat_Webhook-green) ![Status](https://img.shields.io/badge/Impact-90%25_Efficiency_Gain-orange)

## 📖 Executive Summary
**Kaizando** (a portmanteau of *Kaizen* and *Zalando*) is an internal operational excellence tool designed to crowd-source process improvement ideas from frontline employees.

Previously, this process was manual, prone to delays, and suffered from language barriers across the diverse workforce (English, German, Polish). I engineered a **full-stack automation solution** using Google Ecosystem tools that automates data ingestion, translation, notification, and gamification.

---

## 🧐 The Challenge
The Quality Management team faced three specific bottlenecks:
1.  **Language Barrier:** Ideas submitted in Polish or English required manual translation for the German-speaking decision board.
2.  **Latency:** Managers had to manually check spreadsheets to find new entries, slowing down implementation.
3.  **Engagement:** Employees lacked visibility into their "Reward Points," leading to lower participation rates.

---

## ⚙️ Solution Architecture

I designed an automated pipeline using **Google Apps Script (GAS)** as the backend engine.

```mermaid
graph TD
    A["User Submits Idea (EN/DE/PL)"] -->|Google Form| B(Raw Data Sheet)
    B -->|Trigger| C{Apps Script Engine}
    C -->|Native Function| D[LanguageApp Service]
    D -->|Normalized Text| E[Translated Master Overview DE]
    C -->|JSON Payload| F[Google Chat Webhook]
    F -->|Rich Card| G[Management Channel]
    C -->|Scheduled Trigger| H[HTML Email Engine]
    H -->|Monthly Update| I[Employee Inbox]
