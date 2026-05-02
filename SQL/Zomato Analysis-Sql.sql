create database Zomato_Sales_Analysis;
select * from  main;
select * from  currency;
select * from  country;
DESC main;
SET SQL_SAFE_UPDATES = 0;
ALTER TABLE main RENAME COLUMN `Country name` TO countryname;
ALTER TABLE main RENAME COLUMN `Month Name` TO monthname;
ALTER TABLE main RENAME COLUMN `Quater` TO `Quarter`;
ALTER TABLE country RENAME COLUMN `Countryname` TO country_name;

select count('restaurant name ') from main;


--------------    A.Year      ---------------------

ALTER TABLE main 
ADD COLUMN Year INT;
UPDATE main
SET Year = RIGHT(`year&date`, 4);
select Year from main;


--------------    B.Monthno    ----------------------

ALTER TABLE main
ADD COLUMN Month INT;
UPDATE main
SET Month = SUBSTRING(`year&date`, 4, 2);
select Month from main ;


--------------    C.Monthfullname   ------------------

ALTER TABLE main
ADD COLUMN monthname VARCHAR(15);
UPDATE main
SET monthname = MONTHNAME(STR_TO_DATE(`year&date`, '%d-%m-%Y'));
select monthname from main;


---------------    D.Quarter(Q1,Q2,Q3,Q4)   -----------------

ALTER TABLE main
ADD COLUMN Quarter VARCHAR(2);
UPDATE main
SET Quarter = CONCAT('Q',QUARTER(STR_TO_DATE(`year&date`, '%d-%m-%Y')))
WHERE `year&date` IS NOT NULL;
select Quarter from main;


--------------    E. YearMonth ( YYYY-MMM)      ------------------

ALTER TABLE main
ADD COLUMN `year_month` VARCHAR(10);
UPDATE main
SET `year_month` = DATE_FORMAT(STR_TO_DATE(`year&date`, '%d-%m-%Y'),'%Y-%b')
WHERE `year&date` IS NOT NULL;
select `year_month` from main;


---------------   F. Weekdayno   ---------------------

ALTER TABLE main
ADD COLUMN weekday_no INT;
UPDATE main
SET weekday_no = WEEKDAY(STR_TO_DATE(`year&date`, '%d-%m-%Y')) + 1
WHERE `year&date` IS NOT NULL;
select weekday_no from main;


---------------   G.Weekdayname    -----------------------

ALTER TABLE main
ADD COLUMN DayName VARCHAR(10);
UPDATE main
SET DayName = DAYNAME(STR_TO_DATE(`year&date`, '%d-%m-%Y'))
WHERE `year&date` IS NOT NULL;
select DayName from main;


--------------     H.FinancialMonth ( April = FM1, May= FM2  …. March = FM12)   ----------------

ALTER TABLE main
ADD COLUMN FinancialMonth VARCHAR(4);
UPDATE main
SET FinancialMonth = CONCAT('FM',
    CASE
        WHEN MONTH(STR_TO_DATE(`year&date`, '%d-%m-%Y')) >= 4
            THEN MONTH(STR_TO_DATE(`year&date`, '%d-%m-%Y')) - 3
        ELSE MONTH(STR_TO_DATE(`year&date`, '%d-%m-%Y')) + 9
    END)
WHERE `year&date` IS NOT NULL;
select FinancialMonth from main;


----------------   I. Financial Quarter ( Quarters based on Financial Month FQ-1 . FQ-2..)    -----------------

ALTER TABLE main
ADD COLUMN FinancialQuarter VARCHAR(4);
UPDATE main
SET FinancialQuarter = CONCAT(
    'FQ',
    CASE
        WHEN MONTH(STR_TO_DATE(`year&date`, '%d-%m-%Y')) BETWEEN 4 AND 6 THEN 1
        WHEN MONTH(STR_TO_DATE(`year&date`, '%d-%m-%Y')) BETWEEN 7 AND 9 THEN 2
        WHEN MONTH(STR_TO_DATE(`year&date`, '%d-%m-%Y')) BETWEEN 10 AND 12 THEN 3
        ELSE 4
    END
)
WHERE `year&date` IS NOT NULL;
select FinancialQuarter from main;


