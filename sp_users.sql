DROP PROCEDURE IF EXISTS `sp_users`;

CREATE PROCEDURE `sp_users`(
  IN benutzer     VARCHAR(255),
  IN passwort     VARCHAR(255),
  IN hostname     VARCHAR(255),
  IN berechtigung VARCHAR(255),
  IN zugriffsort  VARCHAR(255)
)

  BEGIN
    /* Input Validation */
    IF benutzer IS NULL OR benutzer = ''
    THEN
      SIGNAL SQLSTATE 'ERROR'
      SET MESSAGE_TEXT = 'Ungültige Eingabe: Benutzer darf nicht leer sein!';
    END IF;
    IF passwort IS NULL OR passwort = ''
    THEN
      SIGNAL SQLSTATE 'ERROR'
      SET MESSAGE_TEXT = 'Ungültige Eingabe: Passwort darf nicht leer sein!';
    END IF;
    IF hostname IS NULL OR hostname = ''
    THEN
      SIGNAL SQLSTATE 'ERROR'
      SET MESSAGE_TEXT = 'Ungültige Eingabe: Hostname darf nicht leer sein!';
    END IF;
    IF berechtigung IS NULL OR berechtigung = ''
    THEN
      SIGNAL SQLSTATE 'ERROR'
      SET MESSAGE_TEXT = 'Ungültige Eingabe: Berechtigungsfeld darf nicht leer sein!';
    ELSE
      SET @berechtigungen = UPPER(berechtigung);
      SET @concattedstring = CONCAT(berechtigung, ',');

      berechtiungsloop: LOOP
        SET @berechtigung = SUBSTRING_INDEX(@berechtigungen, ',', 1);
        SET @concattedstring = TRIM(SUBSTRING(@concattedstring, LENGTH(@berechtigung + 2)));
        SET @berechtigung = TRIM(@berechtigung);
        IF @berechtigung NOT REGEXP '\\s*(\\w|\\s)*\\s*'
        THEN
          BEGIN
            SET @nachricht = CONCAT('Ungültige Berechtigung: ', @berechtigung);
          END;
        END IF;
        IF @concattedstring IS NULL OR @concattedstring = ''
        THEN
          LEAVE berechtiungsloop;
        END IF;
      END LOOP;
    END IF;

    IF zugriffsort IS NOT NULL OR zugriffsort <> ''
    THEN
      BEGIN
        IF zugriffsort REGEXP '\\A(\\w+|\\*)\\z'
        THEN
          SET @art = 'DB';
          IF zugriffsort REGEXP '%*%'
          THEN
            SET @zugriffsort = CONCAT(zugriffsort, '.*');
          ELSE
            SET @zugriffsort = zugriffsort;
          END IF;
        ELSEIF zugriffsort REGEXP '\\A(\\w+|\\*)\\.(\\w+|\\*)\\z'
          THEN
            SET @zugriffsort = zugriffsort;
            SET @art = 'TBL';
        ELSEIF zugriffsort REGEXP '\\A(\\w+|\\*)\\.(\\w+|\\*)\\.(\\w+|\\*)\\z'
          THEN
            SET @zugriffsort = SUBSTRING_INDEX(zugriffsort, '.', 2);
            SET @eigenschaft = TRIM(SUBSTRING(zugriffsort, LENGTH(@zugriffsort) + 2));
            SET @art = 'COL';

            SET @concattedstring = CONCAT(@berechtigungen, ',');
            SET @berechtigungen = '';
            berechtigungsloopneu: LOOP
              SET @berechtigung = SUBSTRING_INDEX(@concattedstring, ',', 1);
              SET @concattedstring = TRIM(SUBSTRING(@concattedstring, LENGTH(@berechtigung) + 2));
              SET @berechtigungen = CONCAT(@berechtigungen, TRIM(@berechtigung), ' (', @eigenschaft, '), ');
              IF @concattedstring IS NULL OR @concattedstring = ''
              THEN
                LEAVE berechtigungsloopneu;
              END IF;
            END LOOP;
            SET @berechtigungen = SUBSTRING(@berechtigungen, 1, LENGTH(@berechtigungen) - 2);
        ELSE
          SIGNAL SQLSTATE 'ERROR'
          SET MESSAGE_TEXT = 'Ungültiger Zugriffsort!';
        END IF;
      END;
    ELSE
      SIGNAL SQLSTATE 'ERROR' SET MESSAGE_TEXT = 'Ungültige Eingabe: Zugriffsort';
    END IF;

    SET @benutzer = CONCAT('\'', benutzer, '\'@\'', hostname, '\'');
    SET @erstellen = CONCAT('CREATE USER ', @benutzer);
    IF passwort IS NOT NULL AND passwort <> ''
    THEN
      SET @erstellen = CONCAT(@erstellen, ' IDENTIFIED BY \'', passwort, '\'');
    END IF;

    PREPARE erstellen FROM @erstellen;
    EXECUTE erstellen;
    DEALLOCATE PREPARE erstellen;

    SET @berechtigung_erteilen = CONCAT('GRANT ' + @berechtigungen);
    SET @berechtigung_erteilen = CONCAT(@berechtigung_erteilen, ' ON ', @zugriffsort);
    SET @berechtigung_erteilen = CONCAT(@berechtigung_erteilen, ' TO ', @benutzer);

    PREPARE berechtigung_erteilen FROM @berechtigung_erteilen;
    EXECUTE berechtigung_erteilen;
    DEALLOCATE PREPARE berechtigung_erteilen;

    INSERT INTO `schoolinfo_neu`.`log_berechtigung` (
      benutzer,
      timestamp,
      wofuer,
      typ,
      berechtigung,
      fuer
    ) VALUES (
      CURRENT_USER(),
      CURRENT_DATE(),
      zugriffsort,
      berechtigung,
      benutzer
    );
  END;
