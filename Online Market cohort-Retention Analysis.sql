
select  count(*) as cnt
from pro_test.store ;
-- 총 51,226개의 row 확인

select DATE_FORMAT(Order_date, '%Y-%m') as o_date,
		count(1) as cnt
from pro_test.store
group by DATE_FORMAT(Order_date,'%Y-%m')
order by 1 ;
-- 11년부터 14년까지 총 4년치의 데이터 있음

SELECT COUNT(DISTINCT Customer_ID) AS dist_customer
FROM pro_test.store ;
-- 고유한 고객수는 4,873명 -> 중복 거래가 있다



-- 첫번째 구매일 생성, month_number 구할때 사용
with first_order as (
select Customer_ID, 
		min(Order_date) as first_order
from pro_test.store
group by Customer_ID
), 
-- cohort month와 
cohort_date as(
select  s.Customer_ID,
		date_format(f.first_order, '%Y-%m') as cohort_month,
		timestampdiff(month,f.first_order, s.Order_date) as month_number
from pro_test.store s join first_order f
on s.Customer_ID = f.Customer_ID
)
select cohort_month,
		month_number,
		count(distinct Customer_ID) as act_user
from cohort_date
group by cohort_month, month_number
order by cohort_month, month_number ;

-- 다음달 구매 하지 않았다고 이탈한 것으로 보기 어렵기 때문에 롤링 리텐션 적용하여 재 확인 


