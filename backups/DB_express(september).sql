CREATE DATABASE  IF NOT EXISTS `appexpress` /*!40100 DEFAULT CHARACTER SET utf8mb3 */ /*!80016 DEFAULT ENCRYPTION='N' */;
USE `appexpress`;
-- MySQL dump 10.13  Distrib 8.0.25, for macos11 (x86_64)
--
-- Host: localhost    Database: appexpress
-- ------------------------------------------------------
-- Server version	8.0.33

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `DateValue`
--

DROP TABLE IF EXISTS `DateValue`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `DateValue` (
  `id` int NOT NULL,
  `day` int DEFAULT NULL,
  `date` date DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `id_UNIQUE` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `DateValue`
--

LOCK TABLES `DateValue` WRITE;
/*!40000 ALTER TABLE `DateValue` DISABLE KEYS */;
/*!40000 ALTER TABLE `DateValue` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `command`
--

DROP TABLE IF EXISTS `command`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `command` (
  `id` int NOT NULL AUTO_INCREMENT,
  `infos` varchar(150) DEFAULT NULL,
  `cost` decimal(6,2) DEFAULT '0.00',
  `enter_date` varchar(30) DEFAULT 'ras',
  `return_date` varchar(30) DEFAULT 'ras',
  `discount` decimal(6,2) DEFAULT '0.00',
  `date_` datetime DEFAULT NULL,
  `services_quantity` varchar(5000) DEFAULT '""',
  `agent` int DEFAULT '1',
  `user` int NOT NULL,
  `enter_time` varchar(5) DEFAULT 'ras',
  `return_time` varchar(5) DEFAULT 'ras',
  `sub_total` decimal(6,2) DEFAULT '0.00',
  `delivery` decimal(6,2) DEFAULT '0.00',
  PRIMARY KEY (`id`),
  UNIQUE KEY `id_UNIQUE` (`id`),
  KEY `fk_command_user1_idx` (`user`),
  KEY `fk_command_agent_idx` (`agent`),
  CONSTRAINT `fk_command_agent` FOREIGN KEY (`agent`) REFERENCES `user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_command_user1` FOREIGN KEY (`user`) REFERENCES `user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=161 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `command`
--

LOCK TABLES `command` WRITE;
/*!40000 ALTER TABLE `command` DISABLE KEYS */;
INSERT INTO `command` VALUES (155,'',292.99,'2023/09/26','2023/10/06',0.00,'2023-09-21 05:51:27','50:17',1,2,'10','16',289.00,3.99),(156,'',51.00,'2023/09/29','2023/10/06',0.00,'2023-09-25 12:30:17','47:14',1,1,'10','16',42.00,9.00),(157,'',87.99,'2023/09/29','2023/10/10',0.00,'2023-09-28 00:59:44','49:7',1,31,'11','13',84.00,3.99),(158,'',377.99,'2023/11/07','2023/12/06',0.00,'2023-09-28 21:21:40','49:8,55:7,50:1,50:8,56:8,51:2,53:1,51:8',1,2,'11','15',374.00,3.99),(159,'',6.99,'2023/11/08','2023/11/20',0.00,'2023-09-28 21:59:09','47:5',1,2,'11','17',3.00,3.99),(160,'',32.00,'2023/10/12','2023/10/24',0.00,'2023-10-05 14:43:35','56:8',1,32,'12','16',32.00,0.00);
/*!40000 ALTER TABLE `command` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `command_BEFORE_INSERT` BEFORE INSERT ON `command` FOR EACH ROW BEGIN
	SET NEW.cost = (NEW.sub_total + NEW.delivery - NEW.discount);
	SET NEW.date_ = NOW();
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `command_BEFORE_UPDATE` BEFORE UPDATE ON `command` FOR EACH ROW BEGIN
	SET NEW.cost = (NEW.sub_total + NEW.delivery - NEW.discount);
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `command_service`
--

DROP TABLE IF EXISTS `command_service`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `command_service` (
  `command_id` int NOT NULL,
  `service_id` int NOT NULL,
  `quantity` int NOT NULL,
  PRIMARY KEY (`command_id`,`service_id`),
  KEY `fk_command_has_service_service1_idx` (`service_id`),
  KEY `fk_command_has_service_command1_idx` (`command_id`),
  CONSTRAINT `fk_command_has_service_command1` FOREIGN KEY (`command_id`) REFERENCES `command` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_command_has_service_service1` FOREIGN KEY (`service_id`) REFERENCES `service` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `command_service`
--

LOCK TABLES `command_service` WRITE;
/*!40000 ALTER TABLE `command_service` DISABLE KEYS */;
INSERT INTO `command_service` VALUES (155,50,17),(156,47,14),(157,49,7),(158,49,4),(158,55,6),(158,56,8),(159,47,1),(160,56,8);
/*!40000 ALTER TABLE `command_service` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `coupon`
--

DROP TABLE IF EXISTS `coupon`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `coupon` (
  `id` int NOT NULL AUTO_INCREMENT,
  `code` varchar(45) DEFAULT NULL,
  `discount` decimal(6,2) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `coupon`
--

LOCK TABLES `coupon` WRITE;
/*!40000 ALTER TABLE `coupon` DISABLE KEYS */;
INSERT INTO `coupon` VALUES (2,'ABCDEF',5.99),(3,'YETI2023',3.99),(4,'TEST1',2.12),(6,'BLACK2024',9.80),(8,'TEST2',3099.00),(9,'EXPRESS2024',4.80),(10,'testnico',5.00),(11,'First',5.00),(12,'PROMO',950.00),(13,'PROMO2',9.00);
/*!40000 ALTER TABLE `coupon` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `daysoff`
--

DROP TABLE IF EXISTS `daysoff`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `daysoff` (
  `id` int NOT NULL AUTO_INCREMENT,
  `date` varchar(15) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `id_UNIQUE` (`id`),
  UNIQUE KEY `date_UNIQUE` (`date`)
) ENGINE=InnoDB AUTO_INCREMENT=49 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `daysoff`
--

LOCK TABLES `daysoff` WRITE;
/*!40000 ALTER TABLE `daysoff` DISABLE KEYS */;
INSERT INTO `daysoff` VALUES (41,'2023/09/21'),(43,'2023/09/23'),(44,'2023/09/24');
/*!40000 ALTER TABLE `daysoff` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `params`
--

DROP TABLE IF EXISTS `params`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `params` (
  `id` int NOT NULL,
  `tarif_bruxelles` decimal(6,2) DEFAULT '0.00',
  `tarif_brabant` decimal(6,2) DEFAULT '0.00',
  `tarif_km` decimal(6,2) DEFAULT '0.00',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `params`
--

LOCK TABLES `params` WRITE;
/*!40000 ALTER TABLE `params` DISABLE KEYS */;
/*!40000 ALTER TABLE `params` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `service`
--

DROP TABLE IF EXISTS `service`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `service` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(45) DEFAULT NULL,
  `cost` decimal(6,2) DEFAULT NULL,
  `categories` varchar(45) DEFAULT NULL,
  `time` int DEFAULT NULL,
  `description` varchar(256) DEFAULT NULL,
  `illustration` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `id_UNIQUE` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=59 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `service`
--

LOCK TABLES `service` WRITE;
/*!40000 ALTER TABLE `service` DISABLE KEYS */;
INSERT INTO `service` VALUES (47,'Chemise',3.00,'Nettoyage à sec;Blanchisserie',3,'Si en plus du ménage il faut laver des chemises. Kilos','Chemise'),(49,'Costume',12.00,'Nettoyage à sec',5,'Costume 2 pièces','Costume1'),(50,'Costume',17.00,'Nettoyage à sec',5,'Costume 3 pièces','Costume2'),(51,'Cravate',5.00,'Nettoyage à sec',3,'Une cravate propre c\'est mieux','Cravate'),(53,'Essai',3.56,'Nettoyage à sec',7,'rbgdyvbssuhdghjsgbdjhsbdjksfssf dffsdfdsf sdfdsfds fado','Essai'),(54,'En profondeur',25.00,'Chaussure',6,'Semelle et lacets inclus','Chaussure'),(55,'Premium',49.00,'Chaussure',7,'Désinfectant, désodorisant, colorisation partielle','Chaussure'),(56,'Tenture',4.00,'Blanchisserie',10,'Lavage en profondeur. Le prix est fixé au mètre carré','Tenture'),(57,'Pantalon',5.00,'Couture',3,'Ourlet Machine','Pantalon');
/*!40000 ALTER TABLE `service` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `settings`
--

DROP TABLE IF EXISTS `settings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `settings` (
  `id` int NOT NULL,
  `update` tinyint DEFAULT '0',
  `pub` varchar(512) DEFAULT NULL,
  `infos` varchar(512) DEFAULT NULL,
  `read` tinyint DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `settings`
--

LOCK TABLES `settings` WRITE;
/*!40000 ALTER TABLE `settings` DISABLE KEYS */;
INSERT INTO `settings` VALUES (1,0,'ras','ras',0);
/*!40000 ALTER TABLE `settings` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user`
--

DROP TABLE IF EXISTS `user`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(45) DEFAULT 'NA',
  `password` varchar(45) DEFAULT 'NA',
  `surname` varchar(45) DEFAULT 'NA',
  `mail` varchar(45) DEFAULT 'NA',
  `adress` varchar(120) DEFAULT 'NA',
  `phone` varchar(20) DEFAULT 'NA',
  `type` varchar(5) DEFAULT 'NA',
  PRIMARY KEY (`id`),
  UNIQUE KEY `id_UNIQUE` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=33 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user`
--

LOCK TABLES `user` WRITE;
/*!40000 ALTER TABLE `user` DISABLE KEYS */;
INSERT INTO `user` VALUES (1,'fisher','fisher','Sam','sam@echelon.co','rue des allies 21 1410 waterloo','908641625','admin'),(2,'hean','hean','hean','hean@heanlab.com','rue du perri 13 1000 bruxelles','486650305','user'),(3,'Erfnerinferjf','nfiuerfjer','hean','er@heanlab.vr','EMAIL_USER','0','user,'),(11,'Hubert','H','','hean@heanlab.com','hean@heanlab.com','45236582','user,'),(13,'Testeur1','testeur1','hean','testeur1@heanlab.com','testeur1@heanlab.com','486650303','user,'),(14,'testeur2','testeur2','hean','testeur2@heanlab.com','testeur2@heanlab.com','852343521','user,'),(15,'avalon','avalon','','avalon@gmail.com','avalon@gmail.com','425235601','user,'),(16,'todd','todd','','todd@maison.be','todd@maison.be','852412745','user,'),(17,'tib','tib','','tib@outlokk.com','tib@outlokk.com','963523147','user,'),(18,'pop','pop','','pop@gmail.com','rue royale 32 1000 Bruxelles','435234548','user'),(19,'re','re','','re@te.be','rue royale 20 1000 Bruxelles','468432234','user'),(20,'test0','test0','','+237694608505@unknown.email','rue royale 92 1000 bruxelles','21884051','user'),(21,'Nicola2','Manon0209','','test@test.be','rue willy van der meeren 1 1140  Evere','483313493','user'),(22,'td1','td1','','td1@home.be','avenue emile de mot 7 1000 bruxelles','486650309','user'),(24,'echo','echo','','lever.clad0q@icloud.com','rue des allies 93 1190 Bruxelles','486650303','user'),(25,'hln','titichat','rmn','','léopold i laan 9 a 1560 hoeilaart ','0484 90 171 6','user'),(26,'gg','1234','hh','iejek@jekdk.be','rue pipi 5 gui 8300 bruges ','0483 31 346 5 8','user'),(27,'test2','test@@','hea','test@heanlab.co','trte 12 1000 bruxelles','486650303','user'),(28,'test3','yyy','test2','','','0486 65 030 3','user'),(29,'Rer','mola','','Fdj@te.co','','','user'),(30,'aaa','ccc','bbb','ckhhhvh@hhhj.be','','0482 54 556','user'),(31,'essai1','essai1','essai','test@test.com','rue du petit papillon 17 1000 bruxelles','0486303251','user'),(32,'ytryr','tttt','rtrt','rytf@de.ft','reure 9 w 1200 reree','04865230124','user');
/*!40000 ALTER TABLE `user` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping events for database 'appexpress'
--

--
-- Dumping routines for database 'appexpress'
--
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2023-10-07 17:01:39
