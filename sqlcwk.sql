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
--Remove this line and complete your query for question 1 here
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
--Remove this line and complete your query for question 2 here
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
--Remove this line and complete your query for question 3 here
CREATE VIEW vBestSellingGenreAlbum AS
SELECT g.Name AS Genre, a.Title AS Album, ar.Name AS Artist, SUM(il.Quantity) AS Sales
FROM invoice_items il
JOIN tracks t ON il.TrackId = t.TrackId
JOIN albums al ON t.AlbumId = al.AlbumId
JOIN artists ar ON a.ArtistId = ar.ArtistId
JOIN genres g ON t.GenreId = g.GenreId
GROUP BY g.Name, a.Title
HAVING SUM(il.Quantity) = (
  SELECT MAX(total_sales)
  FROM (
    SELECT g.Name AS Genre, a.Title AS Album, SUM(il.Quantity) AS total_sales
    FROM invoice_items il
    JOIN tracks t ON il.TrackId = t.TrackId
    JOIN albums a ON t.AlbumId = a.AlbumId
    JOIN genres g ON t.GenreId = g.GenreId
    GROUP BY g.Name, a.Title
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
--Remove this line and complete your query for question 4 here
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
--Remove this line and complete your query for question 5 here
CREATE VIEW vTopCustomerEachGenre AS
SELECT 
    g.Name AS Genre, 
    c.FirstName || ' ' || c.LastName AS TopSpender, 
    SUM(ii.Quantity * ii.UnitPrice) AS TotalSpending
FROM 
    genres g
    JOIN tracks t ON g.GenreId = t.GenreId
    JOIN invoice_items ii ON t.TrackId = ii.TrackId
    JOIN invoices i ON ii.InvoiceId = i.InvoiceId
    JOIN customers c ON i.CustomerId = c.CustomerId
WHERE 
    (g.GenreId, TotalSpending) IN (
        SELECT 
            g.GenreId, 
            MAX(GenreTotalSpending.TotalSpending) AS MaxTotalSpending
        FROM 
            genres g
            JOIN tracks t ON g.GenreId = t.GenreId
            JOIN invoice_items ii ON t.TrackId = ii.TrackId
            JOIN (
                SELECT 
                    i.InvoiceId, 
                    SUM(ii.Quantity * ii.UnitPrice) AS TotalSpending
                FROM 
                    invoices i
                    JOIN invoice_items ii ON i.InvoiceId = ii.InvoiceId
                GROUP BY 
                    i.InvoiceId
            ) AS GenreTotalSpending ON ii.InvoiceId = GenreTotalSpending.InvoiceId
        GROUP BY 
            g.GenreId
    )
GROUP BY 
    g.GenreId, 
    c.CustomerId;



/*
To view the created views, use SELECT * FROM views;
You can uncomment the following to look at invididual views created
*/
--SELECT * FROM vCustomerPerEmployee;
--SELECT * FROM v10WorstSellingGenres ;
--SELECT * FROM vBestSellingGenreAlbum ;
--SELECT * FROM v10BestSellingArtists;
--SELECT * FROM vTopCustomerEachGenre;
