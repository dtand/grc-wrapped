--
-- PostgreSQL database dump
--

\restrict WIqh8ZrAufUUeA8VLB7irAnRJfaWAwxz4Igff1tLyk6KRLSmWII3KuBsvJW1kHO

-- Dumped from database version 15.15 (Homebrew)
-- Dumped by pg_dump version 15.15 (Homebrew)

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

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: athlete_nicknames; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.athlete_nicknames (
    id integer NOT NULL,
    athlete_id integer NOT NULL,
    nickname text NOT NULL
);


--
-- Name: athlete_nicknames_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.athlete_nicknames_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: athlete_nicknames_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.athlete_nicknames_id_seq OWNED BY public.athlete_nicknames.id;


--
-- Name: athletes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.athletes (
    id integer NOT NULL,
    name text NOT NULL,
    gender text,
    active boolean,
    website_url text,
    CONSTRAINT athletes_gender_check CHECK (((gender IS NULL) OR (gender = ANY (ARRAY['M'::text, 'F'::text, 'NB'::text]))))
);


--
-- Name: athletes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.athletes_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: athletes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.athletes_id_seq OWNED BY public.athletes.id;


--
-- Name: emails; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.emails (
    id integer NOT NULL,
    title text,
    body text,
    date timestamp without time zone,
    sender text,
    recipient text
);


--
-- Name: emails_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.emails_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: emails_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.emails_id_seq OWNED BY public.emails.id;


--
-- Name: race_results; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.race_results (
    id integer NOT NULL,
    race_id integer NOT NULL,
    athlete_id integer,
    unknown_athlete_name text,
    "time" text,
    pr_improvement text,
    notes text,
    "position" integer,
    is_pr boolean,
    tags text[],
    flagged boolean DEFAULT false,
    flag_reason text,
    email_id integer,
    date_recorded date,
    is_club_record boolean DEFAULT false NOT NULL
);


--
-- Name: race_results_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.race_results_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: race_results_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.race_results_id_seq OWNED BY public.race_results.id;


--
-- Name: races; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.races (
    id integer NOT NULL,
    name text NOT NULL,
    date date,
    year integer NOT NULL,
    distance text,
    type text,
    notes text,
    email_id integer,
    CONSTRAINT races_type_check CHECK (((type IS NULL) OR (type = ANY (ARRAY['TF'::text, 'RD'::text, 'XC'::text, 'TR'::text, 'UL'::text]))))
);


--
-- Name: races_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.races_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: races_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.races_id_seq OWNED BY public.races.id;


--
-- Name: review_flags; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.review_flags (
    id integer NOT NULL,
    flag_type text NOT NULL,
    entity_type text NOT NULL,
    entity_id integer NOT NULL,
    reason text,
    mentioned_name text,
    matched_athlete_id integer,
    resolved boolean DEFAULT false,
    resolved_by text,
    resolved_at timestamp without time zone,
    email_id integer,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: review_flags_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.review_flags_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: review_flags_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.review_flags_id_seq OWNED BY public.review_flags.id;


--
-- Name: workout_groups; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.workout_groups (
    id integer NOT NULL,
    workout_id integer NOT NULL,
    group_name text NOT NULL,
    description text
);


--
-- Name: workout_groups_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.workout_groups_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: workout_groups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.workout_groups_id_seq OWNED BY public.workout_groups.id;


--
-- Name: workout_segments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.workout_segments (
    id integer NOT NULL,
    workout_group_id integer NOT NULL,
    segment_type text NOT NULL,
    repetitions integer,
    rest text,
    targets text
);


--
-- Name: workout_segments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.workout_segments_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: workout_segments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.workout_segments_id_seq OWNED BY public.workout_segments.id;


--
-- Name: workouts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.workouts (
    id integer NOT NULL,
    date date NOT NULL,
    location text,
    start_time time without time zone,
    coach_notes text,
    email_id integer
);


--
-- Name: workouts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.workouts_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: workouts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.workouts_id_seq OWNED BY public.workouts.id;


--
-- Name: athlete_nicknames id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.athlete_nicknames ALTER COLUMN id SET DEFAULT nextval('public.athlete_nicknames_id_seq'::regclass);


--
-- Name: athletes id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.athletes ALTER COLUMN id SET DEFAULT nextval('public.athletes_id_seq'::regclass);


--
-- Name: emails id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.emails ALTER COLUMN id SET DEFAULT nextval('public.emails_id_seq'::regclass);


--
-- Name: race_results id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.race_results ALTER COLUMN id SET DEFAULT nextval('public.race_results_id_seq'::regclass);


--
-- Name: races id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.races ALTER COLUMN id SET DEFAULT nextval('public.races_id_seq'::regclass);


--
-- Name: review_flags id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.review_flags ALTER COLUMN id SET DEFAULT nextval('public.review_flags_id_seq'::regclass);


--
-- Name: workout_groups id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.workout_groups ALTER COLUMN id SET DEFAULT nextval('public.workout_groups_id_seq'::regclass);


--
-- Name: workout_segments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.workout_segments ALTER COLUMN id SET DEFAULT nextval('public.workout_segments_id_seq'::regclass);


--
-- Name: workouts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.workouts ALTER COLUMN id SET DEFAULT nextval('public.workouts_id_seq'::regclass);


--
-- Data for Name: athlete_nicknames; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.athlete_nicknames (id, athlete_id, nickname) FROM stdin;
1	27	Outlaw
2	32	JLP
\.


--
-- Data for Name: athletes; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.athletes (id, name, gender, active, website_url) FROM stdin;
1	Aidan McCaffrey	M	t	https://www.grcrunning.com/aidan-mccaffrey/
2	Alex Roth	M	t	https://www.grcrunning.com/alex-roth/
3	Billy Looney	M	t	https://www.grcrunning.com/billy-looney/
5	Brian Rich	M	t	https://www.grcrunning.com/brian-rich/
6	Cameron Miller	M	t	https://www.grcrunning.com/cameron-miller/
7	Campbell Ross	M	t	https://www.grcrunning.com/campbell-ross/
8	Charlie Ban	M	t	https://www.grcrunning.com/charlie-ban/
9	Chase Osbourne	M	t	https://www.grcrunning.com/chase-osbourne/
10	Chris Bain	M	t	https://www.grcrunning.com/chris-bain/
11	Clint McKelvey	M	t	https://www.grcrunning.com/clint-mckelvey/
12	Connor Rockett	M	t	https://www.grcrunning.com/connor-rockett/
13	Connor Wooding	M	t	https://www.grcrunning.com/connor-wooding/
14	Damian Hackett	M	t	https://www.grcrunning.com/damian-hackett/
15	Daniel Anderson	M	t	https://www.grcrunning.com/daniel-anderson/
16	Daniel Ferrante	M	t	https://www.grcrunning.com/daniel-ferrante/
17	Dave Wertz	M	t	https://www.grcrunning.com/dave-wertz/
18	Dickson Mercer	M	t	https://www.grcrunning.com/dickson-mercer/
19	Dylan Hernandez	M	t	https://www.grcrunning.com/dylan-hernandez/
20	Evan Addison	M	t	https://www.grcrunning.com/evan-addison/
21	Graham Strzelecki	M	t	https://www.grcrunning.com/graham-strzelecki/
22	Ian Denis	M	t	https://www.grcrunning.com/ian-denis/
23	Ian Horsburgh	M	t	https://www.grcrunning.com/ian-horsburgh/
24	Jack Whetstone	M	t	https://www.grcrunning.com/jack-whetstone/
25	Jackson Krieg	M	t	https://www.grcrunning.com/jackson-krieg/
26	Jason Putnam	M	t	https://www.grcrunning.com/jason-putnam/
27	Jerry Greenlaw	M	t	https://www.grcrunning.com/jerry-greenlaw/
28	Jim Heilman	M	t	https://www.grcrunning.com/jim-heilman/
29	Joe LoRusso	M	t	https://www.grcrunning.com/joe-lorusso/
30	John Mascioli	M	t	https://www.grcrunning.com/john-mascioli/
31	John McGowan	M	t	https://www.grcrunning.com/john-mcgowan/
32	John-Louis Pane	M	t	https://www.grcrunning.com/john-louis-pane/
33	Jordan Psaltakis	M	t	https://www.grcrunning.com/jordan-psaltakis/
34	Keith Carlson	M	t	https://www.grcrunning.com/keith-carlson/
35	Kendall Ward	M	t	https://www.grcrunning.com/kendall-ward/
36	Kevin Cory	M	t	https://www.grcrunning.com/kevin-cory/
37	Marcelo Jauregui-Volpe	M	t	https://www.grcrunning.com/marcelo-juaregui-volpe/
38	Mark Hopely	M	t	https://www.grcrunning.com/mark-hopely/
39	Matt Taddeo	M	t	https://www.grcrunning.com/matt-taddeo/
40	Mitch Welter	M	t	https://www.grcrunning.com/mitch-welter/
41	Neil Saddler	M	t	https://www.grcrunning.com/neil-saddler/
42	Patrick Hanley	M	t	https://www.grcrunning.com/patrick-hanley/
43	Rich Wilson	M	t	https://www.grcrunning.com/rich-wilson/
44	Rob Brook	M	t	https://www.grcrunning.com/rob-brook/
45	Rob Mirabello	M	t	https://www.grcrunning.com/rob-mirabello/
46	Ryan Witters	M	t	https://www.grcrunning.com/ryan-witters/
47	Sam Angevine	M	t	https://www.grcrunning.com/sam-angevine/
48	Sean O'Leary	M	t	https://www.grcrunning.com/sean-oleary/
49	Seth Slavin	M	t	https://www.grcrunning.com/seth-slavin/
50	Stuart Russell	M	t	https://www.grcrunning.com/stuart-russell/
51	Terry Tossman	M	t	https://www.grcrunning.com/terry-tossman/
53	Tom Slattery	M	t	https://www.grcrunning.com/tom-slattery/
54	Trever Reed	M	t	https://www.grcrunning.com/trever-reed/
55	Tyler French	M	t	https://www.grcrunning.com/tyler-french/
56	Will Baginski	M	t	https://www.grcrunning.com/will-baginski/
57	Yonel Admasu	M	t	https://www.grcrunning.com/yonel-admasu/
58	Zach Herriott	M	t	https://www.grcrunning.com/zach-herriott/
59	Zack Holden	M	t	https://www.grcrunning.com/zack-holden/
60	Alahna Sabbakhan	F	t	https://www.grcrunning.com/alahna-sabbakhan/
61	Alex Orr	F	t	https://www.grcrunning.com/alex-orr/
62	Ana Keene	F	t	https://www.grcrunning.com/ana-keene/
63	Autumn Sands	F	t	https://www.grcrunning.com/autumn-sands/
64	Belaynesh Tsegaye	F	t	https://www.grcrunning.com/belaynesh-tsegaye/
65	Caroline Rusinski	F	t	https://www.grcrunning.com/caroline-rusinski/
66	Eda Herzog-Vitto	F	t	https://www.grcrunning.com/eda-herzog-vitto/
67	Emily Konkus	F	t	https://www.grcrunning.com/emily-konkus/
68	Erin Foshee	F	t	https://www.grcrunning.com/erin-foshee/
69	Erin Melly	F	t	https://www.grcrunning.com/erin-melly/
70	Frankie Brillante	F	t	https://www.grcrunning.com/frankie-brillante/
71	Franny Kabana	F	t	https://www.grcrunning.com/franny-kabana/
72	Gabi Richichi	F	t	https://www.grcrunning.com/gabi-richichi/
73	Gina McNamara	F	t	https://www.grcrunning.com/gina-mcnamara/
74	Gwen Parks	F	t	https://www.grcrunning.com/gwen-parks/
75	Isolde McManus	F	t	https://www.grcrunning.com/isolde-mcmanus/
76	Jackie Kasal	F	t	https://www.grcrunning.com/jackie-kasal/
77	Jaren Rubio	F	t	https://www.grcrunning.com/jaren-rubio/
78	Jesse Carlin	F	t	https://www.grcrunning.com/jesse-carlin/
79	Kerry Allen	F	t	https://www.grcrunning.com/kerry-allen/
80	Lauren Cerda	F	t	https://www.grcrunning.com/lauren-cerda/
81	Linnaea Kavulich	F	t	https://www.grcrunning.com/linnaea-kavulich/
82	Maura Carroll	F	t	https://www.grcrunning.com/maura-carroll/
83	Mckenna Brownell	F	t	https://www.grcrunning.com/mckenna-brownell/
84	Morgan Lee	F	t	https://www.grcrunning.com/morgan-lee/
85	Page Lester	F	t	https://www.grcrunning.com/page-lester/
86	Sarah Jonathan	F	t	https://www.grcrunning.com/sarah-jonathan/
52	Tom Harrison	M	f	https://www.grcrunning.com/tom-harrison/
87	Sydney Leiher	F	t	https://www.grcrunning.com/sydney-leiher/
88	Whitney Heavner	F	t	https://www.grcrunning.com/whitney-heavner/
89	Aaryn Edge	NB	t	https://www.grcrunning.com/aaryn-edge/
107	Derek	\N	t	
105	Grace Hadley	\N	f	
109	Grace	\N	t	
4	Brian Cave	M	f	https://www.grcrunning.com/brian-cave/
91	Elena	F	f	
90	Zach Matthews	M	f	
93	Sara Stephenson	F	f	
95	Tessa	F	f	
96	Kelly	F	f	
97	Chloe	F	f	
98	June Mwaniki	F	f	
100	Cleo	F	f	
101	Ben	M	f	
103	Maura Linde	F	f	
102	Sara S	F	f	
106	June	F	f	
\.


--
-- Data for Name: emails; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.emails (id, title, body, date, sender, recipient) FROM stdin;
1	wednesday workout, january 15, at bcc	ADMINISTRATIVE\r\n\r\nThanks to everyone who made it to the meeting on Saturday. The amount of talent we had in the room was truly amazing. We had a great year in 2024, and I'm excited to see what we can do for an encore in 2025!\r\n\r\nTo recap, I made three points that I hope you will all take to heart. 1) Come to practice! It helps everyone when we have full attendance. 2) Send me your weekly training reports. I only know what you tell me about your training, and I can't give you helpful input if I'm not aware of what you're up to. 3) I really want to prioritize Clubs. If we can mobilize our full complement of athletes we will have the opportunity to do something truly special. As you all know Clubs will be on January 10 in Tallahassee, in conjunction with World XC. The opportunity to watch Worlds and compete the next day is not something that comes along too often. And the later date will allow everyone who is running an early fall marathon plenty of time to recover and be ready to roll. If you are capable of making the A team I implore you to make the commitment now to be part of our delegation.\r\n\r\nOur friends at District Performance Physio provide all of our athletes one free appointment per year. Now that it's 2025 the clock has reset, and everyone can claim their appointment. I encourage all of you to avail yourself of this benefit. I can make the introduction to get you started.\r\n\r\nRegistration for the Catholic indoor meet, which is on Saturday at PG County, is still open. If you want to run and you didn't receive confirmation from me today that you're entered I need to hear from you right away.\r\n\r\nWORKOUT\r\n\r\nWe'll roll at 6:45 at BCC so meet for the warmup at 6:00. There has been some melting on the track but it's still not clear so we're stuck on the roads again.\r\n\r\nThe road loop we used on Saturday seems like a winner. It's about 1200 and it has a challenging hill. Those who are in the base building phase can do something on the longer side. We'll firm up the plan on Wednesday.\r\n\r\nWe'll keep it short for those who are racing at Catholic.\r\n\r\nThose who are running Houston may want to stay close to home, as it may be more beneficial to do your very light workout on flatter terrain.\r\n\r\nGive me a shout to discuss a plan that works for you.\r\n\r\nJerry\r\n\r\n\r\n-- \r\nYou received this message because you are subscribed to the Google Groups "Georgetown Running Club Men" group.\r\nTo unsubscribe from this group and stop receiving emails from it, send an email to GRCmen+unsubscribe@googlegroups.com.\r\nTo view this discussion visit https://groups.google.com/d/msgid/GRCmen/LV8P221MB1348A0D7FF7F501957DE62319D182%40LV8P221MB1348.NAMP221.PROD.OUTLOOK.COM.\r\n	2025-01-14 02:47:43	coach.jerry@live.com	grcwomen@googlegroups.com
2	wednesday workout, january 22, at bcc	RACES\r\n\r\nCongratulations to Zack Holden for his incredible 2:14:49 at the Houston Marathon! There are a lot of statistics to go along with that run—Zack was eighteenth place in an international caliber field and fifth American, it was a PR by almost two minutes, and it breaks the club record that stood for 15 years. But the numbers, impressive though they are, only tell a portion of the story. What stands out most for me is that Zack has set increasingly ambitious goals for himself, and he has achieved each one of them, and in a way that he made it look easy. Going into Houston the goal was to break 2:15. When we established that goal we expected near perfect conditions, which are the norm in Houston, and plenty of guys to run with. Neither of those expectations panned out-there were strong winds and Zack led an all GRC pack of himself and Clint for most of the race-yet Zack executed his plan perfectly. It's one thing to be fit to hit a target, but it's another thing entirely to actually do it, particularly in sub-optimal conditions, and Zack has done it every time. Zack's training put him in a position to excel, and he had the confidence and poise to make it a reality. I'm not going to make predictions about where Zack's talent can take him other than to say he can, and will, go faster. I'm debating who should play me in the inevitable Disney movie about Zack's inspirational rise from a lowly collegiate club runner to a universally acclaimed marathoner, music critic, and fashion icon, but I'm leaning towards Brad Pitt. You have to admit the resemblance is striking. I'm open to any and all suggestions about who should play Zack. There's an executive producer credit for the winning answer!\r\n\r\nWe had several other big performances in Houston. Clint ran an outstanding 2:15:30, which is a PR of more than a minute, and puts him third on the GRC all-time list. Clint was nineteenth place, and sixth American. Clint rolled with Zack for about 23 miles, and while it started to go in the wrong direction from there he held on for a superb result. Clint has much more in the tank, and he'll be gunning for Zack the next time out!\r\n\r\nAlso in the full, Outlaw ran 2:26:25, which is the third best time of his long career. Outlaw was in PR shape, and while he struggled a bit in the wind it was unquestionably an excellent effort, after an excellent training cycle. The same is true for Dylan, who ran 2:26:53. Dylan had the misfortune of running more than 20 miles solo, and without help in the wind he had no chance to meet his ambitious goal. But again, it was an excellent effort after a stellar training cycle. Zach Matthews ran a big PR of 2:29:15. Zach is in the second year of his medical residency, and there were many weeks where he ran 80 miles and worked 80+ hours in the hospital. Zach reports that he didn't feel great right from the start, but as put it, "An unanticipated benefit of training on little time and rest is that you never feel that great during workouts or long runs, so the territory wasn't unfamiliar." Zach was determined to meet his goal of breaking 2:30, and working 12+ hour shifts six days a week was not going to stand in his way. Rob ran 2:29:39 and worked effectively with Zach for most of the race. That was a big step in the right direction for Rob, and he'll get back in the habit of running PRs in 2025. Patrick had a rough marathon debut, finishing in 2:41:47. That was nowhere close to indicative of Pat's ability. A series of injuries and illnesses in the buildup left him well short of full fitness, but he managed to cross the finish line upright. If that ordeal doesn't scare him away from the marathon nothing will!\r\n\r\nIn the half in Houston, Jack ran an enormous PR of 1:05:23, which puts him sixth on the GRC all-time list. That was a huge breakthrough for Jack, who had yet to translate his excellent track times to the roads. Indeed, Jack's 10 mile split of 49:42 was a PR by 48 seconds, and he kept rolling from there. As proof that running fast pays off, with this performance Jack went from semi-elite status for his marathon debut at Grandmas to an all-expenses paid weekend in Duluth. Also in the half, Elena ran a big PR of 1:10:56. Clearly Elena's years of training with GRC are the gift that keeps on giving!\r\n\r\nThe level of competition for our track crew was a tad lower than in Houston but they made the most of it. At the Cardinal Classic at the PG County Sportsplex Caroline got the win in the 3000 in a solo 10:17.98. And I mean solo—Caroline took the lead at 300 meters and she was on her own from there. Leading virtually every step of a race on a slow track is not a formula for a fast time, and with some competition the next time out Caroline will show what she can do. In the mile, Emily K was hoping to sit and kick but when the leader ran the first 200 in 42 she reluctantly took the lead. Emily pulled the pack along until 1400, and after doing all of the work she didn't have an extra gear to respond when one of her competitors made a move. Emily finished in a solid 5:08.95, and she will run much, much faster this season. Lauren Cerda made her GRC debut, running a strong 5:13.85. Cerda has done only a handful of workouts this season, and there's much more in the tank.\r\n\r\nOn the men's side, Joe got the win in the mile in 4:20.43. Joe is philosophically opposed to taking the lead with more than 200 to go, but when the pace started to slow at 1k Joe cast his principles aside and he was on his own for the last 600. Joe will be ready to lead the charge for our DMR at Millrose. Speaking of the DMR, Chase gives us the legit 400 runner we've been looking for, and he ran 53.08 in his first open 4 in recent memory. That's a strong run on a flat, slow track, and on the fast banked track at the Armory Chase will more than hold his own. Dickson ran 9:21.78 in the 3000, which was a good start to his season that will culminate at the World Masters champs in late March. Daniel F, the third member of our DMR, got the win in both the 800 in 1:58.82 and mile in 4:21.94 at the CNU Captains Invitational, which was even less competitive than the Cardinal Classic, on an equally slow track. There's much more coming from that young fella.\r\n\r\nSydney ran the Bermuda Triangle Challenge in, as the name suggests, Bermuda. While a trip to Bermuda in the dead of winter is not hardship duty, the event itself is demanding because it consists of three races in three days. In the mile on Friday, Sydney was fifth in 5:09 on a course with two hairpin turns, in gusty wind. On Saturday she was third in the 10k in a tempo effort of 37:04 on a very hilly course. Sydney closed out the weekend by finishing fourth in the half marathon in a controlled 1:26, on another hilly course. That was a solid three days of work!\r\n\r\nADMINISTRATIVE\r\n\r\nPlease carefully read Dickson's message from this afternoon. Dix gave a great description of the benefits of training together as a team, and he also includes important information about our new fundraising drive, Tracksmith discount and gear, and other topics of interest to us all. One correction—Dylan won the Lauren Woodall Roady award, and Whitney won the Nina Brekelmans award.\r\n\r\nTrack crew, it is imperative that you communicate with me about meets that you want to run well in advance\r\n\r\nWORKOUT\r\n\r\nWe'll roll at 6:45 at BCC so meet for the warmup at 6:00. The good news is that the streets in the neighborhood are clear; the bad news is the track is not. Thus, we're stuck on the road loop again.\r\n\r\nWe'll roll on the big loop and do something volume oriented. Come out for the big reveal!\r\n\r\nSee you Wednesday at BCC.\r\n\r\nJerry\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n-- \r\nYou received this message because you are subscribed to the Google Groups "Georgetown Running Club Men" group.\r\nTo unsubscribe from this group and stop receiving emails from it, send an email to GRCmen+unsubscribe@googlegroups.com.\r\nTo view this discussion visit https://groups.google.com/d/msgid/GRCmen/LV8P221MB1348B827193172AED71A552B9DE62%40LV8P221MB1348.NAMP221.PROD.OUTLOOK.COM.\r\n	2025-01-21 02:18:51	coach.jerry@live.com	grcmen@googlegroups.com
3	wednesday workout, january 29, at bcc	RACES\r\n\r\nOur Millrose DMR crew was in action this weekend in preparation for our inevitable victory. Evan made a triumphant GRC track debut by breaking the club record in the 3000 with his excellent 8:07.77 at Penn 10 Team Elite. This was the first but surely will not be the last club record for Evan this season. Once he gets race sharp the sky is the limit.\r\nAt the Liberty Tolsma Invitational Daniel F did double duty by running 4:15.78 in the mile and coming back to run 1:56.87 in the 800, both of which are indoor PRs. Joe ran 4:18.43 in the mile, which was a strong performance given that he was not at full strength due to illness. Chase is getting his legs back under him and ran a strong 52.85 in the 400.\r\n\r\nIn his first race since the Olympic Trials, Tom was sixteenth place at the Armed Forces XC Championships in San Antonio. Tom's training has been limited by his personal and professional responsibilities, and he was pleased with the effort.\r\n\r\nFUNDRAISING CAMPAIGN\r\n\r\nAs noted in Dickson's recent Board update, we are getting ready to send out our first GRC fundraising letter (you can preview the message here<https://docs.google.com/document/d/1FRvtOvE09lZsaTWIPpcZ7V3PcwbkjoXtLee66HiGafQ/edit?tab=t.0>.) The easiest way to participate is to help us strengthen our mailing list for this message. Think of family members, friends or people in your network who might like to donate to GRC, and add them to our list here<https://docs.google.com/spreadsheets/d/1LHy7l2C3yel6QvaGgjLRCxCNltDUoErE5OUxi-pMuJQ/edit?gid=0#gid=0>. We will include these contacts in our distribution to save you the work of having to send out a message! Alternatively, we will copy the club email handles on the distribution, so members will also have the option to forward our message. Increasing our budget is an important priority for the club that will benefit everyone, and everyone should take part in making this a success! Please reach out to Dickson if you have any questions.\r\n\r\nADMINISTRATIVE\r\n\r\nTrack gang, let me know if you want to run BU Valentine. The entry fees are quite high so I want to confirm who wants in before I pull the trigger.\r\n\r\nThe USATF road 5k champs are May 3 in Indianapolis. It will be extremely competitive because it is the selection race for the World Roads team, and there is a large prize purse. We want to have a GRC presence at as many USATF championships as possible, so I encourage our A level athletes to consider competing. Let me know if you want to give it a shot.\r\n\r\nLight Horse TC is hosting two late season track meets at George Mason, on May 24 and June 14. The events at the May meet are mile, 5000, and 10,000, and they expect highly competitive fields in the mile and 5000. The events at the June meet are 800, mile, steeple, and 5000.\r\n\r\nWORKOUT\r\n\r\nWe'll roll at 6:45 at BCC so meet for the warmup at 6:00. Waldo and I just did a recon and the track looks terrible. There has been an alarming lack of melting, and while I'm hopeful we can use it Wednesday I'm not entirely confident that we'll be able to do so.\r\n\r\nI have a workout written for the track but I'm going to hold off on publishing it for now.\r\n\r\nWorst case scenario we can get back on the road loop.\r\n\r\nI'll send a status report by mid-day Wednesday.\r\n\r\nEither way, I'll see you at BCC.\r\n\r\nJerry\r\n\r\n\r\n\r\n\r\n\r\n\r\n-- \r\nYou received this message because you are subscribed to the Google Groups "Georgetown Running Club Men" group.\r\nTo unsubscribe from this group and stop receiving emails from it, send an email to GRCmen+unsubscribe@googlegroups.com.\r\nTo view this discussion visit https://groups.google.com/d/msgid/GRCmen/LV8P221MB13482A4AEE9F39D5183EA9979DEF2%40LV8P221MB1348.NAMP221.PROD.OUTLOOK.COM.\r\n	2025-01-28 02:46:41	coach.jerry@live.com	grcmen@googlegroups.com
4	wednesday workout, february 5, at bcc	RACES\r\n\r\nChase got the win in the 800 at the Marlin Invitational in Virginia Beach in 1:58.63. Chase was on his own the last 300. That is a strong performance essentially solo on a flat track.\r\n\r\nWhitney won the Lake Patuxent River Trail half marathon in 1:40:22. The footing was not wonderful as a good portion of the loop was iced over, so that was a very nice run.\r\n\r\nADMINISTRATIVE\r\n\r\nRegister for our Cherry Blossom team!\r\n\r\nThis is the last call for the USATF 25K which is on May 10 in Grand Rapids, MI. The current roster is Zach Herriott, Terry, and Dylan. If you want to be included in our entry request I need to hear from you by Wednesday.\r\n\r\nI also need to hear from you if you want to run the USATF road 5K in Indianapolis, which is on May 3. The current roster is Witty.\r\n\r\nTrack gang, if you want to run BU Valentine or any other meet next week give me a shout right away.\r\n\r\nWORKOUT\r\n\r\nWe'll roll at 6:45 at BCC so meet for the warmup at 6:00.\r\n\r\nThe plan for the men (other than the Millrose crew) is 5 x 1600, 4 x 400. We'll take 2:00 rest after the 16s, except that we'll take 3:00 rest before we hit the 4s. We'll take 45 seconds rest after the 4s.\r\n\r\nTargets for group 1 are 75, 74, 73, 72, 71 on the 16s, and 2 @ 68, 2 @ 66 on the 4s.\r\n\r\nTargets for group 2 are 78, 77, 76, 75, 74 on the 16s, and 2 @ 71, 2 @ 69 on the 4s.\r\n\r\nTargets for group 3 are 81, 80, 79, 78, 77 on the 16s, and 2 @ 74, 2 @ 72 on the 4s.\r\n\r\nI'll send the women's workout separately.\r\n\r\nSee you Wednesday at BCC.\r\n\r\nJerry\r\n\r\n\r\n-- \r\nYou received this message because you are subscribed to the Google Groups "Georgetown Running Club Men" group.\r\nTo unsubscribe from this group and stop receiving emails from it, send an email to GRCmen+unsubscribe@googlegroups.com.\r\nTo view this discussion visit https://groups.google.com/d/msgid/GRCmen/LV8P221MB13482AAF889DC46B5132A8219DF42%40LV8P221MB1348.NAMP221.PROD.OUTLOOK.COM.\r\n	2025-02-04 02:37:24	coach.jerry@live.com	grcmen@googlegroups.com
5	wednesday workout, february 12, at bcc	RACES\r\n\r\nOur men's DMR placed third at the Millrose Games in 10:01.76, which is the fourth fastest time in GRC history. The men have competed at Millrose every year since 2018, and we've been on the podium every time. I take great pride in that streak, and the guys kept it going this year in a very competitive field. Joe led us off in 3:06.83 for 1200, followed by Chase in 52.44 for 400, Daniel F in 1:56.84 for 800, and Evan in 4:05.66 on the anchor. Evan's 1600 was the fastest of the day by almost 3 seconds, and the fastest in GRC history by 4 seconds. We're always at a deficit on the short legs, and lack of track access in January was particularly problematic for Chase and Daniel, both of whom made their Millrose debut. With this experience under their belt and Evan on the anchor we're not going to be denied next year!\r\n\r\nCaroline ran 17:18.1 for 5000 at the BU Scarlett and White Invitational. Caroline is fit to break 17, but the race did not set up well for her, and after 1400 she was stuck between packs and was solo from there. Caroline will have several opportunities to show what she can do, and we'll see some big results from her this season.\r\n\r\nADMINISTRATIVE\r\n\r\nIf you're running Cherry Blossom and haven't joined our team please do so right away.\r\n\r\nTrack gang, it's imperative that you communicate with me about meets you want to run well ahead of time. And by communicate I mean by email. I will forget anything you tell me at practice by the time I get home.\r\n\r\nWORKOUT\r\n\r\nIt looks like winter is going to bite us in the rear again. But we can fight back by shoveling the track at BCC as soon as it stops snowing. As our experience in January bitterly proved, snow and ice on the home straight takes a long time to melt. If we can get the home straight clear we'll have a fighting chance of being back on the track by Saturday. To that end, I need volunteers to come out Wednesday morning. I have four shovels, and if we go at it in shifts we can get the job done. Let me know if you can make it and we'll figure out the details.\r\n\r\nWe might be able to get in a workout on the road loop on Wednesday night. I'll do a recon on Wednesday afternoon and send around an update.\r\n\r\nIn the interim, please err on the side of caution. Stay safe!\r\n\r\nJerry\r\n\r\n\r\n\r\n\r\n-- \r\nYou received this message because you are subscribed to the Google Groups "Georgetown Running Club Men" group.\r\nTo unsubscribe from this group and stop receiving emails from it, send an email to GRCmen+unsubscribe@googlegroups.com.\r\nTo view this discussion visit https://groups.google.com/d/msgid/GRCmen/LV8P221MB1348526289AB8383269CD9F39DFD2%40LV8P221MB1348.NAMP221.PROD.OUTLOOK.COM.\r\n	2025-02-11 02:50:42	coach.jerry@live.com	grcmen@googlegroups.com
6	tuesday workout, february 18, at bcc	RACES\r\n\r\nChase continued his prolific indoor season by running 1:56.53 in the 800 at BU Valentine. That was a nice step forward for Chase, and we'll see much more from him as he continues to race his way into shape.\r\n\r\nADMINISTRATIVE\r\n\r\nTrack crew, it's time to start putting together a schedule for outdoor. Give me a shout to discuss a plan that works for you.\r\n\r\nI have it on good authority that the Trials of Miles meet in NYC will be on May 3.\r\n\r\nRoad crew, let me know if you want to be included in our entry request for Broad Street.\r\n\r\nIt's not too late to grab a comp for the Tim Kennard 10 mile/5k, which is on March 2 in Salisbury, MD. If you're looking for an early season road race this could be a good choice. It's mostly flat, and there's a nice prize purse that will likely be easy pickings.\r\n\r\nWORKOUT\r\n\r\nWe're moving the workout to TUESDAY to avoid the impending snow. We'll roll at 6:45 so meet for the warmup at 6:00.\r\n\r\nThe plan for the men is 5 x 1200, 8 x 600. We'll take 2:00 after the 12s except that we'll take 3:00 after the last one. We'll break the 6s in to 2 sets of 4, and we'll take 1:30 rest in the set, and 3:00 between sets.\r\n\r\nTargets for group 1 are 73, 72, 71, 70, 69 on the 12s. Targets for the 6s are 67 on set 1 and 65 on set 2.\r\n\r\nTargets for group 2 are 76, 75, 74, 73, 72 on the 12s. Targets for the 6s are 70 on set 1 and 68 on set 2.\r\n\r\nTargets for group 3 are 79, 78, 77, 76, 75 on the 12s. Targets for the 6s are 73 on set 1 and 71 on set 2.\r\n\r\nAs always we can modify this in any number of ways. Give me a shout to discuss a plan that works for you.\r\n\r\nI'll send the women's workout separately.\r\n\r\nI will have to dip out right after we finish so that I'm home in time for the USATF zoom meeting about the Trials marathon, so if you want to chat with me before practice is the right time. To the extent that the meeting generates any useful information I'll fill you in.\r\n\r\nSee you at BCC.\r\n\r\nJerry\r\n\r\n\r\n-- \r\nYou received this message because you are subscribed to the Google Groups "Georgetown Running Club Men" group.\r\nTo unsubscribe from this group and stop receiving emails from it, send an email to GRCmen+unsubscribe@googlegroups.com.\r\nTo view this discussion visit https://groups.google.com/d/msgid/GRCmen/LV8P221MB13488090F2A6F78BD3A5DD469DFA2%40LV8P221MB1348.NAMP221.PROD.OUTLOOK.COM.\r\n	2025-02-18 01:32:00	coach.jerry@live.com	grcwomen@googlegroups.com
7	wednesday workout, february 26, at bcc	RACES\r\n\r\nIt was a huge day at the Greenville, SC Half Marathon. Seth had a massive breakthrough by running 1:05:21, which was a PR by two minutes and puts him sixth on the GRC all-time list. That was the best race of Seth's career, by far, but it was not a surprise. Seth was in sub 2:20 shape for Chicago but a stomach problem got the better of him. In Greenville he avoided the proverbial bad shrimp, and it was off to the races!\r\n\r\nSara Stephenson also had a humongous breakthrough in Greenville, running an outstanding 1:16:43 in her half debut. Sara is a huge talent and she clearly has an aptitude for the longer road distances. We'll see much more of what she can do this spring.\r\n\r\nAt Navy Select, Morgan got her season started on the right foot by getting the win in the mile in 4:59.02, which is fifth on the all-time list. Morgan took the lead at around 850 and was solo from there, winning by over four seconds. Daniel F ran 4:14.64, which is an indoor PR and puts him seventh on the list. Daniel is improving every time out, and he'll be ready for a big outdoor season. Caroline was third in the 3000 in 10:07.89. Caroline ran pretty much even splits but unfortunately got stuck in no-man's land again. Caroline is ready for a big breakthrough, and she's got plenty of chances in the coming weeks. Joe had a tough day at the office, running 8:43.25. Joe will regroup and be ready to roll next time out.\r\n\r\nOur Boston crew was in action at the RRCA 10 Mile, where the brutally hilly course makes for slow times but is good Boston prep. Marcelo led the way in fourth in 53:18, followed by Sean in fifth in 53:25, Jim in tenth in 54:11, Outlaw in 54:19, JLP in 54:44, and Trever in 55:36. In other 10 mile action, Charlie ran 57:44 on a rolling course at the Spring Thaw 10 in Pittsburgh, and he was pleased with the effort.\r\n\r\nADMINISTRATIVE\r\n\r\nLet me know if you want to be included in our entry request for Broad Street. I want to submit our request soon so please don't be shy.\r\n\r\nThere's still time to sign up for the Philly Runner indoor meet at Penn on March 8. We have a good crew heading up there and the facility is reportedly first rate.\r\n\r\nThe dreaded start of spring sports in Montgomery County is almost upon us. This week will be our final Wednesday practice at BCC for a couple of months. Please be sure to check the Monday emails for the practice location as we'll be bouncing around for a few weeks.\r\n\r\nWe're fine to stay at BCC on Saturday mornings, but this coming week we need to get an early start. I'll have details in the email on Thursday.\r\n\r\nWhat did you do last week? Offensive and demeaning though that question may be in a certain context, it's always relevant in the running context. To that end, please send me your weekly reports. I probably won't consider failure to do so as your resignation from GRC but why take any chances!\r\n\r\nWORKOUT\r\n\r\nWe'll roll at 6:45 at BCC so meet for the warmup at 6:00.\r\n\r\nThe plan for the men is 3 x 2k, 4 x 1k. We'll take 2:00 rest on all of it except that we'll take 3:00 before we start the 1ks.\r\n\r\nTargets for group 1 are 74, 73, 72 on the 2ks, and 70, 69, 68, 67 on the 1ks.\r\n\r\nTargets for group 2 are 77, 76, 75 on the 2ks, and 73, 72, 71 70 on the 1ks.\r\n\r\nTargets for group 3 are 80, 79, 78 on the 2ks, and 76, 75, 74, 73 on the 1ks.\r\n\r\nWe can modify this in any number of ways. Give me a shout to discuss a plan that works for you.\r\n\r\nI'll send the women's workout separately.\r\n\r\nSee you at BCC.\r\n\r\nJerry\r\n\r\n\r\n\r\n\r\n\r\n-- \r\nYou received this message because you are subscribed to the Google Groups "Georgetown Running Club Men" group.\r\nTo unsubscribe from this group and stop receiving emails from it, send an email to GRCmen+unsubscribe@googlegroups.com.\r\nTo view this discussion visit https://groups.google.com/d/msgid/GRCmen/LV8P221MB134871E94EBA97246FB806739DC32%40LV8P221MB1348.NAMP221.PROD.OUTLOOK.COM.\r\n	2025-02-25 02:42:11	coach.jerry@live.com	grcwomen@googlegroups.com
8	wednesday workout, march 5. on the mall	RACES\r\n\r\nOur crew competed successfully on the national level this weekend. Tessa was 25th at the USATF Half Marathon Championship in Atlanta in 1:14:04 on a hilly course, which is a big PR and is third on the GRC all-time list. Tessa got out hard--her official 5k and 10k splits were 16:56 and 34:22, both of which put her fifth on the GRC list—and hung on for an excellent result. USATF will likely release the standards for the 2028 marathon trials in the next couple of weeks. Whatever the standard is Tessa will hit it, with room to spare.\r\n\r\nBrian was 31st at the Gate River 15k in Jacksonville in a very strong 47:10. The race was not the USATF championship this year but it was more competitive than ever because the field included international athletes, and Brian beat some very good guys. Brian is in great shape, and he's got much more to come this spring.\r\n\r\nIn a slightly less competitive race, Neil got the win at the Tim Kenard 10 mile in Salisbury, MD in a tempo effort of 52:52. Neil led literally every step of the way and won by more than 9 minutes. That was Neil's first race in almost a year due to injury, and it was a very good start.\r\n\r\nADMINISTRATIVE\r\n\r\nWe have received a limited number of comps for Pikes Peak 10k, which is April 27 in Rockville. If you're looking for a fast road 10k this might be the race for you. Give me a shout if you want to stake your claim to one of our entries.\r\n\r\nWhat did you do last week? Part II. This week we mean it. Those who fail to respond might get fired, maybe, or you'll be on the bubble. Or you might not be. We're really not sure. But why risk running afoul of the awesome power of GRC. Send me your weekly training report and your position on the team will be secure, at least for this week.\r\n\r\nWORKOUT\r\n\r\nWe're ON THE MALL on Wednesday for a 6:30 start so meet for the warmup at 5:45. The earlier start will allow us to get in the warmup before dark.\r\n\r\nFor those who have not had the pleasure, we use the inner loop of the mall between 4th and 7th Streets, which is darn close to 800 meters. The meeting spot is on 7th Street, just south of Madison Drive. We're directly across 7th Street from the big white tent. It's easily metro accessible, and there's plenty of parking on the street. You would be well-advised to take metro if that's an option for you as the traffic will be bad thanks to the return to the office policy. There's also a Wizards game, which will make an already bad situation worse. If you get turned around text me at 240 483 8137.\r\n\r\nThe plan for the men is the classic mall 4-3-2-1-1-1 ladder, ie 3200, 2400, 1600, 800, 800, 800. We'll take 2:00 rest on all of it.\r\n\r\nTargets for group 1 are 74 on the 32, 72 on the 24, 70 on the 16, and 68, 67, 66 on the 8s.\r\n\r\nTargets for group 2 are 76 on the 32, 74 on the 24, 72 on the 16, and 70, 69, 68 on the 8s.\r\n\r\nTargets for group 3 are 79 on the 32, 77 on the 24, 75 on the 16, and 73, 72, 71 on the 8s.\r\n\r\nIf you're racing on Saturday you'll probably want to do less than all of this. Give me a shout to discuss a modification that makes sense for you.\r\n\r\nI'll send the women's workout separately.\r\n\r\nSee you ON THE MALL.\r\n\r\nJerry\r\n\r\n\r\n\r\n\r\n\r\n-- \r\nYou received this message because you are subscribed to the Google Groups "Georgetown Running Club Men" group.\r\nTo unsubscribe from this group and stop receiving emails from it, send an email to GRCmen+unsubscribe@googlegroups.com.\r\nTo view this discussion visit https://groups.google.com/d/msgid/GRCmen/LV8P221MB1348D544FFB4CB5096C3CE529DC82%40LV8P221MB1348.NAMP221.PROD.OUTLOOK.COM.\r\n	2025-03-04 02:28:30	coach.jerry@live.com	grcwomen@googlegroups.com
9	wednesday workout, march 12, on the mall	RACES\r\n\r\nOur track crew finished up indoor season/got a jump on outdoor season at the Philly Runner TC Indoor Classic at the Ott Center at Penn. Gina got the win in the 800 in a very controlled 2:09.78. Gina sat on the leader for 600, and when she unleased her ferocious kick--she closed in 31.4--it was all over. Gina had no choice but to win under the watchful eyes of a life size mural of Jesse kicking tail for Penn back in the day. Kelly got the win in the masters mile in a solo 5:17.46. Kelly finally has a credential upon which to hang her hat—PRTC Classic Champion is way more impressive than competing in four Olympic Trials and winning the masters 1500 national championship. In the open mile, Morgan was second in 4:59.8, followed by Emily K in third in 5:03.91, and Cerda in fifth in 5:07.81. Morgan and Emily were on their own almost from the gun, and unreliable pacing (to put it charitably) from the pacer didn't help, but they worked together effectively. Cerda ran a big negative split and closed in an impressive 34.3.\r\n\r\nJason had the performance of the day on the men's side, winning his heat of the 3000 in 8:46.4. Jason's tactics were perfect—he was eleventh at 1600, and from there he began moving up steadily. With 400 to go Jason was fifth, and with 200 to go he took the lead and closed in 30.1, which was the fastest final 200 of the day across all heats, for a decisive victory. Well done, young fella! Joe was fourth in the fast heat in 8:29.04 and closed in 30.6. That was Joe's best performance of the indoor season by far, and he's back on track going into outdoor. Tyler was fifth in a PR of 8:30.54. Tyler pushed the pace in the chase pack for most of the race, and looked very good in his first race since Clubs. Keith was tenth in 8:37.34, which was an encouraging performance given that he has been limited by a balky calf for the the last couple of weeks, so much so that he wasn't sure that he could race at all until Friday. Keith has a clean bill of health, and he'll be ready to roll outdoors. Chase moved up to the mile and ran 4:32.36. Chase will make good use of that strength in the 800 outdoors. In the masters mile Rich ran 4:53.44, which was an impressive performance in his first race on the track since the George W. Bush administration.\r\n\r\nADMINISTRATIVE\r\n\r\nWe have been invited to the Crazy Jerry Run (I couldn't make that up if I tried), otherwise known as the Rainsville Freedom Run 5k/10k in Rainsville, Alabama, which is on June 7. As everyone knows Rainsville is about an hour from Chatanooga, and about 2.5 hours from Nashville. There is a large prize purse—in the 10k it's $1,000-800-600-400-200, and in the 5k it's $600-400-300-200-100. We can get comps, and there are "a limited number" of hotel rooms available. It appears that they will award the rooms on a first-come first-served basis, and if we ask soon we'll probably get them. Based on results from the last three years our A level athletes would have a great chance of cashing in, particularly on the women's side. Let me know if you want to run, and the sooner the better.\r\n\r\nIf you're interested in a road 10k a little closer to home Pikes Peak on April 27 is a good choice. It's a fast course with solid competition. I have the comp code so let me know if you want in.\r\n\r\nTrack gang, I'm waiting on some information that will be pertinent to our schedule. Stand by for more details.\r\n\r\nWORKOUT\r\n\r\nWe're ON THE MALL again for a 6:30 start, so meet for the warmup at 5:45. I'm hopeful that we can get on the track next week but for this week we can enjoy the sunset on the Mall and get most of the workout done before dark.\r\n\r\nThe plan for the men is 3 sets of 2400, 800. We'll take 1:30 rest in the sets and 3:00 rest between sets.\r\n\r\nTargets for group 1 are 73-68 on set 1, 71-67 on set 2, and 69-66 on set 3.\r\n\r\nTargets for group 2 are 75-70 on set 1, 73-69 on set 2, and 71-68 on set 3.\r\n\r\nTargets for group 3 are 78-73 on set 1, 76-72 on set 2, and 74-71 on set 3.\r\n\r\nRNR half crew, you probably want to call it after 2 sets.\r\n\r\nGive me a shout to discuss a plan that works for you.\r\n\r\nI'll send the women's workout separately.\r\n\r\nSee you on the Mall.\r\n\r\nJerry\r\n\r\n\r\n\r\n\r\n\r\n\r\n-- \r\nYou received this message because you are subscribed to the Google Groups "Georgetown Running Club Men" group.\r\nTo unsubscribe from this group and stop receiving emails from it, send an email to GRCmen+unsubscribe@googlegroups.com.\r\nTo view this discussion visit https://groups.google.com/d/msgid/GRCmen/LV8P221MB1348AF39F1978842D48F57619DD12%40LV8P221MB1348.NAMP221.PROD.OUTLOOK.COM.\r\n	2025-03-11 01:55:47	coach.jerry@live.com	grcwomen@googlegroups.com
10	wednesday workout, march 19, at st albans	RACES\r\n\r\nIt was a big day at DC RNR Half. Tessa defended her title, getting the win in 1:15:12. Tessa was still feeling the USATF Half Champs in her legs last week, but that didn't stop her from going out very hard. Tessa paid the price later in the race but she held on for another excellent result. Alex was second in 1:17:53, which was a 90 second PR. To run a big PR on a slow course is a testament to Alex's fitness. Mckenna ran a big PR of 1:18:11, proving definitively that she runs faster when she stays upright. After breaking her ankle at DC Half in September Mckenna missed the rest of the fall, and the fact that she's back in PR shape so quickly is a great sign of big things to come. Chloe ran a massive PR of 1:22:02, which was arguably the best performance of her career. That performance was even more impressive given that Chloe had quite the misadventure getting to the starting line and had no time to warm up. Ana was part of the transportation fiasco with Chloe but it did not deter her from getting in the Boston tuneup she was looking for, running a tempo effort of 1:27:46.\r\n\r\nOn the men's side, Terry finished second in a nice PR of 1:08:26. Terry was in the lead for much of the race, but when a 27:39 10,000 guy tracked him down there wasn't much he could do. Terry's goal race is two months away, and he's right where he wants to be at this stage of his training cycle. Sean had an excellent tuneup for Boston, running 1:10:16, which tied the PR that he set last year at RNR. The 2025 version of Sean is timing his fitness perfectly, and a big marathon PR is coming. Matt also had a strong Boston tuneup in 1:10:21. Matt missed a lot of training time over the winter due to injury, and he's making excellent progress. Kevin Cory made a strong GRC debut, running 1:10:22. Kevin earned a promotion from NOVA, and he's going to be a nice addition to our road crew. Ian ran a solid 1:10:49 as he works his way back to full fitness.\r\n\r\nOutlaw defended his title at the Shamrock Marathon in Virginia Beach, getting the win in 2:27:28. Outlaw hung back for 15 miles, and when he took the lead it was a solo effort to the finish line. For Outlaw to be able to run 2:27:28 only 8 weeks after Houston is impressive indeed. Somehow, he'll be ready to run CB.\r\n\r\nJim was fourth at the Shamrock 5k in Baltimore in a PR of 15:07. It goes without saying that a race in Baltimore was hilly, so that was a really strong performance.\r\n\r\nADMINISTRATIVE\r\n\r\nRoad crew, I have the comp code for Alexandria Half/5k, and Pikes Peak 10k. Let me know if you want to run.\r\n\r\nTrack crew, the roster for Maryland Invite on March 29 is below. If you're not on the list and want to run please let me know asap.\r\nMen: 800-Daniel F; 5000-Keith, Jason, Tyler, Sam, Seth, Campbell, Daniel A, Jim(?)\r\nWomen: 1500-Cerda; 5000-Caroline\r\n\r\nThe bad news is that the Trials of Miles meet at Randalls Island on May 2 will not have a 5000 (though it will have elites heats in the mile). The good news is that Princeton is hosting the Larry Ellis Invite that night. Princeton is a lot easier to get to and the facility is fantastic so it's going to work out fine. Let me know if you want in.\r\n\r\nWORKOUT\r\n\r\nWe're at ST ALBANS for a 6:30 start, so meet for the warmup at 5:45. It's spring break at St Albans so we should have the place to ourselves. Our confidential sources advise that we should enter through the tennis center, and not the main gate. The entrance to the tennis center is a little further down the hill on Garfield Street. There are bathrooms on the way to the track.\r\n\r\nThe plan for the men is 10 x 1k with 2:00 rest. We'll ease into it on the first rep and get rolling on the last rep.\r\n\r\nTargets for group 1 are 72, 2 @ 71, 2 @ 70, 2 @ 69, 2 @ 68, 66.\r\n\r\nTargets for group 2 are 74, 2 @ 73, 2 @ 72, 2 @ 71, 2 @ 70, 68.\r\n\r\nTargets for group 3 are 77, 2 @ 76, 2 @ 75, 2 @ 74, 2 @ 73, 71.\r\n\r\nWe can modify this in any number of ways. Give me a shout to discuss a plan that works for you.\r\n\r\nI'll send the women's workout separately.\r\n\r\nSee you at St Albans.\r\n\r\nJerry\r\n\r\n\r\n\r\n\r\n\r\n\r\n-- \r\nYou received this message because you are subscribed to the Google Groups "Georgetown Running Club Men" group.\r\nTo unsubscribe from this group and stop receiving emails from it, send an email to GRCmen+unsubscribe@googlegroups.com.\r\nTo view this discussion visit https://groups.google.com/d/msgid/GRCmen/LV8P221MB13485F46F4D368E3D07BEC239DDE2%40LV8P221MB1348.NAMP221.PROD.OUTLOOK.COM.\r\n	2025-03-18 01:25:51	coach.jerry@live.com	grcwomen@googlegroups.com
11	wednesday workout, march 26, at st albans	RACES\r\n\r\nSeveral members of our Boston crew got in a solid tuneup at the Project 13.1 Half in Congers, NY. Marcelo ran a big PR of 1:09:26, and after getting out a little too aggressively he was able to regroup and hold on for an excellent result. Trever ran 1:11:40, which is close to his PR, and he ran smart and competed well. JLP ran a tempo effort of 1:13:24, which was very encouraging after he missed some training due to illness.\r\n\r\nGraham is also running Boston, and in a more robust tuneup he finished second in the Terrapin Mountain 50k in 4:31. The course was technical and had 7,000 feet of elevation gain so that was no jog in the park. All of those guys will be ready to roll when the gun goes off in Boston in a month.\r\n\r\nWhitney ran 6:40 at the Heartbreaker 55k Trail race in western North Carolina, in an area that was devastated by Hurricane Helene. The race was extremely meaningful for Whitney because she is from that area, and her goal was to have fun and celebrate the mountains. It was mission accomplished, as Whitney reports that she very much enjoyed the experience.\r\n\r\nCharlie made a triumphant return to the University of Richmond, where he ran 16:09 at the Fred Hardy Invite. Charlie seeded himself at 16:20 and was pleased to run a good bit faster than he expected.\r\n\r\nEvan jumped into the Virgnia Fire Chiefs Foundation 5k in Williamsburg and got the win in 14:51, which is a new course record. Evan has been a little dinged up and this was a nice step in the right direction.\r\n\r\nADMINISTRATIVE\r\n\r\nIn these troubled times we need all the good news we can get, and to that end I'm happy to report that the metro will open at 5:00 on the morning of Cherry Blossom. That should reduce the likelihood of a Chloe/Ana style travel fiasco, and nobody wants a repeat of that!\r\n\r\nTrack gang, the updated roster for Bucknell is below. If you want to join the fun I need to hear from you this week.\r\n\r\nMen: 1500-Joe; 5000-Tyler, Daniel A; 10,000-Keith, Sam, Seth\r\nWomen: 5000-Caroline, June; 10,000-Alex\r\n\r\nRoad crew, let me know if you want to run Alexandria Half or Pikes Peak 10k.\r\n\r\nWORKOUT\r\n\r\nWe'll roll at 6:30 at ST ALBANS so meet for the warmup at 5:45. School is back in session and we want to keep a low profile so we'll muster in front of the bathrooms by the main entrance to the track. Unless there is a pressing need to get on the track sooner, please stay off of it until 6:15. We'll have to clear out quickly after we finish the workout. We're uninvited guests at St Albans so we want to draw as little attention to ourselves as possible.\r\n\r\nThe plan for the men is 5 x 1600, 4 x 400. We'll take 2:00 rest on the 16s except that we'll take 3:00 rest after the last one, and we'll take 45 seconds on the 4s.\r\n\r\nTargets for group 1 are 74, 73, 72, 71 70 on the 16s, and 67, 66, 65, 64 on the 4s.\r\n\r\nTargets for group 2 are 76, 75, 74, 73, 72 on the 16s, and 69, 68, 67, 66 on the 4s.\r\n\r\nTargets for group 3 are 79, 78, 77, 76, 75 on the 16s, and 72, 71, 70, 69 on the 4s.\r\n\r\nA rump group 1 crew will do the PTA workout that the track guys did on Saturday, but faster. If you have such a complete lack of judgment that you think it would be a good idea to join them I'll give you the grotesque details.\r\n\r\nIf you're running at Maryland on Saturday you probably want to do less than all of this. Give me a shout to discuss a plan that works for you.\r\n\r\nI'll send the women's workout separately.\r\n\r\nGood luck to Dickson at World Masters Indoors, where he is running the 3000 tomorrow afternoon. Send 'em!\r\n\r\nSee you Wednesday at St Albans.\r\n\r\nJerry\r\n\r\n\r\n-- \r\nYou received this message because you are subscribed to the Google Groups "Georgetown Running Club Men" group.\r\nTo unsubscribe from this group and stop receiving emails from it, send an email to GRCmen+unsubscribe@googlegroups.com.\r\nTo view this discussion visit https://groups.google.com/d/msgid/GRCmen/LV8P221MB13480FB8826A6A9A72DDCC509DA72%40LV8P221MB1348.NAMP221.PROD.OUTLOOK.COM.\r\n	2025-03-25 02:02:10	coach.jerry@live.com	grcmen@googlegroups.com
12	wednesday workout, april 2, on the mall	RACES\r\n\r\nThe track crew was in action at the Maryland Invitational. Cerda got us off to a good start by finishing second in the 1500 in 4:37.38, which was her best performance in a GRC uniform by far and puts her seventh on the GRC all-time list. Cerda is improving rapidly, and she'll move up the list this season. In the 800, Daniel F ran 1:54.94, which is sixth on the list. Daniel's tactics were excellent, and he's in a great position to run some PRs in the coming weeks. Chase ran 1:57.55 out of the slow heat. Chase led most of the way and doing the work up front caught up to him in the last 100, but that was a very nice step forward.\r\n\r\nThe men's 5000 was a GRC time trial, as our guys went 1-5. When the gun went off it was 85 degrees which made it impossible to run fast, but the guys got in the rustbuster we were looking for. Keith got the win in 14:34.16, and I would say he perfectly executed the plan to run 70s except that he was .84 under the target. We demand perfection at GRC, but just this once we can accept a small error. Keith looked great, and I like his chances to break the club record in the 5000 and to move up the list in the 10,000 in the coming weeks. Campbell ran an enormous PR of 14:46.01, which is even more impressive given the oppressive heat. Campbell proved once again that he is a fearless competitor, and he was right with Keith for 4200. Tyler was third in 14:48.15, which was a strong effort in the heat. Tyler is in great shape and we'll see some big results from him soon. Joe was fourth in 15:08.18, and after hanging with the lead pack through 3200 he started his cool down early. Joe got the first one out of the way, and he'll be ready to lower his club record in the 1500 in the coming weeks. Daniel A made an impressive 5000 debut, running 15:28.04. In good conditions Daniel will have a great shot at breaking 15.\r\n\r\nOn the women's side, Sarah J finished third in 17:43.36. Sarah doesn't love the heat but she took the lead at the mile and pushed the pace the resst of the way. June Mwaniki made her GRC debut in 18:24.54. June is a great addition for us, and we'll see some big resutls from her on the track and roads.\r\n\r\nADMINISTRATIVE\r\n\r\nTrack crew, this is last and final call for the 5000 at Penn Relays. Entries are due shortly. Thanks to the registration system Penn uses that was state of the art in 2003, once I hit the submit button it is impossible to make changes or additions. The current roster is below. If you're not on the list and you want to be, or you're on the list and no longer want to compete I need to hear from you no later than COB Tuesday.\r\n\r\n      Men—Cameron, Sam, Joe, Alex, Tyler, Keith, Zack Holden\r\n      Women/NB—Morgan, Caroline, Alex, Aaryn\r\n\r\nPlease read Outlaw's CB logistics email carefully. He covers all of the salient points, and he's available to answer any questions. One point I will stress is to stay out of the elite tent unless you have an elite bib. I've caused enough commotion with the race director already so let's not ruffle his feathers on race day.\r\n\r\nLet me know if you want to run Alexandria Half/5k.\r\n\r\nIf you're not running Alexandria Half/5k please volunteer! Everyone is expected to volunteer once a year, and it would be wise to get it out of the way now. Volunteering is fun, so don't be shy. The sign up sheet is below.\r\nhttps://docs.google.com/spreadsheets/d/1rg-1bJ17uYxJU3Bv1fJPdTEO89BtF5AJE-Y1vyrXsrc/edit?gid=723917746#gid=723917746\r\n\r\nIf you're looking for a summer race you can't do much better than Beach to Beacon, which is on August 2 in Cape Elizabeth, Maine. It's extremely competitive and by all accounts a beautiful course. The elite field is capped this year and applications are due by April 11. If you're interested submit this form asap. Let me know that you applied and I'll follow up with the elite coordinator, who is one of our former athletes. He owes me a favor, or at least I'll try to convince him that he does.\r\nhttps://docs.google.com/forms/d/e/1FAIpQLSd02Bny5xn9DVMYFBg3ikydR_8VdJRdagCYiFYWvK80BH9PNg/viewform?usp=sharing\r\n\r\nWORKOUT\r\n\r\nWe're ON THE MALL this week due to conflicts at the track. We'll roll at 6:30 so meet for the warmup at 5:45.\r\n\r\nNote that the Bucknell crew is going to hit the track at Yorktown HS on Tuesday night for a track focused workout. The gun goes off at 6:00 so meet for the warmup at 5:15. All are welcome. Let me know if you want in and I'll include you in the workout email.\r\n\r\nFor the for the men's CB crew, the plan on the Mall is 8 x 800 with 2:00 rest. If you're planning for a full send at CB I encourage you to stop there. If you want to get in more volume you can get an earlier start or keep going after the 8s. Give me a shout to discuss a plan that works for you.\r\n\r\nTargets for group 1 are 2 @ 72, 2 @ 70, 2 @ 68, 2 @ 66.\r\n\r\nTargets for group 2 are 2 @ 74, 2 @ 72, 2 @ 70, 2 @ 68.\r\n\r\nTargets for group 3 are 2 @ 77, 2 @ 75, 2 @ 73, 2 @ 71.\r\n\r\nI'll send the women's workout separately.\r\n\r\nSee you on the Mall on Wednesday.\r\n\r\nJerry\r\n\r\n\r\n\r\n\r\n\r\n-- \r\nYou received this message because you are subscribed to the Google Groups "Georgetown Running Club Men" group.\r\nTo unsubscribe from this group and stop receiving emails from it, send an email to GRCmen+unsubscribe@googlegroups.com.\r\nTo view this discussion visit https://groups.google.com/d/msgid/GRCmen/MN0P221MB136301AD1CB6304A806E61809DAD2%40MN0P221MB1363.NAMP221.PROD.OUTLOOK.COM.\r\n	2025-03-31 23:04:38	coach.jerry@live.com	grcwomen@googlegroups.com
13	wednesday workout, april 9, on the mall	RACES\r\n\r\nIt was GRC domination at Cherry Blossom. Tessa was twentieth place in 56:34,which is a PR and puts her seventh on the GRC all-time list. Tessa's top 20 finish in a very deep championship field caps off a big season--in the last five weeks she also ran a half PR on a hilly course in Atlanta and won DC RNR Half. Tessa has rediscovered her love for the sport, and she's already looking forward to defending her MCM title. Cleo got in a very strong tuneup for Boston in 57:31, and she's got a big PR coming. Morgan made a successful 10 mile debut in 58:25. While Morgan has unfinished business to attend to on the track in the coming weeks she showed that she has a promising future on the roads. Sarah took another big step forward in by running 58:29. Mckenzie ran a huge PR of 58:40, and there's more to come. Alex had a bit of a tough day, running 58:55, but she's in great shape and will have the chance to show what she can do this weekend on the track. Emily K made a smashing 10 mile debut in 59:01. Emily will get back to the mile in the coming weeks, and the strength she has developed on the roads is going to pay off in a big way. Autumn Sands made a strong GRC and 10 mile debut, running 59:07. Autumn is a big addition to our road crew, and she will prove it when she makes her marathon debut this season. Sydney ran a comfortable 59:11. Sydney has had a stressful few weeks, to say the least, and she was pleased with the effort. Chloe ran a huge PR of 60:00 which was surely the best race of her career. Erin M ran a very strong 61:46, which is another big step in her return to competition. Whitney ran 66:13, just two weeks after she ran a trail 50k. Frankie ran a controlled 70:17. Several people not from GRC, independent of each other, told me that Frankie is an inspiration. In these polarizing times we can all agree on that!\r\n\r\nOn the men's side, Cameron was twenty-second in an extremely strong field in 48:48. Cam's training has been limited this spring for several reasons that are out of his control, and this was a good start to what promises to be a big season. In his first race since the Olympic Trials Zach Herriott ran 48:59, which is his second fastest time at CB. Zach is in PR shape but an ill-timed case of covid precluded him from showing what he can do. Zach will be ready to go at the USATF 25k champs in 5 weeks. Jack ran a huge PR of 49:28 off of only 3 weeks of workouts, which bodes well for success in his marathon debut at Grandmas. Brian ran 50:10 as a final Boston tuneup. Brian  did not back off the training at all going into the race, and he will be ready to roll in two weeks. Campbell ran a huge PR of 50:23, a week after running a huge 5000 PR. I'm no statistician but I detect a trend. Terry ran 50:24 which is also a big PR, and he too will be ready to go at the 25k champs. Zack Holden ran 50:37 after a hard long run on Friday. Zack will be ready for a shot at the elusive 5000 club record at UVA next week. Neil continued his impressive return to competition after injury with a solid 50:49. Dylan ran a big PR of 51:25 and a 10k PR of 31:51 on route. Perhaps there's something beneficial about training at altitude. After those twin triumphs CB will have no choice but to take a page from Army 10 and make Dylan their poster boy. Connor R ran 51:53, and he's as happy to be back in DC as we are happy to have him back. Ian D ran a big PR of 52:02. Ben made his triumphant return from Florida in 52:17. Connor W ran a nice PR of 52:26. Several members of our Boston crew got in solid tuneups, including Rob in 52:29, Matt in 52:33, Sean in 53:33, Trever in 54:36, and Mitch in 55:02. Jason ran a nice PR of 52:39, followed by Kevin in 52:51. Outlaw ran his twelfth CB in 53:13, just 3 weeks after he got the win at Shamrock Marathon. Stuart got in a workout effort of 53:38. Dickson got back on the roads after an excellent indoor season, running 54:24, followed by Billy in 55:38, and Charlie in 56:36.\r\n\r\nADMINISTRATIVE\r\n\r\nIf you followed the news over the weekend you know that it went from bad to worse at my office. As a result I may be a tad delayed responding to emails while I adapt to the unfortunate situation. If you have a question that needs a timely response such as a workout plan, please so indicate in the subject line so I can put you at the top of the list.\r\n\r\nRoad crew, let me know if you want to run Pikes Peak 10k.\r\n\r\nTrack crew, I need to finalize the roster for Hopkins. The current roster is Daniel A and Cerda in the 1500, and Campbell, Charlie, and Aaryn in the 5000. If you aren't on the list and want to run please let me know this week.\r\n\r\nWe still need volunteers for Alexandria Half/5k. The sign up sheet is below.\r\nhttps://docs.google.com/spreadsheets/d/1rg-1bJ17uYxJU3Bv1fJPdTEO89BtF5AJE-Y1vyrXsrc/edit?gid=723917746#gid=723917746\r\n\r\nWORKOUT\r\n\r\nWe're stuck ON THE MALL again this week. We'll roll at 6:30 so meet for the warmup at 5:45. The good news is that it's spring break in Montgomery County next week so we'll be able to get back on the track. And post-CB we won't be doing anything crazy this week anyway so it's not the worst time for a Mall workout. I hasten to add that if you ran hard at CB you should think about sitting this one out and waiting until Saturday to get back to work.\r\n\r\nThe plan for the road crew is a maintenance workout of 5 x mile with 2:00 rest.\r\n\r\nTargets for group 1 are 75, 74, 73, 72, 71.\r\n\r\nTargets for group 2 are 77, 76, 75, 74, 73.\r\n\r\nTargets for group 3 are 80, 79, 78, 77, 76.\r\n\r\nIf you didn't run CB and you're not running Bucknell this weekend give me a shout to discuss a modification that works for you.\r\n\r\nI'll send the women's workout separately.\r\n\r\nSee you on the Mall.\r\n\r\nJerry\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n-- \r\nYou received this message because you are subscribed to the Google Groups "Georgetown Running Club Men" group.\r\nTo unsubscribe from this group and stop receiving emails from it, send an email to GRCmen+unsubscribe@googlegroups.com.\r\nTo view this discussion visit https://groups.google.com/d/msgid/GRCmen/LV8P221MB1348CFF8090F4ADC1F4722289DB52%40LV8P221MB1348.NAMP221.PROD.OUTLOOK.COM.\r\n	2025-04-08 01:52:28	coach.jerry@live.com	grcwomen@googlegroups.com
14	wednesday workout, april 16, at bcc	RACES\r\n\r\nAlex placed third in the 10,000 at the Bucknell Outdoor Classic in a huge PR of 35:03.3, which puts her seventh on the GRC all-time list. Alex came through 8000 in 28:00, which is also a PR. While Alex was a little disappointed to barely miss her goal of breaking 35:00 she was justifiably pleased with the effort. To put into perspective how dramatically Alex has improved, at Bucknell in 2023 she ran 18:50 for 5000. On Saturday she ran 17:31 twice and crossed the line knowing there was more in the tank. Alex's amazing progresses confirms a revolutionary theory I've been developing, which is that hard work and consistent training works!\r\n\r\nOn the men's side, Tyler ran 14:24.46 in the 5000, which is a humongous PR, and puts him tenth on the GRC list. Tyler's tactics were perfect—he hung at the back of the lead pack and moved up steadily throughout the race, going from twenty-sixth at halfway to tenth at the tape. This was a major breakthrough, and there's more to come this season. Daniel A ran a strong 15:20.73. Daniel's heat was dawdling at 2600 and he took the lead to keep it honest. Leading for several laps took its toll, but it was the right move. It didn't go as well for Sam, who ran 15:33.5. Sam looked great through 3600, and although it went south from there he fought all the way to the tape. On the plus side Sam threw an elbow on the starting line that was so vicious that the starter told me he'd never seen its equal. Don't get on that guy's bad side! Keith had a tough night in the 10,000, running 29:58.8. Keith was in great position at 8000 but when the moves happened he could not respond. Keith was affected by the fact that he missed some training due to a minor injury, but he's got a 5000 PR coming in the next few weeks. Seth also had a tough night. He ran 30:46, which is only marginally faster than the pace he ran in his breakthrough half marathon a few weeks ago. As Seth put it, he just didn't have it on the night, but he has a long season on the roads ahead where he will show what he can do.\r\n\r\nDaniel F finished fourth in the invitational mile at Dennis Craddock Classic at Lynchburg College in 4:11.72, which puts him fourth on the GRC list. Daniel went with the leaders and was in contention for the win at 1200, and he hung on for a very strong result. Daniel is going to find the extra gear he needs in the next couple of weeks.\r\n\r\nDickson got the win in the Coastal Delaware Running Festival 5k in a tempo effort of 16:32. If you haven't noticed, Dix loves to race!\r\n\r\nSean overcame stern competition from the seventh-grade gym class to get the win at the Our Lady of Lourdes 5k in 15:23, which broke his own course record. Now that Sean has defeated the best middle schoolers Bethesda has to offer he's ready to tackle the lower caliber field in Boston.\r\n\r\nADMINISTRATIVE\r\n\r\nWe need more volunteers for Alexandria Half/5k. If you're not racing please help out.\r\nhttps://docs.google.com/spreadsheets/d/1rg-1bJ17uYxJU3Bv1fJPdTEO89BtF5AJE-Y1vyrXsrc/edit?gid=723917746#gid=723917746\r\n\r\nPlease let me know right away if you want to be included in our CIM entry request. The current roster is Brian, Campbell, Seth, and Clint.\r\n\r\nTracksmith and Trials of Miles are hosting an open meet with multiple heats of the 5000 on May 31 at Catholic University. It would be a good look for us to have a crew. We're working on getting some comp entries.\r\n\r\nWORKOUT\r\n\r\nWe'll roll at BCC at 6:45 so meet for the warmup at 6:00.\r\n\r\nThe plan for most of the men is 2 sets of 4-3-2-1 ladder with 2:00 rest on all of it, except that we'll take 3:00 between sets.\r\n\r\nTargets for group 1 are 71 on the 4, 69 on the 3, 67 on the 2, 65 on the 1 on set 1, and 69, 67, 65, 63 on set 2.\r\n.\r\nTargets for group 2 are 75 on the 4, 73 on the 3, 71 on the 2, 68 on the 4 on set 1, and 73, 71, 69, 66 on set 2.\r\n\r\nTargets for group 3 are 77 on the 4, 75 on the 3, 73 on the 2, 70 on the 4 on set 1, and 75, 73, 71, 68 on set 2.\r\n\r\nThe plan for the Boston crew is 6 x 800 with 2:00 rest. We can call the targets 76 on all of it, but we'll stay flexible.\r\n\r\nWe can modify this in any number of ways. Give me a shout to discuss a plan that works for you.\r\n\r\nI'll send the women's workout separately.\r\n\r\nSee you at BCC.\r\n\r\nJerry\r\n\r\n\r\n-- \r\nYou received this message because you are subscribed to the Google Groups "Georgetown Running Club Men" group.\r\nTo unsubscribe from this group and stop receiving emails from it, send an email to GRCmen+unsubscribe@googlegroups.com.\r\nTo view this discussion visit https://groups.google.com/d/msgid/GRCmen/LV8P221MB13488F71EADFBF5922F270B79DB22%40LV8P221MB1348.NAMP221.PROD.OUTLOOK.COM.\r\n	2025-04-15 02:30:05	coach.jerry@live.com	grcwomen@googlegroups.com
15	wednesday workout, april 23, at st albans	RACES\r\n\r\nWe had some big performances this morning in Boston. The race of the day came from Sara S who ran a humongous PR of 2:44:13, which ties her for tenth place on the GRC all-time list with Maura Linde, who was one of Sara's coaches at Hopkins. It all comes full circle at GRC! Sara had an extraordinarily hectic week, and that she was able to focus on the race and not the chaos swirling around her was a victory in and of itself. Well done! It was a successful homecoming for Ana who ran a very strong 2:55:44, which vastly exceded her expectations. Ana has come to the alarming conclusion that she's a marathoner, and for that she has my sympathy. Cleo was on the struggle bus for the last 10k but held on to finish in 2:57:24.\r\n\r\nOn the men's side, Brian ran 2:24:39, which was an excellent effort. Brian had a fantastic training cycle and was fit to run much faster but it wasn't his day. Brian is an extremely determined competitor, and he'll show what he can do the next time out. Matt ran a huge PR of 2:27:51. Matt went into the race with low expectations but felt great and kept rolling for what was unquestionably the best performance of his long career (though his career isn't quite as long as his old coach at Bucknell recalls--when I told him last week that Matt is running with GRC he asked me if Matt was in his late 30s by now). Graham ran 2:28:42, which was a gigantic PR, and he overcame stomach issues and a calf cramp that was so bad he wasn't sure if he could finish. That's what I call running through it! Sean ran a big PR of 2:30:54, which was the product of years of hard work. Granted that performance wasn't as impressive as Sean's course record at the Our Lady of Lourdes 5k but it was still pretty darn good. JLP ran a major PR of 2:33:09. A few weeks ago JLP wasn't sure if he would be able to race at all, which makes this performance even more special. Trever ran 2:36:53, and he was hurting so bad late in the race that he was happy to finish. Trev had an excellent training cycle and he'll be back better than ever. Marcelo had major hamstring problems midway through and it was a struggle to finish but he hung tough and ran 2:39:21.\r\n\r\nLast but not least, Chris Bain ran 2:56:40, which was his 27th consecutive Boston under 3 hours. That is truly remarkable, and is a testament to Chris's durability, consistency, and let's be honest, his obstinance. I tip my cap to you, young fella!\r\n\r\nThe track crew was in action in locations far and wide. Gina opened her outdoor season successfully at the Bryan Clay Invitational by running 4:21.87 for 1500. Gina stayed relaxed throughout and closed in 68.7. That was a good start to what promises to be an epic season.\r\n\r\nAt the Hopkins Loyola Invite, Cerda ran 4:33.54 in the 1500, which was her best performance in a GRC uniform, by far. Cerda will take a few more shots this spring at breaking 4:30, and I very much like her chances. On the men's side, Jim was fifth in the 1500 in a near PR of 3:57.1. Daniel A ran a solid 4:01.61 and closed in 62.6. In the 5000 Charlie ran 16:10.17, which was a very good effort in less than ideal conditions.\r\n\r\nJason made a triumphant return to CNU by finishing fourth in the 1500 at the Captains Classic in 4:03.54.\r\n\r\nEmily K started her track season at the Sean Collier Invitational at MIT by running 4:46.61 in the 1500. Emily was not happy with the performance but better days are coming.\r\n\r\nOn the roads, Daniel F was second in the DOG Street 5k in Williamsburg in a PR of 14:59. Unlike Sean, Daniel was unable to handle the challenge from local high schoolers, as he was bested by a 15 year-old. I've already signed that kid to the GRC class of 2031.\r\n\r\nSOCIAL MEDIA POLICY\r\n\r\nThe GRC code of conduct, which all members have signed, states the following: "Members agree to abide by GRC anti-harassment policy: Harassment is behavior that is hostile or offensive. We prohibit and do not tolerate harassment at GRC-hosted events or at events not hosted by GRC where GRC members are present, including on all social media platforms." Please keep this policy in mind when posting on any and all social media platforms. My grandmother often told us about a saying from the old country which is still relevant all these years later: if you don't have anything nice to say STFU.\r\n\r\nADMINISTRATIVE\r\n\r\nThe Alexandria Half/5k is on Sunday, and we still need volunteers. If you're not running you would be well-served to get your volunteer obligation for 2025 out of the way now. Prospective members are strongly encouraged to volunteer.\r\nhttps://docs.google.com/spreadsheets/d/1rg-1bJ17uYxJU3Bv1fJPdTEO89BtF5AJE-Y1vyrXsrc/edit?gid=723917746#gid=723917746\r\n\r\nTrack crew, please let me know if you want to run at Princeton, Maryland Twilight, and/or Widener Final Qualifier. The current roster for MD Twilight is Daniel F 800, and Daniel F, Daniel A, and Jim 1500. The current roster for Princeton is Joe and Cerda 1500, and Keith, Tyler, Morgan, and Sarah J 5000.\r\n\r\nThere are a couple of comps for the Tracksmith 5000 that are unaccounted for. If you want to stake your claim give me a shout.\r\n\r\nMen, please update your bios. There is a disturbing preponderance of Pacers jerseys in the photo array. If you ran Clubs or Cherry Blossom there are many, many photos to choose from. If you didn't run either of those races, shame on you! Send a photo that you like to Jack.\r\n\r\nWORKOUT\r\n\r\nWe'll roll at ST ALBANS at 6:45 so meet for the warmup at 6:00. There is a lacrosse game at 4:30 so the warmup will be off the track. We'll muster in front of the bathrooms and you can take your stuff up to the track afterwards.\r\n\r\nWe have a lot of moving parts this week. Men, for those who aren't running Penn or Alexandria Half, the plan is 10 x 1k w/ 2:00 rest.\r\n\r\nTargets for group 1 are 2 @ 72, 2 @ 71, 2 @ 70, 2 @ 69, 2 @ 68.\r\n\r\nTargets for group 2 are 2 @ 74, 2 @ 73, 2 @ 72, 2 @ 71, 2 @ 70.\r\n\r\nTargets for group 3 are 2 @ 77, 2 @ 76, 2 @ 75, 2 @ 74, 2 @ 73.\r\n\r\nIf  you're running the half, we'll call it after 6 x k.\r\n\r\nIf you're running Penn you already know the plan for Tuesday.\r\n\r\nGive me a shout to discuss a modification that works for you.\r\n\r\nI'll send the women's workout separately.\r\n\r\nSee you at St Albans.\r\n\r\nJerry\r\n\r\n\r\n-- \r\nYou received this message because you are subscribed to the Google Groups "Georgetown Running Club Men" group.\r\nTo unsubscribe from this group and stop receiving emails from it, send an email to GRCmen+unsubscribe@googlegroups.com.\r\nTo view this discussion visit https://groups.google.com/d/msgid/GRCmen/LV8P221MB13488A1F5EBB9292ED9C5F299DBB2%40LV8P221MB1348.NAMP221.PROD.OUTLOOK.COM.\r\n	2025-04-22 02:49:06	coach.jerry@live.com	grcwomen@googlegroups.com
16	wednesday workout, april 30, at st albans	RACES\r\n\r\nOur athletes were in action at venerable track meets this weekend. At Drake Relays, Gina finished sixth in the elite 800 in 2:05.69, which is the second fastest time of her career. Gina's tactics were spot-on—she stayed attached to the back of the pack and came through 400 in 60 flat, and her 65.61 second lap was the fourth fastest of the day. Gina more than held her own in a field of professional runners, which bodes well for an epic season ahead.\r\n\r\nAt Penn Relays, Cameron was a very close second in the 5000 in a huge PR of 14:13.56, which puts him fourth on the GRC all-time list. Cam ran a smart and confident race--he was with the lead pack for 4k, at which point he made a big move to take the lead. With 400 to go it looked like Cam had it, but despite closing in 61.4 he got passed in the last 200 by a 3:54 miler. The very slow early pace cost Cam the club record--his last 1600 was 4:23(!) and in a better paced race in the coming weeks the record is going down. Evan finished sixth in a PR of 14:32.9. Evan went with the lead pack and tried to hang on long enough to use his formidable closing speed, but the training time he lost to injury and illness in March left him a little short of full fitness. Evan will challenge the club record next time out. Tyler ran a solid 14:37.99. The slow early pace and subsequent big cutdown didn't do Tyler any favors, but he was pleased with the effort. Keith ran 14:45.6, which was an encouraging performance given that he has been dealing with a balky calf, so much so that it was unclear earlier in the week if he would be able to compete at all. Keith has more racing to come, and he'll show what he can do in the near future. Joe had a rough go of it, running 14:48.99, but on the plus side his 65.2 final 400 was fourth fastest in the field. Joe will focus on the 1500 the rest of the season, and he's ready to pop a big one. Alex ran 14:52.88, which was a strong performance in his first race since Clubs. Sam ran 15:29.7, and the experience he gained at Penn this year will serve him well in the future.\r\n\r\nOn the women's side, Morgan ran a nice PR of 16:53.24. Morgan did it the hard way—she led through 2k, at which point the pro runners who were sitting on her broke the race open and left Morgan in no-man's land. Morgan fought all the way to the tape, but the combination of leading for the first 2k and then rolling solo for the last 3k was a lot to overcome. Multiple pro runners sitting on Morgan was the most eggrious example of chickenshit tactics that I've seen in a 5000 since Alan Webb sat on Sam Luff for 3400 at George Mason oh those many years ago. Morgan deserved better, and this week at Princeton she's going to take some time off her new PR. Sarah J ran a solid 16:58.82, and as she continues to work her way back to full fitness we'll see much more from her in the coming weeks. Alex had a rough night, running 17:12.69. Alex was exhausted from flying across the globe last week, and with a little rest she'll be back on top.\r\n\r\nSydney got the win at the inaugural Alexandria Half in 1:17:50. Sydney has had a rough spring outside of running, and her performance was a really nice way to finish the season. Chloe was second in a huge PR of 1:19:30. That was a major breakthrough for Chloe, and with this excellent performance she is going out on top. While Harvard Law School will look good on her resume, a 1:19:30 half will put her in a category above the rest of her well-credentialed classmates! In the 5k, Gabi was third in the 5k in 18:45. We'll see much more from Gabi as she continues to build back to full fitness.\r\n\r\nOn the men's side, Connor W placed second in 1:08:54, which was a near PR. Connor took the lead around 5 miles and held it for quite a while, but fighting the wind solo eventually caught up to him. Connor was happy with the effort, and deservedly so.  Kevin was third in a nice PR of 1:09:30. Charlie won the masters race in 1:12:31, which was his fastest half since 2019.\r\n\r\nAlso on the roads, Neil was second at Pikes Peak 10k in a PR of 30:15, which puts him sixth on the all-time list. That was a good tuneup for an inevitable PR at Broad Street.\r\n\r\nADMINISTRATIVE\r\n\r\nWe have comps for Loudon Street Mile, which is on Memorial Day in Winchester, VA. The course is a net downhill and there are no turns. If you're looking to run fast Loudon is the place to do it. Let me know if you want in.\r\n\r\nWe have a limited number of comps for Lawyers Have Heart 5k/10k. Give me a shout if you want to be considered for an entry.\r\n\r\nThe comps for the Tracksmith 5000 are spoken for, but we have a discount code for additional entries.\r\n\r\nAlso for the Tracksmith 5000, we need pacers for the fast heats. If you're available to help out let me know, and we'll figure out the pacing assignments.\r\n\r\nWe have the opportunity to compete in an invite-only meet on Sunday May 18 at George Mason in the 800 and mile. It's hard to predict the level of competition, but it could be worthwhile.\r\n\r\nWORKOUT\r\n\r\nWe'll roll at 6:45 at St Albans, so meet for the warmup at 6:00.\r\n\r\nThe plan for the Broad Street men is 4 x 1200, 4 x 600, all with 2:00 rest.\r\n\r\nTargets for group 1 are 72, 71, 70, 69 on the 12s and 67, 66, 65, 64 on the 6s.\r\n\r\nTargets for group 2 are 75, 74, 73, 72 on the 12s and 70, 69, 68, 67 on the 6s.\r\n\r\nTargets for group 3 are 77, 76, 75, 74 on the 12s, and 72, 71, 70, 69 on the 6s.\r\n\r\nThose who are not racing this weekend will start early with a 3200 tempo.\r\n\r\nThose who are racing on the track on Friday will roll tomorrow at NOVA practice, and you'll have a separate plan.\r\n\r\nAs always, we can modify this in any number of ways. Give me a shout to discuss a plan that works for you.\r\n\r\nI'll send the women's workout separately.\r\n\r\nSee you at St Albans.\r\n\r\nJerry\r\n\r\n-- \r\nYou received this message because you are subscribed to the Google Groups "Georgetown Running Club Men" group.\r\nTo unsubscribe from this group and stop receiving emails from it, send an email to GRCmen+unsubscribe@googlegroups.com.\r\nTo view this discussion visit https://groups.google.com/d/msgid/GRCmen/LV8P221MB13488DF7855E81756ADD9C0C9D802%40LV8P221MB1348.NAMP221.PROD.OUTLOOK.COM.\r\n	2025-04-29 01:47:28	coach.jerry@live.com	grcwomen@googlegroups.com
17	wednesday workout, may 7, on the mall	RACES\r\n\r\nIt was GRC domination at Broad Street, with thee of our men finishing in the top five. The times were slow across the board because of high humidity and a head wind, and it's super unfortunate that the conditions precluded fast times, but that does not diminish the quality of our performances. Cameron led the way in third in 48:41. Cam has run in the 48:40s three times, and while the conditions precluded him from running the big PR he was ready for, third place at Broad Street is an objectively excellent run. Jack was fourth in 50:15 and was solo almost the entire race. Jack is in great shape, and he'll show it at Grandmas. Neil was fifth in 50:44, and while he was not pleased with the time that was another strong run in his impressive comeback season. Ben prepared for the humidity by establishing a training camp in Florida a few months back and it showed with his seventh place finish in 51:12. Ian D ran a strong 52:12, followed by Alex in 52:42, and Rob in 53:19.\r\n\r\nOn the women's side, Mckenna finished ninth in 59:13, which was an excellent performance to cap off her breakthrough season. Caroline ran a PR of 60:52, and she is capable of running much faster in good conditions. Erin M continued her comeback season with a solid 63:17. Whitney struggled in the conditions and ran 68:02, but she will be back in a big way in the fall.\r\n\r\nAt the USATF 5k road champs in Indy Ryan was twenty-fourth in 14:53. Ryan hung on to the back of the pack and competed well with the big boys on a course that was not nearly as fast as advertised. Alex placed twenty-sixth in 17:54. The national class field was a bit overwhelming for Alex at a distance that is out of her comfort zone but she enjoyed the experience of lining up with the pros.\r\n\r\nThe track crew was also in action. At the Larry Ellis Invite at Princeton Tyler ran a huge 1500 PR of 3:52.64, which puts him sixth on the GRC all-time list. Tyler moved up from fifteenth place at 1100 to seventh at the line with an outstanding 59.02 last 400. Tyler had major breakthroughs this season in both the 1500 and 5000, and his future is bright indeed. Joe ran 3:53.54 and closed in 60.5. That was Joe's best performance of the year, by far, and he isn't done yet.\r\n\r\nIn the 5000 at Princeton Sarah J ran a strong 16:55.91 and closed in 76. Sarah has improved steadily through the season, and she still has some racing left. Morgan ran 17:08.63 which was not indicative of her fitness. Morgan will be back in the coming weeks to show what she can do.\r\n\r\nAt Maryland Twilight, Daniel F ran 1:54.98 in the 800, which moves him up to sixth on the GRC list. Daniel came back to run 3:59.75 in the 1500. Daniel is back to full fitness, and he has is ready to PR in the coming weeks. Chase ran 1:56.79 in the 800, and competed very well. Jim ran 3:57.41, and he's ready for a breakthrough in the coming weeks.\r\n\r\nOn the women's side, Cerda ran a very strong 4:35.22 in the 1500. Cerda is improving every week, and she's going to keep that trend going the rest of the season. Emily K ran a solid 4:37.45, and she is also trending up in a big way. In their first 1500 since college Aaryn ran an impressive 4:54.55 despite a very sore Achilles. Aaryn's goal was to break 5 minutes, and it was mission accomplished, with room to spare.\r\n\r\nADMINISTRATIVE\r\n\r\nI need to submit our entries for Widener Last Chance tomorrow. The current roster is below. If you aren't on it and want to be or are on it and no longer want to compete I need to hear from you right away.\r\n1500: Daniel F; 5000: Keith, Jason, Zack Holden\r\n\r\nMark your calendar for practice on Saturday May 24, when we will have a professional photographer on hand. We want as close to full attendance as possible, and that includes those who aren't going to run the workout. The photographer will get headshots before practice and action shots during practice. Plan to have your white t-shirts and uniform with you, and wear white socks. Bonus points to anyone who can explain why the photographer specifically requested that we wear white socks.\r\n\r\nWe have comps for Loudon Street Mile. Let me know if you want in.\r\n\r\nGive me a shout if you want the discount code for the Tracksmith 5000 and/or Lawyers Have Heart.\r\n\r\nAlso let me know if you want to be included in our entry request for Indy full/half.\r\n\r\nOn behalf of Cam, if you plan to attend the (unofficial) spring party he is hosting on May 17 (1209 5th St NE, Washington DC 20002 starting at 4pm), please let him know on the form below. Plus ones are welcome. I encourage everyone to attend. The official spring team meeting/party will be at a date to be determined.\r\nhttps://docs.google.com/forms/d/19i_BryhVGdXh1b7SUn1twfTwqiKJtHGIfVfmMz7qdv4/edit\r\n\r\nWORKOUT\r\n\r\nWe'll roll on THE MALL at 6:45 so meet for the warmup at 6:00. With any luck this will be our last visit to the Mall until fall.\r\n\r\nThe generic plan for the men is 5 x mile with 2:00 rest.\r\n\r\nTargets for group 1 are 75, 74, 73, 72, 71.\r\n\r\nTargets for group 2 are 77, 76, 75, 74, 73.\r\n\r\nTargets for group 3 are 80, 79, 78, 77, 76.\r\n\r\nAs always we can modify this in any number of ways. Give me a shout to discuss a plan that makes sense for you.\r\n\r\nI'll send the women's workout separately.\r\n\r\nSee you on THE MALL on Wednesday.\r\n\r\nJerry\r\n\r\n\r\n\r\n\r\n-- \r\nYou received this message because you are subscribed to the Google Groups "Georgetown Running Club Men" group.\r\nTo unsubscribe from this group and stop receiving emails from it, send an email to GRCmen+unsubscribe@googlegroups.com.\r\nTo view this discussion visit https://groups.google.com/d/msgid/GRCmen/LV8P221MB1348EE7A9A72C451A76AB1159D892%40LV8P221MB1348.NAMP221.PROD.OUTLOOK.COM.\r\n	2025-05-06 02:08:03	coach.jerry@live.com	grcwomen@googlegroups.com
18	wednesday workout, may 28, at st albans	RACES\r\n\r\nCongratulations to Evan for his excellent 4:02.26 mile at the Down the Stretch Track Fest, which is his second club record in the last two weeks! It was a large field and Evan got caught up in some traffic on the last lap but he beat some very good guys. Evan is giving it one more shot tomorrow night, and if the race shakes out well sub 4 is in play. Also in the mile at Down the Stretch Joe closed out his season with a 4:17.21. Joe competed well, and he'll go into the off-season feeling good about the effort. On the women's side, Morgan ran 5:00.12, which was a good tuneup for the Tracksmith 5000 on Saturday. In the 5000, Charlie ran 16:01.99, which was .42 seconds faster than last year. That's the kind of consistency that masters running is all about.\r\n\r\nAt Loudon Street Mile Jim was sixth in 4:16.3. On the women's side Cerda ran 5:02.1, which ties her for ninth on the GRC all-time list. Emily had a bit of a rough go, running 5:12.5.\r\n\r\nADMINISTRATIVE\r\n\r\nThe USATF 20k championship is on Labor Day in New Haven. It's a fast course and the race is known for its hospitality. It would be an excellent tune up for those running early fall marathons. The race director asked me to submit our request soon, so let me know if you want to be considered for an entry.\r\n\r\nWORKOUT\r\n\r\nWe'll roll at 6:45 at St Albans so meet for the warmup at 6:00.\r\n\r\nThe plan for the men who are not racing this weekend is 6 x 1600 with 2:00 rest.\r\n\r\nTargets for group 1 are 75, 74, 73, 72, 71, 70.\r\n\r\nTargets for group 2 are 77, 76, 75, 74, 73, 72.\r\n\r\nTargets for group 3 are 80, 79, 78, 77, 76, 75.\r\n\r\nThe plan for the Tracksmith 5000 crew is 6 x 600 with 2:00 rest. Targets are goal pace +/- 1 second.\r\n\r\nAs always we can modify this in any number of ways. Give me a shout to discuss a plan that works for you.\r\n\r\nI'll send the women's workout separately.\r\n\r\nSee you Wednesday at St Albans.\r\n\r\nJerry\r\n\r\n\r\n-- \r\nYou received this message because you are subscribed to the Google Groups "Georgetown Running Club Men" group.\r\nTo unsubscribe from this group and stop receiving emails from it, send an email to GRCmen+unsubscribe@googlegroups.com.\r\nTo view this discussion visit https://groups.google.com/d/msgid/GRCmen/LV8P221MB1348FF660F2B8EBB5525D5E59D64A%40LV8P221MB1348.NAMP221.PROD.OUTLOOK.COM.\r\n	2025-05-27 01:20:56	coach.jerry@live.com	grcwomen@googlegroups.com
19	wednesday workout, june 4, at bcc	RACES\r\n\r\nGina had herself a meet at the Games of the Small States of Europe in Andorra, where she did triple duty in the 800, 1500, and 5000. The 800 was first and Gina won gold in 2:10.01. After a very slow first 400 Gina got tripped from behind. When she regained her balance she was at a 10 meter deficit, and with 300 to go she was 15 meters in arrears. But Gina stayed patient, and her outstanding 58.6 last 400 won the day. The 1500 was next, and Gina's opposition, a 2024 Olympian, ran the last 800 in 2:08. Gina covered the move for 400, but with the 800 in her legs Gina could not hold on and was happy to take the silver in 4:29.52. The 5000 was the final event, and the combination of altitude, tired legs, and a competitor who ran 15:30 earlier this year meant that Gina was running for second. Gina unleashed her big kick with 400 to go and closed in 69.1 to secure silver in 17:07.3. Three races, one gold and two silvers was mission accomplished. Well done!\r\n\r\nAt the Tracksmith 5000, Cameron got the win in an excellent 14:11.17, which is a PR, and puts him second on the GRC all-time list. Cam came through 3000 in 8:29.8, which is ninth on the list. Cam came up just short of his goal of breaking the longstanding club record but not for lack of trying. That record is on borrowed time, and Cam is determined to take it down next year. Keith was second in 14:38.44, and the time was not reflective of the effort, which was mostly solo after 1600. Alex ran 15:13.8, and he's got much more in the tank. Dickson and Charlie ran together to great effect, finishing in 15:52.43 and 15:52.69 respectively. Rich rounded our masters squad with a strong 16:23.79.\r\n\r\nOn the women's side, Grace Hadley made an impressive GRC debut, getting the win in 16:27.62, which puts her seventh on the all-time list. Grace came through 3000 in 9:38.47, which is sixth on the list. Grace is a two-time DIII champion and seven-time All-American, and she is a huge addition to our track and xc crew. Morgan was second in 16:49.91, which is a nice PR. That was a great way to close out a successful season. June ran 18:34.79, and she will continue to work her way back to full fitness. Big shout out to our group of intrepid pacers, Joe, Ian D, Connor, Mitch, and new man Derek. Thanks guys!\r\n\r\nJim ended his season with a third place finish in the Bel Air Town Run 5k in 15:12.9, on a very hilly course. Jim was in contention the whole race and was pleased to finish his season with another strong performance.\r\n\r\nADMINISTRATIVE\r\n\r\nCharlie pointed out to me that tomorrow is the ten-year anniversary of Nina's death. To mark that tragic milestone, please take the opportunity to make sure that your smoke detectors are operational and that you can open your windows in case of emergency. Being a member of GRC meant the world to Nina, and the anniversary of her passing is also an opportunity for all of us to reflect on how fortunate we are to be part of the team, particularly in these trying times.\r\n\r\nTo that end, the summer team meeting is on the evening of June 28, at a location to be determined. The winter and summer team meetings are the only occasions each year when we bring everyone together in a non-running setting, and I urge you to attend.\r\n\r\nThe Suds and Soles 5k is on the evening of Saturday June 14 in Rockville. If you're looking for a low key 5k with free craft beer afterwards this is the race for you. I have the comp code. Let me know if you want to compete.\r\n\r\nThere will be slightly more competition at the USATF 20k championship, which is on Labor Day in New Haven. It would be an excellent tune up for those running early fall marathons. The race director asked me to submit our request soon, so let me know if you want to be considered for an entry.\r\n\r\nMarathon crew, I'm sure you've heard that USATF finally got around to publishing the Trials standards. There is a Zoom meeting next Monday to talk about the site selection process and other Trials related topics that I will attend so you don't have to. I'll send a full update afterwards.\r\n\r\nWORKOUT\r\n\r\nWe'll roll at 6:45 at BCC so meet for the warmup at 6:00. (The reason for the location switch is that St Albans was locked last week. Once we're confident that it is open for our use we will make our triumphant return).\r\n\r\nThe plan for the men is 2 x 2400, 4 x 1200, with 2:00 rest on all of it.\r\n\r\nTargets for group 1 are 74, 73 on the 24s, and 71, 70, 69, 68 on the 12s.\r\n\r\nTargets for group 2 are 76, 75 on the 24s, and 73, 72, 71, 70 on the 12s.\r\n\r\nTargets for group 3 are 79, 78 on the 24s, and 76, 75, 74, 73 on the 12s.\r\n\r\nAs always we can modify this in any number of ways. Give me a shout to discuss a plan that works for you.\r\n\r\nI'll send the women's workout separately.\r\n\r\nSee you at BCC.\r\n\r\nJerry\r\n\r\n\r\n-- \r\nYou received this message because you are subscribed to the Google Groups "Georgetown Running Club Men" group.\r\nTo unsubscribe from this group and stop receiving emails from it, send an email to GRCmen+unsubscribe@googlegroups.com.\r\nTo view this discussion visit https://groups.google.com/d/msgid/GRCmen/LV8P221MB13487EE837EBD66AC16325BB9D6DA%40LV8P221MB1348.NAMP221.PROD.OUTLOOK.COM.\r\n	2025-06-03 01:53:39	coach.jerry@live.com	grcmen@googlegroups.com
20	wednesday workout, june 11, at bcc	ADMINISTRATIVE\r\n\r\nWe're at BCC again this week, but we should be fine to return to St Albans next week.\r\n\r\nThe summer team meeting is on the evening of June 28, at a location to be determined. We have important team business to discuss, excellent spring performances to celebrate, and plans for racing in the fall to formulate. Please plan to attend.\r\n\r\nThe Suds and Soles 5k is this Saturday evening in Rockville. I have the comp code. Let me know if you want to compete.\r\n\r\nAlso let me know if you want to run the USATF 20k championship, which is on Labor Day in New Haven. It would be an excellent tune up for those running early fall marathons. We don't want to wait too terribly long to submit our entry request so please let me know soon if you want to be considered for a comp.\r\n\r\nHot off the presses—the USATF XC champs, which is the selection meet for World XC, will be on December 6 in Portland, OR. It would be the best possible tuneup for Clubs XC five weeks hence. I'd love to take two A teams out there so keep it on your radar.\r\n\r\nWORKOUT\r\n\r\nWe'll roll at BCC at 6:45 so meet for the warmup at 6:00.\r\n\r\nI'm behind schedule on writing the workout, so in the interest of getting to bed before 1:00 a.m. I'll send the plan tomorrow morning.\r\n\r\nJerry\r\n\r\n\r\n-- \r\nYou received this message because you are subscribed to the Google Groups "Georgetown Running Club Men" group.\r\nTo unsubscribe from this group and stop receiving emails from it, send an email to GRCmen+unsubscribe@googlegroups.com.\r\nTo view this discussion visit https://groups.google.com/d/msgid/GRCmen/LV8P221MB1348A8063549FF897EBB8DD59D6AA%40LV8P221MB1348.NAMP221.PROD.OUTLOOK.COM.\r\n	2025-06-10 02:33:05	coach.jerry@live.com	grcmen@googlegroups.com
21	wednesday workout, june 18, at st albans	RACES\r\n\r\nA big GRC mazel tov to Gina for her outstanding 2:03.29 800 at the Johnny Lorring Classic in Windsor, Ontario, which is a huge PR, and breaks her own club record. Gina was fourth place in an international field, and if the race were 10 meters longer she would have been second. This was unquestionably the best race of Gina's career, and there's much more in the tank. Not to put too fine a point on it, but I have seen Gina race many times and I have never seen her run so controlled and in command throughout. Gina has several races coming up in Europe and I wouldn't be surprised to see more PRs in the near term. Well done!\r\n\r\nAlso on the track, Keith finished an excellent ninth place in his heat in the 5000 at the Portland Track Festival in 14:23.51. Keith's tactics were perfect—he moved up steadily throughout the race and closed in 65 for the last 400. That was Keith's best race of the year, and it was a great way to close out the season.\r\n\r\nCloser to home, at the Run Unbridled Track Fest at George Mason, Grace ran 2:15.62 in the 800, which puts her sixth on the GRC all-time list. Alahna Sabbakhan made her GRC debut by running 2:16.29, which is ninth on the list. Alahna is a huge addition to our mid distance squad, and she proved it an hour later in the DMR where she ran 57.1 on the 400 leg, which is the fastest split in GRC history. Grace got the relay started in 3:36.66 on the 1200 leg. Jackson Walker ran the 800 leg, and he got the baton 24 seconds behind the leader. Jackson's 2:02.5 got us within 16 seconds. That was close enough for Evan, who made up the gap in the first 1200. Evan cruised in from there, and his 4:14.6 gave us the win by a comfortable margin. Evan has been on break and this was his first non-easy run in a month. 4:14 off of essentially nothing is impressive indeed.\r\n\r\nOn the roads, Cameron was an excellent ninth place at the USATF 4 Mile Championships in Peoria, IL, in 18:40.69. There was no official 5k split but Cam was within shouting distance of his PR and kept rolling. A top 10 finish at national championship is outstanding, and is indicative of Cam's very high fitness level. The race was also the USATF Masters Champs, and Dickson placed second overall, and first in his age group, in 20:53. With that outstanding performance Dix is well on his way to defending his USATF masters grand prix championship.\r\n\r\nAt the Suds and Soles 5k, Daniel A ran 17:03, and Whitney ran 20:12. That was a nice rustbuster for both of them. How many beers they drank after the race is close hold information.\r\n\r\nADMINISTRATIVE\r\n\r\nThe link for the team photo shoot is below. As you'll see, the photos came out great! Our social media team will let the world see them staring this week.\r\nhttps://ahmedcherkaouiphotography.pixieset.com/grcxtracksmithteamuniform/\r\n\r\nThe team meeting is June 28 at a location to be determined. Please plan to be there.\r\n\r\nRoad crew, let me know if you want to run either Annapolis 10 Mile or the USATF 20k champs.\r\n\r\nWORKOUT    \r\n\r\nWe'll roll at St Albans at 6:45 so meet for the warmup at 6:00.\r\n\r\nThe plan for the men is 4 x 1600, 4 x 800, with 2:00 rest on all of it.\r\n\r\nTargets for group 1 are 76, 75, 74, 73 on the 16s, and 71, 70, 69, 68 on the 8s.\r\n\r\nTargets for group 2 are 78, 77, 76, 75 on the 16s, and 73, 72, 71, 70 on the 8s.\r\n\r\nTargets for group 3 are 81, 80, 79, 78 on the 16s, and 76, 75, 74, 73 on the 8s.\r\n\r\nWe'll adjust as needed based on the conditions.\r\n\r\nAs always, we can modify this in any number of ways. Give me a shout to discuss a plan that works for you.\r\n\r\nI'll send the women's workout separately.\r\n\r\nSee you at St Albans.\r\n\r\nJerry\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n-- \r\nYou received this message because you are subscribed to the Google Groups "Georgetown Running Club Men" group.\r\nTo unsubscribe from this group and stop receiving emails from it, send an email to GRCmen+unsubscribe@googlegroups.com.\r\nTo view this discussion visit https://groups.google.com/d/msgid/GRCmen/LV8P221MB134865FAC96EE214241C57939D73A%40LV8P221MB1348.NAMP221.PROD.OUTLOOK.COM.\r\n	2025-06-17 03:01:38	coach.jerry@live.com	grcwomen@googlegroups.com
22	wednesday workout, june 25, at st albans	RACES\r\n\r\nIt was hot at Grandmas—really hot—but the gang got after it nonetheless. In the full, Jack made a very promising debut, running 2:25:30. Jack was right where he wanted to be at the half, coming through in 1:10:02, and he was able to maintain through about 20. The last 10k was a struggle, and Jack's legs were gone the last 2 miles, but he hung tough for an excellent result. Jack is already talking about the next time, which is obviously a good sign. Seth ran 2:26:27, which was extremely impressive given that he had health issues in the two weeks before the race that threatened to derail the race entirely, as well as a death in the family that deeply affected him. It all caught up with Seth at 20 miles and it was a victoty to get to the finish line upright. Seth fought all the way to the tape, and he was justifiably proud of the effort.\r\n\r\nOn the women's side, Autumn made a successful debut, running 3:04:10. Autumn had a very short build due to a nagging injury, and she went into it with a conservative race plan. Autumn executed the plan perfectly, going through the half in 1:33:38, and maintained that pace through 23 miles. Autumn felt good with 5k to go and closed hard for a big negative split. With a full cycle and good conditions next time out Autumn will run much, much faster.\r\n\r\nIn the half, Rob ran an excellent 1:09:04. While that was fractionally slower than Rob's PR from 2018 this was a superior performance due to the challenging conditions. Rob is moving in the right direction and he has PRs coming in the fall. Impressive though his race may have been, it was a bit of a let down from the splits on the live tracker, which had Rob going through 7 miles at 4:11 pace. Charlie and heat don't mix,and the conditions got the better of him early on. Charlie was fine for 3 miles, at which point he realized that it was not his day and started his cool down 10 miles out. Charlie finished in 1:18:37, and was happy to stay out of the med tent.\r\n\r\nGraham finished eighth in the Manitous Revenge 50 miler in upstate New York. That was an excellent result in a competitive field on an extremely challenging course that included traversing several mountains in the Catskills on trails that Graham described as insanely steep, and which required a good amount of hand over hand climbing. 50 miles on trails over steep mountains isn't everyone's idea of an enjoyable day in the country but Graham had a great experience.\r\n\r\nDickson was second in the mile at New Jersey International in 4:46.25. Dix was disappointed to have his three year victory streak broken but it does not diminsh his excellent season.\r\n\r\nADMINISTRATIVE\r\n\r\nThe team meeting is SUNDAY at 5:00 at Sydney's house, 1316 Shepherd Street NW. We have a lot to discuss, and it's important for everyone who is town, including prospective members, to attend.\r\n\r\nLet me know if you want to run Annapolis 10 Miler.\r\n\r\nWORKOUT\r\n\r\nWe'll roll at 6:45 at St Albans so meet for the warmup at 6:00.\r\n\r\nIt's going to be hot out there. We'll keep the intervals short so you don't have to go too long without grabbing water.\r\n\r\nThe plan for the men is 5 sets of 4 x 400 with 45 seconds rest in the set and 3:00 between sets.\r\n\r\nTargets for group 1 are 70, 69, 68, 67, 66.\r\n\r\nTargets for group 2 are 73, 72, 71, 70, 69.\r\n\r\nTargets for group 3 are 76, 75, 74, 73, 72.\r\n\r\nAs always we can modify this in any number of ways. Give me a shout to discuss a plan that works for you.\r\n\r\nI'll send the women's workout separately.\r\n\r\nSee you at St Albans.\r\n\r\nJerry\r\n\r\n\r\n\r\n\r\n\r\n-- \r\nYou received this message because you are subscribed to the Google Groups "Georgetown Running Club Men" group.\r\nTo unsubscribe from this group and stop receiving emails from it, send an email to GRCmen+unsubscribe@googlegroups.com.\r\nTo view this discussion visit https://groups.google.com/d/msgid/GRCmen/LV8P221MB13488FE605C46366C8365B949D78A%40LV8P221MB1348.NAMP221.PROD.OUTLOOK.COM.\r\n	2025-06-24 02:27:07	coach.jerry@live.com	grcmen@googlegroups.com
23	wednesday workout, july 2 at st albans	RACES\r\n\r\nGina was front and center at the European Team Championships Division 3 in Maribor, Slovenia. By winning the 800 and 1500 and anchoring Malta's mixed 4 x 4 to fourth place Gina was the top scoring woman in the meet! The 800 was first, and the tactical race played right into her hands. Gina went through all of the gears on the last lap, closing in 61.4 for the last 400, 28.5 for the last 200, and 13.7 for the final 100 to win in a hard-fought 2:10.05. The 1500 was the next day and in another tactical race Gina made it look easy, closing in 30.5 to get the win in 4:27.22. Two hours later Gina anchored the relay in an unofficial 55.7, which was a big PR in her first competitive 400 in a minute. The European tour will continue this week, but for now it's worth celebrating a great two-day performance.\r\n\r\nI encourage you to take a few minutes to watch the 1500 at the link below. It's a clinic in tactical racing, and it's fun to hear the British announcers sing Gina's praises.\r\n\r\nhttps://na01.safelinks.protection.outlook.com/?url=https%3A%2F%2Fyoutu.be%2FQGrQnV2MtLs%3Fsi%3DHZ-jmxwH4w9VnIFG&data=05%7C02%7C%7C73ea3b7ecbb44f3440f208ddb753d6ab%7C84df9e7fe9f640afb435aaaaaaaaaaaa%7C1%7C0%7C638868292887467221%7CUnknown%7CTWFpbGZsb3d8eyJFbXB0eU1hcGkiOnRydWUsIlYiOiIwLjAuMDAwMCIsIlAiOiJXaW4zMiIsIkFOIjoiTWFpbCIsIldUIjoyfQ%3D%3D%7C0%7C%7C%7C&sdata=5GwkDC3JgoL7zrgg7vLZpGNZShF8%2BcFf%2BCSyuwJF7MQ%3D&reserved=0<https://youtu.be/QGrQnV2MtLs?si=HZ-jmxwH4w9VnIFG>\r\n\r\nADMINISTRATIVE\r\n\r\nThanks to Sydney for hosting the meeting last night. To briefly summarize my presentation, come to practice and run Clubs! And be sure to communicate with me by email. With Clubs in January I encourage everyone to pick a race in September to take a mini-peak for, then take a short break before gearing up for Tallahassee. Many of you will want to run either DC Half or Philly Distance Run. We'll get comps for DC Half and I will reach out to Philly on behalf of anyone who wants to make the trip. There are options for those who prefer not running a half, including Paul Short xc. Give me a shout to discuss a plan that works for you.\r\n\r\nA reminder about the GRC Travel Program--Our sponsorship with Tracksmith increases our funding available to reduce member expenses for race travel. This benefits all members, and all members traveling to races should apply. The program details and application are now available on our website -https://www.grcrunning.com/grc-travel-program/ - and listed in the dropdown menus under the Team sections. This enables members to apply any time to receive funding. Members can now apply for reimbursement for race travel that occurred after March 31. A note to expect the equivalent of partial, not full, reimbursement.\r\n\r\nLet me know if you want to run the Virginia 10 Mile on September 27 in Lynchburg. If you're looking for a beautiful course, great hospitality, and the opportunity to win some $$ and you don't mind hills this is the race for you.\r\n\r\nOne of our former athletes works for Garmin and asked if anyone is interested in a 20% discount on new products. If you want to take advantage of the offer I can make the connection.\r\n\r\nWORKOUT\r\n\r\nWe'll roll at 6:45 at St Albans so meet for the warmup at 6:00.\r\n\r\nAs you probably know the legendary Bill Dellinger died last week. In his honor I am making my own his famous saying that we need to get in shape to get in shape, and we're starting the process for the fall.\r\n\r\nThe forecast for Wednesday looks about as good as we're going to get for a bit so we'll take advantage with some longer intervals. The plan for the men is 4 x 2k, 4 x 500. We'll take 2:00 rest on the 2ks except we'll take 3:00 after the last 2k, and 1:15 after the 5s.\r\n\r\nTargets for group 1, aka Cam and friends, are 75, 74, 73, 72 on the 2ks and 69, 68, 67, 66 on the 5s.\r\n\r\nTargets for group 2 are 78, 77, 76, 75 on the 2ks and 73, 72, 71, 70 on the 5s.\r\n\r\nTargets for group 3 are 81, 80, 79, 78 on the 2ks and 76, 75, 74, 73 on the 5s.\r\n\r\nAs always we can modify this in any number of ways. Give me a shout to discuss a plan that works for you.\r\n\r\nI'll send the women's workout separately.\r\n\r\nSee you at St Albans.\r\n\r\nJerry\r\n\r\n-- \r\nYou received this message because you are subscribed to the Google Groups "Georgetown Running Club Men" group.\r\nTo unsubscribe from this group and stop receiving emails from it, send an email to GRCmen+unsubscribe@googlegroups.com.\r\nTo view this discussion visit https://groups.google.com/d/msgid/GRCmen/LV8P221MB13484B892C5DFE6C4439A5A89D41A%40LV8P221MB1348.NAMP221.PROD.OUTLOOK.COM.\r\n	2025-07-01 02:43:40	coach.jerry@live.com	grcwomen@googlegroups.com
24	wednesday workout, july 9, at st albans	RACES\r\n\r\nGina had another triumphant week in Europe. On Wednesday at the Boysen Memorial in Oslo she ran an outstanding 2:03.13 800, which is a PR and club record. Due to poor pacing by the rabbit the race became tactical, and Gina finished third in a very high quality field, and beat Laura Muir. It's not every day a GRC athlete beats an Olympic medalist! Malta nationals were next on the docket, where Gina won the 800 and 1500. On Friday Gina ran a completely solo 4:33.29 in the 1500. On Saturday, despite having zero competition in the 800 Gina give it a full send and ran an excellent 2:05.41. Gina did it the hard way, going out in 60-low, and coming back in 65. After a training block in DC Gina will return to Europe for more racing later in July. Even bigger things are coming!\r\n\r\nWe had plenty of July 4 action on the roads. At the Firecracker 5k in Reston ran Joe 15:46, followed by Sean in 15:50, Outlaw in 16:13, and Trever in 16:34. Joe and Sean worked together most of the race, and even though Joe has not run a workout since the end of track season he was able to unleash his lethal kick.\r\n\r\nSam got the win at the Autism Speaks 5k in Potomac in a solo 16:12 on a brutally hilly course.\r\n\r\nRob was second in the Hingham, MA Fourth of July Road Race in 22:41 for 4.5 miles.\r\n\r\nJim was third at the Freedom 5k in Kill Devil Hills, NC, in 16:03 on a very hot and humid day.\r\n\r\nIan was third in the Bridgton 4 on the Fourth in Maine in 20:53.\r\n\r\nTyler ran the Bandit GP in Brooklyn, which consisted of a 5k qualifier in the afternoon and a 3k final in the evening, all contested on a 1k loop with nine turns per loop. Tyler ran 16:19 for the 5k and 9:11 for the 3k, which placed him twentieth. There was a large team prize purse, and if the race is held again next year we should send a team and claim that $$.\r\n\r\nADMINISTRATIVE\r\n\r\nThe MCRRC Midsummer Night Mile is on Friday evening. If you're looking for a low key track mile this is the race for you.\r\n\r\nNow is the time to speak up to claim a comp for Annapolis 10 Mile.\r\n\r\nWe've got a strong crew for Virginia 10 Mile. Please let me know if you want in.\r\n\r\nWORKOUT\r\n\r\nWe'll roll at 6:45 at St Albans so meet for the warmup at 6:00. In the category of lessons learned, if you do your cool down off the track please put your stuff in your car first to avoid having anything get locked in the track after they close it up.\r\n\r\nI'll send the details on the workout tomorrow,\r\n\r\nJerry\r\n\r\n-- \r\nYou received this message because you are subscribed to the Google Groups "Georgetown Running Club Men" group.\r\nTo unsubscribe from this group and stop receiving emails from it, send an email to GRCmen+unsubscribe@googlegroups.com.\r\nTo view this discussion visit https://groups.google.com/d/msgid/GRCmen/LV8P221MB13486EABC34C3B17E14AE92F9D4EA%40LV8P221MB1348.NAMP221.PROD.OUTLOOK.COM.\r\n	2025-07-08 02:33:58	coach.jerry@live.com	grcwomen@googlegroups.com
25	fw: wednesday workout, july 9, at st albans	Hey guys. Sorry about the delay.\r\n\r\nIt's going to be a hot one so we'll keep the intervals relatively short.\r\n\r\nThe plan is 10 x 1k with 2:00 rest.\r\n\r\nTargets for group 1 are 2 @ 72, 2 @ 71, 2 @ 70, 2 @ 69, 2 @ 68\r\n\r\nTargets for group 2 are 2 @ 76, 2 @ 75, 2 @ 74, 2 @ 73, 2 @ 72\r\n\r\nTargets for group 3 are 2 @ 79, 2 @ 78, 2 @ 77, 2 @ 76, 2 @ 75.\r\n\r\nAs always we can modify this in any number of ways.\r\n\r\nSee you at St Albans.\r\n\r\nJerry\r\n________________________________\r\nFrom: grcmen@googlegroups.com <grcmen@googlegroups.com> on behalf of jerry alexander <coach.jerry@live.com>\r\nSent: Monday, July 7, 2025 10:33 PM\r\nTo: grcwomen <grcwomen@googlegroups.com>; grcmen <grcmen@googlegroups.com>\r\nSubject: Wednesday workout, July 9, at St Albans\r\n\r\nRACES\r\n\r\nGina had another triumphant week in Europe. On Wednesday at the Boysen Memorial in Oslo she ran an outstanding 2:03.13 800, which is a PR and club record. Due to poor pacing by the rabbit the race became tactical, and Gina finished third in a very high quality field, and beat Laura Muir. It's not every day a GRC athlete beats an Olympic medalist! Malta nationals were next on the docket, where Gina won the 800 and 1500. On Friday Gina ran a completely solo 4:33.29 in the 1500. On Saturday, despite having zero competition in the 800 Gina give it a full send and ran an excellent 2:05.41. Gina did it the hard way, going out in 60-low, and coming back in 65. After a training block in DC Gina will return to Europe for more racing later in July. Even bigger things are coming!\r\n\r\nWe had plenty of July 4 action on the roads. At the Firecracker 5k in Reston ran Joe 15:46, followed by Sean in 15:50, Outlaw in 16:13, and Trever in 16:34. Joe and Sean worked together most of the race, and even though Joe has not run a workout since the end of track season he was able to unleash his lethal kick.\r\n\r\nSam got the win at the Autism Speaks 5k in Potomac in a solo 16:12 on a brutally hilly course.\r\n\r\nRob was second in the Hingham, MA Fourth of July Road Race in 22:41 for 4.5 miles.\r\n\r\nJim was third at the Freedom 5k in Kill Devil Hills, NC, in 16:03 on a very hot and humid day.\r\n\r\nIan was third in the Bridgton 4 on the Fourth in Maine in 20:53.\r\n\r\nTyler ran the Bandit GP in Brooklyn, which consisted of a 5k qualifier in the afternoon and a 3k final in the evening, all contested on a 1k loop with nine turns per loop. Tyler ran 16:19 for the 5k and 9:11 for the 3k, which placed him twentieth. There was a large team prize purse, and if the race is held again next year we should send a team and claim that $$.\r\n\r\nADMINISTRATIVE\r\n\r\nThe MCRRC Midsummer Night Mile is on Friday evening. If you're looking for a low key track mile this is the race for you.\r\n\r\nNow is the time to speak up to claim a comp for Annapolis 10 Mile.\r\n\r\nWe've got a strong crew for Virginia 10 Mile. Please let me know if you want in.\r\n\r\nWORKOUT\r\n\r\nWe'll roll at 6:45 at St Albans so meet for the warmup at 6:00. In the category of lessons learned, if you do your cool down off the track please put your stuff in your car first to avoid having anything get locked in the track after they close it up.\r\n\r\nI'll send the details on the workout tomorrow,\r\n\r\nJerry\r\n\r\n--\r\nYou received this message because you are subscribed to the Google Groups "Georgetown Running Club Men" group.\r\nTo unsubscribe from this group and stop receiving emails from it, send an email to GRCmen+unsubscribe@googlegroups.com<mailto:GRCmen+unsubscribe@googlegroups.com>.\r\nTo view this discussion visit https://groups.google.com/d/msgid/GRCmen/LV8P221MB13486EABC34C3B17E14AE92F9D4EA%40LV8P221MB1348.NAMP221.PROD.OUTLOOK.COM<https://groups.google.com/d/msgid/GRCmen/LV8P221MB13486EABC34C3B17E14AE92F9D4EA%40LV8P221MB1348.NAMP221.PROD.OUTLOOK.COM?utm_medium=email&utm_source=footer>.\r\n\r\n-- \r\nYou received this message because you are subscribed to the Google Groups "Georgetown Running Club Men" group.\r\nTo unsubscribe from this group and stop receiving emails from it, send an email to GRCmen+unsubscribe@googlegroups.com.\r\nTo view this discussion visit https://groups.google.com/d/msgid/GRCmen/LV8P221MB1348E7E2BAC3656D8C0200DD9D4EA%40LV8P221MB1348.NAMP221.PROD.OUTLOOK.COM.\r\n	2025-07-08 12:52:23	coach.jerry@live.com	grcmen@googlegroups.com
26	wednesday workout, july 16, at bcc	RACES\r\n\r\nAutumn ran 1:00:27 at the Boilermaker 15k in Utica, NY, which is 6:30 pace. That was a good effort on a hilly course in challenging conditions only three weeks after Grandmas.\r\n\r\nPRACTICE LOCATION\r\n\r\nWe'll be at BCC for the next few Wednesdays. After getting locked out of St Albans twice in a month it makes sense to use BCC, which we know for sure will be open. When fall sports start we will no longer be welcome so at that point we'll head back to St Albans.\r\n\r\nWe'll be at BCC this Saturday. On July 26 we'll make our triumphant return to Greenbelt Lake, and we'll stay there for the foreseeable future.\r\n\r\nADMINISTRATIVE\r\n\r\nThis is the final call for VA 10 Mile. The current roster is Zach Herriott, Dylan, Campbell, Outlaw, and Jack. If you want to be included give me a shout right away.\r\n\r\nI want to submit our entry request for Philly Distance Run, as well as Philly Marathon, Half, and Rothman 8k soon. Let me know this week if you want in.\r\n\r\nThere are two comps left for Annapolis 10. Give me a shout if you want to claim one of them.\r\n\r\nAlso let me know if you want a comp for DC Half. I know we have a lot of interest. Please email me to confirm that you want to run\r\n\r\nThe NOVA 5k is on Tuesday August 19 at 6:30 pm at Bluemont Park. If you're looking for a really, really low key rustbuster on a relatively fast course this is the race for you.\r\n\r\nWORKOUT\r\n\r\nWe'll roll at BCC at 6:45 so meet for the warmup at 6:00. We may have to contend with storms again this week, and a bonus of working out at BCC is that we can wait it out safely on the level above the track.\r\n\r\nWe'll do the workout we wanted to do last week, which is 10 x 1k with 2:00 rest.\r\n\r\nTargets for group 1 are 2 @ 72, 2 @ 71, 2 @ 70, 2 @ 69, 2 @ 68.\r\n\r\nTargets for group are 2 @ 76, 2 @ 75, 2 @ 74, 2 @ 73, 2 @ 72.\r\n\r\nTargets for group 3 are 2 @ 79, 2 @ 78, 2 @ 77, 2 @ 76, 2 @ 75.\r\n\r\nAs always, we can modify this in any number of ways. Give me a shout to discuss a plan that works for you.\r\n\r\nI'll send the women's workout separately.\r\n\r\nSee you at BCC.\r\n\r\nJerry\r\n\r\n-- \r\nYou received this message because you are subscribed to the Google Groups "Georgetown Running Club Men" group.\r\nTo unsubscribe from this group and stop receiving emails from it, send an email to GRCmen+unsubscribe@googlegroups.com.\r\nTo view this discussion visit https://groups.google.com/d/msgid/GRCmen/LV8P221MB1348DDD6B63748B1807992C39D57A%40LV8P221MB1348.NAMP221.PROD.OUTLOOK.COM.\r\n	2025-07-15 01:27:47	coach.jerry@live.com	grcwomen@googlegroups.com
27	wednesday workout, july 23, at bcc	RACES\r\n\r\nSam was third in Packers 5k in Green Bay in 15:27. That was a strong performance given that Sam is just starting back up. Sam has relatives in Green Bay, and as a lifelong Packers fan it was a treat for Sam to get to finish the race in Lambeau Field. If only he had relatives in Philly he could back a winner!\r\n\r\nADMINISTRATIVE\r\n\r\nI've received a tepid response to the bodyweight strength training class that District Performance Physio will put on for us at their downtown location on Monday July 28 at 7:30 pm. This is an excellent opportunity to get a routine that will improve your performance and help you stay healthy. The class will take around 30 minutes and there will be time to ask questions afterwards. We need to provide a list of attendees to building security and space is limited. Let me know if you want to attend.\r\n\r\nThe Parks Half Marathon is on September 21 in Rockville. The course isn't fast but it's a fun race. There's a generous prize purse ($500-$350-$250-$200-$100 and $100 for masters) and the competition is minimal so it's essentially free $$. Our friends at Montgomery County RRC have provided us a limited number of comps. Let me know if you want to claim one.\r\n\r\nTime is running short to get in on our entry requests for Philly Distance Run, and Philly Marathon, Half, and Rothman 8k. Please let me know right away if you want to be included.\r\n\r\nWe're putting together a crew for DC Half. Give me a shout if you want to compete.\r\n\r\nIf you're looking a low key rustbuster consider the NOVA 5k, which is Tuesday August 19 at 6:30 pm at Bluemont Park.\r\n\r\nWORKOUT\r\n\r\nWe'll roll at 6:45 at BCC so meet for the warmup at 6:00.\r\n\r\nThe long-awaited break in the weather will allow us to do some longer reps. The plan for the men is 2 x 2400, 4 x 1200, all with 2:00 rest.\r\n\r\nTargets for group 1 are 75, 74 on the 24s, and 72, 71, 70, 69 on the 12s.\r\n\r\nTargets for group 2 are 77, 76 on the 24s, and 74, 73, 72, 71 on the 12s.\r\n\r\nTargets for group 3 are 80, 79 on the 24s, and 77, 76, 75, 74 on the 12s.\r\n\r\nAs always we can modify this in any number of ways. Give me a shout to discuss a plan that works for you.\r\n\r\nI'll send the women's workout separately.\r\n\r\nSee you at BCC.\r\n\r\nJerry\r\n\r\n\r\n\r\n\r\n-- \r\nYou received this message because you are subscribed to the Google Groups "Georgetown Running Club Men" group.\r\nTo unsubscribe from this group and stop receiving emails from it, send an email to GRCmen+unsubscribe@googlegroups.com.\r\nTo view this discussion visit https://groups.google.com/d/msgid/GRCmen/LV8P221MB1348E269A5E60BB9C70046DA9D5CA%40LV8P221MB1348.NAMP221.PROD.OUTLOOK.COM.\r\n	2025-07-22 01:31:24	coach.jerry@live.com	grcwomen@googlegroups.com
28	wednesday workout, july 30, at bcc	RACES\r\n\r\nGina had another amazing week in Europe. At the Balkan Championships in Volos, Greece, Gina finished fourth in both the 800 and 1500. The level of competition was much higher than Gina has encountered in a championship setting, and for better or worse unlike most championship racing it was not tactical. In the 800 on Saturday Gina ran an outstanding 2:02.85, which is a big PR and club record. The race got out fast, and Gina came through 400 in about 59.8. It was tight quarters from there and Gina fought tooth and nail with several of her competitors all the way to the tape to secure fourth place. The 1500 was Sunday, and the athlete who won the 800 pushed the pace from the gun. Gina came through 800 in about 2:11.5, which was well outside of her comfort zone. With 100 to go Gina was in sixth place and the tank was on empty but she found the extra gear she needed to claim fourth at the line in 4:16.62. To put those results into context, no athlete from Malta has ever won an individual medal at Balkans, and Gina was extremely close in both races. Gina got the week started with an 800 at the Austrian Open in Eisenstadt, which is a World Athletics Silver level meet, meaning she was running against world class competition. Gina held her own, running 2:04.02 after a 59 second opening lap. Thanks to the miracle of live streaming I was able to watch the race, and seeing Gina compete in a world class field in a GRC uniform was truly something special.\r\n\r\nCameron finished fourteenth in a national class field at the Bix 7 Mile in Davenport, Iowa in an excellent 33:56 on a brutally hilly course. Cam went out with the leaders and when moves started happening he found himself in no-man's land, but he was able to run as close to even pace as is possible on that rollercoaster of a course. Cam beat several full-time pros, once again proving that he can compete on the national level.\r\n\r\nGraham finished fifth in the White River 50 Miler in Washington state in 9:04. The course was in the Cascade mountains and included thousands of feet of climbing. In the second half of the race there was a 3,000 foot continuous climb during which Graham was questioning his life choices but he got through it and ran a very strong last five miles. Graham will take a few days to recover before doing the final prep for a 100 miler on September 12. We'll stage an intervention before then!\r\n\r\nADMINISTRATIVE\r\n\r\nDue to an inexplicable lack of interest we have postponed the strength training class at District Performance Physio until August 25. It will be a great opportunity to get a routine that will both improve your performance and help keep you healthy. I hope many of you will take advantage of that opportunity.\r\n\r\nWe're putting together a crew for the DC Half. Let me know if you want to join the fun.\r\n\r\nI still have comps for Parks Half Marathon. Give me a shout if you want to claim one of them.\r\n\r\nThe NOVA 5k is on Tuesday August 19 at Bluemont Park. It's as low key as a race can get and if you're looking for a rustbuster it could be a good choice.\r\n\r\nWORKOUT\r\n\r\nWe'll roll at BCC at 6:45 so meet for the warmup at 6:00.\r\n\r\nAfter a slight reprieve last week we're back to brutal heat so we'll err on the side of caution.\r\n\r\nThe plan for the men is 10 x 800 with 1:30 rest.\r\n\r\nTargets for group 1 are 2 @ 73, 2 @ 72, 2 @ 71, 2 @ 70, 2 @ 69.\r\n\r\nTargets for group 2 are 2 @ 76, 2 @ 75, 2 @ 74, 2 @ 73, 2 @ 72.\r\n\r\nTargets for group 3 are 2 @ 78, 2 @ 77, 2 @ 76, 2 @ 75, 2 @ 74.\r\n\r\nWe'll have the option of bonus 200s afterwards.\r\n\r\nI'll send the women's workout separately.\r\n\r\nSee you at BCC.\r\n\r\nJerry\r\n\r\n\r\n-- \r\nYou received this message because you are subscribed to the Google Groups "Georgetown Running Club Men" group.\r\nTo unsubscribe from this group and stop receiving emails from it, send an email to GRCmen+unsubscribe@googlegroups.com.\r\nTo view this discussion visit https://groups.google.com/d/msgid/GRCmen/LV8P221MB134848E004E4968A11A4ADC29D25A%40LV8P221MB1348.NAMP221.PROD.OUTLOOK.COM.\r\n	2025-07-29 01:32:50	coach.jerry@live.com	grcwomen@googlegroups.com
29	wednesday workout, august 6, at bcc	RACES\r\n\r\nGina continued her huge season at the Brooklyn Mile where she got the win over a high-quality field in 4:41. It was a sit and kick affair—Gina went through the half in about 2:30 and ran a huge negative split of about 2:11 for the second half, and closed in about 62.  Gina waited until the last 300 to hit the gas hard, and it was game over.\r\n\r\nAt Beach to Beacon 10k in Maine, Sydney ran a nice PR of 34:47, which puts her tenth on the GRC all-time list. Sydney was second in the mass start, and beat several pros. The performance was particularly impressive because Sydney is in her marathon build and trained through the race. Kerry ran a strong 36:39 in her first race of 2025. Kerry is also in a marathon build and this was proof that she's moving in the right direction.\r\n\r\nCharlie ran 16:52 at the St Barnabas 5k in Pittsburgh. Charlie's training has been limited by the heat so that was a solid performance.\r\n\r\nDylan ran 4:34.9 for a full mile at the CU Boulder all-comers meet, which is an altitude-adjusted 4:28. Dylan went for the win and kicked very hard but was nipped at the line. That was an impressive performance given that Dylan is very early in his cycle.\r\n\r\nADMINISTRATIVE\r\n\r\nThe new date for the strength training class at District Performance Physio is August 25. I strongly encourage you to attend. Let me know if you want to reserve one of the limited spots.\r\n\r\nWe still have comps left for Annapolis 10 Mile and Parks Half. Let me know if you're interested.\r\n\r\nAlso let me know if you want to join the crew at DC Half.\r\n\r\nWORKOUT\r\n\r\nWe'll roll at BCC at 6:45 so meet for the warmup at 6:00.\r\n\r\nWe'll take advantage of the cooler weather by doing some longer intervals. The plan for the men is 2 x 3200, 2 x 1600. We'll take 2:00 rest on all of it.\r\n\r\nTargets for group 1 are 75, 73 on the 32s, and 71, 70 on the 16s.\r\n\r\nTargets for group 2 are 77, 75 on the 32s, and 73, 72 on the 16s.\r\n\r\nTargets for group 3 are 80, 78 on the 32s, and 76, 75 on the 16s.\r\n\r\nAs always we can modify this in any number of ways. Give me a shout to discuss a plan that works for you.\r\n\r\nI'll send the women's workout separately.\r\n\r\nSee you at BCC.\r\n\r\nJerry\r\n\r\n\r\n\r\n\r\n-- \r\nYou received this message because you are subscribed to the Google Groups "Georgetown Running Club Men" group.\r\nTo unsubscribe from this group and stop receiving emails from it, send an email to GRCmen+unsubscribe@googlegroups.com.\r\nTo view this discussion visit https://groups.google.com/d/msgid/GRCmen/LV8P221MB1348A5D572BC4ED125DE61899D22A%40LV8P221MB1348.NAMP221.PROD.OUTLOOK.COM.\r\n	2025-08-05 01:19:49	coach.jerry@live.com	grcwomen@googlegroups.com
30	wednesday workout, august 13, at st albans	RACES\r\n\r\nGina finished her breakthrough track season in style by running 4:12.28 for 1500 at La Classique D'Athletisme in Montreal. That was a PR, GRC club record, Malta national record, and an A standard for the 2026 Commonwealth Games! The plan was to run a PR in the 800, but thanks to horrendous pacing by the rabbit Gina was a DNF, clearing the way for her to turn her attention to the 1500. Gina's tactics were perfect, and she finished third in a very high quality field. Gina finished the season with new PRs in the 400, 800, and 1500, and she is primed for an even better 2026. Well done!\r\n\r\nCharlie did double duty this weekend in Pittsburgh, getting the win in the Brookline Breeze 5k in 17:05, and finishing 25th in the Lake Loop 5 Mile in 28:23.\r\n\r\nADMINISTRATIVE\r\n\r\nWe need lots of help for the Pacers Half. If you're not running please volunteer.\r\nhttps://docs.google.com/spreadsheets/d/1QiSxHWa95p3Nl0Aqzgxmc5ntAguKhKYyD5Oc4Zgt42E/edit?gid=1056230274#gid=1056230274\r\n\r\nThe new date for the strength training class at District Performance Physio is August 25. I strongly encourage you to attend. Let me know if you want to reserve one of the limited spots.\r\n\r\nThe NOVA 5k is next Tuesday in Bluemont Park. It's as low key as a race can get, and would be a chill rustbuster.\r\n\r\nAnother low key 5k option is the Legacy Loop 5k Invitational on Sunday afternoon at the RFK fields. I have it on good authority that all you need to do to get invited to this prestigious event is to pay the entry fee. We have a team and all are welcome to be part of our inevitable triumph.\r\n\r\nThere are still unclaimed comps for Annapolis 10 and Parks Half. Let me know if you want in.\r\n\r\nWORKOUT\r\n\r\nWe'll roll at ST ALBANS at 6:30 so meet for the warmup at 5:45.\r\n\r\nThe plan for the men is 3 x 2k, 3 x 1k, 3 x 500, all with 2:00 rest.\r\n\r\nTargets for group 1 are 74, 73, 72 on the 2ks, 70, 69, 68 on the ks, and 66, 65, 64 on the 500s.\r\n\r\nTargets for group 2 are 76, 75, 74 on the 2ks, 72, 71, 70 on the ks, and 68, 67, 66 on the 500s.\r\n\r\nTargets for group 3 are 79, 78, 77 on the 2ks, 75, 74, 73 on the ks, and 71, 70, 69 on the 500s.\r\n\r\nAs always we can modify this in any number of ways. Give me a shout to discuss a plan that works for you.\r\n\r\nI'll send the women's workout separately.\r\n\r\nSee you at ST ALBANS.\r\n\r\nJerry\r\n\r\n\r\n\r\n\r\n-- \r\nYou received this message because you are subscribed to the Google Groups "Georgetown Running Club Men" group.\r\nTo unsubscribe from this group and stop receiving emails from it, send an email to GRCmen+unsubscribe@googlegroups.com.\r\nTo view this discussion visit https://groups.google.com/d/msgid/GRCmen/LV8P221MB13482350C83B77AB2CCE36B79D2BA%40LV8P221MB1348.NAMP221.PROD.OUTLOOK.COM.\r\n	2025-08-12 01:24:19	coach.jerry@live.com	grcwomen@googlegroups.com
31	wednesday workout, august 20 at st albans	RACES\r\n\r\nIt was GRC domination at the inaugural (and judging by the level of organization, possibly final) Chocolate City Criterium 5k. Ryan got the win in 15:02, which was a strong performance after battling a persistent illness for several weeks. Joe was second in 15:14, followed by Sam in third in 15:19, Daniel F in sixth in 15:23, and Tyler in ninth in 15:50.\r\n\r\nRob was fortieth place at Falmouth in 37:26, which is 5:21 pace. That was a solid performance for Rob at this stage of the season.\r\n\r\n\r\nADMINISTRATIVE\r\n\r\nWe need much more help for the Pacers Half. Everyone is expected to volunteer at least once a year, and I know that many of you are not racing. Please take this opportunity to meet your obligation.\r\nhttps://docs.google.com/spreadsheets/d/1QiSxHWa95p3Nl0Aqzgxmc5ntAguKhKYyD5Oc4Zgt42E/edit?gid=1056230274#gid=1056230274\r\n\r\nWe're putting together a crew for the USATF XC Championships, which is in Portland, OR on December 6. There is no better way to tune up for Clubs. I'm optimistic that we'll have a full men's team, and there is momentum on the women's side as well. Let me know if you want to compete.\r\n\r\nThe strength training class at District Performance Physio is August 25, which is a week from tonight. I strongly encourage you to attend. Let me know if you want to reserve one of the limited spots.\r\n\r\nWe still have comps for Parks Half. There's a generous prize purse for the taking.\r\n\r\nThe NOVA 5k is tomorrow night. You can sign up at the race. If you're looking for a super low key rustbuster this is the race for you.\r\n\r\nWORKOUT\r\n\r\nWe'll roll at 6:30 at St Albans so meet for the warmup at 5:45.\r\n\r\nWe'll keep it a little more chill this week. The plan for the men is 5 x 1600, 4 x 400. We'll take 1:30 rest on the 16s except that we'll take 3:00 after the last 16. We'll take 45 seconds rest on the 4s.\r\n\r\nTargets for group 1 are 74, 73, 72, 71, 70 on the 16s, and ~ 65 on the 4s.\r\n\r\nTargets for group 2 are 76, 75, 74, 73, 72 on the 16s, and ~ 67 on the 4s.\r\n\r\nTargets for group 3 are 79, 78, 77, 76, 75 on the 16s, and ~ 70 on the 4s.\r\n\r\nAs always, we can modify this in any number of ways. Give me a shout to discuss a plan that works for you.\r\n\r\nI'll send the women's workout separately.\r\n\r\nSee you at St Albans.\r\n\r\nJerry\r\n\r\n\r\n-- \r\nYou received this message because you are subscribed to the Google Groups "Georgetown Running Club Men" group.\r\nTo unsubscribe from this group and stop receiving emails from it, send an email to GRCmen+unsubscribe@googlegroups.com.\r\nTo view this discussion visit https://groups.google.com/d/msgid/GRCmen/LV8P221MB13487291FA295F9A0E94CF169D30A%40LV8P221MB1348.NAMP221.PROD.OUTLOOK.COM.\r\n	2025-08-19 01:59:11	coach.jerry@live.com	grcwomen@googlegroups.com
32	wednesday workout, august 27, at st albans	RACES\r\n\r\nFall is almost here, and the racing is picking up. Aaryn got the win at the NOVA 5k in a very nice road PR of 17:33. Aaryn looked super relaxed out there, and this is a great sign that their fitness level is high. Daniel F defended his title in an evenly paced 15:18. Daniel would earn legendary status if he can pull off the three-peat next year. Matt was second in 15:48, followed by Jason in 16:15, and Charlie in 17:08.\r\n\r\nAt Annapolis 10 Mile Jim was fifth in 55:16, which was a strong performance on the brutal hills. Whitney was twelfth overall and third master in 1:08:26, which was marathon pace. Whitney will be ready to go in Berlin!\r\n\r\nDickson finished tenth overall and was fourth alum at the Gettysburg alumni XC race. Dix ran 16:51, which is his fastest time on the course since 2015.\r\n\r\nJoe got the win in the Ditch Digger 5k in a chill 15:59. That was Joe's fifth straight win at the highly prestigious event.\r\n\r\nADMINISTRATIVE\r\n\r\nWe still need more help for the Pacers Half. If you're not racing, which many of you are not, please volunteer. It's a fun morning, and it's important that we fully staff the race.\r\nhttps://docs.google.com/spreadsheets/d/1QiSxHWa95p3Nl0Aqzgxmc5ntAguKhKYyD5Oc4Zgt42E/edit?gid=1056230274#gid=1056230274\r\n\r\nThe crew for USATF XC Championships in Portland on December 6 is coming together. We have some logistics to figure out so the sooner you let me know you want to compete the better.\r\n\r\nThis is the last call for Parks Half Marathon. Let me know right away if you want to rum.\r\n\r\nWORKOUT\r\n\r\nWe'll roll at 6:30 at St Albans so meet for the warmup at 5:45. School is back in session, and while I don't expect any problems getting on the track we need to be extra aware that we are guests, and we should go out of our way to be courteous. That includes clearing out right away when security is ready to lock up the track.\r\n\r\nThe plan for the men is 4 x 2400 with 2:00 rest.\r\n\r\nTargets for group 1 are 74, 73, 72, 71.\r\n\r\nTargets for group 2 are 76, 75, 74, 73.\r\n\r\nTargets for group 3 are 79, 78, 77, 76.\r\n\r\nAs always we can modify this in any number of ways. Give me a shout to discuss a plan that works for you.\r\n\r\nI'll send the women's workout seperately.\r\n\r\nSee you Wednesday at St Albans.\r\n\r\nJerry\r\n\r\n\r\n-- \r\nYou received this message because you are subscribed to the Google Groups "Georgetown Running Club Men" group.\r\nTo unsubscribe from this group and stop receiving emails from it, send an email to GRCmen+unsubscribe@googlegroups.com.\r\nTo view this discussion visit https://groups.google.com/d/msgid/GRCmen/LV8P221MB1348C0645F518EF24BBE22069D39A%40LV8P221MB1348.NAMP221.PROD.OUTLOOK.COM.\r\n	2025-08-26 01:38:28	coach.jerry@live.com	grcwomen@googlegroups.com
33	wednesday workout, september 3, at american university	RACES\r\n\r\nTrever ran 34:01 at the 10k Hexagone Trocadero in Paris, which was 23rd place. It was Trev's first time racing outside of the US, and he reports that he was impressed by the way Europeans run the tangents. Trev wasn't exactly rested going into it, and that was a good effort under the circumstances.\r\n\r\nTyler ran 18:37 at the Lehigh Invitational. Tyler wasn't thrilled with his performance, but it was a solid start to his xc season.\r\n\r\nMorgan made a triumphant return to RPI, finishing a strong second in the alumni xc race in 17:57 on a hilly course. Morgan is ready for her half marathon debut in two weeks.\r\n\r\nADMINISTRATIVE\r\n\r\nDC Half is less than two weeks away, and we're still short on volunteers. Please, I beseech you, if you're not running, volunteer.\r\nhttps://docs.google.com/spreadsheets/d/1QiSxHWa95p3Nl0Aqzgxmc5ntAguKhKYyD5Oc4Zgt42E/edit?gid=1056230274#gid=1056230274\r\n\r\nI'm going to send a list of fall races in the near future. Please take a look at it and let me know if you have any questions.\r\n\r\nWORKOUT\r\n\r\nWe'll roll at 6:30 at AMERICAN UNIVERSITY so meet for the warmup at 5:45. We're in for a treat—the track is brand new and by all accounts it is really nice.\r\n\r\nIt's been a minute since we've worked out at AU so this will be a new experience for many of you. The track is at the bottom of the campus, down the hill from Bender Arena. Parking is not an issue--you can park in the garage adjacent to the arena, or in a surface lot wherever you find a space.  There's a veranda next to the track where we'll meet for the warmup. It goes without saying that we're guests at AU and we need to be extremely courteous to everyone we encounter.\r\n\r\nThe plan for the men is 3200, 2400, 1600, 800, 4 x 400. We'll take 2:00 rest on all of it, except that we'll take 3:00 after the 800, and 1:00 on the 400s.\r\n\r\nTargets for group 1 are 75 on the 32, 73 on the 24, 71 on the 16, 69 on the 8, and 67, 66, 65, 64 on the 4s.\r\n\r\nTargets for group 2 are 77 on the 32, 75 on the 24, 73 on the 16, 71 on the 8, and 69, 68, 67, 66 on the 4s.\r\n\r\nTargets for group 3 are 80 on the 32, 78 on the 24, 76 on the 16, 74 on the 8, and 72, 71, 70, 69 o the 4s.\r\n\r\nAs always we can modify this in any number of ways. Give me a shout to discuss a plan that works for you.\r\n\r\nI'll send the women's workout separately.\r\n\r\nSee you at AMERICAN.\r\n\r\nJerry\r\n\r\n-- \r\nYou received this message because you are subscribed to the Google Groups "Georgetown Running Club Men" group.\r\nTo unsubscribe from this group and stop receiving emails from it, send an email to GRCmen+unsubscribe@googlegroups.com.\r\nTo view this discussion visit https://groups.google.com/d/msgid/GRCmen/LV8P221MB134800E8103A6094C13EA0D09D06A%40LV8P221MB1348.NAMP221.PROD.OUTLOOK.COM.\r\n	2025-09-02 01:39:26	coach.jerry@live.com	grcwomen@googlegroups.com
34	wednesday workout, september 10, at american university	RACES\r\n\r\nRyan defended his title at the 9-11 Memorial 5k in Arlington in 14:38. The course was short thanks to the proverbial misplaced cone, but Ryan will take the win.\r\n\r\nADMINISTRATIVE\r\n\r\nThe spreadsheet is up for Clubs XC. We have logistics issues to deal with, and the sooner we know who plans to compete the better.\r\n03A6094C13EA0D09D06A%40LV8P221MB1348.NAMP221.PROD.OUTLOOK.COM<https://groups.google.com/d/msgid/GRCmen/LV8P221MB134800E8103A6094C13EA0D09D06A%40LV8P221MB1348.NAMP221.PROD.OUTLOOK.COM?utm_medium=email&utm_source=footer>.\r\n\r\nLet me know if you want to run Gettysburg XC. We're putting together crews of sufficient vigor to claw our way to victory over the always high quality field.\r\n\r\nAlso let me know if you want to run USATF XC in Portland.\r\n\r\nWORKOUT\r\n\r\nWe'll roll at 6:30 at AMERICAN UNIVERSITY so meet for the warmup at 5:45. The track entrance is accessible by going behind the volleyball courts.\r\n\r\nThe unfortunate events at Greenbelt on Saturday amply illustrate the point that it is imperative that we treat everyone whom we encounter anywhere we work out with respect and courtesy. We are guests everywhere we practice, and it doesn't take much to wear out our welcome.\r\n\r\nThere are a lot of moving parts this week. Men, the plan for those who are not running DC Half or are running it as a workout is 5 x 2k with 2:00 rest.\r\n\r\nTargets for group 1 are 75, 74, 73, 72, 71.\r\n\r\nTargets for group 2 are 77, 76, 75, 74, 73.\r\n\r\nTargets for group 3 are 79, 78, 77, 76, 75.\r\n\r\nThose of you who are going full send at DC Half and taking a break after can do a 1600 hard warm up with the group of your choosing, then 8 x 600 w/ 2:00 rest. We can call the generic targets  2 @ 75, 2 @ 74, 2 @ 73, 2 @ 72, but that's flexible. The idea is to get a little turnover but not to go particularly hard.\r\n\r\nAs always, we can modify this in any number of ways. Give me a shout to discuss a plan that works for you.\r\n\r\nI'll send the women's workout separately.\r\n\r\nSee you at American.\r\n\r\nJerry\r\n\r\n\r\n\r\n\r\n-- \r\nYou received this message because you are subscribed to the Google Groups "Georgetown Running Club Men" group.\r\nTo unsubscribe from this group and stop receiving emails from it, send an email to GRCmen+unsubscribe@googlegroups.com.\r\nTo view this discussion visit https://groups.google.com/d/msgid/GRCmen/IA2P221MB1373BD7F5D8824F1B59C980D9D0FA%40IA2P221MB1373.NAMP221.PROD.OUTLOOK.COM.\r\n	2025-09-09 00:43:38	coach.jerry@live.com	grcwomen@googlegroups.com
35	wednesday workout, september 17, at st albans	RACES\r\n\r\nIt was a good bit warmer than we would have liked at DC Half but we had some excellent performances nevertheless. Morgan got the win in her half debut in 1:17:43. Morgan was well within herself, and proved that she has a promising future on the roads. Caroline was third in a huge PR of 1:19:23. Caroline is in great shape, and she will have a major breakthrough in the full marathon in October. Alex had a rough day at the office, running 1:20:28. Alex is in much better shape than that, and she will be ready to go at Indy. Emily K struggled with the heat but ran a solid 1:20:55. It won't take much convincing to get Emily to turn her focus to the shorter distances going forward.\r\n\r\nOn the men's side, Campbell was fourth in a big PR of 1:08:11. While Campbell is fit to run much faster than that he was justifiably pleased with the PR. Patrick was fifth in a solid 1:08:34. Sam made an impressive half debut in 1:10:24. Jim ran 1:11:56, followed by Ian in 1:12:17, Jason in an evenly paced 1:12:26, Sean in 1:12:52, Connor in 1:13:17, and Trever in 1:14:25.\r\n\r\nIn the 5k, Belaynesh Tsegaye made a triumphant GRC debut, getting the win in 17:38. That was her first ever 5k so it's technically a PR (though she has run much faster en route). Belaynesh has made remarkable progress in the last few months, and she will continue the long road back to full fitness. Gabi was second in 17:41, which was unquestionably her best performance since college. Gabi is also making major strides towards regaining full fitness.\r\n\r\nOn the men's side, Daniel A got the win in a solo 15:59. Daniel went right to the front and led for literally every step of the race. Charlie was second in 17:27.\r\n\r\nAt the Run Rabbit Run 100 Mile in Steamboat Springs, CO, Graham was fifth in the non-professional field in 22:53, which was a good bit faster than his goal. The race was contested in the mountains of Routt National Forest and included many technical sections. The race is not for the faint of heart—Graham reports that at 4:00 am he had a near close encounter with a bear. Graham is going to take a well-earned break before deciding what comes next. For his sake I hope he sticks to the short stuff for a while, like the marathon.\r\n\r\nADMINISTRATIVE\r\n\r\nThanks to all who volunteered at DC Half. Those of you who have not fulfilled your volunteer commitment will have your chance at Pacers Jingle All the Way 5k.\r\n\r\nWe're putting together a very strong crew for Clubs XC. Please indicate your intent to compete on the spreadsheet.\r\nhttps://docs.google.com/spreadsheets/d/1pxaIf8O4lgiNNgsMixU1zu6bPoqF6mDmr-DCHpZSu0U/edit?gid=2062633673#gid=2062633673\r\n\r\nIt's not too late to get on board for Gettysburg XC. Let me know if you want to compete.\r\n\r\nWORKOUT\r\n\r\nWe'll roll at ST ALBANS at 6:30 so meet for the warmup at 5:45.\r\n\r\nThe plan for the men is 10 x 1k with 1:30 rest.\r\n\r\nTargets for group 1 are 2 @ 73, 2 @ 72, 2 @ 71, 2 @ 70, 2 @ 69.\r\n\r\nTargets for group 2 are 2 @ 75, 2 @ 74, 2 @ 73, 2 @ 72, 2 @ 71.\r\n\r\nTargets for group 3 are 2 @ 78, 2 @ 77, 2 @ 76, 2 @ 75, 2 @ 74.\r\n\r\nAs always we can modify this in any number of ways. Give me a shout to discuss a plan that works for you.\r\n\r\nI'll send the women's workout separately.\r\n\r\nSee you at ST ALBANS.\r\n\r\nJerry\r\n\r\n-- \r\nYou received this message because you are subscribed to the Google Groups "Georgetown Running Club Men" group.\r\nTo unsubscribe from this group and stop receiving emails from it, send an email to GRCmen+unsubscribe@googlegroups.com.\r\nTo view this discussion visit https://groups.google.com/d/msgid/GRCmen/IA2P221MB1373AB3A5530770823B549D49D14A%40IA2P221MB1373.NAMP221.PROD.OUTLOOK.COM.\r\n	2025-09-16 01:56:50	coach.jerry@live.com	grcwomen@googlegroups.com
36	wednesday workout, september 24, at american university	RACES\r\n\r\nOur Berlin crew bitterly proved the old adage that the marathon is a cruel event. The ladies prepared incredibly well and were ready for special performances across the board, but the weather made it impossible for them to perform to the level of their fitness. It was hot, really hot, so much so that our crew reported seeing runners literally dropping from the heat throughout the race. It's a tough pill to swallow when months of hard work doesn't pay off due to circumstances beyond our control. The only guarantee in the marathon is that if you don't do the work the results will not come. Unfortunately the inverse is not true, as the ladies most definitely did the work, and then some.\r\n\r\nAs sad as I am that the gang was prevented from showing what they can do, I'm even more proud of how hard they fought out there and the way they represented GRC in extremely trying circumstances. Despite the conditions they gave it everything they had and made the best of a bad situation. Sydney ran 2:50:29, and as I told her this was what we call in the legal business a delayed victory. She was absolutely ready to get an OTQ, and I'm fully confident it will happen the next time out. Elena B ran 2:51:02, which was a really solid performance. Mckenna ran 2:53:55, which was a small PR. That she was able to PR in such atrocious conditions is a testament to her fitness level, and she will have a major breakthrough the next time out. Erin M ran 3:04:46, and reports that it was all she could do to resist the siren song of dropping out. Erin managed to cross the line upright, and is very glad that she did. The major breakthrough Erin trained so hard for is coming.  Whitney ran 3:08:35, and she reports that of the 5 majors she has completed this was her favorite, and fastest. Whitney ran close to even pace throughout and moved up significantly in the second half.\r\n\r\nIn Erin's race report she summed up the camaraderie of the crew in a way that was so moving to me that I wanted to share it with the team. "Truly, this group of women and team make it worth it. To say that I did this alongside such close friends that I have made through this community, who support each other in wins and tough times, is the biggest success of the day. I don’t regret a second of this build/race and that’s exclusively due to this group!!!"\r\n\r\nOn the men's side, JLP ran 2:42:09. JLP was in PR shape, and he too suffered in the heat. JLP reported that he was not having fun after 18 miles. Who says there are no honest men left in DC!\r\n\r\nWe had some really good performances closer to home. At the Philadelphia Distance Run, Linnaea ran a big PR of 1:16:47, which puts her tenth on the GRC all-time list. This was Linnaea's first race in a year, and she killed it. Much more is coming this fall. Aaryn ran a very nice PR of 1:17:42 and finished third in a very competitive NB field. Aaryn has overcome numerous hurdles this fall, and they will be ready for a major PR in Chicago.\r\n\r\nDaniel F made a successful half debut, getting the win at Parks Half in 1:11:01. Parks is a slow course, and that was a really solid run from a miler. With the excellent strength base Daniel has built he'll be ready for a big track season.\r\n\r\nBelaynesh got the win at the Kensington 8k in 27:53, which puts her sixth on the GRC list. Belaynesh is a world-class talent, and as she continues to get back in shape we're going to see great things from her. Ben got the win in an impressive 24:27, and Sam was third in 25:30, which was the same time he ran last year, but this year he ran a hard half six days earlier.\r\n\r\nGina got the win at the Foundry Mile in Michigan in 4:52. That was an excellent run given that Gina took a full two weeks off after she finished her season in August, and she's just getting started.\r\n\r\nADMINISTRATIVE\r\n\r\nWe're getting the band back together for Clubs XC. Please indicate your intent to compete on the spreadsheet.\r\nhttps://docs.google.com/spreadsheets/d/1pxaIf8O4lgiNNgsMixU1zu6bPoqF6mDmr-DCHpZSu0U/edit?gid=2062633673#gid=2062633673\r\n\r\nWe're losing light alarmingly quickly, which means two things for Wednesday workouts: 1) we need to start practice earlier; and 2) our options for locations will soon become limited to facilities with sufficient ambient light. Please pay close attention to the Monday emails for times and locations.\r\n\r\nWORKOUT\r\n\r\nWe'll roll at 6:15 at AMERICAN UNIVERSITY so meet for the warmup at 5:30.\r\n\r\nThe plan for the men is 2 x 3200, 2 sets of 4 x 400. We'll take 2:00 rest between the 32s, 3:00 before we start the 4s, 45 seconds in the sets of 400s, ad 3:00 between sets.\r\n\r\nTargets for group 1 are 75, 73 on the 32s, and 68 on set 1 of the 4s and 66 on set 2.\r\n\r\nTargets for group 2 are 77, 75 on the 32s, and 70 on set 1 of the 4s, and 68 on set 2.\r\n\r\nTargets for group 3 are 80, 78 on the 32s, and 72 on the set 1 of the 4s, and 70 on set 2.\r\n\r\nAs always we can modify this in any number of ways. Give me a shout to discuss a plan that works for you.\r\n\r\nI'll send the women's workout separately.\r\n\r\nSee you at AMERICAN.\r\n\r\nJerry\r\n\r\n\r\n\r\n\r\n-- \r\nYou received this message because you are subscribed to the Google Groups "Georgetown Running Club Men" group.\r\nTo unsubscribe from this group and stop receiving emails from it, send an email to GRCmen+unsubscribe@googlegroups.com.\r\nTo view this discussion visit https://groups.google.com/d/msgid/GRCmen/IA2P221MB1373071B70D54AAC48235D239D1DA%40IA2P221MB1373.NAMP221.PROD.OUTLOOK.COM.\r\n	2025-09-23 01:45:41	coach.jerry@live.com	grcwomen@googlegroups.com
37	wednesday workout, october 1, at bcc	RACES\r\n\r\nCampbell was an excellent 11th place in an international field at the Virginia 10 Miler in Lynchburg, running 51:59 on the brutally hilly course. As if the hills weren't challenging enough it was pouring rain for the second half of the race. While it's hard to come up with a conversion for the course it is clear that Campbell ran really, really well. Keith made a successful 10 mile debut, placing 13th in 53:09. Keith has a big future on the roads. Dylan was 19th in 55:39 and met his goal of finishing in the top 20. Outlaw was 21st in 56:03, and thoroughly enjoyed the experience.\r\n\r\nRyan was second at Run Geek Run 5k in 14:46. Ryan has a lot more in the tank and we'll see some strong performances from him this season. Ben was third in 15:36, and Tyler was fourth in 15:55 in a tempo effort.\r\n\r\nIt was a GRC sweep in the Dulles 5k. Joe got the win in a solo 15:31, and Gina got the win in 17:29.\r\n\r\nADMINISTRATIVE\r\n\r\nWe're gaining momentum for Clubs. Sign up on the spreadsheet to be part of the winning team!\r\nhttps://docs.google.com/spreadsheets/d/1pxaIf8O4lgiNNgsMixU1zu6bPoqF6mDmr-DCHpZSu0U/edit?gid=2062633673#gid=2062633673\r\n\r\nEveryone who runs Clubs needs an active USATF membership, with GRC as your affiliation. There's no need to take action yet. When the time comes I'll walk you through the process, which by USATF standards is reasonably user-friendly.\r\n\r\nPlease continue to pay close attention to the Monday emails about time and location of workouts. We'll be moving around a fair amount the next few weeks.\r\n\r\nWORKOUT\r\n\r\nWe'll roll at BCC at 6:30 so meet for the warmup at 5:45.\r\n\r\nThe plan for the men is 2 x 2400, 4 x 1200, all with 2:00 rest.\r\n\r\nTargets for group 1 are 74, 72 on the 24s, and 2 @ 70, 2 @ 69 on the 12s.\r\n\r\nTargets for group 2 are 76, 74 on the 24s, and 2 @ 72, 2 @ 71 on the 12s.\r\n\r\nTargets for group 3 are 79, 77 on the 24s, and 2 @ 75, 2 @ 74 on the 12s.\r\n\r\nAs always we can modify this in any number of ways. Give me a shout to discuss a plan that works for you.\r\n\r\nI'll send the women's workout separately.\r\n\r\nSee you at BCC.\r\n\r\nJerry\r\n\r\n-- \r\nYou received this message because you are subscribed to the Google Groups "Georgetown Running Club Men" group.\r\nTo unsubscribe from this group and stop receiving emails from it, send an email to GRCmen+unsubscribe@googlegroups.com.\r\nTo view this discussion visit https://groups.google.com/d/msgid/GRCmen/IA2P221MB13739CFDB835B0E9813242C69D1AA%40IA2P221MB1373.NAMP221.PROD.OUTLOOK.COM.\r\n	2025-09-30 01:13:30	coach.jerry@live.com	grcwomen@googlegroups.com
38	wednesday workout, october 8, at american university	RACES\r\n\r\nWe got a good start on XC season in the open race at Paul Short. Seth and Tyler made triumphant returns to Lehigh, with Seth finishing in 24th place in 24:39 which is just off his college PR, and Tyler finishing 26th in 24:42 which was 20 seconds faster than he ran last year. Evan was next in 25:25, followed by Rob Mirabello, who made his GRC debut in a huge PR of 25:45, Jason in 25:54, and Kendall, in his first race in a minute, in 26:04.\r\n\r\nIn Rob's race report he reflected on how a fresh mental approach helped him to run the best XC race of his life.\r\n\r\nThe nature of GRC takes off a lot of the pressure of racing. I ran this race because I wanted to, not because it was a requirement on my team's calendar. There was nothing riding on my result; if I did poorly, I wouldn't be relegated to the non-varsity squad or moved back to a slower workout group. Rather, I was on the start line because I wanted to be, and because I wanted to test myself and my capabilities. Thanks to these reasons, during the race I felt more free than I ever have in a cross race.\r\n\r\nWell said, young fella!\r\n\r\nADMINISTRATIVE\r\n\r\nOn the topic of XC, please sign up on the spreadsheet for Clubs!\r\nhttps://docs.google.com/spreadsheets/d/1pxaIf8O4lgiNNgsMixU1zu6bPoqF6mDmr-DCHpZSu0U/edit?gid=0#gid=0\r\n\r\nArmy 10 is not going to happen if the shutdown isn't resolved by Wednesday so it's time to consider Plan B. One possible alternative is Gettysburg XC. Entries are still open so I can add athletes to our roster. Give me a shout if you want in.\r\n\r\nAnother alternative to Army is the half or 10k at the Baltimore Running Festival. The bad news is that comps are not available, and the entry fees are steep.\r\n\r\nWORKOUT\r\n\r\nWe'll roll at AMERICAN UNIVERSITY at 6:15 so meet for the warmup at 5:30.\r\n\r\nThe plan for the men is a little complicated, so bear with me. We'll do 8 x 1200, which we'll break into two sets of 4. We'll take 1:30 rest on set 1, and 3:00 between sets. The second set will be a pace shift, where we'll hit the target for 800, go right into a 200 float, and we'll hit the gas the last 200. We'll take 2:00 rest in the set.\r\n\r\nTargets for group 1 are 2 @ 72, 2 @ 70 on set 1. On set 2, the targets through 800 are 2 @ 69, 2 @ 68. The 200 float is ~ 42, and the last 200 is ~ 32.\r\n\r\nTargets for group 2 are 2 @ 74, 2 @ 72 on set 1. On set 2, the targets through 800 are 2 @ 71, 2 @ 70, The 200 float is ~ 43, and the last 200 is ~ 32.\r\n\r\nTargets for group 3 are 2 @ 77, 2 @ 75 on set 1. On set 2, the targets through 800 are 2 @ 74, 2 @ 73. The 200 float is ~ 44, and the last 200 is ~ 33.\r\n\r\nWe can modify this in any number of ways. Give me a shout to discuss a plan that works for you.\r\n\r\nI'll send the women's workout separately.\r\n\r\nSee you at AMERICAN.\r\n\r\nJerry\r\n\r\n\r\n\r\n\r\n-- \r\nYou received this message because you are subscribed to the Google Groups "Georgetown Running Club Men" group.\r\nTo unsubscribe from this group and stop receiving emails from it, send an email to GRCmen+unsubscribe@googlegroups.com.\r\nTo view this discussion visit https://groups.google.com/d/msgid/GRCmen/IA2P221MB13730F0B319048CBC525DC209DE0A%40IA2P221MB1373.NAMP221.PROD.OUTLOOK.COM.\r\n	2025-10-07 01:13:00	coach.jerry@live.com	grcwomen@googlegroups.com
39	wednesday workout, october 15, at washington liberty hs	RACES\r\n\r\nAaryn killed it at the Chicago Marathon, running a huge PR of 2:46:46, and placing third in a very competitive NB field. To paraphrase Aaryn, placing third in a World Marathon Major is pretty good, right! Aaryn overcame a litany of health issues in the buildup to the race, so much so that their participation was in doubt two weeks ago. Despite those obstacles Aaryn ran with confidence and kept the pace even for 23 miles. Aaryn had a bit of an issue with the heat the last couple of miles but they held on for a fantastic performance. I'm super proud of Aaryn—this breakthrough was a long time coming, and hard earned. Well done!\r\n\r\nTerry went into Chicago with the singular goal of qualifying for the Olympic Trials, and he went for it. Terry was rolling through 25k but he rode the struggle bus from there, finishing in 2:28:38. Terry knew that there was a good chance that the early pace would be unsustainable and he would pay a steep price later in the race but he was committed to the mission and rolled the dice. It takes a lot of courage to lay it on the line like that, and Terry came away from the race knowing that he hadn't cheated himself, and had done the very best he could.\r\n\r\nMuch to our collective surprise, Army 10 went off without a hitch. It's hard to prepare mentally for a race on Sunday when you thought on Thursday it would be canceled but we had some solid performances nevertheless. Campbell finished twelfth in 52:10, followed by Stuart in 52:53, Ian in 53:10, Daniel A in 54:49, Rob in 55:29, and Trever in 56:26. On the women's side, Autumn went into the race expecting to run a workout but when the gun went off she felt good and ran steady 6:05 pace to finish in 1:00:43, with plentyof gas left in the tank. Jackie surpassed her goal by finishing in 1:11:01, and she cut it down the last 3 miles and felt good doing it.\r\n\r\nBelaynesh's winning streak came to an end at the Great African Run 5k, and it took a world class athlete to do it. Belaynesh finished second to a 2:18 marathoner, and her 17:24 was another step on the long road back towards full fitness.\r\n\r\nADMINISTRATIVE\r\n\r\nPlease sign up on the spreadsheet for Clubs. We're putting together the winning teams and you want to be part of it.\r\nhttps://docs.google.com/spreadsheets/d/1pxaIf8O4lgiNNgsMixU1zu6bPoqF6mDmr-DCHpZSu0U/edit?gid=0#gid=0\r\n\r\nOur options on Wednesday nights are limited for now—it's too dark to use St Albans and American, so that leaves us with Washington-Liberty HS and the Mall. We want to avoid the Mall if at all possible, though it's inevitable we'll be down there at some point soon. Once fall sports are over we'll be good to return to BCC, but for now we'll make do with the venues that are available.\r\n\r\nWORKOUT\r\n\r\nWe'll roll at WASHINGTON LIBERTY HS at 6:45 so meet for the warmup at 6:00. For those who haven't had the pleasure, WL is a nice facility, but it can get crowded with neighborhood users who have as much right to be there as we do. Please be courteous.\r\n\r\nThe plan for the men is 3 x 2k, 4 x 1k, all with 2:00 rest.\r\n\r\nTargets for group 1 are 74, 73, 72 on the 2ks, and 70, 69, 68, 67 on the 1ks.\r\n\r\nTargets for group 2 are 76, 75, 74 on the 2ks, and 72, 71, 70, 69 on the 1ks.\r\n\r\nTargets for group 3 are 79, 78, 77 on the 2ks, and 75, 74, 73, 72 on the 1ks.\r\n\r\nAs always we can modify this in any number of ways. Give me a shout to discuss a plan that works for you.\r\n\r\nI'll send the women's workout separately.\r\n\r\nSee you at WASHINGTON LIBERTY.\r\n\r\nJerry\r\n\r\n\r\n\r\n\r\n\r\n-- \r\nYou received this message because you are subscribed to the Google Groups "Georgetown Running Club Men" group.\r\nTo unsubscribe from this group and stop receiving emails from it, send an email to GRCmen+unsubscribe@googlegroups.com.\r\nTo view this discussion visit https://groups.google.com/d/msgid/GRCmen/IA2P221MB1373F01886FBF3CCEBF5396E9DEBA%40IA2P221MB1373.NAMP221.PROD.OUTLOOK.COM.\r\n	2025-10-14 00:50:34	coach.jerry@live.com	grcwomen@googlegroups.com
40	wednesday workout, october 22, at washington liberty hs	RACES\r\n\r\nGwen Parks made a triumphant GRC debut by getting the win at Gettysburg XC in 21:23. Gwen took the lead at around 4k rather than sit and kick (which she surely could have done) and was unchallenged to the tape. That Gwen is confident enough to push the pace in a xc race is a testament to her fitness heading into track season. This will not be the last time that Gwen breaks the tape in a GRC kit! Gabi was fourth in a very strong 21:55. Every time Gabi has raced this fall it has been her best performance in a GRC uniform, and that trend will continue. Erin F was sixth in a massive 6k PR of 22:05. This was Erin's first race since Gettysburg last year, and after months of dealing with persistent back issues it was great to see Erin back, better than ever! Franny Kabana made a successful GRC debut by finishing twenty-first in 22:34. Franny is going to be a major contributor to our track crew.\r\n\r\nOn the men's side, Keith ran an excellent 24:11, which was 20 seconds faster than his course record. The bad news is that he came in second. Keith's sole focus will now be to reclaim his lost glory in 2026. This sport is all about setting big goals, and there's no loftier achievement than Gettysburg course record holder! Tyler, who like Keith is gearing up for a big race at Clubs, was eighth in 25:00.9, followed by Joe in a strong 25:12. Joe is very good shape for this point in his cycle, and he'll be ready to roll indoors. Rob M continued to impress with his 25:51, followed by Daniel F in 25:59, and Sam in 26:04.\r\n\r\nRyan got the win at the Race For Every Child 5k in 14:49, which was his fiftieth road 5k victory. Ryan will spend the next few weeks responding to the avalanche of interview requests from the national media outlets clamoring for an opportunity to cover a story of this magnitude. Matt was third in a solid 15:29.\r\n\r\nRich was fourth, and third in his age group, at the USATF Masters Road 5k Championship in Atlanta in 17:15. Winning a medal at a USATF champs is a noteworthy accomplishment, and it is a great sign of the progress Rich has made in the last few months.  Rich wasn't thrilled with the time but the course was hilly and the conditions were rough so we'll take it.\r\n\r\nADMINISTRATIVE\r\n\r\nTo fill in the gap in our race calendar from now until St Ritas and Richmond we're putting together a crew for the Rockville 5k/10k, which is on Sunday November 2. The race is nothing special but if we bring our own competition we'll be able to get in a hard effort. I'm looking into the possibility of some comps.\r\nhttps://runsignup.com/Race/MD/Rockville/Rockville10K5K\r\n\r\nPlease sign up on the spreadsheet for Clubs. We're putting together the winning teams and you want to be part of it.\r\nhttps://docs.google.com/spreadsheets/d/1pxaIf8O4lgiNNgsMixU1zu6bPoqF6mDmr-DCHpZSu0U/edit?gid=0#gid=0\r\n\r\nWORKOUT\r\n\r\nWe'll roll at 6:45 at WASHINGTON LIBERTY HS so meet for the warmup at 6:00.\r\n\r\nThe plan for the men is a ladder of 3200, 2400, 1600, 800, 4 x 400. We'll take 2:00 rest on all of it except that we'll take 1:00 rest on the 4s.\r\n\r\nTargets for group 1 are 74 on the 32, 72 on the 24, 70 on the 16, 68 on the 8, and 2 @ 66, 2 @ 64 on the 4s.\r\n\r\nTargets for group 2 are 76 on the 32, 74 on the 24, 72 on the 16, 70 on the 8, and 2 @ 68, 2 @ 66 on the 4s.\r\n\r\nTargets for group 3 are 79 on the 32, 77 on the 24, 75 on the 16, 73 on the 8, and 2 @ 70, 2 @ 68 on the 4s.\r\n\r\nAs always we can modify this in any number of ways. Give me a shout to discuss a plan that works for you.\r\n\r\nI'll send the women's workout separately.\r\n\r\nSee you at Washington Liberty.\r\n\r\nJerry\r\n\r\n-- \r\nYou received this message because you are subscribed to the Google Groups "Georgetown Running Club Men" group.\r\nTo unsubscribe from this group and stop receiving emails from it, send an email to GRCmen+unsubscribe@googlegroups.com.\r\nTo view this discussion visit https://groups.google.com/d/msgid/GRCmen/IA2P221MB1373F141BA703C59B00E22629DF2A%40IA2P221MB1373.NAMP221.PROD.OUTLOOK.COM.\r\n	2025-10-21 01:30:08	coach.jerry@live.com	grcmen@googlegroups.com
41	wednesday workout, october 29, on the mall	RACES\r\n\r\nPatrick finished eleventh at the Marine Corps Marathon in a very strong 2:27:48. That time, which is impressive on the slow course at MCM, exceeded Pat's expectations. Pat ran pretty much even pace, even though he was solo for the last 10 miles. Pat will shut it down for the season, and he'll return better than ever in the spring.\r\n\r\nJim got the win at the Port to Fort 6k (which ended up being 5k due to the shutdown) in Baltimore in a solo 15:30.\r\n\r\nADMINISTRATIVE\r\n\r\nI sent the discount code to those on the list for Rockville 5k/10k, which is on Sunday. If you want to run and you didn't get the code give me a shout.\r\n\r\nI also sent the comp code for the Alexandria Turkey Trot to those on my list. Let me know if you want in.\r\n\r\nSign up on the spreadsheet if you want to run Clubs.\r\nhttps://docs.google.com/spreadsheets/d/1pxaIf8O4lgiNNgsMixU1zu6bPoqF6mDmr-DCHpZSu0U/edit?gid=0#gid=0\r\n\r\nWORKOUT\r\n\r\nWe're ON THE MALL for a 6:15 start so meet for the warmup at 5:30. The early start will allow us to get the warmup in before dark.\r\n\r\nFor those who have not had the pleasure of a Mall workout, we use the inner loop of the mall between 4th and 7th Streets, which is darn close to 800 meters. The meeting spot is on 7th Street, just south of Madison Drive. It's easily metro accessible, and there's plenty of parking on the street. You would be well-advised to take metro if that's an option for you as the traffic around the mall can be rough. If you get turned around text me at 240 483 8137.\r\n\r\nThe plan for the men is 3 sets of 2400-800. We'll take 1:00 after the 24s, and 3:00 after the 8s.\r\n\r\nTargets for group 1 on set 1 are 74 on the 24 and 70 on the 8, 72/68 on set 2, and 70/66 on set 3.\r\n\r\nTargets for group 2 on set 1 are 76 on the 24 and 72 on the 8, 74/70 on set 2, and 72/68 on set 3.\r\n\r\nTargets for group 3 on set 1 are 78 on the 24 and 74 on the 8, 76/72 on set 2, and 74/70 on set 3.\r\n\r\nAs always we can modify this in any number of ways. Give me a shout to discuss a plan that works for you.\r\n\r\nI'll send the women's workout separately.\r\n\r\nSee you ON THE MALL.\r\n\r\nJerry\r\n\r\n\r\n-- \r\nYou received this message because you are subscribed to the Google Groups "Georgetown Running Club Men" group.\r\nTo unsubscribe from this group and stop receiving emails from it, send an email to GRCmen+unsubscribe@googlegroups.com.\r\nTo view this discussion visit https://groups.google.com/d/msgid/GRCmen/IA2P221MB1373E5068A37738A459C2A5B9DFDA%40IA2P221MB1373.NAMP221.PROD.OUTLOOK.COM.\r\n	2025-10-28 01:20:33	coach.jerry@live.com	grcmen@googlegroups.com
42	wednesday workout, november 5, at washington liberty hs	RACES\r\n\r\nJackie had a gutsy performance in the New York Marathon, finishing in 3:26:02. Jackie was on goal pace until 15 miles, but at that point it started going south. Jackie reports that at mile 16 the goal went from running fast to not walking, and she was able to accomplish that objective. Jackie was justifiably proud of the effort, which she called the most painful thing she has ever done!\r\n\r\nAt the Rockville 5k, Keith got the win in a solo 15:29 on a hilly course, and Rob M was second in 16:22. On the women's side, Franny got the win in a strong 18:22. In the Rockville 10k, Belaynesh got the win in 35:41, which was an impressive performance on that course. Whitney ran 40:14 as she begins her return to action after Berlin. On the men's side, Daniel A finished second in a nice PR of 32:41.\r\n\r\nDickson got the win in Long Branch 5k in 17:46 and held off the charge from the local teenagers. Dix is recovering from an illness and will be back to full fitness soon.\r\n\r\nADMINISTRATIVE\r\n\r\nI know that there are some among us who plan to run Clubs but haven't indicated their intent on the spreadsheet. If you fall into that category please rectify your oversight.\r\nhttps://docs.google.com/spreadsheets/d/1pxaIf8O4lgiNNgsMixU1zu6bPoqF6mDmr-DCHpZSu0U/edit?gid=0#gid=0\r\n\r\nNow that we're in November it's time to renew or establish your USATF membership. I will send an email walking through the process in the next day or two.\r\n\r\nLet me know if you want the comp code for the Alexandria turkey trot.\r\n\r\nWORKOUT\r\n\r\nWe'll roll at 6:45 at WASHNGTON LIBERTY HS, so meet for the warmup at 6:00.\r\n\r\nThe plan for the men is 6 x 1600 with 2:00 rest.\r\n\r\nTargets for group 1 are 2 @ 73, 2 @ 71, 2 @ 69.\r\n\r\nTargets for group 2 are 2 @ 75, 2 @ 73, 2 @ 71.\r\n\r\nTargets for group 3 are 2 @ 78, 2 @ 76, 2 @ 74.\r\n\r\nAs always we can modify this in any number of ways. Give me a shout to discuss a plan that works for you.\r\n\r\nI'll send the women's workout separately.\r\n\r\nSee you at WASHINGTON LIBERTY.\r\n\r\nJerry\r\n\r\n\r\n\r\n\r\n\r\n\r\n-- \r\nYou received this message because you are subscribed to the Google Groups "Georgetown Running Club Men" group.\r\nTo unsubscribe from this group and stop receiving emails from it, send an email to GRCmen+unsubscribe@googlegroups.com.\r\nTo view this discussion visit https://groups.google.com/d/msgid/GRCmen/IA2P221MB1373594E680EF36F8F0036749DC4A%40IA2P221MB1373.NAMP221.PROD.OUTLOOK.COM.\r\n	2025-11-04 02:53:53	coach.jerry@live.com	grcwomen@googlegroups.com
43	wednesday workout, november 12, at bcc	RACES\r\n\r\nIn the Indianapolis Marathon Alex ran 2:42:38, which was a few seconds off her PR. Alex was fit to give the OTQ a real shot and she went for it, coming through the half exactly on pace. Alex was rolling through about 17 miles but at that point it started going the wrong way. Alex called the journey from there "a brutal, painful, and lonely battle to the finish," which might be the best description of the marathon I've ever heard. Alex knew there was a risk in going for the OTQ and she willingly accepted it, and I'm glad she did. Alex proved to me, and more importantly to herself, that she has the toughness to get the job done, and as she continues to build fitness in the coming months she will put herself in a position to accomplish her very lofty goal.\r\n\r\nLinnaea made a successful marathon debut, running 2:47:29. Linnaea was on 2:44 pace for 35k when she ran into a rough patch and had to stop for a few moments. She got going again and finished strong, undoubtedly with a smile on her face. Linnaea is looking forward to getting back to the shorter stuff, but she's not saying no to another attempt at the distance at some point in the future. When she gets back to the marathon there is surely a lot more in the tank.\r\n\r\nIn the half, Seth ran 1:05:35. That was not quite a PR but it was a better performance on a harder course, in the midst of a marathon training block. Seth was out hard and that caught up to him in the last two miles when he was starting to question his life decisions but he fought all the way to the tape for a very strong result. Campbell ran a big PR of 1:07:20, and after a hot start he was able to settle in effectively. Ian ran a big PR of 1:08:14, with a nice negative split. That was undoubtedly the best race of Ian's career. Dylan had a bit a rough go of it, running in 1:09:37. Dylan is much fitter than that and will have a chance to prove it at CIM. Seth, Campbell, and Ian are also running CIM, and that will be a big day for the whole crew.\r\n\r\nOn the women's side, Autumn ran a huge PR of 1:18:41. In the days leading up to the race Autumn was dealing with knee issues that made her question whether she could even get on the starting line, which made her performance that much more impressive. If we can keep Autumn in one piece there are many more PRs in her future.\r\n\r\nADMINISTRATIVE\r\n\r\nGRC Travel Program--Our sponsorship with Tracksmith increases our funding to reduce member expenses for race travel. This benefits all members, and all members traveling to races should apply. The Board will soon send out reimbursements for the April-September season; if you have not applied yet, please do prior to Nov. 17. Program details and application are available on our website - https://www.grcrunning.com/grc-travel-program/ - and listed in the dropdown menus under the Team sections. You can apply any time, including for the current October-March season. A note to expect the equivalent of partial, not full, reimbursement.\r\n\r\nPlease sign up on the spreadsheet for Clubs. We're going to start making decisions on logistics and we need to know who's going to run.\r\nhttps://docs.google.com/spreadsheets/d/1pxaIf8O4lgiNNgsMixU1zu6bPoqF6mDmr-DCHpZSu0U/edit?gid=0#gid=0\r\n\r\nIf you're running Clubs you need an active USATF membership, in the Potomac Valley Region, with GRC as your team affiliation. If you have a USATF membership in another region and/or another team affiliation it's important to get that changed. Give me a shout and I'll explain the process, which can be a bit arduous.\r\n\r\nThere's still time to sign up for the Alexandria Turkey Trot. Let me know if you want the code.\r\n\r\nTime is running short to register for the 2026 Chicago Marathon. If you think you want to run be sure to apply in the next couple of days.\r\n\r\nWORKOUT\r\n\r\nWe'll roll at BCC at 6:45 so meet for the warmup at 6:00. Fall sports are over so we'll have BCC at our disposal for the next few months.\r\n\r\nWe have a lot of moving parts this week. If you're not racing this weekend or you're racing but training through the plan is 2 x 2400, 2 x 1600, 2 x 800, all with 2:00 rest.\r\n\r\nTargets for group 1 are 73, 72 on the 24s, 70, 69 on the 16s, and 67, 66 on the 8s.\r\n\r\nTargets for group 2 are 76, 75 on the 24s, 73, 72 on the 16s, and 70, 69 on the 8s.\r\n\r\nTargets for group 3 are 78, 77 on the 24s, 75, 74 on the 16s, and 72, 71 on the 8s.\r\n\r\nFor those who are racing this weekend the plan is 1600, 2:00 rest, then 8 x 600 with 1:30 rest.\r\n\r\nWe can call the targets 76 on the 16, and 2 @ 71, 2 @ 70, 2 @ 69, 2 @ 68, but we'll stay flexible.\r\n\r\nWe can modify this in any number of ways. Give me a shout to discuss a plan that works for you.\r\n\r\nI'll send the women's workout separately.\r\n\r\nSee you at BCC.\r\n\r\nJerry\r\n\r\n\r\n\r\n\r\n-- \r\nYou received this message because you are subscribed to the Google Groups "Georgetown Running Club Men" group.\r\nTo unsubscribe from this group and stop receiving emails from it, send an email to GRCmen+unsubscribe@googlegroups.com.\r\nTo view this discussion visit https://groups.google.com/d/msgid/GRCmen/IA2P221MB1373BB5D44A382AE76E9D0849DCFA%40IA2P221MB1373.NAMP221.PROD.OUTLOOK.COM.\r\n	2025-11-11 03:31:59	coach.jerry@live.com	grcwomen@googlegroups.com
44	wednesday workout, november 19, at bcc	RACES\r\n\r\nIt was truly an epic weekend. Keith made a smashing half marathon debut in Richmond, getting the win in 1:06:25. That performance was doubly impressive because Keith was solo out front after about 3 miles. For all of his accomplishments on the track and in xc, Keith has minimal experience on the roads, and to take the lead so early knowing that he had uncharted territory ahead is a testament to Keith's confidence in his fitness. Keith's long term future is on the roads, and he has a world of potential to explore. Well done!\r\n\r\nAlso in the Richmond Half, Stuart was third in a big PR of 1:07:22. That PR was a long time coming, and it's a big confidence boost for him going into CIM. Speaking of overdue PRs, Sean ran 1:09:41, which was the major breakthrough he's been working towards for a very long time. The next breakthrough will come at CIM. Daniel A ran a huge PR of 1:09:50, which is a quantum leap for him on the roads. Trever ran a very solid 1:12:20, which was a nice tuneup for CIM.\r\n\r\nIn the Richmond 8k Jason was fifth in a massive PR of 24:46. That was a major step forward, and was arguably the best race of his career. Jim ran a very nice PR of 24:55. Jim does the bulk of his racing on hilly courses in Baltimore and he took advantage of the opportunity to run fast in Richmond.\r\n\r\nIt was GRC domination at St Ritas 5k. Damian Hackett made a triumphant GRC debut by getting the win in 14:25, which is a club record. There are many more club records in Damian's future at whatever distances he decides to contest. Cameron gave Damian a battle to the tape, and his 14:26 is number two on the GRC list. Cam will be looking to lower his 8k club record in Philly this weekend. Ryan was third in 14:52, followed by Sam in fourth in 15:03, and Daniel F in fifth in 15:05. Will Baginski was sixth in his GRC debut in a PR of 15:09. Will is going to be a major addition to our track crew. Matt was eighth in 15:22, followed by Rob M in ninth in a road PR of 15:27. Joe started his cool down 2 miles early and finished in 16:11. Joe is recovering from a medical issue and he'll be ready for indoors.\r\n\r\nOn the women's side, Belaynesh got the win in 16:46, which puts her fifth in the GRC list. That was technically a PR because she never raced 5k before this fall. Considering that Belaynesh has run 32:10 for 10k it's safe to say that her new PR won't last long. Page Lester made her long awaited GRC debut, finishing second in 17:01, which was a road PR and ties her for ninth on the all-time list. Page has great range, and she will be a major contributor to our road and xc crew. Morgan was third in an evenly paced 17:06, which was a road PR. Gwen was fourth in 17:18, which was a very promising run as she prepares for indoors. Isolde McManus made her GRC debut by finishing fifth in 17:24. Iso is a great addition to our track and xc crew. Erin F was sixth in a humongous PR of 17:33. Erin is in the shape of her life going into the massive turkey trot duel with her twin. Gabi was seventh in a solid 17:46, followed by Sarah in 18:33. Last but not least, Jesse ran 22:09, and accomplished her goal of walking less than twice.\r\n\r\nADMINISTRATIVE\r\n\r\nIf you're running Clubs please sign up on the spreadsheet this week. It would be very helpful if you make your travel plans promptly and record them on the spreadsheet. We need to make decisions on ground transportation and to do that we need to know when you're arriving.\r\nhttps://docs.google.com/spreadsheets/d/1pxaIf8O4lgiNNgsMixU1zu6bPoqF6mDmr-DCHpZSu0U/edit?gid=0#gid=0\r\n\r\nGive me a shout if you want the comp code for the Alexandria Turkey Trot.\r\n\r\nThe deadline to register for Chicago is tomorrow afternoon. If you miss the deadline there's no going back so get on it tonight.\r\n\r\nWORKOUT\r\n\r\nWe'll roll at 6:45 at BCC so meet for the warmup at 6:00.\r\n\r\nThe plan for the men is 10 x 1k with 1:30 rest.\r\n\r\nTargets for group 1 are 2 @ 71 2 @ 70 2 @ 69 2 @ 68 2 @ 67.\r\n\r\nTargets for group 2 are 2 @ 73 2 @ 72 2 @ 71 2 @ 70 2 @ 69\r\n\r\nTargets for group 3 are 2 @ 76 2 @ 75 2 @ 74 2 @ 73 2 @ 72.\r\n\r\nCIM crew, you'll want to start with a tempo of up to 4800, and we can cut the 1ks early.\r\n\r\nAs always, we can modify this in any number of ways. Give me a shout to discuss a plan that works for you.\r\n\r\nI'll send the women's workout separately.\r\n\r\nSee you at BCC.\r\n\r\nJerry\r\n\r\n\r\n\r\n-- \r\nYou received this message because you are subscribed to the Google Groups "Georgetown Running Club Men" group.\r\nTo unsubscribe from this group and stop receiving emails from it, send an email to GRCmen+unsubscribe@googlegroups.com.\r\nTo view this discussion visit https://groups.google.com/d/msgid/GRCmen/IA2P221MB137303DFA9E415305E2B4DA99DD6A%40IA2P221MB1373.NAMP221.PROD.OUTLOOK.COM.\r\n	2025-11-18 02:41:51	coach.jerry@live.com	grcwomen@googlegroups.com
45	wednesday workout, november 26--no practice	RACES\r\n\r\nIt was a huge weekend in Philly--all six of our athletes ran PRs, which defies the axiom that you can't bat a thousand. Well done, gang!\r\n\r\nIn the 8k, Cameron was third in a very competitive field in an outstanding 23:15, which is a huge PR and breaks his own club record. Cam pushed the pace from the gun, and had enough in the tank to pass two guys in the last mile to finish on the podium. This was arguably the best race of Cam's career, and there's much more to come. Jack finished eighth in a big PR of 23:54, which puts him fifth on the all-time list. Jack's training hasn't been ideal because of extensive work travel and he surprised himself with this excellent performance. Rob M ran a big PR of 25:12, and was fifth in the open race. Rob had quite the adventure-when the gun went off he found himself on the ground amid the mass of humanity and had to scramble just to get upright.\r\n\r\nIn the marathon, Caroline ran a huge PR of 2:47:39, and finished fourth in the open race and twelfth overall. Caroline battled through some rough patches in miles 18 and 19 and was able to run under 6 minutes for the last mile. That was the breakthrough performance that Caroline has worked extremely hard for. I'm super proud of Caroline, and I'm excited to see what she can do at shorter distances in 2026. On the men's side, Kevin ran a very nice PR of 2:27:46, which was seventh in the open race and fourteenth overall. Kevin found himself in no man's land past mile 18 but he fought through it for an excellent finish. Connor made an impressive marathon debut, running 2:29:40, which was twelfth in the open race. Connor worked with Kevin to great effect through 18 miles, at which point stomach problems reared their ugly head. After an unplanned break Connor was able to get back into his rhythm and finished strong.\r\n\r\nADMINISTRATIVE\r\n\r\nIf you run an out of town turkey trot please send me the race report. If you win a turkey be sure to send a photo of your bounty.\r\n\r\nClubs crew, if you haven't already done so, please take a few minutes to make your travel arrangements and record the plans on the spreadsheet. Please also insure that your USATF account is active, and put your USATF number on the spreadsheet. Keep in mind that your USATF affiliation must be with GRC. If you need help with the USATF membership process give me a shout.\r\nhttps://docs.google.com/spreadsheets/d/1pxaIf8O4lgiNNgsMixU1zu6bPoqF6mDmr-DCHpZSu0U/edit?gid=0#gid=0\r\n\r\nThere's still time to register for the Alexandria Turkey Trot. Let me know if you want the comp code.\r\n\r\nI also have the comp code for Jingle 5k, which is on December 14 on the tidal basin. The course is flat and if we bring our own competition, it could be a good tuneup for Clubs. Let me know if you want to compete.\r\n\r\nWORKOUT\r\n\r\nBecause of the impending turkey trots there is no practice on Wednesday. If anyone wants to get in a workout at BCC I'm available. Give me a shout to discuss a plan that works for you.\r\n\r\nGood luck to all who are racing. Send 'em!\r\n\r\nJerry\r\n\r\n-- \r\nYou received this message because you are subscribed to the Google Groups "Georgetown Running Club Men" group.\r\nTo unsubscribe from this group and stop receiving emails from it, send an email to GRCmen+unsubscribe@googlegroups.com.\r\nTo view this discussion visit https://groups.google.com/d/msgid/GRCmen/IA2P221MB1373E4D5B5AFF23670563E8F9DD1A%40IA2P221MB1373.NAMP221.PROD.OUTLOOK.COM.\r\n	2025-11-25 02:44:54	coach.jerry@live.com	grcwomen@googlegroups.com
46	wednesday workout, december 3, at bcc	RACES\r\n\r\nWe had a big day at the Alexandria Turkey Trot 5 Mile. Cameron led wire to wire and to get the win in an outstanding 23:37. That was arguably a better performance than his club record at Rothman 8k last weekend, as this was a full 5 miles and he was solo for the second half of the race. Either way, it was an impressive double. Cam is ready to lead the charge at Clubs where he'll have slightly more competition. Ryan ran a strong 24:45 for fourth place. Sam ran 25:19, followed by Rob M in another PR in 25:20. Daniel A continued his breakthrough season with a nice PR of 25:28, followed by Marcelo in 25:42, and Trever in 26:35. Dickson continued his return to fitness after a nasty illness with a very encouraging 26:51, and Charlie ran 28:07.\r\n\r\nOn the women's side, Belaynesh continued her journey back to fitness by finishing fourth in 27:49, which puts her sixth on the GRC all-time list. Page was sixth in a very nice PR of 27:57, which is seventh on the list. Morgan finished seventh in an impressive 28:08, which is ninth on the list. In her first race post-Berlin Sydney ran 28:24, and she'll continue to build fitness going into Clubs. Eda ran a humongous PR of 28:58. Eda had never broken 30, and she skipped over the 29s entirely. Who says marathoners can't run fast! Jaren Rubio made her GRC debut in a PR of 29:20. What Jaren lacks in experience she makes up for in talent, and we're going to see big things from her at a variety of distances in the months to come. Maura and Frankie made impressive returns to competition post-partum, running 31:49 and 32:09, respectively.\r\n\r\nSean got the win at the Arlington Turkey Trot 5k in 15:21, leaving an angry horde of middle schoolers in his wake.\r\n\r\nJim got the win at the Towson Turkey Trot 5k in 15:51 on a very hilly course. Emily K was a strong second in 18:16.\r\n\r\nErin F ran 29:59 at the Ridgewood Turkey Trot 8k in North Carolina. Erin's twin got the better of her, which will only make it sweeter when Erin exacts her revenge next year.\r\n\r\nWhitney was fifth and was first master at the Asheville Turkey Trot 5k.\r\n\r\nMatt got the win in the San Antonio Road Runners 4 mile in 20:33.\r\n\r\nADMINISTRATIVE\r\n\r\nClubs crew, if you're getting down there on Friday you should get a ticket for World XC. They're free with the code USATF26.\r\nhttps://worldathletics.org/competitions/world-athletics-cross-country-championships/tallahassee26\r\n\r\nPlease update your information on the spreadsheet. We're missing USATF numbers for many of you, and it's time to get on top of that. Bear in mind that if you have an existing USATF membership, even a very old one, you have to switch your affiliation to GRC, and that requires a couple of steps. Do not leave this to the last minute.\r\n\r\nWe need volunteers for the Pacers Jingle 5k. If you haven't fulfilled your volunteer requirement for 2025 this is your last opportunity.\r\nhttps://docs.google.com/spreadsheets/d/1QiSxHWa95p3Nl0Aqzgxmc5ntAguKhKYyD5Oc4Zgt42E/edit?gid=23969292#gid=23969292\r\n\r\nIf you want to run the 5k let me know and I'll send you the comp code.\r\n\r\nWORKOUT\r\n\r\nWe'll roll at 7:00 at BCC so meet for the warmup at 6:15. If history is a guide the lights will come on at 7, and avoiding intervals in the dark is worth the wait.\r\n\r\nThe plan for the men is 2 x 3200, 4 x 800, all with 2:00 rest.\r\n\r\nTargets for group 1 are 72, 71 on the 32s, and 68, 67, 66, 65 on the 8s.\r\n\r\nTargets for group 2 are 74, 73 on the 32s, and 70, 69, 68, 67 on the 8s.\r\n\r\nTargets for group 3 are 77, 76 on the 32s, and 73, 72, 71, 70 on the 8s.\r\n\r\nAs always we can modify this in any number of ways. Give me a shout to discuss a plan that works for you.\r\n\r\nI'll send the women's workout seperately.\r\n\r\nSee you at BCC.\r\n\r\nJerry\r\n\r\n\r\n\r\n\r\n-- \r\nYou received this message because you are subscribed to the Google Groups "Georgetown Running Club Men" group.\r\nTo unsubscribe from this group and stop receiving emails from it, send an email to GRCmen+unsubscribe@googlegroups.com.\r\nTo view this discussion visit https://groups.google.com/d/msgid/GRCmen/IA2P221MB137337A03020811036EADA539DD8A%40IA2P221MB1373.NAMP221.PROD.OUTLOOK.COM.\r\n	2025-12-02 02:15:17	coach.jerry@live.com	grcmen@googlegroups.com
47	wednesday workout, december 10, at bcc	RACES\r\n\r\nThe guys delivered at CIM with seven PRs! Seth led the way with a seven minute (!) PR of 2:19:20. Seth took a shot at an OTQ and he was rolling through 17 miles. It started to go in the wrong direction at that point but Seth hung on for an outstanding result. Stuart ran a 2.5 minute PR of 2:23:02. Stu had some hamstring distress in the last 10k and went into survival mode but was able to finish it up. Dylan ran a 2+ minute PR of 2:23:44, with a nice negative split. Dylan's tune up races did not go well but he trusted his fitness and was able to have a career day. Campbell got out very aggressively and was able to weather a rough last 10k to hang on for a PR of 2:25:45. Sean continued his breakthrough season with a 3.5 minute PR of 2:27:23. Sean has worked hard for years for this result, and it was well-earned. Ian ran a seven minute PR of 2:29:37, with a nice negative split. Ian held back early and was glad he did! Trever ran a minute-plus PR of 2:32:54, which was unquestionably the best race of his career. Trev worked through some rough patches and the tank was on empty when he crossed the line. Outlaw had a tough day at the office, running 2:28:52. Outlaw was in PR shape after a fantastic training cycle but it meant to be. He's already plotting his next shot at the long awaited PR.\r\n\r\nKeith placed an excellent 47th in the USATF XC Championships in Portland. The course was very muddy, which meant Keith was in his element. The field was extraordinarily deep, and Keith was competitive with many full-time pros, including going stride for stride over the last 2k with Woody Kincaid. This was an excellent tuneup for Clubs, and Keith will be ready to lead the charge in Tallahassee.\r\n\r\nGwen made her long-awaited GRC track debut, running 4:47.58 in the mile at the BU Season Opener, which is second on the all-time list. The race got out slowly and Gwen bided her time, moving up steadily throughout and closing in 32. Gwen is going to focus on the mile this season, and we'll see much more from her in the weeks and months ahead.\r\n\r\nIn other track action, Daniel F was second in the 800 at the CNU Holiday Open in 1:57.82. That was a solid opener for what promises to be a breakthrough season. Chase was fourth in 2:01.65. At the Armory Collegiate Invitational 5000 Matt ran a strong 15:11.35, and Rob M ran 15:26.26.\r\n\r\nJason was fourth in the Raleigh Holiday Half Marathon in 1:11:31. Jason is in excellent shape, and this could be the year he delivers on his pledge to finish in the top 100 at Clubs.\r\n\r\nLast but certainly not least, Gina was third in the La Milla Llanera Road Mile in Puerto Rico in 4:37, which is a Malta national record. That was Gina's fastest ever opener, which bodes well for another big year.\r\n\r\nADMINISTRATIVE\r\n\r\nLet me know if you want to be considered for a comp for Grandmas Marathon/Half. I'd like to submit our entry request in the next couple of weeks so there is some urgency.\r\n\r\nClubs crew, if you're getting down there on Friday you should get a ticket for World XC. They're free with the code USATF26.\r\nhttps://worldathletics.org/competitions/world-athletics-cross-country-championships/tallahassee26\r\n\r\nWe're still missing an alarmingly large number of USATF membership numbers. Please get on top of this right away.\r\nhttps://docs.google.com/spreadsheets/d/1pxaIf8O4lgiNNgsMixU1zu6bPoqF6mDmr-DCHpZSu0U/edit?gid=2062633673#gid=2062633673\r\n\r\nWe need more volunteers for the Pacers Jingle 5k. If you haven't fulfilled your volunteer requirement for 2025 this is your last opportunity.\r\nhttps://docs.google.com/spreadsheets/d/1QiSxHWa95p3Nl0Aqzgxmc5ntAguKhKYyD5Oc4Zgt42E/edit?gid=23969292#gid=23969292\r\n\r\nThere's still time to register for the 5k, which would be a good tune up for Clubs. Let me know if you want in.\r\n\r\nWORKOUT\r\n\r\nWe'll roll at 7:00 at BCC so meet for the warmup at 6:15.\r\n\r\nThe plan for the men is 4 x 2k with 2:00 rest, then 4 x 400 with 45 seconds rest.\r\n\r\nTargets for group 1 are 72, 71, 70, 69 on the 2ks, and 66, 65, 64, 63 on the 4s.\r\n\r\nTargets for group 2 are 74, 73, 72, 71 on the 2ks, and 68, 67, 66, 65 on the 4s.\r\n\r\nTargets for group 3 are 77, 76, 75, 74 on the 2ks, and 70, 69, 68, 66 on the 4s.\r\n\r\nAs always we can modify this in any number of ways. Give me a shout to discuss a plan that works for you.\r\n\r\nI'll send the women's workout separately.\r\n\r\nSee you at BCC.\r\n\r\nJerry\r\n\r\n-- \r\nYou received this message because you are subscribed to the Google Groups "Georgetown Running Club Men" group.\r\nTo unsubscribe from this group and stop receiving emails from it, send an email to GRCmen+unsubscribe@googlegroups.com.\r\nTo view this discussion visit https://groups.google.com/d/msgid/GRCmen/IA2P221MB1373E4494FA4F6F645F9158C9DA3A%40IA2P221MB1373.NAMP221.PROD.OUTLOOK.COM.\r\n	2025-12-09 02:50:08	coach.jerry@live.com	grcwomen@googlegroups.com
\.


--
-- Data for Name: race_results; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.race_results (id, race_id, athlete_id, unknown_athlete_name, "time", pr_improvement, notes, "position", is_pr, tags, flagged, flag_reason, email_id, date_recorded, is_club_record) FROM stdin;
2	1	11		2:15:30	\N	Sixth American, third on GRC all-time list	19	t	{"strong performance"}	f		2	2025-01-21	f
3	1	27		2:26:25	\N	Third best time of long career	\N	f	{"solid effort"}	f		2	2025-01-21	f
4	1	19		2:26:53	\N	Ran over 20 miles solo	\N	f	{"challenging conditions"}	f		2	2025-01-21	f
5	1	90		2:29:15	\N	PR while in medical residency	\N	t	{determined}	f		2	2025-01-21	f
7	1	42		2:41:47	\N	Marathon debut hampered by injuries	\N	f	{"challenging debut"}	f		2	2025-01-21	f
8	2	24		1:05:23	\N	Sixth on GRC all-time list, breakthrough performance	\N	t	{"huge PR","track to road success"}	f		2	2025-01-21	f
10	3	65		10:17.98	\N	Solo win in 3000m	1	f	{"solo lead"}	f		2	2025-01-21	f
11	3	67		5:08.95	\N	Led pack, struggled to finish	\N	f	{"strategic run"}	f		2	2025-01-21	f
12	3	80		5:13.85	\N	GRC debut	\N	f	{potential}	f		2	2025-01-21	f
13	3	29		4:20.43	\N	Mile win, led last 600m	1	f	{leadership}	f		2	2025-01-21	f
14	4	87		5:09, 37:04, 1:26	\N	Three races in three days	\N	f	{"multi-race challenge"}	f		2	2025-01-21	f
16	6	16		4:15.78	\N	Indoor PR in mile	\N	t	{"indoor PR"}	f		3	2025-01-28	f
17	6	16		1:56.87	\N	Indoor PR in 800m	\N	t	{"indoor PR"}	f		3	2025-01-28	f
18	6	29		4:18.43	\N	Strong performance while not at full strength due to illness	\N	f	{"strong performance"}	f		3	2025-01-28	f
19	6	9		52.85	\N	Strong 400m performance, getting legs back	\N	f	{"strong performance"}	f		3	2025-01-28	f
21	8	9		1:58.63	\N	Won race, ran essentially solo last 300m	1	f	{strong,"solo performance"}	f		4	2025-02-04	f
22	9	88		1:40:22	\N	Challenging conditions with iced over portions of the loop	\N	f	{"tough conditions"}	f		4	2025-02-04	f
23	10	29		3:06.83	\N	1200m leg of DMR	3	f	{"team performance"}	f		5	2025-02-11	f
24	10	9		0:52.44	\N	400m leg of DMR, Millrose debut	3	f	{"team performance"}	f		5	2025-02-11	f
25	10	16		1:56.84	\N	800m leg of DMR, Millrose debut	3	f	{"team performance"}	f		5	2025-02-11	f
26	10	20		4:05.66	\N	1600m anchor leg, fastest of the day	3	f	{"fastest leg","team record"}	f		5	2025-02-11	f
27	11	65		17:18.10	\N	Stuck between packs after 1400m, raced solo	\N	f	{"potential to improve"}	f		5	2025-02-11	f
28	12	9		1:56.53	\N	Nice step forward, racing into shape	\N	f	{improving}	f		6	2025-02-18	f
29	13	49		1:05:21	\N	Massive breakthrough, best race of career	6	t	{breakthrough,"all-time list"}	f		7	2025-02-25	f
30	13	93		1:16:43	\N	Half marathon debut, huge talent	\N	f	{debut,promising}	f		7	2025-02-25	f
31	14	84		4:59.02	\N	Won mile, led from 850m	1	f	{win,"solo lead"}	f		7	2025-02-25	f
32	14	16		4:14.64	\N	Indoor PR, improving consistently	\N	t	{"indoor PR",improving}	f		7	2025-02-25	f
33	14	65		10:07.89	\N	Even splits, stuck in no-man's land	3	f	{consistent,"breakthrough potential"}	f		7	2025-02-25	f
34	14	29		8:43.25	\N	Tough race, will regroup	\N	f	{"challenging day"}	f		7	2025-02-25	f
35	15	37		53:18	\N	Boston prep on hilly course	4	f	{"boston training"}	f		7	2025-02-25	f
36	15	48		53:25	\N	Boston prep on hilly course	5	f	{"boston training"}	f		7	2025-02-25	f
37	15	28		54:11	\N	Boston prep on hilly course	10	f	{"boston training"}	f		7	2025-02-25	f
38	15	27		54:19	\N	Boston prep on hilly course	\N	f	{"boston training"}	f		7	2025-02-25	f
39	15	32		54:44	\N	Boston prep on hilly course	\N	f	{"boston training"}	f		7	2025-02-25	f
40	15	54		55:36	\N	Boston prep on hilly course	\N	f	{"boston training"}	f		7	2025-02-25	f
41	16	8		57:44	\N	Pleased with effort on rolling course	\N	f	{"satisfied performance"}	f		7	2025-02-25	f
44	19	41		52:52	\N	First race in almost a year after injury, won by over 9 minutes	1	f	{comeback,"dominant win"}	f		8	2025-03-04	f
45	20	73		2:09.78	\N	Controlled win, sat on leader for 600m, closed in 31.4	1	f	{"ferocious kick",strategic}	f		9	2025-03-11	f
47	20	84		4:59.8	\N	Worked with Emily K, unreliable pacing	2	f	{cooperative}	f		9	2025-03-11	f
48	20	67		5:03.91	\N	Worked with Morgan	3	f	{cooperative}	f		9	2025-03-11	f
49	20	80		5:07.81	\N	Big negative split, closed in 34.3	5	f	{"strong finish"}	f		9	2025-03-11	f
50	20	26		8:46.4	\N	Perfect tactics, moved from 11th to first, fastest 200m close	1	f	{strategic,"strong finish"}	f		9	2025-03-11	f
51	20	29		8:29.04	\N	Best indoor performance of the season	4	f	{"strong performance"}	f		9	2025-03-11	f
52	20	55		8:30.54	\N	Pushed pace in chase pack	5	t	{PR,aggressive}	f		9	2025-03-11	f
6	1	44		2:29:39	\N	Worked with Zach Matthews	\N	f	{progress}	f		2	2025-01-21	f
20	7	53			\N	First race since Olympic Trials, limited training due to personal/professional responsibilities	16	f	{"post-Olympic Trials"}	f		3	2025-01-28	f
1	1	59		2:14:49	\N	Fifth American, broke club record	18	t	{impressive,ambitious}	f		2	2025-01-21	t
15	5	20		8:07.77	\N	Broke club record in 3000m	\N	f	{triumphant,"club record"}	f		3	2025-01-28	t
53	20	34		8:37.34	\N	Encouraging performance after calf issues	10	f	{recovering}	f		9	2025-03-11	f
54	20	9		4:32.36	\N	Moved up to mile, will use strength for 800m outdoors	\N	f	{strategic}	f		9	2025-03-11	f
55	20	43		4:53.44	\N	First track race since Bush administration	\N	f	{comeback}	f		9	2025-03-11	f
56	21	95		1:15:12	\N	Defended title, felt previous race in legs	1	f	{"title defense","tough race"}	f		10	2025-03-18	f
57	21	61		1:17:53	\N	PR on a slow course	2	t	{impressive,"strong fitness"}	f		10	2025-03-18	f
58	21	83		1:18:11	\N	Comeback race after ankle injury	\N	t	{recovery,"big comeback"}	f		10	2025-03-18	f
60	21	62		1:27:46	\N	Boston Marathon tuneup effort	\N	f	{"training race"}	f		10	2025-03-18	f
61	21	51		1:08:26	\N	Led most of race, overtaken by 10k specialist	2	t	{"strong performance","near win"}	f		10	2025-03-18	f
62	21	48		1:10:16	\N	Tied previous PR, good Boston tuneup	\N	f	{consistent,"marathon prep"}	f		10	2025-03-18	f
63	21	39		1:10:21	\N	Strong performance after injury recovery	\N	f	{comeback,"injury recovery"}	f		10	2025-03-18	f
64	21	36		1:10:22	\N	GRC debut race	\N	f	{"team debut"}	f		10	2025-03-18	f
65	21	23		1:10:49	\N	Working back to full fitness	\N	f	{"fitness build"}	f		10	2025-03-18	f
66	22	27		2:27:28	\N	Defended title with solo finish	1	f	{"title defense","solo effort"}	f		10	2025-03-18	f
67	23	28		15:07	\N	Strong performance on hilly Baltimore course	4	t	{"hilly course",PR}	f		10	2025-03-18	f
68	24	37		1:09:26	\N	Got out aggressively but regrouped	\N	t	{breakthrough,"smart racing"}	f		11	2025-03-25	f
69	24	54		1:11:40	\N	Close to PR, ran smart	\N	f	{competitive,consistent}	f		11	2025-03-25	f
70	24	32		1:13:24	\N	Tempo effort after illness	\N	f	{comeback,resilient}	f		11	2025-03-25	f
71	25	21		4:31:00	\N	Technical course with 7,000 feet elevation gain	2	f	{competitive,"challenging terrain"}	f		11	2025-03-25	f
72	26	88		6:40:00	\N	Personal meaningful race in hurricane-impacted area	\N	f	{"local pride","enjoyable experience"}	f		11	2025-03-25	f
73	27	8		16:09	\N	Ran faster than seeded time	\N	f	{"exceeded expectations"}	f		11	2025-03-25	f
74	28	20		14:51	\N	Course record, good comeback after being injured	1	f	{victory,"course record"}	f		11	2025-03-25	f
75	29	80		4:37.38	\N	Best performance in GRC uniform, seventh on GRC all-time list	2	f	{improving}	f		12	2025-03-31	f
76	29	16		1:54.94	\N	Sixth on club list, excellent tactics	\N	f	{strategic}	f		12	2025-03-31	f
77	29	9		1:57.55	\N	Led most of the way, struggled in last 100m	\N	f	{gutsy}	f		12	2025-03-31	f
78	29	34		14:34.16	\N	Near-perfect execution, potential club record contender	1	f	{precise}	f		12	2025-03-31	f
79	29	7		14:46.01	\N	Enormous PR in oppressive heat	2	t	{fearless}	f		12	2025-03-31	f
80	29	55		14:48.15	\N	Strong effort in challenging conditions	3	f	{resilient}	f		12	2025-03-31	f
81	29	29		15:08.18	\N	First race of season, potential 1500m record contender	4	f	{consistent}	f		12	2025-03-31	f
82	29	15		15:28.04	\N	Impressive 5000m debut	5	f	{promising}	f		12	2025-03-31	f
83	29	86		17:43.36	\N	Led race at mile, pushed pace despite heat	3	f	{aggressive}	f		12	2025-03-31	f
84	29	98		18:24.54	\N	GRC debut	\N	f	{"new member"}	f		12	2025-03-31	f
85	30	95		0:56:34	\N	Seventh on GRC all-time list, top 20 in championship field	20	t	{impressive,"season highlight"}	f		13	2025-04-08	f
87	30	84		0:58:25	\N	10 mile debut, promising future on roads	\N	f	{debut}	f		13	2025-04-08	f
88	30	86		0:58:29	\N	Another big step forward	\N	f	{improving}	f		13	2025-04-08	f
89	30	83		0:58:40	\N	Huge PR with more to come	\N	t	{breakthrough}	f		13	2025-04-08	f
90	30	61		0:58:55	\N	Tough day, but in great shape	\N	f	{challenging}	f		13	2025-04-08	f
91	30	67		0:59:01	\N	10 mile debut, strength for future track performance	\N	f	{debut}	f		13	2025-04-08	f
92	30	63		0:59:07	\N	Strong GRC debut, future marathon potential	\N	f	{debut}	f		13	2025-04-08	f
93	30	87		0:59:11	\N	Comfortable effort after stressful weeks	\N	f	{resilient}	f		13	2025-04-08	f
94	30	97		1:00:00	\N	Best race of her career	\N	t	{breakthrough}	f		13	2025-04-08	f
95	30	69		1:01:46	\N	Strong race in return to competition	\N	f	{comeback}	f		13	2025-04-08	f
96	30	88		1:06:13	\N	Two weeks after trail 50k	\N	f	{multi-terrain}	f		13	2025-04-08	f
97	30	70		1:10:17	\N	Controlled effort, inspiring to others	\N	f	{inspirational}	f		13	2025-04-08	f
98	30	6		0:48:48	\N	Good start despite limited training	22	f	{promising}	f		13	2025-04-08	f
99	30	58		0:48:59	\N	Second fastest CB time, hampered by COVID	\N	f	{competitive}	f		13	2025-04-08	f
100	30	24		0:49:28	\N	Huge PR after 3 weeks of workouts, marathon debut upcoming	\N	t	{breakthrough}	f		13	2025-04-08	f
102	30	7		0:50:23	\N	Huge PR a week after 5000m PR	\N	t	{breakthrough}	f		13	2025-04-08	f
103	30	51		0:50:24	\N	Big PR, ready for 25k champs	\N	t	{breakthrough}	f		13	2025-04-08	f
104	30	59		0:50:37	\N	Ran after hard long run, targeting 5000 club record	\N	f	{competitive}	f		13	2025-04-08	f
105	30	41		0:50:49	\N	Solid return after injury	\N	f	{comeback}	f		13	2025-04-08	f
106	30	19		0:51:25	\N	Big PR, also ran 10k PR of 31:51, potential benefit from altitude training	\N	t	{breakthrough}	f		13	2025-04-08	f
107	30	12		0:51:53	\N	Happy to be back in DC	\N	f	{returning}	f		13	2025-04-08	f
108	30	22		0:52:02	\N	Big PR	\N	t	{breakthrough}	f		13	2025-04-08	f
110	30	39		0:52:33	\N	Boston Marathon tuneup	\N	f	{tuneup}	f		13	2025-04-08	f
111	31	61		35:03.3	\N	Seventh on GRC all-time list, came through 8000m in 28:00	3	t	{"huge improvement",breakthrough}	f		14	2025-04-15	f
112	31	55		14:24.46	\N	Moved from 26th to 10th place, tenth on GRC list	\N	t	{"tactical race",breakthrough}	f		14	2025-04-15	f
113	31	15		15:20.73	\N	Took lead to keep pace honest	\N	f	{"gutsy performance"}	f		14	2025-04-15	f
114	31	47		15:33.5	\N	Struggled after 3600m but fought to finish	\N	f	{"fought hard"}	f		14	2025-04-15	f
115	31	34		29:58.8	\N	Struggled in later stages due to minor injury	\N	f	{"tough night"}	f		14	2025-04-15	f
116	31	49		30:46.0	\N	Did not have his best race	\N	f	{"off night"}	f		14	2025-04-15	f
117	32	16		4:11.72	\N	Fourth on GRC list, competitive through 1200m	4	f	{"strong result"}	f		14	2025-04-15	f
118	33	18		16:32.0	\N	Tempo effort win	1	f	{"race lover"}	f		14	2025-04-15	f
119	34	48		15:23.0	\N	Broke own course record, defeated middle school competitors	1	f	{"dominant win"}	f		14	2025-04-15	f
120	35	102		2:44:13	\N	Ties for tenth place on GRC all-time list	\N	t	{"huge PR",focused}	f		15	2025-04-22	f
121	35	62		2:55:44	\N	Vastly exceeded expectations, concluded she's a marathoner	\N	f	{"strong performance"}	f		15	2025-04-22	f
122	35	100		2:57:24	\N	Struggled in last 10k but finished	\N	f	{"tough finish"}	f		15	2025-04-22	f
124	35	39		2:27:51	\N	Best performance of long career	\N	t	{"huge PR"}	f		15	2025-04-22	f
125	35	21		2:28:42	\N	Overcame stomach issues and calf cramp	\N	t	{"gigantic PR",tough}	f		15	2025-04-22	f
126	35	48		2:30:54	\N	Product of years of hard work	\N	t	{"big PR"}	f		15	2025-04-22	f
127	35	32		2:33:09	\N	Major PR after uncertainty about racing	\N	t	{"major PR"}	f		15	2025-04-22	f
128	35	54		2:36:53	\N	Hurting late in race, happy to finish	\N	f	{"tough finish"}	f		15	2025-04-22	f
129	35	37		2:39:21	\N	Struggled with hamstring problems	\N	f	{"hung tough"}	f		15	2025-04-22	f
130	35	10		2:56:40	\N	27th consecutive Boston under 3 hours	\N	f	{consistent,durable}	f		15	2025-04-22	f
131	36	73		4:21.87	\N	Relaxed performance, closed in 68.7	\N	f	{"successful season opener"}	f		15	2025-04-22	f
132	37	80		4:33.54	\N	Best performance in GRC uniform	\N	f	{promising}	f		15	2025-04-22	f
133	37	28		3:57.1	\N	Near PR performance	5	f	{}	f		15	2025-04-22	f
134	37	15		4:01.61	\N	Closed in 62.6	\N	f	{"solid performance"}	f		15	2025-04-22	f
135	37	8		16:10.17	\N	Good effort in less than ideal conditions	\N	f	{}	f		15	2025-04-22	f
136	38	26		4:03.54	\N	Triumphant return to CNU	4	f	{}	f		15	2025-04-22	f
137	39	67		4:46.61	\N	Not happy with performance	\N	f	{"better days coming"}	f		15	2025-04-22	f
138	40	16		14:59	\N	Beaten by 15-year-old local high schooler	2	t	{PR}	f		15	2025-04-22	f
139	41	73		2:05.69	\N	Second fastest time of her career, tactically smart race	6	f	{tactical,"elite field"}	f		16	2025-04-29	f
140	42	6		14:13.56	\N	Fourth on GRC all-time list, narrowly missed win in last 200m	2	t	{breakthrough,"close finish"}	f		16	2025-04-29	f
141	42	20		14:32.9	\N	Limited by recent injury and illness	6	t	{recovering,potential}	f		16	2025-04-29	f
142	42	55		14:37.99	\N	Solid performance despite slow early pace	\N	f	{steady}	f		16	2025-04-29	f
143	42	34		14:45.6	\N	Encouraging performance despite calf issues	\N	f	{recovering}	f		16	2025-04-29	f
144	42	29		14:48.99	\N	Rough race, strong final 400m	\N	f	{"strong finish"}	f		16	2025-04-29	f
145	42	2		14:52.88	\N	Strong first race since Clubs	\N	f	{comeback}	f		16	2025-04-29	f
146	42	47		15:29.7	\N	Gaining valuable race experience	\N	f	{learning}	f		16	2025-04-29	f
147	42	84		16:53.24	\N	Led through 2k, then isolated, faced unfair tactics	\N	t	{gutsy,leadership}	f		16	2025-04-29	f
148	42	86		16:58.82	\N	Solid performance while returning to fitness	\N	f	{building}	f		16	2025-04-29	f
149	42	2		17:12.69	\N	Exhausted from travel, needs rest	\N	f	{fatigued}	f		16	2025-04-29	f
150	43	87		1:17:50	\N	Triumphant season finale	1	f	{victory}	f		16	2025-04-29	f
151	43	97		1:19:30	\N	Major breakthrough, ending on high note before law school	2	t	{breakthrough,"personal best"}	f		16	2025-04-29	f
152	43	13		1:08:54	\N	Led race for significant portion, battled wind	2	f	{competitive}	f		16	2025-04-29	f
153	43	36		1:09:30	\N	Nice personal record	3	t	{"personal best"}	f		16	2025-04-29	f
154	43	8		1:12:31	\N	Fastest half since 2019, masters division win	1	f	{"masters victory"}	f		16	2025-04-29	f
155	44	41		30:15	\N	Sixth on all-time list, good tuneup for Broad Street	2	t	{"personal best",preparing}	f		16	2025-04-29	f
156	45	6		0:48:41	\N	Conditions precluded big PR, but strong performance	3	f	{competitive,consistent}	f		17	2025-05-06	f
157	45	24		0:50:15	\N	Ran solo almost entire race	4	f	{"solo runner"}	f		17	2025-05-06	f
158	45	41		0:50:44	\N	Strong run in comeback season	5	f	{comeback}	f		17	2025-05-06	f
159	45	101		0:51:12	\N	Prepared by training in Florida	7	f	{prepared}	f		17	2025-05-06	f
160	45	22		0:52:12	\N	Strong performance	\N	f	{}	f		17	2025-05-06	f
109	30	44		0:52:29	\N	Boston Marathon tuneup	\N	f	{tuneup}	f		13	2025-04-08	f
161	45	2		0:52:42	\N		\N	f	{}	f		17	2025-05-06	f
163	45	83		0:59:13	\N	Excellent performance, breakthrough season	9	f	{breakthrough}	f		17	2025-05-06	f
164	45	65		1:00:52	\N	Capable of much faster time in good conditions	\N	t	{potential}	f		17	2025-05-06	f
165	45	69		1:03:17	\N	Solid run in comeback season	\N	f	{comeback}	f		17	2025-05-06	f
166	45	88		1:08:02	\N	Struggled in conditions, expected stronger performance in fall	\N	f	{challenging}	f		17	2025-05-06	f
167	46	46		0:14:53	\N	Competed well with top runners	24	f	{competitive}	f		17	2025-05-06	f
168	46	61		0:17:54	\N	Out of comfort zone but enjoyed experience	26	f	{learning}	f		17	2025-05-06	f
169	47	55		0:3:52.64	\N	Huge PR, sixth on GRC all-time list, strong last 400m	\N	t	{breakthrough,"strong finish"}	f		17	2025-05-06	f
170	47	29		0:3:53.54	\N	Best performance of the year	\N	f	{improving}	f		17	2025-05-06	f
171	48	16		0:1:54.98	\N	Sixth on GRC list	\N	f	{strong}	f		17	2025-05-06	f
172	48	16		0:3:59.75	\N	Back to full fitness, ready to PR	\N	f	{comeback}	f		17	2025-05-06	f
173	48	9		0:1:56.79	\N	Competed very well	\N	f	{competitive}	f		17	2025-05-06	f
174	48	28		0:3:57.41	\N	Ready for breakthrough	\N	f	{potential}	f		17	2025-05-06	f
175	48	80		0:4:35.22	\N	Improving every week	\N	f	{consistent}	f		17	2025-05-06	f
176	48	67		0:4:37.45	\N	Trending up	\N	f	{improving}	f		17	2025-05-06	f
177	48	89		0:4:54.55	\N	First 1500 since college, broke 5 minutes despite sore Achilles	\N	f	{comeback}	f		17	2025-05-06	f
179	49	29		4:17.21	\N	Closing out season strong	\N	f	{consistent}	f		18	2025-05-27	f
180	49	84		5:00.12	\N	Tuneup for Tracksmith 5000	\N	f	{}	f		18	2025-05-27	f
181	50	8		16:01.99	\N	0.42 seconds faster than last year	\N	f	{consistent}	f		18	2025-05-27	f
182	51	28		4:16.3	\N		6	f	{}	f		18	2025-05-27	f
183	51	80		5:02.1	\N	Ties for ninth on GRC all-time list	9	f	{}	f		18	2025-05-27	f
184	51	67		5:12.5	\N	Rough race	\N	f	{struggled}	f		18	2025-05-27	f
185	52	73		2:10.01	\N	Won gold in 800m after overcoming early deficit	1	f	{gold,comeback}	f		19	2025-06-03	f
186	52	73		4:29.52	\N	Silver in 1500m, competed against 2024 Olympian	2	f	{silver}	f		19	2025-06-03	f
187	52	73		17:07.3	\N	Silver in 5000m with strong final 400m kick	2	f	{silver,"strong finish"}	f		19	2025-06-03	f
188	50	6		14:11.17	\N	Won race, second on GRC all-time list	1	t	{win,"all-time list"}	f		19	2025-06-03	f
189	50	34		14:38.44	\N	Mostly solo effort after 1600m	2	f	{"solo effort"}	f		19	2025-06-03	f
190	50	2		15:13.8	\N	More potential in the tank	\N	f	{potential}	f		19	2025-06-03	f
191	50	18		15:52.43	\N	Ran well with Charlie Ban	\N	f	{"group effort"}	f		19	2025-06-03	f
192	50	8		15:52.69	\N	Ran well with Dickson Mercer	\N	f	{"group effort"}	f		19	2025-06-03	f
193	50	43		16:23.79	\N	Completed masters squad	\N	f	{masters}	f		19	2025-06-03	f
194	50	105		16:27.62	\N	GRC debut, seventh on all-time list	1	f	{win,"all-time list",debut}	f		19	2025-06-03	f
195	50	84		16:49.91	\N	Closed out season successfully	2	t	{PR}	f		19	2025-06-03	f
197	53	28		15:12.9	\N	Hilly course, strong season-ending performance	3	f	{hilly,"season finale"}	f		19	2025-06-03	f
199	55	34		14:23.51	\N	Best race of the year, perfect tactics, closed last 400m in 65 seconds	9	f	{"strong finish","strategic race"}	f		21	2025-06-17	f
200	56	60		2:16.29	\N	GRC debut, ninth on all-time list, ran 57.1 400m split in DMR	\N	f	{debut,"fastest DMR split"}	f		21	2025-06-17	f
201	57	6		18:40.69	\N	Top 10 finish at national championship, near PR	9	f	{"national championship","high fitness"}	f		21	2025-06-17	f
202	57	18		20:53	\N	First in age group, defending USATF masters grand prix championship	2	f	{"age group win","masters championship"}	f		21	2025-06-17	f
203	58	15		17:03	\N	Rustbuster race	\N	f	{rustbuster}	f		21	2025-06-17	f
204	58	88		20:12	\N	Rustbuster race	\N	f	{rustbuster}	f		21	2025-06-17	f
205	59	24		2:25:30	\N	Debut marathon, strong through 20 miles, struggled last 10k	\N	f	{debut,promising}	f		22	2025-06-24	f
206	59	49		2:26:27	\N	Overcame health issues and family loss, fought to finish	\N	f	{resilient,tough}	f		22	2025-06-24	f
207	59	63		3:04:10	\N	Debut marathon with short build, conservative plan, strong negative split	\N	f	{debut,"negative split"}	f		22	2025-06-24	f
208	60	44		1:09:04	\N	Slightly slower than 2018 PR but strong performance in challenging conditions	\N	f	{competitive}	f		22	2025-06-24	f
209	60	8		1:18:37	\N	Struggled with heat, dropped out early	\N	f	{"heat affected"}	f		22	2025-06-24	f
210	61	21			\N	Challenging mountain trail race with steep terrain	8	f	{trail,mountain}	f		22	2025-06-24	f
211	62	18		4:46.25	\N	End of three-year victory streak	2	f	{competitive}	f		22	2025-06-24	f
213	65	73		4:33.29	\N	Solo effort	1	f	{"solo run"}	f		24	2025-07-08	f
214	64	73		2:05.41	\N	No competition, full effort with 60-low/65 split	1	f	{"full send"}	f		24	2025-07-08	f
178	49	20		4:02.26	\N	Club record, caught in traffic on last lap	\N	f	{excellent,"potential sub-4"}	f		18	2025-05-27	t
215	66	29		15:46	\N	Worked with Sean, unleashed lethal kick	\N	f	{"strong finish"}	f		24	2025-07-08	f
216	66	48		15:50	\N	Worked with Joe	\N	f	{}	f		24	2025-07-08	f
217	66	27		16:13	\N		\N	f	{}	f		24	2025-07-08	f
218	66	54		16:34	\N		\N	f	{}	f		24	2025-07-08	f
219	67	47		16:12	\N	Solo win on hilly course	1	f	{"solo win",hilly}	f		24	2025-07-08	f
221	69	28		16:03	\N	Hot and humid conditions	3	f	{"challenging weather"}	f		24	2025-07-08	f
222	70	22		20:53	\N		3	f	{}	f		24	2025-07-08	f
231	68	44		22:41	\N		2	f	{}	f		25	2025-07-08	f
234	71	63		1:00:27	\N	Good effort on a hilly course in challenging conditions, three weeks after Grandmas	\N	f	{hilly,"challenging conditions"}	f		26	2025-07-15	f
235	72	47		15:27	\N	Just starting back up, finished at Lambeau Field	3	f	{"strong performance","hometown race"}	f		27	2025-07-22	f
236	73	6		33:56	\N	Competed on hilly course against pro runners	14	f	{national-level,"hilly course"}	f		28	2025-07-29	f
237	74	21		9:04	\N	Tough mountain course with significant climbing, strong finish	5	f	{ultra,"mountain race"}	f		28	2025-07-29	f
238	75	73		4:41	\N	Won over high-quality field, negative split, closed in 62 seconds	1	f	{strategic,sit-and-kick}	f		29	2025-08-05	f
239	76	87		34:47	\N	10th on GRC all-time list, beat several pros, in marathon build	2	t	{impressive,"trained through"}	f		29	2025-08-05	f
240	76	79		36:39	\N	First race of 2025, in marathon build	\N	f	{"strong performance"}	f		29	2025-08-05	f
241	77	8		16:52	\N	Solid performance despite heat-limited training	\N	f	{consistent}	f		29	2025-08-05	f
242	78	19		4:34.9	\N	Altitude-adjusted time of 4:28, kicked hard but nipped at the line, early in training cycle	\N	f	{impressive,altitude-adjusted}	f		29	2025-08-05	f
244	80	8		17:05	\N		1	f	{winner}	f		30	2025-08-12	f
245	81	8		28:23	\N		25	f	{}	f		30	2025-08-12	f
246	82	46		15:02	\N	strong performance after battling persistent illness	1	f	{"battled illness",dominant}	f		31	2025-08-19	f
247	82	29		15:14	\N		2	f	{}	f		31	2025-08-19	f
248	82	47		15:19	\N		3	f	{}	f		31	2025-08-19	f
249	82	16		15:23	\N		6	f	{}	f		31	2025-08-19	f
250	82	55		15:50	\N		9	f	{}	f		31	2025-08-19	f
251	83	44		37:26	\N	solid performance at this stage of the season	40	f	{consistent}	f		31	2025-08-19	f
252	84	89		0:17:33	\N	Looked super relaxed, high fitness level	1	t	{win,"road PR"}	f		32	2025-08-26	f
254	84	39		0:15:48	\N		2	f	{}	f		32	2025-08-26	f
255	84	26		0:16:15	\N		\N	f	{}	f		32	2025-08-26	f
256	84	8		0:17:08	\N		\N	f	{}	f		32	2025-08-26	f
257	85	28		0:55:16	\N	Strong performance on brutal hills	5	f	{"hilly course"}	f		32	2025-08-26	f
258	85	88		1:08:26	\N	Third master, marathon pace, preparing for Berlin	12	f	{"master's division","marathon prep"}	f		32	2025-08-26	f
259	86	18		0:16:51	\N	Fastest time on course since 2015, fourth alum	10	f	{alumni}	f		32	2025-08-26	f
260	87	29		0:15:59	\N	Fifth straight win at prestigious event	1	f	{win,"consecutive wins"}	f		32	2025-08-26	f
261	88	54		0:34:01	\N	First time racing outside of the US, not fully rested	23	f	{international,"tangent running"}	f		33	2025-09-02	f
262	89	55		0:18:37	\N	Solid start to cross country season	\N	f	{"season opener"}	f		33	2025-09-02	f
263	90	84		0:17:57	\N	Triumphant return, preparing for half marathon debut	2	f	{"hilly course","strong performance"}	f		33	2025-09-02	f
264	91	46		14:38	\N	Course was short due to misplaced cone	1	f	{"title defense","course issue"}	f		34	2025-09-09	f
265	92	84		1:17:43	\N	Half marathon debut, performed well within herself	1	f	{debut,promising}	f		35	2025-09-16	f
266	92	65		1:19:23	\N	Huge PR, in great shape for upcoming marathon	3	t	{breakthrough,"strong performance"}	f		35	2025-09-16	f
267	92	61		1:20:28	\N	Rough day, expected to perform better at Indy	\N	f	{"challenging conditions"}	f		35	2025-09-16	f
268	92	67		1:20:55	\N	Struggled with heat, might focus on shorter distances	\N	f	{"heat impact"}	f		35	2025-09-16	f
269	92	7		1:08:11	\N	Big PR, fit to run faster	4	t	{PR,"strong potential"}	f		35	2025-09-16	f
270	92	42		1:08:34	\N	Solid performance	5	f	{consistent}	f		35	2025-09-16	f
271	92	47		1:10:24	\N	Impressive half marathon debut	\N	f	{debut}	f		35	2025-09-16	f
272	92	28		1:11:56	\N		\N	f	{}	f		35	2025-09-16	f
243	79	73		4:12.28	\N	GRC club record, Malta national record, A standard for 2026 Commonwealth Games	3	t	{breakthrough,"high quality field"}	f		30	2025-08-12	t
273	92	23		1:12:17	\N		\N	f	{}	f		35	2025-09-16	f
274	92	26		1:12:26	\N	Evenly paced	\N	f	{"consistent pacing"}	f		35	2025-09-16	f
275	92	48		1:12:52	\N		\N	f	{}	f		35	2025-09-16	f
276	92	13		1:13:17	\N		\N	f	{}	f		35	2025-09-16	f
277	92	54		1:14:25	\N		\N	f	{}	f		35	2025-09-16	f
278	93	64		17:38	\N	GRC debut, first ever 5k	1	t	{debut,PR,promising}	f		35	2025-09-16	f
279	93	72		17:41	\N	Best performance since college	2	f	{"strong comeback"}	f		35	2025-09-16	f
280	93	15		15:59	\N	Led the entire race	1	f	{dominant}	f		35	2025-09-16	f
281	93	8		17:27	\N		2	f	{}	f		35	2025-09-16	f
282	94	21		22:53	\N	Fifth in non-professional field, had a bear encounter	5	f	{challenging,"mountain race"}	f		35	2025-09-16	f
283	95	87		2:50:29	\N	Ready for OTQ, prevented by heat	\N	f	{"fought hard","tough conditions"}	f		36	2025-09-23	f
284	95	91		2:51:02	\N	Solid performance in difficult conditions	\N	f	{"fought hard","tough conditions"}	f		36	2025-09-23	f
285	95	83		2:53:55	\N	PR in atrocious conditions, fitness level high	\N	t	{"breakthrough potential","tough conditions"}	f		36	2025-09-23	f
286	95	69		3:04:46	\N	Fought hard to avoid dropping out	\N	f	{persistent,"breakthrough potential"}	f		36	2025-09-23	f
287	95	88		3:08:35	\N	Fastest of her 5 major marathons, even paced	\N	f	{consistent,"strong second half"}	f		36	2025-09-23	f
288	95	32		2:42:09	\N	In PR shape, suffered in heat, not enjoying race after 18 miles	\N	f	{"tough conditions"}	f		36	2025-09-23	f
289	96	81		1:16:47	\N	First race in a year, tenth on GRC all-time list	\N	t	{"big breakthrough"}	f		36	2025-09-23	f
290	96	89		1:17:42	\N	PR in competitive field, overcoming hurdles	3	t	{competitive,"breakthrough potential"}	f		36	2025-09-23	f
291	97	16		1:11:01	\N	Successful half debut, win on slow course	1	f	{debut,winner}	f		36	2025-09-23	f
292	98	64		27:53	\N	Sixth on GRC list, world-class talent	1	f	{winner}	f		36	2025-09-23	f
293	98	101		24:27	\N	Impressive win	1	f	{winner}	f		36	2025-09-23	f
294	98	47		25:30	\N	Same time as last year, ran hard half six days earlier	3	f	{}	f		36	2025-09-23	f
295	99	73		4:52	\N	Excellent run after two-week break	1	f	{winner}	f		36	2025-09-23	f
296	100	7		0:51:59	\N	Ran well on brutally hilly course in pouring rain	11	f	{hilly,rainy,"international field"}	f		37	2025-09-30	f
297	100	34		0:53:09	\N	Successful 10 mile debut	13	f	{debut}	f		37	2025-09-30	f
298	100	19		0:55:39	\N	Met goal of finishing in top 20	19	f	{"goal achieved"}	f		37	2025-09-30	f
299	100	27		0:56:03	\N	Thoroughly enjoyed the experience	21	f	{enjoyable}	f		37	2025-09-30	f
300	101	46		0:14:46	\N	Has more potential for strong performances	2	f	{potential}	f		37	2025-09-30	f
301	101	101		0:15:36	\N		3	f	{}	f		37	2025-09-30	f
302	101	55		0:15:55	\N	Ran in tempo effort	4	f	{tempo}	f		37	2025-09-30	f
303	102	29		0:15:31	\N	Solo win	1	f	{winner}	f		37	2025-09-30	f
304	102	73		0:17:29	\N	Won race	1	f	{winner}	f		37	2025-09-30	f
305	103	49		24:39	\N	Just off his college PR	24	f	{"triumphant return"}	f		38	2025-10-07	f
306	103	55		24:42	\N	20 seconds faster than last year	26	f	{"triumphant return"}	f		38	2025-10-07	f
307	103	20		25:25	\N		\N	f	{}	f		38	2025-10-07	f
308	103	45		25:45	\N	GRC debut, best XC race of his life	\N	t	{"huge PR"}	f		38	2025-10-07	f
309	103	26		25:54	\N		\N	f	{}	f		38	2025-10-07	f
310	103	35		26:04	\N	First race in a while	\N	f	{}	f		38	2025-10-07	f
311	104	89		2:46:46	\N	Overcame health issues, kept pace even for 23 miles, struggled with heat in final miles	3	t	{breakthrough,competitive}	f		39	2025-10-14	f
312	104	51		2:28:38	\N	Attempted Olympic Trials qualifying, aggressive early pace, struggled after 25k	\N	f	{courageous,risk-taker}	f		39	2025-10-14	f
313	105	7		52:10	\N		12	f	{}	f		39	2025-10-14	f
314	105	50		52:53	\N		\N	f	{}	f		39	2025-10-14	f
315	105	23		53:10	\N		\N	f	{}	f		39	2025-10-14	f
316	105	15		54:49	\N		\N	f	{}	f		39	2025-10-14	f
317	105	44		55:29	\N		\N	f	{}	f		39	2025-10-14	f
318	105	54		56:26	\N		\N	f	{}	f		39	2025-10-14	f
319	105	63		1:00:43	\N	Ran steady 6:05 pace, felt good with plenty of energy	\N	f	{consistent}	f		39	2025-10-14	f
320	105	76		1:11:01	\N	Surpassed goal, strong finish in last 3 miles	\N	f	{"strong finish"}	f		39	2025-10-14	f
321	106	64		17:24	\N	Lost to a 2:18 marathoner, continuing return to full fitness	2	f	{competitive}	f		39	2025-10-14	f
322	107	74		0:21:23	\N	Race debut for GRC, led from around 4k, unchallenged win	1	f	{triumphant,confident}	f		40	2025-10-21	f
323	107	72		0:21:55	\N	Best performance in GRC uniform	4	f	{strong}	f		40	2025-10-21	f
324	107	68		0:22:05	\N	First race since last year, overcoming back issues	6	t	{comeback}	f		40	2025-10-21	f
325	107	71		0:22:34	\N	GRC debut	21	f	{potential}	f		40	2025-10-21	f
326	107	34		0:24:11	\N	20 seconds faster than course record, but finished second	2	f	{aggressive}	f		40	2025-10-21	f
327	107	55		0:25:00	\N	Preparing for Clubs race	8	f	{}	f		40	2025-10-21	f
328	107	29		0:25:12	\N	Very good shape for current training cycle	\N	f	{strong}	f		40	2025-10-21	f
329	107	45		0:25:51	\N	Continuing to impress	\N	f	{}	f		40	2025-10-21	f
330	107	16		0:25:59	\N		\N	f	{}	f		40	2025-10-21	f
331	107	47		0:26:04	\N		\N	f	{}	f		40	2025-10-21	f
332	108	46		0:14:49	\N	50th road 5k victory	1	f	{milestone}	f		40	2025-10-21	f
333	108	39		0:15:29	\N		3	f	{solid}	f		40	2025-10-21	f
334	109	43		0:17:15	\N	Third in age group, hilly course with rough conditions	4	f	{medal}	f		40	2025-10-21	f
335	110	42		2:27:48	\N	Ran solo for last 10 miles, exceeded expectations	11	f	{"strong performance","consistent pace"}	f		41	2025-10-28	f
336	111	28		15:30	\N	Solo win, course shortened to 5k	1	f	{"first place","solo effort"}	f		41	2025-10-28	f
337	112	76		3:26:02	\N	Struggled after 15 miles, focused on not walking	\N	f	{gutsy,painful}	f		42	2025-11-04	f
338	113	34		15:29	\N	Solo win on hilly course	1	f	{"solo win"}	f		42	2025-11-04	f
339	113	45		16:22	\N		2	f	{}	f		42	2025-11-04	f
340	113	71		18:22	\N	Women's winner	1	f	{"strong performance"}	f		42	2025-11-04	f
341	114	64		35:41	\N	Impressive performance on the course	1	f	{"course win"}	f		42	2025-11-04	f
342	114	88		40:14	\N	Return to action after Berlin	\N	f	{comeback}	f		42	2025-11-04	f
343	114	15		32:41	\N	Nice personal record	2	t	{PR}	f		42	2025-11-04	f
344	115	18		17:46	\N	Held off local teenagers, recovering from illness	1	f	{win}	f		42	2025-11-04	f
345	116	61		2:42:38	\N	Attempted Olympic Trials Qualifier (OTQ), struggled in final miles	\N	f	{gutsy,ambitious}	f		43	2025-11-11	f
346	116	81		2:47:29	\N	Marathon debut, ran strong until 35k	\N	t	{debut,promising}	f		43	2025-11-11	f
347	117	49		1:05:35	\N	Solid performance on harder course during marathon training	\N	f	{tough,"fought hard"}	f		43	2025-11-11	f
348	117	7		1:07:20	\N	Strong race with effective settling	\N	t	{"big PR"}	f		43	2025-11-11	f
349	117	22		1:08:14	\N	Best race of his career with negative split	\N	t	{"career best","negative split"}	f		43	2025-11-11	f
350	117	19		1:09:37	\N	Not representative of current fitness	\N	f	{"off day"}	f		43	2025-11-11	f
351	117	63		1:18:41	\N	Impressive performance despite knee issues before race	\N	t	{"huge PR","overcoming injury"}	f		43	2025-11-11	f
352	118	34		1:06:25	\N	Solo win, debut half marathon	1	t	{epic,breakthrough}	f		44	2025-11-18	f
353	118	50		1:07:22	\N	Long-awaited PR before CIM	3	t	{breakthrough}	f		44	2025-11-18	f
354	118	48		1:09:41	\N	Major breakthrough, targeting CIM	\N	t	{breakthrough}	f		44	2025-11-18	f
355	118	15		1:09:50	\N	Huge PR, quantum leap on roads	\N	t	{breakthrough}	f		44	2025-11-18	f
356	118	54		1:12:20	\N	Solid tuneup for CIM	\N	f	{tuneup}	f		44	2025-11-18	f
357	119	26		24:46	\N	Best race of his career	5	t	{breakthrough,"major step"}	f		44	2025-11-18	f
358	119	28		24:55	\N	PR on fast course after racing hilly Baltimore courses	\N	t	{PR}	f		44	2025-11-18	f
360	120	6		14:26	\N	Close battle with Damian, second on GRC list	2	f	{competitive}	f		44	2025-11-18	f
361	120	46		14:52	\N		3	f	{}	f		44	2025-11-18	f
362	120	47		15:03	\N		4	f	{}	f		44	2025-11-18	f
363	120	16		15:05	\N		5	f	{}	f		44	2025-11-18	f
364	120	56		15:09	\N	GRC debut	6	t	{debut}	f		44	2025-11-18	f
365	120	39		15:22	\N		8	f	{}	f		44	2025-11-18	f
366	120	45		15:27	\N	Road PR	9	t	{"road PR"}	f		44	2025-11-18	f
367	120	29		16:11	\N	Recovering from medical issue	\N	f	{recovery}	f		44	2025-11-18	f
368	120	64		16:46	\N	First 5k race, technical PR, potential for faster time	1	t	{win,debut}	f		44	2025-11-18	f
369	120	85		17:01	\N	GRC debut, road PR	2	t	{"road PR",debut}	f		44	2025-11-18	f
370	120	84		17:06	\N	Road PR, evenly paced	3	t	{"road PR",consistent}	f		44	2025-11-18	f
371	120	74		17:18	\N	Promising run preparing for indoors	4	f	{promising}	f		44	2025-11-18	f
372	120	75		17:24	\N	GRC debut	5	t	{debut}	f		44	2025-11-18	f
373	120	68		17:33	\N	Huge PR, preparing for turkey trot duel	6	t	{"huge PR"}	f		44	2025-11-18	f
374	120	72		17:46	\N		7	f	{}	f		44	2025-11-18	f
375	120	86		18:33	\N		\N	f	{}	f		44	2025-11-18	f
376	120	78		22:09	\N	Accomplished goal of walking less than twice	\N	f	{"goal achieved"}	f		44	2025-11-18	f
378	121	24		0:23:54	\N	Despite limited training due to work travel	8	t	{"surprising performance"}	f		45	2025-11-25	f
379	121	45		0:25:12	\N	Fell at start, had to scramble to get upright	5	t	{resilient}	f		45	2025-11-25	f
380	122	65		2:47:39	\N	Battled through rough patches in miles 18-19, finished strong with sub-6 last mile	4	t	{breakthrough,"mental toughness"}	f		45	2025-11-25	f
381	122	36		2:27:46	\N	Fought through 'no man's land' after mile 18	7	t	{perseverance}	f		45	2025-11-25	f
382	122	13		2:29:40	\N	Marathon debut, stomach issues after mile 18, recovered and finished strong	12	t	{debut,resilient}	f		45	2025-11-25	f
383	123	6		0:23:37	\N	Led wire to wire, solo for second half	1	f	{impressive,dominant}	f		46	2025-12-02	f
384	123	46		0:24:45	\N	Strong performance	4	f	{}	f		46	2025-12-02	f
385	123	47		0:25:19	\N		\N	f	{}	f		46	2025-12-02	f
386	123	45		0:25:20	\N	Personal record	\N	t	{PR}	f		46	2025-12-02	f
387	123	15		0:25:28	\N	Continued breakthrough season	\N	t	{PR,breakthrough}	f		46	2025-12-02	f
388	123	37		0:25:42	\N		\N	f	{}	f		46	2025-12-02	f
389	123	54		0:26:35	\N		\N	f	{}	f		46	2025-12-02	f
390	123	18		0:26:51	\N	Encouraging return after illness	\N	f	{comeback}	f		46	2025-12-02	f
391	123	8		0:28:07	\N		\N	f	{}	f		46	2025-12-02	f
392	123	64		0:27:49	\N	Sixth on GRC all-time list, continuing fitness journey	4	f	{"all-time list"}	f		46	2025-12-02	f
393	123	85		0:27:57	\N	Seventh on GRC all-time list	6	t	{PR,"all-time list"}	f		46	2025-12-02	f
394	123	84		0:28:08	\N	Ninth on GRC all-time list	7	f	{"all-time list"}	f		46	2025-12-02	f
395	123	87		0:28:24	\N	First race post-Berlin, continuing to build fitness	\N	f	{post-marathon}	f		46	2025-12-02	f
396	123	66		0:28:58	\N	First time breaking 30, skipped 29s entirely	\N	t	{PR,breakthrough}	f		46	2025-12-02	f
397	123	77		0:29:20	\N	GRC debut, promising talent	\N	t	{PR,debut}	f		46	2025-12-02	f
398	123	82		0:31:49	\N	Impressive return post-partum	\N	f	{post-partum}	f		46	2025-12-02	f
399	123	70		0:32:09	\N	Impressive return post-partum	\N	f	{post-partum}	f		46	2025-12-02	f
400	124	48		0:15:21	\N	Won race, beat middle schoolers	1	f	{dominant}	f		46	2025-12-02	f
401	125	28		0:15:51	\N	Won on a very hilly course	1	f	{hilly}	f		46	2025-12-02	f
402	125	67		0:18:16	\N	Strong second place	2	f	{}	f		46	2025-12-02	f
403	126	68		0:29:59	\N	Twin beat her this time	\N	f	{"sibling rivalry"}	f		46	2025-12-02	f
404	127	88			\N	First master	5	f	{masters}	f		46	2025-12-02	f
405	128	39		0:20:33	\N	Won the race	1	f	{dominant}	f		46	2025-12-02	f
406	129	49		2:19:20	\N	Took shot at OTQ, started strong through 17 miles	\N	t	{breakthrough,aggressive}	f		47	2025-12-09	f
407	129	50		2:23:02	\N	Experienced hamstring distress in last 10k	\N	t	{tough,persevered}	f		47	2025-12-09	f
408	129	19		2:23:44	\N	Negative split, trusted fitness despite poor tune-up races	\N	t	{"negative split",breakthrough}	f		47	2025-12-09	f
409	129	7		2:25:45	\N	Aggressive start, weathered tough last 10k	\N	t	{aggressive,resilient}	f		47	2025-12-09	f
410	129	48		2:27:23	\N	Continued breakthrough season, well-earned result	\N	t	{breakthrough,consistent}	f		47	2025-12-09	f
411	129	22		2:29:37	\N	Held back early, negative split	\N	t	{strategic,"negative split"}	f		47	2025-12-09	f
412	129	54		2:32:54	\N	Best race of career, completely exhausted at finish	\N	t	{breakthrough,gutsy}	f		47	2025-12-09	f
413	129	27		2:28:52	\N	Tough day despite good training cycle	\N	f	{challenging}	f		47	2025-12-09	f
414	130	34			\N	Competed on muddy course, stride for stride with Woody Kincaid	47	f	{competitive,"muddy conditions"}	f		47	2025-12-09	f
415	131	74		4:47.58	\N	Second on all-time list, strategic race	\N	f	{strategic,"strong finish"}	f		47	2025-12-09	f
416	132	16		1:57.82	\N	Solid season opener	2	f	{promising}	f		47	2025-12-09	f
417	132	9		2:01.65	\N		4	f	{}	f		47	2025-12-09	f
418	133	39		15:11.35	\N	Strong performance	\N	f	{strong}	f		47	2025-12-09	f
419	133	45		15:26.26	\N		\N	f	{}	f		47	2025-12-09	f
420	134	26		1:11:31	\N	In excellent shape	4	f	{strong}	f		47	2025-12-09	f
421	135	73		4:37	\N	Malta national record, fastest opener	3	f	{record,promising}	f		47	2025-12-09	f
43	18	5		47:10	\N	Competitive field with international athletes	31	f	{"strong performance"}	f		8	2025-03-04	f
101	30	5		0:50:10	\N	Boston Marathon tuneup without backing off training	\N	f	{tuneup}	f		13	2025-04-08	f
123	35	5		2:24:39	\N	Excellent effort, fit to run faster	\N	f	{determined}	f		15	2025-04-22	f
253	84	16		0:15:18	\N	Defended title, could be three-peat next year	\N	f	{"defending champion"}	f		32	2025-08-26	f
162	45	44		0:53:19	\N		\N	f	{}	f		17	2025-05-06	f
198	54	73		2:03.29	\N	Club record, best race of career, ran controlled and in command	4	t	{outstanding,"club record","international field"}	f		21	2025-06-17	t
212	63	73		2:03.13	\N	Beat Laura Muir, club record	3	t	{triumphant,"tactical race"}	f		24	2025-07-08	t
359	120	14		14:25	\N	GRC debut, club record	1	t	{"club record",win}	f		44	2025-11-18	t
377	121	6		0:23:15	\N	Broke club record, pushed pace from start, passed two runners in last mile	3	t	{competitive,breakthrough,podium}	f		45	2025-11-25	t
\.


--
-- Data for Name: races; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.races (id, name, date, year, distance, type, notes, email_id) FROM stdin;
1	Houston Marathon	2025-01-22	2025	Marathon	RD	\N	2
2	Houston Half Marathon	2025-01-22	2025	Half Marathon	RD	\N	2
3	Cardinal Classic	2025-01-22	2025	3000m, Mile	TF	\N	2
4	Bermuda Triangle Challenge	2025-01-22	2025	Mile, 10k, Half Marathon	RD	\N	2
5	Penn 10 Team Elite	2025-01-25	2025	3000m	TF	\N	3
6	Liberty Tolsma Invitational	2025-01-25	2025	Mile	TF	\N	3
7	Armed Forces XC Championships	2025-01-25	2025	XC	XC	\N	3
8	Marlin Invitational	2025-02-05	2025	800m	TF	\N	4
9	Lake Patuxent River Trail Half Marathon	2025-02-05	2025	Half Marathon	TR	\N	4
10	Millrose Games Distance Medley Relay	2025-02-12	2025	DMR	TF	\N	5
11	BU Scarlett and White Invitational	2025-02-12	2025	5000m	TF	\N	5
12	BU Valentine Indoor Meet	2025-02-18	2025	800m	TF	\N	6
13	Greenville Half Marathon	2025-02-26	2025	Half Marathon	RD	\N	7
14	Navy Select	2025-02-26	2025	Mile	TF	\N	7
15	RRCA 10 Mile	2025-02-26	2025	10 Mile	RD	\N	7
16	Spring Thaw 10	2025-02-26	2025	10 Mile	RD	\N	7
17	USATF Half Marathon Championship	2025-03-02	2025	Half Marathon	RD	\N	8
18	Gate River 15k	2025-03-02	2025	15k	RD	\N	8
19	Tim Kenard 10 mile	2025-03-02	2025	10 mile	RD	\N	8
20	Philly Runner TC Indoor Classic	2025-03-12	2025	800m, Mile, 3000m	TF	\N	9
21	DC Rock 'n' Roll Half Marathon	2025-03-19	2025	Half Marathon	RD	\N	10
22	Shamrock Marathon	2025-03-19	2025	Marathon	RD	\N	10
23	Shamrock 5k	2025-03-19	2025	5k	RD	\N	10
24	Project 13.1 Half	2025-03-26	2025	Half Marathon	RD	\N	11
25	Terrapin Mountain 50k	2025-03-26	2025	50k	TR	\N	11
26	Heartbreaker 55k Trail Race	2025-03-26	2025	55k	TR	\N	11
27	Fred Hardy Invite	2025-03-26	2025	5000m	TF	\N	11
28	Virginia Fire Chiefs Foundation 5k	2025-03-26	2025	5k	RD	\N	11
29	Maryland Invitational	2025-04-02	2025	1500m	TF	\N	12
30	Cherry Blossom	2025-04-09	2025	10 mile	RD	\N	13
31	Bucknell Outdoor Classic	2025-04-16	2025	10,000m	TF	\N	14
32	Dennis Craddock Classic	2025-04-16	2025	1 mile	TF	\N	14
33	Coastal Delaware Running Festival	2025-04-16	2025	5k	RD	\N	14
34	Our Lady of Lourdes 5k	2025-04-16	2025	5k	RD	\N	14
35	Boston Marathon	2025-04-22	2025	Marathon	RD	\N	15
36	Bryan Clay Invitational	2025-04-22	2025	1500m	TF	\N	15
37	Hopkins Loyola Invite	2025-04-22	2025	1500m	TF	\N	15
38	Captains Classic	2025-04-22	2025	1500m	TF	\N	15
39	Sean Collier Invitational	2025-04-22	2025	1500m	TF	\N	15
40	DOG Street 5k	2025-04-22	2025	5k	RD	\N	15
41	Drake Relays	2025-04-26	2025	800m	TF	\N	16
42	Penn Relays	2025-04-26	2025	5000m	TF	\N	16
43	Alexandria Half	2025-04-26	2025	Half Marathon	RD	\N	16
44	Pikes Peak 10k	2025-04-26	2025	10k	RD	\N	16
45	Broad Street Run	2025-05-04	2025	10 mile	RD	\N	17
46	USATF 5k Road Championships	2025-05-04	2025	5k	RD	\N	17
47	Larry Ellis Invite	2025-05-04	2025	1500m	TF	\N	17
48	Maryland Twilight	2025-05-04	2025	800m/1500m	TF	\N	17
49	Down the Stretch Track Fest	\N	2025	Mile	TF	\N	18
50	Tracksmith 5000	2025-05-31	2025	5000m	TF	\N	18
51	Loudon Street Mile	\N	2025	Mile	RD	\N	18
52	Games of the Small States of Europe	2025-06-04	2025	800m, 1500m, 5000m	TF	\N	19
53	Bel Air Town Run	2025-06-04	2025	5k	RD	\N	19
54	Johnny Lorring Classic	2025-06-18	2025	800m	TF	\N	21
55	Portland Track Festival	2025-06-18	2025	5000m	TF	\N	21
56	Run Unbridled Track Fest	2025-06-18	2025	800m	TF	\N	21
57	USATF 4 Mile Championships	2025-06-18	2025	4 miles	RD	\N	21
58	Suds and Soles 5k	2025-06-18	2025	5k	RD	\N	21
59	Grandma's Marathon	2025-06-25	2025	Full Marathon	RD	\N	22
60	Grandma's Half Marathon	2025-06-25	2025	Half Marathon	RD	\N	22
61	Manitous Revenge	\N	2025	50 miles	TR	\N	22
62	New Jersey International Mile	\N	2025	1 mile	TF	\N	22
63	Boysen Memorial	2025-07-02	2025	800m	TF	\N	24
64	Malta Nationals 800m	2025-07-04	2025	800m	TF	\N	24
65	Malta Nationals 1500m	2025-07-04	2025	1500m	TF	\N	24
66	Firecracker 5k	2025-07-04	2025	5k	RD	\N	24
67	Autism Speaks 5k	2025-07-04	2025	5k	RD	\N	24
68	Hingham Fourth of July Road Race	2025-07-04	2025	4.5 miles	RD	\N	24
69	Freedom 5k	2025-07-04	2025	5k	RD	\N	24
70	Bridgton 4 on the Fourth	2025-07-04	2025	4 miles	RD	\N	24
71	Boilermaker 15k	2025-07-15	2025	15k	RD	\N	26
72	Packers 5k	2025-07-23	2025	5k	RD	\N	27
73	Bix 7 Mile	2025-07-27	2025	7 miles	RD	\N	28
74	White River 50 Miler	2025-07-27	2025	50 miles	UL	\N	28
75	Brooklyn Mile	2025-08-06	2025	1 mile	RD	\N	29
76	Beach to Beacon 10k	2025-08-06	2025	10k	RD	\N	29
77	St Barnabas 5k	2025-08-06	2025	5k	RD	\N	29
78	CU Boulder All-Comers Meet	2025-08-06	2025	1 mile	TF	\N	29
79	La Classique D'Athletisme	2025-08-12	2025	1500m	TF	\N	30
80	Brookline Breeze 5k	2025-08-12	2025	5k	RD	\N	30
81	Lake Loop 5 Mile	2025-08-12	2025	5 mile	RD	\N	30
82	Chocolate City Criterium 5k	2025-08-19	2025	5k	RD	\N	31
83	Falmouth Race	2025-08-19	2025	Unspecified	RD	\N	31
84	NOVA 5k	2025-08-27	2025	5k	RD	\N	32
85	Annapolis 10 Mile	2025-08-27	2025	10 mile	RD	\N	32
86	Gettysburg Alumni XC Race	2025-08-27	2025	5k	XC	\N	32
87	Ditch Digger 5k	2025-08-27	2025	5k	RD	\N	32
88	10k Hexagone Trocadero	2025-09-02	2025	10k	RD	\N	33
89	Lehigh Invitational	2025-09-02	2025	XC	XC	\N	33
90	RPI Alumni XC Race	2025-09-02	2025	XC	XC	\N	33
91	9-11 Memorial 5k	2025-09-09	2025	5k	RD	\N	34
92	DC Half	2025-09-17	2025	Half Marathon	RD	\N	35
93	5k Race	2025-09-17	2025	5k	RD	\N	35
94	Run Rabbit Run 100 Mile	2025-09-17	2025	100 Mile	UL	\N	35
95	Berlin Marathon	2025-09-23	2025	Marathon	RD	\N	36
96	Philadelphia Distance Run	2025-09-23	2025	Half Marathon	RD	\N	36
97	Parks Half Marathon	2025-09-23	2025	Half Marathon	RD	\N	36
98	Kensington 8k	2025-09-23	2025	8k	RD	\N	36
99	Foundry Mile	2025-09-23	2025	1 Mile	RD	\N	36
100	Virginia 10 Miler	2025-09-30	2025	10 mile	RD	\N	37
101	Run Geek Run 5k	2025-09-30	2025	5k	RD	\N	37
102	Dulles 5k	2025-09-30	2025	5k	RD	\N	37
103	Paul Short XC Open Race	2025-10-08	2025	8k	XC	\N	38
104	Chicago Marathon	2025-10-14	2025	Marathon	RD	\N	39
105	Army 10 Mile	2025-10-14	2025	10 Mile	RD	\N	39
106	Great African Run 5k	2025-10-14	2025	5k	RD	\N	39
107	Gettysburg XC	2025-10-21	2025	6k	XC	\N	40
108	Race For Every Child 5k	2025-10-21	2025	5k	RD	\N	40
109	USATF Masters Road 5k Championship	2025-10-21	2025	5k	RD	\N	40
110	Marine Corps Marathon	2025-10-28	2025	marathon	RD	\N	41
111	Port to Fort	2025-10-28	2025	5k	RD	\N	41
112	New York Marathon	2025-11-04	2025	Marathon	RD	\N	42
113	Rockville 5k	2025-11-04	2025	5k	RD	\N	42
114	Rockville 10k	2025-11-04	2025	10k	RD	\N	42
115	Long Branch 5k	2025-11-04	2025	5k	RD	\N	42
116	Indianapolis Marathon	2025-11-12	2025	Marathon	RD	\N	43
117	Half Marathon	2025-11-12	2025	Half Marathon	RD	\N	43
118	Richmond Half Marathon	2025-11-16	2025	Half Marathon	RD	\N	44
119	Richmond 8k	2025-11-16	2025	8k	RD	\N	44
120	St Ritas 5k	2025-11-16	2025	5k	RD	\N	44
121	Philadelphia 8k	2025-11-23	2025	8k	RD	\N	45
122	Philadelphia Marathon	2025-11-23	2025	Marathon	RD	\N	45
123	Alexandria Turkey Trot	2025-11-27	2025	5 mile	RD	\N	46
124	Arlington Turkey Trot	2025-11-27	2025	5k	RD	\N	46
125	Towson Turkey Trot	2025-11-27	2025	5k	RD	\N	46
126	Ridgewood Turkey Trot	2025-11-27	2025	8k	RD	\N	46
127	Asheville Turkey Trot	2025-11-27	2025	5k	RD	\N	46
128	San Antonio Road Runners	2025-11-27	2025	4 mile	RD	\N	46
129	California International Marathon (CIM)	2025-12-09	2025	Marathon	RD	\N	47
130	USATF XC Championships	2025-12-09	2025	XC	XC	\N	47
131	BU Season Opener	2025-12-09	2025	Mile	TF	\N	47
132	CNU Holiday Open	2025-12-09	2025	800m	TF	\N	47
133	Armory Collegiate Invitational	2025-12-09	2025	5000m	TF	\N	47
134	Raleigh Holiday Half Marathon	2025-12-09	2025	Half Marathon	RD	\N	47
135	La Milla Llanera Road Mile	2025-12-09	2025	Mile	RD	\N	47
\.


--
-- Data for Name: review_flags; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.review_flags (id, flag_type, entity_type, entity_id, reason, mentioned_name, matched_athlete_id, resolved, resolved_by, resolved_at, email_id, created_at) FROM stdin;
1	unknown_athlete	race_result	9	unknown athlete: Elena	Elena	\N	f	\N	\N	2	2025-12-13 11:10:20.079704
2	unknown_athlete	race_result	42	unknown athlete: Tessa	Tessa	\N	f	\N	\N	8	2025-12-13 11:12:27.447627
3	unknown_athlete	race_result	46	unknown athlete: Kelly	Kelly	\N	f	\N	\N	9	2025-12-13 11:12:56.181903
4	unknown_athlete	race_result	59	unknown athlete: Chloe	Chloe	\N	f	\N	\N	10	2025-12-13 11:13:23.212754
5	unknown_athlete	race_result	86	unknown athlete: Cleo	Cleo	\N	f	\N	\N	13	2025-12-13 11:15:05.474226
6	unknown_athlete	race_result	196	unknown athlete: June	June	\N	f	\N	\N	19	2025-12-13 11:18:29.455089
\.


--
-- Data for Name: workout_groups; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.workout_groups (id, workout_id, group_name, description) FROM stdin;
1	1	Base Building Group	
2	1	Catholic Meet Prep Group	
3	1	Houston Marathon Group	
4	2	Group 1	
5	4	Group 1	
6	4	Group 2	
7	4	Group 3	
8	6	Group 1	
9	6	Group 2	
10	6	Group 3	
11	7	Group 1	
12	7	Group 2	
13	7	Group 3	
14	8	Group 1	
15	8	Group 2	
16	8	Group 3	
17	9	Group 1	
18	9	Group 2	
19	9	Group 3	
20	10	Group 1	
21	10	Group 2	
22	10	Group 3	
23	11	Group 1	
24	11	Group 2	
25	11	Group 3	
26	12	Group 1	
27	12	Group 2	
28	12	Group 3	
29	13	Group 1	
30	13	Group 2	
31	13	Group 3	
32	14	Group 1	
33	14	Group 2	
34	14	Group 3	
35	14	Boston Crew	
36	15	Group 1	
37	15	Group 2	
38	15	Group 3	
39	16	Group 1	
40	16	Group 2	
41	16	Group 3	
42	17	Group 1	
43	17	Group 2	
44	17	Group 3	
45	18	Group 1	
46	18	Group 2	
47	18	Group 3	
48	18	Tracksmith 5000 Crew	
49	19	Group 1	
50	19	Group 2	
51	19	Group 3	
52	21	Group 1	
53	21	Group 2	
54	21	Group 3	
55	22	Group 1	
56	22	Group 2	
57	22	Group 3	
58	23	Group 1 (Cam and friends)	
59	23	Group 2	
60	23	Group 3	
61	25	Group 1	
62	25	Group 2	
63	25	Group 3	
64	26	Group 1	
65	26	Group 2	
66	26	Group 3	
67	27	Group 1	
68	27	Group 2	
69	27	Group 3	
70	28	Group 1	
71	28	Group 2	
72	28	Group 3	
73	29	Group 1	
74	29	Group 2	
75	29	Group 3	
76	30	Group 1	
77	30	Group 2	
78	30	Group 3	
79	31	Group 1	
80	31	Group 2	
81	31	Group 3	
82	32	Group 1	
83	32	Group 2	
84	32	Group 3	
85	33	Group 1	
86	33	Group 2	
87	33	Group 3	
88	34	Group 1	
89	34	Group 2	
90	34	Group 3	
91	34	DC Half Participants	
92	35	Group 1	
93	35	Group 2	
94	35	Group 3	
95	36	Group 1	
96	36	Group 2	
97	36	Group 3	
98	37	Group 1	
99	37	Group 2	
100	37	Group 3	
101	38	Group 1	
102	38	Group 2	
103	38	Group 3	
104	39	Group 1	
105	39	Group 2	
106	39	Group 3	
107	40	Group 1	
108	40	Group 2	
109	40	Group 3	
110	41	Group 1	
111	41	Group 2	
112	41	Group 3	
113	42	Group 1	
114	42	Group 2	
115	42	Group 3	
116	43	Group 1	
117	43	Group 2	
118	43	Group 3	
119	43	Racing Group	
120	44	Group 1	
121	44	Group 2	
122	44	Group 3	
123	46	Group 1	
124	46	Group 2	
125	46	Group 3	
126	47	Group 1	
127	47	Group 2	
128	47	Group 3	
\.


--
-- Data for Name: workout_segments; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.workout_segments (id, workout_group_id, segment_type, repetitions, rest, targets) FROM stdin;
1	1	Longer workout on road loop with hill	0		Distance: 1200m, Pace: 
2	2	Short workout	0		Distance: , Pace: 
3	3	Very light workout on flat terrain	0		Distance: , Pace: 
4	5	1600m repeats	5	2:00	Distance: 1600m, Pace: 75, 74, 73, 72, 71 seconds per 400m
5	5	400m repeats	4	45 seconds	Distance: 400m, Pace: 2 @ 68, 2 @ 66 seconds
6	6	1600m repeats	5	2:00	Distance: 1600m, Pace: 78, 77, 76, 75, 74 seconds per 400m
7	6	400m repeats	4	45 seconds	Distance: 400m, Pace: 2 @ 71, 2 @ 69 seconds
8	7	1600m repeats	5	2:00	Distance: 1600m, Pace: 81, 80, 79, 78, 77 seconds per 400m
9	7	400m repeats	4	45 seconds	Distance: 400m, Pace: 2 @ 74, 2 @ 72 seconds
10	8	Descending pace 1200m intervals	5	2:00 (3:00 after last rep)	Distance: 1200m, Pace: 73, 72, 71, 70, 69
11	8	600m intervals in two sets	8	1:30 within set, 3:00 between sets	Distance: 600m, Pace: 67 (set 1), 65 (set 2)
12	9	Descending pace 1200m intervals	5	2:00 (3:00 after last rep)	Distance: 1200m, Pace: 76, 75, 74, 73, 72
13	9	600m intervals in two sets	8	1:30 within set, 3:00 between sets	Distance: 600m, Pace: 70 (set 1), 68 (set 2)
14	10	Descending pace 1200m intervals	5	2:00 (3:00 after last rep)	Distance: 1200m, Pace: 79, 78, 77, 76, 75
15	10	600m intervals in two sets	8	1:30 within set, 3:00 between sets	Distance: 600m, Pace: 73 (set 1), 71 (set 2)
16	11	3x 2k	3	2:00	Distance: 2k, Pace: 74, 73, 72 seconds per 2k
17	11	4x 1k	4	3:00	Distance: 1k, Pace: 70, 69, 68, 67 seconds per 1k
18	12	3x 2k	3	2:00	Distance: 2k, Pace: 77, 76, 75 seconds per 2k
19	12	4x 1k	4	3:00	Distance: 1k, Pace: 73, 72, 71, 70 seconds per 1k
20	13	3x 2k	3	2:00	Distance: 2k, Pace: 80, 79, 78 seconds per 2k
21	13	4x 1k	4	3:00	Distance: 1k, Pace: 76, 75, 74, 73 seconds per 1k
22	14	1x 3200m	1	2:00	Distance: 3200m, Pace: 74 seconds per 400m
23	14	1x 2400m	1	2:00	Distance: 2400m, Pace: 72 seconds per 400m
24	14	1x 1600m	1	2:00	Distance: 1600m, Pace: 70 seconds per 400m
25	14	1x 800m	1	2:00	Distance: 800m, Pace: 68 seconds per 400m
26	14	1x 800m	1	2:00	Distance: 800m, Pace: 67 seconds per 400m
27	14	1x 800m	1	2:00	Distance: 800m, Pace: 66 seconds per 400m
28	15	1x 3200m	1	2:00	Distance: 3200m, Pace: 76 seconds per 400m
29	15	1x 2400m	1	2:00	Distance: 2400m, Pace: 74 seconds per 400m
30	15	1x 1600m	1	2:00	Distance: 1600m, Pace: 72 seconds per 400m
31	15	1x 800m	1	2:00	Distance: 800m, Pace: 70 seconds per 400m
32	15	1x 800m	1	2:00	Distance: 800m, Pace: 69 seconds per 400m
33	15	1x 800m	1	2:00	Distance: 800m, Pace: 68 seconds per 400m
34	16	1x 3200m	1	2:00	Distance: 3200m, Pace: 79 seconds per 400m
35	16	1x 2400m	1	2:00	Distance: 2400m, Pace: 77 seconds per 400m
36	16	1x 1600m	1	2:00	Distance: 1600m, Pace: 75 seconds per 400m
37	16	1x 800m	1	2:00	Distance: 800m, Pace: 73 seconds per 400m
38	16	1x 800m	1	2:00	Distance: 800m, Pace: 72 seconds per 400m
39	16	1x 800m	1	2:00	Distance: 800m, Pace: 71 seconds per 400m
40	17	First set with descending pace	3	1:30	Distance: 2400m, Pace: 73-68 seconds per lap
41	17	Fast 800m intervals	3	1:30	Distance: 800m, Pace: 73-68 seconds per lap
42	18	First set with descending pace	3	1:30	Distance: 2400m, Pace: 75-70 seconds per lap
43	18	Fast 800m intervals	3	1:30	Distance: 800m, Pace: 73-69 seconds per lap
44	19	First set with descending pace	3	1:30	Distance: 2400m, Pace: 78-73 seconds per lap
45	19	Fast 800m intervals	3	1:30	Distance: 800m, Pace: 74-71 seconds per lap
46	20	Progressive 1k repeats with decreasing times	10	2:00	Distance: 1k, Pace: 72, 2 @ 71, 2 @ 70, 2 @ 69, 2 @ 68, 66
47	21	Progressive 1k repeats with decreasing times	10	2:00	Distance: 1k, Pace: 74, 2 @ 73, 2 @ 72, 2 @ 71, 2 @ 70, 68
48	22	Progressive 1k repeats with decreasing times	10	2:00	Distance: 1k, Pace: 77, 2 @ 76, 2 @ 75, 2 @ 74, 2 @ 73, 71
49	23	Mile repeats with decreasing pace	5	2:00, 3:00 after last rep	Distance: 1600m, Pace: 74, 73, 72, 71, 70 seconds per 1600m
50	23	400m repeats with decreasing pace	4	45 seconds	Distance: 400m, Pace: 67, 66, 65, 64 seconds per 400m
51	24	Mile repeats with decreasing pace	5	2:00, 3:00 after last rep	Distance: 1600m, Pace: 76, 75, 74, 73, 72 seconds per 1600m
52	24	400m repeats with decreasing pace	4	45 seconds	Distance: 400m, Pace: 69, 68, 67, 66 seconds per 400m
53	25	Mile repeats with decreasing pace	5	2:00, 3:00 after last rep	Distance: 1600m, Pace: 79, 78, 77, 76, 75 seconds per 1600m
54	25	400m repeats with decreasing pace	4	45 seconds	Distance: 400m, Pace: 72, 71, 70, 69 seconds per 400m
55	26	2x 800m	2	2:00	Distance: 800m, Pace: 72 seconds per 400m
56	26	2x 800m	2	2:00	Distance: 800m, Pace: 70 seconds per 400m
57	26	2x 800m	2	2:00	Distance: 800m, Pace: 68 seconds per 400m
58	26	2x 800m	2	2:00	Distance: 800m, Pace: 66 seconds per 400m
59	27	2x 800m	2	2:00	Distance: 800m, Pace: 74 seconds per 400m
60	27	2x 800m	2	2:00	Distance: 800m, Pace: 72 seconds per 400m
61	27	2x 800m	2	2:00	Distance: 800m, Pace: 70 seconds per 400m
62	27	2x 800m	2	2:00	Distance: 800m, Pace: 68 seconds per 400m
63	28	2x 800m	2	2:00	Distance: 800m, Pace: 77 seconds per 400m
64	28	2x 800m	2	2:00	Distance: 800m, Pace: 75 seconds per 400m
65	28	2x 800m	2	2:00	Distance: 800m, Pace: 73 seconds per 400m
66	28	2x 800m	2	2:00	Distance: 800m, Pace: 71 seconds per 400m
67	29	Descending pace mile repeats	5	2:00	Distance: 1 mile, Pace: 75, 74, 73, 72, 71 seconds per mile
68	30	Descending pace mile repeats	5	2:00	Distance: 1 mile, Pace: 77, 76, 75, 74, 73 seconds per mile
69	31	Descending pace mile repeats	5	2:00	Distance: 1 mile, Pace: 80, 79, 78, 77, 76 seconds per mile
70	32	First set of 4	4	2:00	Distance: 400m, Pace: 71 seconds per 400m
71	32	First set of 3	3	2:00	Distance: 400m, Pace: 69 seconds per 400m
72	32	First set of 2	2	2:00	Distance: 400m, Pace: 67 seconds per 400m
73	32	First set of 1, long rest between sets	1	3:00	Distance: 400m, Pace: 65 seconds per 400m
74	33	First set of 4	4	2:00	Distance: 400m, Pace: 75 seconds per 400m
75	33	First set of 3	3	2:00	Distance: 400m, Pace: 73 seconds per 400m
76	33	First set of 2	2	2:00	Distance: 400m, Pace: 71 seconds per 400m
77	33	First set of 1, long rest between sets	1	3:00	Distance: 400m, Pace: 68 seconds per 400m
78	34	First set of 4	4	2:00	Distance: 400m, Pace: 77 seconds per 400m
79	34	First set of 3	3	2:00	Distance: 400m, Pace: 75 seconds per 400m
80	34	First set of 2	2	2:00	Distance: 400m, Pace: 73 seconds per 400m
81	34	First set of 1, long rest between sets	1	3:00	Distance: 400m, Pace: 70 seconds per 400m
82	35	Flexible 800m repeats	6	2:00	Distance: 800m, Pace: 76 seconds per 800m
83	36	2x 1k	2	2:00	Distance: 1k, Pace: 72 seconds per 1k
84	36	2x 1k	2	2:00	Distance: 1k, Pace: 71 seconds per 1k
85	36	2x 1k	2	2:00	Distance: 1k, Pace: 70 seconds per 1k
86	36	2x 1k	2	2:00	Distance: 1k, Pace: 69 seconds per 1k
87	36	2x 1k	2	2:00	Distance: 1k, Pace: 68 seconds per 1k
88	37	2x 1k	2	2:00	Distance: 1k, Pace: 74 seconds per 1k
89	37	2x 1k	2	2:00	Distance: 1k, Pace: 73 seconds per 1k
90	37	2x 1k	2	2:00	Distance: 1k, Pace: 72 seconds per 1k
91	37	2x 1k	2	2:00	Distance: 1k, Pace: 71 seconds per 1k
92	37	2x 1k	2	2:00	Distance: 1k, Pace: 70 seconds per 1k
93	38	2x 1k	2	2:00	Distance: 1k, Pace: 77 seconds per 1k
94	38	2x 1k	2	2:00	Distance: 1k, Pace: 76 seconds per 1k
95	38	2x 1k	2	2:00	Distance: 1k, Pace: 75 seconds per 1k
96	38	2x 1k	2	2:00	Distance: 1k, Pace: 74 seconds per 1k
97	38	2x 1k	2	2:00	Distance: 1k, Pace: 73 seconds per 1k
98	39	Descending pace 1200m repeats	4	2:00	Distance: 1200m, Pace: 72, 71, 70, 69 seconds per lap
99	39	Descending pace 600m repeats	4	2:00	Distance: 600m, Pace: 67, 66, 65, 64 seconds per lap
100	40	Descending pace 1200m repeats	4	2:00	Distance: 1200m, Pace: 75, 74, 73, 72 seconds per lap
101	40	Descending pace 600m repeats	4	2:00	Distance: 600m, Pace: 70, 69, 68, 67 seconds per lap
102	41	Descending pace 1200m repeats	4	2:00	Distance: 1200m, Pace: 77, 76, 75, 74 seconds per lap
103	41	Descending pace 600m repeats	4	2:00	Distance: 600m, Pace: 72, 71, 70, 69 seconds per lap
104	42	Descending pace mile repeats	5	2:00	Distance: mile, Pace: 75, 74, 73, 72, 71 seconds per 400m
105	43	Moderate pace mile repeats	5	2:00	Distance: mile, Pace: 77, 76, 75, 74, 73 seconds per 400m
106	44	Slower pace mile repeats	5	2:00	Distance: mile, Pace: 80, 79, 78, 77, 76 seconds per 400m
107	45	Descending pace interval workout	6	2:00	Distance: 1600m, Pace: 75, 74, 73, 72, 71, 70 seconds per 400m
108	46	Descending pace interval workout	6	2:00	Distance: 1600m, Pace: 77, 76, 75, 74, 73, 72 seconds per 400m
109	47	Descending pace interval workout	6	2:00	Distance: 1600m, Pace: 80, 79, 78, 77, 76, 75 seconds per 400m
110	48	Pace-specific workout for 5000m race	6	2:00	Distance: 600m, Pace: Goal pace +/- 1 second
111	49	First set of 2400m intervals	2	2:00	Distance: 2400m, Pace: 74, 73
112	49	Second set of 1200m intervals	4	2:00	Distance: 1200m, Pace: 71, 70, 69, 68
113	50	First set of 2400m intervals	2	2:00	Distance: 2400m, Pace: 76, 75
114	50	Second set of 1200m intervals	4	2:00	Distance: 1200m, Pace: 73, 72, 71, 70
115	51	First set of 2400m intervals	2	2:00	Distance: 2400m, Pace: 79, 78
116	51	Second set of 1200m intervals	4	2:00	Distance: 1200m, Pace: 76, 75, 74, 73
117	52	Decreasing pace mile repeats	4	2:00	Distance: 1600m, Pace: 76, 75, 74, 73 seconds per 400m
118	52	Decreasing pace 800m repeats	4	2:00	Distance: 800m, Pace: 71, 70, 69, 68 seconds per 400m
119	53	Decreasing pace mile repeats	4	2:00	Distance: 1600m, Pace: 78, 77, 76, 75 seconds per 400m
120	53	Decreasing pace 800m repeats	4	2:00	Distance: 800m, Pace: 73, 72, 71, 70 seconds per 400m
121	54	Decreasing pace mile repeats	4	2:00	Distance: 1600m, Pace: 81, 80, 79, 78 seconds per 400m
122	54	Decreasing pace 800m repeats	4	2:00	Distance: 800m, Pace: 76, 75, 74, 73 seconds per 400m
123	55	Speedwork with descending intervals	4	45 seconds	Distance: 400m, Pace: 70, 69, 68, 67, 66 seconds per 400m
124	56	Speedwork with descending intervals	4	45 seconds	Distance: 400m, Pace: 73, 72, 71, 70, 69 seconds per 400m
125	57	Speedwork with descending intervals	4	45 seconds	Distance: 400m, Pace: 76, 75, 74, 73, 72 seconds per 400m
126	58	First group's long intervals	4	2:00 (3:00 after last interval)	Distance: 2k, Pace: 75, 74, 73, 72 seconds per 2k
127	58	First group's short intervals	4	1:15	Distance: 500m, Pace: 69, 68, 67, 66 seconds per 500m
128	59	Second group's long intervals	4	2:00 (3:00 after last interval)	Distance: 2k, Pace: 78, 77, 76, 75 seconds per 2k
129	59	Second group's short intervals	4	1:15	Distance: 500m, Pace: 73, 72, 71, 70 seconds per 500m
130	60	Third group's long intervals	4	2:00 (3:00 after last interval)	Distance: 2k, Pace: 81, 80, 79, 78 seconds per 2k
131	60	Third group's short intervals	4	1:15	Distance: 500m, Pace: 76, 75, 74, 73 seconds per 500m
132	61	2x 1k	2	2:00	Distance: 1k, Pace: 72 seconds per 400m
133	61	2x 1k	2	2:00	Distance: 1k, Pace: 71 seconds per 400m
134	61	2x 1k	2	2:00	Distance: 1k, Pace: 70 seconds per 400m
135	61	2x 1k	2	2:00	Distance: 1k, Pace: 69 seconds per 400m
136	61	2x 1k	2	2:00	Distance: 1k, Pace: 68 seconds per 400m
137	62	2x 1k	2	2:00	Distance: 1k, Pace: 76 seconds per 400m
138	62	2x 1k	2	2:00	Distance: 1k, Pace: 75 seconds per 400m
139	62	2x 1k	2	2:00	Distance: 1k, Pace: 74 seconds per 400m
140	62	2x 1k	2	2:00	Distance: 1k, Pace: 73 seconds per 400m
141	62	2x 1k	2	2:00	Distance: 1k, Pace: 72 seconds per 400m
142	63	2x 1k	2	2:00	Distance: 1k, Pace: 79 seconds per 400m
143	63	2x 1k	2	2:00	Distance: 1k, Pace: 78 seconds per 400m
144	63	2x 1k	2	2:00	Distance: 1k, Pace: 77 seconds per 400m
145	63	2x 1k	2	2:00	Distance: 1k, Pace: 76 seconds per 400m
146	63	2x 1k	2	2:00	Distance: 1k, Pace: 75 seconds per 400m
147	64	2x 1k	2	2:00	Distance: 1k, Pace: 72 seconds per 1k
148	64	2x 1k	2	2:00	Distance: 1k, Pace: 71 seconds per 1k
149	64	2x 1k	2	2:00	Distance: 1k, Pace: 70 seconds per 1k
150	64	2x 1k	2	2:00	Distance: 1k, Pace: 69 seconds per 1k
151	64	2x 1k	2	2:00	Distance: 1k, Pace: 68 seconds per 1k
152	65	2x 1k	2	2:00	Distance: 1k, Pace: 76 seconds per 1k
153	65	2x 1k	2	2:00	Distance: 1k, Pace: 75 seconds per 1k
154	65	2x 1k	2	2:00	Distance: 1k, Pace: 74 seconds per 1k
155	65	2x 1k	2	2:00	Distance: 1k, Pace: 73 seconds per 1k
156	65	2x 1k	2	2:00	Distance: 1k, Pace: 72 seconds per 1k
157	66	2x 1k	2	2:00	Distance: 1k, Pace: 79 seconds per 1k
158	66	2x 1k	2	2:00	Distance: 1k, Pace: 78 seconds per 1k
159	66	2x 1k	2	2:00	Distance: 1k, Pace: 77 seconds per 1k
160	66	2x 1k	2	2:00	Distance: 1k, Pace: 76 seconds per 1k
161	66	2x 1k	2	2:00	Distance: 1k, Pace: 75 seconds per 1k
162	67	Long rep set for faster group	2	2:00	Distance: 2400m, Pace: 75, 74 seconds per lap
163	67	Short rep set for faster group	4	2:00	Distance: 1200m, Pace: 72, 71, 70, 69 seconds per lap
164	68	Long rep set for mid-pace group	2	2:00	Distance: 2400m, Pace: 77, 76 seconds per lap
165	68	Short rep set for mid-pace group	4	2:00	Distance: 1200m, Pace: 74, 73, 72, 71 seconds per lap
166	69	Long rep set for slower group	2	2:00	Distance: 2400m, Pace: 80, 79 seconds per lap
167	69	Short rep set for slower group	4	2:00	Distance: 1200m, Pace: 77, 76, 75, 74 seconds per lap
168	70	2x 800m	2	1:30	Distance: 800m, Pace: 73 seconds
169	70	2x 800m	2	1:30	Distance: 800m, Pace: 72 seconds
170	70	2x 800m	2	1:30	Distance: 800m, Pace: 71 seconds
171	70	2x 800m	2	1:30	Distance: 800m, Pace: 70 seconds
172	70	2x 800m	2	1:30	Distance: 800m, Pace: 69 seconds
173	71	2x 800m	2	1:30	Distance: 800m, Pace: 76 seconds
174	71	2x 800m	2	1:30	Distance: 800m, Pace: 75 seconds
175	71	2x 800m	2	1:30	Distance: 800m, Pace: 74 seconds
176	71	2x 800m	2	1:30	Distance: 800m, Pace: 73 seconds
177	71	2x 800m	2	1:30	Distance: 800m, Pace: 72 seconds
178	72	2x 800m	2	1:30	Distance: 800m, Pace: 78 seconds
179	72	2x 800m	2	1:30	Distance: 800m, Pace: 77 seconds
180	72	2x 800m	2	1:30	Distance: 800m, Pace: 76 seconds
181	72	2x 800m	2	1:30	Distance: 800m, Pace: 75 seconds
182	72	2x 800m	2	1:30	Distance: 800m, Pace: 74 seconds
183	73	First set of long intervals	2	2:00	Distance: 3200m, Pace: 75, 73 seconds per 400m
184	73	Second set of shorter intervals	2	2:00	Distance: 1600m, Pace: 71, 70 seconds per 400m
185	74	First set of long intervals	2	2:00	Distance: 3200m, Pace: 77, 75 seconds per 400m
186	74	Second set of shorter intervals	2	2:00	Distance: 1600m, Pace: 73, 72 seconds per 400m
187	75	First set of long intervals	2	2:00	Distance: 3200m, Pace: 80, 78 seconds per 400m
188	75	Second set of shorter intervals	2	2:00	Distance: 1600m, Pace: 76, 75 seconds per 400m
189	76	3x 2k	3	2:00	Distance: 2k, Pace: 74, 73, 72
190	76	3x 1k	3	2:00	Distance: 1k, Pace: 70, 69, 68
191	76	3x 500	3	2:00	Distance: 500, Pace: 66, 65, 64
192	77	3x 2k	3	2:00	Distance: 2k, Pace: 76, 75, 74
193	77	3x 1k	3	2:00	Distance: 1k, Pace: 72, 71, 70
194	77	3x 500	3	2:00	Distance: 500, Pace: 68, 67, 66
195	78	3x 2k	3	2:00	Distance: 2k, Pace: 79, 78, 77
196	78	3x 1k	3	2:00	Distance: 1k, Pace: 75, 74, 73
197	78	3x 500	3	2:00	Distance: 500, Pace: 71, 70, 69
198	79	Decreasing pace mile repeats	5	1:30	Distance: 1600m, Pace: 74, 73, 72, 71, 70 seconds per lap
199	79	Fast 400m repeats	4	45 seconds	Distance: 400m, Pace: 65 seconds per 400m
200	80	Decreasing pace mile repeats	5	1:30	Distance: 1600m, Pace: 76, 75, 74, 73, 72 seconds per lap
201	80	Fast 400m repeats	4	45 seconds	Distance: 400m, Pace: 67 seconds per 400m
202	81	Decreasing pace mile repeats	5	1:30	Distance: 1600m, Pace: 79, 78, 77, 76, 75 seconds per lap
203	81	Fast 400m repeats	4	45 seconds	Distance: 400m, Pace: 70 seconds per 400m
204	82	Descending pace workout	4	2:00	Distance: 2400m, Pace: 74, 73, 72, 71 seconds per 400m
205	83	Descending pace workout	4	2:00	Distance: 2400m, Pace: 76, 75, 74, 73 seconds per 400m
206	84	Descending pace workout	4	2:00	Distance: 2400m, Pace: 79, 78, 77, 76 seconds per 400m
207	85	1x 3200m	1	2:00	Distance: 3200m, Pace: 75 seconds per 400m
208	85	1x 2400m	1	2:00	Distance: 2400m, Pace: 73 seconds per 400m
209	85	1x 1600m	1	2:00	Distance: 1600m, Pace: 71 seconds per 400m
210	85	1x 800m	1	3:00	Distance: 800m, Pace: 69 seconds per 400m
211	85	4x 400m	4	1:00	Distance: 400m, Pace: 67, 66, 65, 64 seconds
212	86	1x 3200m	1	2:00	Distance: 3200m, Pace: 77 seconds per 400m
213	86	1x 2400m	1	2:00	Distance: 2400m, Pace: 75 seconds per 400m
214	86	1x 1600m	1	2:00	Distance: 1600m, Pace: 73 seconds per 400m
215	86	1x 800m	1	3:00	Distance: 800m, Pace: 71 seconds per 400m
216	86	4x 400m	4	1:00	Distance: 400m, Pace: 69, 68, 67, 66 seconds
217	87	1x 3200m	1	2:00	Distance: 3200m, Pace: 80 seconds per 400m
218	87	1x 2400m	1	2:00	Distance: 2400m, Pace: 78 seconds per 400m
219	87	1x 1600m	1	2:00	Distance: 1600m, Pace: 76 seconds per 400m
220	87	1x 800m	1	3:00	Distance: 800m, Pace: 74 seconds per 400m
221	87	4x 400m	4	1:00	Distance: 400m, Pace: 72, 71, 70, 69 seconds
222	88	Descending pace 2k intervals	5	2:00	Distance: 2k, Pace: 75, 74, 73, 72, 71
223	89	Descending pace 2k intervals	5	2:00	Distance: 2k, Pace: 77, 76, 75, 74, 73
224	90	Descending pace 2k intervals	5	2:00	Distance: 2k, Pace: 79, 78, 77, 76, 75
225	91	Hard warm-up	1		Distance: 1600m, Pace: 
226	91	Turnover workout	8	2:00	Distance: 600m, Pace: 2 @ 75, 2 @ 74, 2 @ 73, 2 @ 72
227	92	2x 1k	2	1:30	Distance: 1k, Pace: 73 seconds per 1k
228	92	2x 1k	2	1:30	Distance: 1k, Pace: 72 seconds per 1k
229	92	2x 1k	2	1:30	Distance: 1k, Pace: 71 seconds per 1k
230	92	2x 1k	2	1:30	Distance: 1k, Pace: 70 seconds per 1k
231	92	2x 1k	2	1:30	Distance: 1k, Pace: 69 seconds per 1k
232	93	2x 1k	2	1:30	Distance: 1k, Pace: 75 seconds per 1k
233	93	2x 1k	2	1:30	Distance: 1k, Pace: 74 seconds per 1k
234	93	2x 1k	2	1:30	Distance: 1k, Pace: 73 seconds per 1k
235	93	2x 1k	2	1:30	Distance: 1k, Pace: 72 seconds per 1k
236	93	2x 1k	2	1:30	Distance: 1k, Pace: 71 seconds per 1k
237	94	2x 1k	2	1:30	Distance: 1k, Pace: 78 seconds per 1k
238	94	2x 1k	2	1:30	Distance: 1k, Pace: 77 seconds per 1k
239	94	2x 1k	2	1:30	Distance: 1k, Pace: 76 seconds per 1k
240	94	2x 1k	2	1:30	Distance: 1k, Pace: 75 seconds per 1k
241	94	2x 1k	2	1:30	Distance: 1k, Pace: 74 seconds per 1k
242	95	2 x 3200m with 2:00 rest	2	2:00	Distance: 3200m, Pace: 75, 73 seconds per lap
243	95	First set of 4 x 400m	4	45 seconds	Distance: 400m, Pace: 68 seconds per 400m
244	95	Second set of 4 x 400m	4	45 seconds	Distance: 400m, Pace: 66 seconds per 400m
245	96	2 x 3200m with 2:00 rest	2	2:00	Distance: 3200m, Pace: 77, 75 seconds per lap
246	96	First set of 4 x 400m	4	45 seconds	Distance: 400m, Pace: 70 seconds per 400m
247	96	Second set of 4 x 400m	4	45 seconds	Distance: 400m, Pace: 68 seconds per 400m
248	97	2 x 3200m with 2:00 rest	2	2:00	Distance: 3200m, Pace: 80, 78 seconds per lap
249	97	First set of 4 x 400m	4	45 seconds	Distance: 400m, Pace: 72 seconds per 400m
250	97	Second set of 4 x 400m	4	45 seconds	Distance: 400m, Pace: 70 seconds per 400m
251	98	2400m repeats	2	2:00	Distance: 2400m, Pace: 74, 72 seconds per 400m
252	98	1200m repeats	4	2:00	Distance: 1200m, Pace: 2 @ 70, 2 @ 69 seconds per 400m
253	99	2400m repeats	2	2:00	Distance: 2400m, Pace: 76, 74 seconds per 400m
254	99	1200m repeats	4	2:00	Distance: 1200m, Pace: 2 @ 72, 2 @ 71 seconds per 400m
255	100	2400m repeats	2	2:00	Distance: 2400m, Pace: 79, 77 seconds per 400m
256	100	1200m repeats	4	2:00	Distance: 1200m, Pace: 2 @ 75, 2 @ 74 seconds per 400m
257	101	First set, first two reps	2	1:30	Distance: 1200m, Pace: 72 seconds per 400m
258	101	First set, last two reps	2	1:30	Distance: 1200m, Pace: 70 seconds per 400m
259	101	Second set, first two reps through 800m	2	2:00	Distance: 800m, Pace: 69 seconds per 400m
260	101	Second set, last two reps through 800m	2	2:00	Distance: 800m, Pace: 68 seconds per 400m
261	101	Float segment between 800m and final 200m	2	2:00	Distance: 200m, Pace: 42 seconds
262	101	Final 200m sprint	2	2:00	Distance: 200m, Pace: 32 seconds
263	102	First set, first two reps	2	1:30	Distance: 1200m, Pace: 74 seconds per 400m
264	102	First set, last two reps	2	1:30	Distance: 1200m, Pace: 72 seconds per 400m
265	102	Second set, first two reps through 800m	2	2:00	Distance: 800m, Pace: 71 seconds per 400m
266	102	Second set, last two reps through 800m	2	2:00	Distance: 800m, Pace: 70 seconds per 400m
267	102	Float segment between 800m and final 200m	2	2:00	Distance: 200m, Pace: 43 seconds
268	102	Final 200m sprint	2	2:00	Distance: 200m, Pace: 32 seconds
269	103	First set, first two reps	2	1:30	Distance: 1200m, Pace: 77 seconds per 400m
270	103	First set, last two reps	2	1:30	Distance: 1200m, Pace: 75 seconds per 400m
271	103	Second set, first two reps through 800m	2	2:00	Distance: 800m, Pace: 74 seconds per 400m
272	103	Second set, last two reps through 800m	2	2:00	Distance: 800m, Pace: 73 seconds per 400m
273	103	Float segment between 800m and final 200m	2	2:00	Distance: 200m, Pace: 44 seconds
274	103	Final 200m sprint	2	2:00	Distance: 200m, Pace: 33 seconds
275	104	Descending pace 2k repeats	3	2:00	Distance: 2k, Pace: 74, 73, 72 seconds per 400m
276	104	Descending pace 1k repeats	4	2:00	Distance: 1k, Pace: 70, 69, 68, 67 seconds per 400m
277	105	Descending pace 2k repeats	3	2:00	Distance: 2k, Pace: 76, 75, 74 seconds per 400m
278	105	Descending pace 1k repeats	4	2:00	Distance: 1k, Pace: 72, 71, 70, 69 seconds per 400m
279	106	Descending pace 2k repeats	3	2:00	Distance: 2k, Pace: 79, 78, 77 seconds per 400m
280	106	Descending pace 1k repeats	4	2:00	Distance: 1k, Pace: 75, 74, 73, 72 seconds per 400m
281	107	1x 3200m	1	2:00	Distance: 3200m, Pace: 74 seconds per 400m
282	107	1x 2400m	1	2:00	Distance: 2400m, Pace: 72 seconds per 400m
283	107	1x 1600m	1	2:00	Distance: 1600m, Pace: 70 seconds per 400m
284	107	1x 800m	1	2:00	Distance: 800m, Pace: 68 seconds per 400m
285	107	2x 400m	2	1:00	Distance: 400m, Pace: 66 seconds per 400m
286	107	2x 400m	2	1:00	Distance: 400m, Pace: 64 seconds per 400m
287	108	1x 3200m	1	2:00	Distance: 3200m, Pace: 76 seconds per 400m
288	108	1x 2400m	1	2:00	Distance: 2400m, Pace: 74 seconds per 400m
289	108	1x 1600m	1	2:00	Distance: 1600m, Pace: 72 seconds per 400m
290	108	1x 800m	1	2:00	Distance: 800m, Pace: 70 seconds per 400m
291	108	2x 400m	2	1:00	Distance: 400m, Pace: 68 seconds per 400m
292	108	2x 400m	2	1:00	Distance: 400m, Pace: 66 seconds per 400m
293	109	1x 3200m	1	2:00	Distance: 3200m, Pace: 79 seconds per 400m
294	109	1x 2400m	1	2:00	Distance: 2400m, Pace: 77 seconds per 400m
295	109	1x 1600m	1	2:00	Distance: 1600m, Pace: 75 seconds per 400m
296	109	1x 800m	1	2:00	Distance: 800m, Pace: 73 seconds per 400m
297	109	2x 400m	2	1:00	Distance: 400m, Pace: 70 seconds per 400m
298	109	2x 400m	2	1:00	Distance: 400m, Pace: 68 seconds per 400m
299	110	First set 2400m interval	3	1:00	Distance: 2400m, Pace: 74 seconds per 400m
300	110	First set 800m interval	3	3:00	Distance: 800m, Pace: 70 seconds per 400m
301	111	First set 2400m interval	3	1:00	Distance: 2400m, Pace: 76 seconds per 400m
302	111	First set 800m interval	3	3:00	Distance: 800m, Pace: 72 seconds per 400m
303	112	First set 2400m interval	3	1:00	Distance: 2400m, Pace: 78 seconds per 400m
304	112	First set 800m interval	3	3:00	Distance: 800m, Pace: 74 seconds per 400m
305	113	2x 1600m	2	2:00	Distance: 1600m, Pace: 73 seconds per 400m
306	113	2x 1600m	2	2:00	Distance: 1600m, Pace: 71 seconds per 400m
307	113	2x 1600m	2	2:00	Distance: 1600m, Pace: 69 seconds per 400m
308	114	2x 1600m	2	2:00	Distance: 1600m, Pace: 75 seconds per 400m
309	114	2x 1600m	2	2:00	Distance: 1600m, Pace: 73 seconds per 400m
310	114	2x 1600m	2	2:00	Distance: 1600m, Pace: 71 seconds per 400m
311	115	2x 1600m	2	2:00	Distance: 1600m, Pace: 78 seconds per 400m
312	115	2x 1600m	2	2:00	Distance: 1600m, Pace: 76 seconds per 400m
313	115	2x 1600m	2	2:00	Distance: 1600m, Pace: 74 seconds per 400m
314	116	First set of long intervals	2	2:00	Distance: 2400m, Pace: 73, 72 seconds per 400m
315	116	Middle distance intervals	2	2:00	Distance: 1600m, Pace: 70, 69 seconds per 400m
316	116	Short, fast intervals	2	2:00	Distance: 800m, Pace: 67, 66 seconds per 400m
317	117	First set of long intervals	2	2:00	Distance: 2400m, Pace: 76, 75 seconds per 400m
318	117	Middle distance intervals	2	2:00	Distance: 1600m, Pace: 73, 72 seconds per 400m
319	117	Short, fast intervals	2	2:00	Distance: 800m, Pace: 70, 69 seconds per 400m
320	118	First set of long intervals	2	2:00	Distance: 2400m, Pace: 78, 77 seconds per 400m
321	118	Middle distance intervals	2	2:00	Distance: 1600m, Pace: 75, 74 seconds per 400m
322	118	Short, fast intervals	2	2:00	Distance: 800m, Pace: 72, 71 seconds per 400m
323	119	Initial interval	1	2:00	Distance: 1600m, Pace: 76 seconds per 400m
324	119	Varied pace 600m repeats	8	1:30	Distance: 600m, Pace: 71, 70, 69, 68 seconds per 400m
325	120	2x 1k	2	1:30	Distance: 1k, Pace: 71 seconds per 1k
326	120	2x 1k	2	1:30	Distance: 1k, Pace: 70 seconds per 1k
327	120	2x 1k	2	1:30	Distance: 1k, Pace: 69 seconds per 1k
328	120	2x 1k	2	1:30	Distance: 1k, Pace: 68 seconds per 1k
329	120	2x 1k	2	1:30	Distance: 1k, Pace: 67 seconds per 1k
330	121	2x 1k	2	1:30	Distance: 1k, Pace: 73 seconds per 1k
331	121	2x 1k	2	1:30	Distance: 1k, Pace: 72 seconds per 1k
332	121	2x 1k	2	1:30	Distance: 1k, Pace: 71 seconds per 1k
333	121	2x 1k	2	1:30	Distance: 1k, Pace: 70 seconds per 1k
334	121	2x 1k	2	1:30	Distance: 1k, Pace: 69 seconds per 1k
335	122	2x 1k	2	1:30	Distance: 1k, Pace: 76 seconds per 1k
336	122	2x 1k	2	1:30	Distance: 1k, Pace: 75 seconds per 1k
337	122	2x 1k	2	1:30	Distance: 1k, Pace: 74 seconds per 1k
338	122	2x 1k	2	1:30	Distance: 1k, Pace: 73 seconds per 1k
339	122	2x 1k	2	1:30	Distance: 1k, Pace: 72 seconds per 1k
340	123	First interval group	2	2:00	Distance: 3200m, Pace: 72, 71 seconds per 400m
341	123	Second interval group	4	2:00	Distance: 800m, Pace: 68, 67, 66, 65 seconds per 400m
342	124	Second interval group	2	2:00	Distance: 3200m, Pace: 74, 73 seconds per 400m
343	124	Second interval group	4	2:00	Distance: 800m, Pace: 70, 69, 68, 67 seconds per 400m
344	125	Third interval group	2	2:00	Distance: 3200m, Pace: 77, 76 seconds per 400m
345	125	Third interval group	4	2:00	Distance: 800m, Pace: 73, 72, 71, 70 seconds per 400m
346	126	2k repeats	4	2:00	Distance: 2k, Pace: 72, 71, 70, 69 seconds per 400m
347	126	400m repeats	4	45 seconds	Distance: 400m, Pace: 66, 65, 64, 63 seconds per 400m
348	127	2k repeats	4	2:00	Distance: 2k, Pace: 74, 73, 72, 71 seconds per 400m
349	127	400m repeats	4	45 seconds	Distance: 400m, Pace: 68, 67, 66, 65 seconds per 400m
350	128	2k repeats	4	2:00	Distance: 2k, Pace: 77, 76, 75, 74 seconds per 400m
351	128	400m repeats	4	45 seconds	Distance: 400m, Pace: 70, 69, 68, 66 seconds per 400m
\.


--
-- Data for Name: workouts; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.workouts (id, date, location, start_time, coach_notes, email_id) FROM stdin;
1	2025-01-15	BCC	\N	Road workout due to track conditions, using 1200m loop with challenging hill	1
2	2025-01-22	BCC	\N	Road loop workout due to track conditions	2
3	2025-01-29	BCC	\N	Track workout (potentially modified due to track conditions)	3
4	2025-02-05	BCC	\N	Track workout for men	4
5	2025-02-12	BCC	\N	Potential road loop workout, pending track conditions	5
6	2025-02-18	BCC	\N	Track workout with 5x1200m and 8x600m	6
7	2025-02-26	BCC	\N	Men's Track Workout	7
8	2025-03-05	The Mall (between 4th and 7th Streets)	\N	4-3-2-1-1-1 ladder workout	8
9	2025-03-12	The Mall	\N	Men's workout with 3 sets of 2400m, 800m	9
10	2025-03-19	St Albans	\N	Track workout with 10 x 1k repeats	10
11	2025-03-26	ST ALBANS	\N	Track workout with mile and 400m repeats	11
12	2025-04-02	The Mall	\N	8 x 800m workout with varying pace targets	12
13	2025-04-09	The Mall	\N	Maintenance workout for road crew	13
14	2025-04-16	BCC	\N	Ladder workout with two sets of 4-3-2-1 and 800m repeats for Boston crew	14
15	2025-04-23	ST ALBANS	\N	Men's workout, 10 x 1k with 2:00 rest	15
16	2025-04-30	St Albans	\N	Broad Street men's workout	16
17	2025-05-07	The Mall	\N	Mile repeats with varying target paces	17
18	2025-05-28	St Albans	\N	Mixed-pace interval workout	18
19	2025-06-04	BCC	\N	Men's speed workout	19
20	2025-06-11	BCC	\N	Workout details to be sent in morning	20
21	2025-06-18	St Albans	\N	Men's track workout with mile and 800m repeats	21
22	2025-06-25	St Albans	\N	Track workout with 400m intervals in multiple groups	22
23	2025-07-02	St Albans	\N	Honoring Bill Dellinger, getting in shape to get in shape	23
24	2025-07-09	St Albans	\N	Track workout details to be sent later	24
25	2025-07-09	St Albans	\N	10 x 1k intervals with 2:00 rest	25
26	2025-07-16	BCC	\N	10 x 1k with 2:00 rest	26
27	2025-07-23	BCC	\N	Long reps workout with varying target paces	27
28	2025-07-30	BCC	\N	800m repeats with decreasing target times	28
29	2025-08-06	BCC	\N	Longer intervals with 2:00 rest	29
30	2025-08-13	ST ALBANS	\N	Men's track workout with progressive decreasing intervals	30
31	2025-08-20	St Albans	\N	Track workout with mile and 400m repeats	31
32	2025-08-27	St Albans	\N	Track workout with 4 x 2400m repeats	32
33	2025-09-03	American University	\N	Track workout with descending distances and targeted paces	33
34	2025-09-10	American University	\N	Track workout with multiple groups, varying 2k intervals	34
35	2025-09-17	ST ALBANS	\N	10 x 1k with 1:30 rest	35
36	2025-09-24	American University	\N	Track workout for men's group	36
37	2025-09-30	BCC	\N	Track workout with 2 x 2400, 4 x 1200 with 2:00 rest	37
38	2025-10-08	American University	\N	Track workout with 1200m repeats in sets	38
39	2025-10-15	Washington Liberty HS	\N	Track workout with 3 x 2k, 4 x 1k with 2:00 rest	39
40	2025-10-22	Washington Liberty HS	\N	Men's ladder workout	40
41	2025-10-29	The Mall (between 4th and 7th Streets)	\N	Track workout with 3 sets of 2400m-800m intervals	41
42	2025-11-05	Washington Liberty High School	\N	Track workout with 1600m repeats	42
43	2025-11-12	BCC	\N	Track workout with multiple groups and varied intervals	43
44	2025-11-19	BCC	\N	Men's workout: 10 x 1k with 1:30 rest	44
45	2025-11-26	BCC	\N	Optional individual workout due to holiday	45
46	2025-12-03	BCC	\N	Men's workout with intervals	46
47	2025-12-10	BCC	\N	Mixed distance intervals	47
\.


--
-- Name: athlete_nicknames_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.athlete_nicknames_id_seq', 2, true);


--
-- Name: athletes_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.athletes_id_seq', 109, true);


--
-- Name: emails_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.emails_id_seq', 47, true);


--
-- Name: race_results_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.race_results_id_seq', 421, true);


--
-- Name: races_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.races_id_seq', 135, true);


--
-- Name: review_flags_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.review_flags_id_seq', 6, true);


--
-- Name: workout_groups_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.workout_groups_id_seq', 128, true);


--
-- Name: workout_segments_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.workout_segments_id_seq', 351, true);


--
-- Name: workouts_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.workouts_id_seq', 47, true);


--
-- Name: athlete_nicknames athlete_nicknames_athlete_id_nickname_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.athlete_nicknames
    ADD CONSTRAINT athlete_nicknames_athlete_id_nickname_key UNIQUE (athlete_id, nickname);


--
-- Name: athlete_nicknames athlete_nicknames_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.athlete_nicknames
    ADD CONSTRAINT athlete_nicknames_pkey PRIMARY KEY (id);


--
-- Name: athletes athletes_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.athletes
    ADD CONSTRAINT athletes_name_key UNIQUE (name);


--
-- Name: athletes athletes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.athletes
    ADD CONSTRAINT athletes_pkey PRIMARY KEY (id);


--
-- Name: emails emails_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.emails
    ADD CONSTRAINT emails_pkey PRIMARY KEY (id);


--
-- Name: race_results race_results_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.race_results
    ADD CONSTRAINT race_results_pkey PRIMARY KEY (id);


--
-- Name: races races_name_year_distance_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.races
    ADD CONSTRAINT races_name_year_distance_key UNIQUE (name, year, distance);


--
-- Name: races races_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.races
    ADD CONSTRAINT races_pkey PRIMARY KEY (id);


--
-- Name: review_flags review_flags_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.review_flags
    ADD CONSTRAINT review_flags_pkey PRIMARY KEY (id);


--
-- Name: workout_groups workout_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.workout_groups
    ADD CONSTRAINT workout_groups_pkey PRIMARY KEY (id);


--
-- Name: workout_segments workout_segments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.workout_segments
    ADD CONSTRAINT workout_segments_pkey PRIMARY KEY (id);


--
-- Name: workouts workouts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.workouts
    ADD CONSTRAINT workouts_pkey PRIMARY KEY (id);


--
-- Name: athlete_nicknames athlete_nicknames_athlete_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.athlete_nicknames
    ADD CONSTRAINT athlete_nicknames_athlete_id_fkey FOREIGN KEY (athlete_id) REFERENCES public.athletes(id) ON DELETE CASCADE;


--
-- Name: race_results race_results_athlete_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.race_results
    ADD CONSTRAINT race_results_athlete_id_fkey FOREIGN KEY (athlete_id) REFERENCES public.athletes(id);


--
-- Name: race_results race_results_email_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.race_results
    ADD CONSTRAINT race_results_email_id_fkey FOREIGN KEY (email_id) REFERENCES public.emails(id);


--
-- Name: race_results race_results_race_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.race_results
    ADD CONSTRAINT race_results_race_id_fkey FOREIGN KEY (race_id) REFERENCES public.races(id);


--
-- Name: races races_email_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.races
    ADD CONSTRAINT races_email_id_fkey FOREIGN KEY (email_id) REFERENCES public.emails(id);


--
-- Name: review_flags review_flags_email_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.review_flags
    ADD CONSTRAINT review_flags_email_id_fkey FOREIGN KEY (email_id) REFERENCES public.emails(id);


--
-- Name: review_flags review_flags_matched_athlete_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.review_flags
    ADD CONSTRAINT review_flags_matched_athlete_id_fkey FOREIGN KEY (matched_athlete_id) REFERENCES public.athletes(id);


--
-- Name: workout_groups workout_groups_workout_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.workout_groups
    ADD CONSTRAINT workout_groups_workout_id_fkey FOREIGN KEY (workout_id) REFERENCES public.workouts(id);


--
-- Name: workout_segments workout_segments_workout_group_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.workout_segments
    ADD CONSTRAINT workout_segments_workout_group_id_fkey FOREIGN KEY (workout_group_id) REFERENCES public.workout_groups(id);


--
-- Name: workouts workouts_email_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.workouts
    ADD CONSTRAINT workouts_email_id_fkey FOREIGN KEY (email_id) REFERENCES public.emails(id);


--
-- PostgreSQL database dump complete
--

\unrestrict WIqh8ZrAufUUeA8VLB7irAnRJfaWAwxz4Igff1tLyk6KRLSmWII3KuBsvJW1kHO

