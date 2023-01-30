



create user stg_layer_cdvq identified by cdvq;
grant dba to stg_layer_cdvq;

create user ig_layer_cdvq identified by cdvq;
grant dba to ig_layer_cdvq;

create user access_layer_cdvq identified by cdvq;
grant dba to access_layer_cdvq;




--> src customer table 

CREATE TABLE SRC1_CDVQ_CUSTOMERS
(
  CUST_ID VARCHAR2(200 ) 
, FIRST_NAME VARCHAR2(200) 
, LAST_NAME VARCHAR2(200 ) 
, GENDER VARCHAR2(200) 
, COUNTRY VARCHAR2(200) 
, STATE VARCHAR2(200 ) 
, CITY VARCHAR2(200 ) 
, PHONE VARCHAR2(200 ) 
, EMAIL VARCHAR2(200 ) 
, ZIPCODE VARCHAR2(200 ) 
);

--> stg customer table 

CREATE TABLE  STG1_CDVQ_CUSTOMERS
(
  CUST_ID NUMBER  
, FIRST_NAME VARCHAR2(200 ) 
, LAST_NAME VARCHAR2(200 ) 
, GENDER VARCHAR2(200 ) 
, COUNTRY VARCHAR2(200 ) 
, STATE VARCHAR2(200 ) 
, CITY VARCHAR2(200 ) 
, PHONE NUMBER 
, EMAIL VARCHAR2(200 ) 
, ZIPCODE NUMBER 
);

--> SRC1 TO STG1 

INSERT INTO STG1_CDVQ_CUSTOMERS
(
CUST_ID,
FIRST_NAME,
LAST_NAME, 
GENDER, 
COUNTRY, 
STATE, 
CITY,
PHONE,
EMAIL,
ZIPCODE 
)
SELECT 
cast(CUST_ID as number),   
FIRST_NAME,  
LAST_NAME, 
GENDER,
COUNTRY, 
STATE,
CITY, 
cast(PHONE as number), 
EMAIL,
cast(ZIPCODE as number)  
from SRC1_CDVQ_CUSTOMERS;
commit;


--> STG to IG
CREATE TABLE  IG1_CDVQ_CUSTOMERS
(
  CUST_ID NUMBER  
, FULL_NAME VARCHAR2(200 ) 
, GENDER VARCHAR2(200) 
, COUNTRY VARCHAR2(200 ) 
, STATE VARCHAR2(200 ) 
, CITY VARCHAR2(200 ) 
, PHONE VARCHAR2(200) 
, EMAIL VARCHAR2(200 ) 
, ZIPCODE NUMBER,
  SOURCE VARCHAR2(200)
);

--> STG1 TO IG1


Insert into ig_layer_cdvq.IG1_CDVQ_CUSTOMERS
(
CUST_ID,
FULL_NAME, 
GENDER,  
COUNTRY,  
STATE,  
CITY,  
PHONE,  
EMAIL,
ZIPCODE, 
SOURCE )
SELECT 

CUST_ID,
FIRST_NAME||' '||LAST_NAME AS FULL_NAME , 
CASE 
WHEN GENDER='F' then 'Female'
WHEN GENDER='M' then 'Male' end AS GENDER ,  
COUNTRY,  
STATE,  
CITY,  
SUBSTR(PHONE,1,4)||'-'||SUBSTR(PHONE,5,3) ||'-'|| SUBSTR(PHONE,8) AS PHONE ,
EMAIL,
ZIPCODE,
'S1' FROM STG_LAYER_CDVQ.STG1_CDVQ_CUSTOMERS;

commit;

--> IG1 to TEMP 

CREATE TABLE  IG_LAYER_CDVQ.TEMP_CUSTOMERS
(
  CUST_ID NUMBER  
, FULL_NAME VARCHAR2(200 ) 
, GENDER VARCHAR2(200) 
, COUNTRY VARCHAR2(200 ) 
, STATE VARCHAR2(200 ) 
, CITY VARCHAR2(200 ) 
, PHONE VARCHAR2(200) 
, EMAIL VARCHAR2(200 ) 
, ZIPCODE NUMBER,
  SOURCE VARCHAR2(200)
);

--> IG1 TO TEMP
Insert into IG_LAYER_CDVQ.TEMP_CUSTOMERS
SELECT * FROM IG_LAYER_CDVQ.IG1_CDVQ_CUSTOMERS;

commit;

--> DIM_CUSTOMERS

--> Create sequence in Access Layer
create sequence S_cust;

CREATE TABLE  ACCESS_LAYER_CDVQ.DIM_CUSTOMERS
(
  CUST_KEY NUMBER primary key,
  CUST_ID NUMBER  
, FULL_NAME VARCHAR2(200 ) 
, GENDER VARCHAR2(200) 
, COUNTRY VARCHAR2(200 ) 
, STATE VARCHAR2(200 ) 
, CITY VARCHAR2(200 ) 
, PHONE VARCHAR2(200) 
, EMAIL VARCHAR2(200 ) 
, ZIPCODE NUMBER,
  ROW_INSERT_DT date,
  ROW_UPDATE_DT date
);

--> temp to dim_customers

Insert into ACCESS_LAYER_CDVQ.DIM_CUSTOMERS 
SELECT
  S_cust.nextval, 
  CUST_ID 
, FULL_NAME 
, GENDER 
, COUNTRY 
, STATE 
, CITY 
, PHONE 
, EMAIL 
, ZIPCODE,
sysdate,
to_date('12-31-9999','mm-dd-yyyy')
from IG_LAYER_CDVQ.TEMP_CUSTOMERS;

