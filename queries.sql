--Q1 Retrieve all customer records
select * from customers;

--Q2 Display customer names, cities, and segments.
select customer_name, city, customer_segment
from customers;

--Q3 Find customers living in Nairobi.
select * from customers
where city = 'Nairobi';

--Q4 Find customers registered after January 1, 2025.
select * from customers
where registration_date > '2025-01-01';

--Q5 Display all unique customer cities
select distinct  city 
from customers;

--Q6 Retrieve the 10 most recent orders
select * from orders
order by order_date desc
limit 10;

--Q7 Orders with unit prices above KSh 10,000
select * from orders 
where unit_price > 10000;

--Q8 Customers whose names start with A
select * from customers 
where customer_name LIKE 'A%';

--Q9 Orders with quantities between 2 and 5.
select * from orders
where quantity between 2 and 5;

--Q10 Orders paid through M-Pesa.
select * from orders
where payment_method = 'M-Pesa';


--SECTION B - AGGREGATION AND GROUPING

--Q11 Count all customers
select count(*) from customers;

--Q12 Count all orders
select count(*) from orders;

--Q13 Completed-order revenue
select round(sum (quantity * unit_price * (1-(discount/100.0))),2) as Revenue
from orders
where order_status = 'Completed';

--Q14 Average completed-order value.
select round(avg(quantity * unit_price * (1-(discount/100.0))),2) as Avg_order_value
from orders 
where order_status = 'Completed'; 

--Q15 Find the highest and lowest product prices.
select round(max(unit_price),2) as highest_price, round(min(unit_price),2) as lowest_price
from orders;

--Q16  Revenue by product category
select product_category, round(sum (quantity * unit_price * (1-(discount/100.0))),2)  as revenue
from orders
where order_status = 'Completed'
group by product_category
order by revenue desc;

--Q17 Count customers by city
select city, count(*) as num_of_customers
from customers
group by city
order by num_of_customers desc;

--Q18 Quantity sold by product
select product_name, product_category, sum(quantity) as units_sold 
from orders
where order_status = 'Completed'
group by product_category,product_name;

--Q19 Categories generating more than KSh 100,000 in revenue
select product_category, round(sum (quantity * unit_price * (1-(discount/100.0))),2)  as revenue
from orders
where order_status = 'Completed'
group by product_category
having round(sum (quantity * unit_price * (1-(discount/100.0))),2) > 100000
order by revenue desc;

--Q20 Percentage of cancelled orders
select (count(*) filter (where order_status = 'Cancelled')  * 100.0 / nullif(count(*), 0)) as percentage_cancelled_orders
from orders;

--SECTION C — JOINS AND CUSTOMER ANALYTICS

--Q21  Display orders with customer names and cities
select c.customer_name, c.city, o.*
from orders o 
left join customers c
on o.customer_id = c.customer_id;

--Q22 Total spending by customer
select c.customer_id, c.customer_name, round(sum (o.quantity * o.unit_price * (1-(o.discount/100.0))),2) as total_spent
from customers c
left join orders o
on c.customer_id = o.customer_id
and o.order_status = 'Completed'
group by c.customer_id, c.customer_name;


--Q23 Customers who have never ordered

select c.customer_id, c.customer_name
from customers c
left join orders o
on c.customer_id = o.customer_id
where o.order_id is null;

--Q24 10 highest-spending customers
select c.customer_id, c.customer_name,round(sum(o.quantity * o.unit_price * (1 - o.discount / 100.0)), 2) as total_spent
from customers c
inner join orders o
on c.customer_id = o.customer_id
where o.order_status = 'Completed'
group by c.customer_id, c.customer_name
order by total_spent desc
limit 10;

--Q25 Revenue by customer city
select c.city, round(sum (quantity * unit_price * (1-(discount/100.0))),2)  as city_revenue
from customers c
left join orders o 
on c.customer_id = o.customer_id
and o.order_status = 'Completed'
group by c.city 
order by city_revenue desc;

--Q26  Customers with more than five orders.
select c.customer_id, c.customer_name, count(o.order_id) as num_of_orders
from customers c
inner join orders o
on c.customer_id = o.customer_id
group by c.customer_id, c.customer_name
having count(o.order_id) >5
order by num_of_orders desc;

