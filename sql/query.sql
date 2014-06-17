
SELECT
  *,
  SUM(total) OVER (ORDER BY day, month)::text::money AS mtd
FROM
  ( SELECT
    *,
    rank() OVER (ORDER BY total DESC)
  FROM
    ( SELECT
    EXTRACT(MONTH FROM orderdate) AS month, --TODO concat these
    EXTRACT(DAY FROM orderdate) AS day,
    SUM(totalamount)::text::money AS total
    FROM orders
    GROUP BY month, day
    ORDER BY month, day
  ) as f ) as p

SELECT
    CONCAT(c.city, ',', c.state, ',', c.country) as location,
    c.customerid,
    CONCAT(EXTRACT(MONTH FROM orderdate), '-', EXTRACT(DAY FROM orderdate)) AS monthday,
    SUM(totalamount)::text::money AS total
FROM
  orders o
JOIN customers c on o.customerid = c.customerid
WHERE orderdate > '01-02-2013' AND orderdate < '01-31-2013'
GROUP BY location, c.customerid, monthday
ORDER BY location, c.customerid, monthday