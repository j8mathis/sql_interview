--~~~~~~~~~~~~~
--a Entry: Get the first order date and the last order date
--~~~~~~~~~~~~~~~
select 
    min(order_date) as first_order, 
    max(order_date) as last_order
from 
    orders
-- ┌─────────────┬────────────┐
-- │ first_order │ last_order │
-- ├─────────────┼────────────┤
-- │ 2013-02-14  │ 2017-02-13 │
-- └─────────────┴────────────┘
-- 
--~~~~~~~~~~~~~~~~~~~~~~~~~~
--b Entry: Get all the orders for each payment method (pay_method_id) for all of 2015
--~~~~~~~~~~~~~~~~~~~~~~~~~
Select
    payment_method_id,
    count(order_id)
from 
    orders 
where 
    order_date >= '20150101'::date
    and order_date < '20161231'::date
group by 
    payment_method_id
order by --not necessary just for display 
    payment_method_id
-- ┌───────────────────┬───────┐
-- │ payment_method_id │ count │
-- ├───────────────────┼───────┤
-- │                 1 │    15 │
-- │                 2 │    11 │
-- │                 3 │    11 │
-- │                 4 │     7 │
-- └───────────────────┴───────┘
--~~~~~~~~~~~~~~~~~~~~~~~
--c Intermediate: Create a report comparing 2016’s numbers to the numbers returned from 5b above.  
--~~~~~~~~~~~~~~~~~~~~~~~
with tmp_2015 as(
--2015 values
Select
    payment_method_id,
    count(order_id) as count_2015
from 
    orders 
where 
    order_date >= '20150101'::date
    and order_date < '20161231'::date
group by 
    payment_method_id
),

tmp_2016 as (
--2016 values
Select
    payment_method_id,
    count(order_id) as count_2016
from 
    orders 
where 
    order_date >= '20160101'::date
    and order_date < '20171231'::date
group by 
    payment_method_id
)

--join and compare them 
select
    t1.payment_method_id,
    count_2015,
    count_2016
from
    tmp_2015 t1
inner join 
    tmp_2016 t2 on t1.payment_method_id = t2.payment_method_id
-- ┌───────────────────┬────────────┬────────────┐
-- │ payment_method_id │ count_2015 │ count_2016 │
-- ├───────────────────┼────────────┼────────────┤
-- │                 1 │         15 │          8 │
-- │                 2 │         11 │          9 │
-- │                 3 │         11 │          5 │
-- │                 4 │          7 │          2 │
-- └───────────────────┴────────────┴────────────┘
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~
--d Intermediate: Get customers without orders in the past year.
--~~~~~~~~~~~~~~~~~~~~~~~~
with tmp_orders as (
--pull all orders from last year 
select 
    customer_id,
    order_id
from 
    orders 
where 
    order_date >= date_trunc('year', (current_date - interval '1 year'))
    and order_date < date_trunc('year', current_date) 
)

--use left join to find all customers without orders 
Select  
    c.*
from 
    customers c
left join 
    tmp_orders o on o.customer_id = c.customer_id
where 
    o.order_id is null
