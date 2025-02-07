SELECT fin.*,
       CASE
	       WHEN fin.height NOT BETWEEN fin.lcl AND fin.ucl
		   THEN TRUE
		   ELSE FALSE
	   END AS alert
FROM (SELECT agg.*,
       agg.avg_height + 3*agg.stddev_height/SQRT(5) AS ucl,
       agg.avg_height - 3*agg.stddev_height/SQRT(5) AS lcl
	  FROM (SELECT operator,
	   ROW_NUMBER() OVER wind AS row_number,
	   height,
	   AVG(height) OVER wind AS avg_height,
	   STDDEV(height) OVER wind AS stddev_height
			FROM manufacturing_parts
			WINDOW wind AS (PARTITION BY operator
					  ORDER BY item_no
					  ROWS BETWEEN 4 PRECEDING AND CURRENT ROW)) AS agg
	 WHERE agg.row_number >= 5) AS fin;
