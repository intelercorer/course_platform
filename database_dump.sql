--
-- PostgreSQL database dump
--

-- Dumped from database version 16.2
-- Dumped by pg_dump version 16.2

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: addauthor(character varying, character varying, integer, character varying, character varying, character varying); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.addauthor(IN name character varying, IN surname character varying, IN age integer, IN email character varying, IN login character varying, IN password character varying)
    LANGUAGE sql
    AS $$
INSERT INTO authors (name, surname, email, login, password, age) VALUES
(name, surname, email, login, password, age);
$$;


ALTER PROCEDURE public.addauthor(IN name character varying, IN surname character varying, IN age integer, IN email character varying, IN login character varying, IN password character varying) OWNER TO postgres;

--
-- Name: check_lesson_completion(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.check_lesson_completion() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM students_progress sp
        JOIN lessons l ON sp.lesson_id = l.lesson_id
        JOIN enrollments e ON sp.student_id = e.student_id
        WHERE e.course_id = l.course_id 
            AND sp.completion_date < e.enrollment_date
    ) THEN
        RAISE EXCEPTION 'Урок не может быть закончен раньше записи на курс';
    END IF;
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.check_lesson_completion() OWNER TO postgres;

--
-- Name: update_course_duration(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.update_course_duration() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    total_lessons INTEGER;
BEGIN
    SELECT COUNT(*) INTO total_lessons
    FROM lessons
    WHERE course_id = NEW.course_id;

    UPDATE courses
    SET duration = total_lessons
    WHERE course_id = NEW.course_id;

    RETURN NEW;
END;
$$;


ALTER FUNCTION public.update_course_duration() OWNER TO postgres;

--
-- Name: update_student_course_status(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.update_student_course_status() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    total_lessons INTEGER;
    completed_lessons INTEGER;
BEGIN
    -- Получаем общее количество уроков в курсе
    SELECT duration INTO total_lessons
    FROM courses
    WHERE course_id = (
        SELECT course_id
        FROM lessons
        WHERE lesson_id = NEW.lesson_id
    );

    -- Получаем количество пройденных студентом уроков по курсу
    SELECT COUNT(*)
    INTO completed_lessons
    FROM students_progress sp
    JOIN lessons l ON sp.lesson_id = l.lesson_id
    WHERE sp.student_id = NEW.student_id
        AND l.course_id = (
            SELECT course_id
            FROM lessons
            WHERE lesson_id = NEW.lesson_id
        );

    -- Обновляем статус студента в таблице enrollments
    IF completed_lessons >= total_lessons THEN
        UPDATE enrollments
        SET status = 'завершен'
        WHERE student_id = NEW.student_id
          AND course_id = (
            SELECT course_id
            FROM lessons
            WHERE lesson_id = NEW.lesson_id
        );
    ELSE
        UPDATE enrollments
        SET status = 'не завершен'
        WHERE student_id = NEW.student_id
          AND course_id = (
            SELECT course_id
            FROM lessons
            WHERE lesson_id = NEW.lesson_id
        );
    END IF;
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.update_student_course_status() OWNER TO postgres;

--
-- Name: update_student_status(); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION public.update_student_status() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    total_lessons INTEGER;
    completed_lessons INTEGER;
BEGIN
    SELECT duration INTO total_lessons
    FROM courses
    WHERE course_id = (
        SELECT course_id
        FROM lessons
        WHERE lesson_id = NEW.lesson_id
    );

    SELECT COUNT(*)
    INTO completed_lessons
    FROM students_progress sp
    JOIN lessons l ON sp.lesson_id = l.lesson_id
    WHERE sp.student_id = NEW.student_id
        AND l.course_id = (
            SELECT course_id
            FROM lessons
            WHERE lesson_id = NEW.lesson_id
        );

    IF completed_lessons >= total_lessons THEN
        UPDATE enrollments
        SET status = 'завершен'
        WHERE student_id = NEW.student_id
          AND course_id = (
            SELECT course_id
            FROM lessons
            WHERE lesson_id = NEW.lesson_id
        );
    END IF;

    RETURN NEW;
END;
$$;


ALTER FUNCTION public.update_student_status() OWNER TO admin;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: authors; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.authors (
    author_id bigint NOT NULL,
    name character varying(16) NOT NULL,
    surname character varying(32) NOT NULL,
    email character varying(64) NOT NULL,
    login character varying(64) NOT NULL,
    password character varying(32) NOT NULL,
    age integer NOT NULL,
    CONSTRAINT authors_age_check CHECK (((age >= 18) AND (age <= 120))),
    CONSTRAINT authors_email_check CHECK (((email)::text ~ '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'::text))
);


ALTER TABLE public.authors OWNER TO postgres;

--
-- Name: authors_author_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.authors ALTER COLUMN author_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.authors_author_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: courses; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.courses (
    course_id bigint NOT NULL,
    title character varying(64) NOT NULL,
    description text,
    duration integer DEFAULT 0 NOT NULL,
    price money NOT NULL,
    author_id bigint NOT NULL
);


ALTER TABLE public.courses OWNER TO admin;

--
-- Name: courses_author_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE public.courses_author_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.courses_author_id_seq OWNER TO admin;

--
-- Name: courses_author_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE public.courses_author_id_seq OWNED BY public.courses.author_id;


--
-- Name: courses_courses_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE public.courses_courses_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.courses_courses_id_seq OWNER TO admin;

--
-- Name: courses_courses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE public.courses_courses_id_seq OWNED BY public.courses.course_id;


--
-- Name: enrollments; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.enrollments (
    enrollment_id bigint NOT NULL,
    student_id bigint NOT NULL,
    course_id bigint NOT NULL,
    enrollment_date timestamp with time zone NOT NULL,
    payment_status character varying(10) DEFAULT 'не оплачен'::character varying NOT NULL,
    status character varying(11) DEFAULT 'не завершен'::character varying NOT NULL,
    CONSTRAINT enrollments_payment_status_check CHECK ((((payment_status)::text = 'не оплачен'::text) OR ((payment_status)::text = 'оплачен'::text))),
    CONSTRAINT enrollments_status_check CHECK ((((status)::text = 'не завершен'::text) OR ((status)::text = 'завершен'::text)))
);


ALTER TABLE public.enrollments OWNER TO admin;

--
-- Name: enrollments_enrollment_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

ALTER TABLE public.enrollments ALTER COLUMN enrollment_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.enrollments_enrollment_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: lessons; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.lessons (
    lesson_id bigint NOT NULL,
    course_id bigint NOT NULL,
    title character varying(64) NOT NULL,
    description text,
    link text NOT NULL,
    other text,
    lesson_number integer NOT NULL
);


ALTER TABLE public.lessons OWNER TO admin;

--
-- Name: lessons_lesson_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

ALTER TABLE public.lessons ALTER COLUMN lesson_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.lessons_lesson_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: responses; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.responses (
    response_id bigint NOT NULL,
    course_id bigint NOT NULL,
    student_id bigint NOT NULL,
    rating integer NOT NULL,
    comment text,
    CONSTRAINT responses_rating_check CHECK (((rating >= 1) AND (rating <= 5)))
);


ALTER TABLE public.responses OWNER TO admin;

--
-- Name: responses_response_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

ALTER TABLE public.responses ALTER COLUMN response_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.responses_response_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: students; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.students (
    student_id bigint NOT NULL,
    name character varying(16) NOT NULL,
    surname character varying(32) NOT NULL,
    email character varying(64) NOT NULL,
    login character varying(64) NOT NULL,
    password character varying(32) NOT NULL,
    age integer NOT NULL,
    CONSTRAINT students_age_check CHECK (((age >= 7) AND (age <= 120))),
    CONSTRAINT students_email_check CHECK (((email)::text ~ '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'::text))
);


ALTER TABLE public.students OWNER TO admin;

--
-- Name: students_progress; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.students_progress (
    progress_id bigint NOT NULL,
    student_id bigint NOT NULL,
    lesson_id bigint NOT NULL,
    completion_date timestamp with time zone NOT NULL,
    test_score integer
);


ALTER TABLE public.students_progress OWNER TO admin;

--
-- Name: students_progress_progress_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

ALTER TABLE public.students_progress ALTER COLUMN progress_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.students_progress_progress_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: students_student_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

ALTER TABLE public.students ALTER COLUMN student_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.students_student_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: courses course_id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.courses ALTER COLUMN course_id SET DEFAULT nextval('public.courses_courses_id_seq'::regclass);


--
-- Data for Name: authors; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.authors (author_id, name, surname, email, login, password, age) FROM stdin;
1	Гордей	Щербакова	yponomareva@example.net	galkinaverki	81dc9bdb52d04dc20036dbd8313ed055	55
2	Лев	Большаков	hohlovevse@example.net	kliment_65	81dc9bdb52d04dc20036dbd8313ed055	32
3	Зиновий	Маркова	klavdi_2010@example.net	svjatoslavfilippov	81dc9bdb52d04dc20036dbd8313ed055	42
4	Милен	Комиссаров	ziminilja@example.org	mihe2012	81dc9bdb52d04dc20036dbd8313ed055	43
5	Светлана	Рогов	savvaermakov@example.com	ljubov_77	81dc9bdb52d04dc20036dbd8313ed055	73
6	Иванна	Борисова	samsonovaaleksandra@example.net	hkotova	81dc9bdb52d04dc20036dbd8313ed055	74
7	Артемий	Щербакова	ivan_89@example.com	stepan98	81dc9bdb52d04dc20036dbd8313ed055	72
8	Устин	Блинов	askoldchernov@example.com	vladimirsavin	81dc9bdb52d04dc20036dbd8313ed055	76
9	Юлиан	Мясникова	golubevsevastjan@example.org	florentinshubin	81dc9bdb52d04dc20036dbd8313ed055	53
10	Прохор	Сергеева	nina78@example.net	mefodi_1984	81dc9bdb52d04dc20036dbd8313ed055	36
11	Демид	Силина	prokofimedvedev@example.net	aleksandrovpantelemon	81dc9bdb52d04dc20036dbd8313ed055	18
12	Ираклий	Дементьев	ssaveleva@example.org	gerasimmolchanov	81dc9bdb52d04dc20036dbd8313ed055	70
13	Павел	Сидорова	dshchukin@example.net	fedoseevgedeon	81dc9bdb52d04dc20036dbd8313ed055	71
14	Сильвестр	Соколов	kapustinapelageja@example.net	prokofi1992	81dc9bdb52d04dc20036dbd8313ed055	69
15	Сидор	Щукин	antonina_13@example.org	leonid2012	81dc9bdb52d04dc20036dbd8313ed055	24
16	Данила	Носов	vitali_1973@example.org	akulina27	81dc9bdb52d04dc20036dbd8313ed055	40
17	Прохор	Пономарева	sokrat2002@example.net	ymartinov	81dc9bdb52d04dc20036dbd8313ed055	66
18	Климент	Филатов	kirillovhariton@example.org	ruben_1999	81dc9bdb52d04dc20036dbd8313ed055	47
19	Ярополк	Семенов	krilovjakov@example.com	melnikovavalerija	81dc9bdb52d04dc20036dbd8313ed055	33
20	Октябрина	Сидорова	kotovazhanna@example.com	valentin_2020	81dc9bdb52d04dc20036dbd8313ed055	48
21	Егор	Вихлянцев	egor.vihlyantsev@yandex.ru	egor5	81dc9bdb52d04dc20036dbd8313ed055	20
\.


--
-- Data for Name: courses; Type: TABLE DATA; Schema: public; Owner: admin
--

COPY public.courses (course_id, title, description, duration, price, author_id) FROM stdin;
4	Основы программирования на Python	Введение в основы программирования на языке Python. Обзор основных конструкций и инструментов разработки.	6	1 999,99 ?	1
5	Веб-разработка с использованием HTML и CSS	Курс по созданию веб-сайтов с использованием HTML и CSS. Изучение основных тегов HTML и стилей CSS.	6	1 499,99 ?	2
6	Основы баз данных: SQL и PostgreSQL	Изучение языка SQL и работы с базами данных на примере PostgreSQL. Создание, изменение и удаление данных.	6	2 499,99 ?	3
7	JavaScript для начинающих	Основы программирования на языке JavaScript. Введение в язык, работа с переменными, функциями и объектами.	6	2 999,99 ?	4
8	Введение в анализ данных с Python	Основы работы с данными с использованием языка Python. Анализ данных, визуализация и простые статистические расчеты.	6	3 499,99 ?	5
9	Мобильная разработка на Android	Изучение основ мобильной разработки на платформе Android. Создание приложений с использованием Java и Kotlin.	6	3 999,99 ?	6
10	Алгоритмы и структуры данных	Изучение основных алгоритмов и структур данных. Работа с массивами, списками, деревьями и графами.	6	4 499,99 ?	7
17	Лучший курс	Самый лучший курс в рунете по созданию курсов	1	0,00 ?	21
18	Второй лучший курс	Лучший курс в рунете по прочтению лучшего курса в рунете	1	0,00 ?	21
11	Разработка игр на Unity	Основы создания компьютерных игр на движке Unity. Работа с объектами, сценами, физикой и анимацией.	6	4 999,99 ?	8
12	Администрирование Linux	Основы администрирования операционной системы Linux. Установка, настройка, работа с файловой системой и пользователями.	6	2 999,99 ?	9
13	Машинное обучение с Python и scikit-learn	Введение в машинное обучение с использованием библиотеки scikit-learn на языке Python. Обучение моделей, кластеризация данных.	6	3 999,99 ?	10
\.


--
-- Data for Name: enrollments; Type: TABLE DATA; Schema: public; Owner: admin
--

COPY public.enrollments (enrollment_id, student_id, course_id, enrollment_date, payment_status, status) FROM stdin;
1	15	10	2024-04-22 11:38:35.128125+03	не оплачен	не завершен
7	15	7	2024-04-27 15:19:43.922615+03	не оплачен	не завершен
14	20	13	2024-04-23 18:52:23.526119+03	не оплачен	не завершен
17	20	7	2024-04-22 01:56:18.219647+03	не оплачен	не завершен
20	20	6	2024-04-23 21:29:32.813874+03	не оплачен	не завершен
22	10	8	2024-04-22 02:02:35.001484+03	не оплачен	не завершен
25	10	5	2024-04-26 09:56:47.488667+03	не оплачен	не завершен
33	6	9	2024-04-27 09:41:28.210231+03	не оплачен	не завершен
76	13	4	2024-04-24 23:58:37.585105+03	не оплачен	не завершен
82	17	8	2024-04-23 03:10:43.133423+03	не оплачен	не завершен
85	17	5	2024-04-26 12:17:23.33346+03	не оплачен	не завершен
103	18	9	2024-04-27 07:44:27.055382+03	не оплачен	не завершен
106	18	4	2024-04-25 20:53:52.37568+03	не оплачен	не завершен
111	3	10	2024-04-26 03:49:43.730594+03	не оплачен	не завершен
115	3	5	2024-04-22 19:05:16.945242+03	не оплачен	не завершен
117	3	7	2024-04-25 01:46:38.15176+03	не оплачен	не завершен
124	9	13	2024-04-22 06:32:38.410102+03	не оплачен	не завершен
126	9	4	2024-04-25 17:54:46.968001+03	не оплачен	не завершен
158	12	11	2024-04-25 06:52:15.483338+03	не оплачен	не завершен
160	12	6	2024-04-21 05:32:20.789914+03	не оплачен	не завершен
167	8	7	2024-04-25 17:46:48.857839+03	не оплачен	не завершен
184	14	13	2024-04-20 23:00:04.777299+03	не оплачен	не завершен
190	14	6	2024-04-23 07:48:18.936831+03	не оплачен	не завершен
199	4	12	2024-04-23 07:54:51.559591+03	не оплачен	не завершен
57	7	7	2024-04-23 14:11:17.296532+03	оплачен	не завершен
121	9	10	2024-04-21 04:18:39.548163+03	оплачен	не завершен
54	7	13	2024-04-22 07:49:58.753557+03	оплачен	не завершен
80	13	6	2024-04-23 12:02:05.331851+03	оплачен	не завершен
181	14	10	2024-04-24 16:13:19.852545+03	оплачен	не завершен
38	6	11	2024-04-28 19:31:39.398149+03	оплачен	не завершен
83	17	9	2024-04-21 12:36:49.987123+03	оплачен	не завершен
139	11	12	2024-04-24 17:19:42.007269+03	оплачен	завершен
81	17	10	2024-04-28 05:10:53.036192+03	оплачен	не завершен
130	9	6	2024-04-23 04:37:23.229228+03	оплачен	не завершен
189	14	12	2024-04-27 00:19:05.825163+03	оплачен	не завершен
188	14	11	2024-04-24 01:26:42.396377+03	оплачен	не завершен
162	8	8	2024-04-27 14:44:49.468113+03	оплачен	не завершен
92	5	8	2024-04-26 04:27:01.786677+03	оплачен	не завершен
44	19	13	2024-04-22 04:55:57.442155+03	оплачен	не завершен
41	19	10	2024-04-29 06:41:15.446362+03	оплачен	не завершен
77	13	7	2024-04-28 20:03:40.196301+03	оплачен	не завершен
37	6	7	2024-04-20 12:28:51.754753+03	оплачен	не завершен
9	15	12	2024-04-26 14:33:56.28031+03	оплачен	не завершен
143	21	9	2024-04-27 21:17:35.429957+03	оплачен	не завершен
34	6	13	2024-04-20 17:55:14.74807+03	оплачен	не завершен
125	9	5	2024-04-24 09:03:00.943549+03	оплачен	не завершен
46	19	4	2024-04-21 04:41:42.560792+03	оплачен	не завершен
186	14	4	2024-04-25 00:16:43.492719+03	оплачен	завершен
75	13	5	2024-04-27 12:27:16.80051+03	оплачен	не завершен
155	12	5	2024-04-21 16:35:33.854773+03	оплачен	не завершен
89	17	12	2024-04-22 12:27:55.257814+03	оплачен	не завершен
45	19	5	2024-04-25 18:48:28.183293+03	оплачен	не завершен
19	20	12	2024-04-24 04:42:59.623595+03	оплачен	не завершен
58	7	11	2024-04-24 18:43:44.279049+03	оплачен	не завершен
4	15	13	2024-04-26 07:10:00.99049+03	оплачен	не завершен
26	10	4	2024-04-20 07:46:34.484441+03	оплачен	не завершен
161	8	10	2024-04-19 22:17:03.438655+03	оплачен	не завершен
43	19	9	2024-04-23 22:14:12.356933+03	оплачен	завершен
131	11	10	2024-04-22 21:53:48.340736+03	оплачен	не завершен
66	22	4	2024-04-26 16:59:14.877345+03	оплачен	не завершен
128	9	11	2024-04-21 07:10:02.4279+03	оплачен	не завершен
165	8	5	2024-04-24 15:29:17.436595+03	оплачен	не завершен
15	20	5	2024-04-28 13:01:31.042023+03	оплачен	не завершен
71	13	10	2024-04-25 13:29:18.646045+03	оплачен	не завершен
179	16	12	2024-04-20 21:02:56.667815+03	оплачен	не завершен
10	15	6	2024-04-21 13:39:35.689771+03	оплачен	завершен
175	16	5	2024-04-22 08:17:38.061057+03	оплачен	не завершен
6	15	4	2024-04-25 12:22:20.888434+03	оплачен	не завершен
142	21	8	2024-04-29 08:46:31.904412+03	оплачен	завершен
49	19	12	2024-04-23 05:26:24.166929+03	оплачен	не завершен
95	5	5	2024-04-29 07:53:21.12261+03	оплачен	завершен
191	4	10	2024-04-29 03:09:54.104402+03	оплачен	не завершен
169	8	12	2024-04-20 06:55:00.331821+03	оплачен	не завершен
78	13	11	2024-04-28 22:10:31.15479+03	оплачен	не завершен
94	5	13	2024-04-23 00:59:11.826399+03	оплачен	не завершен
120	3	6	2024-04-28 01:47:51.924717+03	оплачен	не завершен
100	5	6	2024-04-21 05:07:49.069422+03	оплачен	не завершен
195	4	5	2024-04-23 21:38:59.426317+03	оплачен	не завершен
118	3	11	2024-04-28 13:04:31.614732+03	оплачен	не завершен
67	22	7	2024-04-22 07:08:06.47468+03	оплачен	не завершен
164	8	13	2024-04-20 04:15:15.197355+03	оплачен	завершен
192	4	8	2024-04-20 07:02:17.132151+03	оплачен	не завершен
163	8	9	2024-04-29 15:21:22.257981+03	оплачен	завершен
180	16	6	2024-04-26 12:15:16.506458+03	оплачен	завершен
52	7	8	2024-04-22 13:49:12.670299+03	оплачен	не завершен
51	7	10	2024-04-27 02:35:17.027444+03	оплачен	не завершен
185	14	5	2024-04-29 03:23:34.257759+03	оплачен	не завершен
135	11	5	2024-04-22 16:03:56.823383+03	оплачен	не завершен
68	22	11	2024-04-20 01:08:12.16124+03	оплачен	не завершен
122	9	8	2024-04-28 15:31:57.514465+03	оплачен	не завершен
98	5	11	2024-04-26 13:42:29.830082+03	оплачен	не завершен
63	22	9	2024-04-28 06:19:53.466011+03	оплачен	не завершен
137	11	7	2024-04-28 13:00:37.998071+03	оплачен	завершен
173	16	9	2024-04-26 14:31:20.105328+03	оплачен	не завершен
2	15	8	2024-04-22 18:38:38.781734+03	оплачен	не завершен
86	17	4	2024-04-20 13:06:47.401716+03	оплачен	завершен
105	18	5	2024-04-21 05:11:47.296776+03	оплачен	не завершен
159	12	12	2024-04-23 13:37:55.570509+03	оплачен	не завершен
112	3	8	2024-04-26 12:06:50.209224+03	оплачен	не завершен
8	15	11	2024-04-26 23:42:23.608871+03	оплачен	не завершен
197	4	7	2024-04-28 01:49:21.456449+03	оплачен	не завершен
200	4	6	2024-04-25 09:55:41.432132+03	оплачен	не завершен
151	12	10	2024-04-21 23:51:41.178249+03	оплачен	не завершен
13	20	9	2024-04-28 05:21:00.620547+03	оплачен	не завершен
193	4	9	2024-04-25 03:43:13.334601+03	оплачен	не завершен
119	3	12	2024-04-20 03:08:17.270525+03	оплачен	не завершен
132	11	8	2024-04-28 18:44:47.173538+03	оплачен	завершен
74	13	13	2024-04-27 07:04:53.144547+03	оплачен	не завершен
127	9	7	2024-04-22 23:46:07.745969+03	оплачен	не завершен
3	15	9	2024-04-25 17:11:27.286003+03	оплачен	не завершен
177	16	7	2024-04-26 05:39:47.461388+03	оплачен	не завершен
39	6	12	2024-04-25 23:59:31.528696+03	оплачен	не завершен
113	3	9	2024-04-21 04:45:36.812829+03	оплачен	не завершен
28	10	11	2024-04-20 10:46:02.683998+03	оплачен	не завершен
11	20	10	2024-04-23 01:55:43.476463+03	оплачен	не завершен
101	18	10	2024-04-28 10:02:46.493464+03	оплачен	завершен
30	10	6	2024-04-23 22:17:57.505395+03	оплачен	не завершен
79	13	12	2024-04-26 09:12:16.633542+03	оплачен	не завершен
40	6	6	2024-04-22 00:11:32.986978+03	оплачен	не завершен
97	5	7	2024-04-25 00:47:53.261789+03	оплачен	не завершен
61	22	10	2024-04-20 10:59:58.149347+03	оплачен	не завершен
21	10	10	2024-04-28 09:29:32.906645+03	оплачен	не завершен
145	21	5	2024-04-26 05:36:23.322654+03	оплачен	завершен
171	16	10	2024-04-25 09:19:13.606268+03	оплачен	не завершен
60	7	6	2024-04-21 16:23:03.52568+03	оплачен	не завершен
5	15	5	2024-04-24 05:03:00.446978+03	оплачен	не завершен
148	21	11	2024-04-29 06:08:46.541354+03	оплачен	не завершен
114	3	13	2024-04-28 09:03:44.31136+03	оплачен	завершен
29	10	12	2024-04-23 20:58:24.552312+03	оплачен	завершен
70	22	6	2024-04-25 04:53:06.058391+03	оплачен	завершен
47	19	7	2024-04-29 13:46:44.933014+03	оплачен	не завершен
146	21	4	2024-04-20 19:26:53.658184+03	оплачен	завершен
32	6	8	2024-04-26 07:50:59.324996+03	оплачен	не завершен
138	11	11	2024-04-26 05:23:37.074673+03	оплачен	не завершен
24	10	13	2024-04-26 10:45:33.503806+03	оплачен	не завершен
153	12	9	2024-04-28 10:26:31.229229+03	оплачен	не завершен
99	5	12	2024-04-25 18:53:31.509047+03	оплачен	не завершен
178	16	11	2024-04-26 08:50:50.602524+03	оплачен	не завершен
136	11	4	2024-04-27 07:24:58.866386+03	оплачен	завершен
56	7	4	2024-04-22 20:36:11.640399+03	оплачен	завершен
110	18	6	2024-04-26 19:58:06.61212+03	оплачен	не завершен
16	20	4	2024-04-25 06:35:25.656704+03	оплачен	не завершен
154	12	13	2024-04-29 14:28:36.389224+03	оплачен	не завершен
116	3	4	2024-04-29 15:13:29.748467+03	оплачен	завершен
102	18	8	2024-04-26 04:21:12.675489+03	оплачен	не завершен
157	12	7	2024-04-24 09:19:14.500301+03	оплачен	не завершен
87	17	7	2024-04-20 19:00:32.384724+03	оплачен	не завершен
183	14	9	2024-04-28 18:42:17.708076+03	оплачен	не завершен
134	11	13	2024-04-22 01:50:56.370735+03	оплачен	не завершен
65	22	5	2024-04-21 18:31:03.220886+03	оплачен	завершен
109	18	12	2024-04-27 23:25:25.404513+03	оплачен	не завершен
42	19	8	2024-04-22 11:07:55.767344+03	оплачен	не завершен
168	8	11	2024-04-20 08:00:29.938925+03	оплачен	завершен
64	22	13	2024-04-22 05:51:30.318258+03	оплачен	не завершен
144	21	13	2024-04-26 02:29:26.68871+03	оплачен	не завершен
18	20	11	2024-04-27 01:05:50.191014+03	оплачен	не завершен
59	7	12	2024-04-20 01:04:59.882696+03	оплачен	не завершен
174	16	13	2024-04-20 15:26:46.295436+03	оплачен	завершен
36	6	4	2024-04-28 07:13:12.815421+03	оплачен	завершен
27	10	7	2024-04-22 02:56:37.849337+03	оплачен	не завершен
72	13	8	2024-04-28 19:35:03.97666+03	оплачен	не завершен
152	12	8	2024-04-25 00:17:56.399515+03	оплачен	завершен
53	7	9	2024-04-23 02:08:59.010396+03	оплачен	завершен
48	19	11	2024-04-22 23:58:37.522565+03	оплачен	завершен
91	5	10	2024-04-24 04:55:26.558476+03	оплачен	не завершен
141	21	10	2024-04-21 02:20:11.794466+03	оплачен	не завершен
198	4	11	2024-04-19 19:18:22.925392+03	оплачен	не завершен
93	5	9	2024-04-22 05:08:00.698973+03	оплачен	завершен
90	17	6	2024-04-27 08:56:01.901274+03	оплачен	не завершен
149	21	12	2024-04-24 13:50:17.501468+03	оплачен	завершен
73	13	9	2024-04-26 12:05:25.662861+03	оплачен	не завершен
84	17	13	2024-04-20 22:55:59.731085+03	оплачен	не завершен
133	11	9	2024-04-26 05:04:34.808722+03	оплачен	завершен
170	8	6	2024-04-19 17:50:34.439208+03	оплачен	завершен
176	16	4	2024-04-22 18:05:11.997489+03	оплачен	не завершен
147	21	7	2024-04-22 18:06:11.797895+03	оплачен	не завершен
194	4	13	2024-04-26 16:02:41.964303+03	оплачен	не завершен
50	19	6	2024-04-21 00:00:53.173639+03	оплачен	не завершен
123	9	9	2024-04-29 10:40:10.394994+03	оплачен	не завершен
23	10	9	2024-04-26 19:40:18.157879+03	оплачен	не завершен
108	18	11	2024-04-26 10:03:39.354466+03	оплачен	завершен
35	6	5	2024-04-23 06:32:08.64094+03	оплачен	не завершен
129	9	12	2024-04-25 13:18:10.802813+03	оплачен	не завершен
166	8	4	2024-04-21 21:59:16.219165+03	оплачен	не завершен
88	17	11	2024-04-29 04:28:24.544902+03	оплачен	завершен
96	5	4	2024-04-23 18:18:12.762791+03	оплачен	не завершен
140	11	6	2024-04-21 09:54:11.29867+03	оплачен	не завершен
187	14	7	2024-04-21 19:04:09.997047+03	оплачен	не завершен
104	18	13	2024-04-26 18:33:46.741835+03	оплачен	не завершен
12	20	8	2024-04-22 03:07:59.294687+03	оплачен	завершен
62	22	8	2024-04-23 17:55:17.016138+03	оплачен	не завершен
55	7	5	2024-04-29 09:50:47.064278+03	оплачен	завершен
196	4	4	2024-04-22 01:45:01.543174+03	оплачен	не завершен
150	21	6	2024-04-27 11:40:49.452451+03	оплачен	не завершен
156	12	4	2024-04-21 01:20:31.568884+03	оплачен	не завершен
182	14	8	2024-04-23 18:26:59.363228+03	оплачен	не завершен
31	6	10	2024-04-26 05:17:07.64849+03	оплачен	завершен
172	16	8	2024-04-22 13:11:30.16464+03	оплачен	не завершен
69	22	12	2024-04-21 16:11:15.938378+03	оплачен	завершен
107	18	7	2024-04-25 09:13:11.42605+03	оплачен	не завершен
\.


--
-- Data for Name: lessons; Type: TABLE DATA; Schema: public; Owner: admin
--

COPY public.lessons (lesson_id, course_id, title, description, link, other, lesson_number) FROM stdin;
21	4	Работа с файлами	Основы работы с текстовыми и бинарными файлами в Python.	http://platform/4/3	Примеры: чтение, запись и обработка данных файлов.	3
22	4	Регулярные выражения	Применение регулярных выражений для обработки текстовой информации.	http://platform/4/4	Поиск и замена текста, разбор строк.	4
24	4	Отладка и профилирование	Инструменты для отладки и оптимизации программ на Python.	http://platform/4/6	Отладка с помощью pdb, анализ производительности.	6
25	5	Введение в HTML	Основы языка разметки HTML. Структура документа и основные теги.	http://platform/5/1	Теги: <html>, <head>, <body>, <title> и др.	1
26	5	Работа с текстом и изображениями	Оформление текста, ссылок и изображений на веб-странице.	http://platform/5/2	Теги: <p>, <h1>-<h6>, <img>, <a>.	2
27	5	Основы CSS	Изучение каскадных таблиц стилей (CSS). Оформление элементов страницы.	http://platform/5/3	Стили: цвет, шрифт, размер, фон.	3
28	5	Позиционирование элементов	Методы позиционирования блоков и элементов на веб-странице.	http://platform/5/4	CSS: position, float, display.	4
29	5	Сетки и макеты	Создание адаптивных сеток и макетов веб-страниц с помощью CSS.	http://platform/5/5	Bootstrap, Flexbox, Grid Layout.	5
23	4	Модули и пакеты\n	Организация кода на Python с использованием модулей и пакетов.\n	http://platform/4/5\n	Импортирование, создание и использование модулей.\n	5
20	4	Управляющие конструкции\n\n\n\n	Изучение условных операторов, циклов и функций в Python.\n\n\n\n	http://platform/4/2\n\n\n\n	Практические задания: написание простых программ.\n\n\n\n	2
30	5	Анимации и трансформации	Применение анимаций и трансформаций к элементам веб-страницы.	http://platform/5/6	CSS: transition, transform, keyframes.	6
31	6	Введение в SQL	Основные операторы языка SQL. Создание, изменение и удаление данных.	http://platform/6/1	DDL, DML, DCL, TCL.	1
32	6	Выборка данных	Извлечение данных из таблиц с использованием оператора SELECT.	http://platform/6/2	Условия выборки: WHERE, ORDER BY, LIMIT.	2
33	6	Фильтрация данных	Применение фильтров и условий к выборке данных в SQL.	http://platform/6/3	Операторы сравнения и логические операторы.	3
34	6	Агрегатные функции	Использование агрегатных функций (SUM, AVG, MIN, MAX) в SQL.	http://platform/6/4	Группировка данных: GROUP BY, HAVING.	4
35	6	Соединение таблиц	Объединение данных из нескольких таблиц с помощью JOIN.	http://platform/6/5	Типы JOIN: INNER, LEFT, RIGHT, FULL.	5
36	6	Подзапросы	Использование подзапросов в SQL для создания более сложных запросов.	http://platform/6/6	Подзапросы в SELECT, WHERE, FROM.	6
37	7	Введение в JavaScript	Основы языка JavaScript. Переменные, типы данных, операторы.	http://platform/7/1	Синтаксис и основные конструкции языка.	1
38	7	Работа с функциями	Изучение функций в JavaScript. Объявление, вызов, параметры.	http://platform/7/2	Анонимные функции, замыкания.	2
39	7	Работа с массивами	Операции с массивами: создание, добавление, удаление элементов.	http://platform/7/3	Методы массивов: push, pop, shift, unshift.	3
40	7	Объектно-ориентированное программирование	Принципы объектно-ориентированного программирования в JavaScript.	http://platform/7/4	Создание и использование объектов.	4
41	7	DOM и события	Работа с объектной моделью документа (DOM) и обработка событий.	http://platform/7/5	События мыши, клавиатуры, элементов.	5
42	7	Асинхронное программирование	Асинхронные операции и работа с функциями обратного вызова (callback).	http://platform/7/6	Таймеры, AJAX, промисы.	6
43	8	Загрузка и обработка данных	Загрузка данных из различных источников и их обработка на Python.	http://platform/8/1	Работа с CSV, JSON, Excel.	1
44	8	Очистка и подготовка данных	Удаление дубликатов, обработка пропущенных значений, преобразование типов.	http://platform/8/2	Методы DataFrame: dropna, fillna, astype.	2
45	8	Анализ данных	Основные методы анализа данных с использованием библиотеки pandas.	http://platform/8/3	Статистические показатели, группировка данных.	3
46	8	Визуализация данных	Построение графиков и диаграмм для визуализации данных с помощью matplotlib и seaborn.	http://platform/8/4	Графики: гистограммы, диаграммы рассеяния.	4
47	8	Простые статистические методы	Применение простых статистических методов к анализу данных.	http://platform/8/5	Средние значения, медиана, дисперсия.	5
48	8	Линейная регрессия	Метод линейной регрессии для прогнозирования зависимости переменных.	http://platform/8/6	Модель линейной регрессии, коэффициенты.	6
49	9	Введение в Android	Основы мобильной разработки на платформе Android. Структура приложения.	http://platform/9/1	Activity, Layout, Manifest.	1
50	9	Работа с пользовательским интерфейсом	Создание и оформление пользовательского интерфейса (UI) на Android.	http://platform/9/2	Элементы UI: TextView, EditText, Button.	2
51	9	Макеты и ресурсы	Использование макетов (Layouts) и ресурсов в приложении Android.	http://platform/9/3	Стили, цвета, изображения, строки.	3
52	9	Взаимодействие с пользователем	Обработка событий и взаимодействие с пользователем на Android.	http://platform/9/4	Обработка кликов, ввод текста, диалогов.	4
53	9	Жизненный цикл активности	Управление жизненным циклом активности в Android приложении.	http://platform/9/5	Методы: onCreate, onStart, onResume.	5
54	9	Работа с данными	Работа с данными и хранение информации на устройстве в приложении Android.	http://platform/9/6	SharedPreferences, SQLite, файлы.	6
55	10	Введение в PHP	Основы языка программирования PHP. Синтаксис, переменные, операторы.	http://platform/10/1	Теги <?php ?>, переменные $, echo.	1
56	10	Работа с формами	Обработка данных форм на веб-страницах с использованием PHP.	http://platform/10/2	Методы GET и POST, массивы $_GET и $_POST.	2
57	10	Работа с базой данных	Взаимодействие с базой данных MySQL с использованием PHP и SQL.	http://platform/10/3	Подключение, запросы SELECT, INSERT, UPDATE.	3
58	10	Сессии и куки	Использование сессий и куков для работы с состоянием на веб-сайте.	http://platform/10/4	Сессии, куки, авторизация, аутентификация.	4
59	10	Функции и объекты	Использование функций и объектов в PHP для организации кода.	http://platform/10/5	Объявление функций, классов и объектов.	5
60	10	Файлы и директории	Работа с файлами и директориями на сервере с помощью PHP.	http://platform/10/6	Файловый ввод-вывод, функции file, dir.	6
61	11	Введение в iOS	Основы мобильной разработки на платформе iOS. Структура приложения.	http://platform/11/1	ViewController, Storyboard, AppDelegate.	1
62	11	Работа с интерфейсом	Создание и оформление пользовательского интерфейса (UI) на iOS.	http://platform/11/2	Элементы UI: UILabel, UITextField, UIButton.	2
63	11	Архитектура MVC	Применение шаблона проектирования MVC (Model-View-Controller) в iOS приложениях.	http://platform/11/3	Разделение логики и отображения.	3
64	11	Навигация и переходы	Управление навигацией и переходами между экранами в приложении iOS.	http://platform/11/4	NavigationController, Segue.	4
65	11	Взаимодействие с пользователем	Обработка событий и взаимодействие с пользователем в приложении iOS.	http://platform/11/5	Обработка жестов, анимации.	5
66	11	Работа с данными	Работа с данными и хранение информации на устройстве в приложении iOS.	http://platform/11/6	User Defaults, Core Data, SQLite.	6
67	12	Введение в алгоритмы	Основные понятия алгоритмов и структур данных. Сложность алгоритмов.	http://platform/12/1	Эффективность, асимптотическая сложность.	1
68	12	Структуры данных	Описание и реализация основных структур данных: массивы, списки, стеки, очереди.	http://platform/12/2	Односвязные и двусвязные списки.	2
69	12	Сортировка и поиск	Алгоритмы сортировки и поиска элементов в массиве.	http://platform/12/3	Сортировка: пузырьком, вставками, слиянием.	3
70	12	Графы и деревья	Описание и реализация алгоритмов для работы с графами и деревьями.	http://platform/12/4	Обход графов: в глубину и в ширину.	4
71	12	Хеш-таблицы	Принцип работы и реализация хеш-таблиц для хранения данных.	http://platform/12/5	Хеш-функции, коллизии, метод цепочек.	5
72	12	Динамическое программирование	Применение метода динамического программирования для решения задач.	http://platform/12/6	Мемоизация, оптимальная подструктура.	6
73	13	Введение в Unity	Основы разработки игр на платформе Unity. Интерфейс, проекты, сцены.	http://platform/13/1	Unity Editor, GameObjects, компоненты.	1
74	13	Создание и настройка объектов	Создание игровых объектов и настройка их параметров в Unity.	http://platform/13/2	Типы объектов, Transform, Material.	2
75	13	Работа с анимациями	Создание анимаций и управление анимационными состояниями в Unity.	http://platform/13/3	Animator Controller, Animation Clips.	3
76	13	Физика в Unity	Применение физических свойств и эффектов в игровом движке Unity.	http://platform/13/4	Коллайдеры, физические материалы, гравитация.	4
77	13	Сценарии и скрипты	Написание скриптов и сценариев на языке C# для Unity.	http://platform/13/5	Методы, переменные, классы, события.	5
78	13	Искусственный интеллект	Применение искусственного интеллекта в играх на Unity.	http://platform/13/6	Алгоритмы поведения, состояния, деревья решений.	6
19	4	Введение в Python\n	Основы синтаксиса, типы данных и структуры программы на языке Python.\n	http://platform/4/1\n	Материалы: презентация и исходный код примеров.\n	1
\.


--
-- Data for Name: responses; Type: TABLE DATA; Schema: public; Owner: admin
--

COPY public.responses (response_id, course_id, student_id, rating, comment) FROM stdin;
6	4	21	2	\N
7	9	7	2	\N
8	6	15	2	\N
14	8	21	3	\N
18	13	8	3	\N
30	5	22	5	\N
31	11	8	5	\N
34	13	16	5	\N
1	9	19	1	Плохой курс. Не рекомендую.
2	12	21	1	Не стоит своих денег.
3	11	17	1	Плохой курс. Не рекомендую.
4	9	8	1	Курс не понравился.
5	4	6	2	Не все материалы были полезны.
9	6	22	2	Можно было бы лучше.
10	11	19	2	Неплохой курс, но есть недостатки.
11	5	5	2	Неплохой курс, но есть недостатки.
12	10	18	2	Неплохой курс, но есть недостатки.
13	12	22	3	Хороший курс, но можно лучше.
15	4	14	3	Средний курс, ничего особенного.
16	7	11	3	Средний курс, ничего особенного.
17	4	3	3	Хороший курс, но можно лучше.
19	4	17	3	Средний курс, ничего особенного.
20	6	16	4	Отличный курс!
21	10	6	4	Очень понравился, рекомендую!
22	11	18	4	Отличный курс!
23	6	8	4	Очень понравился, рекомендую!
24	12	11	4	Отличный курс!
25	5	21	4	Отличный курс!
26	5	7	4	Отличный курс!
27	8	11	5	Курс был отличным, рекомендую!
28	9	11	5	Курс был отличным, рекомендую!
29	12	10	5	Курс был отличным, рекомендую!
32	4	7	5	Курс был отличным, рекомендую!
33	8	12	5	Курс был отличным, рекомендую!
35	8	20	5	Курс был отличным, рекомендую!
36	13	3	5	Курс был отличным, рекомендую!
37	9	5	5	Курс был отличным, рекомендую!
\.


--
-- Data for Name: students; Type: TABLE DATA; Schema: public; Owner: admin
--

COPY public.students (student_id, name, surname, email, login, password, age) FROM stdin;
3	Влас	Сазонов	ninel_2011@example.net	fomichevlongin	81dc9bdb52d04dc20036dbd8313ed055	25
5	Ладимир	Матвеев	mstislavmishin@example.org	innokentishcherbakov	81dc9bdb52d04dc20036dbd8313ed055	36
6	Сидор	Логинова	anatoli_1974@example.org	anastasija_76	81dc9bdb52d04dc20036dbd8313ed055	52
7	Аким	Терентьев	evdokim_71@example.org	filimon32	81dc9bdb52d04dc20036dbd8313ed055	58
8	Юлиан	Соболева	bpopov@example.net	evgeni_29	81dc9bdb52d04dc20036dbd8313ed055	15
9	Казимир	Белоусова	foma_24@example.net	jakushevakim	81dc9bdb52d04dc20036dbd8313ed055	57
10	Флорентин	Горбачева	sharovavalentina@example.com	martinmerkushev	81dc9bdb52d04dc20036dbd8313ed055	33
11	Борис	Шарова	gdavidov@example.com	polikarp79	81dc9bdb52d04dc20036dbd8313ed055	11
12	Герасим	Беляева	zuevfilimon@example.com	jan_97	81dc9bdb52d04dc20036dbd8313ed055	14
13	Авдей	Русакова	milen_98@example.com	onufriafanasev	81dc9bdb52d04dc20036dbd8313ed055	20
14	Ипат	Евсеева	rodionovernest@example.net	kasjan1973	81dc9bdb52d04dc20036dbd8313ed055	7
15	Евпраксия	Полякова	svjatopolkfedotov@example.com	gennadi2022	81dc9bdb52d04dc20036dbd8313ed055	24
16	Ермил	Гордеева	okomissarov@example.org	radislavrogov	81dc9bdb52d04dc20036dbd8313ed055	47
17	Епифан	Лазарева	juli_1985@example.net	uosipova	81dc9bdb52d04dc20036dbd8313ed055	30
18	Олимпиада	Юдина	florentingorbunov@example.org	nosovaviktorija	81dc9bdb52d04dc20036dbd8313ed055	9
19	Клавдий	Доронина	ygordeev@example.net	mefodi_50	81dc9bdb52d04dc20036dbd8313ed055	20
20	Лучезар	Мишина	ljubimkovalev@example.com	semen2008	81dc9bdb52d04dc20036dbd8313ed055	21
21	Гаврила	Марков	krjukovfoti@example.net	belousovkallistrat	81dc9bdb52d04dc20036dbd8313ed055	9
22	Ангелина	Коновалова	innokentigalkin@example.org	simonmironov	81dc9bdb52d04dc20036dbd8313ed055	9
4	Октябрина	Селиверстова	ubelousov@example.net	dig	81dc9bdb52d04dc20036dbd8313ed055	15
23	Егор	Вихлянцев	egor.vihlyantsev@yandex.ru	egor4	81dc9bdb52d04dc20036dbd8313ed055	20
\.


--
-- Data for Name: students_progress; Type: TABLE DATA; Schema: public; Owner: admin
--

COPY public.students_progress (progress_id, student_id, lesson_id, completion_date, test_score) FROM stdin;
13	17	20	2024-05-09 15:03:43.515752+03	41
14	13	72	2024-05-09 14:49:58.013215+03	68
15	15	35	2024-05-09 14:34:21.613465+03	69
16	21	37	2024-05-09 14:26:29.184859+03	85
17	9	58	2024-05-09 14:25:01.576081+03	55
18	21	27	2024-05-09 13:45:01.11044+03	89
19	20	29	2024-05-09 13:20:15.022693+03	41
20	8	72	2024-05-09 13:16:40.111544+03	12
21	16	40	2024-05-09 13:03:51.797784+03	20
22	17	21	2024-05-09 13:02:27.422026+03	86
23	11	70	2024-05-09 12:51:02.305583+03	73
24	14	54	2024-05-09 12:25:00.561463+03	73
25	13	54	2024-05-09 12:09:01.541382+03	85
26	17	60	2024-05-09 11:55:48.572787+03	3
27	11	69	2024-05-09 11:55:29.664934+03	62
28	11	75	2024-05-09 11:47:30.795697+03	41
29	4	44	2024-05-09 11:25:52.965244+03	58
30	4	42	2024-05-09 11:22:41.261091+03	65
31	21	32	2024-05-09 11:21:30.995244+03	33
32	19	23	2024-05-09 11:12:56.763717+03	18
33	7	38	2024-05-09 11:00:00.534345+03	57
34	20	59	2024-05-09 10:58:41.665298+03	95
35	8	75	2024-05-09 10:54:52.206115+03	82
36	19	45	2024-05-09 10:42:24.704628+03	77
37	5	31	2024-05-09 10:21:47.394899+03	18
38	10	69	2024-05-09 10:20:37.16088+03	21
39	14	23	2024-05-09 10:10:04.306372+03	43
40	3	74	2024-05-09 09:45:14.371323+03	67
41	13	58	2024-05-09 09:39:24.082515+03	89
42	16	43	2024-05-09 09:37:08.061121+03	8
43	21	43	2024-05-09 09:36:21.532293+03	93
44	11	59	2024-05-09 09:34:08.342144+03	3
45	21	77	2024-05-09 09:33:32.372369+03	72
46	14	69	2024-05-09 08:55:51.242816+03	30
47	13	31	2024-05-09 08:55:44.060327+03	39
48	10	62	2024-05-09 08:53:57.028936+03	70
49	11	44	2024-05-09 08:46:20.880473+03	43
50	5	27	2024-05-09 08:28:33.053026+03	77
51	19	52	2024-05-09 08:01:38.067994+03	96
52	16	41	2024-05-09 07:57:49.74284+03	54
53	3	22	2024-05-09 07:02:35.793132+03	18
54	3	48	2024-05-09 06:54:39.342335+03	65
55	9	59	2024-05-09 06:40:34.035886+03	20
56	7	73	2024-05-09 06:37:00.670831+03	41
57	7	39	2024-05-09 06:30:26.509166+03	11
58	13	42	2024-05-09 06:18:07.583225+03	38
59	7	75	2024-05-09 06:09:24.94782+03	67
60	20	48	2024-05-09 05:43:26.498332+03	40
61	19	19	2024-05-09 05:43:00.464303+03	47
62	5	30	2024-05-09 05:28:29.291766+03	51
63	6	60	2024-05-09 05:28:04.553996+03	18
64	16	57	2024-05-09 05:25:16.54845+03	8
65	6	65	2024-05-09 05:23:00.632563+03	7
66	21	44	2024-05-09 05:01:52.450562+03	66
67	15	73	2024-05-09 04:40:19.647552+03	55
68	9	38	2024-05-09 04:39:36.412225+03	63
69	10	32	2024-05-09 04:34:00.912287+03	31
70	7	36	2024-05-09 04:27:30.074935+03	35
71	18	69	2024-05-09 04:12:50.873279+03	32
72	21	65	2024-05-09 03:59:41.663593+03	84
73	19	32	2024-05-09 03:52:13.667018+03	32
74	21	72	2024-05-09 03:36:04.50543+03	66
75	22	50	2024-05-09 03:35:13.765325+03	20
76	11	25	2024-05-09 03:35:12.115461+03	20
77	22	47	2024-05-09 03:10:29.953987+03	5
78	9	25	2024-05-09 02:57:04.605386+03	6
79	5	35	2024-05-09 02:28:12.8025+03	89
80	21	50	2024-05-09 00:53:02.405108+03	96
81	15	49	2024-05-09 00:45:34.418149+03	44
82	19	66	2024-05-09 00:33:27.037711+03	28
83	6	39	2024-05-09 00:20:31.573731+03	90
84	8	30	2024-05-09 00:14:26.147885+03	94
85	18	66	2024-05-09 00:10:31.122412+03	67
86	8	28	2024-05-08 23:57:42.734263+03	61
87	5	20	2024-05-08 23:56:29.765691+03	53
88	10	71	2024-05-08 23:55:07.784214+03	70
89	5	61	2024-05-08 23:54:39.903779+03	49
90	21	51	2024-05-08 23:42:44.2712+03	22
91	18	57	2024-05-08 23:38:48.394703+03	23
92	3	61	2024-05-08 23:20:14.759947+03	28
93	16	52	2024-05-08 22:56:59.136018+03	56
94	21	34	2024-05-08 22:47:05.276813+03	33
95	11	76	2024-05-08 22:35:32.156473+03	25
96	11	61	2024-05-08 22:27:53.181157+03	25
97	22	44	2024-05-08 21:59:26.657197+03	44
98	8	45	2024-05-08 21:33:53.310946+03	71
99	5	29	2024-05-08 21:27:56.129174+03	8
100	20	65	2024-05-08 21:16:11.254189+03	42
101	16	31	2024-05-08 20:31:00.008276+03	76
102	4	27	2024-05-08 20:23:58.094012+03	46
103	6	75	2024-05-08 20:11:40.01048+03	81
104	13	40	2024-05-08 19:55:28.039738+03	34
105	11	46	2024-05-08 19:49:31.982893+03	77
106	11	65	2024-05-08 19:19:10.695884+03	88
107	22	48	2024-05-08 19:00:35.588462+03	52
108	5	23	2024-05-08 18:43:02.029352+03	52
109	15	26	2024-05-08 18:00:25.425877+03	48
110	15	34	2024-05-08 17:55:32.405364+03	96
111	14	43	2024-05-08 17:54:07.862308+03	18
112	8	67	2024-05-08 17:52:32.871837+03	84
113	8	65	2024-05-08 17:37:13.134562+03	79
114	5	19	2024-05-08 17:30:08.743557+03	15
115	9	45	2024-05-08 16:38:10.184915+03	43
116	18	41	2024-05-08 16:36:56.224619+03	62
117	15	66	2024-05-08 15:53:03.747137+03	72
118	11	71	2024-05-08 14:58:06.87132+03	52
119	7	57	2024-05-08 14:42:06.898575+03	98
120	19	72	2024-05-08 14:40:53.671373+03	16
121	4	54	2024-05-08 14:39:18.548275+03	51
122	18	26	2024-05-08 14:22:06.94546+03	75
123	11	67	2024-05-08 14:09:53.606186+03	95
124	12	67	2024-05-08 14:08:16.645572+03	83
125	15	33	2024-05-08 13:48:12.586953+03	98
126	6	30	2024-05-08 13:44:54.223102+03	17
127	10	68	2024-05-08 13:17:29.430742+03	45
128	4	55	2024-05-08 13:16:09.028501+03	92
129	16	74	2024-05-08 13:11:48.89309+03	96
130	11	35	2024-05-08 12:53:46.886346+03	37
131	20	19	2024-05-08 12:46:27.575214+03	68
132	5	74	2024-05-08 12:41:00.401007+03	22
133	7	66	2024-05-08 12:27:13.973837+03	69
134	17	51	2024-05-08 12:24:19.710644+03	12
135	6	74	2024-05-08 12:11:50.626823+03	33
136	21	41	2024-05-08 11:56:38.082233+03	59
137	21	48	2024-05-08 11:45:43.627554+03	84
138	5	38	2024-05-08 11:35:57.91151+03	50
139	21	31	2024-05-08 11:25:50.720164+03	55
140	8	43	2024-05-08 11:20:11.821402+03	91
141	13	78	2024-05-08 11:15:52.956487+03	0
142	5	64	2024-05-08 11:12:51.436804+03	59
143	17	54	2024-05-08 11:01:50.266321+03	15
144	20	64	2024-05-08 10:44:50.017123+03	12
145	4	36	2024-05-08 10:39:54.212876+03	64
146	15	61	2024-05-08 09:53:38.618202+03	88
147	6	63	2024-05-08 09:51:05.430258+03	16
148	6	37	2024-05-08 09:47:35.628746+03	51
149	6	59	2024-05-08 09:33:01.602156+03	74
150	20	67	2024-05-08 09:29:27.101588+03	21
151	10	60	2024-05-08 09:28:33.377408+03	40
152	22	76	2024-05-08 09:22:55.664357+03	53
153	14	20	2024-05-08 09:16:44.904615+03	12
154	21	66	2024-05-08 09:13:50.326241+03	61
155	12	30	2024-05-08 09:03:03.106725+03	42
156	7	53	2024-05-08 08:55:40.217513+03	41
157	18	30	2024-05-08 08:44:42.527703+03	58
158	19	46	2024-05-08 08:40:56.8768+03	19
159	12	44	2024-05-08 08:35:27.025265+03	93
160	10	19	2024-05-08 08:32:40.747549+03	42
161	19	50	2024-05-08 08:19:52.704655+03	46
162	7	25	2024-05-08 07:48:06.792411+03	23
163	9	34	2024-05-08 07:46:55.945374+03	54
164	17	39	2024-05-08 07:38:00.88982+03	11
165	18	60	2024-05-08 07:37:01.604236+03	20
166	8	33	2024-05-08 07:23:52.311685+03	45
167	9	54	2024-05-08 07:20:07.519283+03	41
168	18	35	2024-05-08 07:10:47.440122+03	96
169	19	30	2024-05-08 07:07:15.485353+03	60
170	14	22	2024-05-08 06:40:56.259387+03	93
171	14	60	2024-05-08 06:38:15.276405+03	47
172	8	76	2024-05-08 06:25:06.056977+03	57
173	7	20	2024-05-08 06:23:55.123759+03	79
174	14	47	2024-05-08 05:54:49.606894+03	70
175	21	62	2024-05-08 05:45:50.03627+03	69
176	16	24	2024-05-08 05:38:34.607963+03	52
177	9	37	2024-05-08 05:24:59.871829+03	10
178	11	42	2024-05-08 05:24:03.540866+03	68
179	14	45	2024-05-08 05:12:03.048167+03	1
180	15	63	2024-05-08 04:22:40.421386+03	42
181	7	52	2024-05-08 04:22:23.826441+03	24
182	11	30	2024-05-08 04:04:19.655853+03	69
183	7	55	2024-05-08 03:58:05.242982+03	97
184	17	69	2024-05-08 03:43:14.445447+03	13
185	10	21	2024-05-08 02:10:50.345509+03	64
186	15	78	2024-05-08 01:59:31.192114+03	3
187	3	20	2024-05-08 01:30:29.220266+03	7
188	4	49	2024-05-08 01:02:22.642467+03	8
189	21	30	2024-05-08 00:46:15.359429+03	90
190	14	53	2024-05-08 00:45:26.326711+03	7
191	11	56	2024-05-08 00:13:35.847633+03	26
192	17	73	2024-05-08 00:03:56.054106+03	32
193	18	70	2024-05-08 00:03:42.301114+03	64
194	11	32	2024-05-07 23:23:20.61256+03	35
195	18	74	2024-05-07 23:17:33.924383+03	67
196	17	32	2024-05-07 23:09:37.439822+03	87
197	13	39	2024-05-07 22:30:51.441537+03	1
198	7	23	2024-05-07 22:21:59.30216+03	10
199	22	31	2024-05-07 22:02:05.353633+03	36
200	13	46	2024-05-07 21:38:16.009293+03	3
201	4	34	2024-05-07 21:34:43.741135+03	63
202	19	51	2024-05-07 21:21:37.522074+03	34
203	11	68	2024-05-07 20:58:55.463587+03	50
204	8	78	2024-05-07 20:02:57.122187+03	72
205	20	71	2024-05-07 19:58:28.696321+03	100
206	10	78	2024-05-07 19:44:42.86185+03	9
207	16	66	2024-05-07 19:34:16.293133+03	5
208	14	29	2024-05-07 19:29:28.240024+03	54
209	15	45	2024-05-07 19:23:04.675697+03	29
210	17	58	2024-05-07 19:15:17.023233+03	75
211	3	43	2024-05-07 19:09:04.827284+03	80
212	21	68	2024-05-07 18:56:56.809378+03	68
213	15	19	2024-05-07 18:53:28.09262+03	58
214	8	31	2024-05-07 18:28:00.281638+03	20
215	22	26	2024-05-07 17:49:40.469049+03	58
216	21	53	2024-05-07 17:44:26.877856+03	76
217	20	43	2024-05-07 17:43:33.818012+03	34
218	22	74	2024-05-07 17:39:05.930013+03	1
219	20	46	2024-05-07 17:33:55.371889+03	25
220	12	43	2024-05-07 17:24:46.973389+03	33
221	3	51	2024-05-07 17:13:37.561952+03	80
222	8	49	2024-05-07 16:18:37.508296+03	20
223	21	23	2024-05-07 16:18:28.679772+03	81
224	12	42	2024-05-07 16:05:46.629114+03	17
225	19	76	2024-05-07 16:00:16.997323+03	65
226	15	28	2024-05-07 15:47:40.393565+03	38
227	16	73	2024-05-07 15:34:50.406101+03	43
228	17	42	2024-05-07 15:27:19.098972+03	38
229	8	50	2024-05-07 15:12:01.026741+03	72
230	8	62	2024-05-07 15:02:25.605882+03	32
231	20	54	2024-05-07 14:26:25.273015+03	88
232	4	50	2024-05-07 14:02:34.876324+03	21
233	7	40	2024-05-07 13:48:34.380297+03	41
234	19	61	2024-05-07 13:35:45.155361+03	1
235	3	19	2024-05-07 13:27:15.669517+03	66
236	14	24	2024-05-07 13:25:56.867577+03	68
237	11	48	2024-05-07 13:25:23.771307+03	86
238	22	36	2024-05-07 13:21:06.844594+03	44
239	17	70	2024-05-07 13:12:02.23209+03	10
240	5	45	2024-05-07 12:39:36.213138+03	53
241	8	63	2024-05-07 12:23:52.650991+03	95
242	19	64	2024-05-07 12:08:09.301888+03	15
243	12	25	2024-05-07 11:50:45.104488+03	77
244	5	52	2024-05-07 11:40:45.929277+03	93
245	22	62	2024-05-07 11:40:15.305825+03	2
246	12	69	2024-05-07 11:35:05.427737+03	67
247	11	43	2024-05-07 11:21:50.429711+03	99
248	22	28	2024-05-07 11:04:23.431684+03	26
249	7	34	2024-05-07 10:55:40.42374+03	39
250	16	20	2024-05-07 10:21:47.633116+03	96
251	21	22	2024-05-07 10:02:53.561853+03	45
252	3	49	2024-05-07 09:57:12.966873+03	76
253	19	59	2024-05-07 09:33:13.675554+03	93
254	19	55	2024-05-07 09:32:54.088041+03	30
255	20	21	2024-05-07 09:05:44.439368+03	92
256	9	26	2024-05-07 08:58:13.666427+03	15
257	21	45	2024-05-07 07:32:24.341647+03	31
258	8	24	2024-05-07 07:10:34.383616+03	56
259	4	31	2024-05-07 07:01:26.780864+03	89
260	15	51	2024-05-07 06:44:05.153932+03	74
261	14	21	2024-05-07 06:19:19.287892+03	98
262	12	53	2024-05-07 06:15:00.766072+03	7
263	7	76	2024-05-07 05:55:15.786637+03	68
264	13	27	2024-05-07 05:50:51.768477+03	40
265	9	69	2024-05-07 05:50:11.445377+03	99
266	14	57	2024-05-07 05:33:03.442861+03	10
267	22	77	2024-05-07 05:22:54.181724+03	47
268	5	36	2024-05-07 04:56:53.994212+03	74
269	22	49	2024-05-07 04:48:29.660393+03	94
270	9	63	2024-05-07 04:44:55.732375+03	78
271	19	75	2024-05-07 04:32:51.711112+03	60
272	13	68	2024-05-07 04:31:18.997616+03	43
273	18	36	2024-05-07 04:14:35.376374+03	64
274	17	64	2024-05-07 04:11:38.02711+03	2
275	21	29	2024-05-07 04:00:12.207047+03	41
276	22	20	2024-05-07 03:52:38.189892+03	61
277	8	71	2024-05-07 03:27:53.943737+03	36
278	7	41	2024-05-07 03:19:43.618713+03	59
279	6	20	2024-05-07 03:13:29.708136+03	47
280	10	57	2024-05-07 03:06:07.507565+03	67
281	7	28	2024-05-07 03:06:02.900839+03	49
282	11	39	2024-05-07 03:02:05.370851+03	28
283	10	66	2024-05-07 02:52:34.110009+03	33
284	14	67	2024-05-07 02:37:47.17093+03	29
285	13	66	2024-05-07 02:22:18.881259+03	25
286	9	31	2024-05-07 02:00:11.697332+03	99
287	3	77	2024-05-07 01:50:41.076757+03	75
288	21	47	2024-05-07 01:35:10.718599+03	88
289	5	37	2024-05-07 01:16:34.409516+03	67
290	10	73	2024-05-07 00:35:36.795257+03	35
291	10	35	2024-05-07 00:28:14.114729+03	75
292	5	76	2024-05-07 00:18:48.812732+03	50
293	16	60	2024-05-07 00:14:16.669544+03	60
294	7	65	2024-05-07 00:07:50.851382+03	25
295	10	39	2024-05-07 00:02:40.403857+03	7
296	7	21	2024-05-07 00:00:58.63997+03	50
297	4	39	2024-05-06 23:20:40.767492+03	33
298	22	41	2024-05-06 23:18:55.53043+03	15
299	19	77	2024-05-06 23:13:02.096366+03	68
300	9	46	2024-05-06 23:12:49.99548+03	51
301	5	32	2024-05-06 22:24:18.34994+03	14
302	12	56	2024-05-06 22:14:31.242766+03	83
303	5	28	2024-05-06 22:10:38.469974+03	34
304	7	29	2024-05-06 22:07:41.413034+03	25
305	15	48	2024-05-06 22:02:59.229721+03	44
306	7	49	2024-05-06 21:57:59.050239+03	20
307	12	48	2024-05-06 21:53:53.635695+03	91
308	22	27	2024-05-06 21:36:44.117602+03	28
309	15	69	2024-05-06 21:32:37.478876+03	16
310	17	66	2024-05-06 21:14:07.143938+03	89
311	18	31	2024-05-06 21:02:58.247599+03	60
312	5	47	2024-05-06 20:46:50.89847+03	70
313	13	30	2024-05-06 20:34:54.081182+03	51
314	16	69	2024-05-06 20:23:54.354511+03	17
315	16	53	2024-05-06 20:19:14.814145+03	86
316	20	55	2024-05-06 20:18:27.29564+03	46
317	14	37	2024-05-06 19:42:20.855047+03	90
318	3	73	2024-05-06 19:40:25.879893+03	8
319	7	58	2024-05-06 19:26:33.96067+03	13
320	3	69	2024-05-06 19:24:32.425878+03	15
321	6	46	2024-05-06 19:19:25.674263+03	10
322	4	41	2024-05-06 19:16:30.474778+03	59
323	16	34	2024-05-06 18:59:48.6395+03	41
324	13	36	2024-05-06 18:52:17.724071+03	99
325	13	32	2024-05-06 18:23:57.132741+03	43
326	16	56	2024-05-06 18:12:42.122329+03	98
327	17	52	2024-05-06 18:03:18.726121+03	2
328	7	48	2024-05-06 16:48:49.111574+03	69
329	19	63	2024-05-06 16:45:40.593556+03	86
330	17	19	2024-05-06 16:45:07.050168+03	83
331	12	55	2024-05-06 16:35:28.828728+03	4
332	7	68	2024-05-06 16:13:36.297834+03	44
333	6	57	2024-05-06 16:07:00.55084+03	17
334	17	23	2024-05-06 15:55:12.901312+03	97
335	10	22	2024-05-06 15:51:55.862136+03	96
336	11	74	2024-05-06 15:47:21.7697+03	40
337	9	57	2024-05-06 15:45:54.53556+03	41
338	16	42	2024-05-06 15:44:37.237786+03	89
339	21	74	2024-05-06 15:35:29.081127+03	30
340	19	42	2024-05-06 15:07:11.11341+03	14
341	9	62	2024-05-06 15:00:56.081023+03	60
342	7	56	2024-05-06 14:53:16.011388+03	67
343	17	78	2024-05-06 14:48:44.45973+03	52
344	21	71	2024-05-06 14:25:15.720429+03	75
345	19	56	2024-05-06 14:21:24.201097+03	45
346	11	47	2024-05-06 14:18:42.104548+03	50
347	8	68	2024-05-06 14:13:33.995308+03	30
348	13	26	2024-05-06 14:11:07.725997+03	78
349	8	60	2024-05-06 13:34:49.738219+03	37
350	14	41	2024-05-06 13:23:13.458422+03	46
351	19	20	2024-05-06 12:54:30.123458+03	19
352	22	56	2024-05-06 12:49:13.304572+03	90
353	12	54	2024-05-06 12:45:15.388232+03	16
354	22	46	2024-05-06 12:44:08.403009+03	30
355	7	74	2024-05-06 12:40:48.695867+03	40
356	12	75	2024-05-06 12:23:53.815932+03	50
357	9	56	2024-05-06 11:40:39.357803+03	52
358	10	49	2024-05-06 11:38:13.000995+03	6
359	7	77	2024-05-06 11:10:53.143368+03	16
360	15	72	2024-05-06 11:07:42.054457+03	7
361	19	48	2024-05-06 10:53:33.299012+03	78
362	4	76	2024-05-06 10:39:37.213311+03	27
363	14	30	2024-05-06 09:40:13.741064+03	18
364	14	26	2024-05-06 09:38:25.644423+03	62
365	17	65	2024-05-06 09:32:41.017602+03	10
366	5	66	2024-05-06 09:22:41.961241+03	39
367	16	23	2024-05-06 09:18:24.815175+03	77
368	20	63	2024-05-06 09:06:54.039955+03	99
369	22	64	2024-05-06 08:42:43.894896+03	53
370	9	48	2024-05-06 08:34:21.068677+03	32
371	13	53	2024-05-06 08:32:55.717323+03	24
372	16	76	2024-05-06 08:15:13.639904+03	15
373	9	40	2024-05-06 08:08:24.091173+03	69
374	4	26	2024-05-06 08:05:09.131579+03	36
375	22	68	2024-05-06 07:58:04.689097+03	14
376	22	24	2024-05-06 07:28:06.587405+03	28
377	12	21	2024-05-06 07:26:21.488204+03	65
378	6	22	2024-05-06 07:24:55.695325+03	3
379	10	58	2024-05-06 06:51:24.830934+03	60
380	22	40	2024-05-06 06:36:06.137636+03	86
381	18	55	2024-05-06 06:05:56.300625+03	70
382	19	49	2024-05-06 06:02:30.089025+03	18
383	14	64	2024-05-06 05:55:28.611169+03	6
384	14	55	2024-05-06 05:36:56.325252+03	38
385	3	52	2024-05-06 05:34:06.006233+03	72
386	22	66	2024-05-06 04:41:29.424396+03	71
387	13	69	2024-05-06 04:30:31.285025+03	6
388	9	47	2024-05-06 04:13:54.629682+03	97
389	9	33	2024-05-06 03:56:53.718242+03	17
390	5	44	2024-05-06 03:41:08.545765+03	71
391	11	27	2024-05-06 03:38:29.41359+03	75
392	17	33	2024-05-06 03:38:17.997524+03	16
393	8	77	2024-05-06 03:34:04.000008+03	85
394	3	66	2024-05-06 03:15:12.835406+03	56
395	10	61	2024-05-06 02:55:44.790261+03	99
396	11	55	2024-05-06 02:51:31.17079+03	2
397	18	39	2024-05-06 02:23:00.513196+03	51
398	5	26	2024-05-06 02:10:05.103323+03	19
399	21	19	2024-05-06 01:13:34.573702+03	68
400	3	44	2024-05-06 01:07:46.992324+03	97
401	3	76	2024-05-06 00:59:59.289067+03	82
402	14	49	2024-05-06 00:56:28.172742+03	9
403	16	67	2024-05-06 00:28:24.291676+03	51
404	12	72	2024-05-06 00:23:59.347592+03	82
405	4	60	2024-05-06 00:18:30.276132+03	6
406	6	71	2024-05-05 23:43:29.206767+03	32
407	18	68	2024-05-05 23:33:05.331057+03	5
408	17	55	2024-05-05 23:28:29.824121+03	49
409	3	78	2024-05-05 23:03:59.206932+03	34
410	3	62	2024-05-05 22:58:55.890801+03	79
411	9	67	2024-05-05 22:51:44.418994+03	52
412	9	71	2024-05-05 22:33:15.031617+03	8
413	21	67	2024-05-05 22:29:23.955399+03	49
414	22	22	2024-05-05 22:20:30.305587+03	20
415	4	46	2024-05-05 22:13:21.25981+03	27
416	7	45	2024-05-05 21:31:14.914213+03	99
417	14	72	2024-05-05 21:18:06.172988+03	36
418	21	56	2024-05-05 21:18:00.204925+03	57
419	17	68	2024-05-05 21:07:45.685932+03	50
420	8	48	2024-05-05 21:02:53.994718+03	1
421	8	73	2024-05-05 21:00:29.275303+03	98
422	13	34	2024-05-05 20:01:37.065341+03	10
423	19	26	2024-05-05 20:01:18.211525+03	50
424	17	38	2024-05-05 19:42:04.956533+03	82
425	14	58	2024-05-05 19:36:39.581375+03	26
426	16	71	2024-05-05 19:18:46.296786+03	48
427	3	70	2024-05-05 19:18:32.565254+03	58
428	16	62	2024-05-05 19:14:36.305622+03	81
429	6	28	2024-05-05 18:57:02.636944+03	9
430	5	78	2024-05-05 18:04:54.886033+03	76
431	13	43	2024-05-05 17:40:32.061551+03	10
432	13	63	2024-05-05 17:34:11.627758+03	63
433	13	57	2024-05-05 17:29:47.005528+03	20
434	14	38	2024-05-05 17:10:39.430359+03	17
435	19	78	2024-05-05 17:04:38.0604+03	3
436	16	29	2024-05-05 16:31:04.552546+03	95
437	18	64	2024-05-05 16:00:43.146264+03	92
438	7	24	2024-05-05 15:50:40.322469+03	97
439	9	66	2024-05-05 15:48:02.502353+03	68
440	12	22	2024-05-05 15:33:04.63238+03	78
441	21	24	2024-05-05 15:22:29.659777+03	43
442	4	74	2024-05-05 15:19:47.707271+03	88
443	22	35	2024-05-05 15:18:25.527545+03	85
444	6	66	2024-05-05 15:01:56.73809+03	65
445	11	40	2024-05-05 14:40:27.685114+03	94
446	11	20	2024-05-05 14:28:08.583224+03	97
447	17	49	2024-05-05 14:25:34.630395+03	8
448	18	48	2024-05-05 14:07:53.541552+03	40
449	6	41	2024-05-05 13:35:39.396833+03	0
450	11	72	2024-05-05 13:17:57.436745+03	1
451	7	64	2024-05-05 13:04:59.3952+03	91
452	3	34	2024-05-05 12:49:16.125169+03	93
453	13	77	2024-05-05 12:20:32.883259+03	50
454	17	56	2024-05-05 12:02:52.660349+03	83
455	16	26	2024-05-05 11:54:21.135099+03	32
456	9	36	2024-05-05 11:52:01.754787+03	93
457	19	29	2024-05-05 11:49:15.094357+03	65
458	17	41	2024-05-05 11:37:39.090994+03	7
459	7	44	2024-05-05 11:35:00.707027+03	32
460	7	50	2024-05-05 11:24:51.925284+03	32
461	11	50	2024-05-05 10:51:52.20399+03	99
462	4	43	2024-05-05 10:51:06.394711+03	75
463	14	70	2024-05-05 10:36:09.235896+03	59
464	11	77	2024-05-05 10:19:44.680198+03	24
465	14	65	2024-05-05 10:10:08.338221+03	78
466	8	46	2024-05-05 10:07:01.385573+03	61
467	15	44	2024-05-05 09:55:13.028299+03	73
468	9	29	2024-05-05 09:39:46.336586+03	2
469	18	59	2024-05-05 09:32:27.256314+03	37
470	19	53	2024-05-05 09:05:45.046963+03	12
471	18	63	2024-05-05 09:04:20.839106+03	67
472	7	30	2024-05-05 08:57:30.758801+03	83
473	18	28	2024-05-05 08:41:53.907135+03	20
474	17	31	2024-05-05 08:29:42.646923+03	94
475	16	70	2024-05-05 08:15:20.307503+03	78
476	5	48	2024-05-05 07:42:09.573015+03	53
477	21	28	2024-05-05 07:40:19.963258+03	50
478	16	30	2024-05-05 07:38:29.880123+03	17
479	19	73	2024-05-05 07:37:14.058067+03	66
480	22	21	2024-05-05 07:26:23.298507+03	57
481	4	64	2024-05-05 07:26:03.120032+03	5
482	16	25	2024-05-05 06:34:56.520992+03	47
483	20	70	2024-05-05 05:43:52.689702+03	39
484	6	40	2024-05-05 05:39:29.007996+03	65
485	19	37	2024-05-05 05:35:22.094244+03	76
486	16	35	2024-05-05 05:25:36.202549+03	93
487	15	75	2024-05-05 05:17:55.329734+03	58
488	11	41	2024-05-05 05:08:29.983865+03	18
489	12	76	2024-05-05 04:59:09.876283+03	99
490	9	53	2024-05-05 04:55:26.541097+03	67
491	19	60	2024-05-05 04:53:35.381283+03	44
492	9	72	2024-05-05 04:37:19.211223+03	8
493	3	23	2024-05-05 04:23:19.648344+03	62
494	4	73	2024-05-05 03:27:16.698131+03	74
495	12	40	2024-05-05 03:26:28.926494+03	59
496	13	59	2024-05-05 02:50:17.752246+03	17
497	12	23	2024-05-05 02:39:36.856114+03	46
498	13	37	2024-05-05 02:14:23.81059+03	48
499	9	28	2024-05-05 02:10:47.462992+03	96
500	15	43	2024-05-05 01:29:15.222832+03	73
501	5	54	2024-05-05 01:17:57.246071+03	12
502	3	50	2024-05-05 00:49:21.521883+03	90
503	8	54	2024-05-05 00:39:54.919572+03	88
504	17	74	2024-05-05 00:36:48.971394+03	42
505	6	38	2024-05-05 00:30:17.179301+03	62
506	13	75	2024-05-05 00:08:54.265916+03	5
507	16	32	2024-05-05 00:06:28.861628+03	35
508	10	51	2024-05-05 00:02:42.930582+03	82
509	22	54	2024-05-04 23:56:28.786705+03	10
510	6	67	2024-05-04 23:51:25.511902+03	79
511	10	72	2024-05-04 23:25:42.641716+03	40
512	6	19	2024-05-04 22:45:31.44644+03	30
513	15	67	2024-05-04 22:13:08.418686+03	92
514	21	49	2024-05-04 22:08:32.761394+03	5
515	3	65	2024-05-04 21:52:50.571425+03	65
516	6	77	2024-05-04 21:43:08.946493+03	52
517	3	71	2024-05-04 21:25:20.81293+03	12
518	11	21	2024-05-04 21:20:31.045068+03	22
519	9	30	2024-05-04 21:14:30.649543+03	82
520	15	24	2024-05-04 20:42:29.382573+03	94
521	12	71	2024-05-04 20:40:48.496959+03	22
522	22	69	2024-05-04 20:22:56.901901+03	25
523	15	36	2024-05-04 19:37:58.79946+03	58
524	19	35	2024-05-04 19:29:14.264575+03	40
525	4	48	2024-05-04 18:49:14.593592+03	84
526	19	24	2024-05-04 18:27:26.699432+03	9
527	14	19	2024-05-04 18:22:53.072779+03	97
528	13	71	2024-05-04 18:13:55.702934+03	30
529	19	43	2024-05-04 18:13:28.694432+03	8
530	4	20	2024-05-04 18:02:12.192398+03	30
531	5	42	2024-05-04 17:57:38.352295+03	23
532	15	31	2024-05-04 17:26:11.652888+03	31
533	18	76	2024-05-04 17:25:00.690146+03	98
534	11	33	2024-05-04 17:20:26.901708+03	60
535	13	47	2024-05-04 17:19:34.147939+03	73
536	17	63	2024-05-04 17:13:19.424015+03	19
537	13	29	2024-05-04 16:53:06.072946+03	81
538	8	57	2024-05-04 16:30:39.181467+03	70
539	5	69	2024-05-04 16:16:56.488444+03	91
540	12	28	2024-05-04 15:22:41.891592+03	6
541	8	29	2024-05-04 15:04:49.7269+03	65
542	17	71	2024-05-04 15:04:11.985084+03	93
543	19	27	2024-05-04 14:33:47.938213+03	8
544	20	69	2024-05-04 14:15:56.715549+03	38
545	22	71	2024-05-04 14:00:09.004091+03	32
546	6	44	2024-05-04 13:29:17.816381+03	78
547	16	78	2024-05-04 13:20:35.580638+03	99
548	7	69	2024-05-04 12:45:54.493444+03	47
549	4	21	2024-05-04 12:42:49.777338+03	1
550	7	63	2024-05-04 12:24:55.944068+03	25
551	11	31	2024-05-04 11:38:58.307545+03	84
552	21	60	2024-05-04 11:29:48.711477+03	26
553	6	58	2024-05-04 10:53:24.228294+03	50
554	15	74	2024-05-04 10:45:06.688271+03	3
555	12	37	2024-05-04 08:26:18.882479+03	3
556	10	20	2024-05-04 08:11:32.295517+03	56
557	22	30	2024-05-04 08:07:29.233537+03	88
558	20	44	2024-05-04 07:19:56.224459+03	85
559	22	37	2024-05-04 07:18:30.296924+03	100
560	8	55	2024-05-04 07:10:36.386829+03	71
561	10	40	2024-05-04 06:57:49.657166+03	17
562	19	54	2024-05-04 05:42:25.39147+03	60
563	11	57	2024-05-04 05:33:18.999105+03	2
564	3	45	2024-05-04 05:09:56.592532+03	43
565	20	26	2024-05-04 05:01:33.300728+03	78
566	16	51	2024-05-04 04:53:23.022837+03	38
567	10	56	2024-05-04 04:39:28.669745+03	41
568	22	23	2024-05-04 04:38:42.52371+03	24
569	9	65	2024-05-04 04:30:47.42797+03	83
570	8	27	2024-05-04 04:18:26.317822+03	68
571	20	30	2024-05-04 04:10:54.359067+03	37
572	13	55	2024-05-04 04:09:37.348745+03	98
573	16	72	2024-05-04 04:03:27.396617+03	59
574	20	53	2024-05-04 03:50:16.34261+03	78
575	15	32	2024-05-04 03:29:02.646711+03	10
576	18	45	2024-05-04 03:10:22.893347+03	61
577	5	50	2024-05-04 02:52:24.650272+03	58
578	16	28	2024-05-04 02:44:27.943818+03	60
579	12	77	2024-05-04 02:03:01.344988+03	33
580	19	65	2024-05-04 01:50:39.632095+03	56
581	15	21	2024-05-04 01:31:19.064347+03	11
582	16	33	2024-05-04 01:29:54.289546+03	85
583	19	67	2024-05-04 01:16:05.159783+03	91
584	11	54	2024-05-04 01:02:42.55107+03	85
585	21	46	2024-05-04 00:34:35.33703+03	77
586	8	52	2024-05-04 00:31:38.594674+03	62
587	5	60	2024-05-04 00:28:55.131419+03	57
588	8	66	2024-05-04 00:02:24.283493+03	52
589	19	71	2024-05-03 23:28:47.313595+03	15
590	21	21	2024-05-03 23:12:51.076299+03	17
591	4	59	2024-05-03 22:52:40.994056+03	1
592	20	23	2024-05-03 22:52:35.688478+03	83
593	5	25	2024-05-03 22:39:37.909023+03	29
594	4	56	2024-05-03 22:35:40.676315+03	63
595	8	69	2024-05-03 22:28:21.122881+03	86
596	8	53	2024-05-03 22:21:34.378032+03	57
597	16	48	2024-05-03 21:57:13.960259+03	64
598	5	57	2024-05-03 21:41:13.003622+03	11
599	13	65	2024-05-03 21:33:17.670079+03	25
600	5	73	2024-05-03 21:29:37.849972+03	70
601	3	32	2024-05-03 20:47:53.44341+03	47
602	5	34	2024-05-03 20:43:18.778223+03	73
603	16	38	2024-05-03 20:34:38.675347+03	51
604	20	52	2024-05-03 20:04:38.530422+03	43
605	22	70	2024-05-03 19:37:51.27756+03	90
606	5	58	2024-05-03 19:37:26.502059+03	5
607	12	50	2024-05-03 19:33:15.94816+03	42
608	4	29	2024-05-03 19:30:29.697557+03	77
609	3	67	2024-05-03 19:25:30.293084+03	90
610	12	49	2024-05-03 19:25:07.973528+03	8
611	11	37	2024-05-03 19:23:25.630999+03	25
612	8	32	2024-05-03 19:16:34.317103+03	19
613	20	50	2024-05-03 19:05:07.62705+03	50
614	18	44	2024-05-03 18:36:32.67531+03	27
615	3	63	2024-05-03 18:29:33.164032+03	97
616	21	39	2024-05-03 17:56:03.580614+03	84
617	5	72	2024-05-03 17:43:10.110245+03	99
618	7	67	2024-05-03 17:27:22.867518+03	14
619	16	63	2024-05-03 17:14:40.014815+03	48
620	22	42	2024-05-03 17:13:27.203667+03	20
621	8	74	2024-05-03 17:01:52.500571+03	74
622	14	25	2024-05-03 16:50:09.99577+03	79
623	11	49	2024-05-03 16:35:40.558044+03	48
624	18	75	2024-05-03 16:27:46.119385+03	53
625	4	45	2024-05-03 16:18:56.56623+03	65
626	6	29	2024-05-03 16:17:21.518661+03	27
627	20	24	2024-05-03 16:00:50.888594+03	83
628	6	55	2024-05-03 15:58:06.704581+03	90
629	12	24	2024-05-03 15:38:59.480546+03	58
630	8	51	2024-05-03 15:30:29.745336+03	2
631	16	36	2024-05-03 15:28:58.133284+03	28
632	7	46	2024-05-03 15:25:30.961777+03	77
633	7	60	2024-05-03 15:05:43.928698+03	4
634	19	33	2024-05-03 15:02:24.414702+03	28
635	14	27	2024-05-03 14:48:40.061236+03	65
636	11	26	2024-05-03 14:37:56.233787+03	73
637	22	63	2024-05-03 14:30:31.93364+03	29
638	6	48	2024-05-03 14:06:53.098985+03	70
639	9	43	2024-05-03 13:51:35.814198+03	26
640	15	25	2024-05-03 13:31:13.526263+03	83
641	5	62	2024-05-03 12:18:07.562311+03	45
642	6	34	2024-05-03 10:51:49.583118+03	12
643	21	78	2024-05-03 10:38:16.432826+03	44
644	20	62	2024-05-03 10:28:38.737913+03	43
645	22	52	2024-05-03 10:23:17.484644+03	91
646	19	41	2024-05-03 09:51:18.650347+03	89
647	11	38	2024-05-03 09:49:53.779248+03	90
648	16	54	2024-05-03 09:48:35.634923+03	72
649	15	47	2024-05-03 09:48:00.408526+03	26
650	18	58	2024-05-03 09:47:55.71115+03	18
651	20	45	2024-05-03 09:46:14.006393+03	49
652	17	22	2024-05-03 09:33:00.394928+03	32
653	22	34	2024-05-03 09:03:53.839945+03	30
654	17	24	2024-05-03 09:01:18.462024+03	66
655	18	29	2024-05-03 08:38:50.122656+03	92
656	7	19	2024-05-03 08:14:21.877642+03	53
657	6	24	2024-05-03 08:11:17.297577+03	57
658	22	33	2024-05-03 08:09:34.898708+03	81
659	12	68	2024-05-03 07:46:51.996854+03	76
660	7	32	2024-05-03 07:41:59.325835+03	63
661	10	52	2024-05-03 07:33:08.655529+03	45
662	22	55	2024-05-03 07:25:48.890155+03	74
663	12	38	2024-05-03 07:18:01.143319+03	11
664	18	61	2024-05-03 07:15:39.446893+03	67
665	3	46	2024-05-03 06:53:53.070129+03	32
666	15	65	2024-05-03 06:52:35.418699+03	65
667	4	37	2024-05-03 06:45:50.921335+03	37
668	6	23	2024-05-03 06:18:48.583208+03	64
669	20	57	2024-05-03 06:15:21.633675+03	56
670	4	35	2024-05-03 06:11:51.251252+03	36
671	12	57	2024-05-03 05:56:23.098298+03	18
672	7	27	2024-05-03 05:41:31.598656+03	66
673	10	70	2024-05-03 05:31:57.255338+03	80
674	11	51	2024-05-03 05:05:16.751965+03	92
675	12	46	2024-05-03 05:04:21.487746+03	57
676	20	49	2024-05-03 04:55:51.570413+03	71
677	4	51	2024-05-03 04:06:05.685109+03	57
678	3	68	2024-05-03 04:03:59.124124+03	62
679	21	26	2024-05-03 03:58:21.767791+03	39
680	16	75	2024-05-03 03:37:19.19582+03	0
681	11	45	2024-05-03 03:24:12.700511+03	24
682	4	66	2024-05-03 03:16:35.593071+03	85
683	10	36	2024-05-03 03:06:58.161154+03	22
684	8	64	2024-05-03 02:58:29.052869+03	6
685	13	73	2024-05-03 02:33:11.585772+03	9
686	22	29	2024-05-03 02:09:05.195638+03	9
687	22	67	2024-05-03 02:06:18.754425+03	39
688	5	56	2024-05-03 01:56:44.877551+03	46
689	9	39	2024-05-03 01:37:57.056003+03	46
690	15	54	2024-05-03 01:35:26.991624+03	82
691	10	76	2024-05-03 01:21:58.087722+03	26
692	8	35	2024-05-03 01:06:34.236302+03	80
693	5	21	2024-05-03 01:02:00.35487+03	75
694	7	51	2024-05-03 00:29:03.565694+03	66
695	16	39	2024-05-03 00:08:31.275586+03	73
696	6	68	2024-05-02 23:43:34.232692+03	94
697	21	70	2024-05-02 23:40:44.560217+03	56
698	3	54	2024-05-02 23:37:57.86162+03	32
699	8	22	2024-05-02 23:34:31.540353+03	37
700	11	53	2024-05-02 23:14:24.065436+03	42
701	10	64	2024-05-02 23:14:00.505172+03	57
702	11	23	2024-05-02 22:59:48.97384+03	73
703	20	58	2024-05-02 22:31:28.475624+03	60
704	17	36	2024-05-02 22:08:55.473123+03	73
705	18	56	2024-05-02 21:56:14.048637+03	63
706	10	33	2024-05-02 21:39:34.425942+03	73
707	18	73	2024-05-02 21:35:00.643136+03	79
708	15	27	2024-05-02 21:27:53.518086+03	23
709	13	70	2024-05-02 21:09:04.11265+03	17
710	6	36	2024-05-02 20:55:51.346708+03	62
711	18	42	2024-05-02 20:48:46.218276+03	16
712	5	41	2024-05-02 20:46:01.448329+03	56
713	22	59	2024-05-02 20:37:33.244008+03	39
714	10	59	2024-05-02 20:35:36.233402+03	15
715	21	25	2024-05-02 20:34:39.720271+03	20
716	16	55	2024-05-02 20:21:27.671869+03	78
717	13	48	2024-05-02 20:11:55.489833+03	52
718	7	31	2024-05-02 19:58:01.650777+03	43
719	15	29	2024-05-02 19:38:13.334297+03	68
720	6	45	2024-05-02 19:23:38.895007+03	78
721	19	38	2024-05-02 19:06:11.397203+03	76
722	21	61	2024-05-02 18:59:06.888343+03	89
723	3	75	2024-05-02 18:29:58.666125+03	69
724	10	67	2024-05-02 18:10:34.55071+03	28
725	22	32	2024-05-02 18:05:38.564525+03	63
726	19	39	2024-05-02 18:01:47.606326+03	57
727	21	20	2024-05-02 18:00:30.777453+03	83
728	6	47	2024-05-02 17:36:27.187522+03	54
729	11	62	2024-05-02 16:40:25.355401+03	63
730	10	75	2024-05-02 16:40:20.054847+03	17
731	11	22	2024-05-02 16:38:40.225298+03	92
732	3	24	2024-05-02 16:36:39.695713+03	5
733	19	34	2024-05-02 16:24:45.283551+03	68
734	21	42	2024-05-02 16:20:56.416035+03	90
735	17	62	2024-05-02 16:19:27.523895+03	38
736	12	51	2024-05-02 15:57:27.1096+03	46
737	5	70	2024-05-02 15:56:31.803519+03	53
738	16	64	2024-05-02 15:41:49.901601+03	73
739	14	44	2024-05-02 15:31:37.658768+03	57
740	7	22	2024-05-02 15:18:05.883587+03	5
741	11	19	2024-05-02 15:12:03.007031+03	48
742	18	32	2024-05-02 15:10:26.678407+03	86
743	20	22	2024-05-02 14:54:09.86234+03	90
744	12	74	2024-05-02 14:04:51.666468+03	77
745	3	21	2024-05-02 13:42:47.676326+03	35
746	18	46	2024-05-02 12:44:04.899875+03	68
747	12	41	2024-05-02 12:38:19.261298+03	69
748	17	40	2024-05-02 12:35:52.735638+03	90
749	5	53	2024-05-02 12:32:44.644137+03	14
750	12	45	2024-05-02 12:32:18.516262+03	86
751	14	52	2024-05-02 11:52:27.749617+03	3
752	11	73	2024-05-02 11:38:06.92538+03	29
753	4	75	2024-05-02 11:36:32.88439+03	68
754	22	25	2024-05-02 11:14:25.9007+03	12
755	18	67	2024-05-02 11:10:32.793398+03	3
756	19	47	2024-05-02 11:00:15.455817+03	80
757	8	61	2024-05-02 10:44:23.330895+03	56
758	22	78	2024-05-02 10:43:07.418584+03	87
759	13	52	2024-05-02 10:30:45.681058+03	96
760	21	73	2024-05-02 10:30:27.465884+03	36
761	20	66	2024-05-02 09:55:34.170351+03	36
762	7	72	2024-05-02 09:45:42.307331+03	58
763	16	77	2024-05-02 09:35:10.042255+03	82
764	18	37	2024-05-02 09:25:21.77487+03	46
765	5	51	2024-05-02 09:15:25.400391+03	90
766	6	21	2024-05-02 09:08:48.90458+03	93
767	10	38	2024-05-02 08:56:52.696374+03	45
768	9	50	2024-05-02 08:23:29.180629+03	92
769	13	44	2024-05-02 08:07:30.619773+03	21
770	12	47	2024-05-02 07:50:10.439799+03	13
771	7	54	2024-05-02 07:46:28.902733+03	69
772	19	62	2024-05-02 07:42:28.869094+03	27
773	5	55	2024-05-02 07:36:45.919133+03	66
774	21	57	2024-05-02 07:19:49.990071+03	96
775	4	65	2024-05-02 06:27:20.542861+03	99
776	8	34	2024-05-02 06:21:47.460311+03	69
777	18	62	2024-05-02 06:13:43.669259+03	65
778	5	49	2024-05-02 05:40:33.994948+03	33
779	17	35	2024-05-02 05:36:36.482748+03	18
780	21	69	2024-05-02 05:21:30.511638+03	15
781	13	51	2024-05-02 05:06:04.48975+03	62
782	17	76	2024-05-02 04:56:17.870107+03	15
783	11	52	2024-05-02 04:35:44.681039+03	25
784	4	22	2024-05-02 04:18:12.494722+03	65
785	8	36	2024-05-02 04:04:33.805824+03	21
786	16	19	2024-05-02 03:57:31.15463+03	79
787	21	40	2024-05-02 03:55:36.058044+03	44
788	4	77	2024-05-02 03:48:32.334216+03	55
789	19	31	2024-05-02 03:43:13.448447+03	80
790	9	52	2024-05-02 03:18:35.573539+03	16
791	10	53	2024-05-02 03:08:45.429524+03	4
792	18	65	2024-05-02 02:59:38.432324+03	13
793	6	27	2024-05-02 02:51:33.58936+03	47
794	9	68	2024-05-02 02:49:46.110369+03	11
795	21	36	2024-05-02 02:47:51.945529+03	59
796	8	20	2024-05-02 02:37:58.75795+03	48
797	17	61	2024-05-02 02:04:53.255245+03	81
798	5	24	2024-05-02 02:04:24.281189+03	67
799	11	36	2024-05-02 02:03:58.286699+03	4
800	14	42	2024-05-02 01:58:35.207855+03	5
801	18	78	2024-05-02 01:41:34.355381+03	36
802	20	47	2024-05-02 01:28:40.287263+03	61
803	22	45	2024-05-02 01:25:39.898634+03	50
804	7	26	2024-05-02 01:25:31.985637+03	99
805	4	24	2024-05-02 01:23:39.889942+03	78
806	21	33	2024-05-02 01:15:32.602804+03	71
807	12	20	2024-05-02 01:13:33.650751+03	7
808	14	48	2024-05-02 00:59:08.157266+03	43
809	6	56	2024-05-02 00:41:40.653646+03	38
810	16	46	2024-05-02 00:10:02.681941+03	31
811	22	72	2024-05-01 23:33:21.342766+03	40
812	18	38	2024-05-01 23:30:39.011671+03	27
814	11	24	2024-05-09 20:52:27.190685+03	75
\.


--
-- Name: authors_author_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.authors_author_id_seq', 25, true);


--
-- Name: courses_author_id_seq; Type: SEQUENCE SET; Schema: public; Owner: admin
--

SELECT pg_catalog.setval('public.courses_author_id_seq', 1, false);


--
-- Name: courses_courses_id_seq; Type: SEQUENCE SET; Schema: public; Owner: admin
--

SELECT pg_catalog.setval('public.courses_courses_id_seq', 18, true);


--
-- Name: enrollments_enrollment_id_seq; Type: SEQUENCE SET; Schema: public; Owner: admin
--

SELECT pg_catalog.setval('public.enrollments_enrollment_id_seq', 200, true);


--
-- Name: lessons_lesson_id_seq; Type: SEQUENCE SET; Schema: public; Owner: admin
--

SELECT pg_catalog.setval('public.lessons_lesson_id_seq', 94, true);


--
-- Name: responses_response_id_seq; Type: SEQUENCE SET; Schema: public; Owner: admin
--

SELECT pg_catalog.setval('public.responses_response_id_seq', 37, true);


--
-- Name: students_progress_progress_id_seq; Type: SEQUENCE SET; Schema: public; Owner: admin
--

SELECT pg_catalog.setval('public.students_progress_progress_id_seq', 814, true);


--
-- Name: students_student_id_seq; Type: SEQUENCE SET; Schema: public; Owner: admin
--

SELECT pg_catalog.setval('public.students_student_id_seq', 23, true);


--
-- Name: authors authors_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.authors
    ADD CONSTRAINT authors_pkey PRIMARY KEY (author_id);


--
-- Name: courses courses_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.courses
    ADD CONSTRAINT courses_pkey PRIMARY KEY (course_id);


--
-- Name: enrollments enrollments_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.enrollments
    ADD CONSTRAINT enrollments_pkey PRIMARY KEY (enrollment_id);


--
-- Name: lessons lessons_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.lessons
    ADD CONSTRAINT lessons_pkey PRIMARY KEY (lesson_id);


--
-- Name: responses responses_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.responses
    ADD CONSTRAINT responses_pkey PRIMARY KEY (response_id);


--
-- Name: students students_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.students
    ADD CONSTRAINT students_pkey PRIMARY KEY (student_id);


--
-- Name: students_progress students_progress_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.students_progress
    ADD CONSTRAINT students_progress_pkey PRIMARY KEY (progress_id);


--
-- Name: authors unique_author_email; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.authors
    ADD CONSTRAINT unique_author_email UNIQUE (email);


--
-- Name: authors unique_author_login; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.authors
    ADD CONSTRAINT unique_author_login UNIQUE (login);


--
-- Name: courses unique_courses_title; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.courses
    ADD CONSTRAINT unique_courses_title UNIQUE (title);


--
-- Name: students unique_students_email; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.students
    ADD CONSTRAINT unique_students_email UNIQUE (email);


--
-- Name: students unique_students_login; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.students
    ADD CONSTRAINT unique_students_login UNIQUE (login);


--
-- Name: authors_email_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX authors_email_idx ON public.authors USING btree (email);


--
-- Name: authors_login_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX authors_login_idx ON public.authors USING btree (login);


--
-- Name: courses_author_id_idx; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX courses_author_id_idx ON public.courses USING btree (author_id);


--
-- Name: enrollments_course_id_idx; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX enrollments_course_id_idx ON public.enrollments USING btree (course_id);


--
-- Name: enrollments_student_id_idx; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX enrollments_student_id_idx ON public.enrollments USING btree (student_id);


--
-- Name: responses_course_id_idx; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX responses_course_id_idx ON public.responses USING btree (course_id);


--
-- Name: responses_student_id_idx; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX responses_student_id_idx ON public.responses USING btree (student_id);


--
-- Name: students_email_idx; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX students_email_idx ON public.students USING btree (email);


--
-- Name: students_login_idx; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX students_login_idx ON public.students USING btree (login);


--
-- Name: students_progress_lesson_id_idx; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX students_progress_lesson_id_idx ON public.students_progress USING btree (lesson_id);


--
-- Name: students_progress_student_id_idx; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX students_progress_student_id_idx ON public.students_progress USING btree (student_id);


--
-- Name: unique_lesson_course; Type: INDEX; Schema: public; Owner: admin
--

CREATE UNIQUE INDEX unique_lesson_course ON public.lessons USING btree (course_id, lesson_number);


--
-- Name: unique_student_course_enrollment; Type: INDEX; Schema: public; Owner: admin
--

CREATE UNIQUE INDEX unique_student_course_enrollment ON public.enrollments USING btree (student_id, course_id);


--
-- Name: unique_student_course_response; Type: INDEX; Schema: public; Owner: admin
--

CREATE UNIQUE INDEX unique_student_course_response ON public.responses USING btree (student_id, course_id);


--
-- Name: students_progress lesson_completion_trigger; Type: TRIGGER; Schema: public; Owner: admin
--

CREATE TRIGGER lesson_completion_trigger BEFORE INSERT ON public.students_progress FOR EACH ROW EXECUTE FUNCTION public.check_lesson_completion();


--
-- Name: lessons update_course_duration_trigger; Type: TRIGGER; Schema: public; Owner: admin
--

CREATE TRIGGER update_course_duration_trigger AFTER INSERT OR DELETE ON public.lessons FOR EACH ROW EXECUTE FUNCTION public.update_course_duration();


--
-- Name: students_progress update_student_status_trigger; Type: TRIGGER; Schema: public; Owner: admin
--

CREATE TRIGGER update_student_status_trigger AFTER INSERT OR DELETE ON public.students_progress FOR EACH ROW EXECUTE FUNCTION public.update_student_course_status();


--
-- Name: courses fk_author_courses; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.courses
    ADD CONSTRAINT fk_author_courses FOREIGN KEY (author_id) REFERENCES public.authors(author_id);


--
-- Name: enrollments fk_course_enrollment; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.enrollments
    ADD CONSTRAINT fk_course_enrollment FOREIGN KEY (course_id) REFERENCES public.courses(course_id);


--
-- Name: lessons fk_course_lesson; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.lessons
    ADD CONSTRAINT fk_course_lesson FOREIGN KEY (course_id) REFERENCES public.courses(course_id);


--
-- Name: responses fk_course_responses; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.responses
    ADD CONSTRAINT fk_course_responses FOREIGN KEY (course_id) REFERENCES public.courses(course_id);


--
-- Name: students_progress fk_lesson_progress; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.students_progress
    ADD CONSTRAINT fk_lesson_progress FOREIGN KEY (lesson_id) REFERENCES public.lessons(lesson_id);


--
-- Name: enrollments fk_student_enrollment; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.enrollments
    ADD CONSTRAINT fk_student_enrollment FOREIGN KEY (student_id) REFERENCES public.students(student_id);


--
-- Name: students_progress fk_student_progress; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.students_progress
    ADD CONSTRAINT fk_student_progress FOREIGN KEY (student_id) REFERENCES public.students(student_id);


--
-- Name: responses fk_student_responses; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.responses
    ADD CONSTRAINT fk_student_responses FOREIGN KEY (student_id) REFERENCES public.students(student_id);


--
-- Name: TABLE authors; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.authors TO client;


--
-- Name: TABLE courses; Type: ACL; Schema: public; Owner: admin
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.courses TO client;


--
-- Name: SEQUENCE courses_courses_id_seq; Type: ACL; Schema: public; Owner: admin
--

GRANT SELECT,USAGE ON SEQUENCE public.courses_courses_id_seq TO client;


--
-- Name: TABLE enrollments; Type: ACL; Schema: public; Owner: admin
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.enrollments TO client;


--
-- Name: TABLE lessons; Type: ACL; Schema: public; Owner: admin
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.lessons TO client;


--
-- Name: TABLE responses; Type: ACL; Schema: public; Owner: admin
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.responses TO client;


--
-- Name: TABLE students; Type: ACL; Schema: public; Owner: admin
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.students TO client;


--
-- Name: TABLE students_progress; Type: ACL; Schema: public; Owner: admin
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.students_progress TO client;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: public; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT SELECT,INSERT,DELETE,UPDATE ON TABLES TO client;


--
-- PostgreSQL database dump complete
--

