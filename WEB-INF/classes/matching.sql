--
-- PostgreSQL database dump
--

-- Dumped from database version 15.0
-- Dumped by pg_dump version 15.1

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
-- Name: get_classement(character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_classement(idcurrentuser character varying) RETURNS TABLE(iduser_disponible character varying, nom_disponible character varying, password_disponible character varying, genre_disponible character varying, note_disponible numeric)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY SELECT Classement.iduser, nom, password, genre, note FROM
    (SELECT * FROM get_users_disponible(idCurrentUser) AS f(idUser, nom, password, genre)) AS users JOIN (
        SELECT info.iduser, SUM((coefficient * note)) / SUM(coefficient) as note
        FROM (
            SELECT info.iduser, coefficient, note  FROM informations AS info JOIN (
                SELECT *
                FROM criteres
                WHERE idUser = idCurrentUser
            ) AS c ON info.idAxe = c.idAxe
        ) AS info JOIN users ON info.iduser = users.idUser
        GROUP BY info.idUser
    ) AS Classement ON Classement.idUser = users.idUser
    WHERE genre = 'feminin' AND note >=14 AND get_note(Classement.idUser, idCurrentUser) >= 14
    ORDER BY note DESC;
END; $$;


ALTER FUNCTION public.get_classement(idcurrentuser character varying) OWNER TO postgres;

--
-- Name: get_classement(character varying, character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_classement(idcurrentuser character varying, genre_user character varying) RETURNS TABLE(iduser_disponible character varying, nom_disponible character varying, password_disponible character varying, genre_disponible character varying, note_disponible numeric)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY SELECT Classement.iduser, nom, password, genre, note FROM
    (SELECT * FROM get_users_disponible(idCurrentUser) AS f(idUser, nom, password, genre)) AS users JOIN (
        SELECT info.iduser, SUM((coefficient * note)) / SUM(coefficient) as note
        FROM (
            SELECT info.iduser, coefficient, note  FROM informations AS info JOIN (
                SELECT *
                FROM criteres
                WHERE idUser = idCurrentUser
            ) AS c ON info.idAxe = c.idAxe
        ) AS info JOIN users ON info.iduser = users.idUser
        GROUP BY info.idUser
    ) AS Classement ON Classement.idUser = users.idUser
    WHERE genre = genre_user AND note >=14 AND get_note(Classement.idUser, idCurrentUser) >= 14 AND Classement.idUser != idCurrentUser
    ORDER BY note DESC;
END; $$;


ALTER FUNCTION public.get_classement(idcurrentuser character varying, genre_user character varying) OWNER TO postgres;

--
-- Name: get_note(character varying, character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_note(iduser1 character varying, iduser2 character varying) RETURNS double precision
    LANGUAGE plpgsql
    AS $$
declare
   note_moyenne DOUBLE PRECISION;
BEGIN
    SELECT SUM(note) / SUM(coefficient) into note_moyenne
    FROM (
        SELECT (note*coefficient) as note, c.coefficient
        FROM (
            SELECT *
            FROM informations
            WHERE idUser = idUser2
        ) AS info JOIN (
            SELECT *
            FROM criteres
            WHERE idUser = idUser1
        ) AS c ON info.idAxe = c.idAxe
        JOIN axes AS axe ON info.idAxe = axe.idAxe
    ) AS note;

    RETURN note_moyenne;
END; $$;


ALTER FUNCTION public.get_note(iduser1 character varying, iduser2 character varying) OWNER TO postgres;

--
-- Name: get_users_disponible(character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_users_disponible(idcurrentuser character varying) RETURNS TABLE(iduser_disponible character varying, nom_disponible character varying, password_disponible character varying, genre_disponible character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY SELECT idUser, nom, password, genre
    FROM Users
    WHERE iduser NOT IN (
        SELECT iduser1
        FROM raikitra 
        UNION 
        SELECT iduser2
        FROM raikitra
        UNION
        SELECT idUser
        FROM Indisponible 
        WHERE idIndispo=idCurrentUser
    );
END; $$;


ALTER FUNCTION public.get_users_disponible(idcurrentuser character varying) OWNER TO postgres;

--
-- Name: getseqannexe(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqannexe() RETURNS integer
    LANGUAGE plpgsql
    AS $$
    declare annexe integer;
BEGIN
    SELECT nextval('seq_annexe') INTO annexe;
    RETURN annexe;
END;
$$;


ALTER FUNCTION public.getseqannexe() OWNER TO postgres;

--
-- Name: getseqcritere(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqcritere() RETURNS integer
    LANGUAGE plpgsql
    AS $$
    declare critere integer;
BEGIN
    SELECT nextval('seq_critere') INTO critere;
    RETURN critere;
END;
$$;


ALTER FUNCTION public.getseqcritere() OWNER TO postgres;

--
-- Name: getseqindisponible(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqindisponible() RETURNS integer
    LANGUAGE plpgsql
    AS $$
    declare indisponible integer;
BEGIN
    SELECT nextval('seq_indisponible') INTO indisponible;
    RETURN indisponible;
END;
$$;


ALTER FUNCTION public.getseqindisponible() OWNER TO postgres;

--
-- Name: getseqinformation(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqinformation() RETURNS integer
    LANGUAGE plpgsql
    AS $$
    declare information integer;
BEGIN
    SELECT nextval('seq_information') INTO information;
    RETURN information;
END;
$$;


ALTER FUNCTION public.getseqinformation() OWNER TO postgres;

--
-- Name: getseqintervalle(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqintervalle() RETURNS integer
    LANGUAGE plpgsql
    AS $$
    declare intervalle integer;
BEGIN
    SELECT nextval('seq_intervalle') INTO intervalle;
    RETURN intervalle;
END;
$$;


ALTER FUNCTION public.getseqintervalle() OWNER TO postgres;

--
-- Name: getseqmatch(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqmatch() RETURNS integer
    LANGUAGE plpgsql
    AS $$
    declare match integer;
BEGIN
    SELECT nextval('seq_match') INTO match;
    RETURN match;
END;
$$;


ALTER FUNCTION public.getseqmatch() OWNER TO postgres;

--
-- Name: getseqprecision(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqprecision() RETURNS integer
    LANGUAGE plpgsql
    AS $$
    declare precision integer;
BEGIN
    SELECT nextval('seq_precision') INTO precision;
    RETURN precision;
END;
$$;


ALTER FUNCTION public.getseqprecision() OWNER TO postgres;

--
-- Name: getseqraikitra(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getseqraikitra() RETURNS integer
    LANGUAGE plpgsql
    AS $$
    declare raikitra integer;
BEGIN
    SELECT nextval('seq_raikitra') INTO raikitra;
    RETURN raikitra;
END;
$$;


ALTER FUNCTION public.getseqraikitra() OWNER TO postgres;

--
-- Name: getsequser(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getsequser() RETURNS integer
    LANGUAGE plpgsql
    AS $$
    declare users integer;
BEGIN
    SELECT nextval('seq_user') INTO users;
    RETURN users;
END;
$$;


ALTER FUNCTION public.getsequser() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: axes; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.axes (
    idaxe character varying NOT NULL,
    nom character varying
);


ALTER TABLE public.axes OWNER TO postgres;

--
-- Name: criteres; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.criteres (
    idcritere character varying NOT NULL,
    idaxe character varying,
    iduser character varying,
    coefficient integer
);


ALTER TABLE public.criteres OWNER TO postgres;

--
-- Name: indisponible; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.indisponible (
    idindispo character varying,
    iduser character varying
);


ALTER TABLE public.indisponible OWNER TO postgres;

--
-- Name: informations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.informations (
    idinfo character varying NOT NULL,
    idaxe character varying,
    iduser character varying,
    valeur character varying
);


ALTER TABLE public.informations OWNER TO postgres;

--
-- Name: intervalle; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.intervalle (
    idintervalle character varying NOT NULL,
    idaxe character varying,
    intervalle character varying
);


ALTER TABLE public.intervalle OWNER TO postgres;

--
-- Name: match; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.match (
    idmatch character varying NOT NULL,
    iduser character varying,
    idusermatch character varying,
    datematch date
);


ALTER TABLE public.match OWNER TO postgres;

--
-- Name: raikitra; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.raikitra (
    idraikitra character varying NOT NULL,
    iduser1 character varying,
    iduser2 character varying,
    idmatch character varying
);


ALTER TABLE public.raikitra OWNER TO postgres;

--
-- Name: match_dispo; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.match_dispo AS
 SELECT match.idmatch,
    match.iduser,
    match.idusermatch,
    match.datematch
   FROM public.match
  WHERE (NOT ((match.idmatch)::text IN ( SELECT raikitra.idmatch
           FROM public.raikitra)));


ALTER TABLE public.match_dispo OWNER TO postgres;

--
-- Name: precisions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.precisions (
    idprecision character varying NOT NULL,
    idintervalle character varying,
    valeur character varying,
    iduser character varying
);


ALTER TABLE public.precisions OWNER TO postgres;

--
-- Name: raikitra_idraikitra_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.raikitra_idraikitra_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.raikitra_idraikitra_seq OWNER TO postgres;

--
-- Name: raikitra_idraikitra_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.raikitra_idraikitra_seq OWNED BY public.raikitra.idraikitra;


--
-- Name: seq_annexe; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_annexe
    START WITH 10
    INCREMENT BY 10
    MINVALUE 10
    MAXVALUE 200
    CACHE 1
    CYCLE;


ALTER TABLE public.seq_annexe OWNER TO postgres;

--
-- Name: seq_critere; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_critere
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.seq_critere OWNER TO postgres;

--
-- Name: seq_indisponible; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_indisponible
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.seq_indisponible OWNER TO postgres;

--
-- Name: seq_information; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_information
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.seq_information OWNER TO postgres;

--
-- Name: seq_intervalle; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_intervalle
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.seq_intervalle OWNER TO postgres;

--
-- Name: seq_match; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_match
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.seq_match OWNER TO postgres;

--
-- Name: seq_precision; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_precision
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.seq_precision OWNER TO postgres;

--
-- Name: seq_raikitra; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_raikitra
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.seq_raikitra OWNER TO postgres;

--
-- Name: seq_user; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seq_user
    START WITH 21
    INCREMENT BY 1
    MINVALUE 21
    MAXVALUE 9999
    CACHE 1
    CYCLE;


ALTER TABLE public.seq_user OWNER TO postgres;

--
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    iduser character varying NOT NULL,
    nom character varying,
    password character varying,
    genre character varying
);


ALTER TABLE public.users OWNER TO postgres;

--
-- Name: valeur; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.valeur (
    valeur character varying NOT NULL,
    note bigint
);


ALTER TABLE public.valeur OWNER TO postgres;

--
-- Name: raikitra idraikitra; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.raikitra ALTER COLUMN idraikitra SET DEFAULT nextval('public.raikitra_idraikitra_seq'::regclass);


--
-- Data for Name: axes; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.axes (idaxe, nom) FROM stdin;
A020	Fivavahana
A030	Longueur
A040	Salaire par mois
A050	Diplome
A060	Nationalite
A070	Age
\.


--
-- Data for Name: criteres; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.criteres (idcritere, idaxe, iduser, coefficient) FROM stdin;
CRI0183	A020	USR0075	5
CRI0184	A030	USR0075	7
CRI0185	A040	USR0075	4
CRI0186	A050	USR0075	3
CRI0187	A060	USR0075	5
CRI0188	A070	USR0075	6
CRI0189	A020	USR0076	3
CRI0190	A030	USR0076	6
CRI0191	A040	USR0076	5
CRI0192	A050	USR0076	7
CRI0193	A060	USR0076	7
CRI0194	A070	USR0076	6
\.


--
-- Data for Name: indisponible; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.indisponible (idindispo, iduser) FROM stdin;
USR0076	USR0075
\.


--
-- Data for Name: informations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.informations (idinfo, idaxe, iduser, valeur) FROM stdin;
INF0418	A020	USR0075	Oui
INF0419	A030	USR0075	169
INF0420	A040	USR0075	5000
INF0421	A050	USR0075	Bacc+4
INF0422	A060	USR0075	Français
INF0423	A070	USR0075	27
INF0424	A020	USR0076	Oui
INF0425	A030	USR0076	158
INF0426	A040	USR0076	7000
INF0427	A050	USR0076	Bacc+5
INF0428	A060	USR0076	Malagasy
INF0429	A070	USR0076	35
\.


--
-- Data for Name: intervalle; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.intervalle (idintervalle, idaxe, intervalle) FROM stdin;
INT0002	A070	20-30
INT0003	A070	30-40
INT0004	A070	40-50
INT0005	A070	50-60
INT0011	A060	Malagasy
INT0012	A060	Français
INT0013	A060	Afrique
INT0014	A060	Americain
INT0015	A060	Canada
INT0016	A060	Other
\.


--
-- Data for Name: match; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.match (idmatch, iduser, idusermatch, datematch) FROM stdin;
\.


--
-- Data for Name: precisions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.precisions (idprecision, idintervalle, valeur, iduser) FROM stdin;
PRE0102	INT0011	Moyen	USR0075
PRE0103	INT0012	Souhaite	USR0075
PRE0104	INT0013	Mauvais	USR0075
PRE0105	INT0014	Souhaite	USR0075
PRE0106	INT0015	Passable	USR0075
PRE0107	INT0016	Mauvais	USR0075
PRE0108	INT0002	Moyen	USR0075
PRE0109	INT0003	Souhaite	USR0075
PRE0110	INT0004	Passable	USR0075
PRE0111	INT0005	Mauvais	USR0075
PRE0112	INT0011	Souhaite	USR0076
PRE0113	INT0012	Passable	USR0076
PRE0114	INT0013	Passable	USR0076
PRE0115	INT0014	Souhaite	USR0076
PRE0116	INT0015	Souhaite	USR0076
PRE0117	INT0016	Mauvais	USR0076
PRE0118	INT0002	Souhaite	USR0076
PRE0119	INT0003	Passable	USR0076
PRE0120	INT0004	Passable	USR0076
PRE0121	INT0005	Passable	USR0076
\.


--
-- Data for Name: raikitra; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.raikitra (idraikitra, iduser1, iduser2, idmatch) FROM stdin;
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (iduser, nom, password, genre) FROM stdin;
USR0075	Megane	meg	feminin
USR0076	Tendry	tendry	masculin
\.


--
-- Data for Name: valeur; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.valeur (valeur, note) FROM stdin;
Souhaite	5
Moyen	4
Passable	3
Mauvais	1
\.


--
-- Name: raikitra_idraikitra_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.raikitra_idraikitra_seq', 1, true);


--
-- Name: seq_annexe; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_annexe', 90, true);


--
-- Name: seq_critere; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_critere', 194, true);


--
-- Name: seq_indisponible; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_indisponible', 1, false);


--
-- Name: seq_information; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_information', 429, true);


--
-- Name: seq_intervalle; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_intervalle', 16, true);


--
-- Name: seq_match; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_match', 14, true);


--
-- Name: seq_precision; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_precision', 121, true);


--
-- Name: seq_raikitra; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_raikitra', 12, true);


--
-- Name: seq_user; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seq_user', 76, true);


--
-- Name: axes annexes_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.axes
    ADD CONSTRAINT annexes_pkey PRIMARY KEY (idaxe);


--
-- Name: criteres critere_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.criteres
    ADD CONSTRAINT critere_pkey PRIMARY KEY (idcritere);


--
-- Name: informations informations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.informations
    ADD CONSTRAINT informations_pkey PRIMARY KEY (idinfo);


--
-- Name: intervalle intervalle_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.intervalle
    ADD CONSTRAINT intervalle_pkey PRIMARY KEY (idintervalle);


--
-- Name: match match_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.match
    ADD CONSTRAINT match_pkey PRIMARY KEY (idmatch);


--
-- Name: precisions precisions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.precisions
    ADD CONSTRAINT precisions_pkey PRIMARY KEY (idprecision);


--
-- Name: raikitra raikitra_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.raikitra
    ADD CONSTRAINT raikitra_pkey PRIMARY KEY (idraikitra);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (iduser);


--
-- Name: valeur valeur_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.valeur
    ADD CONSTRAINT valeur_pkey PRIMARY KEY (valeur);


--
-- Name: criteres critere_idannexe_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.criteres
    ADD CONSTRAINT critere_idannexe_fkey FOREIGN KEY (idaxe) REFERENCES public.axes(idaxe);


--
-- Name: criteres critere_iduser_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.criteres
    ADD CONSTRAINT critere_iduser_fkey FOREIGN KEY (iduser) REFERENCES public.users(iduser);


--
-- Name: indisponible indisponible_idindispo_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.indisponible
    ADD CONSTRAINT indisponible_idindispo_fkey FOREIGN KEY (idindispo) REFERENCES public.users(iduser);


--
-- Name: indisponible indisponible_iduser_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.indisponible
    ADD CONSTRAINT indisponible_iduser_fkey FOREIGN KEY (iduser) REFERENCES public.users(iduser);


--
-- Name: informations informations_idannexe_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.informations
    ADD CONSTRAINT informations_idannexe_fkey FOREIGN KEY (idaxe) REFERENCES public.axes(idaxe);


--
-- Name: informations informations_iduser_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.informations
    ADD CONSTRAINT informations_iduser_fkey FOREIGN KEY (iduser) REFERENCES public.users(iduser);


--
-- Name: intervalle intervalle_idaxe_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.intervalle
    ADD CONSTRAINT intervalle_idaxe_fkey FOREIGN KEY (idaxe) REFERENCES public.axes(idaxe);


--
-- Name: match match_iduser_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.match
    ADD CONSTRAINT match_iduser_fkey FOREIGN KEY (iduser) REFERENCES public.users(iduser);


--
-- Name: match match_idusermatch_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.match
    ADD CONSTRAINT match_idusermatch_fkey FOREIGN KEY (idusermatch) REFERENCES public.users(iduser);


--
-- Name: precisions precisions_idintervalle_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.precisions
    ADD CONSTRAINT precisions_idintervalle_fkey FOREIGN KEY (idintervalle) REFERENCES public.intervalle(idintervalle);


--
-- Name: precisions precisions_iduser_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.precisions
    ADD CONSTRAINT precisions_iduser_fkey FOREIGN KEY (iduser) REFERENCES public.users(iduser);


--
-- Name: precisions precisions_valeur_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.precisions
    ADD CONSTRAINT precisions_valeur_fkey FOREIGN KEY (valeur) REFERENCES public.valeur(valeur);


--
-- Name: raikitra raikitra_iduserb_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.raikitra
    ADD CONSTRAINT raikitra_iduserb_fkey FOREIGN KEY (iduser1) REFERENCES public.users(iduser);


--
-- Name: raikitra raikitra_iduserv_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.raikitra
    ADD CONSTRAINT raikitra_iduserv_fkey FOREIGN KEY (iduser2) REFERENCES public.users(iduser);


--
-- PostgreSQL database dump complete
--

