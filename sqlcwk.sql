/*
@author

This is an sql file to put your queries for SQL coursework. 
You can write your comment in sqlite with -- or /* * /

To read the sql and execute it in the sqlite, simply
type .read sqlcwk.sql on the terminal after sqlite3 chinook.db.
*/

/* =====================================================
   WARNNIG: DO NOT REMOVE THE DROP VIEW
   Dropping existing views if exists
   =====================================================
*/
DROP VIEW IF EXISTS vCustomerPerEmployee;
DROP VIEW IF EXISTS v10WorstSellingGenres ;
DROP VIEW IF EXISTS vBestSellingGenreAlbum ;
DROP VIEW IF EXISTS v10BestSellingArtists;
DROP VIEW IF EXISTS vTopCustomerEachGenre;

/*
============================================================================
Question 1: Complete the query for vCustomerPerEmployee.
WARNNIG: DO NOT REMOVE THE STATEMENT "CREATE VIEW vCustomerPerEmployee AS"
============================================================================
*/
CREATE VIEW vCustomerPerEmployee  AS
SELECT employees.LastName, employees.FirstName, employees.EmployeeID, COUNT(customers.CustomerID) AS TotalCustomer
FROM employees
LEFT JOIN customers ON employees.EmployeeID = customers.SupportRepId
GROUP BY employees.EmployeeID;

/*
============================================================================
Question 2: Complete the query for v10WorstSellingGenres.
WARNNIG: DO NOT REMOVE THE STATEMENT "CREATE VIEW v10WorstSellingGenres AS"
============================================================================
*/
CREATE VIEW v10WorstSellingGenres  AS
SELECT g.Name AS Genre, COALESCE(SUM(ii.Quantity), 0) AS TotalQuantity
FROM genres g
LEFT JOIN tracks t ON g.GenreId = t.GenreId
LEFT JOIN invoice_items ii ON t.TrackId = ii.TrackId
GROUP BY g.GenreId
ORDER BY TotalQuantity ASC
LIMIT 10;

/*
============================================================================
Question 3:
Complete the query for vBestSellingGenreAlbum
WARNNIG: DO NOT REMOVE THE STATEMENT "CREATE VIEW vBestSellingGenreAlbum AS"
============================================================================
*/
CREATE VIEW vBestSellingGenreAlbum AS
SELECT g.Name AS Genre, al.Title AS Album, ar.Name AS Artist, SUM(il.Quantity) AS Sales
FROM invoice_items il
JOIN tracks t ON il.TrackId = t.TrackId
JOIN albums al ON t.AlbumId = al.AlbumId
JOIN artists ar ON al.ArtistId = ar.ArtistId
JOIN genres g ON t.GenreId = g.GenreId
GROUP BY g.Name, al.Title
HAVING SUM(il.Quantity) = (
  SELECT MAX(total_sales)
  FROM (
    SELECT g.Name AS Genre, al.Title AS Album, SUM(il.Quantity) AS total_sales
    FROM invoice_items il
    JOIN tracks t ON il.TrackId = t.TrackId
    JOIN albums al ON t.AlbumId = al.AlbumId
    JOIN genres g ON t.GenreId = g.GenreId
    GROUP BY g.Name, al.Title
  ) AS genre_album_sales
  WHERE g.Name = genre_album_sales.Genre
)
ORDER BY g.Name;




/*
============================================================================
Question 4:
Complete the query for v10BestSellingArtists
WARNNIG: DO NOT REMOVE THE STATEMENT "CREATE VIEW v10BestSellingArtists AS"
============================================================================
*/

CREATE VIEW v10BestSellingArtists AS
SELECT ar.Name AS Artist, COUNT(DISTINCT a.AlbumId) AS TotalAlbum, SUM(ii.Quantity) AS TotalTrackSales
FROM artists ar
JOIN albums a ON ar.ArtistId = a.ArtistId
JOIN tracks t ON a.AlbumId = t.AlbumId
JOIN invoice_items ii ON t.TrackId = ii.TrackId
GROUP BY ar.ArtistId
ORDER BY TotalTrackSales DESC
LIMIT 10;


/*
============================================================================
Question 5:
Complete the query for vTopCustomerEachGenre
WARNNIG: DO NOT REMOVE THE STATEMENT "CREATE VIEW vTopCustomerEachGenre AS" 
============================================================================
*/
CREATE VIEW vTopCustomerEachGenre AS
-- selecting the customers first and last names
-- grouping by the invoice tables to get their total spending per genre
SELECT g.Name AS Genre,
       c.FirstName || ' ' || c.LastName AS Customer,
       SUM(ii.Quantity * ii.UnitPrice) AS TotalSpending
FROM invoices i
INNER JOIN customers c ON i.CustomerId = c.CustomerId
INNER JOIN invoice_items ii ON i.InvoiceId = ii.InvoiceId
INNER JOIN tracks t ON ii.TrackId = t.TrackId
INNER JOIN genres g ON t.GenreId = g.GenreId
GROUP BY g.Name, c.CustomerId
-- the outer query then selects the highest spender per genre
HAVING SUM(ii.Quantity * ii.UnitPrice) = (
    SELECT MAX(TotalSpending) 
    FROM (
        -- join back the subquery to create the final table
        SELECT SUM(ii2.Quantity * ii2.UnitPrice) AS TotalSpending
        FROM invoices i2
        INNER JOIN customers c2 ON i2.CustomerId = c2.CustomerId
        INNER JOIN invoice_items ii2 ON i2.InvoiceId = ii2.InvoiceId
        INNER JOIN tracks t2 ON ii2.TrackId = t2.TrackId
        INNER JOIN genres g2 ON t2.GenreId = g2.GenreId
        WHERE g2.GenreId = g.GenreId
        GROUP BY c2.CustomerId
    ) AS genre_spending
)
ORDER BY g.Name;

/*
To view the created views, use SELECT * FROM views;
You can uncomment the following to look at invididual views created
*/
--SELECT * FROM vCustomerPerEmployee;
--SELECT * FROM v10WorstSellingGenres ;
--SELECT * FROM vBestSellingGenreAlbum ;
--SELECT * FROM v10BestSellingArtists;
--SELECT * FROM vTopCustomerEachGenre;
