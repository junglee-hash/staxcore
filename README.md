# Transaction Table Rebuild & Table Partitioning Project

This repository contains two related MySQL modernization efforts:

1. **Transaction Table Rebuild Project** — Reconstructs and migrates the legacy `transactions` table into a new, fully optimized, utf8mb3‑compliant structure.
2. **Table Partitioning Project** — Applies long‑term partitioning strategies to large transactional datasets to improve maintainability, query performance, and archival operations.

Both projects are designed and executed using **JetBrains DataGrip**, leveraging organized SQL scripts, environment‑safe execution, and repeatable deployment workflows.

---

## 📌 Repository Contents

### **Transaction Table Rebuild**
- Normalize schema and improve datatype accuracy  
- Migrate from legacy charset → **utf8mb4 / utf8mb4_0900_ai_ci**  
- Rebuild indexes for modern access patterns  
- Ensure primary key + secondary indexes align with MySQL 8+ best practices  
- Enable safe cut‑over via atomic rename operations  
- Improve query performance and reliability

### **Partitioning Project**
- Design sustainable RANGE / RANGE COLUMNS partitioning for time‑based data  
- Improve partition pruning for date‑range queries (MySQL supports indexes on partitions but requires the partition key for pruning effectiveness)  
- Enable drop/roll partitions for data lifecycle management  
- Support MySQL 8 partitioning rules (e.g., **primary key must include all partition columns**)  
- Divide large datasets into manageable logical segments

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
