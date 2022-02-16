
----------- SOME TIPS TO LOAD CSV FILES--------------------------------

# 1. Check if local_infile is ON or OFF
	SHOW GLOBAL VARIABLES LIKE 'local_infile';
	# If local_infile is OFF
	SET GLOBAL local_infile = 1;

# 2. MISSING VALUES
	# Use \N for any NULL values in a column. In this way, MySQL interprets as NULL, otherwise it replaces by 0.

# 3. DATETIME FORMAT
# Format datetime as yyyy-mm-dd hh:mm:ss in excel files (xls, xlsx), save. Then save as CSV files. 
# To check the format, open CSV files with notepad. If open CSV files by MS.Excel, it can change the datetime format to default setting.

########################################################
-- CREATE DATABASE DOGNITION
CREATE DATABASE dognition;
USE dognition;


########################################################
-- CREATE TABLES 

CREATE TABLE Users (
Sign_in_count SMALLINT DEFAULT 0,
Created_at DATETIME NOT NULL,
Updated_at DATETIME NOT NULL,
Max_dogs SMALLINT DEFAULT 0,
Membership_id INT,
Subscribed TINYINT(1) DEFAULT 0,
Exclude TINYINT(1),
Free_start_user TINYINT(1),
Last_active_at DATETIME,
Membership_type INT,
UserID VARCHAR(60),
City VARCHAR(50),
State VARCHAR(50),
Zip VARCHAR(20),
Country VARCHAR(50),
UTC_correction VARCHAR(10),
KEY(UserID)
);


CREATE TABLE Dogs (
Gender VARCHAR(10),
Birthday VARCHAR(10),
Breed VARCHAR(50),
Weight INT,
Dog_fixed BOOLEAN,
DNA_tested BOOLEAN,
Created_at DATETIME NOT NULL,
Updated_at DATETIME NOT NULL,
Dimension VARCHAR(50),
Exclude TINYINT(1),
Breed_type VARCHAR(50),
Breed_group VARCHAR(25),
DogID VARCHAR(60),
UserID VARCHAR(60),
Total_tests_completed SMALLINT,
Mean_iti_days DOUBLE,
Mean_iti_minutes DOUBLE,
Median_iti_days DOUBLE,
Median_iti_minutes DOUBLE,
Time_diff_between_first_and_last_game_days DOUBLE,
Time_diff_between_first_and_last_game_minutes DOUBLE,
KEY(DogID),
KEY(UserID)
);


CREATE TABLE complete_tests (
Created_at DATETIME NOT NULL,
Updated_at DATETIME NOT NULL,
UserID varchar(60),
DogID varchar(60),
Test_name varchar(60),
Subcategory_name varchar(60),
KEY(UserID),
Key(DogID)
); 


CREATE TABLE Reviews (
Rating INT DEFAULT NULL,
Created_at DATETIME NOT NULL,
Updated_at DATETIME NOT NULL,
UserID VARCHAR(60),
DogID VARCHAR(60),
Subcategory_name VARCHAR(50),
Test_name VARCHAR(50),
KEY(UserID),
KEY(DogID)
);



###########################################################
-- LOADING DATA 

LOAD DATA LOCAL INFILE "/data/reviews.csv" 
INTO TABLE reviews
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE "/data/complete_tests.csv" 
INTO TABLE complete_tests
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE "/data/dogs.csv" 
INTO TABLE dogs
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE "/data/users.csv" 
INTO TABLE users
CHARACTER SET latin1
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;


####################################################################
-- CLEANING DATA 

# If we show 'reviews' table, we can see that the Test_name column contain a 'non-print' control character which is '\r'.
# This character make the WHERE clause returns no result when we try to find matching strings. Thus, we should remove '\r' from the string
UPDATE reviews SET Test_name = replace(Test_name, '\r', '')
WHERE Test_name LIKE '%\r';



