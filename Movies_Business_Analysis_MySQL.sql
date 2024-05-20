/*
Maven Movies Project
/*

-- Let's Start

/*
1. Manager and Property Details “My partner and I want to come by each of the stores in person 
and meet the managers. Please send over the managers’ names at each store, 
with the full address of 
each property street address, district, city, and country please
*/

SELECT *
FROM store;

SELECT 
	s.first_name AS manager_first_name,
    s.last_name AS manager_last_name,
    a.address,
    a.district,
    c.city,
    co.country
FROM store 
LEFT JOIN address a
		ON a.address_id=store.address_id
LEFT JOIN city c 
		ON a.city_id=c.city_id
LEFT JOIN staff s 
		ON s.staff_id=store.manager_staff_id
LEFT JOIN country co 
		ON co.country_id=c.country_id;

/*
2. Inventory Overview “I would like to get a better understanding of all of the inventory that 
would come along with the business. Please pull together a list of each inventory item you have 
stocked, including the store_id number, 
the inventory_id, the name of the film, the film’s rating, its rental rate and replacement cost.”
*/

SELECT
	i.store_id,
	i.inventory_id,
    f.title,
    f.rating,
    f.rental_rate,
    f.replacement_cost
FROM inventory i 
LEFT JOIN film f 
		ON i.film_id=f.film_id;
        
/*
3. Inventory Summary “From the same list of films you just pulled, please roll that data up 
and provide a summary level overview of your inventory. 
We would like to know how many inventory items you have with each rating at each store.”
*/

SELECT
	i.store_id,
    f.rating,
	COUNT(i.inventory_id) AS inventory_items
    
FROM inventory i 
LEFT JOIN film f 
		ON i.film_id=f.film_id
GROUP BY
 i.store_id,f.rating;

/*
4. Cost Diversification Analysis “Similarly, we want to understand how diversified the inventory is in 
terms of replacement cost. We want to see how big of a hit it would be if a certain category of film 
became unpopular at a certain store. We would like to see the number of films, 
as well as the average replacement cost, and total replacement cost, sliced by store and film category.”
*/

SELECT 
	store_id,
    cc.name AS Category,
	COUNT(i.inventory_id) AS films,
    AVG(f.replacement_cost) AS avg_replacement_cost,
    SUM(f.replacement_cost) AS total_replacement_Cost
FROM inventory i
LEFT JOIN film f 
		ON f.film_id=i.film_id
LEFT JOIN film_category fc -- acting as a lookup table
		ON fc.film_id=f.film_id
LEFT JOIN category cc 
		ON cc.category_id=fc.category_id

GROUP BY store_id,cc.name;

/*
5. We want to make sure you folks have a good handle on who your customers are. 
Please provide a full list of all customer names, 
which store they go to, whether or not they are currently active, 
and their full addresses – street address, city, and country.
*/

SELECT 
	c.first_name,
	c.last_name,
    c.store_id,
	c.active,
    a.address,
    city.city,
    cc.country
FROM customer c 
LEFT JOIN address a
	ON c.address_id=a.address_id
LEFT JOIN city city 
	ON city.city_id=a.city_id
LEFT JOIN country cc
	ON cc.country_id=city.country_id;


/*
6. We would like you to understand how your customers are spending with you 
and also know who your most valuable customers are. 
Please pull together a list of customer names, their total lifetime rentals, 
and the sum of all payments we have collected from them. 
It would be great to see this ordered on 
total lifetime value with the most valuable customers at the top of the list.
*/

SELECT
	c.first_name,
    c.last_name,
    COUNT(r.rental_id) AS total_lifetime_rentals,
    SUM(p.amount) AS total_payments
FROM customer c 
LEFT JOIN rental r 
	ON r.customer_id=c.customer_id
LEFT JOIN payment p	
	ON p.customer_id=c.customer_id
GROUP BY c.first_name,c.last_name
ORDER BY total_payments DESC;

/*
7. My partner and I would like to get to know your board of advisors 
and any current investors. Could you please provide a list of advisor 
and investor names in one table? Could you please note whether 
they are an investor or an advisor, and for the investors, 
it would be good to include which company they work with.
*/

SELECT 
	first_name AS first_name,
    last_name AS last_name,
    'advisor' AS type,
    'N/A' AS company_name
FROM advisor
UNION
SELECT
	first_name AS first_name,
    last_name AS last_name,
    'investor' AS type,
    company_name
FROM investor;


/*
8. We're interested in how well you have reviewed the most-awarded actors. 
Of all the actors with three types of awards, 
for what % of them do we carry a film? 
And how about for actors with two types or awards? 
Same questions. Finally, how about actors with just one award?
*/


SELECT 
	CASE
		WHEN actor_award.awards='Emmy,Oscar,Tony' THEN '3 awards'
		WHEN actor_award.awards IN ('Emmy,Oscar','Emmy,Tony','Oscar,Tony') THEN '2 awards'
		ELSE '1 award' 
	END AS number_of_awards,
    AVG(CASE WHEN actor_award.actor_id IS NULL THEN 0 ELSE 1 END)*100 AS pct_w_one_film
    
    FROM actor_award
    
    GROUP BY 
	CASE
		WHEN actor_award.awards='Emmy,Oscar,Tony' THEN '3 awards'
		WHEN actor_award.awards IN ('Emmy,Oscar','Emmy,Tony','Oscar,Tony') THEN '2 awards'
		ELSE '1 award' 
    END;





























