CREATE DATABASE IF NOT EXISTS schoolinfo_archiv;

USE schoolinfo_archiv;

CREATE TABLE IF NOT EXISTS lernende_archiv (
  id          INT PRIMARY KEY       AUTO_INCREMENT,

  anrede      VARCHAR(25),
  name        VARCHAR(50)  NOT NULL,
  vorname     VARCHAR(50)  NOT NULL,
  geschlecht  ENUM('M','F'),
  bm          TINYINT(1),
  strasse     VARCHAR(50),
  ort         VARCHAR(50),
  plz         VARCHAR(10),

  richtung    VARCHAR(50)  NOT NULL,

  klasse      VARCHAR(10)  NOT NULL,

  lehrbetrieb VARCHAR(100) NOT NULL,
  lbstrasse   VARCHAR(50),
  lbhausnr    VARCHAR(10),
  lbplz       VARCHAR(8),
  lbort       VARCHAR(50),
  lbland      VARCHAR(15),

  modulname   VARCHAR(50)  NOT NULL,

  note_erf    DECIMAL(3, 2),
  note_knw    DECIMAL(3, 2),

  timestamp   DATETIME     NOT NULL DEFAULT current_timestamp

);