commit;


-------------------------------------------------------------------------------------------------

-->src product table

create table SRC1_CDVQ_Products

(
Product_ID Varchar2(200),
Raw_Pr_Category Varchar2(200),
Custom_Rating Varchar2(200),
Color_Variant Varchar2(200),
Color_Variant_HEXCode Varchar2(200),
Stock_Status Varchar2(200),
Manfacturing_Date Varchar2(200),
Carrier_Size Varchar2(200),
Limited_Stock Varchar2(200),
Active_For_Sale Varchar2(200),
Product_Biz_Status Varchar2(200),
Automatic_Prolongation Varchar2(200),
Product_price Varchar2(200),
Product_selling_price varchar2(200),
Upsell_Availability Varchar2(200),
Seller_ID Varchar2(200),
SKU_Item Varchar2(200),
Assortment_Priority Varchar2(200),
Negat_Ind Varchar2(200),
Promo_Theme Varchar2(200));


--> stg_product table

create table STG1_CDVQ_Products

(
Product_ID number,
Raw_Pr_Category Varchar2(200),
Custom_Rating number,
Color_Variant Varchar2(200),
Color_Variant_HEXCode Varchar2(200),
Stock_Status Varchar2(200),
Manfacturing_Date date,
Carrier_Size Varchar2(200),
Limited_Stock Varchar2(200),
Active_For_Sale Varchar2(200),
Product_Biz_Status Varchar2(200),
Automatic_Prolongation Varchar2(200),
Product_price number,
Product_selling_price number,
Upsell_Availability Varchar2(200),
Seller_ID number,
SKU_Item number,
Assortment_Priority Varchar2(200),
Negat_Ind Varchar2(200),
Promo_Theme Varchar2(200));



-->  SRC1 TO STG1 product table


INSERT INTO STG1_CDVQ_Products
(Product_ID ,
Raw_Pr_Category ,
Custom_Rating ,
Color_Variant ,
Color_Variant_HEXCode ,
Stock_Status ,
Manfacturing_Date ,
Carrier_Size ,
Limited_Stock ,
Active_For_Sale ,
Product_Biz_Status ,
Automatic_Prolongation ,
Product_price ,
Product_selling_price ,
Upsell_Availability ,
Seller_ID ,
SKU_Item ,
Assortment_Priority ,
Negat_Ind ,
Promo_Theme)

SELECT
cast(product_id as number),
Raw_Pr_Category ,
cast(Custom_Rating as number) ,
Color_Variant ,
Color_Variant_HEXCode ,
Stock_Status ,
to_date(Manfacturing_Date,'dd-mm-yyyy'),
Carrier_Size ,
Limited_Stock ,
Active_For_Sale ,
Product_Biz_Status ,
Automatic_Prolongation ,
cast(Product_price as number),
cast(Product_selling_price as number),
Upsell_Availability ,
cast(Seller_ID as number),
cast(SKU_Item as number),
Assortment_Priority ,
Negat_Ind ,
Promo_Theme 
from SRC1_CDVQ_Products;



commit;




--> STG to IG

create table IG1_CDVQ_Products

(
Product_ID number,
Raw_Pr_Category Varchar2(200),
Custom_Rating number,
Rating_status varchar2(20),
Color_Variant Varchar2(200),
Color_Variant_HEXCode Varchar2(200),
Stock_Status Varchar2(200),
Manfacturing_Date date,
Carrier_Size Varchar2(200),
Limited_Stock Varchar2(200),
Active_For_Sale Varchar2(200),
Product_Biz_Status Varchar2(200),
Automatic_Prolongation Varchar2(200),
Product_price number,
Product_selling_price number,
Upsell_Availability Varchar2(200),
Seller_ID number,
SKU_Item number,
Assortment_Priority Varchar2(200),
Negat_Ind Varchar2(200),
Promo_Theme Varchar2(200),
source varchar2(200));


--> STG1 TO IG1

INSERT INTO ig_layer_cdvq.IG1_CDVQ_Products
(
Product_ID ,
Raw_Pr_Category ,
Custom_Rating ,
Rating_status ,
Color_Variant ,
Color_Variant_HEXCode ,
Stock_Status ,
Manfacturing_Date ,
Carrier_Size ,
Limited_Stock ,
Active_For_Sale ,
Product_Biz_Status ,
Automatic_Prolongation ,
Product_price ,
Product_selling_price ,
Upsell_Availability ,
Seller_ID ,
SKU_Item ,
Assortment_Priority ,
Negat_Ind ,
Promo_Theme,
source)

select
Product_ID ,
Raw_Pr_Category ,
Custom_Rating ,
case Custom_Rating when 1 then 'Very Poor' when 2 then 'Poor' when 3 then 'Average' when 4 then 'Good' when 5 then 'Excellent' end,
Color_Variant ,
ltrim(Color_Variant_HEXCode,'#'),
Stock_Status ,
Manfacturing_Date ,
replace(upper(Carrier_Size),'FR',''),
case Limited_Stock when 'FALSE' then 0 when 'TRUE' then 1 end,
Active_For_Sale,
replace(upper(Product_Biz_Status),'TYPE',''),
Automatic_Prolongation ,
Product_price ,
Product_selling_price ,
Upsell_Availability ,
Seller_ID ,
SKU_Item ,
Assortment_Priority ,
case Negat_Ind when 'No' then 0 when 'Yes' then 1 end,
Promo_Theme,
'S1'
from stg_layer_cdvq.STG1_CDVQ_Products;

commit;


---IG1 to temp

create table temp_products

