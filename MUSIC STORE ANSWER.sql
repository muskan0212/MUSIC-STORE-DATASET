##QUESTION SET 1
/* Who is the senior most employee based on job title? */
SELECT FIRST_NAME, LAST_NAME FROM EMPLOYEE WHERE TITLE = 'SENIOR GENERAL MANAGER';
SELECT title, last_name, first_name 
FROM employee
ORDER BY LEVEL DESC
LIMIT 1;

/* Which countries have the most Invoices? */
SELECT COUNT(INVOICE_ID), BILLING_COUNTRY FROM INVOICE GROUP BY BILLING_COUNTRY;
SELECT COUNT(*) AS COUNT, BILLING_COUNTRY 
FROM INVOICE 
GROUP BY BILLING_COUNTRY 
ORDER BY COUNT DESC;

/* What are top 3 values of total invoice? */ 
SELECT TOTAL FROM INVOICE order by TOTAL desc limit 3;
SELECT TOTAL AS TOP_3_VALUES 
FROM INVOICE 
ORDER BY TOTAL DESC 
LIMIT 3 ;

/* Which city has the best customers? We would like to throw a promotional Music Festival in the 
city we made the most money. Write a query that returns one city that has the highest sum of 
invoice totals. Return both the city name & sum of all invoice totals */
SELECT
    BILLING_CITY AS CityName,
    SUM(Total) AS TotalInvoiceSum
FROM Invoice
GROUP BY BILLING_CITY
ORDER BY TotalInvoiceSum DESC LIMIT 1;
SELECT billing_city,SUM(total) AS InvoiceTotal
FROM invoice
GROUP BY billing_city
ORDER BY InvoiceTotal DESC
LIMIT 1;

SELECT SUM(TOTAL) AS INVOICE_TOTAL, 
BILLING_CITY FROM INVOICE 
GROUP BY BILLING_CITY
ORDER BY INVOICE_TOTAL DESC
LIMIT 1;

/* Who is the best customer? The customer who has spent the most money will be declared the 
best customer. Write a query that returns the person who has spent the most money */
SELECT CUSTOMER.FIRST_NAME, CUSTOMER.LAST_NAME, TOTAL FROM INVOICE JOIN CUSTOMER
ON INVOICE.CUSTOMER_ID = CUSTOMER.CUSTOMER_ID WHERE TOTAL = (SELECT MAX(TOTAL) FROM INVOICE);
SELECT customer.customer_id, first_name, last_name, SUM(total) AS total_spending
FROM customer
JOIN invoice ON customer.customer_id = invoice.customer_id
GROUP BY customer.customer_id
ORDER BY total_spending DESC
LIMIT 1;
SELECT CUSTOMER.CUSTOMER_ID, CUSTOMER.FIRST_NAME, CUSTOMER.LAST_NAME, SUM(INVOICE.TOTAL) AS TOTAL
FROM CUSTOMER
JOIN INVOICE ON CUSTOMER.CUSTOMER_ID = INVOICE.CUSTOMER_ID 
GROUP BY CUSTOMER.CUSTOMER_ID
ORDER BY TOTAL DESC
LIMIT 1;

##QUESTION SET 2
/* Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
Return your list ordered alphabetically by email starting with A */

SELECT CUSTOMER.EMAIL, CUSTOMER.FIRST_NAME, CUSTOMER.LAST_NAME, GENRE.NAME 
FROM CUSTOMER LEFT JOIN INVOICE ON CUSTOMER.CUSTOMER_ID = INVOICE.CUSTOMER_ID 
JOIN INVOICE_LINE ON INVOICE.INVOICE_ID = INVOICE_LINE.INVOICE_ID 
JOIN TRACK ON INVOICE_LINE.TRACK_ID = TRACK.TRACK_ID 
JOIN GENRE ON TRACK.GENRE_ID = GENRE.GENRE_ID WHERE GENRE.NAME LIKE '%ROCK%'
GROUP BY CUSTOMER.EMAIL, CUSTOMER.FIRST_NAME, CUSTOMER.LAST_NAME, GENRE.NAME 
ORDER BY CUSTOMER.EMAIL ASC;

/*Method 1 */

SELECT DISTINCT email,first_name, last_name
FROM customer
JOIN invoice ON customer.customer_id = invoice.customer_id
JOIN invoice_line ON invoice.invoice_id = invoice_line.invoice_id
WHERE track_id IN(
	SELECT track_id FROM track
	JOIN genre ON track.genre_id = genre.genre_id
	WHERE genre.name LIKE 'Rock'
)
ORDER BY email;

SELECT DISTINCT EMAIL,FIRST_NAME, LAST_NAME
FROM CUSTOMER 
JOIN INVOICE ON CUSTOMER.CUSTOMER_ID = INVOICE.CUSTOMER_ID
JOIN INVOICE_LINE ON INVOICE.INVOICE_ID = INVOICE_LINE.INVOICE_ID
WHERE TRACK_ID IN(
	SELECT TRACK_ID FROM TRACK
    JOIN GENRE ON TRACK.GENRE_ID = GENRE.GENRE_ID
    WHERE GENRE.NAME LIKE 'ROCK'
)
ORDER BY EMAIL;

