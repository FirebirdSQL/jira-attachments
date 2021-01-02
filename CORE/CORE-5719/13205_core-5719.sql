/******************************************************************************/
/***                                Domains                                 ***/
/******************************************************************************/

CREATE DOMAIN "Boolean" AS
SMALLINT
CHECK (value in (0, 1) or value is null);

CREATE DOMAIN "Date" AS
DATE;

CREATE DOMAIN "DateTime" AS
TIMESTAMP;

CREATE DOMAIN "ExtremeText" AS
VARCHAR(30000);

CREATE DOMAIN "LongID" AS
INTEGER
CHECK (value >= 0 or value is null);

CREATE DOMAIN "LongInt" AS
INTEGER;

CREATE DOMAIN "LongPrice" AS
NUMERIC(8,4)
CHECK (value >= 0 or value is NULL);

CREATE DOMAIN "LongQuantity" AS
INTEGER
DEFAULT 0
NOT NULL
CHECK (value >= 0);

CREATE DOMAIN "LongText" AS
VARCHAR(64);

CREATE DOMAIN "Memo" AS
BLOB SUB_TYPE 1 SEGMENT SIZE 80;

CREATE DOMAIN "Price" AS
NUMERIC(8,2)
DEFAULT 0
NOT NULL
CHECK (value >= 0);

CREATE DOMAIN "ShortID" AS
SMALLINT
CHECK (value >= 0 or value is null);

CREATE DOMAIN "ShortInt" AS
SMALLINT;

CREATE DOMAIN "ShortMoney" AS
NUMERIC(8,2)
DEFAULT 0
NOT NULL;

CREATE DOMAIN "ShortQuantity" AS
SMALLINT
DEFAULT 0
NOT NULL
CHECK (value >= 0);

CREATE DOMAIN "ShortText" AS
VARCHAR(32);

CREATE DOMAIN "Single" AS
NUMERIC(8,2);


/******************************************************************************/
/***                                 Tables                                 ***/
/******************************************************************************/



CREATE TABLE "Branches" (
    "BranID"            "ShortID" NOT NULL /* "ShortID" = SMALLINT CHECK (value >= 0 or value is null) */,
    "BranPos"           "LongInt" NOT NULL /* "LongInt" = INTEGER */,
    GUID                "LongInt" NOT NULL /* "LongInt" = INTEGER */,
    "BranName"          "ShortText" NOT NULL /* "ShortText" = VARCHAR(32) */,
    "BranName2"         "ShortText" NOT NULL /* "ShortText" = VARCHAR(32) */,
    "Rating"            "ShortInt" DEFAULT 0 NOT NULL /* "ShortInt" = SMALLINT */,
    "CurrType"          "Boolean" DEFAULT 0 NOT NULL /* "Boolean" = SMALLINT CHECK (value in (0, 1) or value is null) */,
    "USDRate"           "LongPrice" NOT NULL /* "LongPrice" = NUMERIC(8,4) CHECK (value >= 0 or value is NULL) */,
    "BranType"          "ShortInt" DEFAULT 0 NOT NULL /* "ShortInt" = SMALLINT */,
    "Flags"             "LongInt" DEFAULT 1 NOT NULL /* "LongInt" = INTEGER */,
    "MinAddition"       "Single" DEFAULT 0 NOT NULL /* "Single" = NUMERIC(8,2) */,
    "MaxDiscount"       "Single" DEFAULT 0 NOT NULL /* "Single" = NUMERIC(8,2) */,
    "ManagerID"         "LongInt" /* "LongInt" = INTEGER */,
    "RetroBonus"        "Single" DEFAULT 0 NOT NULL /* "Single" = NUMERIC(8,2) */,
    "DistributorID"     "LongInt" /* "LongInt" = INTEGER */,
    "SupplierID"        "LongInt" /* "LongInt" = INTEGER */,
    "ImporterID"        "LongInt" /* "LongInt" = INTEGER */,
    "ProducerID"        "LongInt" /* "LongInt" = INTEGER */,
    "ImporterType"      "Boolean" DEFAULT 0 NOT NULL /* "Boolean" = SMALLINT CHECK (value in (0, 1) or value is null) */,
    "Discontinued"      "Boolean" DEFAULT 0 NOT NULL /* "Boolean" = SMALLINT CHECK (value in (0, 1) or value is null) */,
    "Stockroom"         "ShortInt" DEFAULT 0 NOT NULL /* "ShortInt" = SMALLINT */,
    "LastInventoried"   "Date" /* "Date" = DATE */,
    "DiscountType"      "ShortInt" DEFAULT 1 NOT NULL /* "ShortInt" = SMALLINT */,
    "SupplierDiscount"  "Single" DEFAULT 0 NOT NULL /* "Single" = NUMERIC(8,2) */
);