(
Product_ID number,
Raw_Pr_Category Varchar2(200),
Custom_Rating number,
Rating_status varchar2(20),
Color_Variant Varchar2(200),
Color_Variant_HEXCode Varchar2(200),
Stock_Status Varchar2(200),
Manfacturing_Date date,
Carrier_Size Varchar2(200),
Limited_Stock Varchar2(200),
Active_For_Sale Varchar2(200),
Product_Biz_Status Varchar2(200),
Automatic_Prolongation Varchar2(200),
Product_price number,
Product_selling_price number,
Upsell_Availability Varchar2(200),
Seller_ID number,
SKU_Item number,
Assortment_Priority Varchar2(200),
Negat_Ind Varchar2(200),
Promo_Theme Varchar2(200),
source varchar2(200));



--> IG1 TO TEMP

Insert into IG_LAYER_CDVQ.TEMP_PRODUCTS
SELECT * FROM IG_LAYER_CDVQ.IG1_CDVQ_PRODUCTS;

commit;

--> DIM_PRODUCTS

--> Create sequence in Access Layer
create sequence S_product;

create table access_layer_cdvq.DIM_products

(
Product_key number primary key,
Product_ID number,
Raw_Pr_Category Varchar2(200),
Custom_Rating number,
Rating_status varchar2(20),
Color_Variant Varchar2(200),
Color_Variant_HEXCode Varchar2(200),
Stock_Status Varchar2(200),
Manfacturing_Date date,
Carrier_Size Varchar2(200),
Limited_Stock Varchar2(200),
Active_For_Sale Varchar2(200),
Product_Biz_Status Varchar2(200),
Automatic_Prolongation Varchar2(200),
Product_price number,
Product_selling_price number,
Upsell_Availability Varchar2(200),
Seller_ID number,
SKU_Item number,
Assortment_Priority Varchar2(200),
Negat_Ind Varchar2(200),
Promo_Theme Varchar2(200),
ROW_INSERT_DT date,
ROW_UPDATE_DT date

);



INSERT INTO access_layer_cdvq.DIM_Products

SELECT
s_product.nextval,
Product_ID ,
Raw_Pr_Category ,
Custom_Rating ,
Rating_status ,
Color_Variant ,
Color_Variant_HEXCode ,
Stock_Status ,
Manfacturing_Date ,
Carrier_Size ,
Limited_Stock ,
Active_For_Sale ,
Product_Biz_Status ,
Automatic_Prolongation ,
Product_price ,
Product_selling_price ,
Upsell_Availability ,
Seller_ID ,
SKU_Item ,
Assortment_Priority ,
Negat_Ind ,
Promo_Theme,
sysdate,
to_date('12-31-9999','mm-dd-yyyy')
from IG_LAYER_CDVQ.TEMP_PRODUCTS;

commit;



---------------------------------------------------------------------------------------------------


-->src orders table

create table stg_layer_cdvq.SRC1_CDVQ_ORDERS
(
Stiris_ID Varchar2(200),
Order_Unique_ID Varchar2(200),
Order_Sale_RoundedValue Varchar2(200),
Freight_Value Varchar2(200),
Product_ID Varchar2(200),
Customer_id Varchar2(200),
SKU_Item Varchar2(200),
Mail_Category Varchar2(200),
Mail_Way_In Varchar2(200),
Mail_Cost_Type Varchar2(200),
Mail_Partner_Type Varchar2(200),
Mail_Partner_Name Varchar2(200),
Order_Status Varchar2(200),
Order_Hour_Of_Day Varchar2(200),
Days_Since_Prior_Order Varchar2(200),
Mail_From_Type Varchar2(200),
Intimate_Profit Varchar2(200),
Order_Quantity_Number Varchar2(200),
Raw_Pr_Category Varchar2(200),
Discount_Applied VARCHAR2(30),
Offer_Claimed VARCHAR2(30),
Order_ForSelf VARCHAR2(30),
Order_ForGift Varchar2(200),
Delivery_Charges varchar2(200),
Order_Purchase_date Varchar2(200),
Order_Approved_At Varchar2(200),
Shipping_Limit_Date Varchar2(200),
Order_Delivered_Carrier_Date Varchar2(200),
Order_Delivered_Customer_Date Varchar2(200),
Order_Estimated_Delivery_Date Varchar2(200));



create table stg_layer_cdvq.STG1_CDVQ_Orders

(

Stiris_ID Varchar2(200),
Order_Unique_ID Number ,
Order_Sale_RoundedValue Number,
Freight_Value Number,
Product_ID Number,
Customer_ID number,
SKU_Item Number,
Mail_Category Varchar2(200),
Mail_Way_In Varchar2(200),
Mail_Cost_Type Varchar2(200),
Mail_Partner_Type Varchar2(200),
Mail_Partner_Name Varchar2(200),
Order_Status Varchar2(200),
Order_Hour_Of_Day Number,
Days_Since_Prior_Order Number,
Mail_From_Type Varchar2(200),
Intimate_Profit Number,
Order_Quantity_Number Number,
Raw_Pr_Category Varchar2(200),
Discount_Applied VARCHAR2(30),
Offer_Claimed VARCHAR2(30),
Order_ForSelf VARCHAR2(30),
Order_ForGift Varchar2(200),
Delivery_Charges number,
Order_Purchase_date date,
Order_Approved_At date,
Shipping_Limit_Date date,
Order_Delivered_Carrier_Date date,
Order_Delivered_Customer_Date date,
Order_Estimated_Delivery_Date date);



--SRC to STG

insert into stg_layer_cdvq.STG1_CDVQ_Orders

