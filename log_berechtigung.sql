USE schoolinfo_neu;

DROP TABLE IF EXISTS log_berechtigung;

CREATE TABLE IF NOT EXISTS log_berechtigung (
  id           INT                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   AUTO_INCREMENT,
  benutzer    VARCHAR(100)               NOT NULL,
  timestamp   DATETIME     NOT NULL                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 DEFAULT current_timestamp,
  wofuer VARCHAR(100) NOT NULL,
  typ         ENUM ('DB', 'TBL', 'ATTR') NOT NULL,
  berechtigung VARCHAR(100)              NOT NULL,
  fuer         VARCHAR(100)              NOT NULL,
  PRIMARY KEY (id)
);
