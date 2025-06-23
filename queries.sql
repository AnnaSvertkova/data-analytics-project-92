select count (customer_id ) as customers_count
from customers;


select 
CONCAT(employees.first_name,' ', employees.last_name) seller, -- имя и фамилия продовца
count (sales.sales_person_id) operations, --количество сделок 
floor(sum (sales.quantity * products.price)) income --суммарная выручка продавца за все время
from employees
join sales on employees.employee_id = sales.sales_person_id
join products on sales.product_id = products.product_id
group by seller
order by income desc
limit 10;


with tab as (
select 
floor(avg (sales.quantity * products.price)) average_all --средняя выручка за сделку по всем продавцам
from sales
join products on sales.product_id = products.product_id
)
select 
CONCAT(employees.first_name,' ', employees.last_name) seller, -- имя и фамилия продавца
floor(avg (sales.quantity * products.price)) average_income
from employees
join sales on employees.employee_id = sales.sales_person_id
join products on sales.product_id = products.product_id
group by seller
having  avg (sales.quantity * products.price) < (select average_all from tab)
order by average_income;


select 
CONCAT(employees.first_name,' ', employees.last_name) seller, -- имя и фамилия продfвца
to_char (sales.sale_date, 'day') day_of_week,
floor(sum(sales.quantity * products.price)) income --суммарная выручка продавца
from employees
join sales on employees.employee_id = sales.sales_person_id
join products on sales.product_id = products.product_id
group by to_char (sales.sale_date, 'D'), seller, day_of_week
order by to_char (sales.sale_date, 'D'), seller;


select
case 
when (age) between 16 and 25 then '16-25'
when (age) between 26 and 40 then '26-40'
when (age) >40 then '40+' end as age_category, --возрастные группы
count (customer_id) as age_count  --количество покупателей
from customers
group by age_category
order by age_category;


select 
to_char(sales.sale_date,'YYYY-MM') selling_month,
count (distinct sales.customer_id) total_customers,
floor (sum (products.price * sales.quantity)) income
from sales
inner join products on sales.product_id = products.product_id
group by selling_month
order by selling_month;


with tab as 
(select 
CONCAT(customers.first_name,' ', customers.last_name) customer, --имя и фамилия покупателя
sales.sale_date,
CONCAT(employees.first_name,' ', employees.last_name) seller -- имя и фамилия продавца
from sales
left join customers on sales.customer_id = customers.customer_id
left join employees on sales.sales_person_id = employees.employee_id
left join products on sales.product_id = products.product_id
where products.price = 0 --акционные товары отпускали со стоимостью равной 0
order by customers.customer_id),
tab2 as (
select 
customer, sale_date, seller, 
row_number() over (partition by customer order by sale_date) as rn
from tab)
select 
customer, sale_date, seller
from tab2
where rn = 1;