--Q27 Average customer spending by segment
select c.customer_segment, round(avg(quantity * unit_price * (1-(discount/100.0))),2) avg_spend
from customers c
left join orders o
on c.customer_id = o.customer_id 
and o.order_status = 'Completed'
group by c.customer_segment
order by avg_spend desc;

--Q28 Most popular category among VIP customers.
select * from orders;
select o.product_category, count(o.order_id) as num_of_orders
from orders o
inner join customers c
on o.customer_id = c.customer_id 
where c.customer_segment = 'VIP'
group by o.product_category
order by num_of_orders desc
limit 1;

--SECTION D — SUBQUERIES AND CTES 

--Q29 Customers spending above the average total spending per purchasing customer
with customer_spend as(
	select c.customer_id, c.customer_name, sum(o.quantity * o.unit_price * (1-(o.discount/100.0))) total_spend
	from customers c
	inner join orders o
	on c.customer_id = o.customer_id
	where o.order_status = 'Completed' 
	group by c.customer_id, c.customer_name
),
average_spending as(
	select avg(total_spend) as avg_spending
	from customer_spend
)
select cs.customer_id, cs.customer_name, cs.total_spend
from customer_spend cs
cross join average_spending av
where cs.total_spend > av.avg_spending
order by cs.total_spend desc;

--Q30  Products priced above the overall average unit price
select product_name, unit_price
from orders
where unit_price > (
    select avg(unit_price)
    from orders
)
group by product_name, unit_price
order by unit_price desc;

--Q31 CTE to identify the three highest-revenue months
with monthly_revenue as(
    select date_trunc('month', order_date) as revenue_month,
        sum(quantity * unit_price * (1 - discount / 100.0)) as total_revenue
    from orders
    where order_status = 'Completed'
    group by date_trunc('month', order_date)
),
rank_months as (
    select revenue_month, total_revenue,
        dense_rank() over (
            order by total_revenue desc
        ) as revenue_rank
    from monthly_revenue
)
select
    initcap(to_char(revenue_month, 'month yyyy')) as month,
    round(total_revenue, 2) as total_revenue
from rank_months
where revenue_rank <= 3
order by total_revenue desc;

--Q32 Customers purchasing from at least three categories
select c.customer_id, c.customer_name
from customers c
where c.customer_id in (
    select o.customer_id
    from orders o
    group by o.customer_id
    having count(distinct o.product_category) >= 3
);

--Q33 CTE to calculate category revenue, cost, profit, and profit margin.
with prod_calc as (
select o.product_category, round(sum(o.quantity * o.unit_price * (1-(o.discount/100.0))),2) as revenue, 
   round(sum(o.quantity * o.cost_price),2) as cost,
   round((sum(o.quantity * o.unit_price * (1-(o.discount/100.0))) - sum(o.quantity * o.cost_price)),2) as profit,
   round((sum(o.quantity * o.unit_price * (1-(o.discount/100.0))) - sum(o.quantity * o.cost_price)) * 100.0
   /nullif(sum(o.quantity * o.unit_price * (1-(o.discount/100.0))),0),2) as profit_margin
 from orders o
 where o.order_status = 'Completed'
 group by o.product_category
 )
 select product_category, revenue, cost, profit, profit_margin
 from prod_calc;

--Q34 Customers whose latest completed order is more than 90 days before the latest order date in the dataset.
with recent_order_date as(select c.customer_name, o.customer_id, max(o.order_date) as latest_date
from orders o
inner join customers c
on o.customer_id = c.customer_id
where o.order_status = 'Completed'
group by o.customer_id,c.customer_name
),
today_date as(
select max(order_date) as today 
from orders
)
select rd.customer_id,rd.customer_name, td.today - rd.latest_date as days_difference
from recent_order_date rd
cross join today_date td
where td.today - rd.latest_date > 90;

--SECTION E — WINDOW FUNCTIONS

--Q35 Rank customers by spending using RANK()
select c.customer_id, c.customer_name, round(sum(o.quantity * o.unit_price * (1-(o.discount/100.0))),2) as total_spend,
rank() over(order by round(sum(o.quantity * o.unit_price * (1-(o.discount/100.0))),2)) as spend_rank
from customers c
inner join orders o
on c.customer_id = o.customer_id
where o.order_status = 'Completed'
group by c.customer_id, c.customer_name;

