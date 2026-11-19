
CREATE DATABASE hospital_management1;
USE hospital_management1;

CREATE TABLE Dim_Patient (
    Patient_ID VARCHAR(10) PRIMARY KEY,
    Patient_Name VARCHAR(100) NOT NULL,
    Gender VARCHAR(10),
    Age INT,
    Blood_Group VARCHAR(5),
    City VARCHAR(50)
);

CREATE TABLE Dim_Department (
    Department_ID VARCHAR(10) PRIMARY KEY,
    Department_Name VARCHAR(100) NOT NULL,
    Beds INT
);

CREATE TABLE Dim_Doctor (
    Doctor_ID VARCHAR(10) PRIMARY KEY,
    Doctor_Name VARCHAR(100) NOT NULL,
    Department_ID VARCHAR(10) NOT NULL,
    Specialization VARCHAR(100),
    Experience_Years INT,
    CONSTRAINT FK_Doctor_Department
        FOREIGN KEY (Department_ID) REFERENCES Dim_Department(Department_ID)
);

CREATE TABLE Dim_Date (
    Date_ID INT PRIMARY KEY,
    Date DATE NOT NULL,
    Day VARCHAR(15),
    Month VARCHAR(15),
    Month_Number INT,
    Quarter VARCHAR(5),
    Year INT
);




CREATE TABLE Dim_Treatment (
    Treatment_ID VARCHAR(10) PRIMARY KEY,
    Treatment_Name VARCHAR(100) NOT NULL,
    Treatment_Category VARCHAR(50),
    Standard_Cost DECIMAL(12,2)
);

CREATE TABLE Fact_Hospital (
    Visit_ID VARCHAR(10) PRIMARY KEY,
    Patient_ID VARCHAR(10) NOT NULL,
    Doctor_ID VARCHAR(10) NOT NULL,
    Department_ID VARCHAR(10) NOT NULL,
    Date_ID INT NOT NULL,
    Treatment_ID VARCHAR(10) NOT NULL,
    Admission_Date DATE,
    Discharge_Date DATE,
    Waiting_Time_Minutes INT,
    Length_of_Stay_Days INT,
    Patient_Rating DECIMAL(3,1),
    Visit_Status VARCHAR(30),
    Gross_Amount DECIMAL(12,2),
    Insurance_Amount DECIMAL(12,2),
    Patient_Payable DECIMAL(12,2),
    Payment_Status VARCHAR(30),
    CONSTRAINT FK_Fact_Patient FOREIGN KEY (Patient_ID) REFERENCES Dim_Patient(Patient_ID),
    CONSTRAINT FK_Fact_Doctor FOREIGN KEY (Doctor_ID) REFERENCES Dim_Doctor(Doctor_ID),
    CONSTRAINT FK_Fact_Department FOREIGN KEY (Department_ID) REFERENCES Dim_Department(Department_ID),
    CONSTRAINT FK_Fact_Date FOREIGN KEY (Date_ID) REFERENCES Dim_Date(Date_ID),
    CONSTRAINT FK_Fact_Treatment FOREIGN KEY (Treatment_ID) REFERENCES Dim_Treatment(Treatment_ID)
);

select * from fact_hospital;
select * from dim_date;
select * from dim_doctor;
select *from dim_patient;
select * from dim_treatment;


SELECT Patient_ID,Patient_Name,Gender,Age,CityFROM Dim_Patient;

#------------------------patients from chennai----------------------------#

SELECT *
FROM Dim_Patient
WHERE City = 'Chennai';

#--------------------------patient above age 50---------------------------------#

SELECT *
FROM Dim_Patient
WHERE Age > 50;

#---------------------------. Completed visits---------------------------------#
SELECT *
FROM Fact_Hospital
WHERE Visit_Status = 'Completed';

#-------------------------------High-value hospital bills------------------#

SELECT *
FROM Fact_Hospital
WHERE Gross_Amount > 20000;

#--------------------------Highest revenue visits---------------------------#
SELECT
    Visit_ID,
    Gross_Amount
FROM Fact_Hospital
ORDER BY Gross_Amount DESC;

#--------------------------oldest patient------------------------#
SELECT
    Patient_ID,
    Patient_Name,
    Age
FROM Dim_Patient
ORDER BY Age DESC;

#--------------------------Total revenue--------------------#
SELECT SUM(Gross_Amount) AS Total_Revenue
FROM Fact_Hospital;

#------------------------ Total insurance------------------#
SELECT SUM(Insurance_Amount) AS Total_Insurance
FROM Fact_Hospital;

