# Thanks knowledge sharing <https://zhuanlan.zhihu.com/p/24671904444>

# Load necessary libraries
library(tidyverse) # For data manipulation syntax (dplyr)
library(tictoc)    # For measuring execution time
library(arrow)     # For reading/writing Parquet and handling Datasets
library(duckdb)    # For high-performance SQL querying
library(duckplyr)  # For accelerating dplyr using the DuckDB engine

# --- DATA PREPARATION (Ingestion and Partitioning - Hypothetical) ---
# NOTE: This section is typically run once to set up the local dataset.
# The code below is commented out as it requires a specific S3 path and local setup.

# open_dataset("s3://voltrondata-labs-datasets/nyc-taxi") |>
#   filter(year %in% 2012:2021) |>
#   # Write filtered data to local disk, partitioned by year and month
#   write_dataset("data/nyc-taxi", partitioning = c("year", "month"))

# --- 1. CORE ANALYSIS SETUP (Using Arrow Dataset) ---
# Open the local partitioned dataset (points to the directory of Parquet files)
nyc = open_dataset("data/nyc-taxi")

# Display dataset structure (Arrow object)
print(nyc)
# Count the total number of records (Note: may take time for large datasets)
print(nrow(nyc)) 

# --- 2. PERFORMANCE COMPARISON: DUCKDB (via DBI/dbplyr) ---
# Use DuckDB to query the Parquet files directly (Zero-Copy Read)

# Connect to a persistent DuckDB database file
con = dbConnect(duckdb(), dbdir = "nyc.duckdb")

# Create an external table reference in DuckDB pointing to the Parquet files
# 'hive_partitioning = true' ensures DuckDB correctly identifies partitions (year, month)
nyc_db = tbl(con, "read_parquet('data/nyc-taxi/*/*/*.parquet', hive_partitioning = true)")
print(nyc_db)

# Start timer
tic("DuckDB (External Table)") 
# Perform the core analysis query using dplyr syntax translated to SQL by dbplyr
analysis_result_duckdb = nyc_db |>
  summarise(
    all_trips = n(),
    # Calculate the number of shared trips (passenger_count > 1)
    shared_trips = sum(as.integer(passenger_count > 1), na.rm = TRUE),
    .by = year) |>
  mutate(pct_shared = shared_trips / all_trips * 100) |>
  arrange(year) |>
  collect() # Pull the final result into R's memory

# Stop timer and print result
toc() 
print(analysis_result_duckdb)

# Optional: Show the generated SQL query (no execution)
nyc_db |>
  summarise(
    all_trips = n(),
    shared_trips = sum(as.integer(passenger_count > 1), na.rm = TRUE),
    .by = year) |>
  mutate(pct_shared = shared_shared / all_trips * 100) |>
  arrange(year) |>
  show_query()

# Disconnect from DuckDB
dbDisconnect(con)


# --- 3. PERFORMANCE COMPARISON: DUCKPLYR (Accelerated DPLYR) ---
# Use the duckplyr library, which automatically leverages DuckDB for dplyr operations.

# Load data using duckplyr's optimized Parquet reader
nyc_duckplyr = read_parquet_duckdb("data/nyc-taxi/*/*/*.parquet") 

# Start timer
tic("Duckplyr (Accelerated dplyr)")
analysis_result_duckplyr = nyc_duckplyr |>
  summarise(
    all_trips = n(),
    shared_trips = sum(as.integer(passenger_count > 1), na.rm = TRUE),
    .by = year) |>
  mutate(pct_shared = shared_trips / all_trips * 100) |>
  collect()
# Stop timer and print result
toc()
print(analysis_result_duckplyr)


# --- 4. PERFORMANCE COMPARISON: ARROW (Native Engine) ---
# Use Arrow's native compute engine without DuckDB acceleration.

# Reopen the Arrow dataset
nyc_arrow = open_dataset("data/nyc-taxi") 

# Start timer
tic("Arrow (Native Engine)")
analysis_result_arrow = nyc_arrow |>
  summarise(
    all_trips = n(),
    shared_trips = sum(passenger_count > 1, na.rm = TRUE),
    .by = year) |>
  mutate(pct_shared = shared_trips / all_trips * 100) |>
  collect()
# Stop timer and print result
toc()
print(analysis_result_arrow)
