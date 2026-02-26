# SQL JSON Data Migration Tool

[English](#english) | [Deutsch](#deutsch)

---

<a name="english"></a>
## 🇬🇧 English

### Project Overview
A robust T-SQL utility designed to extract, transform, and migrate complex, nested JSON product data into structured relational SQL tables. This project demonstrates advanced SQL techniques for handling modern data formats in enterprise environments.

### 📂 Repository Structure
* `sql/`: Contains the core migration script (`migration_script.sql`).
* `data/`: Contains the standardized sample dataset (`sample_product.json`).

### Key Features
* **Automated Parsing**: Extracts deep-nested objects (Variants, Specs, Brands) using `OPENJSON` and `CROSS APPLY`.
* **Dual Mode Support**: Capability to load data from physical files or internal staging tables.
* **Data Integrity**: Implements robust error handling with `TRY...CATCH` blocks.
* **Clean Schema**: Migrates data into normalized tables (Products, Categories, Variants, Attributes).

### Usage
1.  Clone the repository.
2.  Open `sql/migration_script.sql` in SQL Server Management Studio (SSMS).
3.  Update the `@JSONFilePath` variable to match the location of `data/sample_product.json` on your machine.
4.  Execute the script to see the transformation in action.

---

<a name="deutsch"></a>
## 🇩🇪 Deutsch

### Projektübersicht
Ein robustes T-SQL-Utility zum Extrahieren, Transformieren und Migrieren komplexer, verschachtelter JSON-Produktdaten in strukturierte relationale SQL-Tabellen. Dieses Projekt demonstriert fortgeschrittene SQL-Techniken zur Handhabung moderner Datenformate in Unternehmensumgebungen.

### 📂 Repository-Struktur
* `sql/`: Enthält das Haupt-Migrationsskript (`migration_script.sql`).
* `data/`: Enthält den standardisierten Beispieldatensatz (`sample_product.json`).

### Hauptmerkmale
* **Automatisches Parsing**: Extrahiert tief verschachtelte Objekte (Varianten, Spezifikationen, Marken) mittels `OPENJSON` und `CROSS APPLY`.
* **Duale Modus-Unterstützung**: Lädt Daten entweder aus physischen Dateien oder aus internen Staging-Tabellen.
* **Datenintegrität**: Implementiert robuste Fehlerbehandlung durch `TRY...CATCH`-Blöcke.
* **Sauberes Schema**: Migriert Daten in normalisierte Tabellen (Produkte, Kategorien, Varianten, Attribute).

### Verwendung
1.  Klonen Sie das Repository.
2.  Öffnen Sie `sql/migration_script.sql` im SQL Server Management Studio (SSMS).
3.  Passen Sie die Variable `@JSONFilePath` an den Speicherort von `data/sample_product.json` auf Ihrem Rechner an.
4.  Führen Sie das Skript aus, um die Datentransformation zu starten.
