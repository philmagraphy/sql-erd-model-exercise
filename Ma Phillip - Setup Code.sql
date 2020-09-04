-- ===============================================================================
-- ** PROJECT:
-- ** CONVERT QueensClassScheduleSpring2019 data into an ERD design.
-- **
-- ** PHILLIP MA
-- ===============================================================================
--BEGIN PROJECT CODE
USE QueensCollegeSchedulSpring2019;
GO

---- LIST SCHEMA / DROP SCHEMA
/*
SELECT name
FROM sys.schemas

DROP SCHEMA IF EXISTS Course;
DROP SCHEMA IF EXISTS Employee;
DROP SCHEMA IF EXISTS Location;
*/

-- ===============================================================================
-- ============================== CREATE SCHEMA ==================================
-- ===============================================================================

IF NOT EXISTS (SELECT name FROM sys.schemas WHERE name = 'Course')
BEGIN
EXEC('CREATE SCHEMA Course')
END

IF NOT EXISTS (SELECT name FROM sys.schemas WHERE name = 'Employee')
BEGIN
EXEC('CREATE SCHEMA Employee')
END

IF NOT EXISTS (SELECT name FROM sys.schemas WHERE name = 'Location')
BEGIN
EXEC('CREATE SCHEMA Location')
END

IF NOT EXISTS (SELECT name FROM sys.schemas WHERE name = 'Process')
BEGIN
EXEC('CREATE SCHEMA Process')
END

-- ===============================================================================
-- ============================== CREATE TABLES ==================================
-- ===============================================================================

---- CREATE TABLE Process.WorkflowSteps
DROP TABLE IF EXISTS Process.WorkflowSteps
CREATE TABLE Process.WorkflowSteps
(
 [WorkflowStepKey]			 int IDENTITY (1, 1)	NOT NULL ,
 [WorkflowStepDescription]   nvarchar(100)			NOT NULL ,
 [WorkflowStepTableRowCount] int					NULL DEFAULT (0),
 [StartingDateTime]          datetime2(7)			NULL DEFAULT sysdatetime() ,
 [EndingDateTime]            datetime2(7)			NULL DEFAULT sysdatetime() ,

 CONSTRAINT [PK_Workflow] PRIMARY KEY CLUSTERED ([WorkflowStepKey] ASC)
);
GO

---- CREATE TABLE Employee.Instructor
DROP TABLE IF EXISTS Employee.Instructor;
CREATE TABLE Employee.Instructor
(
 [InstructorID]         int IDENTITY (1, 1) NOT NULL ,
 [InstructorLastName]   varchar(30) NOT NULL ,
 [InstructorFirstName]  varchar(30) NOT NULL ,

 CONSTRAINT [PK_Instructor] PRIMARY KEY CLUSTERED ([InstructorID] ASC, [InstructorLastName] ASC, [InstructorFirstName] ASC)
);
GO

---- CREATE TABLE Employee.Department
DROP TABLE IF EXISTS Employee.Department;
CREATE TABLE Employee.Department
(
 [Department] char(6) NOT NULL ,

 CONSTRAINT [PK_Department] PRIMARY KEY CLUSTERED ([Department] ASC)
);
GO

-- CREATE TABLE Employee.InstructorDepartment
DROP TABLE IF EXISTS Employee.InstructorDepartment;
CREATE TABLE Employee.InstructorDepartment
(
 [InstructorID]        int NOT NULL ,
 [InstructorLastName]  varchar(30) NOT NULL ,
 [InstructorFirstName] varchar(30) NOT NULL ,
 [Department]          char(6) NOT NULL ,

 CONSTRAINT [PK_InstructorDepartment] PRIMARY KEY CLUSTERED ([InstructorID] ASC, [InstructorLastName] ASC, [InstructorFirstName] ASC, [Department] ASC),
 CONSTRAINT [FK_ID_Instructor] FOREIGN KEY ([InstructorID], [InstructorLastName], [InstructorFirstName])  REFERENCES [Employee].[Instructor]([InstructorID], [InstructorLastName], [InstructorFirstName]),
 CONSTRAINT [FK_ID_Department] FOREIGN KEY ([Department])  REFERENCES [Employee].[Department]([Department])
);
GO

CREATE NONCLUSTERED INDEX [FK_ID_Instructor] ON [Employee].[InstructorDepartment] 
 (
  [InstructorID] ASC, 
  [InstructorLastName] ASC, 
  [InstructorFirstName] ASC
 )

GO

CREATE NONCLUSTERED INDEX [FK_ID_Department] ON [Employee].[InstructorDepartment] 
 (
  [Department] ASC
 )

GO
-- CREATE TABLE Location.BuildingLocation
DROP TABLE IF EXISTS [Location].BuildingLocation;
CREATE TABLE [Location].BuildingLocation
(
 [Building] varchar(6) NOT NULL ,

 CONSTRAINT [PK_BuildingLocation] PRIMARY KEY CLUSTERED ([Building] ASC)
);
GO

-- CREATE TABLE Location.RoomLocation
DROP TABLE IF EXISTS [Location].RoomLocation;
CREATE TABLE [Location].RoomLocation
(
 [Room]     varchar(6) NOT NULL ,
 [Building] varchar(6) NOT NULL ,

 CONSTRAINT [PK_RoomLocation] PRIMARY KEY CLUSTERED ([Room] ASC, [Building] ASC),
 CONSTRAINT [FK_RL_BuildingLocation] FOREIGN KEY ([Building])  REFERENCES [Location].[BuildingLocation]([Building])
);
GO

