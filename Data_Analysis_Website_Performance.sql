/*
Let's Start the Data Analysis of Website Performance of Ecommerce Business
Major hurdle I solved in the beginning was related to running the SQL script
I got rid of this problem by disk cleaning where source files of MySQL located.
*/

-- 25 May 2024
-- First Request by Website Manager
/*
I'm Morgan, the new Website Manager.
Could you help me get my head around the site by 
pulling the most-viewed website pages, ranked by session volume?
*/

-- CREATE TEMPORARY TABLE most_viewed_pages
SELECT 
	pageview_url,
    COUNT(DISTINCT website_pageview_id) AS pvs
FROM website_pageviews
WHERE created_at<'2012-06-09'
GROUP BY
	pageview_url
ORDER BY 
pvs DESC;
    
SELECT *
FROM most_viewed_pages;

-- 26 May 2024

/*
Second Request by Website Manager
Would you be able to pull a list of the top entry pages? 
I want to confirm where our users are hitting the site.
If you could pull all entry pages and rank them on entry volume, that would be great.
*/

-- Natural Mehtod to solve this query
SELECT
	wp.pageview_url AS landing_page,
    COUNT(ws.website_session_id) AS sessions_hitting_this_landing_page
FROM website_pageviews wp
	LEFT JOIN website_sessions ws
		ON wp.website_session_id=ws.website_session_id
WHERE wp.created_at<'2012-06-12'
GROUP BY
	1
LIMIT 1;

-- Create Temporaray Table Method to solve this query
-- Step 1: find the first pageview for each session.
-- Step 2: find the URL the customer saw on that first pageview

CREATE TEMPORARY TABLE first_pv__per_session
SELECT
	website_session_id,
	MIN(website_pageview_id) AS first_pv
FROM website_pageviews
WHERE created_at<'2012-06-12'
GROUP BY
	website_session_id;
    
SELECT
	website_pageviews.pageview_url AS landing_page,
    COUNT(DISTINCT first_pv__per_session.website_session_id) AS sessions_hitting_page
FROM first_pv__per_session
	LEFT JOIN website_pageviews
		ON first_pv__per_session.first_pv=website_pageviews.website_pageview_id
GROUP BY 1;

/*
Request 3 by Website Manager
The other day you showed us that all of 
our traffic is landing on the homepage right now. 
We should check how the landing page is 
performing. Can you pull bounce rates for traffic landing on the homepage? 
I would like to see three numbers: 
Sessions, Bounced Sessions, and % of Sessions which Bounced (aka ‘Bounce Rate’)
*/

-- Request 3 by Website Manager
-- Step 1
-- Finding the first website_page_id for relevant sessions.

CREATE TEMPORARY TABLE first_pageview
SELECT
	website_session_id,
    MIN(website_pageview_id) AS min_pageview_id
FROM website_pageviews wp
WHERE wp.created_at<'2012-06-14'
GROUP BY 
	website_session_id;

SELECT * FROM first_pageview;

-- Step 2: Sessions with landing page

CREATE TEMPORARY TABLE sessions_w_home_landing_page
SELECT
	first_pageview.website_session_id,
    website_pageviews.pageview_url
FROM first_pageview
	LEFT JOIN website_pageviews
		ON first_pageview.min_pageview_id=website_pageviews.website_pageview_id
WHERE website_pageviews.pageview_url='/home';

-- Step 3: Bounced Sessions

CREATE TEMPORARY TABLE bounced_sessions
SELECT 
	sessions_w_home_landing_page.website_session_id,
    sessions_w_home_landing_page.pageview_url,
    COUNT(website_pageviews.website_pageview_id) AS count_of_pages_viewed
    
FROM sessions_w_home_landing_page
	LEFT JOIN website_pageviews
		ON website_pageviews.website_session_id=sessions_w_home_landing_page.website_session_id

GROUP BY 
	sessions_w_home_landing_page.website_session_id,
    sessions_w_home_landing_page.pageview_url
    
HAVING 
	COUNT(website_pageviews.website_pageview_id)=1;
    
