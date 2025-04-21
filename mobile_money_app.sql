-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Hôte : 127.0.0.1
-- Généré le : lun. 21 avr. 2025 à 19:33
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
-- Structure de la table `agent_account`
--

CREATE TABLE `agent_account` (
  `agent_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `business_name` varchar(100) NOT NULL,
  `business_address` varchar(255) NOT NULL,
  `phone_number` varchar(15) NOT NULL,
  `status` enum('Active','Inactive') DEFAULT 'Active',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `agent_account`
--

INSERT INTO `agent_account` (`agent_id`, `user_id`, `business_name`, `business_address`, `phone_number`, `status`, `created_at`) VALUES
(7, 7, 'a b', 'a b', '5555555555', 'Active', '2025-04-20 20:00:53'),
(8, 6, 'moumou', 'eeazza', '1010101010', 'Active', '2025-04-21 15:03:53');

-- --------------------------------------------------------

--
-- Structure de la table `merchant_account`
--

CREATE TABLE `merchant_account` (
  `merchant_id` int(11) NOT NULL,
  `merchant_email` varchar(255) NOT NULL,
  `merchant_password` varchar(255) NOT NULL,
  `business_name` varchar(100) NOT NULL,
  `business_type` varchar(50) NOT NULL,
  `business_address` varchar(255) NOT NULL,
  `phone_number` varchar(15) NOT NULL,
  `balance` decimal(10,2) DEFAULT 0.00,
  `status` enum('Active','Inactive') DEFAULT 'Active',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `merchant_account`
--

INSERT INTO `merchant_account` (`merchant_id`, `merchant_email`, `merchant_password`, `business_name`, `business_type`, `business_address`, `phone_number`, `balance`, `status`, `created_at`) VALUES
(2, 'restaurant@example.com', '$2b$10$9NP.NNS46xJfVKaDWeIAtu6AaXV1LzkUEmOzxegdDI5n3CabBnrYy', 'Restaurant Plus 32', 'Food', '321 Food Court', '0987654321', 500.00, 'Active', '2025-04-20 08:41:27'),
(3, '', '', 'aa ', 'bb', 'asdfg', '', 0.00, 'Active', '2025-04-20 10:45:52'),
(7, 'merchant@gmail.com', '$2b$10$u9l.ZmgJMCfYs9t3/E8rBuePLnurWQSR2jdtC5Y5LK4wnePQHD2we', 'merchant', 'sales', 'ddh', '7777777777', 192.00, 'Active', '2025-04-21 09:09:27'),
(9, 'a@b.com', '$2b$10$xf/GGC5J1zJt8IyseQoYWud6OaCdRxesIH06mXU9HpbGj/WFBFdXO', 'av', 'food', 'fddfdf', '2222222222', 0.00, 'Active', '2025-04-21 15:07:59');

-- --------------------------------------------------------

--
-- Structure de la table `merchant_transactions`
--

CREATE TABLE `merchant_transactions` (
  `id` int(11) NOT NULL,
  `merchant_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `amount` decimal(10,2) NOT NULL,
  `fees` decimal(10,2) DEFAULT 0.00,
  `transaction_date` timestamp NOT NULL DEFAULT current_timestamp(),
  `status` varchar(20) DEFAULT 'completed'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Structure de la table `rdvs`
--

CREATE TABLE `rdvs` (
  `id` int(11) NOT NULL,
  `description` text NOT NULL,
  `created_by` int(11) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `rdvs`
--

INSERT INTO `rdvs` (`id`, `description`, `created_by`, `created_at`) VALUES
(1, 'Meeting with client A', 1, '2025-04-12 09:47:38'),
(2, 'Follow-up with client B', 2, '2025-04-12 09:47:38');

-- --------------------------------------------------------

--
-- Structure de la table `teams`
--

CREATE TABLE `teams` (
  `id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `teams`
--

INSERT INTO `teams` (`id`, `name`, `created_at`) VALUES
(1, 'Team Alpha', '2025-04-12 09:48:27');

-- --------------------------------------------------------

--
-- Structure de la table `team_members`
--

CREATE TABLE `team_members` (
  `id` int(11) NOT NULL,
  `team_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `role` enum('Manager','Agent') NOT NULL,
  `added_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `team_members`
--

INSERT INTO `team_members` (`id`, `team_id`, `user_id`, `role`, `added_at`) VALUES
(1, 1, 2, 'Manager', '2025-04-12 09:48:27'),
(2, 1, 3, 'Agent', '2025-04-12 09:48:27');

-- --------------------------------------------------------

--
-- Structure de la table `transactions`
--

CREATE TABLE `transactions` (
  `id` int(11) NOT NULL,
  `sender_id` int(11) NOT NULL,
  `receiver_id` int(11) NOT NULL,
  `amount` decimal(10,2) NOT NULL,
  `fees` decimal(10,2) NOT NULL,
  `receiver_amount` decimal(10,2) NOT NULL,
  `transaction_date` timestamp NOT NULL DEFAULT current_timestamp(),
  `is_merchant_transaction` tinyint(1) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `transactions`
--

INSERT INTO `transactions` (`id`, `sender_id`, `receiver_id`, `amount`, `fees`, `receiver_amount`, `transaction_date`, `is_merchant_transaction`) VALUES
(2, 2, 2, 15.00, 0.15, 14.85, '2025-04-19 09:26:20', 0),
(6, 2, 3, 30.30, 0.30, 30.00, '2025-04-19 09:43:07', 0),
(8, 3, 2, 60.61, 0.61, 60.00, '2025-04-19 09:51:27', 0),
(9, 2, 3, 15.00, 0.15, 14.85, '2025-04-20 10:25:36', 0),
(10, 7, 2, 5.00, 0.00, 5.00, '2025-04-20 20:16:44', 0),
(11, 2, 7, 10.00, 0.00, 10.00, '2025-04-20 20:19:25', 0),
(12, 3, 7, 10.00, 0.00, 10.00, '2025-04-20 20:31:13', 0),
(13, 7, 2, 5.00, 0.00, 5.00, '2025-04-20 20:32:08', 0),
(14, 2, 7, 100.00, 0.00, 0.00, '2025-04-21 10:21:21', 0),
(15, 2, 7, 10.00, 0.10, 0.00, '2025-04-21 10:35:19', 0),
(16, 2, 3, 5.05, 0.05, 0.00, '2025-04-21 10:40:27', 0),
(17, 6, 7, 10.00, 0.00, 0.00, '2025-04-21 10:45:57', 0),
(18, 6, 2, 5.05, 0.05, 0.00, '2025-04-21 10:46:49', 0),
(19, 6, 2, 10.00, 0.10, 0.00, '2025-04-21 10:55:56', 0),
(20, 6, 2, 10.10, 0.10, 0.00, '2025-04-21 11:09:57', 0),
(21, 6, 3, 10.10, 0.10, 0.00, '2025-04-21 11:18:11', 0),
(22, 7, 2, 1.00, 0.01, 0.00, '2025-04-21 11:35:01', 0),
(23, 7, 2, 1.00, 0.01, 0.00, '2025-04-21 11:39:15', 0),
(24, 7, 3, 1.00, 0.01, 0.00, '2025-04-21 11:42:07', 0),
(25, 7, 3, 1.00, 0.01, 0.00, '2025-04-21 11:44:08', 0),
(26, 7, 2, 1.00, 0.01, 0.00, '2025-04-21 11:57:34', 0),
(27, 2, 7, 10.00, 0.00, 0.00, '2025-04-21 12:06:32', 0),
(28, 2, 7, 1.00, 0.00, 0.00, '2025-04-21 12:08:50', 0),
(29, 2, 7, 5.00, 0.00, 0.00, '2025-04-21 12:18:38', 0),
(30, 2, 7, 5.00, 0.00, 0.00, '2025-04-21 12:26:56', 1),
(31, 2, 7, 2.00, 0.00, 0.00, '2025-04-21 12:42:24', 1),
(32, 6, 7, 2.00, 0.00, 0.00, '2025-04-21 13:41:35', 1),
(33, 6, 7, 1.00, 0.00, 0.00, '2025-04-21 13:49:22', 1),
(37, 6, 7, 3.00, 0.00, 0.00, '2025-04-21 13:56:33', 1),
(40, 3, 6, 5.00, 0.05, 0.00, '2025-04-21 15:05:34', 0),
(41, 3, 7, 10.00, 0.00, 0.00, '2025-04-21 15:15:09', 1),
(42, 3, 7, 10.00, 0.00, 0.00, '2025-04-21 16:21:29', 1),
(44, 3, 7, 13.00, 0.00, 0.00, '2025-04-21 16:43:03', 1),
(45, 3, 7, 5.00, 0.00, 0.00, '2025-04-21 16:53:14', 1),
(46, 3, 7, 2.00, 0.00, 0.00, '2025-04-21 17:02:00', 1),
(47, 3, 7, 1.00, 0.00, 0.00, '2025-04-21 17:10:50', 1),
(48, 3, 7, 12.00, 0.00, 0.00, '2025-04-21 17:20:14', 1);

-- --------------------------------------------------------

--
-- Structure de la table `users`
--

CREATE TABLE `users` (
  `id` int(11) NOT NULL,
  `username` varchar(50) NOT NULL,
  `password` varchar(255) NOT NULL,
  `role` enum('Admin','Manager','Agent') NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `users`
--

INSERT INTO `users` (`id`, `username`, `password`, `role`, `created_at`) VALUES
(1, 'admin', 'admin', 'Admin', '2025-04-12 09:47:13'),
(2, 'manager1', 'password123', 'Manager', '2025-04-12 09:47:22'),
(3, 'agent1', 'password123', 'Agent', '2025-04-12 09:47:22'),
(4, 'testuser', '$2b$10$lldbQQNjPYI5z.tRC8ncPO9OcMNc0GuKRyaGvMJ2ObziGl1YEqQXq', 'Manager', '2025-04-12 10:32:07'),
(5, 'testuser5', '$2b$10$AQj9N5E9pWZuv95.kLbHQOc/HaV2bHff09he4aewAUQ4OEvKSR27m', 'Manager', '2025-04-14 10:39:40'),
(6, 'user6', '$2b$10$2tW6hIbOmkUDjax8aA.iyek6sfvIKsaeSsQCy2jjOc40dZx/yZ4lu', '', '2025-04-14 10:57:25');

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
(2, 'paul@gmail.com', '$2b$10$kPfF.Soyg4XWvHEdrpv54esvq79LRCnONw.VcTFGmFQ57ceSddlX6', 'paul Eliel', 'KOUAME', '0101905020', 948.27),
(3, 'kpauleliel@gmail.com', '$2b$10$3ZRpGvxG8kT.C2qPyiidQ.BBY/w24QBXm.xnod/1e8PiP12hNXv/2', 'Paul ', 'Kouame', '0595187899', 23385.64),
(6, 'mounir@mail.com', '$2b$10$GqpvvnNK5c7AOUbBmf.4vuUYp6WULPnIuGegnqHZBtT.PEtLB72AW', 'mounirrr', 'bamba', '1010101010', 53.70),
(7, 'abc@mail.com', '$2b$10$eob9pfu6zxq5e0XU1rBcS.Tx8IgS.8QaoEWePaOE.jduCqYw48.9i', 'merchant', '', '5555555555', 24.90);

--
-- Index pour les tables déchargées
--

--
-- Index pour la table `agent_account`
--
ALTER TABLE `agent_account`
  ADD PRIMARY KEY (`agent_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Index pour la table `merchant_account`
--
ALTER TABLE `merchant_account`
  ADD PRIMARY KEY (`merchant_id`),
  ADD UNIQUE KEY `merchant_email` (`merchant_email`),
  ADD UNIQUE KEY `phone_number` (`phone_number`),
  ADD KEY `idx_business_name` (`business_name`),
  ADD KEY `idx_status` (`status`),
  ADD KEY `idx_phone` (`phone_number`);

--
-- Index pour la table `merchant_transactions`
--
ALTER TABLE `merchant_transactions`
  ADD PRIMARY KEY (`id`),
  ADD KEY `merchant_id` (`merchant_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Index pour la table `rdvs`
--
ALTER TABLE `rdvs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `created_by` (`created_by`);

--
-- Index pour la table `teams`
--
ALTER TABLE `teams`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `name` (`name`);

--
-- Index pour la table `team_members`
--
ALTER TABLE `team_members`
  ADD PRIMARY KEY (`id`),
  ADD KEY `team_id` (`team_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Index pour la table `transactions`
--
ALTER TABLE `transactions`
  ADD PRIMARY KEY (`id`),
  ADD KEY `transactions_ibfk_1` (`sender_id`),
  ADD KEY `transactions_ibfk_2` (`receiver_id`),
  ADD KEY `idx_merchant_transaction` (`is_merchant_transaction`);

--
-- Index pour la table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `username` (`username`);

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
-- AUTO_INCREMENT pour la table `agent_account`
--
ALTER TABLE `agent_account`
  MODIFY `agent_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT pour la table `merchant_account`
--
ALTER TABLE `merchant_account`
  MODIFY `merchant_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT pour la table `merchant_transactions`
--
ALTER TABLE `merchant_transactions`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT pour la table `rdvs`
--
ALTER TABLE `rdvs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT pour la table `teams`
--
ALTER TABLE `teams`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT pour la table `team_members`
--
ALTER TABLE `team_members`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT pour la table `transactions`
--
ALTER TABLE `transactions`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=49;

--
-- AUTO_INCREMENT pour la table `users`
--
ALTER TABLE `users`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT pour la table `user_account`
--
ALTER TABLE `user_account`
  MODIFY `user_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- Contraintes pour les tables déchargées
--

--
-- Contraintes pour la table `agent_account`
--
ALTER TABLE `agent_account`
  ADD CONSTRAINT `agent_account_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `user_account` (`user_id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `merchant_transactions`
--
ALTER TABLE `merchant_transactions`
  ADD CONSTRAINT `merchant_transactions_ibfk_1` FOREIGN KEY (`merchant_id`) REFERENCES `merchant_account` (`merchant_id`),
  ADD CONSTRAINT `merchant_transactions_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `user_account` (`user_id`);

--
-- Contraintes pour la table `rdvs`
--
ALTER TABLE `rdvs`
  ADD CONSTRAINT `rdvs_ibfk_1` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `team_members`
--
ALTER TABLE `team_members`
  ADD CONSTRAINT `team_members_ibfk_1` FOREIGN KEY (`team_id`) REFERENCES `teams` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `team_members_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `transactions`
--
ALTER TABLE `transactions`
  ADD CONSTRAINT `transactions_ibfk_1` FOREIGN KEY (`sender_id`) REFERENCES `user_account` (`user_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `transactions_ibfk_2` FOREIGN KEY (`receiver_id`) REFERENCES `user_account` (`user_id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