CREATE TABLE "Items" (
    "BranID"                "ShortID" NOT NULL /* "ShortID" = SMALLINT CHECK (value >= 0 or value is null) */,
    "ItemID"                "LongInt" NOT NULL /* "LongInt" = INTEGER */,
    "ItemPos"               "LongInt" NOT NULL /* "LongInt" = INTEGER */,
    GUID                    "LongInt" NOT NULL /* "LongInt" = INTEGER */,
    "ItemName"              "LongText" NOT NULL /* "LongText" = VARCHAR(64) */,
    "Discontinued"          "Boolean" DEFAULT 0 NOT NULL /* "Boolean" = SMALLINT CHECK (value in (0, 1) or value is null) */,
    "ProducerID"            "LongInt" /* "LongInt" = INTEGER */,
    "CategoryID"            "LongInt" DEFAULT 0 NOT NULL /* "LongInt" = INTEGER */,
    "CompID"                "ShortInt" DEFAULT 0 NOT NULL /* "ShortInt" = SMALLINT */,
    "BrandID"               "ShortInt" /* "ShortInt" = SMALLINT */,
    "PromoID"               "ShortInt" /* "ShortInt" = SMALLINT */,
    "CostType"              "Boolean" DEFAULT 0 NOT NULL /* "Boolean" = SMALLINT CHECK (value in (0, 1) or value is null) */,
    "UnitCost"              "LongPrice" NOT NULL /* "LongPrice" = NUMERIC(8,4) CHECK (value >= 0 or value is NULL) */,
    "UnitCostUSD"           "LongPrice" NOT NULL /* "LongPrice" = NUMERIC(8,4) CHECK (value >= 0 or value is NULL) */,
    "UnitPrice1"            "Price" NOT NULL /* "Price" = NUMERIC(8,2) DEFAULT 0 NOT NULL CHECK (value >= 0) */,
    "Difference1"           "Single" /* "Single" = NUMERIC(8,2) */,
    "UnitPrice2"            "Price" NOT NULL /* "Price" = NUMERIC(8,2) DEFAULT 0 NOT NULL CHECK (value >= 0) */,
    "Difference2"           "Single" /* "Single" = NUMERIC(8,2) */,
    "UnitPrice4"            "Price" NOT NULL /* "Price" = NUMERIC(8,2) DEFAULT 0 NOT NULL CHECK (value >= 0) */,
    "Difference4"           "Single" /* "Single" = NUMERIC(8,2) */,
    "UnitPrice5"            "Price" NOT NULL /* "Price" = NUMERIC(8,2) DEFAULT 0 NOT NULL CHECK (value >= 0) */,
    "Difference5"           "Single" /* "Single" = NUMERIC(8,2) */,
    "LastPrice"             "Price" NOT NULL /* "Price" = NUMERIC(8,2) DEFAULT 0 NOT NULL CHECK (value >= 0) */,
    "LastDiff"              "Single" /* "Single" = NUMERIC(8,2) */,
    "PriceBase"             "Price" DEFAULT 0 NOT NULL /* "Price" = NUMERIC(8,2) DEFAULT 0 NOT NULL CHECK (value >= 0) */,
    "Difference3"           "Single" /* "Single" = NUMERIC(8,2) */,
    "LastOfficialUnitCost"  "Single" DEFAULT 0 NOT NULL /* "Single" = NUMERIC(8,2) */,
    "UnitsReceived"         "LongQuantity" NOT NULL /* "LongQuantity" = INTEGER DEFAULT 0 NOT NULL CHECK (value >= 0) */,
    "UnitsRejected"         "LongQuantity" NOT NULL /* "LongQuantity" = INTEGER DEFAULT 0 NOT NULL CHECK (value >= 0) */,
    "UnitsSelled"           "LongQuantity" NOT NULL /* "LongQuantity" = INTEGER DEFAULT 0 NOT NULL CHECK (value >= 0) */,
    "UnitsOnHold"           "ShortQuantity" NOT NULL /* "ShortQuantity" = SMALLINT DEFAULT 0 NOT NULL CHECK (value >= 0) */,
    "UnitsOnReject"         "ShortQuantity" NOT NULL /* "ShortQuantity" = SMALLINT DEFAULT 0 NOT NULL CHECK (value >= 0) */,
    "UnitsOnOrder"          "ShortQuantity" NOT NULL /* "ShortQuantity" = SMALLINT DEFAULT 0 NOT NULL CHECK (value >= 0) */,
    "Rating"                "ShortInt" DEFAULT 0 NOT NULL /* "ShortInt" = SMALLINT */,
    "UnitsInPack"           "ShortInt" DEFAULT 1 NOT NULL /* "ShortInt" = SMALLINT */,
    "UnitsOrdered"          "ShortQuantity" NOT NULL /* "ShortQuantity" = SMALLINT DEFAULT 0 NOT NULL CHECK (value >= 0) */,
    "Line1"                 "LongText" /* "LongText" = VARCHAR(64) */,
    "Line2"                 "LongText" /* "LongText" = VARCHAR(64) */,
    "Line3"                 "LongText" /* "LongText" = VARCHAR(64) */,
    "ActionItem"            "Boolean" DEFAULT 0 NOT NULL /* "Boolean" = SMALLINT CHECK (value in (0, 1) or value is null) */,
    "PrintPrice"            "Boolean" DEFAULT 0 NOT NULL /* "Boolean" = SMALLINT CHECK (value in (0, 1) or value is null) */,
    "Article"               "ShortText" /* "ShortText" = VARCHAR(32) */,
    "Bonus"                 "Single" DEFAULT 0 NOT NULL /* "Single" = NUMERIC(8,2) */,
    "Childlike"             "Boolean" DEFAULT 0 NOT NULL /* "Boolean" = SMALLINT CHECK (value in (0, 1) or value is null) */,
    "ItemAdded"             "Date" DEFAULT current_date NOT NULL /* "Date" = DATE */,
    "Tara"                  "ShortInt" DEFAULT 0 NOT NULL /* "ShortInt" = SMALLINT */,
    "Weight"                "ShortInt" DEFAULT 0 NOT NULL /* "ShortInt" = SMALLINT */,
    "TaxRate"               "Single" DEFAULT 20 NOT NULL /* "Single" = NUMERIC(8,2) */,
    "MaxDiscount"           "Single" DEFAULT 0 NOT NULL /* "Single" = NUMERIC(8,2) */,
    "MinAddition"           "Single" DEFAULT 0 NOT NULL /* "Single" = NUMERIC(8,2) */,
    "LastReleaseOfGoods"    "Date" DEFAULT null /* "Date" = DATE */,
    "ClearanceSale"         "Boolean" DEFAULT 0 NOT NULL /* "Boolean" = SMALLINT CHECK (value in (0, 1) or value is null) */,
    "CodeFTA"               "ShortText" /* "ShortText" = VARCHAR(32) */,
    "ProductSeries"         "ShortInt" DEFAULT 0 NOT NULL /* "ShortInt" = SMALLINT */,
    "StampID"               "LongInt" DEFAULT 0 NOT NULL /* "LongInt" = INTEGER */,
    "ExpControl"            "Boolean" DEFAULT 0 NOT NULL /* "Boolean" = SMALLINT CHECK (value in (0, 1) or value is null) */,
    "ExpAhead"              "ShortInt" DEFAULT 0 NOT NULL /* "ShortInt" = SMALLINT */,
    "ExpDate"               "Date" DEFAULT NULL /* "Date" = DATE */,
    "SupplierType"          "ShortInt" DEFAULT 0 NOT NULL /* "ShortInt" = SMALLINT */,
    "PayDesk"               "Boolean" DEFAULT 0 NOT NULL /* "Boolean" = SMALLINT CHECK (value in (0, 1) or value is null) */,
    "Removed"               "ShortInt" DEFAULT 0 NOT NULL /* "ShortInt" = SMALLINT */,
    "WebDescription"        "ExtremeText" /* "ExtremeText" = VARCHAR(30000) */,
    "BaseCost"              "Price" /* "Price" = NUMERIC(8,2) DEFAULT 0 NOT NULL CHECK (value >= 0) */,
    "BasePrice"             "Price" /* "Price" = NUMERIC(8,2) DEFAULT 0 NOT NULL CHECK (value >= 0) */,
    "Imported"              "Boolean" DEFAULT 0 NOT NULL /* "Boolean" = SMALLINT CHECK (value in (0, 1) or value is null) */,
    "WSPromoID"             "ShortInt" DEFAULT 0 NOT NULL /* "ShortInt" = SMALLINT */,
    "EBasePrice"            "Price" NOT NULL /* "Price" = NUMERIC(8,2) DEFAULT 0 NOT NULL CHECK (value >= 0) */,
    "EMarkUp"               "Single" /* "Single" = NUMERIC(8,2) */,
    "EShopItem"             "Boolean" DEFAULT 0 NOT NULL /* "Boolean" = SMALLINT CHECK (value in (0, 1) or value is null) */
);


