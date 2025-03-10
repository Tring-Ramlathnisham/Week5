Select current_database();
/*1. Create a departments table */
create table Departments(
	dept_id serial Primary key,
	dept_name varchar(255) unique not null
);

/*2. Create an employees table */

create table Employees (
	emp_id serial primary key,
	emp_name varchar(255) not null,
	email varchar(255) unique,
	salary numeric(10,2) not null check(salary > 0),
	 dept_id INT references departments(dept_id) On DELETE SET NULL
);

/* 3. Create a projects table */
create table projects(
	project_id serial primary key,
	project_name varchar(255) not null,
	dept_id int references departments(dept_id) on delete set null
);

/* 4.Inserting records to departments */

Insert into Departments(dept_name) values
('HR'),
('IT'),
('Finance'),
('Marketing'),
('Operations');

select * from departments;

/* 4. Inserting records to Employees */

Insert into Employees(emp_name,email,salary,dept_id) values
('Alice Johnson','alice@gmail.com',55000,1),
('Bob Smith','bob@gamil.com',62000,2),
('Charlie Brown','charlie@gamil.com',70000,3),
('David Wilson','david@gamil.com',48000,1),
('Emma Watson','emma@gmail.com',75000,2),
('Frank Thomas','frank@gmail.com',50000,4),
('Grace Lee','grace@gmail.com',53000,5),
('Hannah Adams','hannah@gmail.com',59000,3),
('Ian Wright','ian@gmail.com',67000,2),
('Jackie Chan','jackie@gmail.com',72000,4);

Select * from Employees;

/*4. Inserting records to Projects table */

Insert into Projects (project_name,dept_id) values
('Recruitment Drive',1),
('IT System Update',2),
('Annual Budget Planning',3),
('Marketing Campaign 2025',4),
('Supply Chain Management',5);

Select * from Projects;


/*Joins */

/* 5. Inner Join : 
List all employees along with their department names.
*/

Select e.emp_name, d.dept_name from Employees as e 
inner join Departments as d on e.dept_id=d.dept_id; 

/*6. Left join
Show all departments and employees, including departments with no
employees.
*/

Select d.dept_id,d.dept_name,e.emp_id,e.emp_name,e.email,e.salary 
from Departments as d
left join Employees as e 
on e.dept_id=d.dept_id
order by d.dept_id;


Insert into Employees (emp_name,email,salary) values
('Zoe Carter','zoe@gmail.com',60000);

/*7. right join 
Show all employees and their respective departments, including
employees without a department.
*/

Select e.emp_id,e.emp_name,e.email,e.salary,d.dept_id,d.dept_name 
from departments d
right join employees e on e.dept_id=d.dept_id
order by e.emp_id;

Insert into Departments (dept_name) values
('Research');

/*8. Full outer join
List all departments and employees, even if there’s no match
between them.
*/
SELECT e.emp_id, e.emp_name, e.email, e.salary, d.dept_id, d.dept_name
FROM employees e
FULL OUTER JOIN departments d ON e.dept_id = d.dept_id
ORDER BY d.dept_id, e.emp_id;

/* 9. Join with multiple tables
List all employees along with their department name and the
projects assigned to that department.
*/

Select e.emp_name,e.email,e.salary,d.dept_name,p.project_name from Employees e 
join Departments d on e.dept_id=d.dept_id
join Projects p on e.dept_id = p.project_id;

//Aggregate Function

/* 10. Count the total number of employees in each department.*/

Select d.dept_name,count(e.emp_id) as count from Employees e 
right join  Departments d on e.dept_id=d.dept_id
group by d.dept_name order by count desc;

/* 11. Find the total salary paid in each department.*/
Select d.dept_name , sum(e.salary) as total_salary 
from Employees e
join Departments d on e.dept_id = d.dept_id 
group by d.dept_name order by total_salary desc;

/* 12. Calculate the average salary for each department.*/
Select d.dept_name , round(Avg(e.salary),2) as avg_salary 
from Employees e
join Departments d on e.dept_id = d.dept_id 
group by d.dept_name order by avg_salary desc;

/* 13. Find the minimum and maximum salary in the company.*/
Select min(salary) as minimum_salary,max(salary) as maximum_salary from Employees;

/* 14. List the total number of projects each department is handling. */
Select p.dept_id,count(p.project_id) as Total_Assigned_Tasks from Projects p
join Departments d on p.dept_id=d.dept_id 
group by p.dept_id;

/*15. Show the average salary per department, but only for departments where the average
salary is greater than 50,000.
*/
Select d.dept_name,round(avg(e.salary),2) as average
from Employees e 
join Departments d on e.dept_id= d.dept_id
group by d.dept_name
having avg(e.salary) > 50000;

/*
16. Find departments with more than 3 employees.
*/

Select d.dept_name from Departments d 
join Employees e on d.dept_id = e.dept_id
group by dept_name having count(e.emp_id)>3;

/*
17. List projects assigned to departments that have at least 2 projects.
*/

SELECT p.project_id, p.project_name, d.dept_id, d.dept_name
FROM projects p
JOIN departments d ON p.dept_id = d.dept_id
WHERE p.dept_id IN (
    SELECT dept_id
    FROM projects
    GROUP BY dept_id
    HAVING COUNT(project_id) >= 2
)
ORDER BY d.dept_id, p.project_id;

/* 18. Create a function to calculate bonuses */

create function calculate_bonus(salary Numeric)
returns Numeric as $$
begin 
	return salary*0.10;
end;
$$LANGUAGE plpgsql;
	

select emp_id,emp_name,salary,calculate_bonus(salary) as bonus
from Employees;


SELECT * FROM pg_language;
CREATE EXTENSION IF NOT EXISTS plpgsql;

/* 19. Create a function to count employees in a department */
create function count_employees(dep_id numeric)
returns int as $$
declare 
emp_count INT;
begin 
	Select count(emp_id) into emp_count
	from Employees
	where dept_id=dep_id;

	return emp_count;
end;
$$LANGUAGE plpgsql;

drop function count_employees(numeric);
SELECT count_employees(1) AS total_employees_in_dept1;

Select dept_name,count_employees(dept_id) from Departments;


/*20. Create a function to check high salaries */

create function Check_salary(salary int)
return Varchar(255) as $$
declare res varchar(255)
begin 
   case when salary>80000 then "High Salary" into res
   case when salary>50000 and salary<80000 then "Medium Salary" into res
   else "Low Salary" into res;
end;
$$LANGUAGE plpgsql;

   