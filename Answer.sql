use  NEXT_COLA_OLTP ;
-- Q1. Top 5 customers by total order amount
SELECT
    c.CustomerID,
    c.Name AS CustomerName,
    SUM(so.TotalAmount) AS TotalSpent
FROM customer c
JOIN salesorder so ON c.CustomerID = so.CustomerID
GROUP BY c.CustomerID, c.Name
ORDER BY TotalSpent DESC;

-- Q2. Number of products supplied by each supplier (more than 10 products)
SELECT
    s.SupplierID,
    s.Name AS SupplierName,
    COUNT(DISTINCT p2.ProductID) AS ProductCount
FROM supplier s
JOIN purchaseorder po ON s.SupplierID = po.SupplierID
JOIN purchaseorderdetail pod ON po.OrderID = pod.OrderID
JOIN product p2 ON pod.ProductID = p2.ProductID
GROUP BY s.SupplierID, s.Name
HAVING COUNT(DISTINCT p2.ProductID) > 10;

-- Q3. Products ordered but never returned
SELECT
    p.ProductID,
    p.Name AS ProductName,
    SUM(sod.Quantity) AS TotalOrderQuantity
FROM product p
JOIN salesorderdetail sod ON p.ProductID = sod.ProductID
LEFT JOIN returndetail rd ON p.ProductID = rd.ProductID
LEFT JOIN returns r ON rd.ReturnID = r.ReturnID
WHERE r.ReturnID IS NULL
GROUP BY p.ProductID, p.Name;

-- Q4. Most expensive product per category (using subquery)
SELECT
    c.CategoryID,
    c.Name AS CategoryName,
    p.Name AS ProductName,
    p.Price
FROM category c
JOIN product p ON c.CategoryID = p.CategoryID
WHERE p.Price = (
    SELECT MAX(p2.Price)
    FROM product p2
    WHERE p2.CategoryID = c.CategoryID
);

-- Q5. List all sales orders with customer name, product name, category, and supplier
SELECT
    so.OrderID,
    c.Name AS CustomerName,
    p.Name AS ProductName,
    cat.Name AS CategoryName,
    s.Name AS SupplierName,
    sod.Quantity
FROM salesorder so
JOIN customer c ON so.CustomerID = c.CustomerID
JOIN salesorderdetail sod ON so.OrderID = sod.OrderID
JOIN product p ON sod.ProductID = p.ProductID
JOIN category cat ON p.CategoryID = cat.CategoryID
JOIN purchaseorder po ON p.ProductID = po.OrderID  -- this join might not be accurate; adjust as needed
JOIN supplier s ON po.SupplierID = s.SupplierID;

-- Q6. Shipments with warehouse, manager, and products shipped
SELECT
    sh.ShipmentID,
    w.LocationID AS WarehouseName,
    e.Name AS ManagerName,
    p.Name AS ProductName,
    shd.Quantity AS QuantityShipped,
    sh.TrackingNumber
FROM shipment sh
JOIN warehouse w ON sh.WarehouseID = w.WarehouseID
LEFT JOIN employee e ON w.ManagerID = e.EmployeeID
JOIN shipmentdetail shd ON sh.ShipmentID = shd.ShipmentID
JOIN product p ON shd.ProductID = p.ProductID;

-- Q7. Top 3 highest-value orders per customer using RANK()
SELECT
    CustomerID,
    CustomerName,
    OrderID,
    TotalAmount
FROM (
    SELECT
        c.CustomerID,
        c.Name AS CustomerName,
        so.OrderID,
        so.TotalAmount,
        RANK() OVER (PARTITION BY c.CustomerID ORDER BY so.TotalAmount DESC) AS order_rank
    FROM salesorder so
    JOIN customer c ON so.CustomerID = c.CustomerID
) ranked_orders
WHERE order_rank <= 3;

-- Q8. For each product, show sales history with previous and next sales quantities (based on order date)
SELECT
    p.ProductID,
    p.Name AS ProductName,
    so.OrderID,
    so.OrderDate,
    sod.Quantity,
    LAG(sod.Quantity) OVER (PARTITION BY p.ProductID ORDER BY so.OrderDate) AS PrevQuantity,
    LEAD(sod.Quantity) OVER (PARTITION BY p.ProductID ORDER BY so.OrderDate) AS NextQuantity
FROM product p
JOIN salesorderdetail sod ON p.ProductID = sod.ProductID
JOIN salesorder so ON sod.OrderID = so.OrderID
ORDER BY p.ProductID, so.OrderDate;

-- Q9. Create view vw_CustomerOrderSummary
CREATE OR REPLACE VIEW vw_CustomerOrderSummary AS
SELECT
    c.CustomerID,
    c.Name AS CustomerName,
    COUNT(so.OrderID) AS TotalOrders,
    COALESCE(SUM(so.TotalAmount), 0) AS TotalAmountSpent,
    MAX(so.OrderDate) AS LastOrderDate
FROM customer c
LEFT JOIN salesorder so ON c.CustomerID = so.CustomerID
GROUP BY c.CustomerID, c.Name;

-- Q10. Stored procedure sp_GetSupplierSales to get total sales amount by SupplierID
CREATE OR REPLACE PROCEDURE sp_GetSupplierSales (IN inputSupplierID INT)
BEGIN
    SELECT
        s.SupplierID,
        s.Name AS SupplierName,
        COALESCE(SUM(sod.Quantity * p.Price), 0) AS TotalSalesAmount
    FROM supplier s
    LEFT JOIN purchaseorder po ON s.SupplierID = po.SupplierID