SELECT
Stiris_ID ,
cast(Order_Unique_ID as number) ,
cast(Order_Sale_RoundedValue as number),
cast(Freight_Value as number),
cast(Product_ID as number),
cast(Customer_ID as number),
cast(SKU_Item as number) ,
Mail_Category ,
Mail_Way_In ,
Mail_Cost_Type ,
Mail_Partner_Type ,
Mail_Partner_Name ,
Order_Status ,
cast(Order_Hour_Of_Day as number) ,
cast(Days_Since_Prior_Order as number) ,
Mail_From_Type ,
cast(Intimate_Profit as number) ,
cast(Order_Quantity_Number as number) ,
Raw_Pr_Category ,
Discount_Applied ,
Offer_Claimed ,
Order_ForSelf ,
Order_ForGift ,
cast(Delivery_Charges as number),
cast(Order_Purchase_date as date),
cast(Order_Approved_At as date),
cast(Shipping_Limit_Date as date),
cast(Order_Delivered_Carrier_Date as date) ,
cast(Order_Delivered_Customer_Date as date) ,
cast(Order_Estimated_Delivery_Date as date)
from stg_layer_cdvq.SRC1_CDVQ_ORDERS;

commit;



----IG TABLE

create table ig_layer_cdvq.IG1_CDVQ_Orders

(

Stiris_ID Varchar2(200),
Order_Unique_ID Number ,
Order_Sale_RoundedValue Number,
Freight_Value Number,
Product_ID Number,
Customer_ID number,
SKU_Item Number,
Mail_Category Varchar2(200),
Mail_Way_In Varchar2(200),
Mail_Cost_Type Varchar2(200),
Mail_Partner_Type Varchar2(200),
Mail_Partner_Name Varchar2(200),
Order_Status Varchar2(200),
Order_Hour_Of_Day Number,
Days_Since_Prior_Order Number,
Mail_From_Type Varchar2(200),
Intimate_Profit Number,
Order_Quantity_Number Number,
Raw_Pr_Category Varchar2(200),
Discount_Applied VARCHAR2(30),
Offer_Claimed VARCHAR2(30),
Order_ForSelf VARCHAR2(30),
Order_ForGift Varchar2(200),
Delivery_Charges number,
Order_Purchase_date date,
Order_Approved_At date,
Shipping_Limit_Date date,
Order_Delivered_Carrier_Date date,
Order_Delivered_Customer_Date date,
Order_Estimated_Delivery_Date date,
Source varchar2(20));




---> STG TO IG

insert into ig_layer_cdvq.IG1_CDVQ_Orders

SELECT
 
ltrim(Stiris_ID,'0'),
Order_Unique_ID ,
Order_Sale_RoundedValue ,
trunc(Freight_Value) ,
Product_ID ,
Customer_ID,
SKU_Item ,
Mail_Category ,
Mail_Way_In ,
Mail_Cost_Type ,
Mail_Partner_Type,
Mail_Partner_Name ,
Order_Status ,
Order_Hour_Of_Day ,
Days_Since_Prior_Order ,
Mail_From_Type ,
Intimate_Profit ,
Order_Quantity_Number ,
Raw_Pr_Category ,
Discount_Applied ,
Offer_Claimed ,
Order_ForSelf ,
Order_ForGift ,
Delivery_Charges ,
Order_Purchase_date ,
Order_Approved_At ,
Shipping_Limit_Date ,
Order_Delivered_Carrier_Date ,
Order_Delivered_Customer_Date ,
Order_Estimated_Delivery_Date,
'S1'
from stg_layer_cdvq.STG1_CDVQ_Orders;

commit;


---TEMP TABLE




create table ig_layer_cdvq.TEMP_ORDERS

(

Stiris_ID Varchar2(200),
Order_Unique_ID Number ,
Order_Sale_RoundedValue Number,
Freight_Value Number,
Product_ID Number,
Customer_ID number,
SKU_Item Number,
Mail_Category Varchar2(200),
Mail_Way_In Varchar2(200),
Mail_Cost_Type Varchar2(200),
Mail_Partner_Type Varchar2(200),
Mail_Partner_Name Varchar2(200),
Order_Status Varchar2(200),
Order_Hour_Of_Day Number,
Days_Since_Prior_Order Number,
Mail_From_Type Varchar2(200),
Intimate_Profit Number,
Order_Quantity_Number Number,
Raw_Pr_Category Varchar2(200),
Discount_Applied VARCHAR2(30),
Offer_Claimed VARCHAR2(30),
Order_ForSelf VARCHAR2(30),
Order_ForGift Varchar2(200),
Delivery_Charges number,
Order_Purchase_date date,
Order_Approved_At date,
Shipping_Limit_Date date,
Order_Delivered_Carrier_Date date,
Order_Delivered_Customer_Date date,
Order_Estimated_Delivery_Date date,
Source varchar2(20));


--LOad data from IG to TEMP


Insert into IG_LAYER_CDVQ.TEMP_ORDERS
SELECT * FROM IG_LAYER_CDVQ.IG1_CDVQ_Orders;

commit;

--Access Layer

create sequence S_order;


create table access_layer_cdvq.DIM_Orders