-- ┌─────────────┬────────────┬────────────┬───────────────┬──────────────┬──────────────────────────────────┐
-- │ customer_id │ first_name │ last_name  │ date_of_birth │    phone     │              email               │
-- ├─────────────┼────────────┼────────────┼───────────────┼──────────────┼──────────────────────────────────┤
-- │           1 │ James      │ Butt       │ 1978-12-08    │ 504-621-8927 │ jbutt@gmail.com                  │
-- │           2 │ Josephine  │ Darakjy    │ 1978-12-09    │ 810-292-9388 │ josephine_darakjy@darakjy.org    │
-- │           4 │ Lenna      │ Paprocki   │ 1982-04-11    │ 907-385-4412 │ lpaprocki@hotmail.com            │
-- │           5 │ Donette    │ Foller     │ 1978-02-12    │ 513-570-1893 │ donette.foller@cox.net           │
-- │           6 │ Simona     │ Morasca    │ 1978-06-13    │ 419-503-2484 │ simona@morasca.com               │
-- │           7 │ Mitsue     │ Tollner    │ 2064-03-14    │ 773-573-6914 │ mitsue_tollner@yahoo.com         │
-- │           8 │ Leota      │ Dilliard   │ 2056-09-15    │ 408-752-3500 │ leota@hotmail.com                │
-- │          10 │ Kris       │ Marrier    │ 2055-09-17    │ 410-655-8723 │ kris@gmail.com                   │
-- │          13 │ Kiley      │ Caldarera  │ 1978-08-20    │ 310-498-5651 │ kiley.caldarera@aol.com          │
-- ...
-- │          97 │ Malinda    │ Hochard    │ 1979-03-14    │ 317-722-5066 │ malinda.hochard@yahoo.com        │
-- │          98 │ Natalie    │ Fern       │ 1979-03-15    │ 307-704-8713 │ natalie.fern@hotmail.com         │
-- │          99 │ Lisha      │ Centini    │ 1979-03-16    │ 703-235-3937 │ lisha@centini.org                │
-- └─────────────┴────────────┴────────────┴───────────────┴──────────────┴──────────────────────────────────┘
-- (80 rows)
--~~~~~~~~~~~~~~~~~~~~~~~~
--e Intermediate: What is the customer’s current address?
--~~~~~~~~~~~~~~~~~~~~~~~~
Select 
    c.customer_id,
    a.city,
    a.state,
    a.start_date,
    a.end_date 
from 
    customers c
inner join 
    address_history a on a.customer_id = c.customer_id
where 
    end_date is null --if end_date is null it is the current address. 
-- ┌─────────────┬───────────────────┬───────┬────────────┬──────────┐
-- │ customer_id │       city        │ state │ start_date │ end_date │
-- ├─────────────┼───────────────────┼───────┼────────────┼──────────┤
-- │           1 │ New Orleans       │ LA    │ 2015-11-06 │ [null]   │
-- │           2 │ Brighton          │ MI    │ 2010-05-08 │ [null]   │
-- │           3 │ Bridgeport        │ NJ    │ 2010-05-20 │ [null]   │
-- │           4 │ Anchorage         │ AK    │ 2016-10-30 │ [null]   │
-- │           5 │ Hamilton          │ OH    │ 2010-06-29 │ [null]   │
-- ...
-- │          96 │ San Leandro       │ CA    │ 2017-01-18 │ [null]   │
-- │          97 │ Indianapolis      │ IN    │ 2016-05-01 │ [null]   │
-- │          98 │ Rock Springs      │ WY    │ 2010-06-12 │ [null]   │
-- │          99 │ Mc Lean           │ VA    │ 2010-08-03 │ [null]   │
-- └─────────────┴───────────────────┴───────┴────────────┴──────────┘
-- (99 rows)
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~
--f Advanced: How much products shipped to ohio last year?
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~
select
    sum(od.quantity) count_products_oh --sum up all quantities 
from 
    orders o
inner join 
    address_history a on a.customer_id = o.customer_id
inner join 
    order_details od on od.order_id = o.order_id --order_details contains the products and counts of each 
where 
    o.order_date >= date_trunc('year', (current_date - interval '1 year')) --find orders from last year 
    and o.order_date < date_trunc('year', current_date) --find orders from last year
    and a.state = 'OH' --find orders from ohio 
    and o.order_date >= a.start_date --find orders greater than or equal to address start
    and o.order_date <= coalesce(a.end_date, current_date) --find orders less than or equal to the end date or if null use current_date, they are still living there 
-- ┌───────────────────┐
-- │ count_products_oh │
-- ├───────────────────┤
-- │                12 │
-- └───────────────────┘