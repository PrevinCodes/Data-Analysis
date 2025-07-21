SELECT *
FROM hotel_reservations

--Create copy of table
CREATE TABLE hotel_reservations_copy
LIKE hotel_reservations

--Insert data into copy table
INSERT hotel_reservations_copy
SELECT *
FROM hotel_reservations

--Verify
SELECT *
FROM hotel_reservations_copy

--Remove uneccessary columns
ALTER TABLE hotel_reservations_copy
DROP COLUMN type_of_meal_plan,
DROP COLUMN required_car_parking_space,
DROP COLUMN lead_time,
DROP COLUMN no_of_previous_cancellations,
DROP COLUMN no_of_previous_bookings_not_canceled,
DROP COLUMN no_of_special_requests

--Verify
SELECT *
FROM hotel_reservations_copy


--Check for duplicates with a subquery or cte
WITH duplicate_cte AS(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY Booking_ID, no_of_adults, no_of_children, no_of_weekend_nights, no_of_week_nights, 
	room_type_reserved, arrival_year, arrival_month, arrival_date, market_segment_type, repeated_guest,
    avg_price_per_room, booking_status) AS row_num
FROM hotel_reservations_copy);

SELECT *
FROM duplicate_cte
WHERE row_num > 1;

--Verify
SELECT *
FROM hotel_reservations_copy;

--Verify, standardize and clean data
SELECT DISTINCT(Booking_ID)
FROM hotel_reservations_copy
ORDER BY 1;

SELECT DISTINCT(market_segment_type)
FROM hotel_reservations_copy
ORDER BY 1;

SELECT DISTINCT(booking_status)
FROM hotel_reservations_copy
ORDER BY 1;

SELECT DISTINCT(room_type_reserved)
FROM hotel_reservations_copy
ORDER BY 1;

SELECT DISTINCT(repeated_guest)
FROM hotel_reservations_copy
ORDER BY 1;

--Changed values for better understanding
UPDATE hotel_reservations_copy
SET repeated_guest = 'No'
WHERE repeated_guest LIKE '0'

UPDATE hotel_reservations_copy
SET repeated_guest = 'Yes'
WHERE repeated_guest LIKE '1'

--Check for null values
SELECT *
FROM hotel_reservations_copy
WHERE Booking_ID IS NULL

SELECT *
FROM hotel_reservations_copy
WHERE no_of_adults IS NULL

SELECT *
FROM hotel_reservations_copy
WHERE no_of_children IS NULL

SELECT *
FROM hotel_reservations_copy
WHERE no_of_weekend_nights IS NULL

SELECT *
FROM hotel_reservations_copy
WHERE no_of_week_nights IS NULL

SELECT *
FROM hotel_reservations_copy
WHERE room_type_reserved IS NULL

SELECT *
FROM hotel_reservations_copy
WHERE arrival_year IS NULL

SELECT *
FROM hotel_reservations_copy
WHERE arrival_month IS NULL

SELECT *
FROM hotel_reservations_copy
WHERE arrival_date IS NULL

SELECT *
FROM hotel_reservations_copy
WHERE market_segment_type IS NULL

SELECT *
FROM hotel_reservations_copy
WHERE repeated_guest IS NULL

SELECT *
FROM hotel_reservations_copy
WHERE avg_price_per_room IS NULL

SELECT *
FROM hotel_reservations_copy
WHERE booking_status IS NULL

--Create a single date column
---1. Fix incorrect date
SELECT reservation_date, arrival_date
FROM hotel_reservations_copy
WHERE arrival_date LIKE '29' AND
		arrival_month LIKE '02' AND
        arrival_year LIKE '2018';
        
UPDATE hotel_reservations_copy
SET arrival_date = '28'
WHERE arrival_date LIKE '29' AND
		arrival_month LIKE '02' AND
        arrival_year LIKE '2018';

--2. Create date column 
ALTER TABLE hotel_reservations_copy
    ADD COLUMN reservation_date DATE;
    
UPDATE hotel_reservations_copy
	SET reservation_date = STR_TO_DATE(
		CONCAT(arrival_year, '-', LPAD(arrival_month, 2, '0'), '-', LPAD(arrival_date, 2, '0')),
		'%Y-%m-%d')

--Verify data for importing into Power Bi
SELECT *
FROM hotel_reservations_copy;
