-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: May 16, 2026 at 02:31 PM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `pokemuse_db`
--

-- --------------------------------------------------------

--
-- Table structure for table `badges`
--

CREATE TABLE `badges` (
  `badge_id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL,
  `description` varchar(255) DEFAULT NULL,
  `icon` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `badges`
--

INSERT INTO `badges` (`badge_id`, `name`, `description`, `icon`) VALUES
(1, 'First Steps', 'Added your first card to inventory.', '🥾'),
(2, 'Legendary Hunter', 'Caught a Legendary Pokémon.', '⭐'),
(3, 'Museum Curator', 'Owns 20+ cards.', '🏛️'),
(4, 'Veteran Trainer', 'Maintained a 7-day login streak.', '🔥'),
(5, 'Pack Maniac', 'Opened 10 booster packs.', '📦'),
(6, 'Trading Pro', 'Completed 5 trades.', '🔄'),
(7, 'Deck Builder', 'Built a complete deck of 20 cards.', '🃏');

-- --------------------------------------------------------

--
-- Table structure for table `booster_packs`
--

CREATE TABLE `booster_packs` (
  `pack_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `pack_type` enum('basic','elite','master') NOT NULL DEFAULT 'basic',
  `opened_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `booster_packs`
--

INSERT INTO `booster_packs` (`pack_id`, `user_id`, `pack_type`, `opened_at`) VALUES
(1, 3, 'basic', '2026-04-17 08:15:32'),
(2, 3, 'elite', '2026-04-24 08:29:40'),
(3, 3, 'master', '2026-04-24 08:29:48'),
(4, 8, 'master', '2026-05-07 12:08:27');

-- --------------------------------------------------------

--
-- Table structure for table `booster_pack_cards`
--

CREATE TABLE `booster_pack_cards` (
  `id` int(11) NOT NULL,
  `pack_id` int(11) NOT NULL,
  `card_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `booster_pack_cards`
--

INSERT INTO `booster_pack_cards` (`id`, `pack_id`, `card_id`) VALUES
(1, 1, 12),
(2, 1, 19),
(3, 1, 11),
(4, 1, 18),
(5, 1, 18),
(6, 2, 19),
(7, 2, 10),
(8, 2, 8),
(9, 2, 5),
(10, 2, 20),
(11, 3, 7),
(12, 3, 5),
(13, 3, 4),
(14, 3, 1),
(15, 3, 6),
(16, 4, 9),
(17, 4, 1),
(18, 4, 4),
(19, 4, 2),
(20, 4, 15);

-- --------------------------------------------------------

--
-- Table structure for table `catch_log`
--

CREATE TABLE `catch_log` (
  `log_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `card_id` int(11) NOT NULL,
  `shake_1` tinyint(1) NOT NULL DEFAULT 0,
  `shake_2` tinyint(1) NOT NULL DEFAULT 0,
  `shake_3` tinyint(1) NOT NULL DEFAULT 0,
  `caught` tinyint(1) NOT NULL DEFAULT 0,
  `caught_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `catch_log`
--

INSERT INTO `catch_log` (`log_id`, `user_id`, `card_id`, `shake_1`, `shake_2`, `shake_3`, `caught`, `caught_at`) VALUES
(1, 3, 14, 0, 0, 0, 0, '2026-04-17 08:14:44'),
(2, 3, 4, 0, 0, 0, 0, '2026-04-17 08:14:52'),
(3, 3, 12, 1, 1, 1, 1, '2026-04-17 08:14:57'),
(4, 7, 20, 0, 0, 0, 0, '2026-04-19 07:41:21'),
(5, 7, 4, 0, 0, 0, 0, '2026-04-19 07:41:25'),
(6, 7, 10, 1, 1, 1, 1, '2026-04-19 07:41:32'),
(7, 3, 5, 0, 1, 0, 0, '2026-04-24 08:28:22'),
(8, 3, 1, 0, 0, 0, 0, '2026-04-24 08:28:26'),
(9, 3, 3, 0, 0, 0, 0, '2026-04-24 08:28:32'),
(10, 3, 18, 1, 1, 1, 1, '2026-04-24 08:28:34'),
(11, 3, 18, 1, 1, 1, 1, '2026-04-24 08:28:37'),
(12, 3, 16, 0, 0, 0, 0, '2026-04-24 08:28:54'),
(13, 3, 20, 1, 1, 0, 0, '2026-04-24 08:28:57'),
(14, 3, 16, 0, 0, 0, 0, '2026-04-24 08:29:00'),
(15, 3, 14, 0, 0, 0, 0, '2026-04-24 08:29:18'),
(16, 3, 14, 0, 0, 0, 0, '2026-05-03 08:27:42'),
(17, 3, 3, 0, 0, 0, 0, '2026-05-03 21:16:02'),
(18, 3, 3, 0, 0, 0, 0, '2026-05-03 21:16:06'),
(19, 3, 8, 0, 1, 0, 0, '2026-05-03 21:16:08'),
(20, 3, 6, 0, 0, 0, 0, '2026-05-03 21:16:10'),
(21, 3, 13, 1, 1, 1, 1, '2026-05-03 21:16:12'),
(22, 3, 11, 1, 0, 0, 0, '2026-05-03 21:16:15'),
(23, 3, 2, 0, 0, 0, 0, '2026-05-03 21:16:17'),
(24, 3, 8, 0, 0, 0, 0, '2026-05-03 21:16:18'),
(25, 3, 20, 0, 0, 0, 0, '2026-05-03 21:16:20'),
(26, 3, 11, 0, 1, 0, 0, '2026-05-03 21:16:21'),
(27, 3, 4, 0, 0, 0, 0, '2026-05-03 21:16:27'),
(28, 3, 18, 1, 0, 1, 0, '2026-05-03 21:16:32'),
(29, 3, 12, 1, 1, 1, 1, '2026-05-03 21:16:37'),
(30, 3, 7, 0, 0, 0, 0, '2026-05-03 21:17:15'),
(31, 3, 1, 0, 0, 0, 0, '2026-05-03 21:17:17'),
(32, 3, 14, 0, 1, 0, 0, '2026-05-03 21:17:19'),
(33, 3, 10, 1, 1, 1, 1, '2026-05-03 21:17:21'),
(34, 3, 7, 0, 0, 0, 0, '2026-05-03 21:17:23'),
(35, 3, 5, 0, 0, 0, 0, '2026-05-03 21:17:25'),
(36, 3, 6, 0, 0, 0, 0, '2026-05-03 21:17:28'),
(37, 3, 19, 1, 0, 1, 0, '2026-05-03 21:17:30'),
(38, 3, 2, 0, 0, 0, 0, '2026-05-03 21:17:33'),
(39, 3, 12, 0, 0, 0, 0, '2026-05-03 21:17:36'),
(40, 7, 2, 0, 0, 0, 0, '2026-05-04 13:23:22'),
(41, 8, 14, 0, 0, 0, 0, '2026-05-04 14:09:25'),
(42, 8, 4, 0, 0, 0, 0, '2026-05-04 14:09:41'),
(43, 8, 2, 0, 0, 0, 0, '2026-05-04 14:09:44'),
(44, 8, 12, 1, 1, 0, 0, '2026-05-04 14:09:47'),
(45, 8, 11, 1, 1, 1, 1, '2026-05-04 14:09:50'),
(46, 8, 10, 1, 1, 1, 1, '2026-05-04 14:12:08'),
(47, 8, 7, 0, 0, 0, 0, '2026-05-04 14:12:16'),
(48, 8, 18, 0, 0, 1, 0, '2026-05-04 14:12:19'),
(49, 8, 3, 0, 0, 0, 0, '2026-05-07 12:05:44'),
(50, 8, 15, 0, 0, 0, 0, '2026-05-07 12:05:49'),
(51, 8, 20, 0, 1, 0, 0, '2026-05-07 12:05:53'),
(52, 8, 16, 0, 1, 1, 0, '2026-05-07 12:05:57'),
(53, 8, 5, 0, 0, 0, 0, '2026-05-07 12:06:01'),
(54, 8, 5, 0, 0, 0, 0, '2026-05-07 12:06:05'),
(55, 8, 8, 0, 0, 0, 0, '2026-05-07 12:06:08'),
(56, 8, 11, 1, 1, 0, 0, '2026-05-07 12:06:12'),
(57, 8, 1, 0, 0, 0, 0, '2026-05-07 12:07:51'),
(58, 8, 11, 1, 1, 1, 1, '2026-05-07 12:07:54'),
(59, 8, 8, 0, 0, 0, 0, '2026-05-07 12:08:06'),
(60, 8, 15, 0, 0, 0, 0, '2026-05-07 12:08:10'),
(61, 8, 5, 0, 1, 1, 0, '2026-05-07 12:08:14'),
(62, 8, 11, 0, 1, 1, 0, '2026-05-07 12:08:18'),
(63, 7, 4, 0, 0, 0, 0, '2026-05-15 15:35:34'),
(64, 7, 10, 0, 1, 0, 0, '2026-05-16 00:05:23'),
(65, 7, 1, 0, 0, 0, 0, '2026-05-16 00:05:26'),
(66, 7, 3, 0, 0, 0, 0, '2026-05-16 00:05:27'),
(67, 7, 14, 0, 0, 0, 0, '2026-05-16 00:05:29'),
(68, 7, 11, 1, 0, 0, 0, '2026-05-16 00:05:32'),
(69, 7, 9, 1, 0, 1, 0, '2026-05-16 00:05:34'),
(70, 7, 7, 0, 1, 0, 0, '2026-05-16 00:05:35'),
(71, 7, 18, 1, 0, 1, 0, '2026-05-16 00:05:37'),
(72, 7, 14, 1, 0, 0, 0, '2026-05-16 00:05:39'),
(73, 7, 14, 0, 0, 0, 0, '2026-05-16 00:09:15'),
(74, 7, 18, 0, 1, 1, 0, '2026-05-16 00:09:18'),
(75, 7, 18, 1, 1, 1, 1, '2026-05-16 00:09:56'),
(76, 7, 16, 1, 1, 0, 0, '2026-05-16 10:20:04'),
(77, 7, 1, 1, 0, 0, 0, '2026-05-16 10:20:32'),
(78, 7, 11, 1, 1, 1, 1, '2026-05-16 10:20:37'),
(79, 7, 3, 1, 0, 0, 0, '2026-05-16 10:41:14'),
(80, 7, 16, 0, 1, 0, 0, '2026-05-16 10:59:11'),
(81, 7, 13, 1, 1, 0, 0, '2026-05-16 10:59:30'),
(82, 7, 21, 1, 1, 1, 1, '2026-05-16 11:02:42');

-- --------------------------------------------------------

--
-- Table structure for table `daily_rewards`
--

CREATE TABLE `daily_rewards` (
  `reward_id` int(11) NOT NULL,
  `day_number` int(11) NOT NULL,
  `coins` int(11) NOT NULL DEFAULT 0,
  `pack_type` enum('none','basic','elite','master') NOT NULL DEFAULT 'none',
  `description` varchar(150) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `daily_rewards`
--

INSERT INTO `daily_rewards` (`reward_id`, `day_number`, `coins`, `pack_type`, `description`) VALUES
(1, 1, 10, 'none', 'Day 1 – Welcome back! +10 PokéCoins'),
(2, 2, 20, 'none', 'Day 2 – Keep it up! +20 PokéCoins'),
(3, 3, 30, 'basic', 'Day 3 – Basic Pack + 30 PokéCoins'),
(4, 4, 50, 'none', 'Day 4 – Half way! +50 PokéCoins'),
(5, 5, 75, 'none', 'Day 5 – Almost there! +75 PokéCoins'),
(6, 6, 100, 'elite', 'Day 6 – Elite Pack + 100 PokéCoins'),
(7, 7, 200, 'master', 'Day 7 – WEEKLY REWARD! Master Pack + 200 PokéCoins');

-- --------------------------------------------------------

--
-- Table structure for table `decks`
--

CREATE TABLE `decks` (
  `deck_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `deck_name` varchar(100) NOT NULL DEFAULT 'My Deck',
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `decks`
--

INSERT INTO `decks` (`deck_id`, `user_id`, `deck_name`, `created_at`, `updated_at`) VALUES
(1, 3, 'Alu', '2026-05-16 14:10:09', '2026-05-16 14:10:09');

-- --------------------------------------------------------

--
-- Table structure for table `deck_cards`
--

CREATE TABLE `deck_cards` (
  `id` int(11) NOT NULL,
  `deck_id` int(11) NOT NULL,
  `card_id` int(11) NOT NULL,
  `slot_position` int(11) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `pokemon_cards`
--

CREATE TABLE `pokemon_cards` (
  `card_id` int(11) NOT NULL,
  `card_code` varchar(20) NOT NULL,
  `name` varchar(100) NOT NULL,
  `pokedex_number` int(11) DEFAULT NULL,
  `type` varchar(50) NOT NULL,
  `rarity` enum('Common','Rare','Epic','Legendary') NOT NULL,
  `condition_state` enum('Mint','Near Mint','Good','Fair','Poor') NOT NULL DEFAULT 'Mint',
  `value` decimal(10,2) NOT NULL DEFAULT 0.00,
  `image_path` varchar(255) DEFAULT NULL,
  `description` text DEFAULT NULL,
  `catch_rate` int(11) NOT NULL DEFAULT 100,
  `is_available` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `created_by` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `pokemon_cards`
--

INSERT INTO `pokemon_cards` (`card_id`, `card_code`, `name`, `pokedex_number`, `type`, `rarity`, `condition_state`, `value`, `image_path`, `description`, `catch_rate`, `is_available`, `created_at`, `created_by`) VALUES
(1, 'PC001', 'Charizard', 6, 'Fire', 'Legendary', 'Mint', 420.00, 'cards/PC001.png', 'The legendary flame Pokémon. Extremely rare and powerful.', 45, 1, '2026-04-16 12:55:31', NULL),
(2, 'PC002', 'Mewtwo', 150, 'Psychic', 'Legendary', 'Mint', 390.00, 'cards/PC002.png', 'Created by science. The most powerful Pokémon of its time.', 45, 1, '2026-04-16 12:55:31', NULL),
(3, 'PC003', 'Mew', 151, 'Psychic', 'Legendary', 'Mint', 550.00, 'cards/PC003.png', 'Said to contain the genetic composition of all Pokémon.', 45, 1, '2026-04-16 12:55:31', NULL),
(4, 'PC004', 'Lugia', 249, 'Psychic', 'Legendary', 'Near Mint', 480.00, 'cards/PC004.png', 'Guardian of the seas. Symbol of the Silver Wing.', 45, 1, '2026-04-16 12:55:31', NULL),
(5, 'PC005', 'Blastoise', 9, 'Water', 'Rare', 'Near Mint', 180.00, 'cards/PC005.png', 'A brutal Pokémon with pressurized water jets on its shell.', 45, 1, '2026-04-16 12:55:31', NULL),
(6, 'PC006', 'Gengar', 94, 'Ghost', 'Rare', 'Good', 75.00, 'cards/PC006.png', 'Lurks in the shadows. It is said to be the ghost of Clefable.', 45, 1, '2026-04-16 12:55:31', NULL),
(7, 'PC007', 'Dragonite', 149, 'Dragon', 'Epic', 'Near Mint', 130.00, 'cards/PC007.png', 'A dragon Pokémon capable of circling the globe in 16 hours.', 50, 1, '2026-04-16 12:55:31', NULL),
(8, 'PC008', 'Pikachu', 25, 'Electric', 'Epic', 'Good', 95.00, 'cards/PC008.png', 'The iconic electric mouse. Beloved mascot of Pokémon worldwide.', 50, 1, '2026-04-16 12:55:31', NULL),
(9, 'PC009', 'Raichu', 26, 'Electric', 'Rare', 'Mint', 60.00, 'cards/PC009.png', 'Discharges electricity stored in its cheeks.', 75, 1, '2026-04-16 12:55:31', NULL),
(10, 'PC010', 'Bulbasaur', 1, 'Grass', 'Common', 'Fair', 25.00, 'cards/PC010.png', 'The first Pokémon in the national Pokédex. A classic starter.', 45, 1, '2026-04-16 12:55:31', NULL),
(11, 'PC011', 'Squirtle', 7, 'Water', 'Common', 'Good', 22.00, 'cards/PC011.png', 'Withdrawn in its shell when in danger. Blasts water from its mouth.', 45, 1, '2026-04-16 12:55:31', NULL),
(12, 'PC012', 'Charmander', 4, 'Fire', 'Common', 'Good', 28.00, 'cards/PC012.png', 'The flame on its tail indicates how healthy it is.', 45, 1, '2026-04-16 12:55:31', NULL),
(13, 'PC013', 'Eevee', 133, 'Normal', 'Common', 'Mint', 40.00, 'cards/PC013.png', 'Capable of evolving into many different Pokémon forms.', 45, 1, '2026-04-16 12:55:31', NULL),
(14, 'PC014', 'Snorlax', 143, 'Normal', 'Rare', 'Near Mint', 55.00, 'cards/PC014.png', 'Very lazy. Just eats and sleeps. But extremely hard to defeat.', 25, 1, '2026-04-16 12:55:31', NULL),
(15, 'PC015', 'Gyarados', 130, 'Water', 'Epic', 'Good', 110.00, 'cards/PC015.png', 'Magikarp evolved. Destructive and terrifying.', 50, 1, '2026-04-16 12:55:31', NULL),
(16, 'PC016', 'Alakazam', 65, 'Psychic', 'Rare', 'Mint', 70.00, 'cards/PC016.png', 'Its brain cells multiply continually. Genius IQ Pokémon.', 45, 1, '2026-04-16 12:55:31', NULL),
(17, 'PC017', 'Machamp', 68, 'Fighting', 'Rare', 'Good', 65.00, 'cards/PC017.png', 'Uses all four arms to throw its opponents. Incredible strength.', 45, 1, '2026-04-16 12:55:31', NULL),
(18, 'PC018', 'Jigglypuff', 39, 'Normal', 'Common', 'Mint', 18.00, 'cards/PC018.png', 'Captivates its enemies with a lullaby, then scribbles on their faces.', 170, 1, '2026-04-16 12:55:31', NULL),
(19, 'PC019', 'Clefairy', 35, 'Fairy', 'Common', 'Good', 15.00, 'cards/PC019.png', 'Said to arrive from the moon on a moonlit night.', 150, 1, '2026-04-16 12:55:31', NULL),
(20, 'PC020', 'Lapras', 131, 'Water', 'Rare', 'Near Mint', 85.00, 'cards/PC020.png', 'A gentle giant that ferries people across the sea.', 45, 1, '2026-04-16 12:55:31', NULL),
(21, 'PC021', 'Bellsprout', 69, 'Grass', 'Common', 'Good', 45.00, 'cards/PC021.png', 'Bellsprout is a dual-type Grass/Poison Pokémon, classified as the Flower Pokémon and assigned National Pokédex number 069.  It features a 0.7 m (2\'04\") stem-like body with a yellow bell-shaped head, two green leaves, and root-like feet, and it has a 50% male / 50% female gender ratio.', 180, 1, '2026-05-04 14:00:56', 6);

-- --------------------------------------------------------

--
-- Table structure for table `quests`
--

CREATE TABLE `quests` (
  `quest_id` int(11) NOT NULL,
  `title` varchar(150) NOT NULL,
  `description` text NOT NULL,
  `quest_type` enum('daily','weekly','permanent') NOT NULL,
  `action_type` varchar(50) NOT NULL,
  `target_count` int(11) NOT NULL DEFAULT 1,
  `reward_type` enum('coins','basic_pack','elite_pack','master_pack','rare_card','badge') NOT NULL,
  `reward_value` int(11) NOT NULL DEFAULT 50,
  `reward_card_id` int(11) DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `quests`
--

INSERT INTO `quests` (`quest_id`, `title`, `description`, `quest_type`, `action_type`, `target_count`, `reward_type`, `reward_value`, `reward_card_id`, `is_active`) VALUES
(13, 'First Catch of the Day', 'Catch any wild Pokémon today.', 'daily', 'catch', 1, 'coins', 50, NULL, 1),
(14, 'Daily Trainer', 'Log in today to claim your reward.', 'daily', 'login', 1, 'coins', 30, NULL, 1),
(15, 'Pack Opener', 'Open a booster pack today.', 'daily', 'open_pack', 1, 'coins', 40, NULL, 1),
(16, 'Collector', 'Add 3 cards to your inventory today.', 'daily', 'add_inventory', 3, 'coins', 60, NULL, 1),
(17, 'Daily Trader', 'Make a trade offer today.', 'daily', 'trade', 1, 'coins', 45, NULL, 1),
(18, 'Pokémon Hunter', 'Catch 10 wild Pokémon this week.', 'weekly', 'catch', 10, 'coins', 200, NULL, 1),
(19, 'Pack Addict', 'Open 5 booster packs this week.', 'weekly', 'open_pack', 5, 'elite_pack', 1, NULL, 1),
(20, 'Trading Master', 'Complete 3 trades this week.', 'weekly', 'trade', 3, 'coins', 300, NULL, 1),
(21, 'Legendary Hunter', 'Catch a Legendary Pokémon this week.', 'weekly', 'catch_legendary', 1, 'coins', 500, NULL, 1),
(22, 'Week Streak', 'Log in 5 days in a row this week.', 'weekly', 'streak', 5, 'coins', 150, NULL, 1),
(23, 'First Steps', 'Catch your very first Pokémon.', 'permanent', 'catch', 1, 'coins', 100, NULL, 1),
(24, 'Seasoned Trainer', 'Catch 50 Pokémon total.', 'permanent', 'catch', 50, 'coins', 500, NULL, 1),
(26, 'Pack Legend', 'Open 20 booster packs.', 'permanent', 'open_pack', 20, 'master_pack', 1, NULL, 1),
(27, 'Trade Baron', 'Complete 10 trades.', 'permanent', 'trade', 10, 'coins', 750, NULL, 1),
(28, 'Legendary Tamer', 'Catch 3 Legendary Pokémon.', 'permanent', 'catch_legendary', 3, 'coins', 1000, NULL, 1),
(32, 'First Catch', 'Catch any wild Pokémon today.', 'daily', 'catch', 1, 'basic_pack', 1, NULL, 1),
(33, 'Pack Opener', 'Open 1 Booster Pack today.', 'daily', 'open_pack', 1, 'coins', 50, NULL, 1),
(34, 'Collector', 'Add 3 cards to your inventory.', 'daily', 'add_inventory', 3, 'coins', 30, NULL, 1),
(35, 'Pokémon Hunter', 'Catch 10 Pokémon this week.', 'weekly', 'catch', 10, 'elite_pack', 1, NULL, 1),
(36, 'Quest Champion', 'Complete 5 daily quests this week.', 'weekly', 'daily_complete', 5, 'coins', 200, NULL, 1),
(37, 'Deck Master', 'Build a complete deck of 20 cards.', 'weekly', 'build_deck', 1, 'rare_card', 1, NULL, 1),
(38, 'Trading Trainer', 'List 3 cards on the Trading Station.', 'weekly', 'trade', 3, 'coins', 150, NULL, 1),
(40, 'Legendary Hunter', 'Catch a Legendary Pokémon.', 'permanent', 'catch_legendary', 1, 'master_pack', 1, NULL, 1),
(41, 'Museum Curator', 'Own 20 cards in your inventory.', 'permanent', 'add_inventory', 20, 'elite_pack', 1, NULL, 1),
(42, 'Veteran Trainer', 'Maintain a 7-day login streak.', 'permanent', 'streak', 7, 'coins', 500, NULL, 1);

-- --------------------------------------------------------

--
-- Table structure for table `trades`
--

CREATE TABLE `trades` (
  `trade_id` int(11) NOT NULL,
  `offered_by` int(11) NOT NULL,
  `card_id` int(11) NOT NULL,
  `status` enum('open','completed','cancelled') NOT NULL DEFAULT 'open',
  `listed_at` datetime NOT NULL DEFAULT current_timestamp(),
  `completed_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `trades`
--

INSERT INTO `trades` (`trade_id`, `offered_by`, `card_id`, `status`, `listed_at`, `completed_at`) VALUES
(1, 3, 11, 'open', '2026-05-03 08:24:20', NULL),
(2, 8, 1, 'open', '2026-05-15 22:26:09', NULL),
(3, 8, 1, 'open', '2026-05-15 22:39:40', NULL),
(4, 8, 9, 'open', '2026-05-15 22:39:48', NULL),
(5, 8, 10, 'open', '2026-05-15 22:40:12', NULL),
(6, 8, 10, 'open', '2026-05-15 22:40:22', NULL),
(7, 8, 9, 'open', '2026-05-15 22:44:10', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `trade_offers`
--

CREATE TABLE `trade_offers` (
  `offer_id` int(11) NOT NULL,
  `trade_id` int(11) NOT NULL,
  `offered_by` int(11) NOT NULL,
  `offered_card` int(11) NOT NULL,
  `status` enum('pending','accepted','rejected') NOT NULL DEFAULT 'pending',
  `offered_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `user_id` int(11) NOT NULL,
  `username` varchar(50) NOT NULL,
  `password_hash` varchar(255) NOT NULL,
  `email` varchar(100) NOT NULL,
  `role` enum('admin','user') NOT NULL DEFAULT 'user',
  `login_streak` int(11) NOT NULL DEFAULT 0,
  `coins` int(11) NOT NULL DEFAULT 100,
  `last_login` date DEFAULT NULL,
  `is_locked` tinyint(1) NOT NULL DEFAULT 0,
  `failed_attempts` int(11) NOT NULL DEFAULT 0,
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`user_id`, `username`, `password_hash`, `email`, `role`, `login_streak`, `coins`, `last_login`, `is_locked`, `failed_attempts`, `created_at`) VALUES
(3, 'raju', '$2a$10$yAiEe0Cd31wiluz8Ynnqte3YWfPiGwVvaUgYUjT.WRAjBodvWgU.6', 'araj@calc.com', 'user', 2, 100, '2026-05-16', 0, 0, '2026-04-17 08:03:19'),
(6, 'poksmin', '$2a$10$1Sfum/pBlVm7kvFhn1JNVuoJddvx3G0LIevFjneTaVtXBL1P.czx6', 'poksmin@adminpoke.com', 'admin', 2, 100, '2026-05-16', 0, 0, '2026-04-17 11:12:56'),
(7, 'ashkechup', '$2a$10$L/.ViLzSv/V7KsnbjGOkr.TVDF8uBeeJL6GvJ3F5.n8LDvu8xxiim', 'ashichang@gmail.com', 'user', 2, 250, '2026-05-16', 0, 0, '2026-04-19 07:41:06'),
(8, 'bebot', '$2a$10$gUBuWpeHTeVOZa5Zgt5DZO6TqkmDOPTCxxnijJ8kJqY3idTFfL8UG', 'bebot@testcase.com', 'user', 2, 100, '2026-05-16', 0, 0, '2026-05-04 13:30:30');

-- --------------------------------------------------------

--
-- Table structure for table `user_badges`
--

CREATE TABLE `user_badges` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `badge_id` int(11) NOT NULL,
  `earned_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `user_daily_claims`
--

CREATE TABLE `user_daily_claims` (
  `claim_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `current_day` int(11) NOT NULL DEFAULT 1,
  `last_claimed` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `user_inventory`
--

CREATE TABLE `user_inventory` (
  `inventory_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `card_id` int(11) NOT NULL,
  `obtained_via` enum('browse','catch','booster','trade','quest_reward') NOT NULL DEFAULT 'browse',
  `obtained_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `user_inventory`
--

INSERT INTO `user_inventory` (`inventory_id`, `user_id`, `card_id`, `obtained_via`, `obtained_at`) VALUES
(1, 3, 12, 'catch', '2026-04-17 08:14:57'),
(2, 3, 1, 'browse', '2026-04-17 08:15:14'),
(4, 3, 19, 'booster', '2026-04-17 08:15:32'),
(5, 3, 11, 'booster', '2026-04-17 08:15:32'),
(6, 3, 18, 'booster', '2026-04-17 08:15:32'),
(8, 7, 10, 'catch', '2026-04-19 07:41:32'),
(12, 3, 10, 'booster', '2026-04-24 08:29:40'),
(13, 3, 8, 'booster', '2026-04-24 08:29:40'),
(14, 3, 5, 'booster', '2026-04-24 08:29:40'),
(15, 3, 20, 'booster', '2026-04-24 08:29:40'),
(16, 3, 7, 'booster', '2026-04-24 08:29:48'),
(18, 3, 4, 'booster', '2026-04-24 08:29:48'),
(20, 3, 6, 'booster', '2026-04-24 08:29:48'),
(21, 3, 3, 'browse', '2026-05-03 08:23:50'),
(22, 3, 13, 'catch', '2026-05-03 21:16:12'),
(26, 8, 11, 'catch', '2026-05-04 14:09:50'),
(27, 8, 10, 'catch', '2026-05-04 14:12:08'),
(29, 8, 9, 'booster', '2026-05-07 12:08:27'),
(30, 8, 1, 'booster', '2026-05-07 12:08:27'),
(31, 8, 4, 'booster', '2026-05-07 12:08:27'),
(32, 8, 2, 'booster', '2026-05-07 12:08:27'),
(33, 8, 15, 'booster', '2026-05-07 12:08:27'),
(34, 7, 18, 'catch', '2026-05-16 00:09:56'),
(35, 7, 11, 'catch', '2026-05-16 10:20:37'),
(36, 7, 21, 'catch', '2026-05-16 11:02:42');

-- --------------------------------------------------------

--
-- Table structure for table `user_quest_progress`
--

CREATE TABLE `user_quest_progress` (
  `progress_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `quest_id` int(11) NOT NULL,
  `current_count` int(11) NOT NULL DEFAULT 0,
  `is_completed` tinyint(1) NOT NULL DEFAULT 0,
  `is_claimed` tinyint(1) NOT NULL DEFAULT 0,
  `reset_date` date DEFAULT NULL,
  `completed_at` datetime DEFAULT NULL,
  `claimed_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `user_quest_progress`
--

INSERT INTO `user_quest_progress` (`progress_id`, `user_id`, `quest_id`, `current_count`, `is_completed`, `is_claimed`, `reset_date`, `completed_at`, `claimed_at`) VALUES
(1, 7, 13, 1, 1, 1, '2026-05-17', NULL, '2026-05-16 10:22:27'),
(2, 7, 14, 0, 0, 0, '2026-05-17', NULL, NULL),
(3, 7, 15, 0, 0, 0, '2026-05-17', NULL, NULL),
(4, 7, 16, 0, 0, 0, '2026-05-17', NULL, NULL),
(5, 7, 17, 0, 0, 0, '2026-05-17', NULL, NULL),
(6, 7, 18, 2, 0, 0, '2026-05-18', NULL, NULL),
(7, 7, 19, 0, 0, 0, '2026-05-18', NULL, NULL),
(8, 7, 20, 0, 0, 0, '2026-05-18', NULL, NULL),
(9, 7, 21, 0, 0, 0, '2026-05-18', NULL, NULL),
(10, 7, 22, 0, 0, 0, '2026-05-18', NULL, NULL),
(11, 7, 23, 1, 1, 1, NULL, NULL, '2026-05-16 10:22:22'),
(12, 7, 24, 2, 0, 0, NULL, NULL, NULL),
(14, 7, 26, 0, 0, 0, NULL, NULL, NULL),
(15, 7, 27, 0, 0, 0, NULL, NULL, NULL),
(16, 7, 28, 0, 0, 0, NULL, NULL, NULL),
(19, 7, 32, 1, 1, 1, '2026-05-17', NULL, '2026-05-16 10:22:48'),
(20, 7, 33, 0, 0, 0, '2026-05-17', NULL, NULL),
(21, 7, 34, 0, 0, 0, '2026-05-17', NULL, NULL),
(22, 7, 35, 2, 0, 0, '2026-05-18', NULL, NULL),
(23, 7, 36, 0, 0, 0, '2026-05-18', NULL, NULL),
(24, 7, 37, 0, 0, 0, '2026-05-18', NULL, NULL),
(25, 7, 38, 0, 0, 0, '2026-05-18', NULL, NULL),
(27, 7, 40, 0, 0, 0, NULL, NULL, NULL),
(28, 7, 41, 0, 0, 0, NULL, NULL, NULL),
(29, 7, 42, 0, 0, 0, NULL, NULL, NULL);

--
-- Indexes for dumped tables
--

--
-- Indexes for table `badges`
--
ALTER TABLE `badges`
  ADD PRIMARY KEY (`badge_id`);

--
-- Indexes for table `booster_packs`
--
ALTER TABLE `booster_packs`
  ADD PRIMARY KEY (`pack_id`),
  ADD KEY `fk_bp_user` (`user_id`);

--
-- Indexes for table `booster_pack_cards`
--
ALTER TABLE `booster_pack_cards`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_bpc_pack` (`pack_id`),
  ADD KEY `fk_bpc_card` (`card_id`);

--
-- Indexes for table `catch_log`
--
ALTER TABLE `catch_log`
  ADD PRIMARY KEY (`log_id`),
  ADD KEY `idx_catch_user` (`user_id`),
  ADD KEY `idx_catch_date` (`caught_at`),
  ADD KEY `fk_cl_card` (`card_id`);

--
-- Indexes for table `daily_rewards`
--
ALTER TABLE `daily_rewards`
  ADD PRIMARY KEY (`reward_id`),
  ADD UNIQUE KEY `day_number` (`day_number`);

--
-- Indexes for table `decks`
--
ALTER TABLE `decks`
  ADD PRIMARY KEY (`deck_id`),
  ADD KEY `fk_deck_user` (`user_id`);

--
-- Indexes for table `deck_cards`
--
ALTER TABLE `deck_cards`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_deck_slot` (`deck_id`,`slot_position`),
  ADD KEY `fk_dc_card` (`card_id`);

--
-- Indexes for table `pokemon_cards`
--
ALTER TABLE `pokemon_cards`
  ADD PRIMARY KEY (`card_id`),
  ADD UNIQUE KEY `card_code` (`card_code`),
  ADD KEY `idx_name` (`name`),
  ADD KEY `idx_rarity` (`rarity`),
  ADD KEY `idx_type` (`type`),
  ADD KEY `idx_value` (`value`),
  ADD KEY `fk_card_creator` (`created_by`);

--
-- Indexes for table `quests`
--
ALTER TABLE `quests`
  ADD PRIMARY KEY (`quest_id`),
  ADD KEY `fk_quest_reward_card` (`reward_card_id`);

--
-- Indexes for table `trades`
--
ALTER TABLE `trades`
  ADD PRIMARY KEY (`trade_id`),
  ADD KEY `idx_trade_status` (`status`),
  ADD KEY `fk_tr_user` (`offered_by`),
  ADD KEY `fk_tr_card` (`card_id`);

--
-- Indexes for table `trade_offers`
--
ALTER TABLE `trade_offers`
  ADD PRIMARY KEY (`offer_id`),
  ADD KEY `fk_to_trade` (`trade_id`),
  ADD KEY `fk_to_user` (`offered_by`),
  ADD KEY `fk_to_card` (`offered_card`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `username` (`username`),
  ADD UNIQUE KEY `email` (`email`),
  ADD KEY `idx_username` (`username`),
  ADD KEY `idx_role` (`role`);

--
-- Indexes for table `user_badges`
--
ALTER TABLE `user_badges`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_user_badge` (`user_id`,`badge_id`),
  ADD KEY `fk_ub_badge` (`badge_id`);

--
-- Indexes for table `user_daily_claims`
--
ALTER TABLE `user_daily_claims`
  ADD PRIMARY KEY (`claim_id`),
  ADD UNIQUE KEY `user_id` (`user_id`);

--
-- Indexes for table `user_inventory`
--
ALTER TABLE `user_inventory`
  ADD PRIMARY KEY (`inventory_id`),
  ADD UNIQUE KEY `uq_user_card` (`user_id`,`card_id`),
  ADD KEY `fk_inv_card` (`card_id`);

--
-- Indexes for table `user_quest_progress`
--
ALTER TABLE `user_quest_progress`
  ADD PRIMARY KEY (`progress_id`),
  ADD UNIQUE KEY `uq_user_quest` (`user_id`,`quest_id`),
  ADD KEY `fk_qp_quest` (`quest_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `badges`
--
ALTER TABLE `badges`
  MODIFY `badge_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT for table `booster_packs`
--
ALTER TABLE `booster_packs`
  MODIFY `pack_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `booster_pack_cards`
--
ALTER TABLE `booster_pack_cards`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=21;

--
-- AUTO_INCREMENT for table `catch_log`
--
ALTER TABLE `catch_log`
  MODIFY `log_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=83;

--
-- AUTO_INCREMENT for table `daily_rewards`
--
ALTER TABLE `daily_rewards`
  MODIFY `reward_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT for table `decks`
--
ALTER TABLE `decks`
  MODIFY `deck_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `deck_cards`
--
ALTER TABLE `deck_cards`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `pokemon_cards`
--
ALTER TABLE `pokemon_cards`
  MODIFY `card_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=22;

--
-- AUTO_INCREMENT for table `quests`
--
ALTER TABLE `quests`
  MODIFY `quest_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=43;

--
-- AUTO_INCREMENT for table `trades`
--
ALTER TABLE `trades`
  MODIFY `trade_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT for table `trade_offers`
--
ALTER TABLE `trade_offers`
  MODIFY `offer_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `user_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT for table `user_badges`
--
ALTER TABLE `user_badges`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `user_daily_claims`
--
ALTER TABLE `user_daily_claims`
  MODIFY `claim_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `user_inventory`
--
ALTER TABLE `user_inventory`
  MODIFY `inventory_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=37;

--
-- AUTO_INCREMENT for table `user_quest_progress`
--
ALTER TABLE `user_quest_progress`
  MODIFY `progress_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=81;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `booster_packs`
--
ALTER TABLE `booster_packs`
  ADD CONSTRAINT `fk_bp_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE;

--
-- Constraints for table `booster_pack_cards`
--
ALTER TABLE `booster_pack_cards`
  ADD CONSTRAINT `fk_bpc_card` FOREIGN KEY (`card_id`) REFERENCES `pokemon_cards` (`card_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_bpc_pack` FOREIGN KEY (`pack_id`) REFERENCES `booster_packs` (`pack_id`) ON DELETE CASCADE;

--
-- Constraints for table `catch_log`
--
ALTER TABLE `catch_log`
  ADD CONSTRAINT `fk_cl_card` FOREIGN KEY (`card_id`) REFERENCES `pokemon_cards` (`card_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_cl_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE;

--
-- Constraints for table `decks`
--
ALTER TABLE `decks`
  ADD CONSTRAINT `fk_deck_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE;

--
-- Constraints for table `deck_cards`
--
ALTER TABLE `deck_cards`
  ADD CONSTRAINT `fk_dc_card` FOREIGN KEY (`card_id`) REFERENCES `pokemon_cards` (`card_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_dc_deck` FOREIGN KEY (`deck_id`) REFERENCES `decks` (`deck_id`) ON DELETE CASCADE;

--
-- Constraints for table `pokemon_cards`
--
ALTER TABLE `pokemon_cards`
  ADD CONSTRAINT `fk_card_creator` FOREIGN KEY (`created_by`) REFERENCES `users` (`user_id`) ON DELETE SET NULL;

--
-- Constraints for table `quests`
--
ALTER TABLE `quests`
  ADD CONSTRAINT `fk_quest_reward_card` FOREIGN KEY (`reward_card_id`) REFERENCES `pokemon_cards` (`card_id`) ON DELETE SET NULL;

--
-- Constraints for table `trades`
--
ALTER TABLE `trades`
  ADD CONSTRAINT `fk_tr_card` FOREIGN KEY (`card_id`) REFERENCES `pokemon_cards` (`card_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_tr_user` FOREIGN KEY (`offered_by`) REFERENCES `users` (`user_id`) ON DELETE CASCADE;

--
-- Constraints for table `trade_offers`
--
ALTER TABLE `trade_offers`
  ADD CONSTRAINT `fk_to_card` FOREIGN KEY (`offered_card`) REFERENCES `pokemon_cards` (`card_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_to_trade` FOREIGN KEY (`trade_id`) REFERENCES `trades` (`trade_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_to_user` FOREIGN KEY (`offered_by`) REFERENCES `users` (`user_id`) ON DELETE CASCADE;

--
-- Constraints for table `user_badges`
--
ALTER TABLE `user_badges`
  ADD CONSTRAINT `fk_ub_badge` FOREIGN KEY (`badge_id`) REFERENCES `badges` (`badge_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_ub_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE;

--
-- Constraints for table `user_daily_claims`
--
ALTER TABLE `user_daily_claims`
  ADD CONSTRAINT `fk_udc_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE;

--
-- Constraints for table `user_inventory`
--
ALTER TABLE `user_inventory`
  ADD CONSTRAINT `fk_inv_card` FOREIGN KEY (`card_id`) REFERENCES `pokemon_cards` (`card_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_inv_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE;

--
-- Constraints for table `user_quest_progress`
--
ALTER TABLE `user_quest_progress`
  ADD CONSTRAINT `fk_qp_quest` FOREIGN KEY (`quest_id`) REFERENCES `quests` (`quest_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_qp_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
