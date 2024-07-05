-- 3 July 2024
/*
Scenario:
 Cindy is close to securing Maven Fuzzy Factory’s
 next round of funding, and she needs your help
 to tell a compelling story to investors. You’ll
 need to pull the relevant data and assist your
 CEO in crafting a narrative about a data-driven
 company that has been experiencing rapid growth.
*/

-- Request 1
/*
First, I’d like to show our volume growth. Can you pull
 overall session and order volume, presented by quarter
 for the life of the business? Since the most recent
 quarter is incomplete, you can decide how to handle it.
 */
 
 SELECT
 YEAR(ws.created_at) AS yr,
 QUARTER(ws.created_at) AS qtr,
 COUNT(DISTINCT ws.website_session_id) AS sessions,
 COUNT(DISTINCT o.order_id) AS orders,
 COUNT(DISTINCT o.order_id)/
 COUNT(DISTINCT ws.website_session_id) AS cnv_rate
 FROM website_sessions ws
	LEFT JOIN orders o 
		ON ws.website_session_id=o.website_session_id

WHERE ws.created_at<'2015-03-20'

GROUP BY
1,2;

/*
Business insight:
Conversion rate session to orders is 3% in first
two quarters of 2012 and 4% in remaining two quarters
while its jumped to around 6% in the all the quarters of year 2013
and its increased to around 7% in the all the quarters of year 2014
and lastly its 8% in the partially completed 1st quarter of 2015
*/

-- Request 2
/*
Next, let’s showcase all of our efficiency improvements.
 I would like to show our updated figures since we
 launched for session-to-order conversion rate,
 revenue per order, and revenue per session.
 */
 
 SELECT
 YEAR(ws.created_at) AS yr,
 QUARTER(ws.created_at) AS qtr,
 COUNT(DISTINCT ws.website_session_id) AS sessions,
 COUNT(DISTINCT o.order_id) AS orders,
 COUNT(DISTINCT o.order_id)/
 COUNT(DISTINCT ws.website_session_id) AS cnv_rate,
 SUM(price_usd)/COUNT(DISTINCT o.order_id) AS rev_per_order,
 SUM(price_usd)/COUNT(DISTINCT ws.website_session_id) AS rev_per_session
 
 FROM website_sessions ws
	LEFT JOIN orders o 
		ON ws.website_session_id=o.website_session_id

WHERE ws.created_at<'2015-03-20'

GROUP BY
1,2;

/*
Details:
Revenue per oerder is %50 per in all quraters of 2012 and revenue per session is $1.5
in first two quarters of 2012 and $2 in the last two quarters of 2012 then revnue per order is 
increased from $52 to $54 while rev per session increased to $3 in all the quarters of 2013
and i can see a big jump in revenue per order from $54 to $62 in first quarter of 2014
and its remain around this figure in all quarters of 2014 while revenue per session also increased
to $4.5 on average in all the quarter and lastly revenue per order is unchanged in the first
partial quarter of 2014 and revenue per session increased to $5.3 in quarter.


Business insight:
The analysis of efficiency improvements since the 
launch provides clear evidence of positive trends
 in key performance metrics over the years From 2012 to 2015:

Session-to-Order Conversion Rate: There is a steady increase
 in the conversion rate, from 3.19% in Q1 2012 to 8.44% in Q1 2015.
 This indicates improved effectiveness in converting website sessions
 into orders, showcasing better website usability and marketing efforts.

Revenue per Order: The revenue per order has shown consistent growth,
 reaching $62.80 in Q1 2015 compared to $49.99 in Q1 2012. This suggests
 an increase in average order value, indicating successful upselling
 and cross-selling strategies.

Revenue per Session: The revenue per session has also increased significantly
, from $1.60 in Q1 2012 to $5.30 in Q1 2015. This improvement highlights enhanced
 overall session value, reflecting more efficient customer engagement and spending.

These metrics collectively demonstrate substantial efficiency improvements,
 confirming the effectiveness of strategies implemented over the period.
 This data provides a strong foundation for
 continued investment in marketing, customer
 experience, and sales optimization initiatives.

*/  

