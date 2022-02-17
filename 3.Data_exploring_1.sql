######################################################################
-- THE RELATIONSHIP BETWEEN TEST COMPLETION AND TEST CIRCUMSTANCES
######################################################################
-- Skills: Joins, CTE's, Aggregate Functions, Window Function, Logical Functions, Subqueries

################################################################
-- 1. ON WHICH DAY THE DOGNITION USERS CONDUCT THE MOST TESTS

# NUMBER OF COMPLETED TEST EVERY DAY

SELECT  
    CASE dayofweek(Created_at)
    WHEN 1 THEN 'Sunday'
    WHEN 2 THEN 'Monday'
    WHEN 3 THEN 'Tuesday'
    WHEN 4 THEN 'Wednesday'
    WHEN 5 THEN 'Thursday'
    WHEN 6 THEN 'Friday'
    WHEN 7 THEN 'Saturday'
    END AS Weekday,
    count(Created_at) as NumTest
FROM complete_tests
GROUP BY Weekday
ORDER BY NumTest desc;

# IF THE EXLCLUDE FLAGS IN USERS AND DOGS TABLE EQUAL 1, HOW THE RESULTS CHANGE?
# REMIND THAT EXCLUDE VALUE OF '1' MEANS THAT THE ENTRIES IS EXCLUDED DUE TO THE FACTORS MONITORED BY THE DOGNITION TEAM

SELECT  
    CASE dayofweek(c.Created_at)
    WHEN 1 THEN 'Sunday'
    WHEN 2 THEN 'Monday'
    WHEN 3 THEN 'Tuesday'
    WHEN 4 THEN 'Wednesday'
    WHEN 5 THEN 'Thursday'
    WHEN 6 THEN 'Friday'
    WHEN 7 THEN 'Saturday'
    END AS Weekday,
    COUNT(c.Created_at) as NumTest
FROM (SELECT DISTINCT d.DogID as dDogID
		FROM dogs d JOIN users u ON d.UserID = u.UserID
        WHERE (d.Exclude IS NULL or d.Exclude = 0) AND (u.Exclude IS NULL or u.Exclude = 0))
        AS new_dogs
JOIN complete_tests c ON c.DogID = new_dogs.dDogID
GROUP BY Weekday
ORDER BY NumTest DESC;

# NOW BREAK DOWN THE NUMBER OF COMPLETED TEST INTO EACH YEAR TO OBSERVE THE TREND.

SELECT  YEAR(c.Created_at) as Year,
    CASE dayofweek(c.Created_at)
    WHEN 1 THEN 'Sunday'
    WHEN 2 THEN 'Monday'
    WHEN 3 THEN 'Tuesday'
    WHEN 4 THEN 'Wednesday'
    WHEN 5 THEN 'Thursday'
    WHEN 6 THEN 'Friday'
    WHEN 7 THEN 'Saturday'
    END AS Weekday,
    COUNT(c.Created_at) as NumTest
FROM (SELECT DISTINCT d.DogID as dDogID
		FROM dogs d JOIN users u ON d.UserID = u.UserID
        WHERE (d.Exclude IS NULL or d.Exclude = 0) AND (u.Exclude IS NULL or u.Exclude = 0))
        AS new_dogs
JOIN complete_tests c ON c.DogID = new_dogs.dDogID
GROUP BY Year, Weekday
ORDER BY Year, NumTest DESC;


################################################################
-- 2. WHICH COUNTRIES AND STATES HAVE THE MOST DOGNITION USERS

# TOP 10 COUNTRIES HAVE THE MOST USERS

SELECT new_dogs.Country AS Country, COUNT(DISTINCT new_dogs.UserID) AS NumUsers
FROM complete_tests c 
JOIN (SELECT DISTINCT DogID, u.UserID, u.Country
		FROM dogs d JOIN users u ON d.UserID = u.UserID
		WHERE (u.exclude IS NULL OR u.exclude = 0) AND (d.exclude IS NULL OR d.exclude = 0) )
        AS new_dogs
ON c.DogID = new_dogs.DogID
GROUP BY Country
ORDER BY NumUsers DESC
LIMIT 10;


# FOCUS ON THE UNITED STATES, TOP 10 STATES HAVE THE MOST USERS WITH THEIR RANKING AND THEIR PERCENTAGES

WITH US_Users(Country, State, NumUsers)
AS (SELECT new_dogs.Country, new_dogs.State AS State, COUNT(DISTINCT new_dogs.UserID) AS NumUsers
	FROM complete_tests c 
	JOIN (SELECT DISTINCT DogID, u.UserID, u.Country, u.State
			FROM dogs d JOIN users u ON d.UserID = u.UserID
			WHERE (u.exclude IS NULL OR u.exclude = 0) AND (d.exclude IS NULL OR d.exclude = 0) )
			AS new_dogs
	ON c.DogID = new_dogs.DogID
	WHERE new_dogs.Country = 'US'
	GROUP BY State
)
SELECT DENSE_RANK() OVER (PARTITION BY Country ORDER BY NumUsers DESC) AS Ranking,
		State, Concat(ROUND(NumUsers * 100 / (SELECT SUM(NumUsers) AS s FROM US_Users), 2), '%') AS Percent_NumUsers		 
FROM US_Users
LIMIT 10;

# BECAUSE OF THE DIFFERENT TIME ZONES, THE WEEKDAYS EXTRACTED BEFORE MAY NOT ACCURATELY REFLECTED THE WEEKENDS IN THE LOCAL TIME.
# CONTINUE FOCUSING ON THE US USERS, ADJUST THE TIME ZONES BY SUBTRACTING 6 HOURS, ON THE WHICH DAYS THE USERS COMPLETE THE MOST TESTS.
# (EXCLUDE HAWAII (HI) AND ALASKA (AK))

SELECT  YEAR(c.Created_at) as Year,
    CASE dayofweek(DATE_SUB(c.Created_at, INTERVAL 6 HOUR))
    WHEN 1 THEN 'Sunday'
    WHEN 2 THEN 'Monday'
    WHEN 3 THEN 'Tuesday'
    WHEN 4 THEN 'Wednesday'
    WHEN 5 THEN 'Thursday'
    WHEN 6 THEN 'Friday'
    WHEN 7 THEN 'Saturday'
    END AS Weekday,
    COUNT(c.Created_at) as NumTest
FROM (SELECT DISTINCT d.DogID as dDogID 
		FROM dogs d JOIN users u ON d.UserID = u.UserID
        WHERE (d.Exclude IS NULL or d.Exclude = 0) AND (u.Exclude IS NULL or u.Exclude = 0) AND
				u.Country = 'US' AND u.State NOT IN ('HI', 'AK'))
        AS new_dogs
JOIN complete_tests c ON c.DogID = new_dogs.dDogID
GROUP BY Year, Weekday
ORDER BY Year, NumTest DESC;

