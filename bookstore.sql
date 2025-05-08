-- Book Store Database Management System
-- Created: May 7, 2025

-- Drop database if it exists and create a new one
DROP DATABASE IF EXISTS bookstore;
CREATE DATABASE bookstore;
USE bookstore;

-- Authors table
CREATE TABLE authors (
    author_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    birth_date DATE,
    country VARCHAR(50),
    biography TEXT,
    date_added TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_author_name UNIQUE (first_name, last_name)
);

-- Publishers table
CREATE TABLE publishers (
    publisher_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    address TEXT,
    phone VARCHAR(20),
    email VARCHAR(100),
    website VARCHAR(255),
    contact_person VARCHAR(100),
    date_added TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Categories table
CREATE TABLE categories (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    parent_category_id INT,
    date_added TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (parent_category_id) REFERENCES categories(category_id) ON DELETE SET NULL
);

-- Books table
CREATE TABLE books (
    book_id INT AUTO_INCREMENT PRIMARY KEY,
    isbn VARCHAR(20) NOT NULL UNIQUE,
    title VARCHAR(255) NOT NULL,
    publisher_id INT,
    publication_date DATE,
    edition VARCHAR(20),
    language VARCHAR(30) DEFAULT 'English',
    page_count INT,
    description TEXT,
    cover_image VARCHAR(255),
    price DECIMAL(10, 2) NOT NULL,
    stock_quantity INT NOT NULL DEFAULT 0,
    is_featured BOOLEAN DEFAULT FALSE,
    date_added TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (publisher_id) REFERENCES publishers(publisher_id) ON DELETE SET NULL,
    CHECK (price >= 0),
    CHECK (stock_quantity >= 0)
);

-- Book-Author relationship (Many-to-Many)
CREATE TABLE book_authors (
    book_id INT,
    author_id INT,
    role VARCHAR(50) DEFAULT 'Author', -- Author, Co-author, Editor, etc.
    PRIMARY KEY (book_id, author_id),
    FOREIGN KEY (book_id) REFERENCES books(book_id) ON DELETE CASCADE,
    FOREIGN KEY (author_id) REFERENCES authors(author_id) ON DELETE CASCADE
);

-- Book-Category relationship (Many-to-Many)
CREATE TABLE book_categories (
    book_id INT,
    category_id INT,
    PRIMARY KEY (book_id, category_id),
    FOREIGN KEY (book_id) REFERENCES books(book_id) ON DELETE CASCADE,
    FOREIGN KEY (category_id) REFERENCES categories(category_id) ON DELETE CASCADE
);

-- Customers table
CREATE TABLE customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone VARCHAR(20),
    address TEXT,
    city VARCHAR(50),
    state VARCHAR(50),
    postal_code VARCHAR(20),
    country VARCHAR(50),
    date_registered TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_member BOOLEAN DEFAULT FALSE,
    points INT DEFAULT 0,
    CHECK (points >= 0)
);

-- Employees table
CREATE TABLE employees (
    employee_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone VARCHAR(20),
    address TEXT,
    position VARCHAR(50) NOT NULL,
    salary DECIMAL(10, 2),
    hire_date DATE NOT NULL,
    manager_id INT,
    FOREIGN KEY (manager_id) REFERENCES employees(employee_id) ON DELETE SET NULL
);

-- Orders table
CREATE TABLE orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT,
    employee_id INT,
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    required_date DATE,
    shipped_date DATE,
    status ENUM('Pending', 'Processing', 'Shipped', 'Delivered', 'Cancelled') DEFAULT 'Pending',
    payment_method ENUM('Credit Card', 'Debit Card', 'Cash', 'PayPal', 'Bank Transfer'),
    tracking_number VARCHAR(50),
    shipping_fee DECIMAL(10, 2) DEFAULT 0.00,
    total_amount DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id) ON DELETE SET NULL,
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id) ON DELETE SET NULL,
    CHECK (shipping_fee >= 0),
    CHECK (total_amount >= 0)
);

-- Order Details table
CREATE TABLE order_details (
    order_id INT,
    book_id INT,
    quantity INT NOT NULL,
    unit_price DECIMAL(10, 2) NOT NULL,
    discount DECIMAL(5, 2) DEFAULT 0.00,
    PRIMARY KEY (order_id, book_id),
    FOREIGN KEY (order_id) REFERENCES orders(order_id) ON DELETE CASCADE,
    FOREIGN KEY (book_id) REFERENCES books(book_id) ON DELETE CASCADE,
    CHECK (quantity > 0),
    CHECK (unit_price >= 0),
    CHECK (discount >= 0 AND discount <= 100)
);

-- Suppliers table
CREATE TABLE suppliers (
    supplier_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    contact_person VARCHAR(100),
    email VARCHAR(100),
    phone VARCHAR(20),
    address TEXT,
    city VARCHAR(50),
    country VARCHAR(50),
    date_added TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Purchases (from suppliers) table
CREATE TABLE purchases (
    purchase_id INT AUTO_INCREMENT PRIMARY KEY,
    supplier_id INT,
    employee_id INT,
    purchase_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status ENUM('Ordered', 'Received', 'Pending', 'Cancelled') DEFAULT 'Ordered',
    total_amount DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (supplier_id) REFERENCES suppliers(supplier_id) ON DELETE SET NULL,
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id) ON DELETE SET NULL,
    CHECK (total_amount >= 0)
);

