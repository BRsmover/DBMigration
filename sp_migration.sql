/* Stored Procedure - KNW 128 */

/* #1 Database Migration */
CREATE PROCEDURE `DataMigration` ()
BEGIN
  DROP DATABASE IF EXISTS `schoolinfo_neu`;
  CREATE DATABASE IF NOT EXISTS `schoolinfo_neu` CHARACTER SET utf 8 COLLATE utf8_unicode_ci;
  USE `schoolinfo_neu`;
  SET SESSION SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";

  /* 1 - Classes */
  /* Create table */
  START TRANSACTION;
  DROP TABLE IF EXISTS `klassen`;
  CREATE TABLE `klassen` (
    `id_klasse` INT NOT NULL AUTO_INCREMENT,
    `id_lehrer` INT DEFAULT NULL,
    `name` VARCHAR(50) DEFAULT NULL,
    `beschreibung` VARCHAR(255),
    PRIMARY KEY (`id_klasse`)
  )
    ENGINE = InnoDB
    DEFAULT CHARSET = utf8
    COLLATE = utf8_unicode_ci;
  SELECT "Table 'klassen' has been created.";
  COMMIT;

  /* Copy data */
  START TRANSACTION;
  LOCK TABLES `klassen` WRITE;
  ALTER TABLE `klassen` DISABLE KEYS;
  INSERT INTO `klassen` (`id_klasse`, `id_lehrer`, `name`, `beschreibung`)
    SELECT
      `idklasse` AS `id_klasse`,
      `klassenlehrer` AS `id_lehrer`,
      `name` AS `name`,
      `realname` AS `beschreibung`
    FROM `schoolinfo1282017`.`klasse`;
  ALTER TABLE `klassen`
    ENABLE KEYS;
  UNLOCK TABLES;
  SELECT "Data for 'klassen' has been copied.";
  COMMIT;

  /* 2 - Firms */
  /* Create table */
  START TRANSACTION;
  DROP TABLE IF EXISTS `lehrbetriebe`;
  CREATE TABLE `lehrbetriebe` (
    `id_lehrbetrieb` INT NOT NULL AUTO_INCREMENT,
    `name` VARCHAR(100) DEFAULT NULL,
    `strasse` VARCHAR(50) DEFAULT NULL,
    `nummer` VARCHAR(10) DEFAULT NULL,
    `plz` VARCHAR(10) DEFAULT NULL,
    `ort` VARCHAR(50) DEFAULT NULL,
    `kanton` VARCHAR(50) DEFAULT NULL,
    `land` VARCHAR(50) DEFAULT NULL,
    PRIMARY KEY (`id_lehrbetrieb`)
  )
    ENGINE = InnoDB
    DEFAULT CHARSET = utf8
    COLLATE = utf8_unicode_ci;
  SELECT "Table 'lehrbetriebe' has been created.";
  COMMIT;

  /* Copy data */
  START TRANSACTION;
  LOCK TABLES `lehrbetriebe` WRITE;
  ALTER TABLE `lehrbetriebe` DISABLE KEYS;
  INSERT INTO `lehrbetriebe` (id_lehrbetrieb, name, strasse, nummer, plz, ort, kanton, land)
    SELECT
      `id_Lehrbetrieb` AS `id_lehrbetrieb`,
      `FName` AS `name`,
      `FStrasse` AS `strasse`,
      `FHausNr` AS `nummer`,
      `FPlz` AS `plz`,
      `FOrt` AS `ort`,
      `FKanton` AS `kanton`,
      `FLand` AS `land`
    FROM `schoolinfo1282017`.`lehrbetriebe`;
  ALTER TABLE `lehrbetriebe`
    ENABLE KEYS;
  UNLOCK TABLES;
  SELECT "Data for 'lehrbetriebe' has been copied.";
  COMMIT;
  
  /* 3 - Students */
  /* Create table */
  START TRANSACTION;
  DROP TABLE IF EXISTS `lernende`;
  CREATE TABLE `lernende` (
    `id_lernender` INT NOT NULL AUTO_INCREMENT,
    `anrede` VARCHAR(25) DEFAULT NULL,
    `name` VARCHAR(50) DEFAULT NULL,
    `vorname` VARCHAR(50) DEFAULT NULL,
    `geschlecht` VARCHAR(25) DEFAULT NULL,
    `fk_klasse` INT NOT NULL ,
    `bm` TINYINT NOT NULL ,
    `fk_richtung` INT NOT NULL ,
    `fk_lehrbetrieb` INT NOT NULL ,
    `strasse` VARCHAR(50) DEFAULT NULL,
    `plz` VARCHAR(50) DEFAULT NULL,
    `ort` VARCHAR(50) DEFAULT NULL,
    PRIMARY KEY (`id_lernender`),
    FOREIGN KEY (fk_klasse) REFERENCES klassen (id_klasse),
    FOREIGN KEY (fk_richtung) REFERENCES fachrichtungen (id_richtung),
    FOREIGN KEY (fk_lehrbetrieb) REFERENCES lehrbetriebe (id_lehrbetrieb)
  )
    ENGINE = InnoDB
    DEFAULT CHARSET = utf8
    COLLATE = utf8_unicode_ci;
  SELECT "Table 'lernende' has been created.";
  COMMIT;

  /* Copy data */
  START TRANSACTION;
  LOCK TABLES `lernende` WRITE;
  ALTER TABLE `lernende` DISABLE KEYS;
  INSERT INTO `lernende` (id_lehrbetrieb, name, strasse, nummer, plz, ort, kanton, land)
    SELECT
      `id_Lehrbetrieb` AS `id_lehrbetrieb`,
      `FName` AS `name`,
      `FStrasse` AS `strasse`,
      `FHausNr` AS `nummer`,
      `FPlz` AS `plz`,
      `FOrt` AS `ort`,
      `FKanton` AS `kanton`,
      `FLand` AS `land`
    FROM `schoolinfo1282017`.`lernende`;
  ALTER TABLE `lernende`
    ENABLE KEYS;
  UNLOCK TABLES;
  SELECT "Data for 'lernende' has been copied.";
  COMMIT;
END