-- Step 4: Now we will count the bounced sessions and bounced rate. 

SELECT 
	COUNT(DISTINCT sessions_w_home_landing_page.website_session_id) AS sessions,
    COUNT(DISTINCT bounced_sessions.website_session_id) AS bounced_session,
	COUNT(DISTINCT bounced_sessions.website_session_id)/COUNT(DISTINCT sessions_w_home_landing_page.website_session_id) AS bounce_rate
FROM sessions_w_home_landing_page
	LEFT JOIN bounced_sessions
		ON sessions_w_home_landing_page.website_session_id=bounced_sessions.website_session_id;
	
-- 27 May 2024
-- Fourth Request by Website Manager

/*
Hi there! Based on your lander rate analysis, 
we ran a new custom landing page (/lander-1) in a 
50/50 test against the homepage (/home) for our search nonbrand traffic.
 
Can you pull bounce rates for the two groups so we can evaluate the new page? 
Make sure to just look at the time period where /lander-1 was 
getting traffic, so that it is a fair comparison. Thanks, Morgan
*/
-- Step 1: Find out the time frame of comparison.
SELECT
	MIN(created_at) AS first_created_at,
    MIN(website_pageview_id) AS first_pageview_id
FROM website_pageviews
WHERE created_at<'2012-07-28'
AND pageview_url='/lander-1'
AND created_at IS NOT NULL;
	
-- timeframe is '2012-06-19' AND '2012-07-28'

-- Step 2: Find out the first page view of relevant page.

CREATE TEMPORARY TABLE first_test_pageviews
SELECT 
	wp.website_session_id,
    MIN(wp.website_pageview_id) AS min_pageview_id
FROM website_pageviews wp
	INNER JOIN website_sessions ws
		ON wp.website_session_id = ws.website_session_id
	AND ws.created_at < '2012-07-28'
    AND wp.website_pageview_id > 23504
    AND ws.utm_source = 'gsearch'
    AND ws.utm_campaign = 'nonbrand'
GROUP BY
	wp.website_session_id;

    
    
    
-- Step 3: sessions with /lander-1 page.

CREATE TEMPORARY TABLE nonbrand_test_sessions_w_landing_page
SELECT
ftp.website_session_id,
wp.pageview_url AS landing_page
FROM
    first_test_pageviews ftp
LEFT JOIN website_pageviews wp
	ON ftp.website_session_id=wp.website_session_id
WHERE wp.pageview_url IN ('/home','/lander-1');

    
-- SELECT * FROM nonbrand_test_sessions_w_landing_page;

-- Step 4: Bounced Sessions
CREATE TEMPORARY TABLE nonbrand_test_bounced_sessions
SELECT
	nonbrand_test_sessions_w_landing_page.website_session_id,
    nonbrand_test_sessions_w_landing_page.landing_page,
    COUNT(wp.website_pageview_id) AS count_of_pageviews
FROM nonbrand_test_sessions_w_landing_page
	LEFT JOIN website_pageviews wp
		ON nonbrand_test_sessions_w_landing_page.website_session_id=wp.website_session_id
GROUP BY
	nonbrand_test_sessions_w_landing_page.website_session_id,
    nonbrand_test_sessions_w_landing_page.landing_page
HAVING 
COUNT(wp.website_pageview_id)=1;

SELECT *
FROM nonbrand_test_bounced_sessions;


-- Step 5: Calculating the bounced rate of both landing pages and comparing each other.

SELECT 
nonbrand_test_sessions_w_landing_page.landing_page,
COUNT(DISTINCT nonbrand_test_sessions_w_landing_page.website_session_id) AS sessions,
COUNT(DISTINCT nonbrand_test_bounced_sessions.website_session_id) AS bounced_sessions,
(COUNT(DISTINCT nonbrand_test_bounced_sessions.website_session_id)/COUNT(DISTINCT nonbrand_test_sessions_w_landing_page.website_session_id))*100 AS bounced_rate
FROM nonbrand_test_sessions_w_landing_page
	LEFT JOIN nonbrand_test_bounced_sessions
		ON nonbrand_test_sessions_w_landing_page.website_session_id=nonbrand_test_bounced_sessions.website_session_id