CREATE TABLE "Orders" (
    "OrderID"          "LongID" NOT NULL /* "LongID" = INTEGER CHECK (value >= 0 or value is null) */,
    "ParentID"         "LongInt" NOT NULL /* "LongInt" = INTEGER */,
    "OrderDate"        "Date" DEFAULT current_date NOT NULL /* "Date" = DATE */,
    "OrderType"        "ShortInt" NOT NULL /* "ShortInt" = SMALLINT */,
    "DeptID"           "LongInt" NOT NULL /* "LongInt" = INTEGER */,
    "SubjID"           "LongInt" NOT NULL /* "LongInt" = INTEGER */,
    "ItemsTotal"       "ShortMoney" NOT NULL /* "ShortMoney" = NUMERIC(8,2) DEFAULT 0 NOT NULL */,
    "OrderStatus"      "ShortInt" DEFAULT 0 NOT NULL /* "ShortInt" = SMALLINT */,
    "Comments"         "LongText" /* "LongText" = VARCHAR(64) */,
    "ExternalID"       "ShortText" /* "ShortText" = VARCHAR(32) */,
    "CurrType"         "Boolean" DEFAULT 0 NOT NULL /* "Boolean" = SMALLINT CHECK (value in (0, 1) or value is null) */,
    "CurrRate"         "Single" DEFAULT 1 NOT NULL /* "Single" = NUMERIC(8,2) */,
    "Exported"         "ShortInt" DEFAULT 0 NOT NULL /* "ShortInt" = SMALLINT */,
    "Modified"         "DateTime" DEFAULT current_timestamp /* "DateTime" = TIMESTAMP */,
    "PayDesk"          "ShortInt" DEFAULT 0 NOT NULL /* "ShortInt" = SMALLINT */,
    "OrderDate2"       "DateTime" DEFAULT current_timestamp NOT NULL /* "DateTime" = TIMESTAMP */,
    "Delay"            "Date" DEFAULT current_date NOT NULL /* "Date" = DATE */,
    "SalesOfProducts"  "Boolean" DEFAULT 0 NOT NULL /* "Boolean" = SMALLINT CHECK (value in (0, 1) or value is null) */,
    "Official"         "Boolean" DEFAULT 0 NOT NULL /* "Boolean" = SMALLINT CHECK (value in (0, 1) or value is null) */,
    "AgentID"          "LongInt" NOT NULL /* "LongInt" = INTEGER */,
    "VIPSales"         "Boolean" DEFAULT null /* "Boolean" = SMALLINT CHECK (value in (0, 1) or value is null) */,
    "Paid"             "Boolean" /* "Boolean" = SMALLINT CHECK (value in (0, 1) or value is null) */,
    "TaxOrder"         "Boolean" DEFAULT 0 NOT NULL /* "Boolean" = SMALLINT CHECK (value in (0, 1) or value is null) */,
    "NonTaxable"       "Boolean" DEFAULT 0 NOT NULL /* "Boolean" = SMALLINT CHECK (value in (0, 1) or value is null) */,
    "TaxOrderDate"     "DateTime" DEFAULT current_date NOT NULL /* "DateTime" = TIMESTAMP */,
    "TaxItemsTotal"    "Single" DEFAULT 0 NOT NULL /* "Single" = NUMERIC(8,2) */,
    "TaxVAT"           "Single" DEFAULT 0 NOT NULL /* "Single" = NUMERIC(8,2) */,
    "TaxNumber"        "ShortText" /* "ShortText" = VARCHAR(32) */,
    "TaxStatus"        "Boolean" DEFAULT 0 NOT NULL /* "Boolean" = SMALLINT CHECK (value in (0, 1) or value is null) */,
    "AmountPaid"       "Single" DEFAULT 0 NOT NULL /* "Single" = NUMERIC(8,2) */,
    "OperatorID"       "LongInt" /* "LongInt" = INTEGER */,
    "Cash"             "ShortMoney" DEFAULT 0 /* "ShortMoney" = NUMERIC(8,2) DEFAULT 0 NOT NULL */,
    "Change"           "ShortMoney" DEFAULT 0 /* "ShortMoney" = NUMERIC(8,2) DEFAULT 0 NOT NULL */,
    "GiftCertificate"  "ShortMoney" DEFAULT 0 /* "ShortMoney" = NUMERIC(8,2) DEFAULT 0 NOT NULL */,
    "PaymentMethod"    "ShortInt" DEFAULT 0 /* "ShortInt" = SMALLINT */
);


