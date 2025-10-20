# ------------------------------------------------------------------
# R Script: E-Commerce Sales Performance Analysis (Big Data Benchmark)
# ------------------------------------------------------------------

# Load necessary libraries
library(tidyverse)
library(tictoc)
library(arrow)
library(duckdb)
library(duckplyr)

# --- HYPOTHETICAL DATA SETUP (Assumed to be complete) ---
# Assume a local partitioned dataset exists: 'data/ecommerce-sales'
# Partitioned by 'transaction_year' and 'transaction_month'.
# Columns include: transaction_year, transaction_month, customer_id, order_total

# --- 1. CORE ANALYSIS SETUP (Using Arrow Dataset) ---
# Open the local partitioned dataset
SALES_DATA = open_dataset("data/ecommerce-sales")

# --- 2. PERFORMANCE COMPARISON: DUCKDB (via DBI/dbplyr) ---
con = dbConnect(duckdb(), dbdir = "sales_analysis.duckdb")

# Create external table reference in DuckDB
SALES_DB = tbl(con, "read_parquet('data/ecommerce-sales/*/*/*.parquet', hive_partitioning = true)")

# Start timer
tic("DuckDB (External Table) - E-Commerce") 
# Core Analysis: Calculate the percentage of high-value orders (> 500) per year
sales_result_duckdb = SALES_DB |>
  summarise(
    all_orders = n(),
    # Calculate the number of high-value orders (order_total > 500)
    high_value_orders = sum(as.integer(order_total > 500), na.rm = TRUE),
    .by = transaction_year) |>
  mutate(pct_high_value = high_value_orders / all_orders * 100) |>
  arrange(transaction_year) |>
  collect() 

# Stop timer and print result
toc() 
print(sales_result_duckdb)

dbDisconnect(con)


# --- 3. PERFORMANCE COMPARISON: DUCKPLYR (Accelerated DPLYR) ---
SALES_DUCKPLYR = read_parquet_duckdb("data/ecommerce-sales/*/*/*.parquet") 

# Start timer
tic("Duckplyr (Accelerated dplyr) - E-Commerce")
sales_result_duckplyr = SALES_DUCKPLYR |>
  summarise(
    all_orders = n(),
    high_value_orders = sum(as.integer(order_total > 500), na.rm = TRUE),
    .by = transaction_year) |>
  mutate(pct_high_value = high_value_orders / all_orders * 100) |>
  collect()
# Stop timer and print result
toc()
print(sales_result_duckplyr)


# --- 4. PERFORMANCE COMPARISON: ARROW (Native Engine) ---
SALES_ARROW = open_dataset("data/ecommerce-sales") 

# Start timer
tic("Arrow (Native Engine) - E-Commerce")
sales_result_arrow = SALES_ARROW |>
  summarise(
    all_orders = n(),
    high_value_orders = sum(order_total > 500, na.rm = TRUE),
    .by = transaction_year) |>
  mutate(pct_high_value = high_value_orders / all_orders * 100) |>
  collect()
# Stop timer and print result
toc()
print(sales_result_arrow)
