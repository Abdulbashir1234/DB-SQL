-- 1. Elenco uffici con indirizzo, telefono e fatturato (importo totale ordini gestiti dai relativi employee) dell'anno 2004; decrescente per fatturato.
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
-- 2. Produrre l'elenco degli employee (lastName, firstName) con il relativo numero di customer gestiti (anche eventualmente 0).
SELECT lastName,
    firstName,
    COUNT(customerNumber) AS gestiti
FROM employees
    LEFT JOIN customers ON(salesRepEmployeeNumber = employeeNumber)
GROUP BY employeeNumber;
-- 3. Per ciascun prodotto (productCode, productName, buyPrice, minimo, massimo) il minimo ed il massimo prezzo a cui sono stati ordinati (priceEach), solo se non entrambi uguali a buyPrice.
SELECT productCode,
    productName,
    buyPrice,
    MIN(priceEach) AS minimo,
    MAX(priceEach) AS massimo
FROM products
    JOIN orderdetails USING(productCode)
GROUP BY productCode
HAVING buyPrice != minimo OR buyPrice != massimo;
-- 4. Elenco degli ordini (orderNumber, importo, guadagno, % guadagno/importo) in cui il guadagno è stato inferiore al 20% dell'importo.
SELECT orderNumber,
    SUM(quantityOrdered * priceEach) AS importo,
    SUM(quantityOrdered * (priceEach - buyPrice)) AS guadagno,
    SUM(quantityOrdered * (priceEach - buyPrice)) * 100 / SUM(quantityOrdered * priceEach) AS percentuale
FROM orders
    JOIN orderdetails USING(orderNumber)
    JOIN products USING(productCode)
GROUP BY orderNumber
HAVING percentuale < 20;
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
-- 6. Top ten delle productLine più ordinate (productLine, quantità totale ordinata).
SELECT productLine,
    SUM(quantityOrdered) AS ordinato
FROM products p
    JOIN orderdetails USING(productCode)
GROUP BY productLine
ORDER BY ordinato DESC
LIMIT 10;
-- 7. Elenco articoli (productCode, productName, buyPrice, MSRP, margine) con margine di guadagno (rapporto tra (MSRP - buyPrice) e buyPrice) inferiore all’80%.
SELECT productCode,
    productName,
    buyPrice,
    MSRP,
    (MSRP - buyPrice) * 100 / buyPrice AS margine
FROM products p
WHERE (MSRP - buyPrice) * 100 / buyPrice < 80;
-- GROUP BY productCode
-- HAVING margine < 80;
-- 8. Elenco articoli (productCode, productName, buyPrice, prezzo medio, margine) con margine effettivo di guadagno (rapporto tra (prezzo medio ordini - buyPrice) e buyPrice) inferiore all’80%.
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
HAVING margine < 80;
-- 9. Elenco clienti (customerNumber, customerName, importo medio) con relativo importo medio dei pagamenti (solo clienti che hanno effettuato pagamenti).
SELECT c.customerNumber,
    c.customerName,
    AVG(amount) AS medio
FROM customers c
    JOIN payments p USING(customerNumber)
GROUP BY customerNumber;
-- 10. Elenco dei clienti (customerName, country cliente, country ufficio) che fanno riferimento ad un ufficio in una country diversa dalla loro.
SELECT customerName,
    c.country,
    o.country
FROM customers c
    JOIN employees ON (salesRepEmployeeNumber = employeeNumber)
    JOIN offices o USING(officeCode)
WHERE c.country != o.country;
-- 11. Elenco dei clienti (customerName, country cliente, country ufficio) che fanno riferimento ad un ufficio in una country diversa dalla loro, pur essendovi un ufficio nella loro country.
SELECT customerName,
    c.country,
    o.country
FROM customers c
    JOIN employees ON (salesRepEmployeeNumber = employeeNumber)
    JOIN offices o USING(officeCode)
WHERE c.country != o.country
    AND EXISTS(
        SELECT *
        FROM offices oe
        WHERE oe.country = c.country
    );