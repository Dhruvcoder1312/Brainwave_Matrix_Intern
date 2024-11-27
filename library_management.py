# Importing necessary libraries and connections
import mysql.connector
from mysql.connector import Error
# Connect to MySQL Database
def create_connection():
    connection = None
    try:
        connection = mysql.connector.connect(
            host='localhost',
            user='root',  # Your MySQL username
            password= input("Enter your password :"),  # Your MySQL password
            database='library_Management'  # Database name
        )
        if connection.is_connected():
            print("Congratulations! You are successfully connected to Database")
    except Error as e:
        print(f"Error: {e}")
    return connection


# Function to insert a new book into the Books table
def insert_book(connection):
    title = input("Enter Book Title: ")
    author = input("Enter Book Author: ")
    genre = input("Enter Book Genre: ")
    year = int(input("Enter Published Year: "))
    copies = int(input("Enter Number of Copies Available: "))

    cursor = connection.cursor()
    query = """
        INSERT INTO Books (Title, Author, Genre, Published_Year, Copies_available)
        VALUES (%s, %s, %s, %s, %s)
    """
    cursor.execute(query, (title, author, genre, year, copies))
    connection.commit()
    print(f"Book '{title}' added successfully.")

# Function to get all books
def get_books(connection):
    cursor = connection.cursor()
    query = "SELECT * FROM Books"
    cursor.execute(query)
    rows = cursor.fetchall()
    print("Books in the library:")
    for row in rows:
        print(row)


# Function to update book details
def update_book_copies(connection):
    book_id = int(input("Enter BookID to Update: "))
    new_copies = int(input("Enter New Number of Copies: "))

    cursor = connection.cursor()
    query = "UPDATE Books SET Copies_available = %s WHERE BookID = %s"
    cursor.execute(query, (new_copies, book_id))
    connection.commit()
    print(f"Updated copies for BookID {book_id}.")


# Function to insert a new member into the Members table
def insert_member(connection):
    name = input("Enter Member Name: ")
    email = input("Enter Member Email: ")
    phone = input("Enter Member Phone: ")

    cursor = connection.cursor()
    query = """
        INSERT INTO Members (Member_Name, Email, Phone)
        VALUES (%s, %s, %s)
    """
    cursor.execute(query, (name, email, phone))
    connection.commit()
    print(f"Member '{name}' added successfully.")


# Function to view members
def get_members(connection):
    cursor = connection.cursor()
    query = "SELECT * FROM Members"
    cursor.execute(query)
    rows = cursor.fetchall()
    print("Library Members:")
    for row in rows:
        print(row)


# Function to borrow a book
def borrow_book(connection):
    member_id = int(input("Enter MemberID: "))
    book_id = int(input("Enter BookID: "))

    cursor = connection.cursor()
    # Check if the book is available for borrowing
    query = "SELECT Copies_available FROM Books WHERE BookID = %s"
    cursor.execute(query, (book_id,))
    copies_available = cursor.fetchone()[0]

    if copies_available > 0:
        issue_date = input("Enter Issue Date (YYYY-MM-DD): ")
        due_date = input("Enter Due Date (YYYY-MM-DD): ")

        # Insert the transaction for borrowing the book
        transaction_query = """
            INSERT INTO Transactions (MemberID, BookID, IssueDate, DueDate)
            VALUES (%s, %s, %s, %s)
        """
        cursor.execute(transaction_query, (member_id, book_id, issue_date, due_date))

        # Update the book availability
        update_query = "UPDATE Books SET Copies_available = %s WHERE BookID = %s"
        cursor.execute(update_query, (copies_available - 1, book_id))
        connection.commit()
        print(f"Book {book_id} borrowed successfully.")
    else:
        print("Sorry, the book is not available for borrowing.")


# Function to return a book
def return_book(connection):
    transaction_id = int(input("Enter TransactionID for returning the book: "))
    return_date = input("Enter Return Date (YYYY-MM-DD): ")

    cursor = connection.cursor()
    # Get the transaction details (issue date and due date)
    query = "SELECT BookID, DueDate FROM Transactions WHERE TransactionID = %s"
    cursor.execute(query, (transaction_id,))
    result = cursor.fetchone()

    if result:
        book_id, due_date = result
        # Calculate the overdue days and fine if any
        overdue_days = (mysql.connector.MYSQLConnection().date(return_date) - mysql.connector.MYSQLConnection().date(
            due_date)).days
        fine_amount = 0
        if overdue_days > 0:
            fine_amount = overdue_days * 2  # Fine is 2 rupees per day

        # Update the return date and fine in the Transactions table
        update_query = "UPDATE Transactions SET ReturnDate = %s WHERE TransactionID = %s"
        cursor.execute(update_query, (return_date, transaction_id))

        # Insert fine details if applicable
        if fine_amount > 0:
            fine_query = """
                INSERT INTO Fines (TransactionID, FineAmount, PaidStatus)
                VALUES (%s, %s, FALSE)
            """
            cursor.execute(fine_query, (transaction_id, fine_amount))

        # Update the book availability
        book_query = "SELECT Copies_available FROM Books WHERE BookID = %s"
        cursor.execute(book_query, (book_id,))
        copies_available = cursor.fetchone()[0]

        # Update book availability after return
        update_book_query = "UPDATE Books SET Copies_available = %s WHERE BookID = %s"
        cursor.execute(update_book_query, (copies_available + 1, book_id))
        connection.commit()
        print(f"Book {book_id} returned successfully.")
    else:
        print("Transaction not found.")


# Function to view fines for a member
def view_fines(connection):
    member_id = int(input("Enter MemberID to view fines: "))
    cursor = connection.cursor()
    query = """
        SELECT t.TransactionID, f.FineAmount, f.PaidStatus 
        FROM Transactions t
        JOIN Fines f ON t.TransactionID = f.TransactionID
        WHERE t.MemberID = %s
    """
    cursor.execute(query, (member_id,))
    rows = cursor.fetchall()
    print(f"Fines for Member {member_id}:")
    for row in rows:
        print(f"TransactionID: {row[0]}, Fine Amount: {row[1]}, Paid Status: {row[2]}")


# Menu to choose different actions
def menu():
    connection = create_connection()
    if connection:
        while True:
            print("\nLibrary Management System")
            print("1. Add a Book")
            print("2. View All Books")
            print("3. Update Book Copies")
            print("4. Add a Member")
            print("5. View All Members")
            print("6. Borrow a Book")
            print("7. Return a Book")
            print("8. View Member Fines")
            print("9. Exit")

            choice = int(input("\nEnter your choice (1-9): "))

            if choice == 1:
                insert_book(connection)
            elif choice == 2:
                get_books(connection)
            elif choice == 3:
                update_book_copies(connection)
            elif choice == 4:
                insert_member(connection)
            elif choice == 5:
                get_members(connection)
            elif choice == 6:
                borrow_book(connection)
            elif choice == 7:
                return_book(connection)
            elif choice == 8:
                view_fines(connection)
            elif choice == 9:
                print("Exiting the system....Thanks for using")
                connection.close()
                break
            else:
                print("Invalid choice. Please select a valid option.")


if __name__ == "__main__":
    menu()
