-- 1.	Write a Query that get the date of the Third day in the next month
-- Print it in format   like 14-december-2020, Saturday
select TO_CHAR(DATE_TRUNC('month', NOW()) + INTERVAL '1 month' + INTERVAL '2 days' , 'DD-Month-YYYY, Day') AS third_day_next_month;



-- 2.	Write a Query that get the last day date of the current month from today
-- Print it in format   like 14-december-2020, Saturday
select TO_CHAR(DATE_TRUNC('month', NOW()) + INTERVAL '1 month' - INTERVAL '1 days' , 'DD-Month-YYYY, Day') AS Last_day_current_month;


-- 3.	Display the employee’s name, hire date and salary review date,  
-- The salary review date is the day after six months and Five days of service.Label the column Review.
-- Format the dates to appear in the format similar to “Sunday, the 7th of September, 1981 “.
select first_name,hire_date,salary ,  
TO_CHAR(hire_date + INTERVAL '6 month' + INTERVAL '5 days' , 'FMDay, the dth "of" FMMonth ,YYYY') AS salary_review_date
from hr.employees


-- 4.	Write a query that will display the difference between the highest and lowest salaries in each department.
select  department_id, max(salary),min(salary),max(salary)-min(salary) as "difference"
from hr.employees
GROUP by  department_id

--correlated way
SELECT DISTINCT 
    e.department_id,
    (SELECT MAX(salary) FROM hr.employees WHERE department_id = e.department_id) -
    (SELECT MIN(salary) FROM hr.employees WHERE department_id = e.department_id) AS difference
FROM 
    hr.employees e;


-- 5.	write a query that will display the city,
-- department name number of employees and the average salary for all employee in that department, 
--round the average salary to two decimal places. 
SELECT l.city,
       d.department_name,
       COUNT(e.employee_id) AS num_employees,
       ROUND(AVG(e.salary), 2) AS avg_salary
FROM hr.employees e
JOIN hr.departments d 
  ON e.department_id = d.department_id
JOIN hr.locations l 
  ON d.location_id = l.location_id
GROUP BY l.city, d.department_name;



-- 6.	Display the employee number, name and salary 
--for all employee who earn more than the average salary in his department
--correlated way
select e.employee_id, e.first_name, e.salary
from hr.employees e
where e.salary > (select AVG(e2.salary) from hr.employees e2 where e2.department_id = e.department_id);

-- 7.	Show Employees data Whose Salary is Higher Than Their Manager's
-- and show Manager name, salary ( use sub query not join )
SELECT e.employee_id,
       e.first_name AS employee_name,
       e.salary     AS employee_salary,
       (SELECT m.first_name
        FROM hr.employees m
        WHERE m.employee_id = e.manager_id) AS manager_name,
       (SELECT m.salary
        FROM hr.employees m
        WHERE m.employee_id = e.manager_id) AS manager_salary
FROM hr.employees e
WHERE e.salary > (
    SELECT m.salary
    FROM hr.employees m
    WHERE m.employee_id = e.manager_id
);



-- 8.	Show Employees data Who Earn the Lowest Salary in Their Department ( use subquery not join )
select e.employee_id, e.first_name, e.salary
from hr.employees e
where e.salary = (select min(e2.salary) from hr.employees e2 where e2.department_id = e.department_id);

-- 9.	Find employees who have been hired earlier than anyone else in the same job ( use subquery not join )
select e.employee_id, e.first_name, e.salary , e.hire_date
from hr.employees e
where e.hire_date = (select min(e2.hire_date) from hr.employees e2 where e2.job_id = e.job_id);

-- 10.	Write a query to display employee_id, last_name, salary, dept id, dept name, job Id, job title, city, street address, country id, country name, region id, region name for all employees including those employees whose have no department too.
SELECT e.employee_id,
e.last_name,e.salary,e.department_id,e.job_id,

d.department_name,

j.job_title,

l.city,l.street_address,

c.country_id,c.country_name,
r.region_id,r.region_name

FROM hr.employees e 

LEFT JOIN hr.departments d ON e.department_id = d.department_id
LEFT JOIN hr.jobs j ON e.job_id = j.job_id
LEFT JOIN hr.locations l ON d.location_id = l.location_id
LEFT JOIN hr.countries c ON l.country_id = c.country_id
LEFT JOIN hr.regions r ON c.region_id = r.region_id;