-- Purchase Details table
CREATE TABLE purchase_details (
    purchase_id INT,
    book_id INT,
    quantity INT NOT NULL,
    unit_cost DECIMAL(10, 2) NOT NULL,
    PRIMARY KEY (purchase_id, book_id),
    FOREIGN KEY (purchase_id) REFERENCES purchases(purchase_id) ON DELETE CASCADE,
    FOREIGN KEY (book_id) REFERENCES books(book_id) ON DELETE CASCADE,
    CHECK (quantity > 0),
    CHECK (unit_cost >= 0)
);

-- Promotions table
CREATE TABLE promotions (
    promotion_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    discount_rate DECIMAL(5, 2) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    min_purchase DECIMAL(10, 2) DEFAULT 0.00,
    CHECK (discount_rate > 0 AND discount_rate <= 100),
    CHECK (end_date >= start_date),
    CHECK (min_purchase >= 0)
);

-- Book-Promotion relationship (Many-to-Many)
CREATE TABLE book_promotions (
    book_id INT,
    promotion_id INT,
    PRIMARY KEY (book_id, promotion_id),
    FOREIGN KEY (book_id) REFERENCES books(book_id) ON DELETE CASCADE,
    FOREIGN KEY (promotion_id) REFERENCES promotions(promotion_id) ON DELETE CASCADE
);

-- Reviews table
CREATE TABLE reviews (
    review_id INT AUTO_INCREMENT PRIMARY KEY,
    book_id INT,
    customer_id INT,
    rating INT NOT NULL,
    review_text TEXT,
    review_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_verified BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (book_id) REFERENCES books(book_id) ON DELETE CASCADE,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id) ON DELETE CASCADE,
    CHECK (rating >= 1 AND rating <= 5)
);

-- Wishlist table
CREATE TABLE wishlists (
    wishlist_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT,
    name VARCHAR(100) DEFAULT 'My Wishlist',
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_public BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id) ON DELETE CASCADE
);

-- Wishlist-Book relationship (Many-to-Many)
CREATE TABLE wishlist_books (
    wishlist_id INT,
    book_id INT,
    date_added TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    notes TEXT,
    PRIMARY KEY (wishlist_id, book_id),
    FOREIGN KEY (wishlist_id) REFERENCES wishlists(wishlist_id) ON DELETE CASCADE,
    FOREIGN KEY (book_id) REFERENCES books(book_id) ON DELETE CASCADE
);

-- Store Locations table
CREATE TABLE store_locations (
    location_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    address TEXT NOT NULL,
    city VARCHAR(50) NOT NULL,
    state VARCHAR(50),
    postal_code VARCHAR(20) NOT NULL,
    country VARCHAR(50) NOT NULL,
    phone VARCHAR(20),
    email VARCHAR(100),
    manager_id INT,
    opening_hours TEXT,
    FOREIGN KEY (manager_id) REFERENCES employees(employee_id) ON DELETE SET NULL
);

-- Store Inventory table
CREATE TABLE store_inventory (
    location_id INT,
    book_id INT,
    quantity INT NOT NULL DEFAULT 0,
    shelf_location VARCHAR(50),
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (location_id, book_id),
    FOREIGN KEY (location_id) REFERENCES store_locations(location_id) ON DELETE CASCADE,
    FOREIGN KEY (book_id) REFERENCES books(book_id) ON DELETE CASCADE,
    CHECK (quantity >= 0)
);

-- Gift Cards table
CREATE TABLE gift_cards (
    card_number VARCHAR(50) PRIMARY KEY,
    initial_amount DECIMAL(10, 2) NOT NULL,
    current_balance DECIMAL(10, 2) NOT NULL,
    issue_date DATE NOT NULL,
    expiry_date DATE,
    is_active BOOLEAN DEFAULT TRUE,
    customer_id INT,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id) ON DELETE SET NULL,
    CHECK (initial_amount > 0),
    CHECK (current_balance >= 0),
    CHECK (expiry_date > issue_date)
);

-- Events table
CREATE TABLE events (
    event_id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(100) NOT NULL,
    description TEXT,
    event_date DATE NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME,
    location_id INT,
    capacity INT,
    registration_required BOOLEAN DEFAULT FALSE,
    contact_email VARCHAR(100),
    contact_phone VARCHAR(20),
    FOREIGN KEY (location_id) REFERENCES store_locations(location_id) ON DELETE SET NULL,
    CHECK (capacity > 0),
    CHECK (end_time > start_time)
);

