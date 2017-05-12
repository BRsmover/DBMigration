USE schoolinfo_neu;

CREATE TABLE IF NOT EXISTS log_berechtigung (
  id           INT                                                                                                                                                                                                                                                                                                                                       AUTO_INCREMENT,
  benutzer  VARCHAR(150)               NOT NULL,
  timestamp DATETIME     NOT NULL                                                                                                                                                                                                                                                                                                                     DEFAULT current_timestamp,
  wofuer    VARCHAR(80)  NOT NULL,
  typ       ENUM ('db', 'tab', 'attr') NOT NULL,
  berechtigung VARCHAR(100)            NOT NULL,
  fuer         VARCHAR(80)             NOT NULL,
  PRIMARY KEY (id)
);

/*
id             Primärschlüssel, wird automatisch hochgezählt
benutzer       Benutzer, welcher die Berechtigung vergibt
               (Üblicherweise der angemeldete MySQL-User).
timestamp      Zeit-Stempel, an dem der Eintrag gemacht wurde
               (Default-Wert: Aktuelle Zeit).
wofuer         Der Name, für den die Berechtigung gesetzt wird
               (z.B. 'dbbla', 'dbbla.tabbli', 'dbbla.tabbli.attrblu').
typ            Typ des Attributs "wofuer"
               (kann die Werte 'db', 'tab' oder 'attr' haben).
berechtigung   Die Art der Berechtigung, die der Benutzer erhält
               (z.B. 'select, update, delete').
fuer           Der Benutzer, der die Berechtigung erhält
               (z.B. 'felix@musterpc').
*/