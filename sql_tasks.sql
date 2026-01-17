--А

drop table if exists employee;
create table employee
(
id smallint,
emp_name varchar(255),
rating int
);

insert into employee values (1,'Andrei',5);
insert into employee values (2,'Andrei',3);
insert into employee values (3,'Kolya',9);
insert into employee values (4,'Vova',4);
insert into employee values (5,'Misha',2);

drop table if exists tasks;
create table tasks
(
id smallint,
assignee_id smallint,
rating smallint
);

insert into tasks values (1,1,5);
insert into tasks values (2,1,4);
insert into tasks values (3,2,2);
insert into tasks values (4,5,5);
insert into tasks values (5,5,1);
insert into tasks values (6,5,7);
insert into tasks values (7,5,9);
insert into tasks values (8,5,3);
insert into tasks values (9,5,3);
insert into tasks values (10,5,5);
insert into tasks values (11,2,7);
insert into tasks values (12,3,8);
insert into tasks values (13,3,8);
insert into tasks values (14,2,7);
insert into tasks values (15,3,9);
insert into tasks values (16,5,4);
insert into tasks values (17,1,5);

SELECT 
	e.emp_name,
	COUNT (t.id) as task_count
FROM employee as e
LEFT JOIN tasks as t ON t.assignee_id = e.id
GROUP BY  e.emp_name, e.id
HAVING COUNT (t.id)<3
ORDER BY task_count ASC, e.emp_name;

--Б

CREATE OR REPLACE VIEW vw_orders_analytics AS
SELECT
    o.order_id,
    o.order_date_dt,
    o.partner,
    o.sku,
    o.revenue,
    o.weight,
    p.p_business_region,
    p.p_manager,
    br.business_region,
    br.region,
    br.country,
    br.direction
FROM orders AS o
LEFT JOIN partners AS p
    ON o.partner = p.partner
LEFT JOIN business_regions AS br
    ON p.p_business_region = br.business_region;

--В

BEGIN TRANSACTION;
UPDATE ps2
SET 
    ps2.valid_to_dt = DATEADD(day, -1, CAST(GETDATE() AS DATE))  
FROM 
    partners_scd2 ps2
INNER JOIN 
    partners p ON ps2.partner = p.partner
WHERE 
    ps2.valid_to_dt = '9999-12-31'        
    AND ps2.p_manager <> p.p_manager;     

INSERT INTO partners_scd2 (partner, p_manager, valid_from_dt, valid_to_dt)
SELECT 
    p.partner,
    p.p_manager,
    CAST(GETDATE() AS DATE) as valid_from_dt,  
    '9999-12-31' as valid_to_dt                
FROM 
    partners p
WHERE 
    EXISTS (
        SELECT 1 
        FROM partners_scd2 ps2 
        WHERE ps2.partner = p.partner 
        AND ps2.valid_to_dt = DATEADD(day, -1, CAST(GETDATE() AS DATE))
        AND ps2.p_manager <> p.p_manager
    )
    OR 
    NOT EXISTS (
        SELECT 1 
        FROM partners_scd2 ps2 
        WHERE ps2.partner = p.partner 
        AND ps2.valid_to_dt = '9999-12-31'
    );

COMMIT TRANSACTION;