DROP PROCEDURE IF EXISTS `sp_users`;

CREATE PROCEDURE `sp_users`(
  IN benutzer     VARCHAR(100),
  IN passwort     VARCHAR(100),
  IN hostname     VARCHAR(100),
  IN berechtigung VARCHAR(100),
  IN zugriffsort  VARCHAR(100)
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
    END IF;

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
      hostname,
      zugriffsort,
      berechtigung,
      benutzer
    );
  END;
