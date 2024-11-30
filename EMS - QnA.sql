-- Selecting EMS databse
USE EMS;

SELECT * FROM Attendance;
SELECT * FROM Department;
SELECT * FROM Employee;
SELECT * FROM JobTitle;
SELECT * FROM Project;
SELECT * FROM ProjectAllocation;
SELECT * FROM Salary;

-- Retrieve the First & Last Name of all the employees.
SELECT FirstName, LastName FROM Employee;

-- Retrieve the First & Last Name of employees who works as Software Engineer
SELECT FirstName, LastName FROM Employee
WHERE JobTitleID = (SELECT JobTitleID FROM JobTitle 
					WHERE JobTitleName='Software Engineer');

-- Retrieve First & Last names of last 7 hires
SELECT TOP 7 FirstName, LastName
FROM Employee
ORDER BY HireDate DESC;

-- Get the count of employees in each job title
SELECT JobTitleName, COUNT(EmployeeID) Employee_Count
FROM Employee E
INNER JOIN JobTitle J
ON E.JobTitleID = J.JobTitleID
GROUP BY JobTitleName;

-- Retrieve the full name & other personal info of employees who work in Engineering department
SELECT CONCAT(FirstName,' ',LastName) FullName,
		DateOfBirth, Gender, PhoneNumber, Email
FROM Employee E
INNER JOIN Department D
ON E.DepartmentID = D.DepartmentID
WHERE DepartmentName = 'Engineering';

-- List job titles that have more than 3 employees
SELECT JobTitleName, COUNT(EmployeeID) EmployeeCount
FROM JobTitle J
INNER JOIN Employee E
ON J.JobTitleID = E.JobTitleID
GROUP BY JobTitleName
HAVING COUNT(EmployeeID)>3;

-- Retrieve all employees names along with their department names
SELECT CONCAT(FirstName,' ',LastName) FullName,
		DepartmentName
FROM Employee E
INNER JOIN Department D
ON E.DepartmentID = D.DepartmentID;

-- Retrieve the first name of employees and the projects they are working on, along with their role in the project
SELECT FirstName, ProjectName, JobTitleName 'Role'
FROM Employee E
	INNER JOIN ProjectAllocation PA
		ON E.EmployeeID = PA.EmployeeID
	INNER JOIN Project P
		ON P.ProjectID = PA.ProjectID
	INNER JOIN JobTitle J
		ON E.JobTitleID = J.JobTitleID;

-- Get the count of employees in each department
SELECT DepartmentName, COUNT(EmployeeID) 'EmployeeCount'
FROM Employee E
INNER JOIN Department D
ON E.DepartmentID = D.DepartmentID
GROUP BY DepartmentName;

-- List all departments with more than 5 employees
SELECT DepartmentName, COUNT(EmployeeID) 'EmployeeCount'
FROM Employee E
INNER JOIN Department D
ON E.DepartmentID = D.DepartmentID
GROUP BY DepartmentName
HAVING COUNT(EmployeeID)>5;

-- Retrieve the full name of employees and their managers
SELECT CONCAT(E.FirstName,' ',E.LastName) 'EmployeeName',
		CONCAT(M.FirstName,' ',M.LastName) 'ManagerName'
FROM Employee E
INNER JOIN Employee M
ON M.EmployeeID = E.ManagerID;

-- Which manager is managing more employees and how many
SELECT TOP 1 CONCAT(M.FirstName,' ',M.LastName) 'ManagerName',
			COUNT(E.EmployeeID) 'EmployeeCount'
FROM Employee E
INNER JOIN Employee M
ON M.EmployeeID = E.ManagerID
GROUP BY M.EmployeeID, M.FirstName, M.LastName
ORDER BY 'EmployeeCount' DESC;

-- Retrieve full name of employees working on projects as Software Engineer, ordered by project start date
SELECT CONCAT(FirstName,' ',LastName) 'FullName',
		ProjectName, StartDate
FROM Employee E
	INNER JOIN ProjectAllocation PA
		ON E.EmployeeID = PA.EmployeeID
	INNER JOIN Project P
		ON PA.ProjectID = P.ProjectID
	INNER JOIN JobTitle J
		ON E.JobTitleID = J.JobTitleID
WHERE JobTitleName = 'Software Engineer'
ORDER BY StartDate ASC;

-- Retrieve the name of employees who are working on Project Delta
SELECT FirstName, LastName FROM Employee
WHERE EmployeeID IN (SELECT EmployeeID FROM ProjectAllocation
					WHERE ProjectID = (SELECT ProjectID FROM Project 
										WHERE ProjectName='Project Delta'));

-- Retrieve the names of employees, department name, total salary ordered by total salary in descending order
SELECT FirstName, LastName, DepartmentName, 
		(BaseSalary + Bonus - Deduction) 'TotalSalary'
FROM Employee E
	INNER JOIN Department D
		ON E.DepartmentID = D.DepartmentID
	INNER JOIN Salary S
		ON E.EmployeeID = S.EmployeeID
ORDER BY TotalSalary DESC;

-- Create a function to find employees with a birthday in the given month and calculate their age
CREATE FUNCTION Get_Birthday(@Month INT)
RETURNS TABLE
AS
RETURN
(SELECT FirstName, LastName, DateOfBirth,
		DATEDIFF(YEAR, DateOfBirth, GETDATE()) 'Age'
FROM Employee
WHERE MONTH(DateOfBirth)=@Month);

SELECT * FROM DBO.Get_Birthday(10)

-- Find employees who have birthday in November and their age
SELECT * FROM DBO.Get_Birthday(11)

-- Create a function to find employees in a specified department and calcualte their tenure
CREATE FUNCTION Emp_Tenure(@Department VARCHAR(20))
RETURNS TABLE
AS
RETURN
(SELECT FirstName, LastName, DepartmentName,
		DATEDIFF(YEAR, HireDate, GETDATE()) 'Tenure'
FROM Employee E
INNER JOIN Department D
ON E.DepartmentID = D.DepartmentID
WHERE DepartmentName=@Department);

-- Find employees in the Engineering department and their Tenure
SELECT * FROM DBO.Emp_Tenure('Engineering');

-- Find employees in the HR department and their Tenure
SELECT * FROM DBO.Emp_Tenure('Human Resources');