-- Request 3
/*
I’d like to show how we’re growing specific channels.
 Could you pull a quarterly view of orders from Gsearch,
 Nonbrand, Bsearch nonbrand, brand search overall,
 organic search, and direct type-in?
 */
 
 SELECT DISTINCT utm_campaign,utm_source,http_referer
 FROM website_sessions;
 
  SELECT
 YEAR(ws.created_at) AS yr,
 QUARTER(ws.created_at) AS qtr,
 COUNT(DISTINCT CASE WHEN utm_source='gsearch' AND utm_campaign='nonbrand' THEN o.order_id END) AS gsearch_nonbrand_orders,
 COUNT(DISTINCT CASE WHEN utm_source='bsearch' AND utm_campaign='nonbrand' THEN o.order_id END) AS bsearch_nonbrand_orders,
 COUNT(DISTINCT CASE WHEN utm_campaign='brand' THEN o.order_id END) AS brand_orders,
 COUNT(DISTINCT CASE WHEN utm_source IS NULL AND http_referer IS NOT NULL THEN o.order_id END) AS organic_orders,
 COUNT(DISTINCT CASE WHEN utm_source IS NULL AND http_referer IS NULL THEN o.order_id END) AS direct_type_in_orders
 
 
 FROM website_sessions ws
	LEFT JOIN orders o 
		ON ws.website_session_id=o.website_session_id

WHERE ws.created_at<'2015-03-20'

GROUP BY
1,2;

/*
Business Insight:
The quarterly analysis of orders from various channels from
 2012 to early 2015 provides the following business insights:

Gsearch Nonbrand Orders: 
Orders from Gsearch nonbrand have shown a substantial increase,
 growing from 60 in Q1 2012 to 3,025 in Q1 2015. This highlights
 the success of nonbrand paid search efforts 
 in driving significant order volume.

Bsearch Nonbrand Orders:
 Bsearch nonbrand orders, though starting later, have also increased,
 rising from 0 in Q1 2012 to 581 in Q1 2015. This reflects an effective
 strategy in capturing additional nonbrand search traffic.

Brand Orders: 
Orders from brand search have grown steadily, indicating stronger
 brand recognition and loyalty. Brand orders
 increased from 20 in Q2 2012 to 622 in Q1 2015.


Organic Orders: 
Orders from organic search have shown significant growth
, which suggests successful SEO efforts. Organic orders
 increased from 0 in Q1 2012 to 640 in Q1 2015.

Direct Type-In Orders: 
Direct type-in orders, representing customers 
directly visiting the website, have also seen growth.
This indicates increased customer loyalty and brand recall,
 with orders rising from 0 in Q1 2012 to 552 in Q1 2015.

Overall, the data underscores the success of diversified marketing
strategies across paid search, brand campaigns, and organic growth,
leading to a consistent increase in orders across all channels.
This comprehensive approach has effectively driven both new
 and repeat customer orders, supporting sustained business growth.
*/

-- Request 4
/*
Next, let’s show the overall session-to-order conversion rate
 trends for those same channels, by quarter. Please also make
 a note of any periods where we made major improvements or optimizations.
 */
 
  SELECT
 YEAR(ws.created_at) AS yr,
 QUARTER(ws.created_at) AS qtr,
 COUNT(DISTINCT CASE WHEN utm_source='gsearch' AND utm_campaign='nonbrand' THEN o.order_id END)/
 COUNT(DISTINCT CASE WHEN utm_source='gsearch' AND utm_campaign='nonbrand' THEN ws.website_session_id END)AS gsearch_nonbrand_cnv_rate,
 
 COUNT(DISTINCT CASE WHEN utm_source='bsearch' AND utm_campaign='nonbrand' THEN o.order_id END)/
  COUNT(DISTINCT CASE WHEN utm_source='bsearch' AND utm_campaign='nonbrand' THEN ws.website_session_id END)AS bsearch_nonbrand_cnv_rate,
  
 COUNT(DISTINCT CASE WHEN utm_campaign='brand' THEN o.order_id END)/
 COUNT(DISTINCT CASE WHEN utm_campaign='brand' THEN ws.website_session_id END)AS brand_session_cnv_rate,
 
 COUNT(DISTINCT CASE WHEN utm_source IS NULL AND http_referer IN ('https://www.gsearch.com','https://www.bsearch.com') THEN o.order_id END)/
 COUNT(DISTINCT CASE WHEN utm_source IS NULL AND http_referer IN ('https://www.gsearch.com','https://www.bsearch.com') THEN ws.website_session_id END)AS organic_cnv_rate,
 
 COUNT(DISTINCT CASE WHEN utm_source IS NULL AND http_referer IS NULL THEN o.order_id END)/
 COUNT(DISTINCT CASE WHEN utm_source IS NULL AND http_referer IS NULL THEN ws.website_session_id END) AS direct_type_in_cnv_rate
 
 
 FROM website_sessions ws
	LEFT JOIN orders o 
		ON ws.website_session_id=o.website_session_id

