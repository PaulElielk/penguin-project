-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Hôte : 127.0.0.1
-- Généré le : jeu. 17 avr. 2025 à 15:49
-- Version du serveur : 10.4.32-MariaDB
-- Version de PHP : 8.0.30

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de données : `mobile_money_app`
--

-- --------------------------------------------------------

--
-- Structure de la table `user_account`
--

CREATE TABLE `user_account` (
  `user_id` int(11) NOT NULL,
  `user_email` varchar(255) NOT NULL,
  `user_password` varchar(255) NOT NULL,
  `fname` varchar(100) NOT NULL,
  `lname` varchar(100) NOT NULL,
  `phone_number` varchar(15) NOT NULL,
  `balance` decimal(10,2) DEFAULT 0.00
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `user_account`
--

INSERT INTO `user_account` (`user_id`, `user_email`, `user_password`, `fname`, `lname`, `phone_number`, `balance`) VALUES
(1, 'test@example.com', '$2b$10$9NP.NNS46xJfVKaDWeIAtu6AaXV1LzkUEmOzxegdDI5n3CabBnrYy', 'John', 'Does', '1234567890', 10550.00),
(2, 'paul@gmail.com', '$2b$10$/k00nVEwPCuSO3copXrUPu5NwG5kx9eJytckDhxD6sqSeTOfBQ/Qi', 'paul', 'kouame', '0101905020', 1000.00),
(3, 'kpauleliel@gmail.com', '$2b$10$3ZRpGvxG8kT.C2qPyiidQ.BBY/w24QBXm.xnod/1e8PiP12hNXv/2', 'Paul ', 'Kouame', '0595187899', 25000.00);

--
-- Index pour les tables déchargées
--

--
-- Index pour la table `user_account`
--
ALTER TABLE `user_account`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `user_email` (`user_email`),
  ADD UNIQUE KEY `phone_number` (`phone_number`);

--
-- AUTO_INCREMENT pour les tables déchargées
--

--
-- AUTO_INCREMENT pour la table `user_account`
--
ALTER TABLE `user_account`
  MODIFY `user_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
