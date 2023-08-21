# Top-rated chocolate bars based on average ratings

SELECT 
	DISTINCT Bar_Name,
	Rating
FROM flavors_of_cacao2
ORDER BY rating DESC

# How does cocoa percentage affect the rating of chocolate bars

SELECT 
    CASE 
		WHEN Cocoa_percentage > '0,81' AND Cocoa_percentage < '0.90' THEN '81-90 %'
		WHEN Cocoa_percentage > '0,71' AND Cocoa_percentage < '0.80' THEN '71-80 %'
        WHEN Cocoa_percentage > '0,61' AND Cocoa_percentage <= '0.70' THEN '61-70 %'
		WHEN Cocoa_percentage > '0,51' AND Cocoa_percentage <= '0.60' THEN '51-60 %'
		WHEN Cocoa_percentage > '0,41' AND Cocoa_percentage < '0.50' THEN '41-50 %'
        ELSE '90-100 %'
    END AS Percentage,
	AVG (rating) AS Average_rating
FROM flavors_of_cacao2
GROUP BY Percentage
ORDER BY Percentage

# Which company produces the most highly-rated chocolate bars

SELECT 
	DISTINCT Company,
	ROUND(AVG (Rating), 2) AS Rating 
FROM flavors_of_cacao2
GROUP BY company
ORDER BY rating DESC

# Distribution of chocolate bars by cocoa percentage

SELECT 
    DISTINCT Bar_Name,
    Case 
		WHEN Cocoa_percentage = '1' THEN (Cocoa_percentage*100) 
        ELSE CAST(REPLACE(Cocoa_percentage, ',', '') AS DECIMAL(5, 2)) 
		END AS Cocoa_percentage
FROM flavors_of_cacao2
ORDER BY Cocoa_percentage DESC

# Countries are known for producing high-rated chocolate bars

SELECT 
	DISTINCT Country,
	ROUND(AVG(Rating), 2) AS Rating
FROM flavors_of_cacao2
GROUP BY country
ORDER BY rating DESC

# How broad bean origin affect the popularity and rating 

SELECT
	DISTINCT Broad_Bean_Origin,
	ROUND((Count(*)/(Select COUNT(*)FROM flavors_of_cacao2))*100, 2) AS popularity_percentage,
     AVG(Rating) AS Average_rating
FROM flavors_of_cacao2
GROUP BY Broad_Bean_Origin
ORDER BY popularity_percentage DESC

# Correlations between cocoa percentage and the broad bean origin's region

SELECT 
DISTINCT Broad_Bean_Origin,
    CASE 
		WHEN Cocoa_percentage > '0,81' AND Cocoa_percentage < '0.90' THEN '81-90 %'
		WHEN Cocoa_percentage > '0,71' AND Cocoa_percentage < '0.80' THEN '71-80 %'
        WHEN Cocoa_percentage > '0,61' AND Cocoa_percentage < '0.70' THEN '61-70 %'
		WHEN Cocoa_percentage > '0,51' AND Cocoa_percentage < '0.60' THEN '51-60 %'
		WHEN Cocoa_percentage > '0,41' AND Cocoa_percentage < '0.50' THEN '41-50 %'
        ELSE '90-100 %'
    END AS Percentage,
	AVG (rating) AS Average_rating
FROM flavors_of_cacao2
GROUP BY Broad_Bean_Origin, Percentage
ORDER BY Percentage

# Company's location impact the cocoa percentage in chocolate bars

SELECT 
DISTINCT country,
    CASE 
		WHEN Cocoa_percentage > '0,81' AND Cocoa_percentage < '0.90' THEN '81-90 %'
		WHEN Cocoa_percentage > '0,71' AND Cocoa_percentage < '0.80' THEN '71-80 %'
        WHEN Cocoa_percentage > '0,61' AND Cocoa_percentage <= '0.70' THEN '61-70 %'
		WHEN Cocoa_percentage > '0,51' AND Cocoa_percentage <= '0.60' THEN '51-60 %'
		WHEN Cocoa_percentage > '0,41' AND Cocoa_percentage < '0.50' THEN '41-50 %'
        ELSE '90-100 %'
    END AS Percentage,
	AVG (rating) AS Average_rating
FROM flavors_of_cacao2
GROUP BY country, Percentage
ORDER BY Percentage DESC
