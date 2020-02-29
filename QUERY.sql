/*Query 1-Which store received most rental orders and its peak month */
select
DATE_PART('YEAR',rental_date) as rental_year,
DATE_PART('MONTH',rental_date) as rental_month,
i.store_id as store_ID,
count( rental_id)
from rental r
left join inventory i
on i.inventory_id=r.inventory_id
group by 1,2,3
order by 4 desc


/*Query 2-What category is rented most and which film is rented most? */
select
f.title,
TEMP2.name,
rental_count
from (select
i.film_id as fid,
count(r.rental_id) as rental_count
  from rental r
  left join inventory i
  on r.inventory_id=i.inventory_id
group BY fid) TEMP1

join film f
on TEMP1.fid=f.film_id

join
(select
c.name,
fc.film_id
from film_category fc
join category c
on c.category_id=fc.category_id) TEMP2
on TEMP2.film_id=TEMP1.fid
order by 3 desc,2 

 

/*Query 3-Which customer paid most and rented most often? How about monthly payment trend of this customer*/

WITH AGG as (select
date_trunc('month',payment_date) as pay_mon,
customer_id,
count(payment_id),
sum(amount)
from payment
group by 1,2
)

SELECT
pay_mon,
fullname,
Payment_count,
Payment_amount,
sum(Payment_amount) over (PARTITION BY fullname) as Payment_TTL
from (
Select
pay_mon,
c.first_name||' '||c.last_name as fullname,
AGG.COUNT as Payment_count,
AGG.SUM as Payment_amount
from AGG
left join
customer c
on AGG.customer_id=c.customer_id) As NEW
order by 5,4 desc

/*Query 4-Monthly payment difference among top 10 paying customers in 2007? */
WITH AGG as (select
date_trunc('month',payment_date) as pay_mon,
customer_id,
count(payment_id),
sum(amount)
from payment
group by 1,2
),
TOP as (
select
customer_id,
sum(amount) as Payment_Amount
from payment
where date_part('year',payment_date)=2007
group by 1
limit 10)

select
fullname,
pay_mon,
Payment_amount,
LAG(Payment_amount) over (PARTITION BY fullname order by pay_mon,Payment_amount desc) as month_lag,
Payment_amount-(LAG(Payment_amount) over (PARTITION BY fullname order by pay_mon,Payment_amount desc)) difference
from(
Select
pay_mon,
c.first_name||' '||c.last_name as fullname,
AGG.COUNT as Payment_count,
AGG.SUM as Payment_amount
from AGG
inner join TOP 
on TOP.customer_id=AGG.customer_id
left join
customer c
on AGG.customer_id=c.customer_id
 ) As NEW
 



