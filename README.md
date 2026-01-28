# Exploratory Data Analysis (EDA) Project

## Overview
This repository contains SQL queries and database design for an e-commerce-like system including customers, products, orders, shipments, and suppliers. The ERD diagram outlines the relationships among various entities like customers, products, sales orders, suppliers, shipments, and warehouses.

## Features
- SQL queries to analyze customer spending, product orders, supplier contributions, and shipment details.
- Complex queries using window functions and ranking for advanced analytics.
- A stored procedure to get sales summary for suppliers.
- View creation for customer order summaries.

## SQL Queries Included
1. Top 5 customers by total spending.
2. Product count supplied by each supplier (only those with more than 10 products).
3. Products ordered but never returned.
4. Most expensive product per category.
5. Detailed sales order listing with customer, product, category, and supplier info.
6. Shipment details including warehouse and manager info.
7. Top 3 highest-value orders per customer.
8. Sales history with previous and next sales quantities.
9. Customer order summary view.
10. Stored procedure for supplier sales summary.

## How to Use
- Clone the repository.
- Use the ERD to understand database schema.
- Run SQL queries on your database to analyze data.
- Modify queries as per your schema or requirements.

## Technologies
- SQL (MySQL/PostgreSQL compatible syntax)
- Database modeling (ERD)

## Author
Usman Muhammad Zareen

## License
MIT License

---

Feel free to open issues or contribute improvements!

