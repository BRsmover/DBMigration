DROP PROCEDURE IF EXISTS `sp_places`;

CREATE PROCEDURE `sp_places`()
  BEGIN

    /* Declare variables */
    DECLARE id_ort INT(10);
    DECLARE name VARCHAR(50);
    DECLARE plz VARCHAR(10);
    DECLARE lernende_fertig BOOLEAN DEFAULT FALSE;
    DECLARE lehrbetriebe_fertig BOOLEAN DEFAULT FALSE;
    DECLARE lernende_cursor CURSOR FOR SELECT
                                         `id_lernender`,
                                         `plz`,
                                         `ort`
                                       FROM `schoolinfo_neu`.`lernende`;
    DECLARE lehrbetriebe_cursor CURSOR FOR SELECT
                                             `id_lehrbetrieb`,
                                             `plz`,
                                             `ort`
                                           FROM `schoolinfo_neu`.`lehrbetriebe`;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET lernende_fertig = TRUE;

    DROP TABLE IF EXISTS `schoolinfo_neu`.`ortschaften`;

    /* Create table */
    CREATE TABLE `schoolinfo_neu`.`ortschaften` (
      `id_ort` INT(10) AUTO_INCREMENT,
      `name`   VARCHAR(50),
      `plz`    VARCHAR(10),
      PRIMARY KEY (`id_ort`),
      UNIQUE KEY `name_plz` (
        `name`,
        `plz`
      )
    );

    /* Add foreign key columns */
    ALTER TABLE `schoolinfo_neu`.`lernende`
      ADD COLUMN `fk_ort` INT(10) DEFAULT NULL,
      ADD FOREIGN KEY (`fk_ort`) REFERENCES `schoolinfo_neu`.`ortschaften`(`id_ort`);

    ALTER TABLE `schoolinfo_neu`.`lehrbetriebe`
      ADD COLUMN `fk_ort` INT(10) DEFAULT NULL,
      ADD FOREIGN KEY (`fk_ort`) REFERENCES `schoolinfo_neu`.`ortschaften`(`id_ort`);

    OPEN lehrbetriebe_cursor;

    /* Loop to fetch data */
    myloop: LOOP
      IF lehrbetriebe_fertig
      THEN
        BEGIN
          FETCH lernende_cursor
          INTO id_ort,
            name,
            plz;
        END;
      ELSE
        BEGIN
          FETCH lehrbetriebe_cursor
          INTO id_ort,
            name,
            plz;
        END;
      END IF;

      IF lernende_fertig
      THEN
        IF lehrbetriebe_fertig
        THEN
          BEGIN
            CLOSE lernende_cursor;
            LEAVE myloop;
          END;
        ELSE
          BEGIN
            SET lehrbetriebe_fertig = TRUE;
            CLOSE lehrbetriebe_cursor;
            OPEN lernende_cursor;
            SET lernende_fertig = TRUE;
            ITERATE myloop;
          END;
        END IF;
      END IF;

      SET @lernende_fertig = lernende_fertig;

      IF plz IS NOT NULL
      THEN
        SET @id_ort = NULL;
        SELECT
          `id_ort`,
          `name`,
          `plz`
        INTO
          @id_ort,
          @name,
          @plz
        FROM `schoolinfo_neu`.`ortschaften`
        WHERE `name` = name AND `plz` = plz
        LIMIT 1;

        IF @id_ort IS NULL
        THEN
          BEGIN
            INSERT INTO `schoolinfo_neu`.`ortschaften` (
              `name`,
              `plz`
            ) VALUES (
              name,
              plz
            );
            SET @id_ort = LAST_INSERT_ID();
          END;
        END IF;

        IF lehrbetriebe_fertig
        THEN
          UPDATE `schoolinfo_neu`.`lernende`
          SET `id_ort` = @id_ort
          WHERE `id_lernender` = id_ort
          LIMIT 1;
        ELSE
          UPDATE `schoolinfo_neu`.`lehrbetriebe`
          SET `id_ort` = @id_ort
          WHERE `id_lehrbetrieb` = id_ort
          LIMIT 1;
        END IF;

        SET lernende_fertig = @lernende_fertig;
      END IF;
    END LOOP;

    /* Drop old columns */
    ALTER TABLE `schoolinfo_neu`.`lernende`
      DROP COLUMN `plz`,
      DROP COLUMN `ort`;

    /* Drop old columns */
    ALTER TABLE `schoolinfo_neu`.`lehrbetriebe`
      DROP COLUMN `plz`,
      DROP COLUMN `ort`;

  END;
