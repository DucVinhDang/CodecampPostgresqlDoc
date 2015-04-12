-- TABLE levels
create TABLE levels (
level_id serial NOT NULL,
name character varying(30) NOT NULL,
descriptiON text,
CONSTRAINT levels_pkey PRIMARY KEY (level_id)
)

-- Bảng questiONs
create TABLE questiONs (
questiON_id serial NOT NULL,
level_id integer NOT NULL,
questiON character varying(150) NOT NULL,
CONSTRAINT questiONs_pkey PRIMARY KEY (questiON_id),
CONSTRAINT questiONs_level_fkey FOREIGN KEY (level_id) REFERENCES levels (level_id),
descriptiON text
)
-- Bảng answers
create TABLE answers (
answer_id serial NOT NULL,
questiON_id integer NOT NULL,
answer character varying(50) NOT NULL,
is_correct boolean DEFAULT FALSE,
CONSTRAINT answers_pkey PRIMARY KEY (answer_id),
CONSTRAINT answers_questiON_fkey FOREIGN KEY (questiON_id) REFERENCES questiONs (questiON_id),
descriptiON text
)
-- Bảng scores
create TABLE scores (
score_id serial NOT NULL,
score integer NOT NULL,
CONSTRAINT scores_pkey PRIMARY KEY (score_id),
CHECK ( score > 0 )

-- Bảng players
create TABLE players (
player_id serial NOT NULL,
score_id integer,
player_name character varying(100) NOT NULL,
beginning_time timestamp NOT NULL,
CONSTRAINT players_pkey PRIMARY KEY (player_id),
CONSTRAINT players_score_fkey FOREIGN KEY (score_id) REFERENCES scores (score_id)
)

-- 1.1 Nhập dữ liệu cho 100 câu hỏi: 20đ 
CREATE OR REPLACE FUNCTION create_random_questiONs_with_number(number integer)
RETURNS void AS
$BODY$
DECLARE
  i integer; j integer; random_level integer; random_bool integer; random_questiON character varying(150); random_answer character varying(50);
BEGIN
  FOR i in 1..$1 LOOP
    random_questiON = (SELECT md5(random()::text));
    random_level = (SELECT round(random() * ((SELECT max(level_id) FROM levels)-1) + 1));
    INSERT INTO questiONs (level_id, questiON) VALUES (random_level,random_questiON);

    random_bool = (SELECT (round(random()*3 + 1) :: integer));
    FOR j in 1..4 LOOP
      random_answer = (SELECT md5(random()::text));

      if (j = random_bool) then
        INSERT INTO answers (questiON_id, answer, is_correct) VALUES ((SELECT max(questiON_id) FROM questiONs), random_answer, TRUE);
      else
        INSERT INTO answers (questiON_id, answer, is_correct) VALUES ((SELECT max(questiON_id) FROM questiONs), random_answer, false);
      end if;
    END LOOP;
  END LOOP;
END;
$BODY$
LANGUAGE plpgsql;

SELECT create_random_questiONs_with_number(100);

-- 1.2. Truy vấn 1 câu hỏi bất kỳ và lấy ra được nội dung câu hỏi, 4 đáp án, đáp án đúng: 5đ
SELECT q.questiON_id, q.questiON, a.answer, a.is_correct
FROM questiONs AS q JOIN answers AS a ON q.questiON_id = a.questiON_id
WHERE q.questiON_id = (SELECT trunc(random() * ( SELECT count(questiON_id) FROM questiONs) + 1))

--2. Có vấn đề mới phát sinh là có phân loại câu hỏi theo 3 mức: Dễ, Trung bình, Khó.
--2.2 Truy vấn số lượng câu hỏi theo mỗi mức độ khó để kiểm tra số lượng câu hỏi cho mỗi mức độ khó đã bằng nhau chưa: 5đ
-- Function trả về TRUE (bằng nhau) hoặc false (chưa bằng nhau):
CREATE OR REPLACE FUNCTION checking_for_balance() RETURNS BOOLEAN AS
$BODY$
DECLARE
x int; y int; z int; level_count int;
BEGIN
	level_count = (SELECT count(level_id) FROM levels);
	x = (SELECT count(level_id) FROM questiONs WHERE level_id = 1);
	FOR i in 2..level_count LOOP
		y = (SELECT count(level_id) FROM questiONs WHERE level_id = i);
		IF x != y THEN
			RETURN false;
		END IF;
	END LOOP;
	RETURN TRUE;
END;
$BODY$
LANGUAGE plpgsql;

SELECT checking_for_balance();

-- 2.3 Truy vấn lấy ngẫu nhiên được 1 câu hỏi thuộc mức độ Dễ (Trung bình, Khó): 5đ
SELECT *
FROM questiONs
WHERE level_id = (SELECT trunc(random() * ( SELECT count(level_id) FROM levels) + 1)) LIMIT 1

-- 2.4 Truy vấn lấy ra ngẫu nhiên 15 câu hỏi và sắp xếp theo thứ tự độ khó tăng dần (mỗi độ khó có 5 câu hỏi sử dụng UNION): 10đ
CREATE OR REPLACE FUNCTION random_fifteen_questiON_and_sort() 
RETURNS TABLE(questiON_id integer, level_id integer, questiON character varying(150))
AS $$
DECLARE 
BEGIN
  RETURN QUERY
    (SELECT questiONs.questiON_id, questiONs.level_id, questiONs.questiON
    FROM questiONs
    WHERE questiONs.level_id = 1 order by RANDOM() LIMIT 5)

    UNION

    (SELECT questiONs.questiON_id, questiONs.level_id, questiONs.questiON
    FROM questiONs
    WHERE questiONs.level_id = 2 order by RANDOM() LIMIT 5)

    UNION

    (SELECT questiONs.questiON_id, questiONs.level_id, questiONs.questiON
    FROM questiONs
    WHERE questiONs.level_id = 3 order by RANDOM() LIMIT 5)

    order by level_id ASC;
END;
$$
LANGUAGE plpgsql;

SELECT * FROM random_fifteen_questiON_and_sort();

-- 3. Lưu được thông tin cấu hình cho game: Số tiền đạt được ứng với số câu hỏi trả lời được (Ví dụ: trả lời được 1 câu được 500k, 2 câu được 800k, …)
-- 3.1 Nhập dữ liệu cấu hình cho game (15 mốc câu hỏi như Ai là triệu phú): 5đ
INSERT INTO scores (score) VALUES (500000), (800000), (1500000), (2500000), (4000000), (6000000), (9000000), (12000000), (16000000), (20000000), (25000000), (32000000), (45000000), (70000000), (100000000)
SELECT * FROM scores

-- 4. Giả lập trợ giúp người chơi (50-50, trợ giúp từ khán giả, gọi điện cho người thân)
-- 4.1 Truy vấn lấy được ngẫu nhiên 2 trONg số 4 đáp án của 1 câu hỏi bất kỳ, trONg đó bắt buộc phải chứa đáp án đúng: 5đ

CREATE OR REPLACE FUNCTION random_two_answer_with_a_correct_answer(questiON_index integer) 
RETURNS TABLE(answer_id integer, questiON_id integer, answer character varying(50), is_correct boolean)
AS $$
DECLARE
BEGIN
RETURN QUERY
	(SELECT answers.answer_id, answers.questiON_id, answers.answer, answers.is_correct
	FROM answers WHERE (answers.is_correct = TRUE and answers.questiON_id = $1))
	UNION
	(SELECT answers.answer_id, answers.questiON_id, answers.answer, answers.is_correct
	FROM answers WHERE answers.is_correct = FALSE and answers.questiON_id = $1
	order by RANDOM()
	LIMIT 1);
END;
$$
LANGUAGE plpgsql;

SELECT * FROM random_two_answer_with_a_correct_answer(2)

-- 4.2 Truy vấn ngẫu nhiên tỉ lệ khán giả chọn đáp án của 1 câu hỏi theo % (Ví dụ: Đáp án A – 20%, B – 30%, C – 40%, D – 10%): 5đ
CREATE OR REPLACE FUNCTION random_rating_answers()
RETURNS TABLE (m integer, n integer, p integer, q integer)
AS $$
DECLARE
a integer;b integer;c integer;d integer;

BEGIN
	d = 100;
	a = round(random() * d);
	d = d - a;
	b = round(random() * d);
	d = d - b;
	c = round(random() * d);
	d = d - c;
RETURN QUERY
SELECT a,b,c,d;
END;
$$
LANGUAGE plpgsql;

SELECT * FROM random_rating_answers()

-- 4.3 Truy vấn ngẫu nhiên đáp án cho 1 câu hỏi: 5đ (Câu hỏi gọi trợ giúp người thân)

CREATE OR REPLACE FUNCTION random_answer_for_a_questiON(questiON_index integer) 
RETURNS TABLE(answer_id integer, questiON_id integer, answer character varying(50), is_correct boolean)
AS $$
DECLARE 
BEGIN
RETURN QUERY
	SELECT answers.answer_id, answers.questiON_id, answers.answer, answers.is_correct
	FROM answers
	WHERE answers.questiON_id = $1 
	order by RANDOM()
	LIMIT 1;
END;
$$
LANGUAGE plpgsql;

SELECT * FROM random_answer_for_a_questiON(2) 

-- 5. Lưu thông tin người chơi bao gồm: Họ tên, Thời điểm chơi, Số tiền đạt được.
-- 5.1 Nhập dữ liệu mẫu 100 người chơi: 5đ
CREATE OR REPLACE FUNCTION before_add_a_player() RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
	NEW.beginning_time = (SELECT now());
RETURN NEW;
END
$$;

CREATE TRIGGER trigger_add_beginning_time_before_INSERT_player
BEFORE INSERT ON players
FOR EACH ROW
EXECUTE PROCEDURE before_add_a_player(); 


CREATE OR REPLACE FUNCTION random_players(max INTEGER) RETURNS void AS
$BODY$
DECLARE
i int; name character varying(10); random_score_id int;
BEGIN
name = 'player';
FOR i in 1..$1 LOOP
random_score_id = (SELECT trunc(random() * ( SELECT count(score_id) FROM scores) + 1));
INSERT INTO players(player_name, score_id) VALUES (CONCAT(name,i), random_score_id);
END LOOP;
END;
$BODY$
LANGUAGE plpgsql;

SELECT random_players(100);

-- 5.2 Truy vấn lấy ra 10 người chơi đạt điểm cao nhất, sắp xếp theo thứ tự điểm cao giảm dần (nếu 2 người chơi có cùng điểm số thì người chơi sau sẽ được xếp ở vị trí cao hơn): 5đ
SELECT * FROM players
order by score_id DESC, beginning_time DESC
LIMIT 10

-- 6. Quản lý game cần thực hiện các chức năng quản lý:
-- 6.1 Tìm kiếm câu hỏi theo id, theo từ khóa trONg câu hỏi, theo từ khóa trONg câu trả lời:
SELECT * FROM questiONs WHERE questiON_id = 3
SELECT * FROM questiONs WHERE questiON LIKE '%uo%'

-- 6.2 Cập nhật nội dung một câu hỏi, cập nhật nội dung câu trả lời: 5đ
UPDATE questiONs
SET questiON = 'Nuoc nao co dien tich nho nhat the gioi?'
WHERE questiON_id = 1

UPDATE answers
SET answer = 'Nuoc My'
WHERE answer_id = 1 and questiON_id = 1

-- 6.3 Xóa một câu hỏi: 5đ
CREATE OR REPLACE FUNCTION before_remove_a_questiON() RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
DELETE FROM answers WHERE questiON_id = OLD.questiON_id;
RETURN OLD;
END
$$;

CREATE TRIGGER trigger_delete_answers_before_delete_questiON
BEFORE DELETE ON questiONs
FOR EACH ROW
EXECUTE PROCEDURE before_remove_a_questiON();

DELETE FROM questiONs WHERE question_id = 4