CREATE NONCLUSTERED INDEX [FK_RL_BuildingLocation] ON [Location].[RoomLocation] 
 (
  [Building] ASC
 )

GO

-- CREATE TABLE Course.Semester
DROP TABLE IF EXISTS Course.Semester;
CREATE TABLE Course.Semester
(
 [Term] char(6) NOT NULL ,
 [Year] int NOT NULL ,

 CONSTRAINT [PK_Semester] PRIMARY KEY CLUSTERED ([Term] ASC, [Year] ASC)
);
GO

-- CREATE TABLE Course.ModeOfInstruction
DROP TABLE IF EXISTS Course.ModeOfInstruction;
CREATE TABLE Course.ModeOfInstruction
(
 [Mode] varchar(20) NOT NULL ,

 CONSTRAINT [PK_ModeOfInstruction] PRIMARY KEY CLUSTERED ([Mode] ASC)
);
GO

-- CREATE TABLE Course.Course
DROP TABLE IF EXISTS Course.Course;
CREATE TABLE Course.Course
(
 [CourseNumber]      varchar(12) NOT NULL ,
 [CourseDescription] varchar(50) NULL ,
 [Hours]             varchar(6) NULL ,
 [Credits]           varchar(6) NULL ,
 [Department]        char(6) NOT NULL ,

 CONSTRAINT [PK_Course] PRIMARY KEY CLUSTERED ([CourseNumber] ASC, [Department] ASC),
 CONSTRAINT [FK_CO_Department] FOREIGN KEY ([Department])  REFERENCES [Employee].[Department]([Department])
);
GO

CREATE NONCLUSTERED INDEX [FK_CO_Department] ON [Course].[Course] 
 (
  [Department] ASC
 )

GO

-- CREATE TABLE Course.Class
DROP TABLE IF EXISTS Course.Class;
CREATE TABLE Course.Class
(
 [ClassID]             int IDENTITY (1, 1) NOT NULL ,
 [ClassCode]           int			NOT NULL ,
 [Section]             varchar(6)	NOT NULL ,
 [Days]                varchar(10)	NULL ,
 [Time]                varchar(20)	NULL ,
 [Enrollment]          int			NOT NULL ,
 [Limit]               int			NOT NULL ,
 [CourseNumber]        varchar(12)	NOT NULL ,
 [Department]          char(6)		NOT NULL ,
 [InstructorID]        int			NULL ,
 [InstructorLastName]  varchar(30)	NULL ,
 [InstructorFirstName] varchar(30)	NULL ,
 [Term]                char(6)		NOT NULL ,
 [Year]                int			NOT NULL ,
 [Room]                varchar(6)	NULL ,
 [Building]            varchar(6)	NULL ,
 [Mode]                varchar(20)	NOT NULL ,

 CONSTRAINT [PK_Class] PRIMARY KEY CLUSTERED ([ClassID] ASC),
 CONSTRAINT [FK_CL_Course] FOREIGN KEY ([CourseNumber], [Department])  REFERENCES [Course].[Course]([CourseNumber], [Department]),
 CONSTRAINT [FK_CL_Instructor] FOREIGN KEY ([InstructorID], [InstructorLastName], [InstructorFirstName])  REFERENCES [Employee].[Instructor]([InstructorID], [InstructorLastName], [InstructorFirstName]),
 CONSTRAINT [FK_CL_Semester] FOREIGN KEY ([Term], [Year])  REFERENCES [Course].[Semester]([Term], [Year]),
 CONSTRAINT [FK_CL_RoomLocation] FOREIGN KEY ([Room], [Building])  REFERENCES [Location].[RoomLocation]([Room], [Building]),
 CONSTRAINT [FK_CL_ModeOfInstruction] FOREIGN KEY ([Mode])  REFERENCES [Course].[ModeOfInstruction]([Mode])
);
GO
CREATE NONCLUSTERED INDEX [FK_CL_Course] ON [Course].[Class] 
 (
  [CourseNumber] ASC, 
  [Department] ASC
 )

GO

CREATE NONCLUSTERED INDEX [FK_CL_Instructor] ON [Course].[Class] 
 (
  [InstructorID] ASC, 
  [InstructorLastName] ASC, 
  [InstructorFirstName] ASC
 )

GO

CREATE NONCLUSTERED INDEX [FK_CL_Semester] ON [Course].[Class] 
 (
  [Term] ASC, 
  [Year] ASC
 )

GO

CREATE NONCLUSTERED INDEX [FK_CL_RoomLocation] ON [Course].[Class] 
 (
  [Room] ASC, 
  [Building] ASC
 )

GO

CREATE NONCLUSTERED INDEX [FK_CL_ModeOfInstruction] ON [Course].[Class] 
 (
  [Mode] ASC
 )

GO

-- ===============================================================================
-- ============================== WORKFLOW STORED PROCEDURES =====================
-- ===============================================================================

-- STORED PROCEDURE Process.usp_TrackWorkFlow
CREATE or ALTER PROCEDURE Process.usp_TrackWorkFlow 
   @StartTime datetime2,    
   @WorkFlowDescription nvarchar(100),     
   @WorkFlowStepTableRowCount int