WHERE ws.created_at<'2015-03-20'

GROUP BY
1,2;
 
 /*
 Business Insight:
 The quarterly analysis of session-to-order conversion
 rates by channel reveals insightful trends in the
 effectiveness of specific marketing channels from 2012 to early 2015:

Gsearch Nonbrand and Bsearch Nonbrand:
There is a notable increase in conversion rates
 from nonbrand searches on both Gsearch and Bsearch
 platforms. Gsearch nonbrand conversion rates grew 
 from 3.24% in Q1 2012 to 8.61% in Q1 2015, while
 Bsearch nonbrand conversion rates increased from
 0% in Q1 2012 to 8.50% in Q1 2015. This indicates
 a successful expansion in capturing new customers
 through nonbranded search efforts.

Brand Sessions:
Conversion rates from brand searches show consistent
 growth, reflecting increased brand awareness and loyalty.
 From 0% in Q1 2012, brand session-to-order conversion
 rates have grown to 8.52% in Q1 2015.

Organic Sessions:
Organic search conversion rates have also grown steadily,
 indicating strong organic reach and SEO effectiveness.
 Conversion rates rose from 0% in Q1 2012 to 8.21% in Q1 2015.

Direct Type-In Sessions:
Direct type-in conversion rates, which indicate direct
 traffic to the website, show healthy growth, increasing 
 from 0% in Q1 2012 to 7.75% in Q1 2015. This suggests
 improved brand recall and customer loyalty.

These insights illustrate the effectiveness of various
 marketing strategies in driving conversions and
 growing specific channels, supporting the continued
 focus on search engine marketing, brand awareness,
 and organic reach to sustain growth.
*/
 
 -- 4 July 2024
 
 -- Request 5
 
 /*
 We’ve come a long way since the days of selling a single product.
 Let’s pull monthly trending for revenue and margin by product,
 along with total sales and revenue. Note
 anything you notice about seasonality.
 */
 
 SELECT
 YEAR(created_at) AS yr,
 MONTH(created_at) AS mo,
 SUM(CASE WHEN product_id=1 THEN price_usd ELSE NULL END) AS mrfuzzy_rev,
 SUM(CASE WHEN product_id=1 THEN price_usd - cogs_usd ELSE NULL END) mrfuzzy_marg,
 SUM(CASE WHEN product_id=2 THEN price_usd ELSE NULL END) AS lovebear_rev, 
 SUM(CASE WHEN product_id=2 THEN price_usd - cogs_usd ELSE NULL END) AS lovebear_marg,
 SUM(CASE WHEN product_id=3 THEN price_usd ELSE NULL END) AS birthdaybear_rev, 
 SUM(CASE WHEN product_id=3 THEN price_usd - cogs_usd ELSE NULL END) AS birthdaybear_marg,
 SUM(CASE WHEN product_id=4 THEN price_usd ELSE NULL END) AS minbear_rev, 
 SUM(CASE WHEN product_id=4 THEN price_usd - cogs_usd ELSE NULL END) AS minibear_marg,
 SUM(price_usd) AS total_revenue,
 SUM(price_usd-cogs_usd) AS total_margin

 
 FROM order_items
WHERE created_at<'2015-03-20'

GROUP BY
1,2;

/*
Business Insight:
I can see mostly revenue comes peak in the last months of the year like Nov and Dec 
so there is a seasonality element present in the business revenue
*/
 
 -- Reuqest 6
 /*
 Let’s dive deeper into the impact of introducing new products.
 Please pull monthly sessions to the /products page,
 and show how the % of those sessions clicking through
 to another page has changed over time, along with a
 view of how conversion from /products
 to placing an order has improved.
 */
 
 -- step 1 find all the views of the product page
 
 CREATE TEMPORARY TABLE products_pageviews
 SELECT 
 website_session_id,
 website_pageview_id,
 created_at AS saw_product_page_at
 
 FROM website_pageviews
 WHERE pageview_url='/products';
 
 -- step 2 join with orders table 
 
 SELECT
 YEAR(saw_product_page_at) AS yr,
 MONTH(saw_product_page_at) AS mo,
 COUNT(DISTINCT products_pageviews.website_session_id) AS sessions_to_product_page,
 COUNT(DISTINCT website_pageviews.website_session_id) AS clicked_to_next_page,
 COUNT(DISTINCT website_pageviews.website_session_id)/
 COUNT(DISTINCT products_pageviews.website_session_id) AS clickthrough_rt,
 COUNT(DISTINCT orders.order_id) AS orders,
 COUNT(DISTINCT orders.order_id)/
 COUNT(DISTINCT products_pageviews.website_session_id) AS product_to_order_rt
 
 FROM products_pageviews
	LEFT JOIN website_pageviews
		ON products_pageviews.website_session_id=website_pageviews.website_session_id
        AND website_pageviews.website_pageview_id>products_pageviews.website_pageview_id
	LEFT JOIN orders
		ON products_pageviews.website_session_id=orders.website_session_id