/* Method 2 */

SELECT DISTINCT email AS Email,first_name AS FirstName, last_name AS LastName, genre.name AS Name
FROM customer
JOIN invoice ON invoice.customer_id = customer.customer_id
JOIN invoice_line ON invoice_line.invoice_id = invoice.invoice_id
JOIN track ON track.track_id = invoice_line.track_id
JOIN genre ON genre.genre_id = track.genre_id
WHERE genre.name LIKE 'Rock'
ORDER BY email;

/* Let's invite the artists who have written the most rock music in our dataset. Write a query that 
returns the Artist name and total track count of the top 10 rock bands */
SELECT COMPOSER, `NAME` FROM TRACK WHERE GENRE_ID = 1 ORDER BY `NAME` LIMIT 10;

SELECT ARTIST.ARTIST_ID, ARTIST.NAME, COUNT(TRACK_ID) AS NUMBER_OF_TRACKS
FROM TRACK_ID
JOIN album ON album.album_id = track.album_id
JOIN artist ON artist.artist_id = album.artist_id
JOIN GENRE ON GENRE.GENRE_ID = track.genre_id
WHERE GENRE.NAME LIKE 'Rock'
GROUP BY ARTIST.ARTIST_ID
ORDER BY NUMBER_OF_TRACKS DESC
LIMIT 10;
 
/* Return all the track names that have a song length longer than the average song length. Return 
the Name and Milliseconds for each track. Order by the song length with the longest songs listed 
first */
SELECT `NAME`, MILLISECONDS FROM TRACK 
WHERE MILLISECONDS > (SELECT AVG(MILLISECONDS) FROM TRACK)
ORDER BY MILLISECONDS DESC; 

##QUESTION SET 3
/* Find how much amount spent by each customer on artists? Write a query to return customer 
name, artist name and total spent */
SELECT CUSTOMER.CUSTOMER_ID, CUSTOMER.FIRST_NAME, CUSTOMER.LAST_NAME, ARTIST.NAME AS ARTIST_NAME,
SUM(INVOICE.TOTAL) AS TOTAL_SPENT
FROM INVOICE INNER JOIN CUSTOMER ON INVOICE.CUSTOMER_ID = CUSTOMER.CUSTOMER_ID CROSS JOIN ARTIST ON
CUSTOMER.CUSTOMER_ID = ARTIST.ARTIST_ID ORDER BY TOTAL_SPENT;

WITH best_selling_artist AS (
	SELECT artist.artist_id AS artist_id, artist.name AS artist_name, SUM(invoice_line.unit_price*invoice_line.quantity) AS total_sales
	FROM invoice_line
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN album ON album.album_id = track.album_id
	JOIN artist ON artist.artist_id = album.artist_id
	GROUP BY 1
	ORDER BY 3 DESC
	LIMIT 1
)
SELECT c.customer_id, c.first_name, c.last_name, bsa.artist_name, SUM(il.unit_price*il.quantity) AS amount_spent
FROM invoice i
JOIN customer c ON c.customer_id = i.customer_id
JOIN invoice_line il ON il.invoice_id = i.invoice_id
JOIN track t ON t.track_id = il.track_id
JOIN album alb ON alb.album_id = t.album_id
JOIN best_selling_artist bsa ON bsa.artist_id = alb.artist_id
GROUP BY 1,2,3,4
ORDER BY 5 DESC;

WITH BEST_SELLING_ARTIST AS(
	SELECT ARTIST.ARTIST_ID AS ARTIST_ID, ARTIST.NAME AS ARTIST_NAME, 
    SUM(INVOICE_LINE.UNIT_PRICE * INVOICE_LINE.QUANTITY) AS TOTAL_SALES
    FROM INVOICE_LINE
    JOIN TRACK ON TRACK.TRACK_ID = INVOICE_LINE.TRACK_ID
    JOIN ALBUM ON ALBUM.ALBUM_ID = TRACK.ALBUM_ID
    JOIN ARTIST ON ARTIST.ARTIST_ID = ALBUM.ARTIST_ID
    GROUP BY 1
    ORDER BY 3 DESC
    LIMIT 1
)
SELECT C.CUSTOMER_ID, C.FIRST_NAME, C.LAST_NAME, BSA.ARTIST_NAME,
SUM(IL.UNIT_PRICE * IL.QUANTITY) AS AMOUNT_SPENT
FROM INVOICE I
JOIN CUSTOMER C ON C.CUSTOMER_ID = I.CUSTOMER_ID
JOIN INVOICE_LINE IL ON IL.INVOICE_ID = I.INVOICE_ID
JOIN TRACK T ON T.TRACK_ID = IL.TRACK_ID
JOIN ALBUM ALB ON ALB.ALBUM_ID = T.ALBUM_ID
JOIN BEST_SELLING_ARTIST BSA ON BSA.ARTIST_ID = ALB.ARTIST_ID
GROUP BY 1,2,3,4
ORDER BY 5 DESC; 

