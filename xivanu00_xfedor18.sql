--Drop old Foreign Keys before start
ALTER TABLE LekNaPredpis DROP CONSTRAINT FK_LekNaPredpis_Lek_Nazev;
ALTER TABLE Prispevek DROP CONSTRAINT FK_Prispevek_LekNaPredpis_Nazev;
ALTER TABLE Prispevek DROP CONSTRAINT FK_Prispevek_Pojistovna_ICO;
ALTER TABLE Vydani DROP CONSTRAINT FK_Vydani_Lek_Nazev;
ALTER TABLE Vykaz DROP CONSTRAINT FK_Vykaz_LekNaPredpis_Nazev;
ALTER TABLE Vykaz DROP CONSTRAINT FK_Vykaz_Pojistovna_ICO;
ALTER TABLE Vykaz DROP CONSTRAINT FK_Vykaz_Prispevek_ID;

--Drop old Tables before start
DROP TABLE Lek;
DROP TABLE LekNaPredpis;
DROP TABLE Pojistovna;
DROP TABLE Prispevek;
DROP TABLE Vykaz;
DROP TABLE Vydani;

--Drop Sequences
DROP SEQUENCE seq_Pojistovna_ICO;
DROP SEQUENCE seq_Prispevek_ID;
DROP SEQUENCE seq_Vydani_ID;
DROP SEQUENCE seq_Vykaz_ID;

--Drop Trigger
DROP TRIGGER rand_Nazev_Trigger;
DROP TRIGGER rand_Lek_Nazev_Trigger;

--Generalization -> one table for higher-level entity and one for its subtype
CREATE TABLE Lek (
  Nazev VARCHAR(255) NOT NULL,
  dostupnost INTEGER,
  nutnostPredpisu INTEGER,
  cenaLeku INTEGER,
  mnozstvi INTEGER
);

--Generate random Nazev if NULL with DBMS_RANDOM.STRING Oracle function
CREATE OR REPLACE TRIGGER rand_Nazev_Trigger
  BEFORE INSERT ON Lek
  FOR EACH ROW
BEGIN
  IF :NEW.Nazev IS NULL THEN 
    :NEW.Nazev := DBMS_RANDOM.STRING('X', 10);
  END IF;
END;
/

CREATE TABLE LekNaPredpis (
  Lek_Nazev VARCHAR(255) NOT NULL,
  doporuceni VARCHAR(255)
);

CREATE OR REPLACE TRIGGER rand_Lek_Nazev_Trigger
  BEFORE INSERT ON LekNaPredpis
  FOR EACH ROW
BEGIN
  IF :NEW.Lek_Nazev IS NULL THEN 
    :NEW.Lek_Nazev := DBMS_RANDOM.STRING('X', 10);
  END IF;
END;
/

CREATE SEQUENCE seq_Pojistovna_ICO START WITH 1 INCREMENT BY 1;
CREATE TABLE Pojistovna (
  ICO INTEGER DEFAULT seq_Pojistovna_ICO.nextval NOT NULL,
  nazevPojistovny VARCHAR(255),
  --Transformation of "adresa":
  ulice VARCHAR(255),
  mesto VARCHAR(255),
  PSC INTEGER
);

CREATE SEQUENCE seq_Prispevek_ID START WITH 1 INCREMENT BY 1;
CREATE TABLE Prispevek (
  ID NUMBER DEFAULT seq_Prispevek_ID.nextval NOT NULL,
  Pojistovna_ICO INTEGER,
  LekNaPredpis_Nazev VARCHAR(255),
  castka INTEGER
);

CREATE SEQUENCE seq_Vydani_ID START WITH 1 INCREMENT BY 1;
CREATE TABLE Vydani (
  ID NUMBER DEFAULT seq_Vydani_ID.nextval NOT NULL,
  Lek_Nazev VARCHAR(255),
  mnozstviProdane INTEGER
);

CREATE SEQUENCE seq_Vykaz_ID START WITH 1 INCREMENT BY 1;
CREATE TABLE Vykaz (
  ID NUMBER DEFAULT seq_Vykaz_ID.nextval NOT NULL,
  Pojistovna_ICO INTEGER,
  LekNaPredpis_Nazev VARCHAR(255),
  Prispevek_ID INTEGER,
  jmenoZakaznika VARCHAR(255)
);

ALTER TABLE Lek ADD CONSTRAINT PK_Lek PRIMARY KEY (Nazev);

ALTER TABLE LekNaPredpis ADD CONSTRAINT PK_LekNaPredpis PRIMARY KEY (Lek_Nazev);
ALTER TABLE LekNaPredpis ADD CONSTRAINT FK_LekNaPredpis_Lek_Nazev FOREIGN KEY (Lek_Nazev) REFERENCES Lek;

ALTER TABLE Pojistovna ADD CONSTRAINT PK_Pojistovna PRIMARY KEY (ICO);
--Check if ICO is exactly 8 numbers
ALTER TABLE Pojistovna ADD CONSTRAINT CHECK_ICO_SYMB CHECK (REGEXP_LIKE(ICO, '^[0-9]{8}$'));

ALTER TABLE Prispevek ADD CONSTRAINT PK_Prispevek PRIMARY KEY (ID);
ALTER TABLE Prispevek ADD CONSTRAINT FK_Prispevek_Pojistovna_ICO FOREIGN KEY (Pojistovna_ICO) REFERENCES Pojistovna;
ALTER TABLE Prispevek ADD CONSTRAINT FK_Prispevek_LekNaPredpis_Nazev FOREIGN KEY (LekNaPredpis_Nazev) REFERENCES LekNaPredpis;

