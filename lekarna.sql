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
  IF :NEW.Nazev IS NULL THEN 
    :NEW.Nazev := DBMS_RANDOM.STRING('X', 10);
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

COMMIT;
