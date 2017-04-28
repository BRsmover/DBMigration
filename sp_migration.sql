DELIMITER //
  /* Stored Procedure - KNW 128 */

  /* #1 Database Migration */
  CREATE PROCEDURE `sp_migration` ()
  BEGIN
    DROP DATABASE IF EXISTS `schoolinfo_neu`;
    CREATE DATABASE IF NOT EXISTS `schoolinfo_neu` CHARACTER SET utf8;
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
      `fk_fachrichtung` INT NOT NULL ,
      `fk_lehrbetrieb` INT NOT NULL ,
      `strasse` VARCHAR(50) DEFAULT NULL,
      `plz` VARCHAR(50) DEFAULT NULL,
      `ort` VARCHAR(50) DEFAULT NULL,
      PRIMARY KEY (`id_lernender`),
      FOREIGN KEY (fk_klasse) REFERENCES klassen (id_klasse),
      FOREIGN KEY (fk_fachrichtung) REFERENCES fachrichtungen (id_fachrichtung),
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
    INSERT INTO `lernende` (id_lernender, anrede, name, vorname, geschlecht, fk_klasse, bm, fk_fachrichtung, fk_lehrbetrieb, strasse, plz, ort)
      SELECT
        `Lern_id` AS `id_lernender`,
        `anrede` AS `anrede`,
        `name` AS `name`,
        `vorname` AS `vorname`,
        `geschlecht` AS `geschlecht`,
        `klasse` AS `fk_klasse`,
        `bm` AS `bm`,
        `richtung` AS `fk_fachrichtung`,
        `lehrbetrieb` AS `fk_lehrbetrieb`,
        `strasse` AS `strasse`,
        `plz` AS `plz`,
        `ort` AS `ort`
      FROM `schoolinfo1282017`.`lernende`;
    ALTER TABLE `lernende`
      ENABLE KEYS;
    UNLOCK TABLES;
    SELECT "Data for 'lernende' has been copied.";
    COMMIT;

    /* 3 - Modules */
    /* Create table */
    START TRANSACTION;
    DROP TABLE IF EXISTS `module`;
    CREATE TABLE `module` (
      `id_modul` INT NOT NULL AUTO_INCREMENT,
      `name` VARCHAR(50) DEFAULT NULL,
      `beschreibung` VARCHAR(255) DEFAULT NULL,
      PRIMARY KEY (`id_modul`)
    )
      ENGINE = InnoDB
      DEFAULT CHARSET = utf8
      COLLATE = utf8_unicode_ci;
    SELECT "Table 'module' has been created.";
    COMMIT;

    /* Copy data */
    START TRANSACTION;
    LOCK TABLES `module` WRITE;
    ALTER TABLE `module` DISABLE KEYS;
    INSERT INTO `module` (id_modul, name, beschreibung)
      SELECT
        `idmodul` AS `id_modul`,
        `m_name` AS `name`,
        `modulname` AS `beschreibung`
      FROM `schoolinfo1282017`.`modul`;
    ALTER TABLE `module`
      ENABLE KEYS;
    UNLOCK TABLES;
    SELECT "Data for 'module' has been copied.";
    COMMIT;

    /* 4 - Marks */
    /* Create table */
    START TRANSACTION;
    DROP TABLE IF EXISTS `noten`;
    CREATE TABLE `noten` (
      `id_note` INT NOT NULL AUTO_INCREMENT,
      `fk_lernender` INT DEFAULT NULL,
      `fk_modul` INT DEFAULT NULL,
      `note_erfahrung` DOUBLE DEFAULT NULL,
      `note_knw` DOUBLE DEFAULT NULL,
      `datum_erfahrungsnote` DATE DEFAULT NULL,
      `datum_knw` DATE NOT NULL,
      PRIMARY KEY (`id_note`),
      FOREIGN KEY (fk_lernender) REFERENCES lernende (id_lernender),
      FOREIGN KEY (fk_modul) REFERENCES module (id_modul)
    )
      ENGINE = InnoDB
      DEFAULT CHARSET = utf8
      COLLATE = utf8_unicode_ci;
    SELECT "Table 'noten' has been created.";
    COMMIT;

    /* Copy data */
    START TRANSACTION;
    LOCK TABLES `noten` WRITE;
    ALTER TABLE `noten` DISABLE KEYS;
    INSERT INTO `noten` (fk_lernender, fk_modul, note_erfahrung, note_knw, datum_erfahrungsnote, datum_knw)
      SELECT
        `lerndende_idlernende` AS `fk_lernender`,
        `module_idmodule` AS `fk_modul`,
        `erfahrungsnote` AS `note_erfahrung`,
        `knw_note` AS `note_knw`,
        `dat_erfa` AS `datum_erfahrungsnote`,
        `dat_knw` AS `datum_knw`
      FROM `schoolinfo1282017`.`noten`;
    ALTER TABLE `noten`
      ENABLE KEYS;
    UNLOCK TABLES;
    SELECT "Data for 'noten' has been copied.";
    COMMIT;

    /* 4 - Orientation */
    /* Create table */
    START TRANSACTION;
    DROP TABLE IF EXISTS `fachrichtungen`;
    CREATE TABLE `fachrichtungen` (
      `id_fachrichtung` INT NOT NULL AUTO_INCREMENT,
      `name` VARCHAR(50) DEFAULT NULL,
      PRIMARY KEY (`id_fachrichtung`)
    )
      ENGINE = InnoDB
      DEFAULT CHARSET = utf8
      COLLATE = utf8_unicode_ci;
    SELECT "Table 'fachrichtungen' has been created.";
    COMMIT;

    /* Copy data */
    START TRANSACTION;
    LOCK TABLES `fachrichtungen` WRITE;
    ALTER TABLE `fachrichtungen` DISABLE KEYS;
    INSERT INTO `fachrichtungen` (id_fachrichtung, name)
      SELECT
        `idrichtung` AS `id_fachrichtung`,
        `richtung` AS `name`
      FROM `schoolinfo1282017`.`richtung`;
    ALTER TABLE `fachrichtungen`
      ENABLE KEYS;
    UNLOCK TABLES;
    SELECT "Data for 'fachrichtungen' has been copied.";
    COMMIT;
  END //
DELIMITER ;
