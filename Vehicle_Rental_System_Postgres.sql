/* Creates a Customer table */
create table customers(
	customer_id serial primary key,
	name varchar(100) Not null,
	contact varchar(50) unique not null
);
-- Creates a table vehicles
create table vehicles(
	vehicle_id serial primary key,
	vehicle_type varchar(50) not null check(vehicle_type in ('Car','Bike')),
	brand varchar(50) not null,
	model varchar(50) not null,
	year int not null check(year>=1900 and year<=(extract(year from CURRENT_DATE))),
	rental_rate decimal(10,2) not null check(rental_rate>=0)
);
-- creates a table cars which is extended from vehicle
CREATE TABLE cars (
    car_id SERIAL PRIMARY KEY REFERENCES vehicles(vehicle_id) ON DELETE CASCADE,
    num_persons INT NOT NULL CHECK (num_persons > 0),
    fuel_type VARCHAR(20) NOT NULL CHECK (fuel_type IN ('Petrol', 'Diesel', 'Electric'))
);

--creates a table bikes table which is extended from vehicles
CREATE TABLE bikes (
    bike_id SERIAL PRIMARY KEY REFERENCES vehicles(vehicle_id) ON DELETE CASCADE,
    bike_type VARCHAR(50) NOT NULL
);


--creates a table rentals to store the information about the rented vehicles
create table rentals(
	rental_id serial primary key,
	customer_id int not null references customers(customer_id) on delete cascade,
	vehicle_id int not null references vehicles(vehicle_id) on delete cascade,
	rental_days int not null check (rental_days>0),
	total_cost decimal(10,2) not null check(total_cost>=0),
	is_returned boolean default false
);

Insert into customers(name,contact) values ('Shami','9087456321');

Select * from customers;


/*Function to insert a conetents in both vehicle and their respective type's table  */

create or replace function insert_vehicle(
	v_type varchar,
	v_brand varchar,
	v_model varchar,
	v_year int,
	v_rental_rate decimal(10,2),
	v_num_persons int default null,
	v_fuel_type varchar default null,
	v_bike_type varchar default null
)returns void as $$
declare 
	new_vehicle_id int;
begin
	Insert into vehicles(vehicle_type,brand,model,year,rental_rate)
	values (v_type,v_brand,v_model,v_year,v_rental_rate)
	returning vehicle_id into new_vehicle_id;

	--insert into their respective types
	if v_type='Car' then
		insert into cars(car_id,num_persons,fuel_type)
		values(new_vehicle_id,v_num_persons,v_fuel_type);
	end if;

	if v_type='Bike' then
		insert into bikes(bike_id,bike_type)
		values(new_vehicle_id,v_bike_type);
	end if;
end;
$$language plpgsql;

-- Execute the function 
select insert_vehicle('Car', 'Toyota', 'Supra', 2020, 100, 4, 'Petrol',null);
select insert_vehicle('Bike', 'TVS', 'Jupyter 125', 2024, 75,null,null, 'Fuel-Based');
select insert_vehicle('Car', 'Ford', 'Figo', 2023, 200, 4, 'Diesel',null);
select insert_vehicle('Bike', 'Honda', 'CXR', 2000, 50,null,null, 'Fuel-Based');

Select * from vehicles;
Select * from cars;
Select * from bikes;

drop function calculate_totalRentalCost(int,int);

alter table rentals alter column total_cost set default 0;

--create a trigger to before insert
create or replace function calculate_rentalCost_trigger()
returns trigger as $$
declare 
	rental_cost decimal(10,2);
begin 
	select rental_rate into rental_cost 
	from vehicles where vehicle_id=new.vehicle_id;

	new.total_cost := rental_cost * new.rental_days;

	return new;
end;
$$ language plpgsql;

-- create rental cost trigger and attach with the rentals table
create trigger rental_cost_trigger
before insert on rentals
for each row 
execute function calculate_rentalCost_trigger();

--Rent a vehicle 

--manually add the cost
Insert into rentals(customer_id,vehicle_id,rental_days,total_cost)
values(1,3,4,400);

-- automatically calculates the cost and updates
Insert into rentals(customer_id,vehicle_id,rental_days)
values (1,4,2);

delete from rentals where rental_id=4;

select * from rentals;

--Return a Vehicle by rental id
update rentals 
set is_returned=false
where rental_id=1;

--Return a vehicle by customer id and vehicle_id
update rentals
set is_returned=true
where vehicle_id=4 and customer_id=1;

--Display the available vehicles 
Select * from vehicles where vehicle_id not in (select vehicle_id from rentals where is_returned=false);

--Display the renatl_vehicles
Select * from vehicles where vehicle_id  in (select vehicle_id from rentals where is_returned=false);

--Remove the vehicle
delete from vehicles where vehicle_id=5;


Select * from cars;

--Update the rental cost by their id
update vehicles 
set rental_rate=300
where vehicle_id=3;

select * from rentals;

--available vehicles
Select v.vehicle_id,v.vehicle_type,v.brand,v.model,v.year,v.rental_rate
from vehicles as v
left join rentals as r
on v.vehicle_id=r.vehicle_id and r.is_returned=false
where r.vehicle_id is null;

--rental vehicles
Select v.vehicle_id,v.vehicle_type,v.brand,v.model,v.year,v.rental_rate
from vehicles as v
inner join rentals as r
on v.vehicle_id=r.vehicle_id 
where r.is_returned=false;

--count the number of vehicles_type
select vehicle_type,count(*) from vehicles group by vehicle_type;

select brand,model from vehicles where rental_rate=(select max(rental_rate) from vehicles);


-- Display the rental vehicles and the customer who rented 
select distinct(c.name),c.contact,v.brand,v.model from customers c 
join rentals r on c.customer_id=r.customer_id
join vehicles v on v.vehicle_id=r.vehicle_id;

select * from customers;