as
insert into Process.WorkflowSteps(
				WorkflowStepDescription, 
				WorkFlowStepTableRowCount, 
				StartingDateTime,
				EndingDateTime
			)
values (
		@WorkflowDescription, 
		@WorkflowStepTableRowCount, 
		@StartTime,
		sysdatetime()
		);
GO

-- STORED PROCEDURE [Process].[usp_ShowWorkflowSteps]
CREATE or ALTER PROCEDURE Process.usp_ShowWorkflowSteps
AS
BEGIN
set nocount on;
select * from Process.WorkflowSteps
END;
GO

-- STORED PROCEDURE Process.usp_TotalExecutionTime
CREATE or ALTER PROCEDURE Process.usp_TotalExecutionTime
AS
BEGIN
set nocount on;
select [Total Runtime in Seconds]=
cast(
	DATEDIFF(millisecond,min(startingdatetime),MAX(endingdatetime))
 as float) / 10000
 from Process.WorkflowSteps
END;
GO

-- STORED PROCEDURE Process.DropForeignKeys
create or alter procedure Process.DropForeignKeys
as
begin
	set nocount on;
	declare @CurrentTime datetime2 = SYSDATETIME();
	
	alter table Employee.InstructorDepartment
		drop constraint FK_ID_Instructor, 
						FK_ID_Department

	alter table Course.Course
		drop constraint FK_CO_Department

	alter table [Location].RoomLocation			
		drop constraint FK_RL_BuildingLocation

	alter table [Course].[Class]
		drop constraint FK_CL_Course, 
						FK_CL_Instructor, 
						FK_CL_Semester, 
						FK_CL_RoomLocation, 
						FK_CL_ModeOfInstruction

	exec Process.usp_TrackWorkFlow 
		@StartTime = @CurrentTime, 
		@WorkFlowDescription = 'Drop Foreign Keys', 
		@WorkFlowStepTableRowCount = @@RowCount
end;
GO

-- STORED PROCEDURE Process.TruncateTables
create or alter procedure Process.TruncateTables
as
begin
	set nocount on;
	declare @CurrentTime datetime2 = SYSDATETIME();

	truncate table Employee.Instructor
	truncate table Employee.Department
	truncate table Employee.InstructorDepartment

	truncate table [Location].BuildingLocation
	truncate table [Location].RoomLocation

	truncate table Course.Semester
	truncate table Course.ModeOfInstruction
	truncate table Course.Course
	truncate table Course.Class

	truncate table Process.WorkflowSteps

	exec Process.usp_TrackWorkFlow 
		@StartTime = @CurrentTime, 
		@WorkFlowDescription = 'Truncate Tables', 
		@WorkFlowStepTableRowCount = @@RowCount
end;
GO

-- STORED PROCEDURE Process.AddForeignKeys
create or alter procedure Process.AddForeignKeys
as
begin
	set nocount on;
	declare @CurrentTime datetime2 = SYSDATETIME();

	alter table Employee.InstructorDepartment with check add
		constraint [FK_ID_Instructor] foreign key ([InstructorID], [InstructorLastName], [InstructorFirstName])
			references Employee.Instructor([InstructorID], [InstructorLastName], [InstructorFirstName]),
		constraint [FK_ID_Department] foreign key ([Department])
			references Employee.Department([Department])

	alter table [Location].RoomLocation with check add 
		constraint [FK_RL_BuildingLocation] foreign key ([Building])
			references [Location].BuildingLocation([Building])

	alter table Course.Course with check add
		constraint [FK_CO_Department] foreign key ([Department])
			references Employee.Department([Department])

	alter table Course.Class with check add
		constraint [FK_CL_Course] foreign key ([CourseNumber], [Department])
			references Course.Course([CourseNumber], [Department]),
		constraint [FK_CL_Instructor] foreign key ([InstructorID], [InstructorLastName], [InstructorFirstName])
			references Employee.Instructor([InstructorID], [InstructorLastName], [InstructorFirstName]),
		constraint [FK_CL_Semester] foreign key ([Term], [Year])
			references Course.Semester([Term], [Year]),
		constraint [FK_CL_RoomLocation] foreign key ([Room], [Building])
			references [Location].RoomLocation([Room], [Building]),
		constraint [FK_CL_ModeOfInstruction] foreign key ([Mode])
			references Course.ModeOfInstruction([Mode])

	exec Process.usp_TrackWorkFlow 
		@StartTime = @CurrentTime, 
		@WorkFlowDescription = 'Add Foreign Keys', 
		@WorkFlowStepTableRowCount = @@RowCount
end;
GO

-- ===============================================================================
-- ====================== INSERT TABLES STORED PROCEDURES ========================
-- ===============================================================================

-- INSERT INTO TABLE Employee.Instructor
-- InstructorLastName,
-- InstructorFirstName
create or alter procedure Process.LoadInstructor
as
begin
	set nocount on;
	declare @CurrentTime datetime2 = sysdatetime();

