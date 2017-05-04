DROP PROCEDURE IF EXISTS `sp_migration`;

CREATE PROCEDURE `sp_migration`()
  BEGIN
    DROP DATABASE IF EXISTS `schoolinfo_neu`;

    /* Define settings */
    SET DEFAULT_STORAGE_ENGINE = InnoDB;

    SET CHARACTER_SET_CLIENT = utf8;
    SET CHARACTER_SET_RESULTS = utf8;
    SET CHARACTER_SET_CONNECTION = utf8;

    SET COLLATION_SERVER = utf8_unicode_ci;
    SET COLLATION_DATABASE = utf8_unicode_ci;
    SET COLLATION_CONNECTION = utf8_unicode_ci;

    SET SQL_MODE = 'ALLOW_INVALID_DATES';

    CREATE DATABASE `schoolinfo_neu`;

    /* ----- Create tables  ------ */
    /* Create table for classes */
    CREATE TABLE `schoolinfo_neu`.`klassen` (
      `id_klasse`    INT(10)      NOT NULL AUTO_INCREMENT,
      `id_lehrer`    INT(10)               DEFAULT NULL,
      `name`         VARCHAR(50)  NOT NULL,
      `beschreibung` VARCHAR(255) NOT NULL,
      PRIMARY KEY (`id_klasse`),
      INDEX `id_lehrer` (`id_lehrer`)
    );

    /* Create table for companies */
    CREATE TABLE `schoolinfo_neu`.`lehrbetriebe` (
      `id_lehrbetrieb` INT(10)      NOT NULL AUTO_INCREMENT,
      `name`           VARCHAR(100) NOT NULL,
      `strasse`        VARCHAR(100)          DEFAULT NULL,
      `nummer`         VARCHAR(10)           DEFAULT NULL,
      `plz`            VARCHAR(10)           DEFAULT NULL,
      `ort`            VARCHAR(50)           DEFAULT NULL,
      `kanton`         VARCHAR(50)           DEFAULT NULL,
      `land`           VARCHAR(50)           DEFAULT NULL,
      PRIMARY KEY (`id_lehrbetrieb`)
    );

    /* Create table for orientations */
    CREATE TABLE `schoolinfo_neu`.`fachrichtungen` (
      `id_fachrichtung` INT(10)     NOT NULL AUTO_INCREMENT,
      `name`            VARCHAR(50) NOT NULL,
      PRIMARY KEY (`id_fachrichtung`)
    );

    /* Create table for students */
    CREATE TABLE `schoolinfo_neu`.`lernende` (
      `id_lernender`    INT(10)         NOT NULL AUTO_INCREMENT,
      `anrede`          VARCHAR(25)     NOT NULL,
      `name`            VARCHAR(50)     NOT NULL,
      `vorname`         VARCHAR(50)     NOT NULL,
      `geschlecht`      ENUM ('M', 'F') NOT NULL,
      `fk_klasse`       INT(10)                  DEFAULT NULL,
      `bm`              BOOL            NOT NULL,
      `fk_fachrichtung` INT(10)         NOT NULL,
      `fk_lehrbetrieb`  INT(10)                  DEFAULT NULL,
      `strasse`         VARCHAR(50)              DEFAULT NULL,
      `plz`             VARCHAR(50)              DEFAULT NULL,
      `ort`             VARCHAR(50)              DEFAULT NULL,
      PRIMARY KEY (`id_lernender`),
      FOREIGN KEY (`fk_klasse`) REFERENCES `klassen` (`id_klasse`),
      INDEX `fk_klasse` (`fk_klasse`),
      FOREIGN KEY (`fk_fachrichtung`) REFERENCES `fachrichtungen` (`id_fachrichtung`),
      INDEX `fk_fachrichtung` (`fk_fachrichtung`),
      FOREIGN KEY (`fk_lehrbetrieb`) REFERENCES `lehrbetriebe` (`id_lehrbetrieb`),
      INDEX `fk_lehrbetrieb` (`fk_lehrbetrieb`)
    );

    /* Create table for modules */
    CREATE TABLE `schoolinfo_neu`.`module` (
      `id_modul`     INT(10)     NOT NULL AUTO_INCREMENT,
      `name`         VARCHAR(50) NOT NULL,
      `beschreibung` VARCHAR(255)         DEFAULT NULL,
      PRIMARY KEY (`id_modul`)
    );

    /* Create table for marks */
    CREATE TABLE `schoolinfo_neu`.`noten` (
      `fk_lernender`         INT(10)       NOT NULL,
      `fk_modul`             INT(10)       NOT NULL,
      `note_knw`             DECIMAL(3, 2) NOT NULL,
      `note_erfahrung`       DECIMAL(3, 2) NOT NULL,
      `datum_erfahrungsnote` DATETIME DEFAULT NULL,
      `datum_knw`            DATETIME DEFAULT NULL,
      FOREIGN KEY (`fk_lernender`) REFERENCES lernende (`id_lernender`)
        ON DELETE CASCADE,
      INDEX `fk_lernender` (`fk_lernender`),
      FOREIGN KEY (`fk_modul`) REFERENCES module (`id_modul`),
      INDEX `fk_modul` (`fk_modul`)
    );

    /* ----- Create column for old PKs ----- */
    ALTER TABLE `schoolinfo_neu`.`klassen`
      ADD COLUMN id_old INT(10) NOT NULL;
    ALTER TABLE `schoolinfo_neu`.`fachrichtungen`
      ADD COLUMN id_old INT(10) NOT NULL;
    ALTER TABLE `schoolinfo_neu`.`lehrbetriebe`
      ADD COLUMN id_old INT(10) NOT NULL;
    ALTER TABLE `schoolinfo_neu`.`lernende`
      ADD COLUMN id_old INT(10) NOT NULL;
    ALTER TABLE `schoolinfo_neu`.`module`
      ADD COLUMN id_old INT(10) NOT NULL;
    ALTER TABLE `schoolinfo_neu`.`noten`
      ADD COLUMN id_old_lernender INT(10) NOT NULL,
      ADD COLUMN id_old_modul INT(10) NOT NULL;


    /* ----- Copy Data ----- */
    /* Migrate orientations */
    INSERT INTO `schoolinfo_neu`.`fachrichtungen` (`id_old`, `name`)
      SELECT
        `idrichtung` AS `id_old`,
        `richtung`   AS `name`
      FROM `schoolinfo1282017`.`richtung`;

    INSERT INTO `schoolinfo_neu`.`klassen` (id_old, id_lehrer, name, beschreibung)
      SELECT
        `idklasse`      AS `id_old`,
        `klassenlehrer` AS `id_lehrer`,
        `name`          AS `name`,
        `realname`      AS `beschreibung`
      FROM `schoolinfo1282017`.`klasse`;

    /* Migrate companies */
    INSERT INTO `schoolinfo_neu`.`lehrbetriebe` (`id_old`, `name`, `strasse`, `nummer`, `plz`, `ort`, `kanton`, `land`)
      SELECT
        `id_Lehrbetrieb`                       AS `id_old`,
        `FName`                                AS `name`,
        `FStrasse`                             AS `strasse`,
        `FHausNr`                              AS `nummer`,
        `FPlz`                                 AS `plz`,
        `FOrt`                                 AS `ort`,
        `FKanton`                              AS `kanton`,
        IF(`FLand` = 'Schweiz', 'CH', `FLand`) AS `land`
      FROM `schoolinfo1282017`.`lehrbetriebe`;

    UPDATE `schoolinfo_neu`.`lehrbetriebe`
    SET
      `strasse` = IF(`strasse` = '', NULL, `strasse`),
      `nummer`  = IF(`nummer` = '', NULL, `nummer`),
      `kanton`  = IF(`kanton` = '', NULL, `kanton`),
      `land`    = IF(`land` = '', NULL, `land`);

    /* Migrate classes */
    INSERT INTO `schoolinfo_neu`.`klassen` (`id_old`, `id_lehrer`, `name`, `beschreibung`)
      SELECT DISTINCT
        CONCAT('foobar-', `lernender`.`klasse`) AS `name`,
        CONCAT('foobar-', `lernender`.`klasse`) AS `beschreibung`,
        NULL                                    AS `id_lehrer`,
        `lernender`.`klasse`                    AS `id_old`
      FROM `schoolinfo1282017`.`lernende` AS `lernender`
        INNER JOIN `schoolinfo1282017`.`klasse` AS `k`
          ON `k`.`idklasse` = `lernender`.`klasse`
      WHERE `k`.`idklasse` IS NULL;

    /* Migrate students */
    INSERT INTO `schoolinfo_neu`.`lernende` (`id_old`, `anrede`, `name`, `vorname`, `geschlecht`, `fk_klasse`, `bm`, `fk_fachrichtung`, `fk_lehrbetrieb`, `strasse`, `plz`, `ort`)
      SELECT
        `lernender`.`Lern_id`                                       AS `id_old`,
        `lernender`.`anrede`                                        AS `anrede`,
        `lernender`.`name`                                          AS `name`,
        `lernender`.`vorname`                                       AS `vorname`,
        IF(`lernender`.`geschlecht` REGEXP '[Mm].*', 'M', 'F')      AS `geschlecht`,
        `klassen`.`id_klasse`                                       AS `fk_klasse`,
        IF(`lernender`.`bm` = 0, FALSE, TRUE)                       AS `bm`,
        `fachrichtungen`.`id_fachrichtung`                          AS `fk_fachrichtung`,
        `lehrbetriebe`.`id_Lehrbetrieb`                             AS `fk_lehrbetrieb`,
        IF(`lernender`.`strasse` = '', NULL, `lernender`.`strasse`) AS `strasse`,
        IF(`lernender`.`plz` = '', NULL, `lernender`.`plz`)         AS `plz`,
        `lernender`.`ort`                                           AS `ort`
      FROM `schoolinfo1282017`.`lernende` AS `lernender`
        LEFT JOIN `schoolinfo_neu`.`klassen` ON `klassen`.`id_old` = `lernender`.`klasse`
        LEFT JOIN `schoolinfo_neu`.`fachrichtungen` ON `fachrichtungen`.`id_old` = `lernender`.`richtung`
        LEFT JOIN `schoolinfo_neu`.`lehrbetriebe` ON `lehrbetriebe`.`id_old` = `lernender`.`lehrbetrieb`;

    /* Migrate modules */
    INSERT INTO `schoolinfo_neu`.`module` (`id_old`, `name`, `beschreibung`)
      SELECT
        `idmodul`   AS `id_old`,
        `m_name`    AS `name`,
        `modulname` AS `beschreibung`
      FROM `schoolinfo1282017`.`modul`;

    /* Migrate marks */
    INSERT INTO `schoolinfo_neu`.`noten` (`fk_lernender`, `fk_modul`, `note_erfahrung`, `note_knw`, `datum_erfahrungsnote`, `datum_knw`, `id_old_lernender`, `id_old_modul`)
      SELECT
        `lernender`.`id_lernender` AS `fk_lernender`,
        `modul`.`id_modul`         AS `fk_modul`,
        `note`.`erfahrungsnote`    AS `note_erfahrung`,
        `note`.`knw_note`          AS `note_knw`,
        `note`.`dat_erfa`          AS `datum_erfahrungsnote`,
        `note`.`dat_knw`           AS `datum_knw`,
        `lernender`.`id_old`       AS `id_old_lernender`,
        `modul`.`id_old`           AS `id_old_modul`
      FROM `schoolinfo1282017`.`noten` AS `note`
        LEFT JOIN `schoolinfo_neu`.`module` AS `modul` ON `modul`.`id_old` = `note`.`module_idmodule`
        LEFT JOIN `schoolinfo_neu`.`lernende` AS `lernender` ON `lernender`.`id_old` = `note`.`lernende_idLernende`
      WHERE `lernender`.`id_lernender` IS NOT NULL;


    /* ----- Delete old IDs ----- */
    ALTER TABLE `schoolinfo_neu`.`klassen`
      DROP COLUMN `id_old`;
    ALTER TABLE `schoolinfo_neu`.`fachrichtungen`
      DROP COLUMN `id_old`;
    ALTER TABLE `schoolinfo_neu`.`lehrbetriebe`
      DROP COLUMN `id_old`;
    ALTER TABLE `schoolinfo_neu`.`lernende`
      DROP COLUMN `id_old`;
    ALTER TABLE `schoolinfo_neu`.`module`
      DROP COLUMN `id_old`;
    ALTER TABLE `schoolinfo_neu`.`noten`
      DROP COLUMN `id_old_lernender`,
      DROP COLUMN `id_old_modul`;

  END;
