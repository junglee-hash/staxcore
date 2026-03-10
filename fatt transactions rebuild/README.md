# Transaction Table Rebuild Project

Reconstructs and migrates the legacy `transactions` table into a new, fully optimized, utf8mb3‑compliant structure.
The project is designed and executed using **JetBrains DataGrip**, leveraging organized SQL scripts, environment‑safe execution, and repeatable deployment workflows.

---

## 📌 Repository Contents

### **Transaction Table Rebuild**
- Normalize schema and improve datatype accuracy  
- Rebuild indexes for modern access patterns  
- Ensure primary key + secondary indexes align with MySQL 8+ best practices  
- Enable safe cut‑over via atomic rename operations  
- Improve query performance and reliability
---

## 💼 Prerequisites

- **MySQL 8.0+**
- **DataGrip (2023+)**
- Permissions allowing:
  - Table creation & DDL changes  
  - Altering indexes  
  - Temporary buffers (sort/tmp) allocation  
- Parameter group adjustments for larger migrations (recommended):

- ## 🚀 Project Setup

### 1. Clone the Repository
```bash
git clone https://github.com/<org>/<repo>.git
cd <repo>