/* We want to find out the most popular music Genre for each country. We determine the most 
popular genre as the genre with the highest amount of purchases. Write a query that returns 
each country along with the top Genre. For countries where the maximum number of purchases 
is shared return all Genres */
SELECT MAX(GENRE.NAME) AS TOP_GENRE, CUSTOMER.COUNTRY FROM GENRE
CROSS JOIN CUSTOMER ON GENRE.GENRE_ID = CUSTOMER.CUSTOMER_ID
CROSS JOIN ALBUM ON CUSTOMER.CUSTOMER_ID = ALBUM.ALBUM_ID
CROSS JOIN INVOICE ON ALBUM.ALBUM_ID = INVOICE.INVOICE_ID GROUP BY NAME;

/*Steps to Solve:There are two parts in question- first most popular music genre and second need data at country level. */

/* Method 1: Using CTE*/

WITH popular_genre AS 
(
    SELECT COUNT(invoice_line.quantity) AS purchases, customer.country, genre.name, genre.genre_id, 
	ROW_NUMBER() OVER(PARTITION BY customer.country ORDER BY COUNT(invoice_line.quantity) DESC) AS RowNo 
    FROM invoice_line 
	JOIN invoice ON invoice.invoice_id = invoice_line.invoice_id
	JOIN customer ON customer.customer_id = invoice.customer_id
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN genre ON genre.genre_id = track.genre_id
	GROUP BY 2,3,4
	ORDER BY 2 ASC, 1 DESC
)
SELECT * FROM popular_genre WHERE RowNo <= 1;

/* Method 2: : Using Recursive */

WITH RECURSIVE
	sales_per_country AS(
		SELECT COUNT(*) AS purchases_per_genre, customer.country, genre.name, genre.genre_id
		FROM invoice_line
		JOIN invoice ON invoice.invoice_id = invoice_line.invoice_id
		JOIN customer ON customer.customer_id = invoice.customer_id
		JOIN track ON track.track_id = invoice_line.track_id
		JOIN genre ON genre.genre_id = track.genre_id
		GROUP BY 2,3,4
		ORDER BY 2
	),
	max_genre_per_country AS (SELECT MAX(purchases_per_genre) AS max_genre_number, country
		FROM sales_per_country
		GROUP BY 2
		ORDER BY 2)

SELECT sales_per_country.* 
FROM sales_per_country
JOIN max_genre_per_country ON sales_per_country.country = max_genre_per_country.country
WHERE sales_per_country.purchases_per_genre = max_genre_per_country.max_genre_number;

/* Write a query that determines the customer that has spent the most on music for each country. 
Write a query that returns the country along with the top customer and how much they spent. 
For countries where the top amount spent is shared, provide all customers who spent this AMOUNT */
SELECT CUSTOMER.FIRST_NAME, CUSTOMER.LAST_NAME, CUSTOMER.COUNTRY, ALBUM.TITLE, TRACK.NAME,
TRACK.ALBUM_ID, INVOICE.TOTAL FROM CUSTOMER 
CROSS JOIN ALBUM ON CUSTOMER.COUNTRY = ALBUM.TITLE
CROSS JOIN TRACK ON ALBUM.TITLE = TRACK.NAME
CROSS JOIN INVOICE ON TRACK.ALBUM_ID = INVOICE.TOTAL
WHERE TOTAL = (SELECT MAX(TOTAL) FROM INVOICE);

/* Steps to Solve:  Similar to the above question. There are two parts in question- 
first find the most spent on music for each country and second filter the data for respective customers. */

/* Method 1: using CTE */

WITH Customter_with_country AS (
		SELECT customer.customer_id,first_name,last_name,billing_country,SUM(total) AS total_spending,
	    ROW_NUMBER() OVER(PARTITION BY billing_country ORDER BY SUM(total) DESC) AS RowNo 
		FROM invoice
		JOIN customer ON customer.customer_id = invoice.customer_id
		GROUP BY 1,2,3,4
		ORDER BY 4 ASC,5 DESC)
SELECT * FROM Customter_with_country WHERE RowNo <= 1;

/* Method 2: Using Recursive */

WITH RECURSIVE 
	customter_with_country AS (
		SELECT customer.customer_id,first_name,last_name,billing_country,SUM(total) AS total_spending
		FROM invoice
		JOIN customer ON customer.customer_id = invoice.customer_id
		GROUP BY 1,2,3,4
		ORDER BY 2,3 DESC),

	country_max_spending AS(
		SELECT billing_country,MAX(total_spending) AS max_spending
		FROM customter_with_country
		GROUP BY billing_country)

SELECT cc.billing_country, cc.total_spending, cc.first_name, cc.last_name, cc.customer_id
FROM customter_with_country cc
JOIN country_max_spending ms
ON cc.billing_country = ms.billing_country
WHERE cc.total_spending = ms.max_spending
ORDER BY 1;


