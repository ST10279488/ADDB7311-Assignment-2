CREATE TABLE CUSTOMERR (
    CUSTOMER_ID INT PRIMARY KEY,
    FIRST_NAME VARCHAR(50),
    SURNAME VARCHAR(50),
    ADDRESS VARCHAR(100),
    CONTACT_NUMBER VARCHAR(20),
    EMAIL VARCHAR(100)
);
CREATE TABLE EMPLOYEEE (
    EMPLOYEE_ID VARCHAR(10) PRIMARY KEY,
    FIRST_NAME VARCHAR(50),
    SURNAME VARCHAR(50),
    CONTACT_NUMBER VARCHAR(20),
    ADDRESS VARCHAR(100),
    EMAIL VARCHAR(100)
);
CREATE TABLE DONATORR (
    DONATOR_ID INT PRIMARY KEY,
    FIRST_NAME VARCHAR(50),
    SURNAME VARCHAR(50),
    CONTACT_NUMBER VARCHAR(20),
    EMAIL VARCHAR(100)
);
CREATE TABLE DONATIONN (
    DONATION_ID INT PRIMARY KEY,
    DONATOR_ID INT,
    DONATION VARCHAR(100),
    PRICE DECIMAL(10, 2),
    DONATION_DATE DATE
);
CREATE TABLE DELIVERYY (
    DELIVERY_ID INT PRIMARY KEY,
    DELIVERY_NOTES VARCHAR(255),
    DISPATCH_DATE DATE,
    DELIVERY_DATE DATE
);
CREATE TABLE RETURNSS (
    RETURN_ID VARCHAR(10) PRIMARY KEY,
    RETURN_DATE DATE,
    REASON VARCHAR(255),
    CUSTOMER_ID INT,
    DONATION_ID INT,
    EMPLOYEE_ID VARCHAR(10)
);
CREATE TABLE INVOICEE (
    INVOICE_NUM INT PRIMARY KEY,
    CUSTOMER_ID INT,
    INVOICE_DATE DATE,
    EMPLOYEE_ID VARCHAR(10),
    DONATION_ID INT,
    DELIVERY_ID INT
);

SELECT 
    c.FIRST_NAME || ' ' || c.SURNAME AS CUSTOMER_NAME,
    i.EMPLOYEE_ID,
    d.DELIVERY_NOTES,
    don.DONATION AS DONATION_PURCHASED,
    i.INVOICE_NUM
FROM 
    INVOICEE i
JOIN CUSTOMERR c ON i.CUSTOMER_ID = c.CUSTOMER_ID
JOIN EMPLOYEEE e ON i.EMPLOYEE_ID = e.EMPLOYEE_ID
JOIN DELIVERYY d ON i.DELIVERY_ID = d.DELIVERY_ID
JOIN DONATION don ON i.DONATION_ID = don.DONATION_ID
WHERE 
    i.INVOICE_DATE > TO_DATE('2024-05-16', 'YYYY-MM-DD');
    
    
CREATE TABLE Funding (
    funding_id NUMBER PRIMARY KEY,
    funder VARCHAR2(100),
    funding_amount NUMBER(10, 2)
);

CREATE SEQUENCE funding_seq
    START WITH 1
    INCREMENT BY 1
    NOCACHE;
    
CREATE OR REPLACE TRIGGER funding_id_trigger
BEFORE INSERT ON Funding
FOR EACH ROW
BEGIN
    :NEW.funding_id := funding_seq.NEXTVAL;
END;
/

INSERT INTO Funding (funder, funding_amount)
VALUES ('John Doe', 5000.00);


BEGIN
    FOR rec IN
    (
        SELECT 
            c.FIRST_NAME || ' ' || c.SURNAME AS CUSTOMER_NAME, 
            d.DONATION AS DONATION_PURCHASED,
            d.PRICE AS DONATION_PRICE,
            r.REASON AS RETURN_REASON
        FROM 
            RETURNS r
        JOIN CUSTOMER c ON r.CUSTOMER_ID = c.CUSTOMER_ID
        JOIN DONATION d ON r.DONATION_ID = d.DONATION_ID
    ) 
    LOOP
        DBMS_OUTPUT.PUT_LINE('Customer Name: ' || rec.CUSTOMER_NAME);
        DBMS_OUTPUT.PUT_LINE('Donation Purchased: ' || rec.DONATION_PURCHASED);
        DBMS_OUTPUT.PUT_LINE('Donation Price: ' || rec.DONATION_PRICE);
        DBMS_OUTPUT.PUT_LINE('Return Reason: ' || rec.RETURN_REASON);
        DBMS_OUTPUT.PUT_LINE('------------------------------');
    END LOOP;
END;
/

SET SERVEROUTPUT ON;

