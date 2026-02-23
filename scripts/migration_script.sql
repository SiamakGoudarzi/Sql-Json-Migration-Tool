--------------------------------------------------------------------------------
-- PROJECT: Advanced JSON to Relational Data Migration
-- SOURCE CODE ORIGIN: 2024 (Migrated to GitHub in 2026)
--------------------------------------------------------------------------------
-- DESCRIPTION:
-- This script provides a production-grade solution for extracting nested JSON
-- data into normalized SQL Server tables. It utilizes OPENJSON and CROSS APPLY
-- to ensure high performance and data integrity.
--
-- TECHNICAL STACK:
-- * T-SQL (SQL Server 2016+)
-- * JSON Parsing (JSON_VALUE, OPENJSON)
-- * Schema Design (Normalization)
--------------------------------------------------------------------------------
/* * Project: JSON to Relational Schema Migration
 * Developed by: [Siamak Goudarzi / GitHub SiamakGoudarzi]
 * * Description: 
 * Optimized T-SQL script to parse complex product JSON data 
 * into normalized database tables.
 */

SET NOCOUNT ON;

-- CONFIGURATION
DECLARE @MigrationMode INT = 1; -- 1: File Loading | 2: Internal Table
DECLARE @JSONFilePath  NVARCHAR(MAX) = 'C:\YourPath\sample_product.json'; 

-- DATABASE SETUP
DROP TABLE IF EXISTS dbo.TempCategory;
DROP TABLE IF EXISTS dbo.TempProduct;
DROP TABLE IF EXISTS dbo.TempOptionValue;
DROP TABLE IF EXISTS dbo.TempVariant;

CREATE TABLE dbo.TempCategory (
    Id   BIGINT PRIMARY KEY, 
    Code NVARCHAR(500)
);

CREATE TABLE dbo.TempProduct (
    Id           BIGINT PRIMARY KEY, 
    Product_Name NVARCHAR(1000), 
    CategoryId   BIGINT, 
    Brand_Name   NVARCHAR(500), 
    Review       NVARCHAR(MAX)
);

CREATE TABLE dbo.TempOptionValue (
    Product_Id BIGINT, 
    Attr_Name  NVARCHAR(1000), 
    Attr_Value NVARCHAR(2000)
);

CREATE TABLE dbo.TempVariant (
    Id         BIGINT PRIMARY KEY, 
    Product_Id BIGINT, 
    Warranty   NVARCHAR(1000), 
    Color      NVARCHAR(100), 
    Seller     NVARCHAR(1000), 
    Price      DECIMAL(18,2)
);

-- DATA ACQUISITION
DECLARE @Json NVARCHAR(MAX);

IF @MigrationMode = 1
BEGIN
    PRINT 'Loading local JSON file...';
    DECLARE @SqlLoadQuery NVARCHAR(MAX) = N'SELECT @ContentOut = BulkColumn FROM OPENROWSET (BULK ''' + @JSONFilePath + ''', SINGLE_CLOB) AS j';
    
    BEGIN TRY
        EXEC sp_executesql @SqlLoadQuery, N'@ContentOut NVARCHAR(MAX) OUTPUT', @ContentOut = @Json OUTPUT;
    END TRY
    BEGIN CATCH
        PRINT 'ERROR: Check file path or SQL Server permissions.';
        RETURN;
    END CATCH
END

-- CORE PROCESSING
IF @Json IS NOT NULL AND ISJSON(@Json) = 1
BEGIN
    DECLARE @ProductId BIGINT = JSON_VALUE(@Json, '$.data.product.id');

    BEGIN TRY
        -- Category Mapping
        INSERT INTO dbo.TempCategory (Id, Code) 
        VALUES (
            JSON_VALUE(@Json, '$.data.product.category.id'), 
            JSON_VALUE(@Json, '$.data.product.category.code')
        );

        -- Product Mapping
        INSERT INTO dbo.TempProduct (Id, Product_Name, CategoryId, Brand_Name, Review)
        VALUES (
            @ProductId, 
            JSON_VALUE(@Json, '$.data.product.title_en'), 
            JSON_VALUE(@Json, '$.data.product.category.id'), 
            JSON_VALUE(@Json, '$.data.product.brand.title_en'),
            JSON_VALUE(@Json, '$.data.product.expert_reviews.description')
        );

        -- Specification Attributes Mapping
        INSERT INTO dbo.TempOptionValue (Product_Id, Attr_Name, Attr_Value)
        SELECT @ProductId, 
               JSON_VALUE(attr.Value, '$.title'), 
               attrval.Value
        FROM OPENJSON(@Json, '$.data.product.specifications[0].attributes') attr
        CROSS APPLY OPENJSON(attr.Value, '$.values') attrval;

        -- Variant & Pricing Mapping
        INSERT INTO dbo.TempVariant (Id, Product_Id, Warranty, Color, Seller, Price)
        SELECT JSON_VALUE(v.Value, '$.id'), 
               @ProductId, 
               JSON_VALUE(v.Value, '$.warranty.title_en'),
               JSON_VALUE(v.Value, '$.color.title'), 
               JSON_VALUE(v.Value, '$.seller.title'),
               JSON_VALUE(v.Value, '$.price.selling_price')
        FROM OPENJSON(@Json, '$.data.product.variants') v;

        PRINT 'SUCCESS: Data migration finished.';
        
        -- Validation Output
        SELECT * FROM dbo.TempProduct;
        SELECT * FROM dbo.TempVariant;

    END TRY
    BEGIN CATCH
        PRINT 'Critical Error during parsing: ' + ERROR_MESSAGE();
    END CATCH
END
ELSE 
BEGIN
    PRINT 'ERROR: JSON source is empty or invalid.';

END

