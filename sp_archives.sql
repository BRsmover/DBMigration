DROP PROCEDURE IF EXISTS `sp_archives`;

CREATE PROCEDURE `sp_archives`(
  IN klasse VARCHAR(255)
) BEGIN
  SET @id_klasse = (
    SELECT `id_klasse`
    FROM `schoolinfo_neu`.`klassen`
    WHERE `name` = klasse
    LIMIT 1
  );

  INSERT INTO `schoolinfo_archiv`.`lernende_archiv` (
    `anrede`,
    `name`,
    `vorname`,
    `geschlecht`,
    `bm`,
    `strasse`,
    `ort`,
    `plz`,
    `richtung`,
    `klasse`,
    `lehrbetrieb`,
    `lbstrasse`,
    `lbhausnr`,
    `lbplz`,
    `lbort`,
    `lbland`,
    `note_erf`,
    `note_knw`
  ) SELECT
      `lernender`.`anrede`,
      `lernender`.`name`,
      `lernender`.`vorname`,
      `lernender`.`geschlecht`,
      `lernender`.`bm`,
      `lernender`.`strasse`,
      `lernender_ort`.`name`,
      `lernender_ort`.`plz`,
      `klasse`.`name`,
      `klasse`.`beschreibung`,
      `richtung`.`name`,
      `lehrbetrieb`.`name`,
      `lehrbetrieb`.`strasse`,
      `lehrbetrieb`.`nummer`,
      `lehrbetrieb_ort`.`plz`,
      `lehrbetrieb_ort`.`name`,
      `note`.`note_erfahrung`,
      `note`.`note_knw`
    FROM `schoolinfo_neu`.`lernende` AS `lernender`
      LEFT JOIN `schoolinfo_neu`.`klassen` AS `klasse`
        ON `klasse`.`id_klasse` = `lernender`.`fk_klasse`
      LEFT JOIN `schoolinfo_neu`.`ortschaften` AS `lernender_ort`
        ON `lernender_ort`.`id_ort` = `lernender`.`fk_ort`
      LEFT JOIN `schoolinfo_neu`.`module` AS `richtung`
        ON `richtung`.`id_modul` = `lernender`.`fk_fachrichtung`
      LEFT JOIN `schoolinfo_neu`.`lehrbetriebe` AS `lehrbetrieb`
        ON `lehrbetrieb`.`id_lehrbetrieb` = `lernender`.`fk_lehrbetrieb`
      LEFT JOIN `schoolinfo_neu`.`ortschaften` AS `lehrbetrieb_ort`
        ON `lehrbetrieb_ort`.`id_ort` = `lehrbetrieb`.`fk_ort`
      LEFT JOIN `schoolinfo_neu`.`noten` AS `note`
        ON `note`.`fk_lernender` = `lernender`.`id_lernender`
    WHERE `id_klasse` = @id_klasse;

  DELETE FROM `schoolinfo_neu`.`noten`
  WHERE `fk_lernender` IN (
    SELECT *
    FROM (
           SELECT `lernende`.`id_lernender` AS `idl`
           FROM `schoolinfo_neu`.`noten` AS `note`
             LEFT JOIN `schoolinfo_neu`.`lernende` AS `lernender`
               ON `lernender`.`id_lernender` = `note`.`fk_lernender`
           WHERE `lernender`.`fk_klasse` = @id_klasse
         ) AS `auswahl`
  );

END;