-- 롤링 리텐션으로 계산
WITH user_dates AS (
  SELECT
    Customer_ID,
    MIN(Order_date) AS first_order_date,
    MAX(Order_date) AS last_order_date
  FROM pro_test.store
  GROUP BY Customer_ID
),
retention_monthly AS (
  SELECT
    Customer_ID,
    DATE_FORMAT(first_order_date, '%Y-%m') AS cohort_month,
    PERIOD_DIFF(DATE_FORMAT(last_order_date, '%Y%m'), DATE_FORMAT(first_order_date, '%Y%m')) AS months_retained
  FROM user_dates months_retained
)
SELECT
  cohort_month,
  COUNT(*) AS total_users,
  -- 리텐션 비율(%)
  ROUND(SUM(CASE WHEN months_retained >= 0 THEN 1 ELSE 0 END) / COUNT(*) * 100, 1) AS m0_pct,
  ROUND(SUM(CASE WHEN months_retained >= 1 THEN 1 ELSE 0 END) / COUNT(*) * 100, 1) AS m1_pct,
  ROUND(SUM(CASE WHEN months_retained >= 2 THEN 1 ELSE 0 END) / COUNT(*) * 100, 1) AS m2_pct,
  ROUND(SUM(CASE WHEN months_retained >= 3 THEN 1 ELSE 0 END) / COUNT(*) * 100, 1) AS m3_pct,
  ROUND(SUM(CASE WHEN months_retained >= 4 THEN 1 ELSE 0 END) / COUNT(*) * 100, 1) AS m4_pct,
  ROUND(SUM(CASE WHEN months_retained >= 5 THEN 1 ELSE 0 END) / COUNT(*) * 100, 1) AS m5_pct,
  ROUND(SUM(CASE WHEN months_retained >= 6 THEN 1 ELSE 0 END) / COUNT(*) * 100, 1) AS m6_pct,
  ROUND(SUM(CASE WHEN months_retained >= 7 THEN 1 ELSE 0 END) / COUNT(*) * 100, 1) AS m7_pct,
  ROUND(SUM(CASE WHEN months_retained >= 8 THEN 1 ELSE 0 END) / COUNT(*) * 100, 1) AS m8_pct,
  ROUND(SUM(CASE WHEN months_retained >= 9 THEN 1 ELSE 0 END) / COUNT(*) * 100, 1) AS m9_pct,
  ROUND(SUM(CASE WHEN months_retained >= 10 THEN 1 ELSE 0 END) / COUNT(*) * 100, 1) AS m10_pct,
  ROUND(SUM(CASE WHEN months_retained >= 11 THEN 1 ELSE 0 END) / COUNT(*) * 100, 1) AS m11_pct,
  ROUND(SUM(CASE WHEN months_retained >= 12 THEN 1 ELSE 0 END) / COUNT(*) * 100, 1) AS m12_pct,
  ROUND(SUM(CASE WHEN months_retained >= 13 THEN 1 ELSE 0 END) / COUNT(*) * 100, 1) AS m13_pct,
  ROUND(SUM(CASE WHEN months_retained >= 14 THEN 1 ELSE 0 END) / COUNT(*) * 100, 1) AS m14_pct,
  ROUND(SUM(CASE WHEN months_retained >= 15 THEN 1 ELSE 0 END) / COUNT(*) * 100, 1) AS m15_pct,
  ROUND(SUM(CASE WHEN months_retained >= 16 THEN 1 ELSE 0 END) / COUNT(*) * 100, 1) AS m16_pct,
  ROUND(SUM(CASE WHEN months_retained >= 17 THEN 1 ELSE 0 END) / COUNT(*) * 100, 1) AS m17_pct,
  ROUND(SUM(CASE WHEN months_retained >= 18 THEN 1 ELSE 0 END) / COUNT(*) * 100, 1) AS m18_pct,
  ROUND(SUM(CASE WHEN months_retained >= 19 THEN 1 ELSE 0 END) / COUNT(*) * 100, 1) AS m19_pct,
  ROUND(SUM(CASE WHEN months_retained >= 20 THEN 1 ELSE 0 END) / COUNT(*) * 100, 1) AS m20_pct,
  ROUND(SUM(CASE WHEN months_retained >= 21 THEN 1 ELSE 0 END) / COUNT(*) * 100, 1) AS m21_pct,
  ROUND(SUM(CASE WHEN months_retained >= 22 THEN 1 ELSE 0 END) / COUNT(*) * 100, 1) AS m22_pct,
  ROUND(SUM(CASE WHEN months_retained >= 23 THEN 1 ELSE 0 END) / COUNT(*) * 100, 1) AS m23_pct,
  ROUND(SUM(CASE WHEN months_retained >= 24 THEN 1 ELSE 0 END) / COUNT(*) * 100, 1) AS m24_pct,
  ROUND(SUM(CASE WHEN months_retained >= 25 THEN 1 ELSE 0 END) / COUNT(*) * 100, 1) AS m25_pct,
  ROUND(SUM(CASE WHEN months_retained >= 26 THEN 1 ELSE 0 END) / COUNT(*) * 100, 1) AS m26_pct,
  ROUND(SUM(CASE WHEN months_retained >= 27 THEN 1 ELSE 0 END) / COUNT(*) * 100, 1) AS m27_pct,
  ROUND(SUM(CASE WHEN months_retained >= 28 THEN 1 ELSE 0 END) / COUNT(*) * 100, 1) AS m28_pct,
  ROUND(SUM(CASE WHEN months_retained >= 29 THEN 1 ELSE 0 END) / COUNT(*) * 100, 1) AS m29_pct,
  ROUND(SUM(CASE WHEN months_retained >= 30 THEN 1 ELSE 0 END) / COUNT(*) * 100, 1) AS m30_pct,
  ROUND(SUM(CASE WHEN months_retained >= 31 THEN 1 ELSE 0 END) / COUNT(*) * 100, 1) AS m31_pct,
  ROUND(SUM(CASE WHEN months_retained >= 32 THEN 1 ELSE 0 END) / COUNT(*) * 100, 1) AS m32_pct,
  ROUND(SUM(CASE WHEN months_retained >= 33 THEN 1 ELSE 0 END) / COUNT(*) * 100, 1) AS m33_pct,
  ROUND(SUM(CASE WHEN months_retained >= 34 THEN 1 ELSE 0 END) / COUNT(*) * 100, 1) AS m34_pct,
  ROUND(SUM(CASE WHEN months_retained >= 35 THEN 1 ELSE 0 END) / COUNT(*) * 100, 1) AS m35_pct,
  ROUND(SUM(CASE WHEN months_retained >= 36 THEN 1 ELSE 0 END) / COUNT(*) * 100, 1) AS m36_pct,
  ROUND(SUM(CASE WHEN months_retained >= 37 THEN 1 ELSE 0 END) / COUNT(*) * 100, 1) AS m37_pct,
  ROUND(SUM(CASE WHEN months_retained >= 38 THEN 1 ELSE 0 END) / COUNT(*) * 100, 1) AS m38_pct,
  ROUND(SUM(CASE WHEN months_retained >= 39 THEN 1 ELSE 0 END) / COUNT(*) * 100, 1) AS m39_pct,
  ROUND(SUM(CASE WHEN months_retained >= 40 THEN 1 ELSE 0 END) / COUNT(*) * 100, 1) AS m40_pct,
  ROUND(SUM(CASE WHEN months_retained >= 41 THEN 1 ELSE 0 END) / COUNT(*) * 100, 1) AS m41_pct,
  ROUND(SUM(CASE WHEN months_retained >= 42 THEN 1 ELSE 0 END) / COUNT(*) * 100, 1) AS m42_pct,
  ROUND(SUM(CASE WHEN months_retained >= 43 THEN 1 ELSE 0 END) / COUNT(*) * 100, 1) AS m43_pct,
  ROUND(SUM(CASE WHEN months_retained >= 44 THEN 1 ELSE 0 END) / COUNT(*) * 100, 1) AS m44_pct,
  ROUND(SUM(CASE WHEN months_retained >= 45 THEN 1 ELSE 0 END) / COUNT(*) * 100, 1) AS m45_pct,
  ROUND(SUM(CASE WHEN months_retained >= 46 THEN 1 ELSE 0 END) / COUNT(*) * 100, 1) AS m46_pct,
  ROUND(SUM(CASE WHEN months_retained >= 47 THEN 1 ELSE 0 END) / COUNT(*) * 100, 1) AS m47_pct,
  ROUND(SUM(CASE WHEN months_retained >= 48 THEN 1 ELSE 0 END) / COUNT(*) * 100, 1) AS m48_pct  