GROUP BY
		nonbrand_test_sessions_w_landing_page.landing_page;

-- We saw an improvement in '/lander-1' bounce rate as compared to the '/home'

-- 28 May 2024
-- Fifth Request by Website Manager

/*
Could you pull the volume of paid search nonbrand traffic landing on
 /home and /lander-1, trended weekly since June 1st? 
 I want to confirm the traffic is all routed correctly.
 
Could you also pull our overall paid search bounce rate trended weekly?
 I want to make sure the lander change has improved the overall performance.
*/

-- Solution is a multi-step query

-- STEP 1: finding the first website pageview id for relevant sessions
-- STEP 2: identifying the landing page of each session
-- STEP 3: counting pageviews for each session, to identify "bounces"
-- STEP 4: summarizing by week(total bounce rate, sessions to each lander)

-- STEP 1: finding the first website pageview id for relevant sessions

CREATE TEMPORARY TABLE sessions_w_min_pv_id_and_view_count
SELECT 
	ws.website_session_id,
    MIN(wp.website_pageview_id) AS first_pageview_id,
	COUNT(wp.website_pageview_id) AS count_pageviews
    
FROM website_sessions ws
LEFT JOIN website_pageviews wp
		ON ws.website_session_id=wp.website_session_id
        
WHERE ws.created_at>'2012-06-01'	-- asked by requestor
AND ws.created_at<'2012-08-31'		-- prescribed by assignment date
AND ws.utm_source='gsearch'
AND ws.utm_campaign='nonbrand'

GROUP BY 
ws.website_session_id;

-- STEP 2: identifying the landing page of each session

CREATE TEMPORARY TABLE sessions_w_counts_lander_and_created_at
SELECT
	sessions_w_min_pv_id_and_view_count.website_session_id,
    sessions_w_min_pv_id_and_view_count.first_pageview_id,
    sessions_w_min_pv_id_and_view_count.count_pageviews,
    wp.pageview_url AS landing_page,
    wp.created_at AS session_created_at
FROM sessions_w_min_pv_id_and_view_count
	LEFT JOIN website_pageviews wp
		ON wp.website_pageview_id=sessions_w_min_pv_id_and_view_count.first_pageview_id;

/*
STEP 3: counting pageviews for each session, to identify "bounces" 
& summarizing by week(total bounce rate, sessions to each lander)
*/

SELECT
	-- YEARWEEK(session_created_at) AS year_week,
    MIN(DATE(session_created_at)) AS week_start_date,
    -- COUNT(DISTINCT website_session_id) AS total_sessions,
    -- COUNT(DISTINCT CASE WHEN count_pageviews=1 THEN website_session_id ELSE NULL END) AS bounced_sessions,
    COUNT(DISTINCT CASE WHEN count_pageviews=1 THEN website_session_id ELSE NULL END)/COUNT(DISTINCT website_session_id) AS bounced_rate,
    COUNT(DISTINCT CASE WHEN landing_page='/home' THEN website_session_id ELSE NULL END) AS home_sessions,
    COUNT(DISTINCT CASE WHEN landing_page='/lander-1' THEN website_session_id ELSE NULL END) AS lander_sessions

FROM sessions_w_counts_lander_and_created_at

GROUP BY 
	YEARWEEK(session_created_at);

-- 29 May 2024
-- 6th Request by Website Manager
/*
Hi there!
I’d like to understand where we lose our search visitors between the new /lander-1 page 
and placing an order. Can you build us a full conversion funnel, 
analyzing how many customers make it to each step?

Start with /lander-1 and build the funnel all the way to our thank you page. 
Please use data since August 5th.
*/

-- Step 1: Select all pageviews for relevant sessions

