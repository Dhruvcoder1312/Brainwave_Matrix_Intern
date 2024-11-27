-- Create the database
CREATE DATABASE IF NOT EXISTS library_Management;
USE library_Management;

-- Create the Books table to manage books in the library
CREATE TABLE IF NOT EXISTS Books (
    BookID INT AUTO_INCREMENT PRIMARY KEY,
    Title VARCHAR(255) NOT NULL,
    Author VARCHAR(255) NOT NULL,
    Genre VARCHAR(100) NOT NULL,
    Published_Year INT NOT NULL,
    Copies_available INT NOT NULL
);

-- Create the Members table to manage library members
CREATE TABLE IF NOT EXISTS Members (
    MemberID INT AUTO_INCREMENT PRIMARY KEY,
    Member_Name VARCHAR(255) NOT NULL,
    Email VARCHAR(255) NOT NULL,
    Phone VARCHAR(20) NOT NULL
);

-- Create the Transactions table to manage borrowing transactions
CREATE TABLE IF NOT EXISTS Transactions (
    TransactionID INT AUTO_INCREMENT PRIMARY KEY,
    MemberID INT,
    BookID INT,
    IssueDate DATE,
    DueDate DATE,
    ReturnDate DATE DEFAULT NULL,
    FOREIGN KEY (MemberID) REFERENCES Members(MemberID),
    FOREIGN KEY (BookID) REFERENCES Books(BookID)
);

-- Create the Fines table to manage fines for overdue books
CREATE TABLE IF NOT EXISTS Fines (
    FineID INT AUTO_INCREMENT PRIMARY KEY,
    TransactionID INT,
    FineAmount DECIMAL(10, 2),
    PaidStatus BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (TransactionID) REFERENCES Transactions(TransactionID)
);
SELECT * FROM Books
SET SQL_SAFE_UPDATES=0
DELETE FROM Books
