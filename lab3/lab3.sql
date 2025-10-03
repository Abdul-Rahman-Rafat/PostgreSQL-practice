set search_path = hr;

-- 1.	Create pgsql block and to check for all employees using cursor; and update their commission_pct based on the salary
-- SALARY < 7000  :                    COMM = 0.1
-- 7000 <= SALARY < 10000      COMM = 0.15
-- 10000 <= SALARY < 15000    COMM = 0.2
-- 15000 <= SALARY  	                COMM = 0.25
DO $$
DECLARE
    emp_cursor CURSOR FOR
        SELECT * FROM employees;
BEGIN
    FOR v_emp_record IN emp_cursor
    LOOP
        
        IF v_emp_record.salary < 7000 THEN
            UPDATE employees
            SET commission_pct = 0.10
            WHERE employee_id = v_emp_record.employee_id;

        ELSIF v_emp_record.salary >= 7000 AND v_emp_record.salary < 10000 THEN
            UPDATE employees
            SET commission_pct = 0.15
            WHERE employee_id = v_emp_record.employee_id;

        ELSIF v_emp_record.salary >= 10000 AND v_emp_record.salary < 15000 THEN
            UPDATE employees
            SET commission_pct = 0.20
            WHERE employee_id = v_emp_record.employee_id;

        ELSE -- salary >= 15000
            UPDATE employees
            SET commission_pct = 0.25
            WHERE employee_id = v_emp_record.employee_id;
        END IF;
    END LOOP;
END;
$$;



-- 2.	Alter table employees then add column retired_bonus
-- Create pgsql block to calculate the retired salary for all employees using cursor and update retired_bonus column
-- Retired bonus = no of working months * 10 % of his current salary
-- Only for those employees have passed 18 years of their hired date

Alter table employees
add column retired_bonus  NUMERIC ;


DO $$
DECLARE
	v_years INT;
	v_months INT;
	v_total_months INT;
    emp_cursor CURSOR FOR
        SELECT * FROM employees;
BEGIN
	
    FOR v_emp_record IN emp_cursor
    LOOP
		v_years := EXTRACT('year' FROM AGE(NOW(), v_emp_record.hire_date));
		v_months := EXTRACT('month' FROM AGE(NOW(), v_emp_record.hire_date));
		v_total_months := (v_years * 12) + v_months;

        IF v_years > 18 THEN
            UPDATE employees
            SET  retired_bonus = v_total_months * (0.1 *salary)
            WHERE employee_id = v_emp_record.employee_id;
			raise notice 'v years = %,v months = % , v_total_months =%', v_years,v_months ,v_total_months ;

 
        END IF;
    END LOOP;
END;
$$;





-- 3.	Create pgsql block that loop over employees table and 
-- Increase only those working in ‘IT’ department by 10% of their salary. 

DO $$
DECLARE
    emp_cursor CURSOR FOR
        SELECT e.employee_id, e.salary
        FROM employees e
        JOIN departments d ON e.department_id = d.department_id
        WHERE d.department_name = 'IT';
BEGIN
    FOR v_emp_record IN emp_cursor
    LOOP
        UPDATE employees
        SET salary = salary * 1.10
        WHERE employee_id = v_emp_record.employee_id;

        RAISE NOTICE 'Increased salary for Emp ID = %', v_emp_record.employee_id;
    END LOOP;
END;
$$;



-- 4.	Create a PG/SQL block to award a 500 bonus to all employees who have been working for more than 15 years and have no commission.
DO $$
DECLARE
    v_years INT;
    emp_cursor CURSOR FOR
        SELECT * FROM employees;
BEGIN
    FOR v_emp_record IN emp_cursor
    LOOP
        v_years := EXTRACT(YEAR FROM AGE(NOW(), v_emp_record.hire_date));

        IF v_years > 15 AND v_emp_record.commission_pct IS NULL THEN
            UPDATE employees
            SET salary = salary + 500
            WHERE employee_id = v_emp_record.employee_id;
			
	        RAISE NOTICE 'Bonus added: Emp ID = %, Years = %, New Salary = %',
	                     v_emp_record.employee_id, v_years, v_emp_record.salary;
        END IF;
    END LOOP;
END;
$$;


-- 5.	Create a PG/SQL block to give a 5% bonus to all employees in the ‘Sales’ department who have a salary greater than 8000.
DO $$
DECLARE
    emp_record employees%ROWTYPE;
    emp_cursor CURSOR FOR
        SELECT e.*
        FROM employees e
        JOIN departments d ON e.department_id = d.department_id
        WHERE d.department_name = 'Sales'
          AND e.salary > 8000;
BEGIN
    FOR emp_record IN emp_cursor
    LOOP
        UPDATE employees
        SET salary = salary * 1.05   
        WHERE employee_id = emp_record.employee_id;

        RAISE NOTICE 'Employee % got 5%% bonus. New Salary = %',
                     emp_record.employee_id, emp_record.salary * 1.05;
    END LOOP;
END;
$$;

-- 6.	
--a- add RETIRED INT  column to employees table using alter

Alter table employees
add column retired  INT ;

-- b- Create and call
-- CHECK_RETIRED FUNCTION(V_EMP_ID INT, V_MAX_HIRE_YEAR INT) RETURN INT;
-- that will return 1 if employee has passed no of years >=  V_MAX_HIRE_YEAR, return 0 for otherwise
CREATE OR REPLACE FUNCTION check_retired(v_emp_id INT, v_max_hire_year INT)
RETURNS INT AS $$
DECLARE
    v_hire_date DATE;
    v_years     INT;
BEGIN
    SELECT hire_date
    INTO v_hire_date
    FROM employees
    WHERE employee_id = v_emp_id;

    v_years := EXTRACT(YEAR FROM AGE(NOW(), v_hire_date));

    IF v_years >= v_max_hire_year THEN
        RETURN 1;
    ELSE
        RETURN 0;
    END IF;
END;
$$ LANGUAGE plpgsql;
SELECT check_retired(101, 18);
SELECT check_retired(101, 50);

-- c- create block to call and update the emp with set retired = 1  if this employee will retired
DO $$
DECLARE
    v_emp_record employees%ROWTYPE;
    emp_cursor CURSOR FOR SELECT * FROM employees;
BEGIN
    FOR v_emp_record IN emp_cursor
    LOOP
        IF check_retired(v_emp_record.employee_id, 30) = 1 THEN
            UPDATE employees
            SET retired = 1
            WHERE employee_id = v_emp_record.employee_id;

            RAISE NOTICE 'Employee id % , name % has retired', v_emp_record.employee_id,v_emp_record.first_name;
        END IF;
    END LOOP;
END;
$$;