ALTER TABLE Vydani ADD CONSTRAINT PK_Vydani PRIMARY KEY (ID);
ALTER TABLE Vydani ADD CONSTRAINT FK_Vydani_Lek_Nazev FOREIGN KEY (Lek_Nazev) REFERENCES Lek;

ALTER TABLE Vykaz ADD CONSTRAINT PK_Vykaz PRIMARY KEY (ID);
ALTER TABLE Vykaz ADD CONSTRAINT FK_Vykaz_Pojistovna_ICO FOREIGN KEY (Pojistovna_ICO) REFERENCES Pojistovna;
ALTER TABLE Vykaz ADD CONSTRAINT FK_Vykaz_LekNaPredpis_Nazev FOREIGN KEY (LekNaPredpis_Nazev) REFERENCES LekNaPredpis;
ALTER TABLE Vykaz ADD CONSTRAINT FK_Vykaz_Prispevek_ID FOREIGN KEY (Prispevek_ID) REFERENCES Prispevek;

INSERT INTO Lek (Nazev, dostupnost, nutnostPredpisu, cenaLeku, mnozstvi)
VALUES('Ibuprofen', 1, 0, 199, 27);
INSERT INTO Lek (Nazev, dostupnost, nutnostPredpisu, cenaLeku, mnozstvi)
VALUES('Multivitamin', 0, 0, 599, 0);
INSERT INTO Lek (Nazev, dostupnost, nutnostPredpisu, cenaLeku, mnozstvi)
VALUES('Antibiotikum', 1, 1, 249, 1002);
INSERT INTO Lek (Nazev, dostupnost, nutnostPredpisu, cenaLeku, mnozstvi)
VALUES('AntibiotikumNova', 1, 1, 1049, 2);
INSERT INTO Lek (Nazev, dostupnost, nutnostPredpisu, cenaLeku, mnozstvi)
VALUES('Trittico', 0, 1, 149, 0);

INSERT INTO LekNaPredpis (Lek_Nazev, doporuceni)
VALUES('Antibiotikum', '1x denne');
INSERT INTO LekNaPredpis (Lek_Nazev, doporuceni)
VALUES('AntibiotikumNova', 'nepouzivat pri nachlazeni');
INSERT INTO LekNaPredpis (Lek_Nazev, doporuceni)
VALUES('Trittico', '1x vecer');

INSERT INTO Pojistovna (ICO, nazevPojistovny, ulice, mesto, PSC)
VALUES(12345678, 'VZP', 'Nadrazni', 'Prague', 15000);
INSERT INTO Pojistovna (ICO, nazevPojistovny, ulice, mesto, PSC)
VALUES(82345671, 'pVZP', 'Kolejni', 'Brno', 61200);

INSERT INTO Prispevek (Pojistovna_ICO, LekNaPredpis_Nazev, castka)
VALUES(12345678, 'Antibiotikum', 50);
INSERT INTO Prispevek (Pojistovna_ICO, LekNaPredpis_Nazev, castka)
VALUES(82345671, 'Antibiotikum', 55);
INSERT INTO Prispevek (Pojistovna_ICO, LekNaPredpis_Nazev, castka)
VALUES(12345678, 'AntibiotikumNova', 100);
INSERT INTO Prispevek (Pojistovna_ICO, LekNaPredpis_Nazev, castka)
VALUES(82345671, 'AntibiotikumNova', 99);

INSERT INTO Vydani (Lek_Nazev, mnozstviProdane)
VALUES('Ibuprofen', 2);
INSERT INTO Vydani (Lek_Nazev, mnozstviProdane)
VALUES('Ibuprofen', 3);

INSERT INTO Vykaz (Pojistovna_ICO, LekNaPredpis_Nazev, Prispevek_ID, jmenoZakaznika)
VALUES (12345678, 'Antibiotikum', 1, 'Honza');
INSERT INTO Vykaz (Pojistovna_ICO, LekNaPredpis_Nazev, Prispevek_ID, jmenoZakaznika)
VALUES (12345678, 'AntibiotikumNova', 1, 'Hana');

COMMIT;

SELECT *
FROM Prispevek
JOIN Pojistovna ON Prispevek.Pojistovna_ICO = Pojistovna.ICO;

SELECT *
FROM Vykaz
JOIN LekNaPredpis ON Vykaz.LekNaPredpis_Nazev = LekNaPredpis.Lek_Nazev;

SELECT vk.jmenoZakaznika, pr.castka, lnp.doporuceni
FROM Vykaz vk
JOIN Prispevek pr ON vk.Prispevek_ID = pr.ID
JOIN LekNaPredpis lnp ON vk.LekNaPredpis_Nazev = lnp.Lek_Nazev;

SELECT l.Nazev, SUM(vd.mnozstviProdane) AS TotalSell
FROM Lek l
JOIN Vydani vd ON l.Nazev = vd.Lek_Nazev
GROUP BY l.Nazev;

SELECT ps.nazevPojistovny, lnp.Lek_Nazev, SUM(pr.castka) AS TotalForMed
FROM Pojistovna ps
JOIN Prispevek pr ON ps.ICO = pr.Pojistovna_ICO
JOIN LekNaPredpis lnp ON pr.LekNaPredpis_Nazev = lnp.Lek_Nazev
GROUP BY ps.nazevPojistovny, lnp.Lek_Nazev;

SELECT lnp.Lek_Nazev as LekySPrispevkem
FROM LekNaPredpis lnp
WHERE EXISTS (
  SELECT *
  FROM Prispevek pr
  WHERE pr.LekNaPredpis_Nazev = lnp.Lek_Nazev
);

SELECT SUM(pr.castka) as TotalMoneyInBrno
FROM Prispevek pr
WHERE pr.Pojistovna_ICO IN (
  SELECT ps.ICO
  FROM Pojistovna ps
  WHERE mesto = 'Brno'
);