SELECT 
	ws.website_session_id,
    wp.pageview_url, 
	-- wp.created_at AS pageview_created_at,
    -- CASE WHEN pageview_url='/lander-1' THEN 1 ELSE 0 END AS lander_page,
    CASE WHEN pageview_url='/products' THEN 1 ELSE 0 END AS products_page,
    CASE WHEN pageview_url='/the-original-mr-fuzzy' THEN 1 ELSE 0 END AS mrfuzzy_page,
    CASE WHEN pageview_url='/cart' THEN 1 ELSE 0 END AS cart_page,
    CASE WHEN pageview_url='/shipping' THEN 1 ELSE 0 END AS shipping_page,
    CASE WHEN pageview_url='/billing' THEN 1 ELSE 0 END AS billing_page,
    CASE WHEN pageview_url='/thank-you-for-your-order' THEN 1 ELSE 0 END AS thankyou_page
    
FROM website_sessions ws
		LEFT JOIN website_pageviews wp
			ON wp.website_session_id=ws.website_session_id
            
WHERE ws.created_at>'2012-08-05'
AND ws.created_at<'2012-09-05'
AND ws.utm_source='gsearch'
AND ws.utm_campaign='nonbrand'

ORDER BY 
	ws.website_session_id,
    wp.created_at;
    
-- Step 2: Website Session Level Summary

CREATE TEMPORARY TABLE session_level_made_it_flags
SELECT 
	website_session_id,
    MAX(products_page) AS products_made_it,
    MAX(mrfuzzy_page) AS mrfuzzy_made_it,
    MAX(cart_page) AS cart_made_it,
    MAX(shipping_page) AS shipping_made_it,
    MAX(billing_page) AS billing_made_it,
    MAX(thankyou_page) AS thankyou_mdae_it
FROM (
SELECT
ws.website_session_id,
    wp.pageview_url, 
	-- wp.created_at AS pageview_created_at,
    -- CASE WHEN pageview_url='/lander-1' THEN 1 ELSE 0 END AS lander_page,
    CASE WHEN pageview_url='/products' THEN 1 ELSE 0 END AS products_page,
    CASE WHEN pageview_url='/the-original-mr-fuzzy' THEN 1 ELSE 0 END AS mrfuzzy_page,
    CASE WHEN pageview_url='/cart' THEN 1 ELSE 0 END AS cart_page,
    CASE WHEN pageview_url='/shipping' THEN 1 ELSE 0 END AS shipping_page,
    CASE WHEN pageview_url='/billing' THEN 1 ELSE 0 END AS billing_page,
    CASE WHEN pageview_url='/thank-you-for-your-order' THEN 1 ELSE 0 END AS thankyou_page
    
FROM website_sessions ws
		LEFT JOIN website_pageviews wp
			ON wp.website_session_id=ws.website_session_id
            
WHERE ws.created_at>'2012-08-05'
AND ws.created_at<'2012-09-05'
AND ws.utm_source='gsearch'
AND ws.utm_campaign='nonbrand'

ORDER BY 
	ws.website_session_id,
    wp.created_at
) AS pageview_level

GROUP BY 
	website_session_id;
    
SELECT * FROM session_level_made_it_flags;

-- Step 3: I will produce the final output

SELECT
COUNT(DISTINCT website_session_id) AS sessions,
COUNT(DISTINCT CASE WHEN products_made_it = 1 THEN  website_session_id ELSE NULL END) AS to_products,
COUNT(DISTINCT CASE WHEN mrfuzzy_made_it = 1 THEN  website_session_id ELSE NULL END) AS to_mrfuzzy,
COUNT(DISTINCT CASE WHEN cart_made_it = 1 THEN  website_session_id ELSE NULL END) AS to_cart,
COUNT(DISTINCT CASE WHEN shipping_made_it = 1 THEN  website_session_id ELSE NULL END) AS to_shipping,
COUNT(DISTINCT CASE WHEN billing_made_it = 1 THEN  website_session_id ELSE NULL END) AS to_billing,
COUNT(DISTINCT CASE WHEN thankyou_mdae_it = 1 THEN  website_session_id ELSE NULL END) AS to_thankyou

FROM session_level_made_it_flags; 

