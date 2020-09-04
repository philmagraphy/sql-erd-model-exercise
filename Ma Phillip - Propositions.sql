-- Show all instructors who are teaching classes in multiple departments.
use QueensCollegeSchedulSpring2019;

select InstructorID, InstructorLastName, InstructorFirstName 
from Employee.InstructorDepartment
group by InstructorID, InstructorLastName, InstructorFirstName
having count(InstructorID) > 1
;

-- How many instructors are in each department?
use QueensCollegeSchedulSpring2019;

select count(distinct InstructorID) as [Instructors per Department]
from Employee.InstructorDepartment
group by Department
;

-- How many classes that are being taught that semester 
--	grouped by course and 
--	aggregating the total enrollment, total class limit and the percentage of enrollment.
use QueensCollegeSchedulSpring2019;

select	Department, 
		CourseNumber, 
		count(distinct ClassID) as NumberOfClasses, 
		sum(enrollment) as TotalEnrollment, 
		sum(limit) as TotalClassLimit, 
		cast(cast((sum(enrollment)/(sum(limit) + 0.0) * 100) as int) as varchar) + '%' as PercentEnrollment
from Course.Class
where Term = 'Spring' and [Year] = 2019
group by Department, CourseNumber
;

-- Where are the majority of classes being held?
use QueensCollegeSchedulSpring2019;

select C.Building, count(distinct C.Room) as NumberOfClasses
from Course.Class as C
	inner join [Location].RoomLocation as RL
		on RL.Building = C.Building
		and RL.Room = C.Room
group by C.Building
order by NumberOfClasses desc
;

-- Show departments as organized by number of classes offered.
use QueensCollegeSchedulSpring2019;

select	Department, 
		count(distinct ClassID) as NumberOfClasses
from Course.Class
group by Department
order by NumberOfClasses desc
;

-- What is the mode of instruction breakdown by department?
use QueensCollegeSchedulSpring2019;

select Department, Mode, count(Mode) as NumberOfClasses
from Course.Class
group by Department, Mode
order by Department asc, NumberOfClasses desc
;