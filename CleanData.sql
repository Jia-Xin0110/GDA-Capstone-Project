-- Focus on metrics that contain both periods of data
-- They are dailyActivities, HourlyCalories, HourlySteps

--dailyActivities
CREATE VIEW dailyActivity AS
(
	SELECT * FROM P1DailyActivity UNION --don't include duplicates
	SELECT * FROM P2DailyActivity 
) 
--Generate all column names in a table
SELECT * INTO DailyAct_ColName
FROM(
SELECT
     name
FROM
     sys.columns
WHERE
     object_id = OBJECT_ID('dailyActivity'))AS colname

SELECT * FROM DailyAct_ColName

--Check duplicates
SELECT Id
FROM dailyActivity
GROUP BY Id, ActivityDate
HAVING COUNT(Id) > 1 --24 Ids have two different records from two tables on 2016-04-12

--By assuming first lesser steps record is an incomplete record, we create a cleaned daily activity table
SELECT * 
INTO CleanedDailyActivities
FROM 
(
	SELECT * FROM P1DailyActivity
	WHERE NOT (
	ActivityDate  = '4/12/2016'
	AND Id IN
	(
	SELECT Id
	FROM dailyActivity
	GROUP BY Id, ActivityDate
	HAVING COUNT(Id) > 1 
	))
	UNION ALL
	SELECT * FROM P2DailyActivity 
) AS CleanedDailyActivities

DROP TABLE CleanedDailyActivities

--Check duplicate again
SELECT Id, COUNT(DISTINCT(ActivityDate)),COUNT(ActivityDate)
FROM CleanedDailyActivities
GROUP BY ID

SELECT Id
FROM CleanedDailyActivities
GROUP BY Id, ActivityDate
HAVING COUNT(Id) > 1  --No more duplicates


--HourlySteps
CREATE VIEW hourlystep AS
(
	SELECT * FROM P1HourlySteps UNION --don't include duplicates
	SELECT * FROM P2HourlySteps
)
-- Check duplicate
SELECT Id
FROM hourlystep
GROUP BY Id, ActivityHour
HAVING COUNT(Id) > 1 
GO
SELECT Id, COUNT(DISTINCT(ActivityHour)), COUNT(ActivityHour)
FROM hourlystep
GROUP BY ID
GO

--Create new table by having two period merged table
SELECT * INTO CleanedHourlySteps
FROM
(
	SELECT * FROM P1HourlySteps UNION 
	SELECT * FROM P2HourlySteps
) AS cleanedhourlysteps

SELECT * FROM CleanedHourlySteps

-- Check min and max value from steptotal column
SELECT MIN(StepTotal) AS minStep, MAX(StepTotal) AS maxStep
FROM CleanedHourlySteps --reasonable


--HourlyCalories
CREATE VIEW hourlycalories AS
(
	SELECT * FROM P1HourlyCalories UNION --don't include duplicates
	SELECT * FROM P2HourlyCalories
)
-- Check duplicate
SELECT Id
FROM hourlycalories
GROUP BY Id, ActivityHour
HAVING COUNT(Id) > 1 
GO
SELECT Id, COUNT(DISTINCT(ActivityHour)), COUNT(ActivityHour)
FROM hourlycalories
GROUP BY ID
GO

--Create new table by having two period merged table
SELECT * INTO CleanedHourlyCalories
FROM
(
	SELECT * FROM P1HourlyCalories UNION 
	SELECT * FROM P2HourlyCalories
) AS cleanedhourlycalories

SELECT * FROM CleanedHourlyCalories

-- Check min and max value from calories column
SELECT MIN(Calories) AS minCalories, MAX(Calories) AS maxCalories
FROM CleanedHourlyCalories --reasonable

-- Weight
CREATE VIEW weightInfo AS
(
	SELECT * FROM P1Weight UNION --don't include duplicates
	SELECT * FROM P2Weight
) 
SELECT * FROM weightInfo
ORDER BY Id, Date DESC

SELECT COUNT(DISTINCT(Id))
FROM weightInfo --Only 13 user report their weight

SELECT Id
FROM weightInfo
GROUP BY Id, Date
HAVING COUNT(Id) > 1 
GO
SELECT Id, COUNT(DISTINCT(Date)), COUNT(Date)
FROM weightInfo
GROUP BY ID
GO
-- Check min and max value for weight column
SELECT MIN(WeightKg) AS minKg, MAX(WeightKg) AS maxKg, min(BMI) AS minBMI, MAX(BMI) AS maxBMI
FROM weightInfo--reasonable

-- I am not focusing in Fat, isManualReport, LogId due to insufficient information from these columns. We will not include them into cleaned table
SELECT * INTO CleanedWeight
FROM
(
	SELECT Id, Date, WeightKg, BMI FROM P1Weight UNION 
	SELECT Id, Date, WeightKg, BMI FROM P2Weight
) AS cleanedweight
SELECT * FROM CleanedWeight


-- Determine the number of user ID (sample size),  for each metric
SELECT COUNT(DISTINCT(Id)) AS UserCount
FROM CleanedDailyActivities

SELECT COUNT(DISTINCT(Id)) AS UserCount
FROM CleanedHourlyCalories

SELECT COUNT(DISTINCT(Id)) AS UserCount
FROM CleanedHourlySteps
-- The sample size is 35 for all these three metrics.
SELECT COUNT(DISTINCT(Id)) AS UserCount
FROM CleanedWeight
-- Only 13 user recorded their weight


