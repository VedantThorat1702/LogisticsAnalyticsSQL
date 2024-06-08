create database Logistic_Company;
use Logistic_Company;
show tables;

select *from customer;
select *from employee_details;
select *from employee_manages_shipment;
select *from membership;
select *from payment_details;
select *from shipment_details;
select *from status;

describe customer;
describe employee_details;
describe employee_manages_shipment;
describe membership;
describe payment_details;
describe shipment_details;
describe status;


# Data analysis
# Calculate total payments made by each customer.

SELECT 
    c.cust_id AS Customer_ID,
    c.cust_name AS Customer_Name,
    SUM(p.amount) AS Amount
FROM
    customer AS c
        JOIN
    payment_details AS p ON c.cust_id = p.customer_cust_id
GROUP BY p.customer_cust_id;

# Get the current status of a shipment. 

SELECT 
    CURRENT_Status, SENT_DATE, DELIVERY_DATE
FROM
    Status 
WHERE
    SH_ID = '42';                     # here you can find current status of a shipment by entering Shipment ID




# List all shipments managed by a specific employee.

SELECT 
    e.emp_id AS Employee_ID,
    e.emp_name AS Employee_Name,
    ems.shipment_Sh_ID AS Shipment_Managed_By_Employee
FROM
    employee_details AS e
        JOIN
    employee_manages_shipment AS ems ON e.emp_id = ems.employee_E_ID
WHERE
    e.emp_id = 11;               # here you can find all of shipment managed by employee by there Employee ID


# Calculate the average shipment charge for each shipment domain:

SELECT 
    SD_Domain AS Domain,
    ROUND(AVG(SD_charges), 2) AS Average_Charge
FROM
    shipment_details
GROUP BY SD_Domain;

# Find the total number of shipments managed by each employee:

SELECT 
    e.emp_id AS Employee_ID,
    e.emp_name AS Employee_Name,
    COUNT(ems.shipment_Sh_ID) AS Count_Shipment_Managed_By_Employee
FROM
    employee_details AS e
        JOIN
    employee_manages_shipment AS ems ON e.emp_id = ems.employee_E_ID
GROUP BY e.emp_id;

# List all customers who have active memberships

SELECT 
    c.cust_id AS Customer_Id,
    m.m_id AS Membership_ID,
    c.cust_name AS Customer_Name
FROM
    customer AS c
        JOIN
    membership AS m ON c.membership_m_id = m.m_id
WHERE
    end_date > '2020-08-03';          

# Retrieve the details of the employee who manages the most shipments.

SELECT 
    *
FROM
    employee_details AS ed
        JOIN
    (SELECT 
        employee_e_id AS Employee_ID, COUNT(*) AS Number_Shipment
    FROM
        employee_manages_shipment
    GROUP BY Employee_ID
    ORDER BY number_shipment DESC
    LIMIT 1) AS Most_Shipment ON ed.emp_id = Most_Shipment.Employee_ID;

# Find the customers who have not made any payments.

SELECT 
    c.cust_Id AS Customer_ID, c.cust_name AS Customer_Name
FROM
    customer AS c
        JOIN
    payment_details AS pd ON c.cust_id = pd.customer_cust_id
WHERE
    pd.payment_status = 'NOT PAID';

# Retrieve the details of shipments along with the names of their corresponding customers.

SELECT 
    c.cust_name AS Customer_Name, sd.*
FROM
    customer AS c
        JOIN
    shipment_details AS sd ON c.cust_id = sd.customer_cust_id;

# Find all customers who have made payments along with the payment details:

SELECT 
    c.cust_Id AS Customer_ID,
    c.cust_name AS Customer_Name,
    pd.payment_id AS Payment_ID,
    pd.amount AS Amount,
    pd.payment_status AS Status,
    pd.payment_mode AS Mode,
    pd.payment_date AS Date
FROM
    customer AS c
        JOIN
    payment_details AS pd ON c.cust_id = pd.customer_cust_id
WHERE
    pd.payment_status = 'PAID';

# Retrieve all shipments along with their current status and the employee who manages them.

SELECT 
    e.emp_id AS Employee_ID,
    e.emp_name AS Employee_Name,
    sd.sd_Id AS Shipment_ID,
    s.current_status AS Current_Status
FROM
    employee_details AS e
        JOIN
    employee_manages_shipment AS ems ON e.emp_id = ems.employee_e_id
        JOIN
    shipment_details AS sd ON sd.sd_id = ems.shipment_sh_id
        JOIN
    status AS s ON s.sh_id = ems.status_sh_id;

# Find the customers who have spent more than the average payment amount.

SELECT 
    c.cust_id AS Customer_ID, c.Cust_Name AS Customer_Name
FROM
    customer AS c
        JOIN
    (SELECT 
        customer_cust_id, AVG(amount) AS Avg_amount
    FROM
        payment_details
    GROUP BY customer_cust_id
    HAVING AVG(amount) > (SELECT 
            AVG(amount)
        FROM
            payment_details)) AS Cust_spend_more_than_avg ON c.cust_id = Cust_spend_more_than_avg.customer_cust_id;

# List all shipments that have not been delivered yet

SELECT 
    *
FROM
    status
WHERE
    current_status = 'NOT DELIVERED';


# List all customers who have active memberships.

SELECT 
    c.*
FROM
    Customer as c
        JOIN
    Membership as m ON c.Cust_ID = m.M_ID
WHERE
    CURDATE() BETWEEN STR_TO_DATE(m.START_DATE, '%Y-%m-%d') AND STR_TO_DATE(m.END_DATE, '%Y-%m-%d');


# Stored Procedure
# Create a stored procedure to insert a new employee into the employee_details table.

DELIMITER //

