-- 거래날짜별 할인, 세금, 배송료 계산  

WITH OnlinesalesWithMonth AS (
    SELECT 
        o.고객ID, o.거래ID, o.거래날짜, o.제품ID, o.제품카테고리, o.수량, o.평균금액, o.배송료, o.쿠폰상태,                   
        ROUND((o.평균금액 * o.수량), 2) AS 총금액, -- 세금 & 할인 전 원래 총금액

        -- 거래날짜에서 MM만 추출하여 'Jan', 'Feb' 등으로 변환
        CASE SUBSTRING(o.거래날짜, 6, 2)  
            WHEN '01' THEN 'Jan' WHEN '02' THEN 'Feb' WHEN '03' THEN 'Mar'
            WHEN '04' THEN 'Apr' WHEN '05' THEN 'May' WHEN '06' THEN 'Jun'
            WHEN '07' THEN 'Jul' WHEN '08' THEN 'Aug' WHEN '09' THEN 'Sep'
            WHEN '10' THEN 'Oct' WHEN '11' THEN 'Nov' WHEN '12' THEN 'Dec'
        END AS 할인월,

        -- "ROW_NUMBER()"를 사용해 같은 거래ID 내에서 첫 번째 행 찾기
        ROW_NUMBER() OVER (PARTITION BY o.거래ID ORDER BY o.제품ID) AS 행번호  

    FROM Onlinesales o
),

FinalResult AS (
    SELECT 
        os.고객ID, os.거래ID, os.거래날짜, os.제품ID, os.제품카테고리, os.수량, os.평균금액, os.배송료, os.쿠폰상태,  
        os.총금액,  
        -- 쿠폰이 'Used'인 경우 할인율 적용 (할인 먼저 적용)
        CASE 
            WHEN os.쿠폰상태 = 'Used' AND d.할인율 IS NOT NULL 
            THEN d.할인율
            ELSE 0  
        END AS 할인율,

        -- "할인 적용 후 금액" 계산 (할인 먼저 적용)
        ROUND(
            CASE 
                WHEN os.쿠폰상태 = 'Used' AND d.할인율 IS NOT NULL  
                THEN os.총금액 * (1 - d.할인율 / 100)  
                ELSE os.총금액  
            END, 2) AS "할인적용금액",
        t.GST,

        -- "할인 적용 후" 세금 부과 (할인 먼저 적용 후 GST 계산)
        ROUND(
            CASE 
                WHEN os.쿠폰상태 = 'Used' AND d.할인율 IS NOT NULL  
                THEN (os.총금액 * (1 - d.할인율 / 100)) * (1 + t.GST)
                ELSE os.총금액 * (1 + t.GST)
            END, 2) AS "총금액(세금)",

        -- 거래ID 기준 첫 번째 행에만 배송료 추가
        ROUND(
            CASE 
                WHEN os.행번호 = 1 THEN 
                    CASE 
                        WHEN os.쿠폰상태 = 'Used' AND d.할인율 IS NOT NULL  
                        THEN ((os.총금액 * (1 - d.할인율 / 100)) * (1 + t.GST)) + os.배송료
                        ELSE (os.총금액 * (1 + t.GST)) + os.배송료
                    END
                ELSE 
                    CASE 
                        WHEN os.쿠폰상태 = 'Used' AND d.할인율 IS NOT NULL  
                        THEN (os.총금액 * (1 - d.할인율 / 100)) * (1 + t.GST)
                        ELSE os.총금액 * (1 + t.GST)
                    END
            END, 2) AS "최종금액"

    FROM OnlinesalesWithMonth os
    LEFT JOIN Discount d
    ON os.할인월 = d.월 AND os.제품카테고리 = d.제품카테고리
    LEFT JOIN Tax t
    ON os.제품카테고리 = t.제품카테고리
)

SELECT * FROM FinalResult
ORDER BY 거래ID, 제품ID;



-- 거래 날짜별 매출 비용 집계

WITH OnlinesalesWithMonth AS (
    SELECT 
        o.고객ID, o.거래ID, o.거래날짜, o.제품ID, o.제품카테고리, o.수량, o.평균금액, o.배송료, o.쿠폰상태,                   
        ROUND((o.평균금액 * o.수량), 2) AS 총금액, -- 세금 & 할인 전 원래 총금액

        -- 거래날짜에서 MM만 추출하여 'Jan', 'Feb' 등으로 변환
        CASE SUBSTRING(o.거래날짜, 6, 2)  
            WHEN '01' THEN 'Jan' WHEN '02' THEN 'Feb' WHEN '03' THEN 'Mar'
            WHEN '04' THEN 'Apr' WHEN '05' THEN 'May' WHEN '06' THEN 'Jun'
            WHEN '07' THEN 'Jul' WHEN '08' THEN 'Aug' WHEN '09' THEN 'Sep'
            WHEN '10' THEN 'Oct' WHEN '11' THEN 'Nov' WHEN '12' THEN 'Dec'
        END AS 할인월,

        -- "ROW_NUMBER()"를 사용해 같은 거래ID 내에서 첫 번째 행 찾기
        ROW_NUMBER() OVER (PARTITION BY o.거래ID ORDER BY o.제품ID) AS 행번호  

    FROM Onlinesales o
),

