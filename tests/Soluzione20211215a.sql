use classicmodels;
-- 1 Numero, denominazione, nome del referente, telefono, limite di credito dei clienti residenti negli USA con limite di credito compreso tra 100.000 e 200.000)
SELECT customerNumber,
    customerName,
    contactLastname,
    contactFirstname,
    phone,
    creditLimit
FROM customers
WHERE creditLimit BETWEEN 100000 AND 200000
    AND country = "USA";
-- 2 Numero di clienti per venditore, suddivisi per stato di residenza
SELECT employeeNumber,
    lastName,
    firstName,
    country,
    COUNT(*) AS clienti
FROM customers
    JOIN employees ON salesRepEmployeeNumber = employeeNumber
GROUP BY employeeNumber,
    country WITH ROLLUP;
-- 3 Nome referente (se presente) di tutti i clienti residenti in Spagna
SELECT customerNumber,
    customerName,
    country,
    lastName,
    firstName
FROM customers
    LEFT JOIN employees ON (SalesRepEmployeeNumber = employeeNumber)
WHERE country = "Spain";
-- 4 Elenco dei clienti che nell'anno 2004 hanno effettuato pagamenti con totale oltre 50000
SELECT customerNumber,
    customerName,
    SUM(amount) AS totale -- per verifica
FROM customers
    JOIN payments USING(customerNumber)
WHERE YEAR(paymentDate) = 2004
GROUP BY customerNumber
HAVING totale > 50000;
-- 5 Elenco delle categorie (productLine) con il relativo numero di prodotti (anche eventualmente 0).
SELECT productLine,
    COUNT(productCode) AS prodotti
FROM productlines
    LEFT JOIN products USING(productLine)
GROUP BY productLine;
-- 6 Elenco dei clienti (customerNumber, customerName) con il relativo numero di ordini (almeno uno) effettuati in un dato periodo di tempo, specificato tramite le date di inizio e fine.
SET @Inizio = '2003-10-10';
SET @Fine = '2004-10-10';
SELECT customerNumber,
    customerName,
    COUNT(*) AS ordini
FROM customers
    JOIN orders USING(customerNumber)
WHERE orderDate BETWEEN @Inizio AND @Fine
GROUP BY customerNumber;
-- 7 Elenco dei clienti (customerNumber, customerName) con il relativo numero di pagamenti (anche eventualmente 0) effettuati in un dato periodo di tempo, specificato tramite le date di inizio e fine.
SET @Inizio = '2004-01-01';
SET @Fine = '2004-05-31';
-- NON funziona
SELECT customerNumber,
    customerName,
    COUNT(checkNumber) AS pagamenti
FROM customers
    LEFT JOIN payments USING(customerNumber)
WHERE paymentDate BETWEEN @Inizio AND @Fine
GROUP BY customerNumber;
-- con subquery
SELECT customerNumber,
    customerName,
    (
        SELECT COUNT(*)
        FROM payments p
        WHERE p.customerNumber = c.customerNumber
            AND paymentDate BETWEEN @Inizio AND @Fine
    ) AS pagamenti
FROM customers c;
-- con join "anomalo"
SELECT c.customerNumber,
    c.customerName,
    COUNT(checkNumber) AS pagamenti
FROM customers c
    LEFT JOIN payments p ON(
        p.customerNumber = c.customerNumber
        AND paymentDate BETWEEN @Inizio AND @Fine
    )
GROUP BY customerNumber;
-- 8 Elenco degli ordini (orderNumber, importo, guadagno, % guadagno/importo) in cui il guadagno è stato superiore al 40% dell'importo.
SELECT orderNumber,
    SUM(quantityOrdered * priceEach) AS importo,
    SUM(quantityOrdered * (priceEach - buyPrice)) AS guadagno,
    SUM(quantityOrdered * (priceEach - buyPrice)) * 100 / SUM(quantityOrdered * priceEach) AS percentuale
FROM orders
    JOIN orderdetails USING(orderNumber)
    JOIN products USING(productCode)
GROUP BY orderNumber
HAVING percentuale > 40;
-- 9 Elenco dei clienti (customerNumber, customerName, creditLimit) che hanno superato il creditLimit, con relativo saldo a debito (ordinato - pagato).
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
GROUP BY customerNumber -- not needed: should be a WHERE...
HAVING saldo > creditLimit;
-- 10 Ritardo (o anticipo) medio, minimo e massimo degli ordini con stato 'Shipped'.
SELECT AVG(DATEDIFF(shippedDate, requiredDate)) AS medio,
    MIN(DATEDIFF(shippedDate, requiredDate)) AS minimo,
    MAX(DATEDIFF(shippedDate, requiredDate)) AS massimo
FROM orders
WHERE status = 'Shipped';
-- 11 Top ten degli articoli più ordinati assieme a 'S18_3232' (productCode, productName, numero ordini comuni).
SELECT productCode,
    productName,
    COUNT(orderNumber) AS ordini
FROM products p
    JOIN orderdetails od USING(productCode)
WHERE orderNumber IN (
        SELECT orderNumber
        FROM orderdetails
        WHERE productCode = 'S18_3232'
    )
    AND productCode != 'S18_3232'
GROUP BY productCode
ORDER BY ordini DESC
LIMIT 10;