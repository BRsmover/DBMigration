DROP PROCEDURE IF EXISTS `sp_users`;

CREATE PROCEDURE `sp_users`(
  IN benutzer       VARCHAR(255),
  IN passwort       VARCHAR(255),
  IN hostname       VARCHAR(255),
  IN berechtigungen VARCHAR(255),
  IN zugriffsort    VARCHAR(255)
)

  BEGIN
    /* Input Validation */
    IF (ISNULL(benutzer, '') = '')
    THEN
      SELECT "Ungültige Eingabe: Benutzer darf nicht leer sein!";
    END IF;
    IF (ISNULL(passwort, '') = '') THEN
      SELECT "Ungültige Eingabe: Benutzer darf nicht leer sein!";
    END IF;
    IF (ISNULL(hostname, '') = '') THEN
      SELECT "Ungültige Eingabe: Hostname darf nicht leer sein!";
    END IF;
    IF (ISNULL(berechtigungen, '') = '') THEN
      SELECT "Ungültige Eingabe: Berechtigungen dürfen nicht leer sein!";
    END IF;
    IF (ISNULL(zugriffsort, '') = '') THEN
      SELECT "Ungültige Eingabe: Zugriffsort darf nicht leer sein!";
    END IF;

    /**/
    
END;