GROUP BY
1,2;

/*
Business Insight:
The monthly analysis of sessions to the products page,
 clickthrough rates, and product-to-order conversion
 rates provides the following business insights:

Increasing Product Page Sessions: 
There has been a steady increase in sessions to
 the product page, reflecting growing customer
 interest and traffic. For instance, sessions
 increased from 743 in March 2012 to 17,240 in December 2014.

Improving Clickthrough Rates:
 The clickthrough rate from the product page to
 other pages has shown a positive trend, improving
 from 71.33% in March 2012 to 84.56% in February 2015.
 This indicates enhanced user engagement and effective page design or product listings.

Enhanced Conversion Rates: 
The product-to-order conversion rate has significantly
 improved over time, from 8.08% in March 2012 to 13.89%
 in February 2015. This improvement suggests successful
 conversion strategies, possibly due to better product
 offerings, pricing, or promotional activities.

Overall, these metrics demonstrate the effectiveness of
 initiatives to drive traffic to the product page, increase
 user engagement, and enhance conversion rates,
 contributing to overall business growth.
 */
 
 -- Request 7
 /*
 We made our #4 product available as a primary product
 on December 05, 2014. It was previously only a cross-sell item.
 Could you please pull sales data since then, and
 show how well each product cross-sells from one another?
 */
 
-- step 1 create temp table for primary_products
CREATE TEMPORARY TABLE primary_products
SELECT
order_id,
primary_product_id,
created_at AS ordered_at
FROM orders
WHERE created_at>'2014-12-05';

-- step 2
-- sub query
SELECT
	primary_products.*,
    order_items.product_id AS cross_sell_product_id
FROM primary_products
	LEFT JOIN order_items
		ON primary_products.order_id=order_items.order_id
        AND order_items.is_primary_item=0; -- only fetching cross_sells;

-- step 3
-- final output

SELECT
primary_product_id,
COUNT(DISTINCT order_id) AS total_orders,
COUNT(DISTINCT CASE WHEN cross_sell_product_id=1 THEN order_id ELSE NULL END) AS _xsold_p1,
COUNT(DISTINCT CASE WHEN cross_sell_product_id=2 THEN order_id ELSE NULL END) AS _xsold_p2,
COUNT(DISTINCT CASE WHEN cross_sell_product_id=3 THEN order_id ELSE NULL END) AS _xsold_p3,
COUNT(DISTINCT CASE WHEN cross_sell_product_id=4 THEN order_id ELSE NULL END) AS _xsold_p4,
COUNT(DISTINCT CASE WHEN cross_sell_product_id=1 THEN order_id ELSE NULL END)/
COUNT(DISTINCT order_id) AS p1_xsell_rt, 
COUNT(DISTINCT CASE WHEN cross_sell_product_id=2 THEN order_id ELSE NULL END)/
COUNT(DISTINCT order_id) AS p2_xsell_rt,
COUNT(DISTINCT CASE WHEN cross_sell_product_id=3 THEN order_id ELSE NULL END)/
COUNT(DISTINCT order_id) AS p3_xsell_rt,
COUNT(DISTINCT CASE WHEN cross_sell_product_id=4 THEN order_id ELSE NULL END)/
COUNT(DISTINCT order_id) AS p4_xsell_rt
FROM 
(
SELECT
	primary_products.*,
    order_items.product_id AS cross_sell_product_id
FROM primary_products
	LEFT JOIN order_items
		ON primary_products.order_id=order_items.order_id
        AND order_items.is_primary_item=0
) primary_cross_sell

GROUP BY
1;