CREATE TABLE "OrdersDetails" (
    "OrderID"       "LongInt" NOT NULL /* "LongInt" = INTEGER */,
    "BranID"        "ShortInt" NOT NULL /* "ShortInt" = SMALLINT */,
    "ItemID"        "LongInt" NOT NULL /* "LongInt" = INTEGER */,
    "ItemPosition"  "LongInt" DEFAULT 0 NOT NULL /* "LongInt" = INTEGER */,
    "UnitPrice"     "LongPrice" NOT NULL /* "LongPrice" = NUMERIC(8,4) CHECK (value >= 0 or value is NULL) */,
    "UnitPrice1"    "Price" /* "Price" = NUMERIC(8,2) DEFAULT 0 NOT NULL CHECK (value >= 0) */,
    "UnitPrice2"    "Price" /* "Price" = NUMERIC(8,2) DEFAULT 0 NOT NULL CHECK (value >= 0) */,
    "Quantity"      "ShortQuantity" /* "ShortQuantity" = SMALLINT DEFAULT 0 NOT NULL CHECK (value >= 0) */,
    "Income"        "ShortMoney" NOT NULL /* "ShortMoney" = NUMERIC(8,2) DEFAULT 0 NOT NULL */,
    "Discount"      "Single" default 0 NOT NULL /* "Single" = NUMERIC(8,2) */,
    "Price"         "LongPrice" NOT NULL /* "LongPrice" = NUMERIC(8,4) CHECK (value >= 0 or value is NULL) */,
    "Bonus"         "Single" DEFAULT 0 NOT NULL /* "Single" = NUMERIC(8,2) */,
    "Salary1"       "Single" DEFAULT 0 NOT NULL /* "Single" = NUMERIC(8,2) */,
    "AgentID"       "LongInt" /* "LongInt" = INTEGER */
);


