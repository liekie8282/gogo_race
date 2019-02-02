/* 기본쿼리  */
SELECT * FROM race_info
WHERE race_place='S' AND race_date Like '1/6%'
;

SELECT * FROM race_result
WHERE h_name LIKE '%심청사달%';

/* 경기결과 엑셀자료 race_info.race_seq => race_result.seq 대상 추출 */
SELECT
	  	race_seq, -- race_year, race_date, race_round,
        CONCAT(
        REPLACE(SUBSTRING_INDEX(race_date, '(', 1),'/','.')
        ,'.'
        ,REPLACE(race_round,'R','')
        ) as result_date
FROM     race_info
WHERE    race_place   = 'S'
  AND    race_year = '2018'
ORDER by
         convert(SUBSTRING_INDEX(race_date, '/', 1),UNSIGNED) asc  -- 월 추출
        ,convert(SUBSTRING_INDEX(SUBSTRING_INDEX(race_date, '(', 1), '/', -1),UNSIGNED) ASC -- 일 추출
        ,convert(race_round,UNSIGNED) ASC
;

-- UPDATE 예제
UPDATE race_result SET race_seq = REPLACE('1440',' ','') WHERE race_seq = REPLACE('12.23.15',' ',''); COMMIT;

UPDATE race_result SET h_name = '심청사달' WHERE h_name = '★심청사달'; COMMIT;

/* 우승예상마 추출 */
-- 기본데이터 추출
SELECT race_seq, ranking,h_name
  FROM race_result
 WHERE (
		h_name LIKE '%심청사달%'
        OR h_name LIKE '%이겨주마%'
 )
ORDER BY h_name
;

-- 1등 횟수로 추출
-- 2등이내 횟수로 추출
-- 3등이내 횟수로 추출
-- 취소 횟수로 추출



-- 평균순위 : 마명, 기수 기준 (최근 1년)
SELECT *
FROM
(
    /* 메인쿼리 Start */
	SELECT
    	   TRUNCATE(AVG(ranking),1) 평균순위
           ,h_name 마명
           -- ,h_rider 기수
           ,CONCAT(RI.race_year,'/',RI.race_date) 최근경기일
	       ,
	       CONCAT(
	        RI.race_year,'-'
	        ,REPLACE(SUBSTRING_INDEX(RI.race_date, '(', 1),'/','-')
	       ) as result_date

	  FROM race_result RR
           JOIN race_info RI ON RR.race_seq = RI.race_seq
	 WHERE
     		 -- RI.race_year = '2018'
             -- and
	       (/* 경주마 정보 입력 */
			h_name LIKE '%심청사달%'
	        OR h_name LIKE '%이겨주마%'
	        )

  -- and CONCAT(RI.race_year,'-',REPLACE(SUBSTRING_INDEX(RI.race_date, '(', 1),'/','-') ) BETWEEN '2018-01-01' and '2018-07-01'

	 GROUP BY h_name  -- ,h_rider
    /* 메인쿼리 End */

) as RS
ORDER BY RS.평균순위 asc
;


/* 작년 + 현재 조회 */

/* 최근 1년 조회 */
SELECT
       SUBDATE(curdate(),INTERVAL 12 MONTH) as from_mm -- 12개월전
       ,CURDATE() as to_mm
FROM
       race_info
WHERE race_seq = 1
;



