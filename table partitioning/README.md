# Table Partitioning Project

Applies long‑term partitioning strategies to large transactional datasets to improve maintainability, query performance, and archival operations.

The project is designed and executed using **JetBrains DataGrip**, leveraging organized SQL scripts, environment‑safe execution, and repeatable deployment workflows.

---

## 📌 Repository Contents

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
