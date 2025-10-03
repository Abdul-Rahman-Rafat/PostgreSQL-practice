-- 1. Display the last name concatenated with the job id, separated by a 
-- comma and space and name the column [Employee and Title] as alias
select last_name||' , '||job_id as "Employee and Title" from hr.employees



-- 2. Display the last name and salary for all employees whose salary is not 
-- in the range of $1500 and $7000.
SELECT last_name, salary
FROM hr.employees
WHERE salary NOT BETWEEN 1500 AND 7000;



-- 3. Display the last name, salary and commission for all employees who 
-- earn commissions, Sort data in descending order of salary and 
-- commissions.
select last_name,salary,commission_pct
from hr.employees
-- where commission_pct !=0         X
where commission_pct IS NOT NULL
order by salary desc , commission_pct desc



-- 4. Display the last name, job id and salary for all employees whose job id
-- is SA_REP or PU_MAN and their salary is not equal to $9500, $9000
-- or $8000
select last_name,job_id,salary
from employees
where job_id in ('SA_REP','PU_MAN')



-- 5. Display all information about employees whose last name begin with 
-- letter 'S’ or letter ‘s’
select * from employees 
where last_name like 's%' or last_name like 'S%'--	iklie not case sensitive ,,  like case sensitive



-- 6. Display allemployees whose first name contains letter before last ‘e’ 
-- or ‘E’
select * from employees 
where first_name like '%e_' or first_name like '%E_' -- another way >>	where first_name ilike '%e_' 



-- # DDLs
-- 1. Create table with name of emps based on employees table ( with no 
-- data )- populate the emps table using a select statement from the 
-- employees table for the employees in department 20.
CREATE TABLE emps 
AS
SELECT *
FROM employees
WHERE 1=0;
INSERT INTO emps
SELECT *
FROM employees
WHERE department_id = 20;

--  Add column Gender to table emps. ( int ), default 0 ; add comment on 
-- column ( 0 stands for Male, 1 stands for Female )
ALTER TABLE hr.emps
ADD COLUMN gender INT DEFAULT 0;
COMMENT ON COLUMN hr.emps.gender 
IS '0  for Male, 1  for Female';


-- 2. Create the DEPTS table based on the following table instance chart. 
-- Create table with 2 columns
CREATE TABLE depts (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL , 
);
-- no need to PRIMARY KEY , NOT NULL as we used the table to copy valid data below here

--  Populate the DEPTS table with data from departments table. Include 
-- only columns that you need. ( insert using sub query )
insert into depts
 select department_id,department_name from hr.departments


-- 2. Create table employee_bkp based on the structure of the employees 
-- table(Structure with data).
--  Include only the employee_id, last_name, email, salary and 
-- department_id columns
create table employee_bkp as select employee_id, last_name, email, salary ,department_id from hr.employees


-- # DMLs

-- 1- Insert new location with suitable data
insert into hr.locations 
(location_id,street_address,postal_code,city,state_province,country_id)
values(3201 ,'new street' , 15021,'shobra','cairo','UK')

-- 2- Insert new department with suitable data for this location
insert into hr.departments
(department_id,department_name,manager_id,location_id)
values(271 ,'Finance' ,200 , 3201 )


-- 3- Insert new employee with suitable data for this department
insert into hr.employees
(employee_id,first_name,last_name,email,phone_number,hire_date,job_id,salary,commission_pct,manager_id,department_id)
values(300, 'Ali', 'Hassan', 'ALI.HASSAN', '01012345678', '2025-10-01', 'IT_PROG', 6000, NULL, 103, 271);


-- 4- Update your salary + 4000, update your job_id to have the same job_id 
UPDATE hr.employees
SET salary = salary + 4000,
    job_id = job_id
WHERE employee_id = 300;

-- for employee no. 107, updte your phone_number to null
UPDATE hr.employees
SET phone_number = null
where employee_id = 107; 


-- 5- Be sure to Delete the created location

delete from hr.employees
where employee_id = 300;

delete from hr.departments
where department_id =271;

delete from hr.locations
where location_id=3201;


