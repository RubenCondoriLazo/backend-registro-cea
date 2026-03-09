-- Database Schema for Online Store
CREATE DATABASE IF NOT EXISTS onlinestore_db;
USE onlinestore_db;

CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(100) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    role ENUM('Admin', 'Vendedor', 'Comprador') NOT NULL,
    full_name VARCHAR(100) NOT NULL
);

CREATE TABLE IF NOT EXISTS products (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    price DECIMAL(10,2) NOT NULL,
    stock INT NOT NULL DEFAULT 0,
    seller_id INT,
    image_url VARCHAR(500),
    FOREIGN KEY (seller_id) REFERENCES users(id)
);

CREATE TABLE IF NOT EXISTS orders (
    id INT AUTO_INCREMENT PRIMARY KEY,
    buyer_id INT,
    total DECIMAL(10,2) NOT NULL,
    status VARCHAR(50) DEFAULT 'Pendiente',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (buyer_id) REFERENCES users(id)
);

CREATE TABLE IF NOT EXISTS order_items (
    id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT,
    product_id INT,
    quantity INT NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (order_id) REFERENCES orders(id),
    FOREIGN KEY (product_id) REFERENCES products(id)
);

CREATE TABLE IF NOT EXISTS reviews (
    id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT,
    buyer_id INT,
    rating INT CHECK (rating BETWEEN 1 AND 5),
    comment TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES products(id),
    FOREIGN KEY (buyer_id) REFERENCES users(id)
);

-- Initial Data Examples
INSERT IGNORE INTO users (username, password, role, full_name) VALUES 
('admin_ruben@store.com', 'admin123', 'Admin', 'Ruben Admin'),
('vendedor_juan@store.com', 'vend123', 'Vendedor', 'Juan Seller'),
('comprador_ana@store.com', 'comp123', 'Comprador', 'Ana Buyer');

INSERT IGNORE INTO products (name, description, price, stock, seller_id, image_url) VALUES 
('Laptop Pro', 'Potente laptop para desarrollo', 1200.00, 10, 2, 'https://via.placeholder.com/200'),
('Mouse Gaming', 'Mouse con RGB y alta precision', 50.00, 25, 2, 'https://via.placeholder.com/200'),
('Teclado Mecanico', 'Teclado para gaming profesional', 100.00, 15, 2, 'https://via.placeholder.com/200');
