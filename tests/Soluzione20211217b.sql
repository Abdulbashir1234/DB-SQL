-- 1. Elenco uffici con indirizzo, telefono e fatturato (importo totale ordini gestiti dai relativi employee) dell'anno 2004; decrescente per fatturato
SELECT officecode,
    addressline1,
    city,
    phone,
    SUM(quantityOrdered * priceEach) AS Fatturato
FROM offices
    JOIN employees USING (officeCode)
    JOIN customers ON (employeeNumber = salesRepEmployeeNumber)
    JOIN orders USING (customerNumber)
    JOIN orderdetails USING (orderNumber)
WHERE YEAR(orderDate) = 2004
GROUP BY officeCode
ORDER BY Fatturato DESC;
-- 2. Elenco degli uffici (city) con il relativo numero di employees (anche eventualmente 0).
SELECT city,
    COUNT(employeeNumber) AS lavoratori
FROM offices
    LEFT JOIN employees USING(officeCode)
GROUP BY officeCode;
-- 3. Per ciascun prodotto (productCode, productName, buyPrice, minimo, massimo) il minimo ed il massimo prezzo a cui sono stati ordinati (priceEach), solo se non entrambi uguali a buyPrice.
SELECT productCode,
    productName,
    buyPrice,
    MIN(priceEach) AS minimo,
    MAX(priceEach) AS massimo
FROM products
    JOIN orderdetails USING(productCode)
GROUP BY productCode
HAVING buyPrice != minimo
    OR buyPrice != massimo;
-- 4. Elenco degli ordini (orderNumber, importo, guadagno, % guadagno/importo) in cui il guadagno è stato superiore al 40% dell'importo.
SELECT orderNumber,
    SUM(quantityOrdered * priceEach) AS importo,
    SUM(quantityOrdered * (priceEach - buyPrice)) AS guadagno,
    SUM(quantityOrdered * (priceEach - buyPrice)) * 100 / SUM(quantityOrdered * priceEach) AS percentuale
FROM orders
    JOIN orderdetails USING(orderNumber)
    JOIN products USING(productCode)
GROUP BY orderNumber
HAVING percentuale > 40;
-- 5. Elenco dei clienti (customerNumber, customerName, creditLimit) che hanno superato il creditLimit, con relativo saldo a debito (ordinato - pagato).
SELECT customerNumber,
    customerName,
    creditLimit,
    (
        SELECT SUM(quantityOrdered * priceEach)
        FROM orders o
            JOIN orderdetails USING(orderNumber)
        WHERE o.customerNumber = c.customerNumber
    ) - (
        SELECT SUM(amount)
        FROM payments p
        WHERE p.customerNumber = c.customerNumber
    ) AS saldo
FROM customers c
GROUP BY customerNumber
HAVING saldo > creditLimit;
-- 6. Top ten dei prodotti più ordinati (productCode, productName, quantità totale ordinata).
SELECT productCode,
    productName,
    SUM(quantityOrdered) AS ordinato
FROM products p
    JOIN orderdetails USING(productCode)
GROUP BY productCode
ORDER BY ordinato DESC
LIMIT 10;
-- 7. Elenco articoli (productCode, productName, buyPrice, MSRP, margine) con margine di guadagno (rapporto tra (MSRP - buyPrice) e buyPrice) maggiore del 100%.
SELECT productCode,
    productName,
    buyPrice,
    MSRP,
    (MSRP - buyPrice) * 100 / buyPrice AS margine
FROM products p
GROUP BY productCode
HAVING margine > 100;
-- 8. Elenco articoli (productCode, productName, buyPrice, prezzo medio, margine) con margine effettivo di guadagno (rapporto tra (prezzo medio ordini - buyPrice) e buyPrice) maggiore del 100%.
SELECT productCode,
    productName,
    buyPrice,
    (
        SELECT SUM(quantityOrdered * priceEach) / SUM(quantityOrdered)
        FROM orderdetails od
        WHERE od.productCode = p.productCode
    ) AS medio,
    (
        (
            SELECT SUM(quantityOrdered * priceEach) / SUM(quantityOrdered)
            FROM orderdetails od
            WHERE od.productCode = p.productCode
        ) - buyPrice
    ) * 100 / buyPrice AS margine
FROM products p
GROUP BY productCode
HAVING margine > 100;
-- 9. Elenco clienti (customerNumber, customerName, importo medio) con relativo importo medio degli ordini (anche clienti che non hanno effettuato ordini).
SELECT c.customerNumber,
    c.customerName,
    IFNULL(AVG(importo), 0) AS medio
FROM (
        SELECT customerNumber,
            orderNumber,
            SUM(quantityOrdered * priceEach) AS importo
        FROM orders
            JOIN orderdetails USING(orderNumber)
        GROUP BY orderNumber
    ) o
    RIGHT JOIN customers c USING(customerNumber)
GROUP BY customerNumber;
-- 10. Elenco articoli (productCode, productName, buyPrice, prezzo medio) con relativo prezzo medio ordini.
SELECT productCode,
    productName,
    buyPrice,
    (
        SELECT SUM(quantityOrdered * priceEach) / SUM(quantityOrdered)
        FROM orderdetails od
        WHERE od.productCode = p.productCode
    ) AS medio
FROM products p;
-- 11. Elenco dei clienti (customerName, country cliente, country ufficio) che fanno riferimento ad un ufficio in una country diversa dalla loro.
SELECT customerName,
    c.country,
    o.country
FROM customers c
    JOIN employees ON (salesRepEmployeeNumber = employeeNumber)
    JOIN offices o USING(officeCode)
WHERE c.country != o.country;