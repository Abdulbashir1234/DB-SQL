use classicmodels;
-- 1 Numero di clienti per stato con valore di limite di credito  medio, minimo e massimo 
SELECT country,
    COUNT(*),
    AVG(creditLimit),
    MIN(creditLimit),
    MAX(creditLimit)
FROM customers
GROUP BY country;
-- 2 Numero, indirizzo, città, telefono di ciascun negozio e il relativo numero di impiegati
SELECT officecode,
    addressline1,
    city,
    phone,
    COUNT(employeeNumber) AS NUMImpiegati
FROM offices
    JOIN employees USING (officeCode)
GROUP BY officeCode;
-- 3 Contare gli ordini per cliente divisi per stato ordine
SELECT customerNumber,
    customerName,
    COUNT(orderNumber),
    status
FROM customers
    LEFT JOIN orders USING (customerNumber)
GROUP BY customerNumber,
    status;
-- 4 Elenco dei prodotti che nell'anno 2004 hanno avuto ordini per un numero di pezzi superiore a 700, in ordine decrescente per quantità
SELECT productCode,
    productName,
    productLine,
    SUM(quantityOrdered) as QTA
FROM products
    JOIN orderdetails USING(productCode)
    JOIN orders USING (orderNumber)
WHERE YEAR(orderDate) = 2004
GROUP BY productCode
HAVING QTA > 700
ORDER BY QTA DESC;
--  5 Elenco degli uffici (city) con il relativo numero di employees (anche eventualmente 0).
SELECT city,
    COUNT(employeeNumber) AS lavoratori
FROM offices
    LEFT JOIN employees USING(officeCode)
GROUP BY officeCode;
--  6 Elenco dei clienti (customerNumber, customerName) con il relativo numero di pagamenti (almeno uno) effettuati in un dato periodo di tempo, specificato tramite le date di inizio e fine.
SET @Inizio = '2004-01-01';
SET @Fine = '2004-05-31';
SELECT customerNumber,
    customerName,
    COUNT(checkNumber) AS pagamenti
FROM customers
    JOIN payments USING(customerNumber)
WHERE paymentDate BETWEEN @Inizio AND @Fine
GROUP BY customerNumber;
--  7 Elenco dei clienti (customerNumber, customerName) con il relativo numero di ordini (anche eventualmente 0) effettuati in un dato periodo di tempo, specificato tramite le date di inizio e fine.
SET @Inizio = '2004-01-01';
SET @Fine = '2004-05-31';
-- con subquery
SELECT customerNumber,
    customerName,
    (
        SELECT COUNT(*)
        FROM orders o
        WHERE o.customerNumber = c.customerNumber
            AND orderDate BETWEEN @Inizio AND @Fine
    ) AS ordini
FROM customers c;
-- con join "anomalo"
SELECT c.customerNumber,
    c.customerName,
    COUNT(orderNumber) AS ordini
FROM customers c
    LEFT JOIN orders o ON(
        o.customerNumber = c.customerNumber
        AND orderDate BETWEEN @Inizio AND @Fine
    )
GROUP BY customerNumber;
--  8 Elenco degli ordini (orderNumber, importo, guadagno, % guadagno/importo) in cui il guadagno è stato inferiore al 20% dell'importo.
SELECT orderNumber,
    SUM(quantityOrdered * priceEach) AS importo,
    SUM(quantityOrdered * (priceEach - buyPrice)) AS guadagno,
    SUM(quantityOrdered * (priceEach - buyPrice)) * 100 / SUM(quantityOrdered * priceEach) AS percentuale
FROM orders
    JOIN orderdetails USING(orderNumber)
    JOIN products USING(productCode)
GROUP BY orderNumber
HAVING percentuale < 20;
-- 9 Articoli (productCode, productName, quantityInStock, ordinato) con quantityInStock minore della quantità ordinata in ordini con stato 'In process'.
-- con subquery
SELECT productCode,
    productName,
    quantityInStock,
    (
        SELECT SUM(quantityOrdered)
        FROM orderdetails od
            JOIN orders o USING(orderNumber)
        WHERE od.productCode = p.productCode
            AND o.status = 'In process'
    ) AS ordinato
FROM products p
GROUP BY productCode
HAVING quantityInStock < ordinato;
-- GROUP BY was just a trick to avoid repeating 'ordinato' computation
SELECT productCode,
    productName,
    quantityInStock,
    (
        SELECT SUM(quantityOrdered)
        FROM orderdetails od
            JOIN orders o USING(orderNumber)
        WHERE od.productCode = p.productCode
            AND o.status = 'In process'
    ) AS ordinato
FROM products p
WHERE quantityInStock < (
        SELECT SUM(quantityOrdered)
        FROM orderdetails od
            JOIN orders o USING(orderNumber)
        WHERE od.productCode = p.productCode
            AND o.status = 'In process'
    );
-- con join
SELECT productCode,
    productName,
    quantityInStock,
    SUM(quantityOrdered) AS ordinato
FROM products p
    JOIN orderdetails od USING(productCode)
    JOIN orders o USING(orderNumber)
WHERE o.status = 'In process'
GROUP BY productCode
HAVING quantityInStock < ordinato;
-- 10 Valore del magazzino (articoli in stock) considerando per ciascun articolo la media tra buyPrice e MSRP.
SELECT SUM(quantityInStock * (buyPrice + MSRP) / 2) AS valore
FROM products p;
-- 11 Elenco degli ordini con gg di lavorazione superiori a 5, indicando il nome del cliente e dell'impiegato referente.
SELECT orderNumber,
    orderDate,
    shippedDate,
    DATEDIFF(shippedDate, orderDate) AS GG,
    customerName,
    CONCAT(lastName, firstName) AS referente
FROM orders
    JOIN customers USING (customerNumber)
    JOIN employees ON (salesRepEmployeeNumber = employeeNumber)
WHERE DATEDIFF(shippedDate, orderDate) > 5;