-- Event Registrations table
CREATE TABLE event_registrations (
    event_id INT,
    customer_id INT,
    registration_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    attendance_status ENUM('Registered', 'Attended', 'Cancelled', 'No-show') DEFAULT 'Registered',
    notes TEXT,
    PRIMARY KEY (event_id, customer_id),
    FOREIGN KEY (event_id) REFERENCES events(event_id) ON DELETE CASCADE,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id) ON DELETE CASCADE
);


-- Sample Data for South African Bookstore Database

-- Authors (South African authors)
INSERT INTO authors (first_name, last_name, birth_date, country, biography) VALUES
('Deon', 'Meyer', '1958-07-04', 'South Africa', 'Deon Meyer is a South African crime fiction author and screenwriter, known for his detective novels featuring characters like Benny Griessel.'),
('Nadine', 'Gordimer', '1923-11-20', 'South Africa', 'Nadine Gordimer was a South African writer and political activist who received the Nobel Prize for Literature in 1991. Her works dealt with moral and racial issues in South Africa during apartheid.'),
('J.M.', 'Coetzee', '1940-02-09', 'South Africa', 'John Maxwell Coetzee is a South African-Australian novelist, essayist, and translator. He won the Nobel Prize in Literature in 2003 and is known for works like "Disgrace" and "Life & Times of Michael K".'),
('Zakes', 'Mda', '1948-10-06', 'South Africa', 'Zanemvula Kizito Gatyeni Mda is a South African novelist, poet, and playwright known for works like "Ways of Dying" and "The Heart of Redness".'),
('Lauren', 'Beukes', '1976-06-05', 'South Africa', 'Lauren Beukes is a South African novelist, short story writer, and journalist known for her blend of science fiction, horror, and thriller genres.'),
('Wilbur', 'Smith', '1933-01-09', 'Zambia (raised in South Africa)', 'Wilbur Smith was a South African novelist specializing in historical fiction about Southern Africa across different time periods.'),
('Kopano', 'Matlwa', '1985-11-01', 'South Africa', 'Kopano Matlwa is a South African medical doctor and author known for her novels "Coconut" and "Spilt Milk", which explore post-apartheid South Africa.'),
('Njabulo', 'Ndebele', '1948-07-08', 'South Africa', 'Njabulo Simakahle Ndebele is a South African writer, academic, and former university administrator known for his critical essays and fiction.'),
('Sindiwe', 'Magona', '1943-08-23', 'South Africa', 'Sindiwe Magona is a South African author, poet, and playwright known for her autobiographical works and stories about the struggles of black women in South Africa.'),
('Achmat', 'Dangor', '1948-10-02', 'South Africa', 'Achmat Dangor was a South African writer and anti-apartheid activist whose work often deals with the complexities of racial identity and sexuality.');

-- Publishers (South African publishers)
INSERT INTO publishers (name, address, phone, email, website, contact_person) VALUES
('NB Publishers', '40 Heerengracht, Cape Town, 8001', '+27 21 406 3033', 'info@nbpublishers.com', 'www.nbpublishers.com', 'Johan Olivier'),
('Jonathan Ball Publishers', 'PO Box 33977, Jeppestown, 2043', '+27 11 601 8000', 'info@jonathanball.co.za', 'www.jonathanball.co.za', 'Sarah Johnson'),
('Jacana Media', '10 Orange Street, Auckland Park, Johannesburg, 2092', '+27 11 628 3200', 'sales@jacana.co.za', 'www.jacana.co.za', 'Maggie Peters'),
('Kwela Books', '40 Heerengracht, Cape Town, 8001', '+27 21 406 3033', 'info@kwela.com', 'www.kwela.com', 'Nadia Goetham'),
('Umuzi', '40 Heerengracht, Cape Town, 8001', '+27 21 406 3033', 'info@umuzi.co.za', 'www.umuzi.co.za', 'Fourie Botha'),
('Pan Macmillan South Africa', '34 Whiteley Road, Melrose Arch, Johannesburg, 2076', '+27 11 325 5220', 'info@panmacmillan.co.za', 'www.panmacmillan.co.za', 'Terry Morris'),
('LAPA Publishers', '380 Bosman Street, Pretoria, 0001', '+27 12 401 0700', 'info@lapa.co.za', 'www.lapa.co.za', 'Danie van Wyk'),
('Protea Book House', '1067 Burnett Street, Hatfield, Pretoria, 0083', '+27 12 362 5683', 'info@proteaboekhuis.co.za', 'www.proteaboekhuis.co.za', 'Etienne Bloemhof');

-- Categories
INSERT INTO categories (name, description) VALUES
('South African Fiction', 'Fiction written by South African authors or set in South Africa'),
('African Literature', 'Literature from across the African continent'),
('Crime and Thriller', 'Mystery, crime and thriller novels'),
('Historical Fiction', 'Novels set in historical periods'),
('Poetry', 'Collections of poems and verse'),
('Non-Fiction', 'Factual works including biography, history, politics'),
('SA Politics', 'Books about South African politics and history'),
('Afrikaans Literature', 'Books written in Afrikaans'),
('Local Biography', 'Biographies of South African personalities'),
('Indigenous Languages', 'Books in South African indigenous languages like Zulu, Xhosa, etc.');