--Q36 Number each customer's orders by recency using ROW_NUMBER()
select c.customer_id, c.customer_name,o.order_id, o.order_date, o.order_status,
row_number() over(
	partition by c.customer_id
	order by o.order_date desc
) as order_number
from customers c 
inner join orders o
on c.customer_id = o.customer_id
order by customer_id, order_number;

--Q37 Rank products within categories using DENSE_RANK()
select product_category, product_name, sum(quantity) as ordered_units,
dense_rank() over(
	partition by product_category 
	order by sum(quantity) desc
) as product_rank
from orders
group by product_category, product_name;

--Q38 Cumulative monthly revenue
with monthly_revenue as (
    select
        cast(date_trunc('month', order_date) as date)  as sales_month,
        sum(quantity * unit_price * (1 - discount / 100.0)) as total_revenue
    from orders
    where order_status = 'Completed'
    group by date_trunc('month', order_date)
)
select sales_month, round(total_revenue, 2) as monthly_revenue,
 round(
 	sum(total_revenue) over (
            order by sales_month
            rows between unbounded preceding and current row
        ), 2
    ) as cumulative_revenue
from monthly_revenue
order by sales_month;

--Q39 Compare monthly revenue using LAG()
select cast(date_trunc('month', order_date) as date) as sales_month, 
round(sum(quantity * unit_price * (1 - discount / 100.0)),2) as revenue,
lag(sum(quantity * unit_price * (1 - discount / 100.0))) over(
order by cast(date_trunc('month', order_date) as date) 
) as previous_revenue
from orders
where order_status = 'Completed'
group by sales_month;

--Q40 month-over-month revenue growth (%)
with monthly_revenue as (
select cast(date_trunc('month', order_date) as date) as sales_month, 
round(sum(quantity * unit_price * (1 - discount / 100.0)),2) as revenue,
lag(sum(quantity * unit_price * (1 - discount / 100.0))) over(
order by cast(date_trunc('month', order_date) as date) 
) as previous_revenue
from orders
where order_status = 'Completed'
group by sales_month
)
select sales_month,revenue, round(((revenue - previous_revenue) * 100.0 /revenue),2) as revenue_growth
from monthly_revenue;

--Q41 Divide customers into four spending groups using ntile()
select c.customer_id, c.customer_name, 
round(coalesce(sum(o.quantity * o.unit_price * (1 - o.discount / 100.0)),0),2) as amount_spent,
ntile (4) over(
 order by round(coalesce(sum(o.quantity * o.unit_price * (1 - o.discount / 100.0)),0),2) desc) as spend_group
from customers c
left join orders o 
on c.customer_id = o.customer_id
and order_status = 'Completed'
group by c.customer_id, c.customer_name;

--Q42 Each category's share of total revenue using window functions
select product_category, sum(quantity * unit_price * (1 - discount / 100.0)) as revenue,
round(
        sum(quantity * unit_price * (1 - discount / 100.0))
        * 100.0
        / sum(sum(quantity * unit_price * (1 - discount / 100.0))) over (),2)
 as revenue_share
from orders 
group by product_category
order by revenue;

--Q43 Create a monthly_sales_summary view (month, orders, revenue, cost, profit), then select from it
create view monthly_sales_summary as(
select cast(date_trunc('Month', order_date) as date) as sales_month,
count(order_id) as num_of_orders, 
sum(quantity * unit_price * (1 - discount / 100.0)) as revenue,
sum(quantity * cost_price * (1 - discount / 100.0)) as cost,
(sum(quantity * unit_price * (1 - discount / 100.0))) - (sum(quantity * cost_price * (1 - discount / 100.0))) as profit
from orders
where order_status = 'Completed'
group by sales_month
order by sales_month
);
select sales_month, num_of_orders, round(revenue,2) as revenue, round(cost,2) as cost, round(profit,2) as profit
from monthly_sales_summary;