insert into Employee.Instructor(InstructorLastName, InstructorFirstName)
	select distinct
		substring(Instructor, 1,
			case when charindex(',', Instructor + ' ') - 1 < 1 then 0
			else charindex(',', Instructor + ' ') - 1
			end),
		substring(Instructor, charindex(',', Instructor + ' ') + 1, 30)
	from Uploadfile.CoursesSpring2019
	where 
			substring(Instructor, 1,
				case when charindex(',', Instructor + ' ') - 1 < 1 then 0
				else charindex(',', Instructor + ' ') - 1
				end) is not null
		and substring(Instructor, charindex(',', Instructor + ' ') + 1, 30) is not null
		and substring(Instructor, 1,
				case when charindex(',', Instructor + ' ') - 1 < 1 then 0
				else charindex(',', Instructor + ' ') - 1
				end) <> ''
		and substring(Instructor, charindex(',', Instructor + ' ') + 1, 30) <> ''

		exec Process.usp_TrackWorkflow 
		@StartTime = @CurrentTime, 
		@WorkFlowDescription = 'Load Instructor Table', 
		@WorkFlowStepTableRowCount = @@RowCount
end;
GO

-- INSERT INTO TABLE Employee.Department
-- Department
create or alter procedure Process.LoadDepartment
as
begin
	set nocount on;
	declare @CurrentTime datetime2 = sysdatetime();

insert into Employee.Department(Department)
	select distinct
		substring([Course (hr, crd)], 1, 
			case when charindex(' ', [Course (hr, crd)] + ' ') - 1 < 1 then 0
			else charindex(' ', [Course (hr, crd)] + ' ') - 1
			end)
	from Uploadfile.CoursesSpring2019
	where 
			substring([Course (hr, crd)], 1, 
				case when charindex(' ', [Course (hr, crd)] + ' ') - 1 < 1 then 0
				else charindex(' ', [Course (hr, crd)] + ' ') - 1
				end) is not null
		and substring([Course (hr, crd)], 1, 
			case when charindex(' ', [Course (hr, crd)] + ' ') - 1 < 1 then 0
			else charindex(' ', [Course (hr, crd)] + ' ') - 1
			end) <> ''

		exec Process.usp_TrackWorkflow 
		@StartTime = @CurrentTime, 
		@WorkFlowDescription = 'Load Department Table', 
		@WorkFlowStepTableRowCount = @@RowCount
end;
GO

-- INSERT INTO TABLE Employee.InstructorDepartment
-- InstructorID,
-- InstructorLastName,
-- InstructorFirstName,
-- Department
create or alter procedure Process.LoadInstructorDepartment
as
begin
	set nocount on;
	declare @CurrentTime datetime2 = sysdatetime();

insert into Employee.InstructorDepartment(InstructorID, InstructorLastName, InstructorFirstName, Department)
	select distinct
		EI.InstructorID,
		substring(Instructor, 1,
			case when charindex(',', Instructor + ' ') - 1 < 1 then 0
			else charindex(',', Instructor + ' ') - 1
			end),
		substring(Instructor, charindex(',', Instructor + ' ') + 1, 30),
		substring([Course (hr, crd)], 1, 
			case when charindex(' ', [Course (hr, crd)] + ' ') - 1 < 1 then 0
			else charindex(' ', [Course (hr, crd)] + ' ') - 1
			end)
	from Uploadfile.CoursesSpring2019 as UF
		inner join Employee.Instructor as EI
			on
				substring(Instructor, 1,
					case when charindex(',', UF.Instructor + ' ') - 1 < 1 then 0
					else charindex(',', UF.Instructor + ' ') - 1
					end) = EI.InstructorLastName
				and
				substring(Instructor, charindex(',', UF.Instructor + ' ') + 1, 30) = EI.InstructorFirstName
	where 
			substring(Instructor, 1,
				case when charindex(',', Instructor + ' ') - 1 < 1 then 0
				else charindex(',', Instructor + ' ') - 1
				end) is not null
		and substring(Instructor, charindex(',', Instructor + ' ') + 1, 30) is not null
		and substring(Instructor, 1,
				case when charindex(',', Instructor + ' ') - 1 < 1 then 0
				else charindex(',', Instructor + ' ') - 1
				end) <> ''
		and substring(Instructor, charindex(',', Instructor + ' ') + 1, 30) <> ''
		and substring([Course (hr, crd)], 1, 
				case when charindex(' ', [Course (hr, crd)] + ' ') - 1 < 1 then 0
				else charindex(' ', [Course (hr, crd)] + ' ') - 1
				end) is not null
		and substring([Course (hr, crd)], 1, 
			case when charindex(' ', [Course (hr, crd)] + ' ') - 1 < 1 then 0
			else charindex(' ', [Course (hr, crd)] + ' ') - 1
			end) <> ''

		exec Process.usp_TrackWorkflow 
		@StartTime = @CurrentTime, 
		@WorkFlowDescription = 'Load InstructorDepartment Table', 
		@WorkFlowStepTableRowCount = @@RowCount
end;
GO

-- INSERT INTO TABLE Location.BuildingLocation
--Building
create or alter procedure Process.LoadBuildingLocation
as
begin
	set nocount on;
	declare @CurrentTime datetime2 = sysdatetime();

insert into Location.BuildingLocation(Building)
	select distinct
		substring([Location], 1, 
			case when charindex(' ', [Location] + ' ') - 1 < 1 then 0
			else charindex(' ', [Location] + ' ') - 1
			end)
	from Uploadfile.CoursesSpring2019
	where
			substring([Location], 1, 
				case when charindex(' ', [Location] + ' ') - 1 < 1 then 0
				else charindex(' ', [Location] + ' ') - 1
				end) is not null
		and substring([Location], 1, 
				case when charindex(' ', [Location] + ' ') - 1 < 1 then 0
				else charindex(' ', [Location] + ' ') - 1
				end) <> ''

		exec Process.usp_TrackWorkflow 
		@StartTime = @CurrentTime, 
		@WorkFlowDescription = 'Load BuildingLocation Table', 
		@WorkFlowStepTableRowCount = @@RowCount