CREATE PROCEDURE Insert_Employee_Details(
    IN IE_Emp_ID INT,
    IN IE_Emp_Name VARCHAR(30),
    IN IE_Emp_Designation VARCHAR(40),
    IN IE_Emp_Addr VARCHAR(100),
    IN IE_Emp_Branch VARCHAR(15),
    IN IE_Emp_Cont_No VARCHAR(10)
)
BEGIN
    INSERT INTO employee_details (Emp_ID, Emp_Name, Emp_Designation, Emp_Addr, Emp_Branch, Emp_Cont_No)
    VALUES (IE_Emp_ID, IE_Emp_Name, IE_Emp_Designation, IE_Emp_Addr, IE_Emp_Branch, IE_Emp_Cont_No);
END //

DELIMITER ;


CALL Insert_Employee_Details(997, 'John', 'Sales Manager', '123 Main St, City', 'MA', '1234567890');


# Create a stored procedure to insert a new shipment into the shipment_details table.

delimiter //
create procedure Insert_Shipment_Details(
	in IS_SD_ID int,
    in IS_Customer_Cust_ID int,
    in IS_SD_Content varchar(40),
    in IS_SD_Domain varchar(15),
    in IS_SD_Type varchar(15),
    in IS_SD_Weight varchar(10),
    in IS_SD_Charges int,
    in IS_SD_Addr varchar(100),
    in IS_DS_Addr varchar(100)
)
begin
	insert into shipment_details(SD_ID, Customer_Cust_ID, SD_Content, SD_Domain, SD_Type, SD_Weight, SD_Charges, SD_Addr, DS_Addr)
    values ( IS_SD_ID, IS_Customer_Cust_ID, IS_SD_Content, IS_SD_Domain, IS_SD_Type, IS_SD_Weight, IS_SD_Charges, IS_SD_Addr, IS_DS_Addr);
end //

delimiter ;


call Insert_Shipment_details(22, 114, "Healthcare",  "International", "Regular",  "1117", 777, "17TH ST / 800 Block", "JONES ST / GOLDEN GATE AV");

# Create a stored procedure to insert a new payment into the payment_details table.

delimiter //

create procedure Insert_Payment_Details(
	in IP_Payment_ID varchar(40),
    in IP_Customer_Cust_ID int,
    in IP_Shipment_SH_ID int,
    in IP_Amount int,
    in IP_Payment_Status varchar(10),
    in IP_Payment_Mode varchar(25),
    in IP_Payment_Date text
)
begin
	insert into Payment_Details (Payment_ID, Customer_Cust_ID, Shipment_SH_ID, Amount, Payment_Status, Payment_Mode, Payment_Date)
    values (IP_Payment_ID, IP_Customer_Cust_ID, IP_Shipment_SH_ID, IP_Amount, IP_Payment_Status, IP_Payment_Mode, IP_Payment_Date);
end //

delimiter ;


call Insert_Payment_Details('41affa0a-66f3-11ea-8464-7077813058ce', 2573, 536, 8206, 'PAID', 'CARD PAYMENT', '2016-09-21');

# Create a stored procedure to assign an employee to manage a shipment.

delimiter //

create procedure Insert_Employee_Manages_Shipment(
	in IEMS_Employee_E_ID int,
    in IEMS_Shipment_SH_ID int,
    in IEMS_Status_SH_ID int
)
begin 
	insert into Employee_Manages_Shipment(Employee_E_ID, Shipment_SH_ID, Status_SH_ID)
	values (IEMS_Employee_E_ID, IEMS_Shipment_SH_ID, IEMS_Status_SH_ID);
end//

delimiter //

call Insert_Employee_Manages_Shipment('900', '45', '018');


# Create a stored procedure to insert a new customer into the customer table.


delimiter //

create procedure Insert_Customer(
	in IC_Cust_ID int,
    in IC_Membership_M_ID int,
    in IC_Cust_Name varchar(30),
    in IC_Cust_Email_ID varchar(50),
    in IC_Cust_Type varchar(30),
    in IC_Cust_Addr varchar(100),
    in IC_Cust_Cont_No varchar(10)
)
begin
	insert into Customer(Cust_ID, Membership_M_ID, Cust_Name, Cust_Email_ID, Cust_Type, Cust_Addr, Cust_Cont_No)
    values (IC_Cust_ID, IC_Membership_M_ID, IC_Cust_Name, IC_Cust_Email_ID, IC_Cust_Type, IC_Cust_Addr, IC_Cust_Cont_No);
end//

delimiter ;

call Insert_Customer( 9969, 989, "Jack", "jack1845@gmail.com", "Internal Goods", "13th ST", "991288456") ;


# Data Validation 
# Create a trigger to ensure that the End_Date in the membership table is always greater than the Start_Date.

delimiter //

CREATE TRIGGER ensure_end_date_after_start_date
BEFORE INSERT ON membership
FOR EACH ROW
BEGIN
    IF NEW.End_Date <= NEW.Start_Date THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'End date must be greater than start date';
    END IF;
END;
//

delimiter ;

# Create a trigger to ensure that the Sh_Charge in the shipment_details table is always greater than zero.

delimiter //

CREATE TRIGGER ensure_positive_shipment_charge
BEFORE INSERT ON shipment_details
FOR EACH ROW
BEGIN
    IF NEW.SD_Charges <= 0 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Shipment charge must be greater than zero';
    END IF;
END;
//

delimiter ;

# Create a trigger to ensure that the Amount in the payment_details table is always greater than zero.

delimiter //

CREATE TRIGGER ensure_positive_payment_amount
BEFORE INSERT ON payment_details
FOR EACH ROW
BEGIN
    IF NEW.Amount <= 0 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Payment amount must be greater than zero';
    END IF;
END;
//

delimiter ;
