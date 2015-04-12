/*create table levels (
	level_id serial NOT NULL,
	name character varying(30) NOT NULL,
	description text,
	CONSTRAINT levels_pkey PRIMARY KEY (level_id)
)*/

/*create table questions (
	question_id serial NOT NULL,
	level_id integer NOT NULL,
	question character varying(150) NOT NULL,
	CONSTRAINT questions_pkey PRIMARY KEY (question_id),
	CONSTRAINT questions_level_fkey FOREIGN KEY (level_id) REFERENCES levels (level_id),
	description text
)*/

/*create table answers (
	answer_id serial NOT NULL,
	question_id integer NOT NULL,
	answer character varying(50) NOT NULL,
	is_correct boolean DEFAULT FALSE,
	CONSTRAINT answers_pkey PRIMARY KEY (answer_id),
	CONSTRAINT answers_question_fkey FOREIGN KEY (question_id) REFERENCES questions (question_id),
	description text
)*/

/*create table scores (
	score_id serial NOT NULL,
	score integer NOT NULL,
	CONSTRAINT scores_pkey PRIMARY KEY (score_id),
	CHECK ( score > 0 )
)*/

/*create table players (
	player_id serial NOT NULL,
	score_id integer,
	player_name character varying(100) NOT NULL,
	beginning_time timestamp NOT NULL,
	CONSTRAINT players_pkey PRIMARY KEY (player_id),
	CONSTRAINT players_score_fkey FOREIGN KEY (score_id) REFERENCES scores (score_id)
)*/

/*insert into levels (name) values ('De'), ('Trung Binh'), ('Kho')*/

/*insert into questions (level_id, question) values (1,'Nuoc nao lon nhat the gioi?'), (2,'Chim nao dap canh voi tan suat lon nhat?'), (3,'Vo anh Cuong ten la gi?')*/

/*insert into answers (question_id, answer, is_correct) values (1, 'My', FALSE), (1, 'Trung Quoc', FALSE), (1, 'Nga', TRUE), (1, 'Brazil', FALSE)*/
/*insert into answers (question_id, answer, is_correct) values (2, 'Dai bang', FALSE), (2, 'Chim ruoi', TRUE), (2, 'Chim en', FALSE), (2, 'Da dieu', FALSE)*/
/*insert into answers (question_id, answer, is_correct) values (3, 'Thu', TRUE), (3, 'Hien', FALSE), (3, 'Huyen', FALSE), (3, 'Nguyet', FALSE)*/

/*select q.question, a.answer, a.is_correct
from questions as q join answers as a on q.question_id = a.question_id*/

/* 1.1 () */

/* 1.2 (Done) */

/*select q.question_id, q.question, a.answer, a.is_correct
from questions as q join answers as a on q.question_id = a.question_id
where q.question_id = (select trunc(random() * ( select count(question_id) from questions) + 1))*/

/* 1.3 () */

/* 2.1 (Done) */

/* 2.2 (Done) */

/*CREATE OR REPLACE FUNCTION checking_for_balance() RETURNS void AS
$BODY$
DECLARE
  x int; y int; z int; level_count int;
BEGIN
  level_count = (select count(level_id) from levels);
  x = (select count(level_id) from questions where level_id = 1);
  FOR i in 2..level_count LOOP
    y = (select count(level_id) from questions where level_id = i);
    IF x != y THEN
	RAISE EXCEPTION 'So luong cau hoi giua cac level khong bang nhau';
    END IF;
  END LOOP;
END;
$BODY$
LANGUAGE plpgsql;

select checking_for_balance();

insert into questions (level_id, question) values (1,'Con gi gay vao buoi sang?')
insert into answers (question_id, answer, is_correct) values (4, 'Ngan', FALSE), (4, 'Ngong', FALSE), (4, 'Vit', FALSE), (4, 'Ga', TRUE)

select* from questions */

/* 2.3 (Done) */

/*select *
from questions
where level_id = (select trunc(random() * ( select count(level_id) from levels) + 1)) limit 1
*/

/* 2.4 (Done) */