-- Set up parent-child relationships for categories
UPDATE categories SET parent_category_id = 2 WHERE name = 'South African Fiction';
UPDATE categories SET parent_category_id = 6 WHERE name = 'SA Politics';
UPDATE categories SET parent_category_id = 6 WHERE name = 'Local Biography';

-- Books
INSERT INTO books (isbn, title, publisher_id, publication_date, edition, language, page_count, description, price, stock_quantity, is_featured) VALUES
('9780340953570', 'Blood Safari', 4, '2009-09-01', '1st', 'English', 384, 'Lemmer is a professional bodyguard in South Africa with a secret past. When he is hired to protect a wealthy woman investigating her missing brother, they uncover a conspiracy that puts them both in danger.', 275.00, 45, TRUE),
('9780143538417', 'Coconut', 1, '2017-06-15', '2nd', 'English', 224, 'Coconut explores what it means to be black in contemporary South Africa, following two young women navigating identity in a post-apartheid world.', 220.00, 30, FALSE),
('9780099540489', 'Disgrace', 3, '1999-11-02', '1st', 'English', 220, 'Set in post-apartheid South Africa, the novel follows a middle-aged professor whose career and reputation are destroyed when he has an affair with a student.', 195.00, 25, TRUE),
('9780062292070', 'The Shining Girls', 6, '2013-04-25', '1st', 'English', 384, 'A time-traveling serial killer is impossible to track, until one of his victims survives. Set partly in South Africa.', 310.00, 18, FALSE),
('9781415203910', 'Ways of Dying', 5, '2007-08-01', 'Reprint', 'English', 212, 'Set in a South African township during the transition from apartheid, the novel follows Toloki, a professional mourner who creates a new identity and purpose for himself.', 185.00, 22, FALSE),
('9780330376310', 'The Heart of Redness', 5, '2003-08-01', '1st', 'English', 277, 'Explores the history of the Xhosa cattle-killing and its impact on contemporary South Africa.', 205.00, 15, FALSE),
('9780062467508', 'Born a Crime', 6, '2016-11-15', '1st', 'English', 304, 'Trevor Noah\'s autobiographical book about growing up in South Africa during the apartheid era.', 290.00, 50, TRUE),
('9780795704932', 'Hunger Eats a Man', 7, '2014-09-01', '1st', 'English', 208, 'Set in the fictional village of Ndimande in rural KwaZulu-Natal, this novel examines poverty and inequality in contemporary South Africa.', 195.00, 12, FALSE),
('9780795708886', 'Oorlog en Terpentyn', 8, '2019-05-01', '1st', 'Afrikaans', 240, 'An Afrikaans novel exploring themes of war, art, and family history across generations in South Africa.', 230.00, 20, FALSE),
('9781415209141', 'Die Aanspraak van Lewende Wesens', 4, '2012-08-01', '1st', 'Afrikaans', 308, 'An Afrikaans novel by acclaimed author Ingrid Winterbach, exploring themes of loss and connection.', 240.00, 15, FALSE),
('9780624046622', 'Piece of Mind', 7, '2017-03-01', '1st', 'English', 224, 'A collection of essays reflecting on South African society and politics.', 185.00, 18, FALSE),
('9780795704789', 'Thirteen Cents', 4, '2013-08-01', 'Reprint', 'English', 176, 'A gritty coming-of-age novel set in Cape Town following a young orphan named Azure.', 170.00, 22, FALSE),
('9780795708497', 'Zoo City', 3, '2010-09-01', '1st', 'English', 384, 'An urban fantasy novel set in a dystopian Johannesburg where criminals are magically attached to animals.', 260.00, 35, TRUE),
('9780143027904', 'Long Walk to Freedom', 2, '1995-12-01', '1st', 'English', 630, 'Nelson Mandela\'s autobiography detailing his early life, education, and 27 years in prison.', 350.00, 60, TRUE);

-- Book-Author relationships
INSERT INTO book_authors (book_id, author_id, role) VALUES
(1, 1, 'Author'),
(2, 7, 'Author'),
(3, 3, 'Author'),
(4, 5, 'Author'),
(5, 4, 'Author'),
(6, 4, 'Author'),
(7, 1, 'Author'),
(8, 9, 'Author'),
(9, 10, 'Author'),
(10, 2, 'Author'),
(11, 8, 'Author'),
(12, 4, 'Author'),
(13, 5, 'Author'),
(14, 6, 'Author');

-- Book-Category relationships
INSERT INTO book_categories (book_id, category_id) VALUES
(1, 3), (1, 1),
(2, 1), (2, 2),
(3, 1), (3, 2),
(4, 3), (4, 1),
(5, 1), (5, 2),
(6, 1), (6, 4),
(7, 6), (7, 9),
(8, 1), (8, 2),
(9, 8),
(10, 8),
(11, 6), (11, 7),
(12, 1), (12, 2),
(13, 1), (13, 3),
(14, 6), (14, 9);

