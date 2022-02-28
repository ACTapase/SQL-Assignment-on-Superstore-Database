use superstore;

/*--------------------------------Assignment 2 ----------------------------*/

/* -- Q.1 Write query to display the Customer_Name and Customer Segment using alias name “Customer Name", "Customer Segment" from table Cust_dimen. --*/

select Customer_Name as "CUSTOMER NAME",Customer_Segment as "CUSTOMER SEGMENT" 
from cust_dimen;

/* -- Q.2 Write a query to find all the details of the customer from the table cust_dimen order by desc --*/

SELECT * 
FROM cust_dimen ORDER BY cust_id DESC;

/* -- Q.3  Write a query to get the Order ID, Order date from table orders_dimen where ‘Order Priority’ is high --*/

select Order_ID ,Order_Date,Order_Priority 
from orders_dimen 
where Order_Priority =  "HIGH";

/* -- Q.4  Find the total and the average sales (display total_sales and avg_sales)  -- Ans: TOTAL_SALES=14647187.90 And AVG SALES= 1757.100  --*/

SELECT SUM(SALES) AS TOTAL_SALES,AVG(SALES) AS AVG_SALES 
FROM market_fact;
  
/* -- Q.5  Write a query to get the maximum and minimum sales from maket_fact table        -- Ans : MAX SALES = 89061.05 And MIN SALES = 2.24 --*/

SELECT MAX(SALES) AS MAX_SALES,MIN(SALES) AS MIN_SALES 
FROM market_fact;
  
/* -- Q.6  Display the number of customers in each region in decreasing order of no_of_customers.The result should contain columns Region, no_of_customers.  -- */

SELECT region, COUNT(*) AS no_of_customers 
FROM cust_dimen  GROUP BY region ORDER BY no_of_customers DESC; 

/* -- Q.7  Find the region having maximum customers (display the region name and max(no_of_customers) -- Ans : WEST=382 --*/
  
SELECT region, COUNT(*) AS no_of_customers 
FROM cust_dimen GROUP BY region  HAVING no_of_customers >= ALL ( SELECT COUNT(*) AS no_of_customers FROM cust_dimen GROUP BY region );

/*-- Q.8  Find all the customers from Atlantic region who have ever purchased ‘TABLES’ and the number of tables purchased (display the customer name, no_of_tables purchased ). -- */
  
SELECT c.customer_name, COUNT(*) AS no_of_tables_purchased
FROM market_fact m
INNER JOIN
cust_dimen c ON m.cust_id = c.cust_id
WHERE
c.region = 'atlantic'
AND m.prod_id = ( SELECT 
				  prod_id
				  FROM
				  prod_dimen
				  WHERE
				  product_sub_category = 'tables'	)
GROUP BY m.cust_id, c.customer_name;
        
/* -- Q.9  Find all the customers from Ontario province who own Small Business. (display the customer name, no of small business owners) -- */    

SELECT Customer_Name as "Customer Name" ,Customer_Segment as "no. of small businees owners"
FROM cust_dimen  
where Province="ONTARIO" AND  Customer_Segment="SMALL BUSINESS";


/* -- Q.10  Find the number and id of products sold in decreasing order of products sold (display product id, no_of_products sold) -- */

SELECT prod_id AS product_id, COUNT(*) AS no_of_products_sold
FROM  market_fact GROUP BY prod_id ORDER BY no_of_products_sold DESC;

/* -- Q.11  Display product Id and product sub category whose produt category belongs to Furniture and Technlogy. The result should contain columns product id, product sub category.  -- */

SELECT prod_id, product_sub_category 
from prod_dimen where product_category ='furniture' OR  product_category='technology';

/*-- Q.12  Display the product categories in descending order of profits (display the product category wise profits i.e. product_category, profits)?  -- */    

select b.product_category,b.product_sub_category,a.profit 
from superstore.market_fact a inner join superstore.prod_dimen b
on a.Prod_id
group by b.Product_Sub_Category;
select*from superstore.market_fact;
 
/* -- Q.13 Display the product category, product sub-category and the profit within each subcategory in three columns.  -- */

select b.product_category,b.product_sub_category, a. profit 
from superstore.market_fact a inner join superstore.prod_dimen b on a.Prod_id=b.Prod_id
group by b.Product_Sub_Category;

/* -- Q.14  Display the order date, order quantity and the sales for the order.   -- */

select b.order_date,a.order_quantity,a.sales 
from superstore.market_fact a join superstore.orders_dimen b on a.Ord_id = b.Ord_id;

/* -- Q.15  Display the names of the customers whose name contains the  i) Second letter as ‘R’   ii) Fourth letter as ‘D’       -- */

select customer_name from superstore.cust_dimen where Customer_Name like '_R%';
select customer_name from superstore.cust_dimen where Customer_Name like '___D%';

/* -- Q.16  Write a SQL query to to make a list with Cust_Id, Sales, Customer Name and their region where sales are between 1000 and 5000.    -- */

select a.cust_id,b.sales,a.customer_name,a.region 
from superstore.cust_dimen a join superstore.market_fact b on a.Cust_id = b.Cust_id
where sales between 1000 and 5000;

/* --  Q.17 Write a SQL query to find the 3rd highest sales.   -- */

select sales as '3rd highest sales'
from (select*, dense_rank() over (order by sales Desc) as d_rank from superstore.market_fact) a 
where d_rank=3;	

/* -- Q.18 Where is the least profitable product subcategory shipped the most? For the least profitable product sub-category, display the region-wise no_of_shipments and the profit made in each region in decreasing order of profits (i.e. region, no_of_shipments, profit_in_each_region)  -- */

SELECT c.region, COUNT(distinct s.ship_id) AS no_of_shipments, SUM(m.profit) AS profit_in_each_region
FROM market_fact m
INNER JOIN
cust_dimen c ON m.cust_id = c.cust_id
INNER JOIN
shipping_dimen s ON m.ship_id = s.ship_id
INNER JOIN
prod_dimen p ON m.prod_id = p.prod_id
WHERE
p.product_sub_category IN 
    (	SELECT 							
		p.product_sub_category
        FROM
		market_fact m
		INNER JOIN
		prod_dimen p ON m.prod_id = p.prod_id
        GROUP BY p.product_sub_category
        HAVING SUM(m.profit) <= ALL
				(	SELECT 
					SUM(m.profit) AS profits
					FROM
					market_fact m
					INNER JOIN
					prod_dimen p ON m.prod_id = p.prod_id
					GROUP BY p.product_sub_category
				)
	)
GROUP BY c.region
ORDER BY profit_in_each_region DESC;