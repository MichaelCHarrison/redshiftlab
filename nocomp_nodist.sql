-- Create tables without compression, distribution style or sort keys:

CREATE TABLE orders_nocomp
(
	o_orderkey BIGINT NOT NULL,
	o_custkey BIGINT NOT NULL,
	o_orderstatus CHAR(1) NOT NULL,
	o_totalprice NUMERIC(12, 2) NOT NULL,
	o_orderdate DATE NOT NULL,
	o_orderpriority CHAR(15) NOT NULL,
	o_clerk CHAR(15) NOT NULL,
	o_shippriority INTEGER NOT NULL,
	o_comment VARCHAR(79) NOT NULL);


CREATE TABLE lineitem_nocomp
(
	l_orderkey BIGINT NOT NULL,
	l_partkey BIGINT NOT NULL,
	l_suppkey INTEGER NOT NULL,
	l_linenumber INTEGER NOT NULL,
	l_quantity NUMERIC(12, 2) NOT NULL,
	l_extendedprice NUMERIC(12, 2) NOT NULL,
	l_discount NUMERIC(12, 2) NOT NULL,
	l_tax NUMERIC(12, 2) NOT NULL,
	l_returnflag CHAR(1) NOT NULL,
	l_linestatus CHAR(1) NOT NULL,
	l_shipdate DATE NOT NULL,
	l_commitdate DATE NOT NULL,
	l_receiptdate DATE NOT NULL,
	l_shipinstruct CHAR(25) NOT NULL,
	l_shipmode CHAR(10) NOT NULL,
	l_comment VARCHAR(44) NOT NULL);


copy orders_nocomp from 's3://bigdatalabmch/redshiftdata/orders.manifest' iam_role 'arn:aws:iam::821189638502:role/redshiftlab' delimiter '|' manifest compupdate off;
copy lineitem_nocomp from 's3://bigdatalabmch/redshiftdata/lineitem.manifest' iam_role 'arn:aws:iam::821189638502:role/redshiftlab' delimiter '|' manifest compupdate off;



SELECT
    l_shipmode,
    sum(case
        when o_orderpriority = '1-URGENT'
            OR o_orderpriority = '2-HIGH'
            then 1
        else 0
    end) as high_line_count,
    sum(case
        when o_orderpriority <> '1-URGENT'
            AND o_orderpriority <> '2-HIGH'
            then 1
        else 0
    end) AS low_line_count
FROM
    orders_nocomp,
    lineitem_nocomp
WHERE
    o_orderkey = l_orderkey
    AND l_shipmode in ('AIR', 'SHIP')
    AND l_commitdate < l_receiptdate
    AND l_shipdate < l_commitdate
    AND l_receiptdate >= date '1992-01-01'
    AND l_receiptdate < date '1996-01-01' + interval '1' year
GROUP BY
    l_shipmode
ORDER BY
    l_shipmode;