CREATE TABLE "OrdersOnlineDetails" (
    "OrderID"            "LongInt" NOT NULL /* "LongInt" = INTEGER */,
    "BranID"             "ShortInt" NOT NULL /* "ShortInt" = SMALLINT */,
    "ItemID"             "LongInt" NOT NULL /* "LongInt" = INTEGER */,
    "Quantity"           "ShortInt" DEFAULT 1 NOT NULL /* "ShortInt" = SMALLINT */,
    "Cost"               "Price" NOT NULL /* "Price" = NUMERIC(8,2) DEFAULT 0 NOT NULL CHECK (value >= 0) */,
    "Price"              "Price" NOT NULL /* "Price" = NUMERIC(8,2) DEFAULT 0 NOT NULL CHECK (value >= 0) */,
    "Discount"           "Single" DEFAULT 0 NOT NULL /* "Single" = NUMERIC(8,2) */,
    "ItemPosition"       "LongInt" NOT NULL /* "LongInt" = INTEGER */,
    "PromoItem"          "Boolean" DEFAULT 0 NOT NULL /* "Boolean" = SMALLINT CHECK (value in (0, 1) or value is null) */,
    "Reserved"           "ShortInt" DEFAULT 0 NOT NULL /* "ShortInt" = SMALLINT */,
    "CommissionPercent"  "Single" DEFAULT 0 NOT NULL /* "Single" = NUMERIC(8,2) */
);