FROM retention_monthly
GROUP BY cohort_month
ORDER BY cohort_month;
-- 11년 첫구매자에 비해 14년 첫구매자의 m1 retention의 값이 90% -> 40% 아래로 변경됨을 확인할 수 있음
-- 코호트를 월별 -> 년별로 나눠서 계산하면 더 확실히 추세가 보일 것이라 판단


-- 코호트를 년으로 기준 11년, 12년, 13년 첫 구매자의 구매년도 분석
with user_date as (
select  Customer_ID,
		min(Order_date) as first_order,
		max(Order_date) as last_order
from pro_test.store
group by Customer_ID
),
retention_year as(
select  Customer_ID,
		year(first_order) as cohort_year,
		timestampdiff(year,first_order,last_order) as year_retained
from user_date
)
select  cohort_year,
		count(*) as total_user,
		ROUND(SUM(CASE WHEN year_retained >= 0 THEN 1 ELSE 0 END) / COUNT(*) * 100, 1) AS y1_pct,
		ROUND(SUM(CASE WHEN year_retained >= 1 THEN 1 ELSE 0 END) / COUNT(*) * 100, 1) AS y2_pct,
		ROUND(SUM(CASE WHEN year_retained >= 2 THEN 1 ELSE 0 END) / COUNT(*) * 100, 1) AS y3_pct,
		ROUND(SUM(CASE WHEN year_retained >= 3 THEN 1 ELSE 0 END) / COUNT(*) * 100, 1) AS y4_pct,
		ROUND(SUM(CASE WHEN year_retained >= 4 THEN 1 ELSE 0 END) / COUNT(*) * 100, 1) AS y5_pct
from retention_year
group by cohort_year
order by cohort_year ;
-- 년이 갈수록 구매율이 하락하는 모습을 보임, 이해를 돋기위해 년-월 별 구매건수 확인
		

select  date_format(Order_date, '%Y-%m') as order_date,
		count(*) as total_user
from  pro_test.store
group by date_format(Order_date,'%Y-%m')
order by date_format(Order_date,'%Y-%m') ;
-- 총 구매에 참여한 유저의 수는 계속 증가 하고 있으며 일정한 패턴이 보임
-- 11,12월이 매출의 피크로 확인
-- 동일한 데이터를 매출의 총합으로 확인

select  date_format(Order_date, '%Y-%m') as order_date,
		count(*) as total_uesr,
		round(sum(Profit)) as total_Profit
