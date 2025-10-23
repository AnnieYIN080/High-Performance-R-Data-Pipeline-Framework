# R Data Workflow & Query Comparison: Arrow, Polars, DuckDB, Duckplyr  

This repository provides a comprehensive R script (`data_analysis_workflow.R`) demonstrating a robust data preparation, conversion, and comparative analysis workflow using modern, high‑performance R packages. The project illustrates how to efficiently process, query, and visualize large datasets through multiple analytical engines — all within R.

##  Core Objectives

### Workflow Demonstration
Illustrate an end‑to‑end data pipeline in R:  
**CSV I/O → Parquet Conversion → Comparative Exploratory Data Analysis (EDA)**

### Engine Comparison
Benchmark and visualize analytical results derived from the same dataset (California Housing) using four distinct high‑performance approaches:

- **Apache Arrow:** Zero‑copy I/O and rapid dplyr‑based analytics over Parquet.  
- **Reticulate + Polars:** Rust‑based, multi‑threaded DataFrame operations via Python interoperability.  
- **DuckDB SQL:** Embedded OLAP engine enabling high‑speed SQL queries directly on CSV or Parquet.  
- **Duckplyr:** dplyr syntax accelerated through transparent delegation to the DuckDB engine.  

>  **Applied Case Study: E‑Commerce Analytics:**
> 
> The **E‑commerce Sales Performance Benchmark** analyzes partitioned sales data by `transaction_year` and `transaction_month`, computing KPIs such as:
> - Percentage of high‑value orders (> $500) per year  
> - Total transaction volume per partition  
> - Aggregated metrics for order distribution visualization
---

##  Technical Stack

| Tool | Role | Why It's Used | Example E‑commerce Use Case |
|------|------|----------------|------------------------------|
| **Arrow** | Dataset Management & I/O | Zero‑copy, in‑memory columnar storage for efficient Parquet/CSV operations. | Handling massive transaction logs or clickstream data with minimal memory overhead. |
| **DuckDB** | High‑Performance Database | Embedded analytical engine supporting SQL on local files. | Running product revenue aggregation or cohort analysis directly on CSV exports. |
| **Duckplyr** | Accelerated dplyr Syntax | Offloads R dplyr workflows to DuckDB for speedups. | Quickly filtering, grouping, and summarizing large customer datasets without SQL. |
| **Reticulate + Polars** | Multi‑threaded DataFrame Ops | Integrates Rust‑based Polars for fast in‑memory computation. | Computing KPIs like AOV (Average Order Value) or customer lifetime metrics in parallel. |
| **Tidyverse (ggplot2)** | Visualization | Clean, high‑quality static and interactive plots. | Visual dashboards summarizing sales volumes, price distribution, or geolocation insights. |

---

##  Prerequisites and Installation

The project requires both **R** and a minimal **Python** environment (for Polars via Reticulate).

### R Setup
```
install.packages(c("Rcpp", "BH", "DBI"), dependencies = TRUE)
install.packages(c("arrow", "duckdb", "duckplyr", "tidyverse", "reticulate", "readr"), dependencies = TRUE)
reticulate::py_install(packages = c("polars", "s3fs", "fsspec"), pip = TRUE)
```

