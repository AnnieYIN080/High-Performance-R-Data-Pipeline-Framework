# R Big Data Query Benchmark: Arrow vs. DuckDB Performance

This repository provides a comprehensive R script to benchmark the performance of various data processing engines when executing common analytical queries on large, partitioned Parquet datasets.

The code is heavily inspired by advanced R big data practices and leverages modern, high-performance tools.

## Core Objective

To calculate the percentage of "shared trips" (trips with `passenger_count > 1`) in the NYC Taxi dataset over time (2012-2021) and **measure the execution time** of the same query using different backends:

1.  **DuckDB** (via `dbplyr` as an external table).
2.  **Duckplyr** (using the `duckplyr` library for accelerated `dplyr`).
3.  **Apache Arrow** (using Arrow's native compute engine).

## Technical Stack

| Tool | Role | Why It's Used |
| :--- | :--- | :--- |
| **Arrow** | Dataset Management & I/O | Enables reading and handling massive, partitioned Parquet files efficiently without loading them entirely into R's memory. |
| **DuckDB** | High-Performance Database | An embedded analytical database engine optimized for fast query execution on column-oriented formats (like Parquet). |
| **`duckplyr`** | Accelerated `dplyr` Syntax | Accelerates standard `dplyr` operations by transparently offloading the computation to the DuckDB engine. |
| **`tictoc`** | Benchmarking | Provides accurate measurement of the query execution time for direct comparison. |

## Prerequisites

To run the analysis script, you need to install the following R packages:

`install.packages(c("tidyverse", "tictoc", "arrow", "duckdb", "duckplyr"))`

1. DuckDB External Table Query
```
con = dbConnect(duckdb(), dbdir = "nyc.duckdb")
nyc_db = tbl(con, "read_parquet('data/nyc-taxi/*/*/*.parquet', hive_partitioning = true)")

tic("DuckDB (External Table)") 
analysis_result_duckdb = nyc_db |>
  summarise(...) |>
  collect() 
toc() # Measures SQL execution time
```

2. Duckplyr Accelerated Query
```
nyc_duckplyr = read_parquet_duckdb("data/nyc-taxi/*/*/*.parquet") 
tic("Duckplyr (Accelerated dplyr)")
# ... (standard dplyr pipe execution) ...
toc()
```

3. Arrow Native Compute
```
nyc_arrow = open_dataset("data/nyc-taxi") 
tic("Arrow (Native Engine)")
# ... (standard dplyr pipe execution) ...
toc()
```
