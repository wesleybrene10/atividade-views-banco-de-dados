USE classicmodels;

CREATE OR REPLACE VIEW view_relatorio_financeiro AS
SELECT
    c.customerName,
    o.orderNumber,
    SUM(od.quantityOrdered * od.priceEach) AS valor_total
FROM customers c
JOIN orders o ON c.customerNumber = o.customerNumber
JOIN orderdetails od ON o.orderNumber = od.orderNumber
WHERE o.status = 'Shipped'
  AND o.orderDate >= '2004-01-01'
  AND o.orderDate < '2005-01-01'
GROUP BY c.customerName, o.orderNumber;

SELECT * FROM view_relatorio_financeiro;

-- A consulta abaixo deve retornar zero linhas.
SELECT v.orderNumber, o.status, o.orderDate
FROM view_relatorio_financeiro v
JOIN orders o ON v.orderNumber = o.orderNumber
WHERE o.status <> 'Shipped'
   OR o.orderDate < '2004-01-01'
   OR o.orderDate >= '2005-01-01';
