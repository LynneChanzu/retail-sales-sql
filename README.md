# Retail Sales & Customer Intelligence

## Project Overview

This project analyses retail sales and customer data using PostgreSQL to uncover insights into business performance, product profitability and customer purchasing behaviour.

The analysis focuses on:
- Overall revenue, costs and profitability.
- Most profitable product categories.
- Top five products by revenue.
- Customer segmentation based on spending.
- Top five customers by spending.
- Monthly revenue trends.

## Tools & Technologies

- **Database:** PostgreSQL 18
- **SQL Environment:** DBeaver
- **Language:** SQL

## Dataset

The project uses the Retail Sales & Customer Intelligence dataset, consisting of two tables:

| Table | Description |
|---|---|
| `customers` | Contains customer information. |
| `orders` | Contains order and transaction details. |

**Dataset coverage:** January 2025 – September 2026

**Dataset size:**
- 150 customer records
- 800 order records

## Project Setup

### 1. Install the Requirements

Ensure you have:
- PostgreSQL installed.
- DBeaver installed (or another PostgreSQL-compatible SQL client).
- The project dataset files.

### 2. Create a Database

Open DBeaver or your PostgreSQL terminal and execute:

`CREATE DATABASE retail_analytics;`

### 3. Import the Dataset

Import the customer and order data into PostgreSQL, creating the following tables:

- `customers`
- `orders`

Ensure the column names and data types match those expected by the SQL scripts.

## Running the Queries

1. Open DBeaver and connect to the `retail_analytics` database.
2. Open the SQL scripts included in the project.
3. Execute the queries using the SQL editor.
4. Review the result sets to explore the findings.

### Financial Calculation Rules

Financial calculations consider completed orders only (`order_status = 'Completed'`).

The following formulas are used:

- **Revenue:** Quantity × Unit Price × (1 − Discount / 100)
- **Cost:** Quantity × Cost Price
- **Profit:** Revenue − Cost
- **Profit Margin:** (Profit / Revenue) × 100

## Project Findings

The analysis is documented in [`insights.md`](insights.md), which presents the key findings, business implications and recommendations.