-- Customers (South African)
INSERT INTO customers (first_name, last_name, email, phone, address, city, state, postal_code, country, is_member, points) VALUES
('Thabo', 'Mbeki', 'thabo.m@example.co.za', '+27 82 123 4567', '45 Main Road', 'Cape Town', 'Western Cape', '8001', 'South Africa', TRUE, 150),
('Siphokazi', 'Ndlovu', 'siphokazi@example.co.za', '+27 71 234 5678', '12 Long Street', 'Johannesburg', 'Gauteng', '2001', 'South Africa', TRUE, 75),
('Johan', 'van der Merwe', 'johan@example.co.za', '+27 83 345 6789', '78 Beach Road', 'Durban', 'KwaZulu-Natal', '4001', 'South Africa', FALSE, 0),
('Zinhle', 'Dlamini', 'zinhle.d@example.co.za', '+27 76 456 7890', '23 Church Street', 'Pretoria', 'Gauteng', '0002', 'South Africa', TRUE, 210),
('Pieter', 'Venter', 'pieter@example.co.za', '+27 84 567 8901', '56 Park Avenue', 'Bloemfontein', 'Free State', '9301', 'South Africa', FALSE, 0),
('Nomsa', 'Khumalo', 'nomsa.k@example.co.za', '+27 73 678 9012', '34 Nelson Mandela Drive', 'Port Elizabeth', 'Eastern Cape', '6001', 'South Africa', TRUE, 95),
('Riaan', 'Oosthuizen', 'riaan@example.co.za', '+27 82 789 0123', '89 Adderley Street', 'Stellenbosch', 'Western Cape', '7600', 'South Africa', TRUE, 180),
('Lerato', 'Molefe', 'lerato@example.co.za', '+27 71 890 1234', '67 Main Road', 'Kimberley', 'Northern Cape', '8301', 'South Africa', FALSE, 0),
('Willem', 'du Plessis', 'willem@example.co.za', '+27 83 901 2345', '12 Church Street', 'George', 'Western Cape', '6530', 'South Africa', TRUE, 120),
('Thandi', 'Nkosi', 'thandi.n@example.co.za', '+27 76 012 3456', '45 Beach Road', 'East London', 'Eastern Cape', '5201', 'South Africa', TRUE, 65);

-- Employees (South African)
INSERT INTO employees (first_name, last_name, email, phone, address, position, salary, hire_date) VALUES
('Sibusiso', 'Tshabalala', 'sibusiso@sabookstore.co.za', '+27 82 111 2222', '23 Main Road, Cape Town', 'Store Manager', 45000.00, '2021-05-10'),
('Anele', 'Mkhize', 'anele@sabookstore.co.za', '+27 71 222 3333', '45 Long Street, Cape Town', 'Assistant Manager', 32000.00, '2021-08-15'),
('Gerhard', 'Bezuidenhout', 'gerhard@sabookstore.co.za', '+27 83 333 4444', '67 Beach Road, Cape Town', 'Senior Bookseller', 25000.00, '2022-01-20'),
('Precious', 'Ngwenya', 'precious@sabookstore.co.za', '+27 76 444 5555', '89 Church Street, Cape Town', 'Bookseller', 18000.00, '2022-06-05'),
('Jan', 'Visagie', 'jan@sabookstore.co.za', '+27 84 555 6666', '12 Park Avenue, Cape Town', 'Bookseller', 18000.00, '2022-09-10'),
('Nosipho', 'Radebe', 'nosipho@sabookstore.co.za', '+27 73 666 7777', '34 Loop Street, Cape Town', 'Cashier', 16000.00, '2023-03-15'),
('Francois', 'le Roux', 'francois@sabookstore.co.za', '+27 82 777 8888', '56 Kloof Street, Cape Town', 'Warehouse Manager', 28000.00, '2021-10-01'),
('Buhle', 'Mazibuko', 'buhle@sabookstore.co.za', '+27 71 888 9999', '78 Bree Street, Cape Town', 'Events Coordinator', 22000.00, '2022-11-15'),
('Hendrik', 'Botha', 'hendrik@sabookstore.co.za', '+27 83 999 0000', '90 Orange Street, Cape Town', 'IT Specialist', 35000.00, '2023-02-01'),
('Naledi', 'Mokoena', 'naledi@sabookstore.co.za', '+27 76 000 1111', '11 Rose Street, Cape Town', 'Marketing Specialist', 30000.00, '2023-05-20');

-- Set managers
UPDATE employees SET manager_id = 1 WHERE employee_id IN (2, 7, 8, 9, 10);
UPDATE employees SET manager_id = 2 WHERE employee_id IN (3, 4, 5, 6);