end;
GO

-- INSERT INTO TABLE Location.RoomLocation
--Room,
--Building
create or alter procedure Process.LoadRoomLocation
as
begin
	set nocount on;
	declare @CurrentTime datetime2 = sysdatetime();

insert into Location.RoomLocation(Room, Building)
	select distinct
		substring([Location], charindex(' ', [Location] + ' ') + 1, 6),
		substring([Location], 1, 
			case when charindex(' ', [Location] + ' ') - 1 < 1 then 0
			else charindex(' ', [Location] + ' ') - 1
			end)
	from Uploadfile.CoursesSpring2019
	where
			substring([Location], charindex(' ', [Location] + ' ') + 1, 6) is not null
		and substring([Location], 1, 
				case when charindex(' ', [Location] + ' ') - 1 < 1 then 0
				else charindex(' ', [Location] + ' ') - 1
				end) is not null
		and substring([Location], charindex(' ', [Location] + ' ') + 1, 6) <> ''
		and substring([Location], 1, 
				case when charindex(' ', [Location] + ' ') - 1 < 1 then 0
				else charindex(' ', [Location] + ' ') - 1
				end) <> ''

		exec Process.usp_TrackWorkflow 
		@StartTime = @CurrentTime, 
		@WorkFlowDescription = 'Load RoomLocation Table', 
		@WorkFlowStepTableRowCount = @@RowCount
end;
GO

-- INSERT INTO TABLE Course.Semester
--Term,
--[Year]
create or alter procedure Process.LoadSemester
as
begin
	set nocount on;
	declare @CurrentTime datetime2 = sysdatetime();

insert into Course.Semester(Term, [Year])
	select distinct
		substring(Semester, 1, 6),
		cast(substring(Semester, charindex(' ', Semester + ' ') + 1, 4) as int)
	from Uploadfile.CoursesSpring2019
	where 
			substring(Semester, 1, 6) is not null
		and cast(substring(Semester, charindex(' ', Semester + ' ') + 1, 4) as int) is not null
		and substring(Semester, 1, 6) <> ''
		and cast(substring(Semester, charindex(' ', Semester + ' ') + 1, 4) as int) <> ''

		exec Process.usp_TrackWorkflow 
		@StartTime = @CurrentTime, 
		@WorkFlowDescription = 'Load Semester Table', 
		@WorkFlowStepTableRowCount = @@RowCount
end;
GO

-- INSERT INTO TABLE Course.ModeOfInstruction
--Mode
create or alter procedure Process.LoadModeOfInstruction
as
begin
	set nocount on;
	declare @CurrentTime datetime2 = sysdatetime();

insert into Course.ModeOfInstruction(Mode)
	select distinct
		[Mode of Instruction]
	from Uploadfile.CoursesSpring2019
	where
			[Mode of Instruction] is not null
		and [Mode of Instruction] <> ''

		exec Process.usp_TrackWorkflow 
		@StartTime = @CurrentTime, 
		@WorkFlowDescription = 'Load ModeOfInstruction Table', 
		@WorkFlowStepTableRowCount = @@RowCount
end;
GO

-- INSERT INTO TABLE Course.Course
--CourseNumber,
--CourseDescription,
--Hours,
--Credits,
--Department
create or alter procedure Process.LoadCourse
as
begin
	set nocount on;
	declare @CurrentTime datetime2 = sysdatetime();