#-------------------------Total patient payable-------------#
SELECT SUM(Patient_Payable) AS Total_Patient_Payable
FROM Fact_Hospital;

#-----------------------Average waiting time----------------#
SELECT AVG(Waiting_Time_Minutes) AS Avg_Waiting_Time
FROM Fact_Hospital;

#---------------------Average length of stay----------------#
SELECT AVG(Length_of_Stay_Days) AS Avg_Length_of_Stay
FROM Fact_Hospital;

#---------------------Average patient rating----------------#
SELECT AVG(Patient_Rating) AS Avg_Patient_Rating
FROM Fact_Hospital;

#----------------------Total visits------------------------#
SELECT COUNT(*) AS Total_Visits
FROM Fact_Hospital;

#--------------------Unique patients-------------------------#
SELECT COUNT(DISTINCT Patient_ID) AS Total_Patients
FROM Fact_Hospital;

#--------------------Visits by department---------------------#
SELECT
    d.Department_Name,
    COUNT(*) AS Total_Visits
FROM Fact_Hospital f
JOIN Dim_Department d
    ON f.Department_ID = d.Department_ID
GROUP BY d.Department_Name
ORDER BY Total_Visits DESC;

#-------------------Revenue by department------------------#
SELECT
    d.Department_Name,
    SUM(f.Gross_Amount) AS Total_Revenue
FROM Fact_Hospital f
JOIN Dim_Department d
    ON f.Department_ID = d.Department_ID
GROUP BY d.Department_Name
ORDER BY Total_Revenue DESC;

#--------------Average rating by department-----------------#
SELECT
    d.Department_Name,
    ROUND(AVG(f.Patient_Rating),2) AS Avg_Rating
FROM Fact_Hospital f
JOIN Dim_Department d
    ON f.Department_ID = d.Department_ID
GROUP BY d.Department_Name
ORDER BY Avg_Rating DESC;

#------------------Average waiting time by department----------------#
SELECT
    d.Department_Name,
    ROUND(AVG(f.Waiting_Time_Minutes),2) AS Avg_Waiting_Time
FROM Fact_Hospital f
JOIN Dim_Department d
    ON f.Department_ID = d.Department_ID
GROUP BY d.Department_Name;

#--------------------Visits by doctor-----------------------------#
SELECT
    d.Doctor_Name,
    COUNT(*) AS Total_Visits
FROM Fact_Hospital f
JOIN Dim_Doctor d
    ON f.Doctor_ID = d.Doctor_ID
GROUP BY d.Doctor_Name
ORDER BY Total_Visits DESC;

#-------------------Doctor-wise revenue-----------------#
SELECT
    d.Doctor_Name,
    SUM(f.Gross_Amount) AS Revenue
FROM Fact_Hospital f
JOIN Dim_Doctor d
    ON f.Doctor_ID = d.Doctor_ID
GROUP BY d.Doctor_Name
ORDER BY Revenue DESC;

#---------------------------Doctor-wise average rating-------------#
SELECT
    d.Doctor_Name,
    ROUND(AVG(f.Patient_Rating),2) AS Avg_Rating
FROM Fact_Hospital f
JOIN Dim_Doctor d
    ON f.Doctor_ID = d.Doctor_ID
GROUP BY d.Doctor_Name
ORDER BY Avg_Rating DESC;

#-------------------------Treatment-wise number of visits------------------#
SELECT
    t.Treatment_Name,
    COUNT(*) AS Total_Visits
FROM Fact_Hospital f
JOIN Dim_Treatment t
    ON f.Treatment_ID = t.Treatment_ID
GROUP BY t.Treatment_Name
ORDER BY Total_Visits DESC;

#-----------------------------Treatment-wise revenue--------------------#
SELECT
    t.Treatment_Name,
    SUM(f.Gross_Amount) AS Revenue
FROM Fact_Hospital f
JOIN Dim_Treatment t
    ON f.Treatment_ID = t.Treatment_ID
    GROUP BY t.Treatment_Name
ORDER BY Revenue DESC;

#----------------------------Revenue by treatment category---------------#
SELECT
    t.Treatment_Category,
    SUM(f.Gross_Amount) AS Revenue
FROM Fact_Hospital f
JOIN Dim_Treatment t
    ON f.Treatment_ID = t.Treatment_ID
GROUP BY t.Treatment_Category
ORDER BY Revenue DESC;

#----------------------------Payment status distribution---------------------#
SELECT
    Payment_Status,
    COUNT(*) AS Total_Visits
