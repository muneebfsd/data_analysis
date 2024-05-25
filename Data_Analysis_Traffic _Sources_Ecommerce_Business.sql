/*
Let's Start the Data Analysis of Ecommerce Business
Major hurdle I solved in the beginning was related to running the SQL script
I got rid of this problem by disk cleaning where source files of MySQL located.
*/
USE mavenfuzzyfactory;
SELECT 
	ws.utm_content,
    COUNT(DISTINCT ws.website_session_id) AS sessions,
    COUNT(DISTINCT o.order_id) AS orders,
    COUNT(DISTINCT o.order_id)/COUNT(DISTINCT ws.website_session_id) AS Session_to_order_conv_rt
FROM website_sessions ws
	LEFT JOIN orders o
		ON ws.website_session_id=o.website_session_id
WHERE ws.website_session_id BETWEEN 1000 AND 5000
GROUP BY 
	1
ORDER BY
	2 DESC;
    
-- 24 May 2024
-- First Rquest by CEO

/*
We've been live for almost a month now and we're starting to generate sales.
 Can you help me understand where the bulk of our website sessions are coming from,
 through a breakdown by UTM source, campaign id, and referring domain if possible. Thanks!
 */
 
 
SELECT 
    utm_source,
    utm_campaign,
    http_referer,
    COUNT(DISTINCT website_session_id) AS sessions
FROM website_sessions
WHERE created_at < '2012-04-12'
GROUP BY utm_source, utm_campaign, http_referer
ORDER BY sessions DESC;


SELECT *
FROM website_sessions;

SELECT *
FROM orders;

-- Second Request by Marketing Director
/*
Sounds like gsearch nonbrand is our major traffic source, but we need to understand if those sessions are driving sales.
Could you please calculate the conversion rate (CVR) from session to order? 
Based on what we're paying for clicks, if we'll need a CVR of at least 4% to make the numbers work. 
If we're much lower, we’ll need to reduce bids. If we’re higher, we can increase bids to drive more volume.
*/

SELECT 
	COUNT(DISTINCT ws.website_session_id) AS sessions,
	COUNT(DISTINCT o.order_id) AS orders,
    (COUNT(DISTINCT o.order_id)/COUNT(DISTINCT ws.website_session_id))*100 AS session_to_order_cvr -- Less than 4% 
    
FROM website_sessions ws
LEFT JOIN orders o
		ON o.website_session_id=ws.website_session_id
WHERE ws.created_at < '2012-04-14'
AND utm_source='gsearch'
AND utm_campaign='nonbrand';

-- Date Function

SELECT
    MONTH(created_at) AS month_name,
    WEEK(created_at) AS week_name,
    MIN(DATE(created_at)) AS week_start,
    YEAR(created_at) AS year_name,
    COUNT(DISTINCT website_session_id) AS sessions
FROM website_sessions
GROUP BY 
	1,2,4   
ORDER BY 
	5 DESC;

-- Case Pivoting Method

SELECT
	primary_product_id,
   
    COUNT(DISTINCT CASE WHEN items_purchased=1 THEN order_id ELSE NULL END) AS orders_w_1_item,
    COUNT(DISTINCT CASE WHEN items_purchased=2 THEN order_id ELSE NULL END) AS orders_w_2_item

FROM orders

WHERE order_id BETWEEN 31000 AND 32000 -- arbitrary
GROUP BY 1;

/*Third Request by Marketing Director
Based on your conversion rate analysis, we bid down Gsearch nonbrand on 2012-04-15.
Can you pull Gsearch nonbrand session volume, by week, 
to see if the bid changes have caused volume to drop at all?
*/

SELECT 
	
    MIN(DATE(created_at)) AS week_start_date,
    COUNT(DISTINCT website_session_id) AS sessions 
    -- WEEK(created_at)
    -- YEAR(created_at)
FROM website_sessions
WHERE created_at < '2012-05-10'
AND utm_source='gsearch'
AND utm_campaign='nonbrand'
GROUP BY
	WEEK(created_at),
    YEAR(created_at);
    
-- We can see a downtrend after the bid changes to drop.

/* 4th Request by Marketing Director
I was trying to use our site on my mobile device the other day, and the experience was not great.
Could you pull conversion rates from session to order, by day, 
and compare notes on mobile vs desktop performance? If desktop 
performance is better than on mobile we may be able to bid up 
for desktop specifically to get more volume?
*/


SELECT
	ws.device_type,
	COUNT(DISTINCT ws.website_session_id) AS sessions,
    COUNT(DISTINCT o.order_id) AS orders,
    (COUNT(DISTINCT o.order_id)/COUNT(DISTINCT ws.website_session_id))*100 AS session_to_order_cvr
FROM website_sessions ws
LEFT JOIN orders o
		ON ws.website_session_id=o.website_session_id
WHERE ws.created_at<'2012-05-11'
	AND ws.utm_source='gsearch'
    AND ws.utm_campaign='nonbrand'
GROUP BY ws.device_type;
    
	
/* 
5th Request by Marketing Director
After your device-level analysis of conversion rates, 
we realized desktop was doing well on 2012-05-19.
Nonbrand desktop campaigns up, so we bid our search.
Could you pull the impact on both desktop and mobile so we can see weekly trends for volume?
Make sure to normalize for the big change as a baseline.
*/

SELECT 
	WEEK(created_at),
    MIN(DATE(created_at)) AS week_start_date,
    COUNT(CASE WHEN device_type='desktop' THEN website_session_id ELSE NULL END) AS dtop_sessions,
    COUNT(CASE WHEN device_type='mobile' THEN website_session_id ELSE NULL END) AS mob_sessions
FROM website_sessions
WHERE created_at BETWEEN '2012-04-15' AND '2012-06-09'
		AND utm_source='gsearch'
        AND utm_campaign='nonbrand'
GROUP BY 1


 
 
 
 
 
 
 
 
 
 
 
 
 