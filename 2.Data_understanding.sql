############################################################################################
-- DATA UNDERSTANDING
############################################################################################

# ALL BREED_TYPE, BREED_GROUP AND CHARACTERS OF DOGS
SELECT DISTINCT Breed_type
FROM dogs;
SELECT DISTINCT Breed_group
FROM dogs;
SELECT DISTINCT Dimension
FROM dogs;
# There are NULL variables in Breed_group and in Dimension field

#--------------------------------------------------------------------------

# CHECKING WHETHER THERE ARE DUPLICATES USER ACCOUNTS IN DOGS AND USERS TABLES
SELECT DISTINCT UserID, COUNT(UserID) as NumUsers
FROM users
GROUP BY UserID
ORDER BY NumUsers DESC
LIMIT 20;

SELECT DISTINCT UserID, COUNT(UserID) as NumUsers
FROM dogs
GROUP BY UserID
ORDER BY NumUsers DESC
LIMIT 20;

SELECT DISTINCT DogID, COUNT(DogID) as NumDogs
FROM dogs
GROUP BY DogID
ORDER BY NumDogs DESC
LIMIT 20;

#----------------------------------------------------------------------------


# COUNTRIES AND STATES IN WHICH USERS ATTENDING THE TESTS
SELECT Country, State, COUNT(DISTINCT UserID) as NumUsers
FROM users
GROUP BY Country, State
ORDER BY NumUsers DESC;

#----------------------------------------------------------------------------


# US AND NON-US CUSTOMERS
SELECT IF(Country = 'US', 'US', IF(Country = 'N/A', 'Not Application', 'Non-US')) as User_residence, COUNT(UserID) as NumUsers
FROM (SELECT DISTINCT UserID, Country
		FROM users
		WHERE Country IS NOT NULL) AS DistinctUsers
GROUP BY User_residence
ORDER BY NumUsers;

#--------------------------------------------------------------------------------


# NUMBER OF UNIQUE DOGS DOING EACH TESTS
SELECT c.Test_name, COUNT(c.Created_at) as NumTests
FROM dogs d JOIN complete_tests c ON d.DogID = c.DogID
WHERE (d.Exclude IS NULL or d.Exclude = 0) AND c.Test_name IS NOT NULL
GROUP BY c.Test_name
ORDER BY NumTests DESC;





