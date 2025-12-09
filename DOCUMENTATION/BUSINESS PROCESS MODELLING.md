Phase II: Business Process Modeling Document
Project: Microloan Management System for Small Businesses
I. Business Process Modeling (BPMN) Diagram
Objective: To visually outline the steps, actors, and system interactions involved in the Microloan Origination and Repayment process.
Actors/Swimlanes: The process involves three primary actors: the Client, the Microfinance Officer (MFO), and the Microloan System.
________________________________________
II. Business Process Documentation (One-Page Explanation)
A. Scope Definition and Objectives
The business process modeled is the end-to-end Microloan Origination and Repayment Cycle. This process is highly relevant to MIS (Management Information Systems) as it involves data-driven decisions (credit assessment), financial transaction tracking, and automated rule enforcement.
Key Objectives and Outcomes:
1.	Streamline Loan Administration: Automate record-keeping for disbursements and repayments.
2.	Enforce Lending Rules: Implement business logic (e.g., penalty calculation) at the database level using PL/SQL.
3.	Ensure Data Accuracy: Log all transactions to maintain transparency and accountability.
B. Roles, Responsibilities, and Flow
Actor/System	Role and Responsibility Allocation 
Client	Initiates the process by submitting the loan application and fulfills the responsibility of making scheduled repayments.
Microfinance Officer (MFO)	Conducts the credit assessment, makes the approval/denial decision, records the disbursement, and receives physical payments.
Microloan System	Manages data (registers Client/Loan), automatically computes and applies penalties, and updates outstanding balances (System boundary/Handoff point).
Logical Flow Summary:
1.	Origination: The Client applies. The MFO registers the Client, performs the Credit Assessment (Activity), and reaches the Decision Point (Loan Approved? - Gateway).
2.	Disbursement: If approved, the MFO records the Loan in the Microloan System (Handoff).
3.	Repayment & Penalty: The Client makes a payment. The System processes the transaction, reaches the Decision Point (Payment Late? - Gateway), and, if late, automatically calculates and applies the penalty before finalizing the transaction.
C. MIS Functions and Organizational Impact
MIS Functions Explained:
The system provides core MIS functions by replacing informal, manual tracking with structured database operations:
•	Client Management: Storing and retrieving client registration details (CLIENTS table).
•	Transaction Processing: Recording every disbursement (LOANS table) and payment (PAYMENTS table).
•	Automated Calculation & Enforcement: Using PL/SQL (procedures/triggers) for automatic penalty computation when a late payment is logged.
Organizational Impact Justification:
The implementation of this system will significantly enhance the organization's capacity for effective credit management. By automating penalty computation, it removes dependency on manual tracking , ensures consistent enforcement of lending rules, and reduces administrative risk, leading to better accountability and financial discipline.
D. Analytics Opportunities Identified
The structured data model enables several key opportunities for Business Intelligence:
•	Portfolio Health: Track total loan portfolio value, outstanding balances, and repayment rates (KPI: Repayment Success Rate).
•	Risk Segmentation: Analyze the correlation between BUSINESS_TYPE and penalty accrual to identify high-risk sectors (KPI: Default Rate by Segment).
•	Operational Efficiency: Measure the total accumulated penalties and collection performance (KPI: Penalty Collection Rate).
