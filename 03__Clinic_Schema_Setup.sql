--B. For the below schema for a clinic management system
--Process:
--Creating database and tables:

CREATE DATABASE clinic_management;
USE clinic_management;

CREATE TABLE clinics (
    cid VARCHAR(50) PRIMARY KEY,
    clinic_name VARCHAR(100),
    city VARCHAR(100),
    state VARCHAR(100),
    country VARCHAR(100)
);

CREATE TABLE customer (
    uid VARCHAR(50) PRIMARY KEY,
    name VARCHAR(100),
    mobile VARCHAR(20)
);

CREATE TABLE clinic_sales (
    oid VARCHAR(50) PRIMARY KEY,
    uid VARCHAR(50),
    cid VARCHAR(50),
    amount DECIMAL(10,2),
    datetime DATETIME,
    sales_channel VARCHAR(50),
    FOREIGN KEY (uid) REFERENCES customer(uid),
    FOREIGN KEY (cid) REFERENCES clinics(cid)
);

CREATE TABLE expenses (
    eid VARCHAR(50) PRIMARY KEY,
    cid VARCHAR(50),
    description VARCHAR(255),
    amount DECIMAL(10,2),
    datetime DATETIME,
    FOREIGN KEY (cid) REFERENCES clinics(cid)
);

--Inserting Values into the tables:

INSERT INTO clinics VALUES
('cnc-0100001', 'XYZ Clinic', 'Hyderabad', 'Telangana', 'India'),
('cnc-0100002', 'ABC Clinic', 'Bengaluru', 'Karnataka', 'India');

INSERT INTO customer VALUES
('uid-1001', 'John Doe', '97XXXXXXXX'),
('uid-1002', 'Alice', '88XXXXXXXX');
INSERT INTO clinic_sales VALUES
('ord-00100-00100', 'uid-1001', 'cnc-0100001', 24999, '2021-09-23 12:03:22', 'sodat'),
('ord-00100-00101', 'uid-1002', 'cnc-0100001', 13000, '2021-11-12 14:10:55', 'website');

INSERT INTO expenses VALUES
('exp-0100-00100', 'cnc-0100001', 'first-aid supplies', 557, '2021-09-23 07:36:48'),
('exp-0100-00101', 'cnc-0100001', 'rent', 8000, '2021-11-03 10:15:22');
