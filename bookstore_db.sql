-- ------------------------------------------------------
-- Bookstore Database Full Setup Script
-- ------------------------------------------------------
-- Sections:
-- 1. Database and Table Creation
-- 2. Initial Data Insertion
-- 3. User and Permission Management
-- 4. Example Test Queries
-- ------------------------------------------------------

-- ------------------------------------------------------
-- Section 1: Database and Table Creation
-- ------------------------------------------------------

-- Create the database (if it doesn't exist)
CREATE DATABASE IF NOT EXISTS bookstore_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Use the newly created database
USE bookstore_db;

-- Table: book_language
CREATE TABLE IF NOT EXISTS book_language (
  language_id INT AUTO_INCREMENT PRIMARY KEY,
  language_code VARCHAR(8) COMMENT 'Standard language code (e.g., en, es, fr)',
  language_name VARCHAR(50) NOT NULL COMMENT 'Name of the language (e.g., English, Spanish)',
  CONSTRAINT uq_language_code UNIQUE (language_code),
  CONSTRAINT uq_language_name UNIQUE (language_name)
) ENGINE=InnoDB COMMENT='List of possible languages for books';

-- Table: publisher
CREATE TABLE IF NOT EXISTS publisher (
  publisher_id INT AUTO_INCREMENT PRIMARY KEY,
  publisher_name VARCHAR(255) NOT NULL COMMENT 'Name of the publisher',
  CONSTRAINT uq_publisher_name UNIQUE (publisher_name)
) ENGINE=InnoDB COMMENT='List of publishers for books';

-- Table: book
CREATE TABLE IF NOT EXISTS book (
  book_id INT AUTO_INCREMENT PRIMARY KEY,
  title VARCHAR(255) NOT NULL COMMENT 'Title of the book',
  isbn13 VARCHAR(13) COMMENT '13-digit ISBN',
  num_pages INT COMMENT 'Number of pages in the book',
  publication_date DATE COMMENT 'Date the book was published',
  price DECIMAL(10, 2) NOT NULL DEFAULT 0.00 COMMENT 'Price of the book',
  language_id INT COMMENT 'Foreign key referencing the language of the book',
  publisher_id INT COMMENT 'Foreign key referencing the publisher of the book',
  CONSTRAINT uq_isbn13 UNIQUE (isbn13),
  CONSTRAINT fk_book_language FOREIGN KEY (language_id) REFERENCES book_language (language_id) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT fk_book_publisher FOREIGN KEY (publisher_id) REFERENCES publisher (publisher_id) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB COMMENT='List of all books available in the store';

-- Table: author
CREATE TABLE IF NOT EXISTS author (
  author_id INT AUTO_INCREMENT PRIMARY KEY,
  author_name VARCHAR(255) NOT NULL COMMENT 'Full name of the author'
) ENGINE=InnoDB COMMENT='List of all authors';

-- Table: book_author (Junction Table)
CREATE TABLE IF NOT EXISTS book_author (
  book_id INT NOT NULL COMMENT 'Foreign key referencing the book',
  author_id INT NOT NULL COMMENT 'Foreign key referencing the author',
  PRIMARY KEY (book_id, author_id), -- Composite primary key
  CONSTRAINT fk_ba_book FOREIGN KEY (book_id) REFERENCES book (book_id) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_ba_author FOREIGN KEY (author_id) REFERENCES author (author_id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB COMMENT='Manages the many-to-many relationship between books and authors';

-- Table: country
CREATE TABLE IF NOT EXISTS country (
  country_id INT AUTO_INCREMENT PRIMARY KEY,
  country_name VARCHAR(100) NOT NULL COMMENT 'Name of the country',
  CONSTRAINT uq_country_name UNIQUE (country_name)
) ENGINE=InnoDB COMMENT='List of countries where addresses are located';

-- Table: address
CREATE TABLE IF NOT EXISTS address (
  address_id INT AUTO_INCREMENT PRIMARY KEY,
  street_number VARCHAR(20) COMMENT 'Street number',
  street_name VARCHAR(200) COMMENT 'Street name',
  address_line2 VARCHAR(200) COMMENT 'Optional second address line (e.g., Apt, Suite)',
  city VARCHAR(100) NOT NULL COMMENT 'City name',
  region VARCHAR(100) COMMENT 'State, Province, or Region',
  postal_code VARCHAR(20) COMMENT 'Postal or Zip code',
  country_id INT NOT NULL COMMENT 'Foreign key referencing the country',
  CONSTRAINT fk_address_country FOREIGN KEY (country_id) REFERENCES country (country_id) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB COMMENT='List of all addresses in the system';

-- Table: Customer
CREATE TABLE IF NOT EXISTS Customer (
  customer_id INT AUTO_INCREMENT PRIMARY KEY,
  first_name VARCHAR(100) NOT NULL COMMENT 'Customer''s first name',
  last_name VARCHAR(100) NOT NULL COMMENT 'Customer''s last name',
  email VARCHAR(255) NOT NULL COMMENT 'Customer''s email address',
  phone VARCHAR(20) COMMENT 'Customer''s phone number',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Timestamp when the customer record was created',
  CONSTRAINT uq_customer_email UNIQUE (email)
) ENGINE=InnoDB COMMENT='List of the bookstore''s customers';

-- Table: address_status
CREATE TABLE IF NOT EXISTS address_status (
  status_id INT AUTO_INCREMENT PRIMARY KEY,
  address_status VARCHAR(20) NOT NULL COMMENT 'Status description (e.g., Current, Old, Billing, Shipping)',
  CONSTRAINT uq_address_status UNIQUE (address_status)
) ENGINE=InnoDB COMMENT='List of statuses for an address';

-- Table: customer_address (Junction Table)
CREATE TABLE IF NOT EXISTS customer_address (
  customer_id INT NOT NULL COMMENT 'Foreign key referencing the customer',
  address_id INT NOT NULL COMMENT 'Foreign key referencing the address',
  status_id INT NOT NULL COMMENT 'Foreign key referencing the status of this address for the customer',
  PRIMARY KEY (customer_id, address_id), -- Composite primary key
  CONSTRAINT fk_ca_customer FOREIGN KEY (customer_id) REFERENCES Customer (customer_id) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_ca_address FOREIGN KEY (address_id) REFERENCES address (address_id) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_ca_status FOREIGN KEY (status_id) REFERENCES address_status (status_id) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB COMMENT='Links customers to their addresses and specifies the status';

-- Table: shipping_method
CREATE TABLE IF NOT EXISTS shipping_method (
  method_id INT AUTO_INCREMENT PRIMARY KEY,
  method_name VARCHAR(100) NOT NULL COMMENT 'Name of the shipping method (e.g., Standard, Express)',
  cost DECIMAL(10, 2) NOT NULL DEFAULT 0.00 COMMENT 'Cost associated with this shipping method'
) ENGINE=InnoDB COMMENT='List of possible shipping methods for an order';

-- Table: order_status
CREATE TABLE IF NOT EXISTS order_status (
  status_id INT AUTO_INCREMENT PRIMARY KEY,
  status_value VARCHAR(50) NOT NULL COMMENT 'Status description (e.g., Pending, Processing, Shipped, Delivered, Cancelled)',
  CONSTRAINT uq_order_status_value UNIQUE (status_value)
) ENGINE=InnoDB COMMENT='List of possible statuses for an order';

-- Table: cust_order
CREATE TABLE IF NOT EXISTS cust_order (
  order_id INT AUTO_INCREMENT PRIMARY KEY,
  order_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Date and time the order was placed',
  customer_id INT COMMENT 'Foreign key referencing the customer who placed the order',
  shipping_method_id INT COMMENT 'Foreign key referencing the chosen shipping method',
  dest_address_id INT COMMENT 'Foreign key referencing the destination address for the order',
  total_order_price DECIMAL(10, 2) COMMENT 'Calculated total price for the order (optional, could be derived)',
  CONSTRAINT fk_cust_order_customer FOREIGN KEY (customer_id) REFERENCES Customer (customer_id) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT fk_cust_order_shipping FOREIGN KEY (shipping_method_id) REFERENCES shipping_method (method_id) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT fk_cust_order_address FOREIGN KEY (dest_address_id) REFERENCES address (address_id) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB COMMENT='List of orders placed by customers';

-- Table: order_line
CREATE TABLE IF NOT EXISTS order_line (
  line_id INT AUTO_INCREMENT PRIMARY KEY,
  order_id INT NOT NULL COMMENT 'Foreign key referencing the order',
  book_id INT NOT NULL COMMENT 'Foreign key referencing the book included in the order',
  price DECIMAL(10, 2) NOT NULL COMMENT 'Price of the book at the time of order',
  quantity INT NOT NULL DEFAULT 1 COMMENT 'Number of copies of this book in the order',
  CONSTRAINT fk_ol_order FOREIGN KEY (order_id) REFERENCES cust_order (order_id) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_ol_book FOREIGN KEY (book_id) REFERENCES book (book_id) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB COMMENT='List of books (lines) that are part of each order';

-- Table: order_history
CREATE TABLE IF NOT EXISTS order_history (
  history_id INT AUTO_INCREMENT PRIMARY KEY,
  order_id INT NOT NULL COMMENT 'Foreign key referencing the order',
  status_id INT NOT NULL COMMENT 'Foreign key referencing the order status',
  status_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Date and time when this status was applied',
  notes VARCHAR(255) COMMENT 'Optional notes regarding this status change',
  CONSTRAINT fk_oh_order FOREIGN KEY (order_id) REFERENCES cust_order (order_id) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_oh_status FOREIGN KEY (status_id) REFERENCES order_status (status_id) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB COMMENT='Record of the status history of an order';


-- ------------------------------------------------------
-- Section 2: Initial Data Insertion
-- ------------------------------------------------------
INSERT INTO book_language (language_code, language_name) VALUES
('en', 'English'),
('es', 'Spanish'),
('fr', 'French')
ON DUPLICATE KEY UPDATE language_name=VALUES(language_name);

INSERT INTO address_status (address_status) VALUES
('Current'),
('Old'),
('Billing'),
('Shipping')
ON DUPLICATE KEY UPDATE address_status=VALUES(address_status);

INSERT INTO order_status (status_value) VALUES
('Pending'),
('Processing'),
('Shipped'),
('Delivered'),
('Cancelled'),
('Returned')
ON DUPLICATE KEY UPDATE status_value=VALUES(status_value);

INSERT INTO shipping_method (method_name, cost) VALUES
('Standard', 5.00),
('Express', 15.00),
('Next Day', 25.00)
ON DUPLICATE KEY UPDATE cost=VALUES(cost);

INSERT INTO country (country_name) VALUES
('United States'),
('Canada'),
('United Kingdom'),
('Kenya')
ON DUPLICATE KEY UPDATE country_name=VALUES(country_name);

-- Add more initial data as needed for authors, publishers, etc.
-- Example:
-- INSERT INTO publisher (publisher_name) VALUES ('Penguin Random House'), ('HarperCollins');
-- INSERT INTO author (author_name) VALUES ('J.K. Rowling'), ('George R.R. Martin');


-- ------------------------------------------------------
-- Section 3: User and Permission Management
-- ------------------------------------------------------
-- Note: Replace 'password' placeholders with strong, unique passwords.

-- Create an Admin User (Full privileges)
CREATE USER IF NOT EXISTS 'bs_admin'@'localhost' IDENTIFIED BY 'admin_password';
GRANT ALL PRIVILEGES ON bookstore_db.* TO 'bs_admin'@'localhost' WITH GRANT OPTION;

-- Create a Staff User (Typical operational privileges)
CREATE USER IF NOT EXISTS 'bs_staff'@'localhost' IDENTIFIED BY 'staff_password';
GRANT SELECT, INSERT, UPDATE ON bookstore_db.Customer TO 'bs_staff'@'localhost';
GRANT SELECT, INSERT, UPDATE ON bookstore_db.cust_order TO 'bs_staff'@'localhost';
GRANT SELECT, INSERT, UPDATE ON bookstore_db.order_line TO 'bs_staff'@'localhost';
GRANT SELECT, INSERT ON bookstore_db.order_history TO 'bs_staff'@'localhost';
GRANT SELECT, UPDATE ON bookstore_db.address TO 'bs_staff'@'localhost';
GRANT SELECT ON bookstore_db.book TO 'bs_staff'@'localhost';
GRANT SELECT ON bookstore_db.author TO 'bs_staff'@'localhost';
GRANT SELECT ON bookstore_db.publisher TO 'bs_staff'@'localhost';
GRANT SELECT ON bookstore_db.shipping_method TO 'bs_staff'@'localhost';
GRANT SELECT ON bookstore_db.order_status TO 'bs_staff'@'localhost';
GRANT SELECT ON bookstore_db.country TO 'bs_staff'@'localhost';
GRANT SELECT ON bookstore_db.address_status TO 'bs_staff'@'localhost';
-- Add other necessary grants based on staff responsibilities

-- Create a Read-Only User (For reporting or analytics)
CREATE USER IF NOT EXISTS 'bs_readonly'@'localhost' IDENTIFIED BY 'readonly_password';
GRANT SELECT ON bookstore_db.* TO 'bs_readonly'@'localhost';

-- Apply Permission Changes
FLUSH PRIVILEGES;


-- ------------------------------------------------------
-- Section 4: Example Test Queries
-- ------------------------------------------------------
-- These are examples. You might run them manually after populating data.
/*

-- 1. Find all books published by a specific publisher (e.g., Publisher ID 1)
SELECT
    b.title, b.isbn13, b.price, p.publisher_name
FROM book b JOIN publisher p ON b.publisher_id = p.publisher_id
WHERE p.publisher_id = 1;

-- 2. Find all books written by a specific author (e.g., Author ID 1)
SELECT
    b.title, b.isbn13, a.author_name
FROM book b JOIN book_author ba ON b.book_id = ba.book_id JOIN author a ON ba.author_id = a.author_id
WHERE a.author_id = 1;

-- 3. List all customers and their 'Current' addresses
SELECT
    c.first_name, c.last_name, c.email, ad.street_number, ad.street_name, ad.city, ad.postal_code, co.country_name
FROM Customer c JOIN customer_address ca ON c.customer_id = ca.customer_id JOIN address ad ON ca.address_id = ad.address_id
JOIN address_status ast ON ca.status_id = ast.status_id JOIN country co ON ad.country_id = co.country_id
WHERE ast.address_status = 'Current';

-- 4. Find all orders placed by a specific customer (e.g., Customer ID 1)
SELECT
    o.order_id, o.order_date, o.total_order_price, sm.method_name AS shipping_method
FROM cust_order o JOIN shipping_method sm ON o.shipping_method_id = sm.method_id
WHERE o.customer_id = 1;

-- 5. List all books included in a specific order (e.g., Order ID 1)
SELECT
    ol.quantity, b.title, ol.price AS price_at_order_time
FROM order_line ol JOIN book b ON ol.book_id = b.book_id
WHERE ol.order_id = 1;

-- 6. Get the most recent status for a specific order (e.g., Order ID 1)
SELECT
    os.status_value, oh.status_date, oh.notes
FROM order_history oh JOIN order_status os ON oh.status_id = os.status_id
WHERE oh.order_id = 1
ORDER BY oh.status_date DESC LIMIT 1;

-- 7. Count the number of books per language
SELECT
    bl.language_name, COUNT(b.book_id) AS number_of_books
FROM book b JOIN book_language bl ON b.language_id = bl.language_id
GROUP BY bl.language_name ORDER BY number_of_books DESC;



