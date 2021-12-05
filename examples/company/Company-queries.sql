SELECT "USE Company;" AS "Impostazione database di default (per evitare database.table...)";
USE Company;

SELECT "Rich employees (earning more than 99500)" AS Query, "A simple query ... please wait" AS Info;
SELECT *
    FROM employee
    WHERE salary > 99500;

SELECT "Poor employees (earning less than 11500)" AS Query, "A simple query ... please wait" AS Info;
SELECT *
    FROM employee
    WHERE salary < 10500;

SELECT "Number of old employees (more than 30 years)" AS Query, "A simple query ... please wait" AS Info;
SELECT COUNT(*) AS "The old ones are ..."
    FROM employee
    WHERE age > 30;

SELECT "Employees celebrating their birthday today" AS Query, "A simple query ... please wait" AS Info;
SELECT *, "Happy birthday" AS message
    FROM employee
    WHERE MONTH(birthdate) = MONTH(NOW()) AND DAY(birthdate) = DAY(NOW());

-- queste sono per RG ... et alii
SELECT "How many partecipations started in 2006" AS Query, "A simple query (HAVING version)... please wait" AS Info;
SELECT YEAR(start) AS Year, COUNT(*) AS "Started in Year"
    FROM partecipation
    GROUP BY Year
    HAVING Year = 2006;

SELECT "How many partecipations started in 2006" AS Query, "A simple query (WHERE version)... please wait" AS Info;
SELECT YEAR(start) AS Year, COUNT(*) AS "Started in Year"
    FROM partecipation
    WHERE YEAR(start) = 2006;

SELECT "How many partecipations started in 2006" AS Query, "A simple query (WHERE+LIKE version)... please wait" AS Info;
SELECT YEAR(start) AS Year, COUNT(*) AS "Started in Year"
    FROM partecipation
    WHERE start LIKE '2006%';

SELECT "How many partecipations started in 2006" AS Query, "A simple query (WHERE+BETWEEN version)... please wait" AS Info;
SELECT YEAR(start) AS Year, COUNT(*) AS "Started in Year"
    FROM partecipation
    WHERE start BETWEEN '2006-01-01' AND '2006-12-31';

SELECT "How many employees with salary greater than their manager's" AS Query, "A simple query with JOINs... please wait" AS Info;
SELECT COUNT(*) AS 'Earn more than their manager'
    FROM employee e
        JOIN department d ON(e.department = d.name AND e.branch = d.branch)
        JOIN employee m ON(d.manager = m.code)
    WHERE e.salary > m.salary;

SELECT "How much does each department spend in members salary?" AS Query, "A simple query with JOINs... please wait" AS Info;
SELECT d.branch, name, SUM(salary) AS 'Total salary cost', COUNT(*) AS 'N. of employees', AVG(salary) AS 'Average salary'
    FROM department d
        JOIN employee e ON(e.department = d.name AND e.branch = d.branch)
    GROUP BY d.branch, name;

SELECT "Top ten departments by spending in members salary?" AS Query, "A simple query with JOINs... please wait" AS Info;
SELECT d.branch, name, SUM(salary) AS 'Total salary cost', COUNT(*) AS 'N. of employees', AVG(salary) AS 'Average salary'
    FROM department d
        JOIN employee e ON(e.department = d.name AND e.branch = d.branch)
    GROUP BY d.branch, name
    ORDER BY 'Total salary cost' DESC
    LIMIT 10;
-- DOESN'T WORK !!! Expression 'Total salary cost' is a constant !!!
SELECT d.branch, name, SUM(salary) AS 'Total salary cost', COUNT(*) AS 'N. of employees', AVG(salary) AS 'Average salary'
    FROM department d
        JOIN employee e ON(e.department = d.name AND e.branch = d.branch)
    GROUP BY d.branch, name
    ORDER BY `Total salary cost` DESC   -- note the ``
    LIMIT 10;

SELECT "Top ten departments by average member salary?" AS Query, "A simple query with JOINs... please wait" AS Info;
SELECT d.branch, name, SUM(salary) AS 'Total salary cost', COUNT(*) AS 'N. of employees', AVG(salary) AS 'Average salary'
    FROM department d
        JOIN employee e ON(e.department = d.name AND e.branch = d.branch)
    GROUP BY d.branch, name
    ORDER BY `Average salary` DESC   -- note the ``
    LIMIT 10;