-- Store Locations (South African cities)
INSERT INTO store_locations (name, address, city, state, postal_code, country, phone, email, manager_id, opening_hours) VALUES
('Cape Town Central', '45 Long Street', 'Cape Town', 'Western Cape', '8001', 'South Africa', '+27 21 123 4567', 'capetown@sabookstore.co.za', 1, 'Mon-Fri: 09:00-18:00, Sat: 09:00-16:00, Sun: 10:00-14:00'),
('Johannesburg Sandton', '15 Rivonia Road, Sandton', 'Johannesburg', 'Gauteng', '2196', 'South Africa', '+27 11 234 5678', 'sandton@sabookstore.co.za', 2, 'Mon-Fri: 09:00-19:00, Sat: 09:00-17:00, Sun: 10:00-15:00'),
('Durban Umhlanga', '45 Palm Boulevard, Umhlanga', 'Durban', 'KwaZulu-Natal', '4320', 'South Africa', '+27 31 345 6789', 'durban@sabookstore.co.za', 3, 'Mon-Fri: 09:00-18:00, Sat: 09:00-16:00, Sun: 10:00-14:00'),
('Pretoria Brooklyn', '56 Duxbury Road, Brooklyn', 'Pretoria', 'Gauteng', '0181', 'South Africa', '+27 12 456 7890', 'pretoria@sabookstore.co.za', 4, 'Mon-Fri: 08:30-17:30, Sat: 09:00-15:00, Sun: Closed');

-- Store Inventory
INSERT INTO store_inventory (location_id, book_id, quantity, shelf_location) VALUES
(1, 1, 15, 'A3-12'),
(1, 2, 10, 'B2-05'),
(1, 3, 8, 'A1-07'),
(1, 4, 6, 'C4-09'),
(1, 7, 20, 'D1-01'),
(1, 13, 12, 'B3-15'),
(1, 14, 18, 'D2-03'),
(2, 1, 12, 'A2-10'),
(2, 3, 7, 'A1-05'),
(2, 5, 9, 'B1-08'),
(2, 7, 15, 'D1-02'),
(2, 11, 8, 'C2-11'),
(2, 14, 22, 'D2-01'),
(3, 2, 10, 'B2-07'),
(3, 4, 5, 'C4-08'),
(3, 6, 7, 'B1-09'),
(3, 8, 6, 'A3-14'),
(3, 12, 8, 'C1-06'),
(3, 14, 12, 'D2-02'),
(4, 1, 8, 'A3-11'),
(4, 3, 5, 'A1-06'),
(4, 7, 10, 'D1-03'),
(4, 9, 12, 'B4-12'),
(4, 10, 15, 'B4-13'),
(4, 14, 8, 'D2-04');

-- Suppliers (South African)
INSERT INTO suppliers (name, contact_person, email, phone, address, city, country) VALUES
('SA Book Distributors', 'Themba Ncube', 'themba@sabookdist.co.za', '+27 11 987 6543', '123 Main Road', 'Johannesburg', 'South Africa'),
('Cape Publishing Supplies', 'Michelle van Rooyen', 'michelle@cps.co.za', '+27 21 876 5432', '45 Beach Road', 'Cape Town', 'South Africa'),
('KZN Book Wholesalers', 'Sipho Zulu', 'sipho@kznbooks.co.za', '+27 31 765 4321', '67 Smith Street', 'Durban', 'South Africa'),
('Gauteng Literature Supplies', 'Annika Pretorius', 'annika@gls.co.za', '+27 12 654 3210', '89 Church Street', 'Pretoria', 'South Africa');

-- Purchases from suppliers
INSERT INTO purchases (supplier_id, employee_id, purchase_date, status, total_amount) VALUES
(1, 7, '2025-04-10', 'Received', 15000.00),
(2, 7, '2025-04-15', 'Received', 12500.00),
(3, 7, '2025-04-20', 'Ordered', 18000.00),
(4, 7, '2025-04-25', 'Pending', 9500.00);

-- Purchase Details
INSERT INTO purchase_details (purchase_id, book_id, quantity, unit_cost) VALUES
(1, 1, 20, 165.00),
(1, 3, 15, 115.00),
(1, 7, 25, 175.00),
(2, 2, 15, 130.00),
(2, 4, 10, 180.00),
(2, 13, 20, 155.00),
(3, 5, 15, 110.00),
(3, 6, 12, 125.00),
(3, 14, 30, 210.00),
(4, 8, 10, 115.00),
(4, 9, 15, 140.00),
(4, 10, 15, 145.00);

-- Promotions
INSERT INTO promotions (name, description, discount_rate, start_date, end_date, is_active, min_purchase) VALUES
('Freedom Day Sale', 'Special discounts to celebrate South African Freedom Day', 15.00, '2025-04-20', '2025-04-27', TRUE, 200.00),
('Mandela Day Specials', 'Discounts in honor of Nelson Mandela Day', 18.00, '2025-07-10', '2025-07-18', FALSE, 250.00),
('Heritage Month Promotion', 'Celebrating South African authors during Heritage Month', 20.00, '2025-09-01', '2025-09-30', FALSE, 300.00),
('Summer Reading Challenge', 'Special offers to promote summer reading', 10.00, '2025-12-01', '2026-01-15', FALSE, 150.00);

