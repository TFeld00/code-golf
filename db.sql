--
-- PostgreSQL database dump
--

-- Dumped from database version 11.1
-- Dumped by pg_dump version 11.1

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;


--
-- Name: hole; Type: TYPE; Schema: public; Owner: jraspass
--

CREATE TYPE public.hole AS ENUM (
    '12-days-of-christmas',
    '99-bottles-of-beer',
    'arabic-to-roman',
    'brainfuck',
    'christmas-trees',
    'cubes',
    'diamonds',
    'divisors',
    'emirp-numbers',
    'evil-numbers',
    'fibonacci',
    'fizz-buzz',
    'happy-numbers',
    'leap-years',
    'morse-decoder',
    'morse-encoder',
    'niven-numbers',
    'odious-numbers',
    'pangram-grep',
    'pascals-triangle',
    'pernicious-numbers',
    'poker',
    'prime-numbers',
    'quine',
    'roman-to-arabic',
    'rule-110',
    'seven-segment',
    'sierpiński-triangle',
    'spelling-numbers',
    'sudoku',
    'ten-pin-bowling',
    'λ',
    'π',
    'τ',
    'φ',
    '√2',
    '𝑒'
);


--
-- Name: lang; Type: TYPE; Schema: public; Owner: jraspass
--

CREATE TYPE public.lang AS ENUM (
    'bash',
    'brainfuck',
    'c',
    'haskell',
    'j',
    'javascript',
    'julia',
    'lisp',
    'lua',
    'nim',
    'perl',
    'perl6',
    'php',
    'python',
    'ruby'
);


--
-- Name: trophy; Type: TYPE; Schema: public; Owner: jraspass
--

CREATE TYPE public.trophy AS ENUM (
    'elephpant-in-the-room',
    'happy-birthday-code-golf',
    'hello-world',
    'inception',
    'interview-ready',
    'its-over-9000',
    'my-god-its-full-of-stars',
    'ouroboros',
    'polyglot',
    'slowcoach',
    'tim-toady',
    'the-watering-hole'
);


SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: solutions; Type: TABLE; Schema: public; Owner: jraspass
--

CREATE TABLE public.solutions (
    submitted timestamp without time zone NOT NULL,
    user_id integer NOT NULL,
    hole public.hole NOT NULL,
    lang public.lang NOT NULL,
    code text NOT NULL,
    failing boolean DEFAULT false NOT NULL
);


--
-- Name: points; Type: VIEW; Schema: public; Owner: jraspass
--

CREATE VIEW public.points AS
 WITH leaderboard AS (
         SELECT DISTINCT ON (solutions.hole, solutions.user_id) solutions.hole,
            length(solutions.code) AS strokes,
            solutions.user_id
           FROM public.solutions
          WHERE (NOT solutions.failing)
          ORDER BY solutions.hole, solutions.user_id, (length(solutions.code)), solutions.submitted
        ), scored_leaderboard AS (
         SELECT l.hole,
            round(((((count(*) OVER (PARTITION BY l.hole) - rank() OVER (PARTITION BY l.hole ORDER BY l.strokes)) + 1))::numeric * (1000.0 / (count(*) OVER (PARTITION BY l.hole))::numeric))) AS score,
            l.user_id
           FROM leaderboard l
        )
 SELECT scored_leaderboard.user_id,
    sum(scored_leaderboard.score) AS points,
    count(*) AS holes
   FROM scored_leaderboard
  GROUP BY scored_leaderboard.user_id;


--
-- Name: trophies; Type: TABLE; Schema: public; Owner: jraspass
--

CREATE TABLE public.trophies (
    earned timestamp without time zone NOT NULL,
    user_id integer NOT NULL,
    trophy public.trophy NOT NULL
);


--
-- Name: users; Type: TABLE; Schema: public; Owner: jraspass
--

CREATE TABLE public.users (
    id integer NOT NULL,
    login text NOT NULL
);


--
-- Name: solutions solutions_pkey; Type: CONSTRAINT; Schema: public; Owner: jraspass
--

ALTER TABLE ONLY public.solutions
    ADD CONSTRAINT solutions_pkey PRIMARY KEY (user_id, hole, lang);


--
-- Name: trophies trophies_user_id_trophy_key; Type: CONSTRAINT; Schema: public; Owner: jraspass
--

ALTER TABLE ONLY public.trophies
    ADD CONSTRAINT trophies_user_id_trophy_key UNIQUE (user_id, trophy);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: jraspass
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: trophies trophies_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: jraspass
--

ALTER TABLE ONLY public.trophies
    ADD CONSTRAINT trophies_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: TABLE solutions; Type: ACL; Schema: public; Owner: jraspass
--

GRANT SELECT,INSERT,UPDATE ON TABLE public.solutions TO code_golf;


--
-- Name: TABLE points; Type: ACL; Schema: public; Owner: jraspass
--

GRANT SELECT ON TABLE public.points TO code_golf;


--
-- Name: TABLE trophies; Type: ACL; Schema: public; Owner: jraspass
--

GRANT SELECT,INSERT,UPDATE ON TABLE public.trophies TO code_golf;


--
-- Name: TABLE users; Type: ACL; Schema: public; Owner: jraspass
--

GRANT SELECT,INSERT,UPDATE ON TABLE public.users TO code_golf;


--
-- PostgreSQL database dump complete
--
