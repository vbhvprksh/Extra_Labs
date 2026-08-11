SALES POWER QUERY + STAR SCHEMA PRACTICE DATASET
====================================================

Files
-----
1. DimDate.csv
2. DimCustomer.csv
3. DimProduct.csv
4. DimSalesperson.csv
5. Sales_2024_Raw.csv
6. Sales_2025_Raw.csv
7. Returns.csv
8. SalesTargets.csv
9. MonthlyTargets_Wide.csv
10. ChannelPayment_Summary.csv

Recommended Power BI / Power Query practice
-------------------------------------------
DATA PROFILING
- Enable Column quality, Column distribution and Column profile.
- Look for nulls in DimCustomer Email/CustomerTier.
- Profile Sales_2024_Raw and Sales_2025_Raw for inconsistent values.

TRANSFORM COLUMNS
- Clean/Trim SalesChannel, PaymentMethod and CustomerType.
- Replace "completed" / "Completed" with a single standard value.
- Convert UnitPrice from text such as ₹45,000.00 to decimal.
- Convert DiscountPct from "10%" to decimal/percentage.
- Parse OrderDate in different source formats.
- Extract Year, Month, Quarter and Day from OrderDate.

ADD NEW COLUMNS
- Gross Sales = Quantity * UnitPrice
- Discount Amount = Gross Sales * DiscountPct
- Net Sales = Gross Sales - Discount Amount
- Order Year / Month
- Sales Band based on NetSales

SPLIT / EXTRACT
- Split CustomerName into First Name and Last Name.
- Extract email domain from Email.
- Split ProductName into meaningful pieces where applicable.
- Extract Year and Month from InvoiceNo / OrderDate if desired.

USER-FRIENDLY VALUES
- Standardize channel values: Online, Retail Store, Distributor.
- Standardize payment values: Credit Card, UPI, Bank Transfer, Cash, Wallet.
- Replace blanks with "Unknown" where appropriate.
- Create friendly labels for CustomerTier/ProductClass.

SHAPING TABLE STRUCTURE
- Remove unnecessary columns.
- Reorder and rename columns.
- Filter cancelled orders.
- Keep only required columns for the fact table.
- Group/aggregate data for summary tables.

DATA TYPES
- Date: OrderDate, ReturnDate, SignupDate, FullDate
- Whole number: Quantity, Year, MonthNumber, WeekNumber
- Decimal: UnitPrice, GrossSales, NetSales, RefundAmount, SalesTarget
- Percentage: DiscountPct
- Text: keys and descriptive columns
- Boolean: IsWeekend

APPEND QUERIES
- Append Sales_2024_Raw + Sales_2025_Raw into FactSales_Raw.
- Standardize data types/formats before or during the append.

MERGE QUERIES
- Merge FactSales with DimCustomer using CustomerKey.
- Merge FactSales with DimProduct using ProductKey.
- Merge FactSales with DimSalesperson using SalespersonKey.
- Merge FactSales with Returns using InvoiceNo.
- Merge monthly/region results with SalesTargets using MonthRegionKey.

UNPIVOT
- Use MonthlyTargets_Wide.csv.
  Region + Jan-Jun should be unpivoted into Month and TargetAmount.

PIVOT
- Use ChannelPayment_Summary.csv.
  Pivot PaymentMethod to create one column per payment method.

PARAMETERS / DYNAMIC REPORTS
Create Power Query parameters such as:
- StartDate = 2024-01-01
- EndDate = 2025-12-31
- MinimumSales = 10000
Use them to dynamically filter FactSales.

STAR SCHEMA
-------------------------
                    DimDate
                       |
DimCustomer ---- FactSales ---- DimProduct
                       |
                 DimSalesperson

Optional supporting table:
FactSales ---- Returns
FactSales/aggregations ---- SalesTargets

Recommended FactSales grain:
One row = one invoice/order line.

Recommended final FactSales columns:
InvoiceNo, OrderDate, DateKey, CustomerKey, ProductKey,
SalespersonKey, Quantity, UnitPrice, DiscountPct,
GrossSales, NetSales, PaymentMethod, SalesChannel,
OrderStatus, CustomerType

Recommended relationships:
DimDate[DateKey] 1 -> * FactSales[DateKey]
DimCustomer[CustomerKey] 1 -> * FactSales[CustomerKey]
DimProduct[ProductKey] 1 -> * FactSales[ProductKey]
DimSalesperson[SalespersonKey] 1 -> * FactSales[SalespersonKey]

Suggested report pages
----------------------
1. Executive Sales Overview
2. Sales by Region / City
3. Product & Category Performance
4. Customer Segmentation
5. Salesperson Performance
6. Returns Analysis
7. Target vs Actual
8. Dynamic Date / Minimum Sales parameter page
