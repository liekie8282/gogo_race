DELIMITER $$
# DROP PROCEDURE IF EXISTS 'SP_SET_RACEINFO_YMD'
CREATE PROCEDURE SP_SET_RACEINFO_YMD()

BEGIN

    # 프로시저 내부 변수 정의
    DECLARE wEndOfRow SMALLINT UNSIGNED DEFAULT 0;
    DECLARE result_count INT DEFAULT '0';
	DECLARE var_race_date VARCHAR(10) DEFAULT '0';
	DECLARE var_race_ymd VARCHAR(10) DEFAULT '0';

    # 커서 정의
    DECLARE cur CURSOR FOR

    /* race_ymd 데이터 추출 START */
		SELECT  race_date,
			  	-- 0+월, 0+일 수정
				CONCAT(
		        	md.race_year, '-',
				    		CASE
						     WHEN LENGTH(md.race_m) < 2 THEN CONCAT('0',md.race_m)
					         ELSE md.race_m
						END
				        ,'-',
						CASE
						     WHEN LENGTH(md.race_d) < 2 THEN CONCAT('0',md.race_d)
					         ELSE md.race_d
						END
				) as race_ymd
		 FROM
			   (
			    -- 월,일 추출
				SELECT race_date, race_year,
				  SUBSTRING_INDEX(race_date, '/', 1) as race_m
				  ,
				  SUBSTRING_INDEX(SUBSTRING_INDEX(race_date, '/', -1) , '(',1)
				  as race_d
				FROM race_info
		        -- WHERE race_date LIKE '1/13%' and race_round='1R'
				--
				) md
           GROUP  BY race_date, race_ymd
    /* race_ymd 데이터 추출 END */
    ;

    # NOT FOUND 핸들러 정의 (마지막 행 FETCH 후 처리할 내용)
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET wEndOfRow = 1;

    # 커서 오픈 (실제로 쿼리가 실행되는 시점)
    OPEN cur;

    # 루프를 돌면서 각 행을 패치
    cur_loop: WHILE wEndOfRow = 0 DO

        FETCH cur INTO var_race_date, var_race_ymd;

        IF wEndOfRow > 0 THEN LEAVE cur_loop; END IF;

            UPDATE race_info
			SET    race_ymd = var_race_ymd
			WHERE  race_date= var_race_date

        ;

    END WHILE cur_loop;

    CLOSE cur;
 END $$

DELIMITER ;