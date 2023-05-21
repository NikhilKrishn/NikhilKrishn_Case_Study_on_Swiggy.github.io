use [SWIGGY]
go

CREATE TABLE "USERS"
(
c_id int not null,
"Name" varchar(40) not null,
Email varchar(50) ,
"password" varchar(20)
)
exec sp_rename 'user.Customer_id','user_id','column'
exec sp_rename 'user.user_id','passwords','column'
insert into "user"
Values (1,	'Nitish',	'nitish@gmail.com',	'p252h'),
		(2,	'Khushboo',	'khushboo@gmail.com',	'hxn9b'),
		(3,	'Vartika',	'vartika@gmail.com',	'9hu7j'),
		(4,	'Ankit',	'ankit@gmail.com', 'lkko3'),
		(5,	'Neha',	'neha@gmail.com',	'3i7qm'),
		(6,	'Anupama',	'anupama@gmail.com',	'46rdw2'),
		(7,	'Rishabh',	'rishabh@gmail.com',	'4sw123')

select * from "user"
go

CREATE TABLE "Restaurants"
(
r_id int not null,
"r_name" varchar(40) not null,
cuisine varchar(50) not null
)
exec sp_rename 'restaurants.r_id','restaurant_id','column'
exec sp_rename 'restaurants.r_name','restaurant_name','column'

insert into Restaurants
values
(1,	'dominos',	'Italian'),
(2,	'kfc',	'American'),
(3, 'box8',	'North Indian'),
(4,	'Dosa Plaza',	'South Indian'),
(5,	'China Town', 'Chinese')

select * from Restaurants
go

CREATE TABLE "food"
(
food_id int not null,
"food_name" varchar(60) not null,
"type" varchar(40) not null
)



select * from food
go

Create table menu
(
menu_id int not null,
restaurant_id int not null,
food_id int not null,
price int not null
)

select * from menu
go


create table orders
(
order_id int not null,
"user_id" int not null,
"restaurant_id" int not null,
"amount" int not null,
"order_date" date not null,
partner_id int not null,
delivery_time int not null,
delivery_rating int not null,
restaurant_rating int 
)

select * from orders
go


create table delivery_partner
(
partner_id int not null,
partner_name varchar(50) not null
)

select * from delivery_partner
go


create table order_details
(
id int not null,
order_id int not null,
food_id int not null
)

select * from order_details
go

--------------SWIGGY CASE STUDY---------------
--Q1. Find customers who have never ordered ?

select * from "USERS"
select * from "orders"

select "name" from "USERS"
where
"user_id" not in(select "user_id" from orders)

go

--Q2. Average price of each dish?

select * from menu
select * from food

select food.[food_name], avg(price) as avg_price 
from menu 
join food on menu.food_id = food.[food_id]
group by food.food_name
order by avg_price desc

go

--Q3. Find top restaurant in terms of number of orders in JUNE, JULY, MAY month?

select * from orders

--Here we observe that there are only three months (dates) in which orders have taken place.

select top(1)
Restaurants.restaurant_name, count(*) as No_of_Order 
from orders 
join Restaurants
on Restaurants.restaurant_id = orders.restaurant_id
where DATENAME(month,order_date) like 'june'
group by Restaurants.restaurant_name
order by count(*) desc

go

select top(1)
Restaurants.restaurant_name, count(*) as No_of_Order 
from orders 
join Restaurants
on Restaurants.restaurant_id = orders.restaurant_id
where DATENAME(month,order_date) like 'july'
group by Restaurants.restaurant_name
order by count(*) desc
go

select top(1)
Restaurants.restaurant_name, count(*) as No_of_Order 
from orders 
join Restaurants
on Restaurants.restaurant_id = orders.restaurant_id
where DATENAME(month,order_date) like 'may'
group by Restaurants.restaurant_name
order by count(*) desc
GO

--Q4. Name the Restaurants with monthly sales > its avg monthly revenue in the month of june?

select restaurants.restaurant_name,orders.restaurant_id, sum(amount) as 'monthly_revenue'
from orders
join Restaurants
on orders.restaurant_id = Restaurants.restaurant_id
where datename(month,order_date) like 'june'
group by orders.restaurant_id, Restaurants.restaurant_name
having sum(amount) > avg(amount)
order by monthly_revenue desc

/*select restaurant_id, avg(amount) as 'avg_monthly_revenue'
from orders
where datename(month,order_date) like 'june'
group by restaurant_id
*/

go

--Q5. Show all orders with order details for a particular customer in a particular date range:
		/*		----CUSTOMER DETAILS----
		NAME - ANKIT
		USER_ID = 4
		ORDER_DATE = 2022-06-10 TO 2022-07-10   */
												
select orders.order_id,Restaurants.restaurant_name, order_details.food_id, food.food_name
from orders 
join Restaurants
on orders.restaurant_id = Restaurants.restaurant_id
join order_details
on orders.order_id = order_details.order_id
join food
on order_details.food_id = food.food_id
where user_id = (select user_id from [dbo].[USERS] where user_id = 4)
and (order_date > '2022-06-10' and order_date < '2022-07-10')

GO

--Q6. Find restaurants with max repeated customers?
select * from orders

select top(1)
tbl1.restaurant_id, restaurants.restaurant_name, count(*) as 'loyal customer' 
from
	(select restaurant_id,"user_id", count(*) as 'visits'
	from orders
	group by restaurant_id, "user_id"
	having count(*) > 1) as tbl1
join Restaurants
on Restaurants.restaurant_id = tbl1.restaurant_id
group by tbl1.restaurant_id, Restaurants.restaurant_name
order by [loyal customer] desc

go


--Q7 customer -> favorite food

select orders.user_id,users.Name,order_details.food_id,food.food_name, count(*) as frequency from orders
join order_details
on orders.order_id = order_details.order_id
join users
on users.user_id = orders.user_id
join food
on food.food_id = order_details.food_id
group by orders.user_id,order_details.food_id, users.Name, food.food_name
order by frequency desc