BEGIN
   FOR rec IN
   (
       SELECT 
           c.FIRST_NAME || ' ' || c.SURNAME AS CUSTOMER_NAME, -- Using || for concatenation
           e.FIRST_NAME || ' ' || e.SURNAME AS EMPLOYEE_NAME,
           d.DONATION AS DONATION_PURCHASED,
           del.DISPATCH_DATE,
           del.DELIVERY_DATE,
           (del.DELIVERY_DATE - del.DISPATCH_DATE) AS DAYS_BETWEEN
       FROM 
           INVOICE i
       JOIN CUSTOMER c ON i.CUSTOMER_ID = c.CUSTOMER_ID
       JOIN EMPLOYEE e ON i.EMPLOYEE_ID = e.EMPLOYEE_ID
       JOIN DONATION d ON i.DONATION_ID = d.DONATION_ID
       JOIN DELIVERY del ON i.DELIVERY_ID = del.DELIVERY_ID
       WHERE 
           c.CUSTOMER_ID = 11011
   ) 
   LOOP
       DBMS_OUTPUT.PUT_LINE('Customer Name: ' || rec.CUSTOMER_NAME);
       DBMS_OUTPUT.PUT_LINE('Employee Name: ' || rec.EMPLOYEE_NAME);
       DBMS_OUTPUT.PUT_LINE('Donation Purchased: ' || rec.DONATION_PURCHASED);
       DBMS_OUTPUT.PUT_LINE('Dispatch Date: ' || TO_CHAR(rec.DISPATCH_DATE, 'DD-MON-YYYY'));
       DBMS_OUTPUT.PUT_LINE('Delivery Date: ' || TO_CHAR(rec.DELIVERY_DATE, 'DD-MON-YYYY'));
       DBMS_OUTPUT.PUT_LINE('Days Between Dispatch and Delivery: ' || rec.DAYS_BETWEEN);
       DBMS_OUTPUT.PUT_LINE('------------------------------');
   END LOOP;
END;
/

SELECT 
    c.FIRST_NAME || ' ' || c.SURNAME AS CUSTOMER_NAME,
    SUM(d.PRICE) AS TOTAL_SPENT,
    CASE 
        WHEN SUM(d.PRICE) >= 1500 THEN '3-Star'
        ELSE 'No Rating'
    END AS CUSTOMER_RATING
FROM 
    INVOICE i
JOIN CUSTOMER c ON i.CUSTOMER_ID = c.CUSTOMER_ID
JOIN DONATION d ON i.DONATION_ID = d.DONATION_ID
GROUP BY 
    c.FIRST_NAME, c.SURNAME;


DECLARE
   -- Declare a variable using %TYPE to inherit the data type of CUSTOMER.FIRST_NAME
   v_customer_first_name CUSTOMER.FIRST_NAME%TYPE;
BEGIN
   -- Assign a value to the variable
   SELECT FIRST_NAME INTO v_customer_first_name
   FROM CUSTOMER
   WHERE CUSTOMER_ID = 11011;

   -- Output the customer's first name
   DBMS_OUTPUT.PUT_LINE('Customer First Name: ' || v_customer_first_name);
END;
/

DECLARE
   -- Declare a variable of %ROWTYPE to hold a complete row from the CUSTOMER table
   v_customer_rec CUSTOMER%ROWTYPE;
BEGIN
   -- Select the entire row for customer with ID 11011 into the record variable
   SELECT * INTO v_customer_rec
   FROM CUSTOMER
   WHERE CUSTOMER_ID = 11011;

   -- Output some fields from the record
   DBMS_OUTPUT.PUT_LINE('Customer Name: ' || v_customer_rec.FIRST_NAME || ' ' || v_customer_rec.SURNAME);
   DBMS_OUTPUT.PUT_LINE('Customer Email: ' || v_customer_rec.EMAIL);
END;
/

DECLARE
   -- Declare a user-defined exception for when the donation price is too high
   e_high_price EXCEPTION;
   v_donation_price DONATION.PRICE%TYPE;
BEGIN
   -- Select the price of a donation
   SELECT PRICE INTO v_donation_price
   FROM DONATION
   WHERE DONATION_ID = 7111;

   -- Raise the exception if the donation price exceeds 1000
   IF v_donation_price > 1000 THEN
      RAISE e_high_price;
   END IF;

   -- Normal flow if no exception is raised
   DBMS_OUTPUT.PUT_LINE('Donation price is acceptable: ' || v_donation_price);

EXCEPTION
   -- Handle the user-defined exception
   WHEN e_high_price THEN
      DBMS_OUTPUT.PUT_LINE('Error: Donation price exceeds the allowed limit.');
END;
/

SELECT 
    c.FIRST_NAME || ' ' || c.SURNAME AS CUSTOMER_NAME,  -- Using || for concatenation
    SUM(d.PRICE) AS TOTAL_SPENT,
    CASE 
        WHEN SUM(d.PRICE) >= 1500 THEN '3-Star'
        WHEN SUM(d.PRICE) BETWEEN 1000 AND 1499 THEN '2-Star'
        ELSE '1-Star'
    END AS CUSTOMER_RATING
FROM 
    INVOICE i
JOIN CUSTOMER c ON i.CUSTOMER_ID = c.CUSTOMER_ID
JOIN DONATION d ON i.DONATION_ID = d.DONATION_ID
GROUP BY 
    c.FIRST_NAME, c.SURNAME;




