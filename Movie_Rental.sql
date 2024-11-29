CREATE DATABASE Movie_Rental
USE Movie_rental

CREATE TABLE Customers(
CustomerID INT AUTO_INCREMENT PRIMARY KEY,
Customer_Name VARCHAR(50) NOT NULL,
Email VARCHAR(20) UNIQUE NOT NULL,
Phone CHAR(10)
);

CREATE TABLE Movies (
    MovieID INT AUTO_INCREMENT PRIMARY KEY,
    Title VARCHAR(100) NOT NULL,
    Genre VARCHAR(50),
    Stock INT DEFAULT 0,
    RentalPrice DECIMAL(5, 2) NOT NULL
);

CREATE TABLE Rentals (
    RentalID INT AUTO_INCREMENT PRIMARY KEY,
    CustomerID INT,
    MovieID INT,
    RentalDate DATE,
    ReturnDate DATE,
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID),
    FOREIGN KEY (MovieID) REFERENCES Movies(MovieID)
);

CREATE TABLE Payments (
    PaymentID INT AUTO_INCREMENT PRIMARY KEY,
    RentalID INT,
    Amount DECIMAL(6, 2) NOT NULL,
    PaymentDate DATE,
    FOREIGN KEY (RentalID) REFERENCES Rentals(RentalID)
);



INSERT INTO Customers (Customer_Name, Email, Phone) VALUES
('Aman', 'aman@example.com', '9876543210'),
('Bob', 'bob@example.com', '0123456789'),
('Chaman', 'chaman@example.com', '1212121212');

INSERT INTO Movies (Title, Genre, Stock, RentalPrice) VALUES
('3 Idiots', 'Comedy', 5, 3.50),
('Titanic', 'Romance', 3, 2.50),
('Godzilla', 'Action', 7, 4.00);

INSERT INTO Rentals (CustomerID, MovieID, RentalDate, ReturnDate) VALUES
(1, 1, '2024-11-25', '2024-11-27'),
(2, 2, '2024-11-26', NULL),
(3, 3, '2024-11-26', '2024-11-28');

INSERT INTO Payments (RentalID, Amount) VALUES
(1, 7.00),
(3, 8.00);
SELECT * FROM Rentals


-- Basic Queries-----------------------------------------------

-- Listing all customers
SELECT * FROM Customers;

-- Listing all available movies
SELECT * FROM Movies WHERE Stock > 0;

-- Listing all rentals
SELECT * FROM Rentals;

-- Viewing payment history
SELECT * FROM Payments;

-- Intermediate Queries---------------------------------
-- Getting rental details of a specific customer
SELECT r.RentalID, c.Customer_Name, m.Title, r.RentalDate, r.ReturnDate
FROM Rentals r
JOIN Customers c ON r.CustomerID = c.CustomerID
JOIN Movies m ON r.MovieID = m.MovieID
WHERE c.Customer_Name = 'Aman';

-- Finding all overdue rentals (assuming today is '2024-11-28')
SELECT r.RentalID, c.Customer_Name, m.Title, r.RentalDate, r.ReturnDate
FROM Rentals r
JOIN Customers c ON r.CustomerID = c.CustomerID
JOIN Movies m ON r.MovieID = m.MovieID
WHERE r.ReturnDate IS NULL AND r.RentalDate < DATE_SUB(CURDATE(), INTERVAL 3 DAY);

-- Total revenue generated from payments
SELECT SUM(Amount) AS TotalRevenue FROM Payments;

-- Movies with the highest number of rentals
SELECT m.Title, COUNT(r.MovieID) AS RentalCount
FROM Rentals r
JOIN Movies m ON r.MovieID = m.MovieID
GROUP BY m.MovieID
ORDER BY RentalCount DESC
LIMIT 1;

-- Advanced Queries---------------------------------------------------------------
-- Finding customers with no rentals
SELECT c.Customer_Name, c.Email
FROM Customers c
LEFT JOIN Rentals r ON c.CustomerID = r.CustomerID
WHERE r.RentalID IS NULL;

-- Getting the total rentals per genre
SELECT m.Genre, COUNT(r.RentalID) AS TotalRentals
FROM Rentals r
JOIN Movies m ON r.MovieID = m.MovieID
GROUP BY m.Genre;

-- Checking movie stock after all rentals
SELECT m.Title, m.Stock - COUNT(r.MovieID) AS AvailableStock
FROM Movies m
LEFT JOIN Rentals r ON m.MovieID = r.MovieID AND r.ReturnDate IS NULL
GROUP BY m.MovieID;

-- Calculate late fees for overdue rentals (assuming 2 units/day late fees)
SELECT r.RentalID, c.Name, m.Title,
       DATEDIFF(CURDATE(), r.RentalDate) - 3 AS OverdueDays,
       (DATEDIFF(CURDATE(), r.RentalDate) - 3) * 2 AS LateFee
FROM Rentals r
JOIN Customers c ON r.CustomerID = c.CustomerID
JOIN Movies m ON r.MovieID = m.MovieID
WHERE r.ReturnDate IS NULL AND DATEDIFF(CURDATE(), r.RentalDate) > 3;

-- Getting a list of customers with the total amount they have spent
SELECT c.Name, SUM(p.Amount) AS TotalSpent
FROM Customers c
JOIN Rentals r ON c.CustomerID = r.CustomerID
JOIN Payments p ON r.RentalID = p.RentalID
GROUP BY c.CustomerID;


-- Movies not rented by any customer
SELECT m.Title
FROM Movies m
LEFT JOIN Rentals r ON m.MovieID = r.MovieID
WHERE r.RentalID IS NULL;