--Q45  PL/pgSQL function that returns completed-order revenue for a supplied customer ID
create or replace function check_revenue(p_customer_id int)
returns numeric
language plpgsql
as $$
begin
    return(
	select round(coalesce(sum(quantity * unit_price * (1 - discount / 100.0)),0),2) as revenue
		from orders 
	where order_status = 'Completed'
	and customer_id = p_customer_id
	);
end;
$$;

select check_revenue(1);
select check_revenue(876);

--Q45 Segment customers into High, Medium and Low Value, and explain why you chose your thresholds.
with customer_spending as (
select c.customer_id,c.customer_name,
coalesce(sum(o.quantity * o.unit_price *(1 - o.discount / 100.0)), 0) as total_spent
from customers c
left join orders o
on c.customer_id = o.customer_id
and o.order_status = 'Completed'
group by c.customer_id, c.customer_name
)
select customer_id,customer_name, round(total_spent, 2) as total_spent,
	case
	    when total_spent >= 214973.075 then 'High Value'
	    when total_spent >= 76051.725 then 'Medium Value'
	    else 'Low Value'
	end as customer_group
from customer_spending
order by total_spent desc;

/* Reasons for Threshold
 * I considered the average and median customer spending to understand the distribution.
 * Average spending (KSh 161,035.81) and Median spending (KSh 76,051.73). The median provides a natural starting point for 
   separating lower-spending customers from the rest, while the 75th percentile identifies the higher-spending customers.
 * The average is considerably higher than the median, it suggests that some customers spend 
   substantially more than the typical customer.
 * Median (KSh 76,051.73), 50% of customers spend below this amount hence 'Low Value'
 * Average (KSh 161,035.81), 'Medium Value are between (KSh 76,051.73) and 75th percentile.
 * 75th percentile (KSh 214,973.075) is the High Value threshold. This is above the average spending
   allowing the High Value category to capture the top 25% of customers.
 */

--Q46 Management report: top five customers, top five products, the most profitable category, and the lowest-revenue month.
--Top 5 customers
with top_customers as(
select c.customer_id, c.customer_name, sum((o.quantity * o.unit_price *(1 - o.discount / 100.0))) as amount_spent
from customers c
inner join orders o
on c.customer_id = o.customer_id
where o.order_status = 'Completed'
group by c.customer_id, c.customer_name
),
ranked_customers as (
select *,dense_rank() over (
        order by amount_spent desc
        ) as spending_rank
from top_customers
)
select customer_id, customer_name, round(amount_spent, 2) as total_spent
from ranked_customers
where spending_rank <= 5;

--Top 5 products
with top_products as (
select product_name, sum(quantity) as units_sold,
sum(quantity * unit_price *(1 - discount / 100.0)) as total_revenue
from orders
where order_status = 'Completed'
group by product_name
),
ranked_products as (
select *,dense_rank() over (
        order by total_revenue desc) as product_rank
from top_products
)
select product_name, units_sold, round(total_revenue, 2) as total_revenue
from ranked_products
where product_rank <= 5;

--Top Category profit-wise
with category_profit as (
select product_category,sum(quantity * unit_price *(1 - discount / 100.0)) as total_revenue,
sum(quantity * cost_price) as total_cost,
(sum(quantity * unit_price * (1 - discount / 100.0)) - sum(quantity * cost_price)) as total_profit
from orders
where order_status = 'Completed'
group by product_category
),
ranked_categories as (
select *,
        dense_rank() over (
            order by total_profit desc
        ) as profit_rank
    from category_profit
)
select product_category, round(total_revenue, 2) as total_revenue, round(total_cost, 2) as total_cost,
round(total_profit, 2) as total_profit
from ranked_categories
where profit_rank = 1;

--Month with lowest revenue
with monthly_revenue as(
select date_trunc('month', order_date)::date as sales_month,
sum(quantity * unit_price * (1 - discount / 100.0)) as total_revenue
from orders
where order_status = 'Completed'
group by date_trunc('month', order_date)
),
ranked_months as (
select *,
        dense_rank() over (
            order by total_revenue asc
        ) as revenue_rank
from monthly_revenue
)
select sales_month, round(total_revenue, 2) as total_revenue
from ranked_months
where revenue_rank = 1
order by sales_month;