-----------  Convert the Average cost for 2 column into USD dollars (currently the Average cost for 2 in local currencies  ----------------

ALTER TABLE main
ADD COLUMN USDRate DECIMAL(10,2);
UPDATE main
SET USDRate =
    CASE Currency
        WHEN 'Indian Rupees(Rs.)'        THEN `Average cost for two` * 0.012
        WHEN 'Dollar($)'                 THEN `Average cost for two` * 1
        WHEN 'Pounds(Œ£)'                THEN `Average cost for two` * 1.24
        WHEN 'NewZealand($)'             THEN `Average cost for two` * 0.6
        WHEN 'Emirati Diram(AED)'        THEN `Average cost for two` * 0.27
        WHEN 'Brazilian Real(R$)'        THEN `Average cost for two` * 0.2
        WHEN 'Turkish Lira(TL)'          THEN `Average cost for two` * 0.05
        WHEN 'Qatari Rial(QR)'           THEN `Average cost for two` * 0.27
        WHEN 'Rand(R)'                   THEN `Average cost for two` * 0.051
        WHEN 'Botswana Pula(P)'          THEN `Average cost for two` * 0.073
        WHEN 'Sri Lankan Rupee(LKR)'     THEN `Average cost for two` * 0.0034
        WHEN 'Indonesian Rupiah(IDR)'    THEN `Average cost for two` * 0.000067
        ELSE NULL
    END
WHERE `Average_Cost_for_two` IS NOT NULL;
select USDRate from main;


 ---------   Find the Numbers of Resturants based on City and Country.    ---------------

select city ,count(restaurantid) from main group by city;

select countryname,count(restaurantid) from main m
left join country c on m.CountryCode=c.CountryID
group by countryname;


 ----------   Numbers of Resturants opening based on Year , Quarter , Month   -------------
 
SELECT `year`,COUNT(*) AS total_restaurants
FROM main
GROUP BY `year` ORDER BY `year`;

SELECT monthname,COUNT(*) AS total_restaurants
FROM main
GROUP BY monthname;

select `Quarter`,count(*) as RestaurantCount from main
where `Quarter` is not null
group by `Quarter`
order by `Quarter`;



------------   Percentage of Resturants based on "Has_Table_booking"  ---------------

select Has_Table_booking,count(*) as TotalRestaurants,
round((count(*) / (select count(*) from main)) * 100,2) as Percentage
from main group by Has_Table_booking;



------------   Percentage of Resturants based on "Has_Online_delivery"  ---------------

select Has_Online_delivery ,count(*) as TotalRestaurants,
round((count(*) / (select count(*) from main)) * 100,2) as Percentage
from main group by Has_Online_delivery;



------------   Count of Resturants based on Average Ratings  -----------------

select Rating as IndividualRating,count(*) as RestaurantCount
from main
Where Rating is not null
group by Rating
order by Rating asc;



-----------  Create buckets based on Average Price of reasonable size and find out how many resturants falls in each buckets  ---------------

select Cost_Range,count(*) as TotalRestaurants
from ( select case
                   when Average_Cost_for_two between 0 and 300 then '0-300'
                   when Average_Cost_for_two between 301 and 600 then '301-600'
                   when Average_Cost_for_two between 601 and 1000 then '601-1000'
                   when Average_Cost_for_two between 1001 and 430000 then '1001-430000'
                   else 'Other'
			   end as Cost_Range
from main ) as subquery
group by Cost_Range;






-----------  Total Cuisines  -----------------
select Cuisines,count(Cuisines) from main group by Cuisines;



