CREATE TABLE "Subjects" (
    "SubjID"            "LongInt" NOT NULL /* "LongInt" = INTEGER */,
    "SubjType"          "LongInt" DEFAULT 0 NOT NULL /* "LongInt" = INTEGER */,
    "SubjName"          "ShortText" NOT NULL /* "ShortText" = VARCHAR(32) */,
    "Address"           "LongText" /* "LongText" = VARCHAR(64) */,
    "Phone"             "ShortText" /* "ShortText" = VARCHAR(32) */,
    "SubjCode"          "ShortText" /* "ShortText" = VARCHAR(32) */,
    GUID                "LongInt" NOT NULL /* "LongInt" = INTEGER */,
    "Condition"         "ShortInt" DEFAULT 0 NOT NULL /* "ShortInt" = SMALLINT */,
    "Locked"            "Boolean" DEFAULT 0 NOT NULL /* "Boolean" = SMALLINT CHECK (value in (0, 1) or value is null) */,
    "Disabled"          "Boolean" DEFAULT 0 NOT NULL /* "Boolean" = SMALLINT CHECK (value in (0, 1) or value is null) */,
    "DisabledDate"      "DateTime" DEFAULT null /* "DateTime" = TIMESTAMP */,
    "Modifyed"          "DateTime" DEFAULT current_timestamp NOT NULL /* "DateTime" = TIMESTAMP */,
    "Childlike"         "Boolean" DEFAULT 0 NOT NULL /* "Boolean" = SMALLINT CHECK (value in (0, 1) or value is null) */,
    "DeptID"            "LongInt" DEFAULT null /* "LongInt" = INTEGER */,
    "Discount1"         "Single" DEFAULT 0 NOT NULL /* "Single" = NUMERIC(8,2) */,
    "Discount1Type"     "ShortInt" DEFAULT 0 NOT NULL /* "ShortInt" = SMALLINT */,
    "Balance1"          "Single" DEFAULT 0 NOT NULL /* "Single" = NUMERIC(8,2) */,
    "Discount2"         "Single" DEFAULT 0 NOT NULL /* "Single" = NUMERIC(8,2) */,
    "Discount2Type"     "ShortInt" DEFAULT 0 NOT NULL /* "ShortInt" = SMALLINT */,
    "Balance2"          "Single" DEFAULT 0 NOT NULL /* "Single" = NUMERIC(8,2) */,
    "Comment"           "Memo" /* "Memo" = BLOB SUB_TYPE 1 SEGMENT SIZE 80 */,
    "SpecDiscountCard"  "Boolean" DEFAULT 0 NOT NULL /* "Boolean" = SMALLINT CHECK (value in (0, 1) or value is null) */,
    "SpecMinDiscount"   "Single" DEFAULT 0 NOT NULL /* "Single" = NUMERIC(8,2) */,
    "Bonus"             "Single" DEFAULT 0 NOT NULL /* "Single" = NUMERIC(8,2) */,
    "LastName"          "LongText" /* "LongText" = VARCHAR(64) */,
    "FirstName"         "ShortText" /* "ShortText" = VARCHAR(32) */,
    "Patronymic"        "ShortText" /* "ShortText" = VARCHAR(32) */,
    "BirthDate"         "DateTime" /* "DateTime" = TIMESTAMP */,
    "StampID"           "LongInt" DEFAULT 0 NOT NULL /* "LongInt" = INTEGER */,
    "CommonName"        "ShortText" NOT NULL /* "ShortText" = VARCHAR(32) */,
    "HireDate"          "Date" /* "Date" = DATE */,
    "Category"          "ShortText" /* "ShortText" = VARCHAR(32) */
);


ALTER TABLE "Items" ADD "UnitsInStock" COMPUTED BY ("UnitsReceived" - "UnitsRejected" - "UnitsSelled" - "UnitsOnReject" - "UnitsOnOrder");


/******************************************************************************/
/***                           Check constraints                            ***/
/******************************************************************************/