insert into Course.Course(CourseNumber, CourseDescription, [Hours], Credits, Department)
	select distinct
		substring(
				[Course (hr, crd)], 
				charindex(' ', [Course (hr, crd)]) + 1,
				case when charindex(' ', [Course (hr, crd)]) = 0 then 0
				else charindex(' ', [Course (hr, crd)], charindex(' ', [Course (hr, crd)]) + 1) - charindex(' ', [Course (hr, crd)])
				end),
		[Description],
		substring(
				[Course (hr, crd)], 
				charindex('(', [Course (hr, crd)]) + 1,
				case when charindex('(', [Course (hr, crd)]) = 0 then 0
				else charindex(',', [Course (hr, crd)]) - charindex('(', [Course (hr, crd)]) - 1
				end),
		substring(
				[Course (hr, crd)], 
				charindex(',', [Course (hr, crd)]) + 2,
				case when charindex(',', [Course (hr, crd)]) = 0 then 0
				else charindex(')', [Course (hr, crd)]) - charindex(' ', [Course (hr, crd)],charindex(',', [Course (hr, crd)])) - 1 
				end),
		substring([Course (hr, crd)], 1, charindex(' ', [Course (hr, crd)] + ' ') - 1)
	from Uploadfile.CoursesSpring2019
	where 
			substring(
				[Course (hr, crd)], 
				charindex(' ', [Course (hr, crd)]) + 1,
				case when charindex(' ', [Course (hr, crd)]) = 0 then 0
				else charindex(' ', [Course (hr, crd)], charindex(' ', [Course (hr, crd)]) + 1) - charindex(' ', [Course (hr, crd)])
				end) is not null
		and [Description] is not null
		and substring(
				[Course (hr, crd)], 
				charindex('(', [Course (hr, crd)]) + 1,
				case when charindex('(', [Course (hr, crd)]) = 0 then 0
				else charindex(',', [Course (hr, crd)]) - charindex('(', [Course (hr, crd)]) - 1
				end) is not null
		and substring(
				[Course (hr, crd)], 
				charindex(',', [Course (hr, crd)]) + 2,
				case when charindex(',', [Course (hr, crd)]) = 0 then 0
				else charindex(')', [Course (hr, crd)]) - charindex(' ', [Course (hr, crd)],charindex(',', [Course (hr, crd)])) - 1 
				end) is not null
		and substring([Course (hr, crd)], 1, charindex(' ', [Course (hr, crd)] + ' ') - 1) is not null
		and substring(
				[Course (hr, crd)], 
				charindex(' ', [Course (hr, crd)]) + 1,
				case when charindex(' ', [Course (hr, crd)]) = 0 then 0
				else charindex(' ', [Course (hr, crd)], charindex(' ', [Course (hr, crd)]) + 1) - charindex(' ', [Course (hr, crd)])
				end) <> ''
		and [Description] <> ''
		and substring(
				[Course (hr, crd)], 
				charindex('(', [Course (hr, crd)]) + 1,
				case when charindex('(', [Course (hr, crd)]) = 0 then 0
				else charindex(',', [Course (hr, crd)]) - charindex('(', [Course (hr, crd)]) - 1
				end) <> ''
		and substring(
				[Course (hr, crd)], 
				charindex(',', [Course (hr, crd)]) + 2,
				case when charindex(',', [Course (hr, crd)]) = 0 then 0
				else charindex(')', [Course (hr, crd)]) - charindex(' ', [Course (hr, crd)],charindex(',', [Course (hr, crd)])) - 1 
				end) <> ''
		and substring([Course (hr, crd)], 1, charindex(' ', [Course (hr, crd)] + ' ') - 1) <> ''

		exec Process.usp_TrackWorkflow 
		@StartTime = @CurrentTime, 
		@WorkFlowDescription = 'Load Course Table', 
		@WorkFlowStepTableRowCount = @@RowCount
end;
GO

-- INSERT INTO TABLE Course.Class
--ClassCode,
--CourseNumber,
--Section,
--Term,
--Days,
--[Year],
--[Time],
--Enrollment,
--Limit
--Department,
--InstructorID,
--InstructorLastName,
--InstructorFirstName,
--Room,
--Building,
--Mode
create or alter procedure Process.LoadClass
as
begin
	set nocount on;
	declare @CurrentTime datetime2 = sysdatetime();

insert into Course.Class(
				ClassCode, 
				CourseNumber, 
				Section, 
				Term, 
				[Days], 
				[Year], 
				[Time], 
				Enrollment, 
				Limit,
				Department,
				InstructorID,
				InstructorLastName,
				InstructorFirstName,
				Room,
				Building,
				Mode
				)
	select
		cast(Code as int),
		substring(
				[Course (hr, crd)], 
				charindex(' ', [Course (hr, crd)]) + 1,
				case when charindex(' ', [Course (hr, crd)]) = 0 then 0
				else charindex(' ', [Course (hr, crd)], charindex(' ', [Course (hr, crd)]) + 1) - charindex(' ', [Course (hr, crd)])
				end),
		case when len(Sec) = 1 then right('00' + ISNULL(Sec,''), 2)
			else Sec 
			end,
		substring(Semester, 1, 6),
		[Day],
		cast(substring(Semester, charindex(' ', Semester + ' ') + 1, 4) as int),
		[Time],
		cast(Enrolled as int),
		cast(Limit as int),
		substring([Course (hr, crd)], 1, 
			case when charindex(' ', [Course (hr, crd)] + ' ') - 1 < 1 then 0
			else charindex(' ', [Course (hr, crd)] + ' ') - 1
			end),
		EI.InstructorID,
		substring(Instructor, 1,
			case when charindex(',', Instructor + ' ') - 1 < 1 then 0
			else charindex(',', Instructor + ' ') - 1
			end),
		substring(Instructor, charindex(',', Instructor + ' ') + 1, 30),
		substring([Location], charindex(' ', [Location] + ' ') + 1, 6),
		substring([Location], 1, 
			case when charindex(' ', [Location] + ' ') - 1 < 1 then 0
			else charindex(' ', [Location] + ' ') - 1
			end),
		[Mode of Instruction]
	from Uploadfile.CoursesSpring2019 as UF
		inner join Employee.Instructor as EI
			on
				substring(Instructor, 1,
					case when charindex(',', UF.Instructor + ' ') - 1 < 1 then 0
					else charindex(',', UF.Instructor + ' ') - 1
					end) = EI.InstructorLastName
				and
				substring(Instructor, charindex(',', UF.Instructor + ' ') + 1, 30) = EI.InstructorFirstName
	where 
			cast(Code as int) is not null
		and substring(
				[Course (hr, crd)], 
				charindex(' ', [Course (hr, crd)]) + 1,
				case when charindex(' ', [Course (hr, crd)]) = 0 then 0
				else charindex(' ', [Course (hr, crd)], charindex(' ', [Course (hr, crd)]) + 1) - charindex(' ', [Course (hr, crd)])
				end) is not null
		and substring(Semester, 1, 6) is not null
		and cast(substring(Semester, charindex(' ', Semester + ' ') + 1, 4) as int) is not null
		and cast(Enrolled as int) is not null
		and cast(Limit as int) is not null
		and substring([Course (hr, crd)], 1, 
			case when charindex(' ', [Course (hr, crd)] + ' ') - 1 < 1 then 0
			else charindex(' ', [Course (hr, crd)] + ' ') - 1
			end) is not null
		and substring([Location], charindex(' ', [Location] + ' ') + 1, 6) is not null
		and substring([Location], 1, 
			case when charindex(' ', [Location] + ' ') - 1 < 1 then 0
			else charindex(' ', [Location] + ' ') - 1
			end) is not null
		and [Mode of Instruction] is not null

		and cast(Code as int) <> ''
		and substring(
				[Course (hr, crd)], 
				charindex(' ', [Course (hr, crd)]) + 1,
				case when charindex(' ', [Course (hr, crd)]) = 0 then 0
				else charindex(' ', [Course (hr, crd)], charindex(' ', [Course (hr, crd)]) + 1) - charindex(' ', [Course (hr, crd)])
				end) <> ''
		and substring(Semester, 1, 6) <> ''
		and cast(substring(Semester, charindex(' ', Semester + ' ') + 1, 4) as int) <> ''
		and cast(Enrolled as int) <> ''
		and cast(Limit as int) <> ''
		and substring([Course (hr, crd)], 1, 
			case when charindex(' ', [Course (hr, crd)] + ' ') - 1 < 1 then 0
			else charindex(' ', [Course (hr, crd)] + ' ') - 1
			end) <> ''
		and substring([Location], charindex(' ', [Location] + ' ') + 1, 6) <> ''
		and substring([Location], 1, 
			case when charindex(' ', [Location] + ' ') - 1 < 1 then 0
			else charindex(' ', [Location] + ' ') - 1
			end) <> ''
		and [Mode of Instruction] <> ''

		exec Process.usp_TrackWorkflow 
		@StartTime = @CurrentTime, 
		@WorkFlowDescription = 'Load Class Table', 
		@WorkFlowStepTableRowCount = @@RowCount