(
Order_key number primary key,
Stiris_ID Varchar2(200),
Order_Unique_ID Number ,
Order_Sale_RoundedValue Number,
Freight_Value Number,
Product_ID Number,
customer_id Number,
SKU_Item Number,
Mail_Category Varchar2(200),
Mail_Way_In Varchar2(200),
Mail_Cost_Type Varchar2(200),
Mail_Partner_Type Varchar2(200),
Mail_Partner_Name Varchar2(200),
Order_Status Varchar2(200),
Order_Hour_Of_Day Number,
Days_Since_Prior_Order Number,
Mail_From_Type Varchar2(200),
Intimate_Profit Number,
Order_Quantity_Number Number,
Raw_Pr_Category Varchar2(200),
Discount_Applied VARCHAR2(30),
Offer_Claimed VARCHAR2(30),
Order_ForSelf VARCHAR2(30),
Order_ForGift Varchar2(200),
Delivery_Charges number,
Order_Purchase_date date,
Order_Approved_At date,
Shipping_Limit_Date date,
Order_Delivered_Carrier_Date date,
Order_Delivered_Customer_Date date,
Order_Estimated_Delivery_Date date,
ROW_INSERT_DT date,
ROW_UPDATE_DT date
);



insert into access_layer_cdvq.DIM_Orders

SELECT
S_order.nextval,
Stiris_ID,
Order_Unique_ID ,
Order_Sale_RoundedValue ,
Freight_Value ,
Product_ID ,
customer_id ,
SKU_Item ,
Mail_Category ,
Mail_Way_In ,
Mail_Cost_Type ,
Mail_Partner_Type,
Mail_Partner_Name ,
Order_Status ,
Order_Hour_Of_Day ,
Days_Since_Prior_Order ,
Mail_From_Type ,
Intimate_Profit ,
Order_Quantity_Number ,
Raw_Pr_Category ,
Discount_Applied ,
Offer_Claimed ,
Order_ForSelf ,
Order_ForGift ,
Delivery_Charges,
Order_Purchase_date ,
Order_Approved_At ,
Shipping_Limit_Date ,
Order_Delivered_Carrier_Date ,
Order_Delivered_Customer_Date ,
Order_Estimated_Delivery_Date,
sysdate,
to_date('12-31-9999','mm-dd-yyyy')
from IG_LAYER_CDVQ.TEMP_ORDERS;

commit;


-----------------------------------------------------------------------------------------------


-->SRC table

create table SRC1_CDVQ_Payments

(
Order_Unique_ID Varchar2(200),
Payment_Unique_ID Varchar2(200) ,
Payment_Sequential Varchar2(200),
Payment_Type Varchar2(200),
Payment_Installments Varchar2(200),
Check_Date Varchar2(200),
Card_Type Varchar2(200),
Card_Num Varchar2(200),
Transaction_Log_ID Varchar2(200),
Transaction_User_ID Varchar2(200),
Transaction_Status Varchar2(200));


--> STG Table 

create table stg_layer_cdvq.STG1_CDVQ_Payments

(

Order_Unique_ID Number,
Payment_Unique_ID Number ,
Payment_Sequential Number,
Payment_Type Varchar2(200),
Payment_Installments Number,
Check_Date date,
Card_Type Varchar2(200),
Card_Num Varchar2(200),
Transaction_Log_ID Varchar2(200),
Transaction_User_ID Varchar2(200),
Transaction_Status Varchar2(200));


Insert into stg_layer_cdvq.STG1_CDVQ_Payments

select 
cast(Order_Unique_ID as Number),
cast(Payment_Unique_ID as Number) ,
cast(Payment_Sequential as Number),
Payment_Type ,
cast(Payment_Installments as Number),
cast(Check_Date as date),
Card_Type ,
Card_Num,
Transaction_Log_ID ,
Transaction_User_ID ,
Transaction_Status 
from stg_layer_cdvq.SRC1_CDVQ_Payments;

commit;


--> IG TABLE

create table ig_layer_cdvq.IG1_CDVQ_Payments
(

Order_Unique_ID Number,
Payment_Unique_ID Number ,
Payment_Sequential Number,
Payment_Type Varchar2(200),
Payment_Installments Number,
Check_Date date,
Card_Type Varchar2(200),
Card_Num Varchar2(200),
Transaction_Log_ID Varchar2(200),
Transaction_User_ID Varchar2(200),
Transaction_Status Varchar2(200),
Source Varchar2(30));

-->Payments Table


--STG TO IG 

Insert into ig_layer_cdvq.IG1_CDVQ_Payments

select 
Order_Unique_ID,
Payment_Unique_ID  ,
Payment_Sequential ,
Payment_Type ,
Payment_Installments ,
Check_Date ,
Card_Type ,
replace(card_num,substr(card_num,-4),'****') as Card_Num ,
Transaction_Log_ID ,
Transaction_User_ID ,
Transaction_Status,
'S1' 
from stg_layer_cdvq.STG1_CDVQ_Payments;

commit;



--> temp table 

create table ig_layer_cdvq.TEMP_Payments
(

Order_Unique_ID Number,
Payment_Unique_ID Number ,
Payment_Sequential Number,
Payment_Type Varchar2(200),
Payment_Installments Number,
Check_Date date,
Card_Type Varchar2(200),
Card_Num Varchar2(200),
Transaction_Log_ID Varchar2(200),
Transaction_User_ID Varchar2(200),
Transaction_Status Varchar2(200),
Source Varchar2(30));


---> IG TO TEMP

Insert into IG_LAYER_CDVQ.TEMP_Payments
SELECT * FROM IG_LAYER_CDVQ.IG1_CDVQ_payments;

commit;

--Access Layer

create sequence S_Payment;