-- Book-Promotion relationships
INSERT INTO book_promotions (book_id, promotion_id) VALUES
(1, 1), (3, 1), (7, 1), (14, 1),
(3, 2), (7, 2), (13, 2), (14, 2),
(1, 3), (2, 3), (3, 3), (4, 3), (5, 3), (6, 3), (7, 3), (8, 3), (13, 3),
(1, 4), (4, 4), (7, 4), (13, 4);

-- Reviews
INSERT INTO reviews (book_id, customer_id, rating, review_text, is_verified) VALUES
(1, 1, 5, 'One of the best thrillers set in South Africa I\'ve ever read. Meyer\'s portrayal of the South African landscape is vivid and captivating.', TRUE),
(3, 2, 4, 'A thought-provoking narrative that captures post-apartheid tensions beautifully.', TRUE),
(7, 3, 5, 'Trevor Noah\'s storytelling is hilarious yet profound. A must-read for understanding apartheid-era South Africa through a personal lens.', TRUE),
(14, 4, 5, 'Mandela\'s autobiography is inspiring and enlightening. Every South African should read this important piece of our history.', TRUE),
(2, 5, 3, 'Interesting perspective on identity in post-apartheid South Africa, though I found some parts difficult to relate to.', FALSE),
(13, 6, 4, 'A brilliant blend of fantasy and South African urban reality. Beukes creates a Johannesburg like you\'ve never seen before.', TRUE),
(4, 7, 4, 'The time-travel element mixed with South African settings makes for a unique thriller.', TRUE),
(3, 8, 5, 'Coetzee\'s masterpiece - raw, unflinching, and honest about our complex society.', FALSE),
(7, 9, 5, 'This book made me laugh and cry. Noah captures the South African experience so well.', TRUE),
(14, 10, 5, 'A profound and moving account of Madiba\'s life and struggle. Essential reading for everyone.', TRUE);

-- Wishlists
INSERT INTO wishlists (customer_id, name, is_public) VALUES
(1, 'SA Crime Novels', TRUE),
(2, 'Post-Apartheid Literature', FALSE),
(4, 'My Reading List 2025', TRUE),
(6, 'South African Women Writers', TRUE),
(7, 'Afrikaans Boeke', FALSE);

-- Wishlist Books
INSERT INTO wishlist_books (wishlist_id, book_id, notes) VALUES
(1, 1, 'Heard great things about Meyer\'s writing'),
(1, 4, 'Want to try Beukes next'),
(1, 13, 'Another thriller to check out'),
(2, 2, NULL),
(2, 3, 'Recommended by book club'),
(2, 5, NULL),
(2, 6, 'Historical fiction about Xhosa history'),
(2, 8, 'Contemporary South African village life'),
(3, 7, 'Need to read this soon'),
(3, 13, 'Sounds fascinating'),
(3, 14, 'Essential reading'),
(3, 1, 'For when I want a thriller'),
(4, 2, 'Heard good reviews'),
(4, 12, 'Coming of age in Cape Town'),
(5, 9, NULL),
(5, 10, 'Next on my list');

-- Orders
INSERT INTO orders (customer_id, employee_id, order_date, required_date, shipped_date, status, payment_method, tracking_number, shipping_fee, total_amount) VALUES
(1, 4, '2025-04-01', '2025-04-08', '2025-04-03', 'Delivered', 'Credit Card', 'SAP10029384', 45.00, 520.00),
(2, 6, '2025-04-05', '2025-04-12', '2025-04-07', 'Shipped', 'PayPal', 'SAP10029385', 45.00, 195.00),
(3, 5, '2025-04-10', '2025-04-17', '2025-04-12', 'Shipped', 'Debit Card', 'SAP10029386', 45.00, 290.00),
(4, 4, '2025-04-15', '2025-04-22', NULL, 'Processing', 'Credit Card', NULL, 0.00, 640.00),
(5, 6, '2025-04-20', '2025-04-27', NULL, 'Pending', 'Bank Transfer', NULL, 45.00, 230.00);

-- Order Details
INSERT INTO order_details (order_id, book_id, quantity, unit_price, discount) VALUES
(1, 1, 1, 275.00, 0.00),
(1, 13, 1, 260.00, 5.00),
(2, 3, 1, 195.00, 0.00),
(3, 7, 1, 290.00, 0.00),
(4, 14, 1, 350.00, 0.00),
(4, 13, 1, 260.00, 0.00),
(4, 2, 1, 220.00, 20.00),
(5, 9, 1, 230.00, 0.00);