end;
GO

-- ===============================================================================
-- ============================== ADD 7 PROJECT COLUMNS ==========================
-- ===============================================================================
ALTER TABLE Process.WorkflowSteps
ADD
 [ClassTime]         char(5)	  NOT NULL DEFAULT '' ,
 [LastName]          varchar(30)  NOT NULL DEFAULT 'Ma' ,
 [FirstName]         varchar(30)  NOT NULL DEFAULT 'Phillip' ,
 [QmailEmailAddress] varchar(30)  NOT NULL DEFAULT '' ,
 [DateAdded]         datetime2(7) NOT NULL DEFAULT sysdatetime() ,
 [DateOfLastUpdate]  datetime2(7) NOT NULL DEFAULT sysdatetime() ,
 [AuthorizedUserId]  int		  NOT NULL DEFAULT 90
;

ALTER TABLE Employee.Instructor
ADD
 [ClassTime]         char(5)	  NOT NULL DEFAULT '' ,
 [LastName]          varchar(30)  NOT NULL DEFAULT 'Ma' ,
 [FirstName]         varchar(30)  NOT NULL DEFAULT 'Phillip' ,
 [QmailEmailAddress] varchar(30)  NOT NULL DEFAULT '' ,
 [DateAdded]         datetime2(7) NOT NULL DEFAULT sysdatetime() ,
 [DateOfLastUpdate]  datetime2(7) NOT NULL DEFAULT sysdatetime() ,
 [AuthorizedUserId]  int		  NOT NULL DEFAULT 90
;

ALTER TABLE Employee.Department
ADD
 [ClassTime]         char(5)	  NOT NULL DEFAULT '' ,
 [LastName]          varchar(30)  NOT NULL DEFAULT 'Ma' ,
 [FirstName]         varchar(30)  NOT NULL DEFAULT 'Phillip' ,
 [QmailEmailAddress] varchar(30)  NOT NULL DEFAULT '' ,
 [DateAdded]         datetime2(7) NOT NULL DEFAULT sysdatetime() ,
 [DateOfLastUpdate]  datetime2(7) NOT NULL DEFAULT sysdatetime() ,
 [AuthorizedUserId]  int		  NOT NULL DEFAULT 90
 ;

ALTER TABLE Employee.InstructorDepartment
ADD
 [ClassTime]         char(5)	  NOT NULL DEFAULT '' ,
 [LastName]          varchar(30)  NOT NULL DEFAULT 'Ma' ,
 [FirstName]         varchar(30)  NOT NULL DEFAULT 'Phillip' ,
 [QmailEmailAddress] varchar(30)  NOT NULL DEFAULT '' ,
 [DateAdded]         datetime2(7) NOT NULL DEFAULT sysdatetime() ,
 [DateOfLastUpdate]  datetime2(7) NOT NULL DEFAULT sysdatetime() ,
 [AuthorizedUserId]  int		  NOT NULL DEFAULT 90
 ;
 
ALTER TABLE Location.BuildingLocation
ADD
 [ClassTime]         char(5)	  NOT NULL DEFAULT '' ,
 [LastName]          varchar(30)  NOT NULL DEFAULT 'Ma' ,
 [FirstName]         varchar(30)  NOT NULL DEFAULT 'Phillip' ,
 [QmailEmailAddress] varchar(30)  NOT NULL DEFAULT '' ,
 [DateAdded]         datetime2(7) NOT NULL DEFAULT sysdatetime() ,
 [DateOfLastUpdate]  datetime2(7) NOT NULL DEFAULT sysdatetime() ,
 [AuthorizedUserId]  int		  NOT NULL DEFAULT 90
