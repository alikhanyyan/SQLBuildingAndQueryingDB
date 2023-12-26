CREATE DATABASE BookstoreDB;

\c bookstoredb;

CREATE TABLE IF NOT EXISTS Books (
    BookID SERIAL PRIMARY KEY, 
    Title VARCHAR(50) NOT NULL, 
    Author VARCHAR(30), 
    Genre VARCHAR(25), 
    Price FLOAT(2) CHECK(Price >= 0), 
    QuantityInStock INTEGER CHECK(QuantityInStock >= 0)
);

INSERT INTO Books(Title, Author, Genre, Price, QuantityInStock)
    VALUES ('Don Quixote', 'Miguel de Cervantes', 'Action and Adventure', 3.50, 20),
           ('On the Road', 'Jack Kerouac', 'Autobiographical', 4.0, 15),
           ('Alice''s Adventures in Wonderland', 'Lewis Carroll', 'Fantasy', 3.80, 8),
           ('A Tale of Two Cities', 'Charles Dickens', 'Historical', 5.0, 11),
           ('Frankenstein, or, the Modern Prometheus', 'Mary Shelley', 'Horror', 2.90, 10),
           ('The Adventures of Tom Sawyer', 'Mark Twain', 'Action and Adventure', 3.60, 23),
           ('The Complete Sherlock Holmes', 'Arthur Conan Doyle', 'Mystery/Detective', 4.90, 4),
           ('The Hobbit, or, There and Back Again', 'J.R.R. Tolkien', 'Fantasy', 3.0, 9),
           ('The Three Musketeers', 'Alexandre Dumas', 'Historical', 4.50, 17),
           ('Robinson Crusoe', 'Daniel Defoe', 'Action and Adventure', 2.90, 3);

CREATE TABLE IF NOT EXISTS Customers (
    CustomerID SERIAL PRIMARY KEY, 
    Name VARCHAR(30) NOT NULL, 
    Email VARCHAR(50) UNIQUE, 
    Phone VARCHAR(15)
);

INSERT INTO Customers(Name, Email, Phone)
    VALUES ('Cian Gross', 'ciangross@gmail.com', '+1287569430'),
           ('Danyal Cochran', 'danyalcochran@gmail.com', '+7812694587'),
           ('Annabella Blaese', 'annabellablaese@gmail.com', '+37491256848'),
           ('Nicola Simmons', 'nicolasimmons@gmail.com', '+3185236974512'),
           ('Mia Bailey', 'miabailey@gmail.com', '+34975066468');

CREATE TABLE IF NOT EXISTS Sales (
    SaleID SERIAL PRIMARY KEY, 
    BookID INTEGER, 
    CustomerID INTEGER, 
    DateOfSale DATE, 
    QuantitySold INTEGER CHECK(QuantitySold > 0), 
    TotalPrice FLOAT(2) CHECK(TotalPrice >= 0),
    
    FOREIGN KEY (BookID) 
    	REFERENCES Books(BookID) ON DELETE SET NULL,
    FOREIGN KEY (CustomerID) 
    	REFERENCES Customers(CustomerID) ON DELETE SET NULL
);

INSERT INTO Sales(BookID, CustomerID, DateOfSale, QuantitySold, TotalPrice)
    VALUES (1, 4, '2023-01-01', 1, 3.50),
           (9, 3, '2023-08-19', 2, 9.0),
           (5, 2, '2022-11-30', 1, 2.90),
           (7, 1, '2022-12-21', 1, 4.90),
           (2, 3, '2023-10-05', 2, 8.0),
           (10, 3, '2023-10-05', 1, 2.90);

SELECT B.Title AS BookTitle, C.Name AS CustomerName, S.DateOfSale as DateOfSale
FROM Sales S 
	JOIN Books B ON S.BookID = B.BookID
	JOIN Customers C ON S.CustomerID = C.CustomerID;

SELECT B.Genre, COALESCE(ROUND(SUM(S.TotalPrice)::numeric, 2), 0) AS SummaryPrice
FROM Books B 
	LEFT JOIN Sales S ON B.BookID = S.BookID
GROUP BY B.Genre;

CREATE OR REPLACE FUNCTION update_quantity_in_stock()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE Books
    SET QuantityInStock = QuantityInStock - NEW.QuantitySold
    WHERE BookID = NEW.BookID;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_quantity_trigger
AFTER INSERT ON Sales
FOR EACH ROW
EXECUTE FUNCTION update_quantity_in_stock();