create table access_layer_cdvq.DIM_Payments
(
payment_key number primary key,
Order_Unique_ID Number,
Payment_Unique_ID Number ,
Payment_Sequential Number,
Payment_Type Varchar2(200),
Payment_Installments Number,
Check_Date date,
Card_Type Varchar2(200),
Card_Num Varchar2(200),
Transaction_Log_ID Varchar2(200),
Transaction_User_ID Varchar2(200),
Transaction_Status Varchar2(200),
ROW_INSERT_DT date,
ROW_UPDATE_DT date)
;


insert into access_layer_cdvq.DIM_Payments

SELECT
S_payment.nextval,
Order_Unique_ID,
Payment_Unique_ID  ,
Payment_Sequential ,
Payment_Type ,
Payment_Installments ,
Check_Date ,
Card_Type ,
Card_Num ,
Transaction_Log_ID ,
Transaction_User_ID ,
Transaction_Status,
sysdate,
to_date('12-31-9999','mm-dd-yyyy')
from IG_LAYER_CDVQ.TEMP_Payments; 

commit;


-----------------------------------------------------------------------------------------------


--->Reviews Table

--SRC TABLE


create table stg_layer_cdvq.SRC1_CDVQ_Reviews

(

NATASITE_ID Varchar2(200),
Review_ID Varchar2(200),
Order_Unique_ID Varchar2(200),
Product_id varchar2(200),
Customer_Unique_ID Varchar2(200),
Review_Score Varchar2(200),
Review_Condition varchar2(200),
Review_Method Varchar2(200),
Review_Case Varchar2(200),
Review_Reason Varchar2(200),
Review_State Varchar2(200),
Customer_Verification_Status Varchar2(200),
Reply_Reflect_State Varchar2(200),
Review_Elicitation Varchar2(200),
Reviewer_Reputation Varchar2(200),
Review_Post_Date Varchar2(200),
Review_Created_Date Varchar2(200));




--> STG Table 

create table stg_layer_cdvq.STG1_CDVQ_Reviews

(
NATASITE_ID Varchar2(200),
Review_ID Number,
Order_Unique_ID Number,
Product_id Number,
Customer_Unique_ID Number,
Review_Score Number,
Review_Condition varchar2(200),
Review_Method Varchar2(200),
Review_Case Varchar2(200),
Review_Reason Varchar2(200),
Review_State Varchar2(200),
Customer_Verification_Status Varchar2(200),
Reply_Reflect_State Varchar2(200),
Review_Elicitation Varchar2(200),
Reviewer_Reputation Varchar2(200),
Review_Post_Date date,
Review_Created_Date date);


Insert into stg_layer_cdvq.STG1_CDVQ_Reviews

SELECT

NATASITE_ID ,
cast(Review_ID as Number),
cast(Order_Unique_ID as Number),
cast(Product_id as Number),
cast(Customer_Unique_ID as Number),
cast(Review_Score as Number),
Review_Condition ,
Review_Method ,
Review_Case ,
Review_Reason ,
Review_State ,
Customer_Verification_Status ,
Reply_Reflect_State ,
Review_Elicitation ,
Reviewer_Reputation ,
to_date(Review_Post_Date,'dd-mm-yyyy'),
to_date(Review_Created_Date,'dd-mm-yyyy')
from stg_layer_cdvq.SRC1_CDVQ_Reviews;

commit;



--> IG TABLE

create table ig_layer_cdvq.IG1_CDVQ_Reviews
(
NATASITE_ID Varchar2(200),
Review_ID Number,
Order_Unique_ID Number,
Product_id Number,
Customer_Unique_ID Number,
Review_Score Number,
Review_Condition varchar2(200),
Review_Method Varchar2(200),
Review_Case Varchar2(200),
Review_Reason Varchar2(200),
Review_State Varchar2(200),
Customer_Verification_Status Varchar2(200),
Reply_Reflect_State Varchar2(200),
Review_Elicitation Varchar2(200),
Reviewer_Reputation Varchar2(200),
Review_Post_Date date,
Review_Created_Date date,
Source varchar2(30));

--STG TO IG 

Insert into ig_layer_cdvq.IG1_CDVQ_Reviews

select 
NATASITE_ID,
Review_ID,
Order_Unique_ID,
Product_id ,
Customer_Unique_ID,
Review_Score,
Review_Condition,
Review_Method,
Review_Case,
Review_Reason,
Review_State,
Customer_Verification_Status,
Reply_Reflect_State,
Review_Elicitation,
Reviewer_Reputation,
Review_Post_Date,
Review_Created_Date,
'S1'
from stg_layer_cdvq.STG1_CDVQ_Reviews;

commit;

--> temp table 

create table ig_layer_cdvq.TEMP_Reviews
(
NATASITE_ID Varchar2(200),
Review_ID Number,
Order_Unique_ID Number,
Product_id Number,
Customer_Unique_ID Number,
Review_Score Number,
Review_Condition varchar2(200),
Review_Method Varchar2(200),
Review_Case Varchar2(200),
Review_Reason Varchar2(200),
Review_State Varchar2(200),
Customer_Verification_Status Varchar2(200),
Reply_Reflect_State Varchar2(200),
Review_Elicitation Varchar2(200),
Reviewer_Reputation Varchar2(200),
Review_Post_Date date,
Review_Created_Date date,
Source varchar2(30));


---> IG TO TEMP

Insert into IG_LAYER_CDVQ.TEMP_Reviews
SELECT * FROM IG_LAYER_CDVQ.IG1_CDVQ_Reviews;

commit;



--Access Layer

create sequence S_Review;


