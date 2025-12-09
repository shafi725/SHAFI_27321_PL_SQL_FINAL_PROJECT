This is a great idea for your GitHub repository! A concise and professional `README.md` is essential for summarizing your project's scope, technology, and key features.

Here is a brief, professional overview of your **Microloan Management System** capstone project:

---

# 🚀 Microloan Management System (MMS)

## Project Overview

This is an individual capstone project focused on the complete design, development, and implementation of a production-ready **Microloan Management System (MMS)** using the **Oracle Database** and **PL/SQL**.

The system addresses the challenge of managing short-term micro-credit by automating core financial processes, ensuring data integrity, and providing essential analytical capabilities for a microfinance institution.

## 🛠️ Technology Stack

| Component | Technology | Role in Project |
| :--- | :--- | :--- |
| **Database** | Oracle 19c (PDB Architecture) | Core data persistence and environment setup. |
| **Business Logic** | **PL/SQL** (Procedures, Functions, Triggers) | Enforces all lending rules and automates key processes. |
| **Data Modeling** | UML/BPMN, 3NF Logical Model | Defines business processes and structured data relationships. |
| **Intelligence** | SQL Queries, Analytical Functions | Used for generating KPIs and performance reports (Phase VIII). |

## ✨ Key Features and Innovation

The Microloan Management System is built around a powerful, database-enforced architecture, providing the following core functionalities:

1.  **Client and Loan Administration:** Management of client registration, loan disbursement, and repayment schedules (`CLIENTS`, `LOANS` tables).
2.  **Automated Penalty Enforcement (PL/SQL Trigger):** The system's central innovation. A **trigger** automatically checks if a payment is late (`PAYMENT_DATE > DUE_DATE`), calculates a penalty based on the outstanding balance, and instantly records it in the **`PENALTIES`** table, ensuring consistent and unbiased application of lending rules. 
3.  **Transactional Integrity:** Use of **PL/SQL Procedures** (e.g., `PRC_DISBURSE_LOAN`, `PRC_RECORD_PAYMENT`) and **Packages** (`MMS_LOAN_PKG`) to guarantee that all transactions are processed securely and atomicity is maintained.
4.  **Reporting Foundation:** The normalized schema provides the foundation for Business Intelligence (BI) reporting, enabling calculation of KPIs like repayment rates, default rates by business type, and total collected penalties.
MY BUSINESS PROCESS MODELLING
<img width="512" height="271" alt="BPM" src="https://github.com/user-attachments/assets/d55781ae-b2c0-45fc-8cbf-64aa83214e1b" />
