1.retrieve the total number of order placed
SELECT count(order_id) as total_orders FROM pizzapoint.orders;

2.Find the total number of pizzas ordered on a specific date
 SELECT SUM(quantity) AS total_pizzas
FROM order_details od JOIN orders  o ON od.order_id = o.order_id
WHERE date = '2015-01-01';

3.Get the details of all orders that include a specific pizza (e.g., 'hawaiian_m')
SELECT o.order_id, o.date, o.time, od.pizza_id, od.quantity
FROM orders  o
JOIN order_details   od  ON o.order_id = od.order_id
WHERE od.pizza_id = 'hawaiian_m';

4.calculate the total renvenue generated from the pizza sales 
SELECT  ROUND(SUM(o.quantity * p.price),2) AS total_renvenue
FROM pizzas p JOIN
 order_details o ON p.pizza_id = o.pizza_id;

5.identify the highest-priced pizza
SELECT  p.price, pt.name
FROM pizza_types pt JOIN
  pizzas p ON p.pizza_type_id = pt.pizza_type_id
ORDER BY p.price DESC
LIMIT 1; 

6.identify the most common pizza size ordered
SELECT  COUNT(o.idorder_details_id) AS common_size, p.size
FROM order_details o  JOIN
pizzas p ON o.pizza_id = p.pizza_id
GROUP BY p.size
ORDER BY common_size DESC;

7.list the top 5 most ordered pizza types along with their quantities 
SELECT 
SUM(o.quantity) AS total_quantity, pt.name
FROM order_details o JOIN
pizzas p ON p.pizza_id = o.pizza_id JOIN  pizza_types pt ON pt.pizza_type_id = p.pizza_type_id
GROUP BY pt.name
ORDER BY total_quantity DESC
LIMIT 5;

8.join necessary tables to find the total quantity of each pizza cateogry
SELECT 
SUM(o.quantity) AS total_quantity, pt.category
FROM order_details o JOIN
pizzas p ON p.pizza_id = o.pizza_id JOIN
pizza_types pt ON pt.pizza_type_id = p.pizza_type_id
GROUP BY pt.category
ORDER BY total_quantity DESC ;

9.determine the distribution of orders by hour of the day 
SELECT 
HOUR(order_time) AS hours, COUNT(order_id) AS order_count
FROM orders
GROUP BY HOUR(order_time);

10.join the relevant tables to find the cateogry-wise disribution of pizzas 
select category , count(name) from  pizza_types
group by category ;

11.group the orders by date and calculate the average number of pizzas ordered per day 
 SELECT  AVG(quantity) AS avg_quantity_per_day
FROM
 (SELECT 
 SUM(o.quantity) AS quantity, od.order_date
FROM orders od JOIN order_details o ON o.order_id = od.order_id
  GROUP BY od.order_date) AS tol_quan; 

12.determine the top 3 most ordered pizza types based on revenues 
 select sum(o.quantity * p.price ) as revenue  , pt.name 
 from order_details  o 
 join pizzas p  on p.pizza_id = o.pizza_id
 join pizza_types pt on pt.pizza_type_id = p.pizza_type_id 
 group by pt.name 
 order by revenue desc limit 3 ;

13.calculate the percentage contribution of each pizza type to total revenue 
SELECT   SUM(o.quantity * p.price) AS revenue,  pt.category,
 ROUND((SUM(o.quantity * p.price) / (SELECT  ROUND(SUM(o.quantity * p.price), 2) FROM
  pizzas p  JOIN order_details o ON p.pizza_id = o.pizza_id)) * 100) AS revenue_percentage
FROM order_details o JOIN
pizzas p ON p.pizza_id = o.pizza_id JOIN pizza_types pt ON pt.pizza_type_id = p.pizza_type_id
GROUP BY pt.category
ORDER BY revenue DESC;

14.analyze the cumulative revenue generated over time
select order_date ,revenue , sum(revenue) over (order by order_date) as cum_revenue
from (select  od.order_date , round(sum(o.quantity * p.price),0)as revenue 
from order_details o
join pizzas  p on o.pizza_id = p.pizza_id
join orders od on o.order_id = od.order_id
group by od.order_date 
order by od.order_date )  as sales ;

15.determine the top 3 most ordered pizza types based on revenue for each pizza category
select name , revenue 
from
(select name , category , revenue , 
rank() over ( partition by category order by revenue desc ) as rn 
from
(select pt.category , pt.name , sum( od.quantity * p.price ) as revenue 
from pizza_types pt
join pizzas p on pt.pizza_type_id = p.pizza_type_id
join order_details  od on od.pizza_id = p.pizza_id 
group by pt.category , pt.name ) as a) as b 
where rn <=3 ;

16.Find the day with the highest sales in terms of the number of pizzas sold and display the details of the orders on that day:
WITH daily_sales AS (
    SELECT date, SUM(quantity) AS total_pizzas
    FROM orders
    JOIN order_details ON o.order_id = od.order_id
    GROUP BY date
)
SELECT o.order_id, o.date, o.time, od.pizza_id, od.quantity
FROM orders o
JOIN order_details od ON o.order_id = od.order_id
WHERE o.date = (SELECT date FROM daily_sales ORDER BY total_pizzas DESC LIMIT 1)