create table access_layer_cdvq.DIM_Reviews
(
Review_key number primary key,
NATASITE_ID Varchar2(200),
Review_ID Number,
Order_Unique_ID Number,
Product_id Number,
Customer_Unique_ID Number,
Review_Score Number,
Review_Condition varchar2(200),
Review_Method Varchar2(200),
Review_Case Varchar2(200),
Review_Reason Varchar2(200),
Review_State Varchar2(200),
Customer_Verification_Status Varchar2(200),
Reply_Reflect_State Varchar2(200),
Review_Elicitation Varchar2(200),
Reviewer_Reputation Varchar2(200),
Review_Post_Date date,
Review_Created_Date date,
ROW_INSERT_DT date,
ROW_UPDATE_DT date
);


insert into access_layer_cdvq.DIM_Reviews

SELECT
S_Review.nextval,
NATASITE_ID,
Review_ID,
Order_Unique_ID,
Product_id,
Customer_Unique_ID,
Review_Score,
Review_Condition,
Review_Method,
Review_Case,
Review_Reason,
Review_State,
Customer_Verification_Status,
Reply_Reflect_State,
Review_Elicitation,
Reviewer_Reputation,
Review_Post_Date,
Review_Created_Date,
sysdate,
to_date('12-31-9999','mm-dd-yyyy')
from IG_LAYER_CDVQ.TEMP_Reviews; 

commit;


----------------------------------------------------------------------------------------------


--->Sellers Table

--SRC TABLE

create table stg_layer_cdvq.SRC1_CDVQ_Sellers
(
PIPS_ID Varchar2(200),
Seller_ID Varchar2(200) ,
Seller_Zip_Code_Prefix Varchar2(200),
Seller_City Varchar2(200),
Seller_State Varchar2(200),
Product_ID Varchar2(200),
Seller_Section Varchar2(200),
Seller_Code_List Varchar2(200),
Seller_Code_Rating Varchar2(200),
Seller_Registration_Type Varchar2(200),
Trading_Cause Varchar2(200),
Cred_Raw_Rating Varchar2(200),
Raw_Reviews Varchar2(200),
Seller_Country_Code Varchar2(200),
Seller_Country_Name Varchar2(200),
Seller_Reg_Timestamp Varchar2(200),
Seller_Last_Update_Timestamp Varchar2(200));




--> STG Table 


create table stg_layer_cdvq.STG1_CDVQ_Sellers
(

PIPS_ID Varchar2(200),
Seller_ID Number ,
Seller_Zip_Code_Prefix Number,
Seller_City Varchar2(200),
Seller_State Varchar2(200),
Product_ID Number,
Seller_Section Varchar2(200),
Seller_Code_List Varchar2(200),
Seller_Code_Rating Number,
Seller_Registration_Type Varchar2(200),
Trading_Cause Varchar2(200),
Cred_Raw_Rating Varchar2(200),
Raw_Reviews Number,
Seller_Country_Code Varchar2(200),
Seller_Country_Name Varchar2(200),
Seller_Reg_Timestamp date ,
Seller_Last_Update_Timestamp date);




Insert into stg_layer_cdvq.STG1_CDVQ_Sellers

SELECT
PIPS_ID ,
cast(Seller_ID as Number) ,
cast(Seller_Zip_Code_Prefix as Number),
Seller_City ,
Seller_State ,
cast(Product_ID as Number),
Seller_Section ,
Seller_Code_List ,
cast(Seller_Code_Rating as Number),
Seller_Registration_Type ,
Trading_Cause ,
Cred_Raw_Rating ,
cast(Raw_Reviews as Number),
Seller_Country_Code ,
Seller_Country_Name ,
cast(Seller_Reg_Timestamp as date) ,
cast(Seller_Last_Update_Timestamp as date)
from stg_layer_cdvq.SRC1_CDVQ_Sellers;


commit;


--> IG TABLE

create table ig_layer_cdvq.IG1_CDVQ_Sellers
(


PIPS_ID Varchar2(200),
Seller_ID Number ,
Seller_Zip_Code_Prefix Number,
Seller_City Varchar2(200),
Seller_State Varchar2(200),
Product_ID Number,
Seller_Section Varchar2(200),
Seller_Code_List Varchar2(200),
Seller_Code_Rating Number,
Seller_Registration_Type Varchar2(200),
Trading_Cause Varchar2(200),
Cred_Raw_Rating Varchar2(200),
Raw_Reviews Number,
Seller_Country_Code Varchar2(200),
Seller_Country_Name Varchar2(200),
Seller_Reg_Timestamp date ,
Seller_Last_Update_Timestamp date,
Source varchar2(30));


--STG TO IG 

Insert into ig_layer_cdvq.IG1_CDVQ_Sellers

select
PIPS_ID,
Seller_ID,
Seller_Zip_Code_Prefix,
Seller_City,
Seller_State,
Product_ID,
Seller_Section,
Seller_Code_List,
Seller_Code_Rating,
Seller_Registration_Type,
Trading_Cause,
Cred_Raw_Rating,
Raw_Reviews,
Seller_Country_Code,
Seller_Country_Name,
Seller_Reg_Timestamp,
Seller_Last_Update_Timestamp,
'S1'
from stg_layer_cdvq.STG1_CDVQ_Sellers;

commit;
--> temp table 

create table ig_layer_cdvq.TEMP_Sellers
(
PIPS_ID Varchar2(200),
Seller_ID Number ,
Seller_Zip_Code_Prefix Number,
Seller_City Varchar2(200),
Seller_State Varchar2(200),
Product_ID Number,
Seller_Section Varchar2(200),
Seller_Code_List Varchar2(200),
Seller_Code_Rating Number,
Seller_Registration_Type Varchar2(200),
Trading_Cause Varchar2(200),
Cred_Raw_Rating Varchar2(200),
Raw_Reviews Number,
Seller_Country_Code Varchar2(200),
Seller_Country_Name Varchar2(200),
Seller_Reg_Timestamp date ,
Seller_Last_Update_Timestamp date,
Source varchar2(30));