/*
CREATE OR REPLACE FUNCTION random_fifteen_question_and_sort() 
RETURNS TABLE(question_id integer, level_id integer, question character varying(150))
AS $$
DECLARE 
BEGIN
  RETURN QUERY
  select c.question_id, c.level_id, c.question
  from
	(  select b.question_id, b.level_id, b.question
	  from 
	   ( select questions.question_id, questions.level_id, questions.question
	    from questions
	    where questions.level_id = 1
	    
	    UNION
	    
	    select questions.question_id, questions.level_id, questions.question
	    from questions
	    where questions.level_id = 2
	    
	    UNION
	    
	    select questions.question_id, questions.level_id, questions.question
	    from questions
	    where questions.level_id = 3 ) as b
	    
	    order by RANDOM()
	    limit 15 ) as c
  order by c.level_id ASC;

END;
$$
LANGUAGE plpgsql;

select * from random_fifteen_question_and_sort();
*/

/* 3.1 (Done) */

/*
insert into scores (score) values (500000), (800000), (1500000), (2500000), (4000000), (6000000), (9000000), (12000000), (16000000), (20000000), (25000000), (32000000), (45000000), (70000000), (100000000)
select * from scores
*/

/* 4.1 (Done) */

/*
CREATE OR REPLACE FUNCTION random_two_answer_with_a_correct_answer(question_index integer) 
RETURNS TABLE(answer_id integer, question_id integer, answer character varying(50), is_correct boolean)
AS $$
DECLARE
BEGIN
  RETURN QUERY
    select answers.answer_id, answers.question_id, answers.answer, answers.is_correct
    from answers where (answers.is_correct = TRUE and answers.question_id = $1) 
    or (answers.is_correct = FALSE and answers.answer_id = (select trunc(random() * 4 +  ( select min(answers.answer_id) from answers where answers.question_id = $1))))
    order by answers.is_correct DESC
    limit 2;
END;
$$
LANGUAGE plpgsql;

select * from answers
select * from random_two_answer_with_a_correct_answer(2)
*/

/* 4.2 () */

/*
CREATE OR REPLACE FUNCTION random_rating_answers()
RETURNS table (m integer, n integer, p integer integer)
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
   select a,b,c,d;
END;
$$
LANGUAGE plpgsql;

select * from random_rating_answers()
*/

/* 4.3 (Done) */

/*
CREATE OR REPLACE FUNCTION random_answer_for_a_question(question_index integer) 
RETURNS TABLE(answer_id integer, question_id integer, answer character varying(50), is_correct boolean)
AS $$
DECLARE 
BEGIN
  RETURN QUERY
    select answers.answer_id, answers.question_id, answers.answer, answers.is_correct
    from answers
    where answers.answer_id = (select trunc(random() *4 +  ( select min(answers.answer_id) from answers where answers.question_id = $1))); 
END;
$$
LANGUAGE plpgsql;

select * from random_answer_for_a_question(2) 
*/

/* 5.1 (Done) */

/*
CREATE OR REPLACE FUNCTION before_add_a_player() RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
  NEW.beginning_time = (select now());
  return NEW;
END
$$;

CREATE TRIGGER trigger_add_beginning_time_before_insert_player
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
    random_score_id = (select trunc(random() * ( select count(score_id) from scores) + 1));
    insert into players(player_name, score_id) values (CONCAT(name,i), random_score_id);
  END LOOP;
END;
$BODY$
LANGUAGE plpgsql;

select random_players(100);

select * from players
*/

/* 5.2 (Done) */

/*
select * from players
order by score_id DESC, beginning_time DESC
limit 10
*/

/* 6.1 (Done) */

/*
select * from questions where question_id = 3
select * from questions where question LIKE '%uo%'
*/

/* 6.2 (Done) */
/*
select * from questions

update questions
set question = 'Nuoc nao co dien tich nho nhat the gioi?'
where question_id = 1

select * from questions

select * from answers

update answers
set answer = 'Phap'
where question_id = 1 and answer_id = 1

select * from answers
*/

/* 6.3 (Done) */
/*
CREATE OR REPLACE FUNCTION before_remove_a_question() RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
  delete from answers where question_id = OLD.question_id;
  return OLD;
END
$$;

CREATE TRIGGER trigger_delete_answers_before_delete_question
BEFORE DELETE ON questions
FOR EACH ROW
EXECUTE PROCEDURE before_remove_a_question();

select * from questions
select * from answers
delete from questions where question_id = 4
*/

select * from answers


