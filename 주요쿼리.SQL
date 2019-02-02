/* 기본쿼리  */
SELECT * FROM race_info
WHERE race_place='S' AND race_date Like '1/6%'
;

SELECT * FROM race_result
WHERE h_name LIKE '%심청사달%';

/* 경기결과 엑셀자료 race_info.race_seq => race_result.seq 대상 추출
   조회결과로 update문 생성해서 돌림. race_result에 seq 생성 => 나중에 프로시저로 생성
*/
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
         race_ymd ASC -- 일 추출
        ,race_round ASC
;

-- UPDATE 예제
UPDATE race_result SET race_seq = REPLACE('1440',' ','') WHERE race_seq = REPLACE('12.23.15',' ','');
UPDATE race_info SET race_round = replace(race_round,'R',''); -- 라운드 값에서 R 제거
UPDATE race_result SET ranking = '0' WHERE ranking = '' or ranking is null;



/* 우승예상마 추출 */
-- 평균순위 : 마명, 기수 기준 (최근 1년)
 SELECT
       CASE WHEN (@rownum := @rownum+1)-2 > 0
            THEN @rownum-2
            ELSE ''
       END
       AS RNUM,
       A.*
 FROM
 (
  -- // 감싸기
  SELECT '서울1R' as avg_rank,   '2012-1-13' as h_name,  '국6 1000M 별정A'  as last_races FROM race_info WHERE race_seq=1
    UNION ALL
    (SELECT '평균순위' as avg_rank,  '마명' as h_name,  '최근경기일' as last_races FROM race_info LIMIT 0,1)
    UNION ALL
( /* 메인쿼리 Start */
	SELECT
    	    CONCAT(TRUNCATE(AVG(RR.ranking),1),'위') as avg_rank
           ,RR.h_name
           ,MAX(CONCAT(RI.race_year,'/',RI.race_date)) last_races
	  FROM race_result RR
      JOIN race_info RI ON RR.race_seq = RI.race_seq
	 WHERE 1=1
	   AND RR.ranking <> '0' AND RR.ranking <>''
           AND(
               h_name LIKE '%과천공주%'
            OR h_name LIKE '%아임해피%'
            OR h_name LIKE '%송암바비%'
            OR h_name LIKE '%풀문오션%'
            OR h_name LIKE '%당대질주%'
            OR h_name LIKE '%로열샬롬%'
            OR h_name LIKE '%청담퀸즈%'
            OR h_name LIKE '%맥파이%'
            OR h_name LIKE '%금빛열정%'
            OR h_name LIKE '%스틸런%'
            OR h_name LIKE '%우대륭%'
            OR h_name LIKE '%속보옹주%'
              AND RI.entry_grade LIKE '%국6%1000%별A%'
	        )
           AND RI.race_ymd BETWEEN '2018-01-01' AND '2018-12-31'
	 GROUP BY RR.h_name
    /* 메인쿼리 End */
    ) ORDER BY CONVERT(avg_rank,UNSIGNED) asc
    LIMIT 0,6
    -- // 감싸기
 ) A
 , (SELECT @rownum :=0) AS R
;
ㄴ

/* 최근 1년 조회 */
SELECT
       SUBDATE(curdate(),INTERVAL 12 MONTH) as from_mm -- 12개월전
       ,CURDATE() as to_mm
FROM
       race_info
WHERE race_seq = 1
;



