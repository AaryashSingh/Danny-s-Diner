#aaryashsingh
-- 1. What is the total amount each customer spent at the restaurant?
SELECT customer_id, SUM(price) FROM sales 
JOIN menu 
ON sales.product_id = menu.product_id
GROUP BY customer_id;


-- 2. How many days has each customer visited the restaurant?
SELECT customer_id, count(DISTINCT order_date) AS 'Days Visited' FROM sales
GROUP BY customer_id;

-- 3. What was the first item from the menu purchased by each customer?
WITH ordered_sales AS (
  SELECT 
    sales.customer_id, 
    sales.order_date, 
    menu.product_name,
    DENSE_RANK() OVER (
      PARTITION BY sales.customer_id 
      ORDER BY sales.order_date) AS rn
  FROM dannys_diner.sales
  INNER JOIN dannys_diner.menu
    ON sales.product_id = menu.product_id
)
SELECT 
  customer_id, 
  product_name
FROM ordered_sales
WHERE rn = 1
GROUP BY customer_id, product_name;


-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
SELECT 
    sales.product_id,
    count(*),
    menu.product_name 
from sales join menu
ON sales.product_id = menu.product_id
group by sales.product_id,menu.product_name 
order by count(*) desc limit 1;


-- 5. Which item was the most popular for each customer?
With fav_order as (Select 
	customer_id,
    menu.product_name, 
    count(sales.product_id) as order_count,
	dense_rank() over(partition by customer_id order by count(sales.product_id) desc) AS ranking
from sales join menu
ON sales.product_id = menu.product_id 
group by customer_id,menu.product_name
order by customer_id asc,count(sales.product_id) desc)
Select customer_id,
	product_name,
    order_count
from fav_order
where ranking = 1;


-- 6. Which item was purchased first by the customer after they became a member?
with member_first_order as(
select 
	members.customer_id,
	product_name,
    order_date,
    dense_rank() over(partition by members.customer_id order by order_date) AS ranking
from members JOIN sales
on members.customer_id = sales.customer_id
JOIN menu
on sales.product_id = menu.product_id
where sales.order_date > members.join_date)
SELECT customer_id,
	product_name
    from member_first_order
    where ranking = 1;

-- 7. Which item was purchased just before the customer became a member?
WITH orders_befor_membership AS (
SELECT 
	members.customer_id,
	menu.product_name,
    dense_rank() over(PARTITION BY members.customer_id order by order_date) AS ranking
from members JOIN sales
on members.customer_id = sales.customer_id
JOIN menu
on sales.product_id = menu.product_id
WHERE order_date < join_date)
SELECT 
	customer_id,
    product_name
    from orders_befor_membership
    where ranking = 1;
    
-- 8. What is the total items and amount spent for each member before they became a member?
SELECT 
	sales.customer_id,
	count(sales.product_id), 
	sum(price) 
FROM menu JOIN sales
ON sales.product_id = menu.product_id
JOIN members 
ON members.customer_id = sales.customer_id
where order_date < join_date
group by sales.customer_id
order by sales.customer_id;

-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

SELECT 
	sales.customer_id,
    SUM(CASE
		WHEN sales.product_id = 1 then price*20
        else price*10
        END) AS points
	from sales join menu
    on sales.product_id = menu.product_id
    group by sales.customer_id;
    
    
    