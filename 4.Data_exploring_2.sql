#################################################################
-- RELATIONSHIP BETWEEN DOG CHARACTERISTICS AND TEST COMPETION
#################################################################
-- Skills: Joins, Logical Functions, Window Functions, CTE's, Temp Tables, Subqueries, Aggregate Functions

#################################################################
-- 1. DOG DIMENSIONS AND NUMBER OF TESTS COMPLETED
# Remind that Dog dimensions represent the distinct combinations of characteristics assessed by Dognition test.

# NUMBER OF TESTS COMPLETED BY EACH UNIQUE DOG. NOTE: DogID IN DOGS TABLE IS NOT DUPLICATED AS WE CHECKED BEFORE.

SELECT d.DogID as DogID, d.Dimension, COUNT(c.Created_at) as NumTests
FROM dogs d JOIN complete_tests c ON d.DogID = c.DogID
GROUP BY DogID
LIMIT 100;
#--------------------------------------------------------------


# NUMBER OF TESTS COMPLETED BY UNIQUE DOGS IN EACH PERSONALITY DIMENSION
SELECT DISTINCT Dimension, AVG(NumTests) OVER (PARTITION BY Dimension) AS AvgTest
FROM (SELECT d.DogID as DogID, d.Dimension, COUNT(c.Created_at) AS NumTests
	FROM dogs d JOIN complete_tests c ON d.DogID = c.DogID
    WHERE d.dimension IS NOT NULL
	GROUP BY d.DogID) AS dimension_test
ORDER BY AvgTest DESC;

# ATERNATIVE APPROACH BY CTE'S

WITH dimension_test(DogID, Dimension, NumTests) 
AS (SELECT d.DogID as DogID, d.Dimension, COUNT(c.Created_at) AS NumTests
	FROM dogs d JOIN complete_tests c ON d.DogID = c.DogID
    WHERE d.dimension IS NOT NULL
	GROUP BY d.DogID)
SELECT DISTINCT Dimension, AVG(NumTests) OVER (PARTITION BY Dimension) AS AvgTest
FROM dimension_test;
#---------------------------------------------------

# THE EXCLUDE FLAGS OF '1' IN  dogs TABLE, NUMBER OF TESTS COMPLETED BY UNIQUE DOGS IN EACH PERSONALITY DIMENSION

SELECT DISTINCT Dimension, AVG(NumTests) AS AvgTest, COUNT(DISTINCT DogID) AS NumDogs
FROM (SELECT d.DogID as DogID, d.Dimension, COUNT(c.Created_at) AS NumTests
	FROM dogs d JOIN complete_tests c ON d.DogID = c.DogID
    WHERE d.dimension IS NOT NULL AND (d.Exclude IS NULL or d.Exclude = 0)
	GROUP BY d.DogID) AS dimension_test
GROUP BY Dimension
ORDER BY AvgTest DESC;


#####################################################################################
-- 2. DOGS BREED AND NUMBER OF TESTS COMPLETED

# FROM NOW WE CREATE A TEMPORARY TABLE TO EXTRACT ONLY NECESARY FIELD IN DOGS TABLE

DROP TABLE IF EXISTS breed_test;
CREATE TEMPORARY TABLE breed_test(
DogID VARCHAR(50),
Dimension VARCHAR(20),
Exclude TINYINT,
Breed_type VARCHAR(50),
Breed_group VARCHAR(50),
Dog_fixed BOOLEAN,
NumTest INT
);

INSERT INTO breed_test 
SELECT d.DogID, d.Dimension, d.Exclude, d.Breed_type, d.Breed_group, Dog_fixed,
		COUNT(c.Created_at) as NumTest
FROM dogs d JOIN complete_tests c ON d.DogID = c.DogID
WHERE d.Exclude IS NULL OR d.Exclude = 0
GROUP BY d.DogID;

#-----------------------------------------------------

# BREED_GROUP AND NUMBER OF COMPLETION TESTS

SELECT Breed_group, AVG(NumTest) AS AvgTest, COUNT(DISTINCT DogID) as NumDogs
FROM breed_test
WHERE Breed_group IS NOT NULL
GROUP BY Breed_group;

# BREED_TYPE AND NUMBER OF COMPLETION TESTS

SELECT Breed_type, AVG(NumTest) AS AvgTest, COUNT(DISTINCT DogID) as NumDogs
FROM breed_test
WHERE Breed_type IS NOT NULL
GROUP BY Breed_type;

#-------------------------------------------------------------------

# BREED_TYPE WITH DOG NEUTERED AND NUMBER OF COMPLETION TESTS
# IN THIS CASE, BREED_TYPE ONLY INCLUDED 'PURE BREED' AND NOT 'NOT PURE BREED'

SELECT IF(Breed_type = 'Pure Breed', 'Pure Breed', 'Not Pure Breed') AS Pure_breed, 
		CASE Dog_fixed
        WHEN 1 THEN 'Neutered'
        WHEN 0 THEN 'Not Neutered'
        ELSE 'None'
        END AS Neutered,
        AVG(NumTest) AS AvgTest, COUNT(DISTINCT DogID) as NumDogs
FROM breed_test
WHERE Breed_type IS NOT NULL
GROUP BY Pure_breed, Neutered;

        
#################################################################################
-- AVERAGE TIME TO COMPLETE EACH TEST

WITH test_time(DogID, Test_name, First_test, Last_test)
AS (SELECT d.DogID, Test_name, MIN(c.Created_at) as First_test, MAX(c.Created_at) AS Last_test
	FROM dogs d JOIN complete_tests c ON d.DogID = c.DogID
	GROUP BY d.DogID)
SELECT Test_name, AVG(TIMESTAMPDIFF(DAY, First_test, Last_test)) AS Day_AvgDuration
FROM test_time
GROUP BY Test_name;