/*
Business Insight:
Business Insight
The analysis of cross-sell rates for different primary products
 reveals significant opportunities for boosting revenue through
 strategic cross-selling. The data shows that certain products
 have higher cross-sell rates, indicating customer preferences
 for complementary items.
 
 Here are key insights and recommendations:

Identify High-Potential Cross-Sell Products:

Product 4 exhibits the highest cross-sell rates with
 Product 1 (_p1_xsell_rt) and Product 3 (_p3_xsell_rt),
 suggesting that customers who purchase Product 4 are more
 likely to add these items to their orders. Focus marketing 
efforts on promoting these combinations to maximize sales.
Targeted Marketing Strategies:

Product 1 has substantial cross-sell rates with
 Products 2, 3, and 4. Implement targeted promotions
 and bundle offers for customers purchasing Product 1,
 emphasizing the value and benefits of adding these complementary items.
Optimize Inventory and Product Placement:

Ensure sufficient stock levels of high cross-sell products to meet demand.
 Optimize product placement both online and in-store by grouping these
 frequently purchased together items to encourage additional purchases.
 
Personalized Recommendations:

Use this data to enhance personalized recommendation algorithms on
 the website. When customers view or add a primary product to their
 cart, prominently display the high cross-sell products as suggested
 additions.
 
By leveraging these insights, we can strategically
 enhance our cross-selling efforts, leading to increased
 average order values and overall sales growth. This data-driven
 approach will help us tailor our marketing and inventory strategies
 to better meet customer preferences and drive profitability.
*/

-- Request 8
/*
In addition to telling investors about what we have already achieved,
 let’s show them that we still have plenty of gas in the tank. Based on
 all the analysis you’ve done, could you share some recommendations and
 opportunities for us going forward? No right or wrong answer here
 – I’d just like to hear your perspective.  
 */
 
 /*
 Based on the comprehensive analysis of our data, here are some recommendations and opportunities for continued growth and improvement:

Enhance Customer Retention through Personalized Marketing:

Leverage Data-Driven Insights: Utilize the data from repeat sessions and purchase history to create personalized marketing campaigns. Target repeat customers with tailored offers, loyalty programs, and personalized product recommendations to increase customer retention.
Optimize Paid Channels: Since a significant number of repeat sessions come from paid channels, consider optimizing ad spend by focusing on high-performing channels and campaigns. Test different ad creatives and messages to further boost engagement and conversions.
Improve Product Quality and Customer Experience:

Monitor and Address Quality Issues: Continuously monitor product quality and address any emerging issues promptly. Ensuring high product quality will maintain customer trust and reduce refund rates.
Enhance User Experience: Improve the website’s user interface and navigation based on user behavior data. Streamline the checkout process to reduce cart abandonment and increase conversion rates.
Expand and Diversify Marketing Channels:

Invest in Organic and Social Channels: While paid channels are performing well, there is potential for growth in organic search and social media. Invest in SEO strategies and engage with customers on social media platforms to drive organic traffic and build brand loyalty.
Explore New Marketing Channels: Experiment with emerging marketing channels and technologies such as influencer partnerships, video marketing, and AI-driven chatbots to reach a broader audience and enhance customer interaction.
Capitalize on High-Performing Products and Categories:

Focus on Best Sellers: Identify and promote top-selling products and categories. Use insights from sales data to optimize inventory management and ensure the availability of popular items.
Introduce Complementary Products: Based on customer preferences and buying patterns, introduce complementary products to encourage cross-selling and upselling. Create bundled offers to increase average order value.
Refine Conversion Optimization Strategies:

A/B Testing and Analytics: Conduct regular A/B testing on landing pages, product pages, and marketing campaigns to identify the most effective elements. Use analytics to track performance and make data-driven decisions.
Enhance Mobile Experience: With the increasing trend of mobile shopping, ensure that the website is fully optimized for mobile devices. Improve mobile site speed, usability, and overall user experience to capture mobile traffic and conversions.
Leverage Customer Feedback and Reviews:

Incorporate Customer Feedback: Actively collect and analyze customer feedback to understand their needs and pain points. Use this information to make product improvements and enhance the overall customer experience.
Promote Positive Reviews: Highlight positive customer reviews and testimonials on the website and in marketing materials to build trust and credibility with potential customers.
By implementing these strategies, we can continue to drive growth, enhance customer satisfaction, and maximize our market potential. These recommendations aim to build on our existing successes while exploring new opportunities for future development.
*/