ALTER TABLE "Items" ADD CONSTRAINT "ckcItemsBonus" CHECK("Bonus" >= 0);
ALTER TABLE "Items" ADD CONSTRAINT "ckcItemsWeight" CHECK("Weight" >= 0);
ALTER TABLE "Orders" ADD CONSTRAINT "chkOrdersCurrRate" CHECK("CurrRate" > 0);
ALTER TABLE "Items" ADD CONSTRAINT "chkItemsLastPrice" CHECK(("CompID" > 0 and "LastPrice" <> 0) or ("CompID" = 0));
ALTER TABLE "Items" ADD CONSTRAINT "ckcItemsUnitsInStock" CHECK("UnitsInStock" >= 0);
ALTER TABLE "Branches" ADD CONSTRAINT "chkBranchesDiscountType" CHECK("DiscountType" in (1, 2, 3));
ALTER TABLE "Branches" ADD CONSTRAINT "chkBranchesUSDRate" CHECK("USDRate" > 0);
ALTER TABLE "Items" ADD CONSTRAINT "ckcItemsTaxRate" CHECK ("TaxRate" in (7, 20));
ALTER TABLE "OrdersOnlineDetails" ADD CONSTRAINT "chk1_OrdersOnlineDetails" CHECK("Quantity" > 0);
ALTER TABLE "Subjects" ADD CONSTRAINT "chkSubjectsSubjType" CHECK("SubjType" = 1 or "SubjType" = 2 or "SubjType" = 4 or "SubjType" = 32768 or "SubjType" = 65536 or bin_or("SubjType", 425976) = 425976);
ALTER TABLE "OrdersOnlineDetails" ADD CONSTRAINT "chk2_OrdersOnlineDetails" CHECK("Quantity" >= "Reserved");



/******************************************************************************/
/***                           Stored procedures                            ***/
/******************************************************************************/



SET TERM ^ ;

CREATE OR ALTER PROCEDURE "spReports.Sales01" (
    "iStartDate" DATE,
    "iEndDate" DATE)
RETURNS (
    "DeptID" INTEGER,
    "BranID" SMALLINT,
    "ItemID" INTEGER,
    "DeptName" VARCHAR(64),
    "BranName" VARCHAR(32),
    "Article" VARCHAR(32),
    "ItemName" VARCHAR(64),
    "UnitCost" NUMERIC(9,2),
    "UnitPrice" NUMERIC(9,2),
    "LastPrice" NUMERIC(9,2),
    "Price" NUMERIC(9,2),
    "Quantity" SMALLINT,
    "SupplierType" SMALLINT)
AS
begin
  for
    select
      OD."DeptID",
      "BranID",
      "ItemID",
      "BranName",
      "Article",
      "ItemName",
      "UnitCost",
      "UnitPrice2",
      "LastPrice",
      "Price",
      "Quantity",
      "SubjName",
      "SupplierType"
    from
        (select
           "Orders"."DeptID",
           "OrdersDetails"."BranID",
           "OrdersDetails"."ItemID",
           "OrdersDetails"."Price",
           sum(
           case "Orders"."OrderType"
             when 30 then
                 -"OrdersDetails"."Quantity"
             else "OrdersDetails"."Quantity"
           end) "Quantity"
         from
             "Orders"
           inner join
             "OrdersDetails" using ("OrderID")
         where
            "Orders"."OrderType" in (11, 13, 25, 30, 31, 46, 42)
           and
            "Orders"."OrderDate" between :"iStartDate" and :"iEndDate"
         group by
           "Orders"."DeptID",
           "OrdersDetails"."BranID",
           "OrdersDetails"."ItemID",
           "OrdersDetails"."Price"

         union all
         select
           "Orders"."DeptID",
           "OrdersOnlineDetails"."BranID",
           "OrdersOnlineDetails"."ItemID",
           "OrdersOnlineDetails"."Price",
           sum(
           case "Orders"."OrderType"
             when 50 then
                 "OrdersOnlineDetails"."Quantity"
             else 0
           end) "Quantity"
         from
             "Orders"
           inner join
             "OrdersOnlineDetails" using ("OrderID")
         where
            "Orders"."OrderType" in (50)
           and
            "Orders"."OrderDate" between :"iStartDate" and :"iEndDate"
         group by
           "Orders"."DeptID",
           "OrdersOnlineDetails"."BranID",
           "OrdersOnlineDetails"."ItemID",
           "OrdersOnlineDetails"."Price"

        ) OD
      inner join
        "Items" using ("BranID", "ItemID")
      inner join
        "Branches" using ("BranID")
      inner join
        "Subjects" on (OD."DeptID" = "Subjects"."SubjID")
    where
       "Quantity" <> 0
    order by
      OD."DeptID",
      "BranPos",
      "ItemPos"
    into
      :"DeptID",
      :"BranID",
      :"ItemID",
      :"BranName",
      :"Article",
      :"ItemName",
      :"UnitCost",
      :"UnitPrice",
      :"LastPrice",
      :"Price",
      :"Quantity",
      :"DeptName",
      :"SupplierType"
  do
    suspend;
end^



SET TERM ; ^

COMMIT;