-- Additional Orders (historical data for reporting)
INSERT INTO orders (customer_id, employee_id, order_date, required_date, shipped_date, status, payment_method, tracking_number, shipping_fee, total_amount) VALUES
(6, 5, '2025-03-10', '2025-03-17', '2025-03-12', 'Delivered', 'Credit Card', 'SAP10029375', 45.00, 550.00),
(7, 4, '2025-03-15', '2025-03-22', '2025-03-17', 'Delivered', 'PayPal', 'SAP10029376', 45.00, 465.00),
(8, 6, '2025-03-18', '2025-03-25', '2025-03-20', 'Delivered', 'Debit Card', 'SAP10029377', 45.00, 195.00),
(9, 5, '2025-03-22', '2025-03-29', '2025-03-24', 'Delivered', 'Credit Card', 'SAP10029378', 45.00, 260.00),
(10, 4, '2025-03-25', '2025-04-01', '2025-03-27', 'Delivered', 'Bank Transfer', 'SAP10029379', 45.00, 350.00),
(1, 6, '2025-03-28', '2025-04-04', '2025-03-30', 'Delivered', 'Credit Card', 'SAP10029380', 45.00, 185.00),
(2, 5, '2025-03-30', '2025-04-06', '2025-04-01', 'Delivered', 'PayPal', 'SAP10029381', 45.00, 260.00),
(3, 4, '2025-04-02', '2025-04-09', '2025-04-04', 'Delivered', 'Debit Card', 'SAP10029382', 45.00, 405.00),
(4, 6, '2025-04-05', '2025-04-12', '2025-04-07', 'Delivered', 'Credit Card', 'SAP10029383', 45.00, 350.00);

-- Additional Order Details
INSERT INTO order_details (order_id, book_id, quantity, unit_price, discount) VALUES
(6, 14, 1, 350.00, 0.00),
(6, 5, 1, 185.00, 0.00),
(6, 2, 1, 220.00, 20.00),
(7, 1, 1, 275.00, 0.00),
(7, 3, 1, 195.00, 5.00),
(8, 3, 1, 195.00, 0.00),
(9, 13, 1, 260.00, 0.00),
(10, 14, 1, 350.00, 0.00),
(11, 5, 1, 185.00, 0.00),
(12, 13, 1, 260.00, 0.00),
(13, 14, 1, 350.00, 0.00),
(13, 2, 1, 220.00, 15.00),
(14, 14, 1, 350.00, 0.00);

-- Gift Cards
INSERT INTO gift_cards (card_number, initial_amount, current_balance, issue_date, expiry_date, is_active, customer_id) VALUES
('SABK-GC-10001', 500.00, 500.00, '2025-03-15', '2026-03-15', TRUE, 1),
('SABK-GC-10002', 250.00, 55.00, '2025-02-20', '2026-02-20', TRUE, 4),
('SABK-GC-10003', 1000.00, 1000.00, '2025-04-05', '2026-04-05', TRUE, 7),
('SABK-GC-10004', 300.00, 300.00, '2025-04-10', '2026-04-10', TRUE, NULL),
('SABK-GC-10005', 200.00, 200.00, '2025-04-15', '2026-04-15', TRUE, 2),
('SABK-GC-10006', 500.00, 350.00, '2025-03-20', '2026-03-20', TRUE, 6),
('SABK-GC-10007', 150.00, 0.00, '2025-01-10', '2026-01-10', FALSE, 9),
('SABK-GC-10008', 750.00, 750.00, '2025-04-25', '2026-04-25', TRUE, NULL);

-- Events
INSERT INTO events (title, description, event_date, start_time, end_time, location_id, capacity, registration_required, contact_email, contact_phone) VALUES
('Meet Deon Meyer', 'Book signing and Q&A session with bestselling crime author Deon Meyer', '2025-05-15', '18:00:00', '20:00:00', 1, 50, TRUE, 'events@sabookstore.co.za', '+27 21 123 4567'),
('South African Literature Festival', 'A celebration of contemporary South African writing featuring panel discussions and readings', '2025-06-10', '10:00:00', '18:00:00', 2, 200, TRUE, 'events@sabookstore.co.za', '+27 11 234 5678'),
('Children\'s Story Hour - South African Folktales', 'Interactive storytelling session featuring traditional South African stories', '2025-05-22', '10:00:00', '11:30:00', 3, 30, FALSE, 'events@sabookstore.co.za', '+27 31 345 6789'),
('Afrikaans Book Club', 'Monthly meeting of the Afrikaans literature book club discussing "Die Aanspraak van Lewende Wesens"', '2025-05-20', '18:30:00', '20:00:00', 4, 25, TRUE, 'bookclub@sabookstore.co.za', '+27 12 456 7890'),
('Poetry Evening - Celebrating South African Voices', 'An evening of poetry readings featuring works of South African poets', '2025-06-05', '19:00:00', '21:00:00', 1, 40, TRUE, 'events@sabookstore.co.za', '+27 21 123 4567'),
('Lauren Beukes Book Launch', 'Launch of Lauren Beukes\' newest novel with reading and signing', '2025-07-10', '18:00:00', '20:00:00', 2, 75, TRUE, 'events@sabookstore.co.za', '+27 11 234 5678'),
('South African History Book Discussion', 'Panel discussion on recent South African historical non-fiction works', '2025-06-25', '18:00:00', '19:30:00', 4, 35, TRUE, 'events@sabookstore.co.za', '+27 12 456 7890'),
('Youth Day Special: Books for Young Adults', 'Special event celebrating Youth Day with focus on literature for young South Africans', '2025-06-16', '14:00:00', '17:00:00', 3, 60, FALSE, 'events@sabookstore.co.za', '+27 31 345 6789');