from pro_test.store
group by date_format(Order_date, '%Y-%m')
order by date_format(Order_date, '%Y-%m') ;
-- 시간이 경과와 비슷하게 총이익과 유저의 수가 증가 하고 있으나 14년 첫 구매자들의 rolling retention에서 두번째 달로 넘어가는 인원이 적음을 확인
-- 14년도 코호트로 분류된 고객을 기존 코호트 고객과 비교하여 차이점 확인 진행

-- 13년 2월 코호트와 14년 2월 코호트 유저 비교
with user_date as(
select Customer_ID,
		min(Order_date) as first_order
from pro_test.store
group by Customer_ID
)
select s.*, u.first_order
from pro_test.store s join user_date u
on s.Customer_ID= u.Customer_ID
where date_format(u.first_order,'%Y-%m') = '2012-02' 
or  date_format(u.first_order,'%Y-%m') = '2014-02' ;

-- 코호트 그룹의 21년2월과 14년2월인 두 그릅만 추출
-- tableau에서 확인 -> market2 컬럼에서 12년2월 apac market 36% 였지만 14년 2원은 0%
-- 각 지역별 재구매 율을 확인 필요
-- 만약 각 지역별 재구매율이 차이가 난다면 이것이 코호트의 감소 원인으로 작용할수 있을것이며
-- 재 규매율이 높은 market 마케팅에 집중하는 방법이 좋을 것이다


with cus_orders as(
select Market2,Customer_ID,
		count(distinct Order_ID) as order_cnts
from pro_test.store
group by Market2, Customer_ID
), rep_customer as (
select Market2,
		count(*) as total_customer,
		SUM(CASE WHEN order_cnts > 1 THEN 1 ELSE 0 END) AS rep_customer
from cus_orders 
group by Market2
)
select Market2,
	total_customer,
	rep_customer,
	round(100 * rep_customer / total_customer, 2) as rep_rate
from rep_customer 
order by round(rep_customer / total_customer * 100, 2) ;
-- APAC 마켓의 고객들의 재 구매율도 높음 
-- 14년2월 코호트 고객은 12년 2월에 비해 해당 마켓의 고객이 적었음
-- 특히 재구매율이 낮은 Africa와 N.America 고객이 더 많았음
-- 재구율이 높은 마켓 위주로 고객 유입을 위한 액션이 필요함


-- 해당 마켓별 profit도 함께 확인
with year_profit as(
select Market2,
		year(Order_date) as order_year,
		round(sum(Profit)) as profit		
from pro_test.store
group by Market2, year(Order_date)
)
select Market2, order_year, profit,
		round((profit - lag(profit) over(partition by Market2 order by order_year))/
	nullif(lag(profit) over(partition by Market2 order by order_year),0),2) as profit_growth
from year_profit
order by Market2, order_year ;


-- 년도 별 market2 의 profit 순위
with pro_table as(
select Market2, 
	year(Order_date) as order_year,
	round(sum(Profit)) as profit
from pro_test.store
group by Market2, year(Order_date)
)
select Market2,
	order_year,
	profit,
	rank () over (partition by order_year order by profit desc ) as ranking
from pro_table
order by order_year, ranking ;
-- APAC의 순위가 높으며 해당 market의 순위 또한 높게 집게 되었다
-- 재구매율과 이익의 순위가 높은 마켓이며 주력해야하는 마켓임을 다시 확인하게 되었다



-- 마지막으로 m2의 재구매율이 낮은 14년도 코호트로 분류된 고객의 Market2를 확인해본다
with user_date as(
select Customer_ID,
		min(Order_date) as first_order
from pro_test.store
group by Customer_ID
), cohort as (
select s.*, u.first_order
from pro_test.store s join user_date u
on s.Customer_ID= u.Customer_ID
where date_format(u.first_order,'%Y-%m') like('2014%')  
)
select Market2,
		count( distinct Customer_ID) as total_user
from  cohort
group by Market2 ;

-- 14년도 코호트로 분류된 고객들의 market을 확인
-- 재 구매율이 높은 eu와 apac, latam 비율이 낮았다
-- 해당 코호트의 재구매율이 낮은 사유는 해당 코호트가 줒로 사용했던 마켓의 성격이라 볼수 있으며
-- 재구매율을 높이기 위해서는 재구매율이 높은 마켓의 고객을 유도할수 있는 방법을 마련해야 한다.