FinalResult AS (
    SELECT 
        os.거래날짜,
        os.쿠폰상태,  
        t.GST,

        -- 거래ID 기준 첫 번째 행에만 배송료 추가
        ROUND(
            CASE 
                WHEN os.행번호 = 1 THEN 
                    CASE 
                        WHEN os.쿠폰상태 = 'Used' AND d.할인율 IS NOT NULL -- 쿠폰 유무에 따라 계산
                        THEN ((os.총금액 * (1 - d.할인율 / 100)) * (1 + t.GST)) + os.배송료
                        ELSE (os.총금액 * (1 + t.GST)) + os.배송료
                    END
                ELSE 
                    CASE 
                        WHEN os.쿠폰상태 = 'Used' AND d.할인율 IS NOT NULL -- 쿠폰 유무에 따라 계산
                        THEN (os.총금액 * (1 - d.할인율 / 100)) * (1 + t.GST)
                        ELSE os.총금액 * (1 + t.GST)
                    END
            END, 2) AS "최종금액"

    FROM OnlinesalesWithMonth os
    LEFT JOIN Discount d
    ON os.할인월 = d.월 AND os.제품카테고리 = d.제품카테고리
    LEFT JOIN Tax t
    ON os.제품카테고리 = t.제품카테고리
),

SalesWithMarketing AS (
    -- 거래날짜 기준으로 마케팅 테이블의 오프라인/온라인 비용/마케팅비용 계산
    SELECT 
        f.거래날짜, 
        SUM(f.최종금액) AS 일매출,  
        ROUND(COALESCE(m.오프라인비용, 0), 2) AS 오프라인비용, 
        ROUND(COALESCE(m.온라인비용, 0), 2) AS 온라인비용,
        -- 마케팅비용 = 오프라인비용 + 온라인비용
        ROUND(COALESCE(m.오프라인비용, 0) + COALESCE(m.온라인비용, 0), 2) AS 마케팅비용,  
        -- 손익 = 일매출 - 마케팅비용
        ROUND(SUM(f.최종금액) - (COALESCE(m.오프라인비용, 0) + COALESCE(m.온라인비용, 0)), 2) AS 손익,
        -- 쿠폰 사용 횟수
        COUNT(CASE WHEN f.쿠폰상태 = 'Used' THEN 1 END) AS 쿠폰사용,
        -- 쿠폰 미사용 횟수
        COUNT(CASE WHEN f.쿠폰상태 != 'Used' OR f.쿠폰상태 IS NULL THEN 1 END) AS 쿠폰미사용

    FROM FinalResult f
    LEFT JOIN Marketing m  
    ON f.거래날짜 = m.날짜
    GROUP BY f.거래날짜, m.오프라인비용, m.온라인비용
    ORDER BY f.거래날짜
)

SELECT * FROM SalesWithMarketing;


-- 재구매 고객과 신규 고객의 수 확인
with buy_cnts as (
select 고객ID, count(distinct 거래Id) as buy_cnt
from dev_project.onlinesales
group by 고객ID 
), customer_types as(
select 고객ID, buy_cnt,
	case when buy_cnt = 1 then 'new'
		else 'old'
	end as customer_type
from buy_cnts 
)
select customer_type,
		count(distinct 고객ID) as cnt
from customer_types
group by customer_type
-- 재구매 고객의 수가 91.% 이상으로 신규 고객보다 많았음

-- 신규고객과 재구매 고객의 구매하는 제품카테고리 확인
with buy_cnts as (
select 고객ID, count(distinct 거래Id) as buy_cnt
from dev_project.onlinesales
group by 고객ID 
), customer_types as(
select 고객ID, buy_cnt,
	case when buy_cnt = 1 then 'new'
		else 'old'
	end as customer_type
from buy_cnts 
), category_cnt as (
select c.customer_type, o.제품카테고리,count(*) as purchase_cnt
from dev_project.onlinesales o join customer_types c
on o.고객ID = c.고객ID
group by c.customer_type, o.제품카테고리
), cate_ranking as (
select *,
		row_number() over(partition by customer_type order by purchase_cnt desc) as rn
from category_cnt 
)
select customer_type, 제품카테고리, purchase_cnt, rn
from cate_ranking
where rn < 10
-- 거의 비슷한 카테고리 형성이고 신규고객의 수가 8% 정도라서 순위보다는 카테고리가 있는지 중점적으로 확인



-- 19년도 공휴일 자료를 붙여 주말 공휴일 평일의 평균 매출을 비교해 본다
 with sales_with_date as(
 select o.*, h.공휴일,
 		DAYOFWEEK(STR_TO_DATE(o.거래날짜, '%Y-%m-%d')) AS 요일번호,
 		(o.수량*o.평균금액) as 매출,
 		case 
 			when h.공휴일 IS NOT NULL THEN '공휴일'
 			when dayofweek(str_to_date(o.거래날짜,'%Y-%m-%d')) in (1,7) then '주말'
 			else '평일'
 		end as day_type
 from dev_project.onlinesales o left join holidays h
 on STR_TO_DATE(o.거래날짜, '%Y-%m-%d') = h.날짜
 )
 select day_type,
 		round(avg(매출),2) as 평균매출,
 		count(*) as 거래건수
 from sales_with_date
 group by day_type
-- 공휴일, 평일, 주말 순으로 평균매출이 높게 나타났다 
 
 -- 공휴일 , 평일, 주말 데이터 추출하여 평균으로 통계적 유효성 검사 및 효과의 크기 확인
 -- 데이터 추출 쿼리
 with sales_with_date as(
select o.*, h.공휴일,
		DAYOFWEEK(STR_TO_DATE(o.거래날짜, '%Y-%m-%d')) AS 요일번호,
		(o.수량*o.평균금액) as 매출,
		case 
			when h.공휴일 IS NOT NULL THEN '공휴일'
			when dayofweek(str_to_date(o.거래날짜,'%Y-%m-%d')) in (1,7) then '주말'
			else '평일'
		end as day_type
from dev_project.onlinesales o left join holidays h
on STR_TO_DATE(o.거래날짜, '%Y-%m-%d') = h.날짜
)
select day_type, 매출 as sales
from sales_with_date
 