---> IG TO TEMP

Insert into IG_LAYER_CDVQ.TEMP_Sellers
SELECT * FROM IG_LAYER_CDVQ.IG1_CDVQ_Sellers;

commit;

--Access Layer

create sequence S_Seller;


create table access_layer_cdvq.DIM_Sellers
(
Seller_key number primary key,
PIPS_ID Varchar2(200),
Seller_ID Number ,
Seller_Zip_Code_Prefix Number,
Seller_City Varchar2(200),
Seller_State Varchar2(200),
Product_ID Number,
Seller_Section Varchar2(200),
Seller_Code_List Varchar2(200),
Seller_Code_Rating Number,
Seller_Registration_Type Varchar2(200),
Trading_Cause Varchar2(200),
Cred_Raw_Rating Varchar2(200),
Raw_Reviews Number,
Seller_Country_Code Varchar2(200),
Seller_Country_Name Varchar2(200),
Seller_Reg_Timestamp date ,
Seller_Last_Update_Timestamp date,
ROW_INSERT_DT date,
ROW_UPDATE_DT date
);



insert into access_layer_cdvq.DIM_Sellers

SELECT
S_Seller.nextval,
PIPS_ID,
Seller_ID,
Seller_Zip_Code_Prefix,
Seller_City,
Seller_State,
Product_ID,
Seller_Section,
Seller_Code_List,
Seller_Code_Rating,
Seller_Registration_Type,
Trading_Cause,
Cred_Raw_Rating,
Raw_Reviews,
Seller_Country_Code,
Seller_Country_Name,
Seller_Reg_Timestamp,
Seller_Last_Update_Timestamp,
sysdate,
to_date('12-31-9999','mm-dd-yyyy')
from IG_LAYER_CDVQ.TEMP_Sellers; 

commit;

---------------------------------------------------------------------------------------------


----src_table

create table src_cdvq_date(
FULL_DATE date,
Year number,
Quarter varchar2(2),
DAY_OF_MONTH number(2),
DAY_NAME varchar2(10),
day_of_week number(2),
Month_Name varchar2(10),
Month_Number number(2),
day_of_year number(3));




create sequence s_date;


create table dim_date(
date_key number primary key,
FULL_DATE date,
Year number,
Quarter varchar2(2),
DAY_OF_MONTH number(2),
DAY_NAME varchar2(10),
day_of_week number(2),
Month_Name varchar2(10),
Month_Number number(2),
day_of_year number(3));




insert into access_layer_cdvq.dim_date
select
s_date.nextval,
FULL_DATE ,
Year ,
Quarter ,
DAY_OF_MONTH ,
DAY_NAME ,
day_of_week ,
Month_Name ,
Month_Number ,
day_of_year
from stg_layer_cdvq.src_cdvq_date;


commit;

----------------------------------------------------------------------------------

create table cdvq_fact_sales
(
CUST_key number references dim_customers (CUST_key),
Product_key number references DIM_products (Product_key),
Order_key number references Dim_Orders (Order_key),
payment_key number references Dim_payments (Payment_key),
date_key number references dim_date(date_key),
Price number,
selling_price number,
quantity number,
discount number,
delivery_charges number,
Net_price number,
Profit number
);




merge into cdvq_fact_sales cf 
using 
(select c.cust_key,
p.product_key,
o.order_key,
py.Payment_key,
d.date_key,
sum(p.product_price) as price,
sum(p.product_selling_price) as selling_price,
sum(o.ORDER_QUANTITY_NUMBER) as quantity,
sum(p.product_selling_price*0.1) as discount,
sum(o.DELIVERY_CHARGES) as delivery_charges ,
sum((p.product_selling_price*o.order_quantity_number)-o.delivery_charges) as net_price,
sum((p.product_selling_price*o.order_quantity_number)-o.delivery_charges)-
sum((p.product_price*o.order_quantity_number)-o.delivery_charges) as profit
from dim_orders o left outer join dim_products p
on o.product_id=p.product_id
left outer join dim_customers c
on o.customer_id=c.cust_id
left outer join dim_payments py
on o.order_unique_id=py.order_unique_id
left outer join dim_date d
on o.order_purchase_date=d.full_date
group by 
 c.cust_key,
p.product_key,
o.order_key,
py.Payment_key,
d.date_key) st 
on(cf.order_key=st.order_key)
when matched then 
update set cf.cust_key=st.cust_key,cf.product_key=st.product_key,cf.Payment_key=st.Payment_key,
cf.date_key=st.date_key,cf.Price=st.Price,cf.selling_price=st.selling_price,cf.quantity =st.quantity,
cf.discount =st.discount ,cf.delivery_charges=st.delivery_charges ,cf.Net_price=st.Net_price ,
cf.Profit=st.Profit
when not matched then 
insert (
cf.CUST_key ,
cf.Product_key,
cf.Order_key ,
cf.payment_key ,
cf.date_key,
cf.Price ,
cf.selling_price ,
cf.quantity ,
cf.discount ,
cf.delivery_charges ,
cf.Net_price ,
cf.Profit ) values (st.CUST_key ,
st.Product_key,
st.Order_key ,
st.payment_key ,
st.date_key,
st.Price ,
st.selling_price ,
st.quantity ,
st.discount ,
st.delivery_charges ,
st.Net_price ,
st.Profit );