-- Step 4: I will produce the final output - click rates

SELECT
-- COUNT(DISTINCT website_session_id) AS sessions,
COUNT(DISTINCT CASE WHEN products_made_it = 1 THEN  website_session_id ELSE NULL END)/
COUNT(DISTINCT website_session_id)  AS lander_click_rt,
COUNT(DISTINCT CASE WHEN mrfuzzy_made_it = 1 THEN  website_session_id ELSE NULL END)/
COUNT(DISTINCT CASE WHEN products_made_it = 1 THEN  website_session_id ELSE NULL END) AS products_click_rt,
COUNT(DISTINCT CASE WHEN cart_made_it = 1 THEN  website_session_id ELSE NULL END)/
COUNT(DISTINCT CASE WHEN mrfuzzy_made_it = 1 THEN  website_session_id ELSE NULL END) AS mrfuzzy_click_rt,
COUNT(DISTINCT CASE WHEN shipping_made_it = 1 THEN  website_session_id ELSE NULL END)/
COUNT(DISTINCT CASE WHEN cart_made_it = 1 THEN  website_session_id ELSE NULL END) AS cart_click_rt,
COUNT(DISTINCT CASE WHEN billing_made_it = 1 THEN  website_session_id ELSE NULL END)/
COUNT(DISTINCT CASE WHEN shipping_made_it = 1 THEN  website_session_id ELSE NULL END) AS shipping_click_rt,
COUNT(DISTINCT CASE WHEN thankyou_mdae_it = 1 THEN  website_session_id ELSE NULL END)/
COUNT(DISTINCT CASE WHEN billing_made_it = 1 THEN  website_session_id ELSE NULL END) AS billing_click_rt

FROM session_level_made_it_flags; 

-- 7th Request by Website Manager
/*
Hello!

We tested an updated billing page based on your funnel analysis.
 Can you take a look and see whether /billing-2 is doing any 
 better than the original /billing page?

We're wondering what % of sessions on those pages end up placing an order.
 FYI – we ran this test for all traffic, not just for our search visitors.

Thanks!
-Morgan
*/

-- Step 1: Find out when the /billing-2 was first created at.

SELECT 
	MIN(created_at) AS first_created_at,
    pageview_url AS first_pageview_id
	
FROM website_pageviews wp
WHERE pageview_url='/billing-2'

ORDER BY 
	created_at;
    
-- /billing-2 created on '2012-09-10'

-- Step 2: Create a temp table for sessions and orders of /billing

CREATE TEMPORARY TABLE billing_sessions_new
SELECT
wp.website_session_id AS sessions,
wp.pageview_url AS billing_version
FROM
    website_pageviews wp
LEFT JOIN orders o
	ON wp.website_session_id=o.website_session_id
WHERE wp.pageview_url IN ('/billing','/billing-2')
AND wp.created_at>'2012-09-10'
AND wp.created_at<'2012-11-10';

SELECT * FROM billing_sessions_new;

CREATE TEMPORARY TABLE billing_orders_new
SELECT
o.order_id AS orders,
wp.pageview_url AS billing_version
FROM
    orders o
LEFT JOIN website_pageviews wp
	ON wp.website_session_id=o.website_session_id
WHERE wp.pageview_url IN ('/billing','/billing-2')
AND wp.created_at>'2012-09-10'
AND wp.created_at<'2012-11-10';

SELECT
	billing_sessions_new.billing_version,
	COUNT(DISTINCT billing_sessions_new.sessions) AS sessions ,
    COUNT(DISTINCT billing_orders_new.orders) AS orders,
    COUNT(DISTINCT billing_orders_new.orders)/
    COUNT(DISTINCT billing_sessions_new.sessions) AS billing_to_order
    
FROM billing_sessions_new
	INNER JOIN billing_orders_new
		ON billing_sessions_new.billing_version=billing_orders_new.billing_version

GROUP BY
	billing_sessions_new.billing_version;
    
	
    
-- We can see an incredible improvement in /billing-2 page up from 45% to 62% as compared to /billing page