FROM Fact_Hospital
GROUP BY Payment_Status
ORDER BY Total_Visits DESC;

#----------------------------Revenue by payment status------------------------#
SELECT
    Payment_Status,
    SUM(Gross_Amount) AS Revenue
FROM Fact_Hospital
GROUP BY Payment_Status;
 
 #---------------------------Completed vs cancelled vs follow-up--------------#
SELECT
    Visit_Status,
    COUNT(*) AS Total_Visits
FROM Fact_Hospital
GROUP BY Visit_Status;

#------------------------------Cancellation percentage------------------------#
SELECT
    ROUND(
        100.0 * SUM(CASE WHEN Visit_Status = 'Cancelled' THEN 1 ELSE 0 END)
        / COUNT(*),
        2
    ) AS Cancellation_Percentage
FROM Fact_Hospital;

#-------------------------------Gender distribution---------------------------#
SELECT
    Gender,
    COUNT(*) AS Total_Patients
FROM Dim_Patient
GROUP BY Gender;

#-----------------------------City-wise patients--------------------------#
SELECT
    City,
    COUNT(*) AS Total_Patients
FROM Dim_Patient
GROUP BY City
ORDER BY Total_Patients DESC;

#----------------------------Age-group analysis---------------------------#
SELECT
    CASE
        WHEN Age < 18 THEN 'Child'
        WHEN Age BETWEEN 18 AND 35 THEN 'Young Adult'
        WHEN Age BETWEEN 36 AND 60 THEN 'Adult'
        ELSE 'Senior'
    END AS Age_Group,
    COUNT(*) AS Total_Patients
FROM Dim_Patient
GROUP BY Age_Group;

#--------------------------monthly Analysis------------------------------#
SELECT
    dd.Year,
    dd.Month,
    dd.Month_Number,
    COUNT(*) AS Total_Visits
FROM Fact_Hospital f
JOIN Dim_Date dd
    ON f.Date_ID = dd.Date_ID
GROUP BY
    dd.Year,
    dd.Month,
    dd.Month_Number
ORDER BY
    dd.Year,
    dd.Month_Number;

#---------------------------Monthly revenue-----------------------------#
SELECT
    dd.Year,
    dd.Month,
    dd.Month_Number,
    SUM(f.Gross_Amount) AS Revenue
FROM Fact_Hospital f
JOIN Dim_Date dd
    ON f.Date_ID = dd.Date_ID
GROUP BY
    dd.Year,
    dd.Month,
    dd.Month_Number
ORDER BY
    dd.Year,
    dd.Month_Number;
    
#-------------------Departments having more than 200 visits----------------#
SELECT
    d.Department_Name,
    COUNT(*) AS Total_Visits
FROM Fact_Hospital f
JOIN Dim_Department d
    ON f.Department_ID = d.Department_ID
GROUP BY d.Department_Name
HAVING COUNT(*) > 200;

#----------------------Visits with revenue above average----------------#
SELECT
    Visit_ID,
    Gross_Amount
FROM Fact_Hospital
WHERE Gross_Amount >
(
    SELECT AVG(Gross_Amount)
    FROM Fact_Hospital
)
ORDER BY Gross_Amount DESC;

 #--------------------------Department revenue using CTE-----------------------#
WITH Department_Revenue AS
(
    SELECT
        Department_ID,
        SUM(Gross_Amount) AS Revenue
    FROM Fact_Hospital
    GROUP BY Department_ID
)
SELECT
    d.Department_Name,
    dr.Revenue
FROM Department_Revenue dr
JOIN Dim_Department d
    ON dr.Department_ID = d.Department_ID
ORDER BY dr.Revenue DESC;

#-------------------------Rank departments by revenue-----------------#
SELECT
    d.Department_Name,
    SUM(f.Gross_Amount) AS Revenue,
    RANK() OVER (
        ORDER BY SUM(f.Gross_Amount) DESC
    ) AS Revenue_Rank
FROM Fact_Hospital f
JOIN Dim_Department d
    ON f.Department_ID = d.Department_ID
GROUP BY d.Department_Name;

#-------------------------- Top 5 Doctors-------------------------#
SELECT
    d.Doctor_Name,
    COUNT(*) AS Total_Visits
FROM Fact_Hospital f
JOIN Dim_Doctor d
    ON f.Doctor_ID = d.Doctor_ID
GROUP BY d.Doctor_Name
ORDER BY Total_Visits DESC
LIMIT 5;


















