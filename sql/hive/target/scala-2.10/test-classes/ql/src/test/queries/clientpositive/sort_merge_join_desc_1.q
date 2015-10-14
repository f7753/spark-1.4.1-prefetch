drop table table_desc1;
drop table table_desc2;

set hive.enforce.sorting = true;

create table table_desc1(key string, value string) clustered by (key) sorted by (key DESC) into 1 BUCKETS;
create table table_desc2(key string, value string) clustered by (key) sorted by (key DESC) into 1 BUCKETS;

insert overwrite table table_desc1 select key, value from src;
insert overwrite table table_desc2 select key, value from src;

set hive.optimize.bucketmapjoin = true;
set hive.optimize.bucketmapjoin.sortedmerge = true;
set hive.input.format = org.apache.hadoop.hive.ql.io.BucketizedHiveInputFormat;

-- The columns of the tables above are sorted in same descending order.
-- So, sort merge join should be performed

explain
select /*+ mapjoin(b) */ count(*) from table_desc1 a join table_desc2 b on a.key=b.key where a.key < 10;

select /*+ mapjoin(b) */ count(*) from table_desc1 a join table_desc2 b on a.key=b.key where a.key < 10;
