-- Database Schema extracted from .frm files
-- Generated on: 2026-03-23

CREATE DATABASE IF NOT EXISTS db DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE db;

-- Table: users
CREATE TABLE users (
    userID INT AUTO_INCREMENT PRIMARY KEY,
    name1 VARCHAR(255) NOT NULL,
    name2 VARCHAR(255),
    surname1 VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL,
    password VARCHAR(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Table: allenamenti
CREATE TABLE allenamenti (
    trainingID INT AUTO_INCREMENT PRIMARY KEY,
    userID INT NOT NULL, 
    data DATE NOT NULL,
    CONSTRAINT allenamenti_users FOREIGN KEY(userID) REFERENCES users(userID) ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Table: esecuzioni
CREATE TABLE esecuzioni (
    executionID INT AUTO_INCREMENT PRIMARY KEY,
    trainingID INT NOT NULL,
    nomeEsercizio VARCHAR(255) NOT NULL,
    ripetizioni INT NOT NULL,
    kg FLOAT NOT NULL,
    note TEXT,
    CONSTRAINT esecuzioni_allenamenti FOREIGN KEY(trainingID) REFERENCES allenamenti(trainingID) ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