;

ALTER TABLE Location.RoomLocation
ADD
 [ClassTime]         char(5)	  NOT NULL DEFAULT '' ,
 [LastName]          varchar(30)  NOT NULL DEFAULT 'Ma' ,
 [FirstName]         varchar(30)  NOT NULL DEFAULT 'Phillip' ,
 [QmailEmailAddress] varchar(30)  NOT NULL DEFAULT '' ,
 [DateAdded]         datetime2(7) NOT NULL DEFAULT sysdatetime() ,
 [DateOfLastUpdate]  datetime2(7) NOT NULL DEFAULT sysdatetime() ,
 [AuthorizedUserId]  int		  NOT NULL DEFAULT 90
;

ALTER TABLE Course.Semester
ADD
 [ClassTime]         char(5)	  NOT NULL DEFAULT '' ,
 [LastName]          varchar(30)  NOT NULL DEFAULT 'Ma' ,
 [FirstName]         varchar(30)  NOT NULL DEFAULT 'Phillip' ,
 [QmailEmailAddress] varchar(30)  NOT NULL DEFAULT '' ,
 [DateAdded]         datetime2(7) NOT NULL DEFAULT sysdatetime() ,
 [DateOfLastUpdate]  datetime2(7) NOT NULL DEFAULT sysdatetime() ,
 [AuthorizedUserId]  int		  NOT NULL DEFAULT 90
;

ALTER TABLE Course.ModeOfInstruction
ADD
 [ClassTime]         char(5)	  NOT NULL DEFAULT '' ,
 [LastName]          varchar(30)  NOT NULL DEFAULT 'Ma' ,
 [FirstName]         varchar(30)  NOT NULL DEFAULT 'Phillip' ,
 [QmailEmailAddress] varchar(30)  NOT NULL DEFAULT '' ,
 [DateAdded]         datetime2(7) NOT NULL DEFAULT sysdatetime() ,
 [DateOfLastUpdate]  datetime2(7) NOT NULL DEFAULT sysdatetime() ,
 [AuthorizedUserId]  int		  NOT NULL DEFAULT 90
;

ALTER TABLE Course.Course
ADD
 [ClassTime]         char(5)	  NOT NULL DEFAULT '' ,
 [LastName]          varchar(30)  NOT NULL DEFAULT 'Ma' ,
 [FirstName]         varchar(30)  NOT NULL DEFAULT 'Phillip' ,
 [QmailEmailAddress] varchar(30)  NOT NULL DEFAULT '' ,
 [DateAdded]         datetime2(7) NOT NULL DEFAULT sysdatetime() ,
 [DateOfLastUpdate]  datetime2(7) NOT NULL DEFAULT sysdatetime() ,
 [AuthorizedUserId]  int		  NOT NULL DEFAULT 90
;

ALTER TABLE Course.Class
ADD
 [ClassTime]         char(5)	  NOT NULL DEFAULT '' ,
 [LastName]          varchar(30)  NOT NULL DEFAULT 'Ma' ,
 [FirstName]         varchar(30)  NOT NULL DEFAULT 'Phillip' ,
 [QmailEmailAddress] varchar(30)  NOT NULL DEFAULT '' ,
 [DateAdded]         datetime2(7) NOT NULL DEFAULT sysdatetime() ,
 [DateOfLastUpdate]  datetime2(7) NOT NULL DEFAULT sysdatetime() ,
 [AuthorizedUserId]  int		  NOT NULL DEFAULT 90
;
GO

-- ===============================================================================
-- ============================ CREATE ERD =======================================
-- ===============================================================================

-- STORED PROCEDURE Process.LoadERD
create or alter procedure Process.LoadERD
as
begin
	declare @CurrentTime datetime2 = SYSDATETIME();

	-- Drop foreign keys before truncation
	exec Process.DropForeignKeys

	-- Truncate star schema data
	exec Process.TruncateTables

    -- Load the ERD
	exec Process.LoadInstructor
	exec Process.LoadDepartment
	exec Process.LoadInstructorDepartment
	exec Process.LoadBuildingLocation
	exec Process.LoadRoomLocation
	exec Process.LoadSemester
	exec Process.LoadModeOfInstruction
	exec Process.LoadCourse
	exec Process.LoadClass

	-- Recreate foreign keys after schema loading
	exec Process.AddForeignKeys

	exec Process.usp_TrackWorkFlow 
		@StartTime = @CurrentTime, 
		@WorkFlowDescription = 'Load ERD', 
		@WorkFlowStepTableRowCount = @@RowCount
end;
GO

-- ===============================================================================
-- =========================== TEST THE QUERY ====================================
-- ===============================================================================
truncate table Process.WorkflowSteps
exec Process.LoadERD
/*
exec Process.usp_ShowWorkflowSteps
exec Process.usp_TotalExecutionTime
--CHECK TABLES
SELECT * FROM Employee.Instructor

SELECT * FROM Employee.Department

SELECT * FROM Employee.InstructorDepartment

SELECT * FROM [Location].BuildingLocation

SELECT * FROM [Location].RoomLocation

SELECT * FROM Course.Semester

SELECT * FROM Course.ModeOfInstruction

SELECT * FROM Course.Course

SELECT * FROM Course.Class

*/