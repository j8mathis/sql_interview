create table if not exists customers(
customer_id int primary key,
first_name text,
last_name text,
date_of_birth date,
phone text,
email text
);

create table if not exists address_history(
address_id int primary key,
customer_id int,
street_number text,
city text,
postal_code text,
state text,
start_date date,
end_date date
);

create table if not exists orders (
order_id int primary key,
customer_id int,
order_date date,
order_status text,
payment_method_id int,
comments text
);

create table if not exists order_details (
product_name text,
order_id int,
price numeric, 
quantity int,
comments text
);


