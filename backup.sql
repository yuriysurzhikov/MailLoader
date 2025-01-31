PGDMP                         w         
   Order_News    11.5    11.5     %           0    0    ENCODING    ENCODING        SET client_encoding = 'UTF8';
                       false            &           0    0 
   STDSTRINGS 
   STDSTRINGS     (   SET standard_conforming_strings = 'on';
                       false            '           0    0 
   SEARCHPATH 
   SEARCHPATH     8   SELECT pg_catalog.set_config('search_path', '', false);
                       false            (           1262    69254 
   Order_News    DATABASE     �   CREATE DATABASE "Order_News" WITH TEMPLATE = template0 ENCODING = 'UTF8' LC_COLLATE = 'Russian_Russia.1251' LC_CTYPE = 'Russian_Russia.1251';
    DROP DATABASE "Order_News";
             postgres    false            [           1247    69623    mail    DOMAIN     p   CREATE DOMAIN public.mail AS character varying
	CONSTRAINT mail_check CHECK (((VALUE)::text ~ '%@%\.%'::text));
    DROP DOMAIN public.mail;
       public       postgres    false            �            1255    69664    add_connect()    FUNCTION       CREATE FUNCTION public.add_connect() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
id_rel INT;
BEGIN
	SELECT id_relation INTO id_rel FROM mails_news MN
	WHERE MN.id_news = NEW.id_news
	AND MN.id_mail = NEW.id_mail;
	IF NOT FOUND THEN
		RETURN NEW;
	ELSE
		IF((SELECT MN.mailing_date FROM mails_news MN WHERE MN.id_relation = id_rel)::DATE - NEW.mailing_date::DATE < 0) THEN
			UPDATE mails_news
			SET mailing_date = NEW.mailing_date
			WHERE id_relation = id_rel;
		END IF;
		RETURN OLD;
	END IF;
END;
$$;
 $   DROP FUNCTION public.add_connect();
       public       postgres    false            �            1255    69661 
   add_mail()    FUNCTION     �  CREATE FUNCTION public.add_mail() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
id_mail_old INT;
BEGIN
	SELECT M.id_mail INTO id_mail_old FROM e_mails M
	WHERE M.mail = NEW.mail;
	IF NOT FOUND THEN
		RETURN NEW;
	ELSE
		IF (SELECT M.valid_state FROM e_mails M
		    WHERE M.id_mail = id_mail_old) = FALSE
			AND NEW.valid_state = TRUE THEN
			UPDATE e_mails M
				SET valid_state = NEW.valid_state
				WHERE id_mail = id_mail_old;
		END IF;
		RETURN OLD;
	END IF;
END;
$$;
 !   DROP FUNCTION public.add_mail();
       public       postgres    false            �            1255    69703 "   export_rows(date, integer, bigint)    FUNCTION     �  CREATE FUNCTION public.export_rows(low_date date, valid_state integer, amount_rows bigint) RETURNS SETOF character varying
    LANGUAGE plpgsql
    AS $$ 
DECLARE
	counter INT := 0;
	var_t text;
BEGIN
	CASE
		WHEN valid_state = 1 THEN
			FOR var_t IN (SELECT E.mail FROM e_mails E
				  	  	  WHERE EXISTS(SELECT * FROM mails_news MN
								   	   WHERE MN.id_mail = E.id_mail
									   AND low_date - MN.mailing_date >= 0)
						  AND E.valid_state)
			LOOP
				EXIT WHEN counter >= amount_rows;
				counter = counter + 1;
				RETURN NEXT var_t;
			END LOOP;
		WHEN valid_state = 2 THEN
			FOR var_t IN (SELECT E.mail FROM e_mails E
				  	  	  WHERE EXISTS(SELECT * FROM mails_news MN
								   	   WHERE MN.id_mail = E.id_mail
									   AND low_date - MN.mailing_date >= 0)
						  AND NOT E.valid_state)
			LOOP
				EXIT WHEN counter >= amount_rows;
				counter = counter + 1;
				RETURN NEXT var_t;
			END LOOP;
		WHEN valid_state = 3 THEN
			FOR var_t IN (SELECT E.mail FROM e_mails E
				  	  	  WHERE EXISTS(SELECT * FROM mails_news MN
								   	   WHERE MN.id_mail = E.id_mail
									   AND low_date - MN.mailing_date >= 0))
			LOOP
				EXIT WHEN counter >= amount_rows;
				counter = counter + 1;
				RETURN NEXT var_t;
			END LOOP;
	END CASE;
END;
$$;
 Z   DROP FUNCTION public.export_rows(low_date date, valid_state integer, amount_rows bigint);
       public       postgres    false            �            1255    69702 5   export_rows(date, integer, bigint, character varying)    FUNCTION     Z  CREATE FUNCTION public.export_rows(low_date date, valid_state integer, amount_rows bigint, name_news character varying) RETURNS SETOF character varying
    LANGUAGE plpgsql
    AS $$ 
DECLARE
	counter INT := 0;
	var_t text;
BEGIN
	CASE
		WHEN valid_state = 1 THEN
			FOR var_t IN (SELECT E.mail FROM e_mails E
				  	  	  WHERE EXISTS(SELECT * FROM mails_news MN
								   	   WHERE MN.id_mail = E.id_mail
									   AND low_date - MN.mailing_date >= 0
									   AND MN.id_news IN (SELECT N.id_news FROM news N
														  WHERE N.news_name <> name_news))
						  AND E.valid_state)
			LOOP
				EXIT WHEN counter >= amount_rows;
				counter = counter + 1;
				RETURN NEXT var_t;
			END LOOP;
		WHEN valid_state = 2 THEN
			FOR var_t IN (SELECT E.mail FROM e_mails E
				  	  	  WHERE EXISTS(SELECT * FROM mails_news MN
								   	   WHERE MN.id_mail = E.id_mail
									   AND low_date - MN.mailing_date >= 0
									   AND MN.id_news IN (SELECT N.id_news FROM news N
														  WHERE N.news_name <> name_news))
						  AND NOT E.valid_state)
			LOOP
				EXIT WHEN counter >= amount_rows;
				counter = counter + 1;
				RETURN NEXT var_t;
			END LOOP;
		WHEN valid_state = 3 THEN
			FOR var_t IN (SELECT E.mail FROM e_mails E
				  	  	  WHERE EXISTS(SELECT * FROM mails_news MN
								   	   WHERE MN.id_mail = E.id_mail
									   AND low_date - MN.mailing_date >= 0
									   AND MN.id_news IN (SELECT N.id_news FROM news N
														  WHERE N.news_name <> name_news)))
			LOOP
				EXIT WHEN counter >= amount_rows;
				counter = counter + 1;
				RETURN NEXT var_t;
			END LOOP;
	END CASE;
END;
$$;
 w   DROP FUNCTION public.export_rows(low_date date, valid_state integer, amount_rows bigint, name_news character varying);
       public       postgres    false            �            1255    69704    export_without_date(bigint)    FUNCTION     Y  CREATE FUNCTION public.export_without_date(amount_rows bigint) RETURNS SETOF character varying
    LANGUAGE plpgsql
    AS $$
DECLARE
counter INT := 0;
var_t text;
BEGIN
	FOR var_t IN(SELECT mail FROM e_mails
				 WHERE NOT valid_state)
	LOOP
		EXIT WHEN counter >= amount_rows;
		counter = counter + 1;
		RETURN NEXT var_t;
	END LOOP;
END;
$$;
 >   DROP FUNCTION public.export_without_date(amount_rows bigint);
       public       postgres    false            �            1255    69669 A   import_mails(boolean, character varying, date, character varying)    FUNCTION     �  CREATE FUNCTION public.import_mails(valid_state boolean, mail_add character varying, mail_date date DEFAULT CURRENT_DATE, name_news character varying DEFAULT ''::character varying) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
id_news_cur INT;
id_mail_cur INT;
count_mails_old BIGINT;
count_mails_new BIGINT;
BEGIN
	SELECT COUNT(E.id_mail) INTO count_mails_old FROM e_mails E;
	SELECT E.id_mail INTO id_mail_cur FROM e_mails E
	WHERE E.mail = mail_add;
	IF NOT FOUND THEN
		count_mails_new = 0;
		id_mail_cur = NEXTVAL('s_mail');
		INSERT INTO e_mails
		VALUES(id_mail_cur, mail_add, valid_state);
	ELSE
		count_mails_new = 1;
		INSERT INTO e_mails(mail, valid_state)
		VALUES(mail_add, valid_state);
	END IF;
	
	SELECT N.id_news INTO id_news_cur FROM news N
	WHERE N.news_name = name_news;
	
	IF(name_news <> '') THEN
		INSERT INTO mails_news(id_news, id_mail, mailing_date)
		VALUES(id_news_cur, id_mail_cur, mail_date);
	END IF;
	RETURN count_mails_new;
END;
$$;
 �   DROP FUNCTION public.import_mails(valid_state boolean, mail_add character varying, mail_date date, name_news character varying);
       public       postgres    false            �            1259    69616    s_mail    SEQUENCE     o   CREATE SEQUENCE public.s_mail
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
    DROP SEQUENCE public.s_mail;
       public       postgres    false            �            1259    69625    e_mails    TABLE     �   CREATE TABLE public.e_mails (
    id_mail integer DEFAULT nextval('public.s_mail'::regclass) NOT NULL,
    mail character varying,
    valid_state boolean DEFAULT false NOT NULL
);
    DROP TABLE public.e_mails;
       public         postgres    false    196            �            1259    69620    s_mail_news    SEQUENCE     t   CREATE SEQUENCE public.s_mail_news
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 "   DROP SEQUENCE public.s_mail_news;
       public       postgres    false            �            1259    69645 
   mails_news    TABLE     �   CREATE TABLE public.mails_news (
    id_relation integer DEFAULT nextval('public.s_mail_news'::regclass) NOT NULL,
    id_news integer NOT NULL,
    id_mail integer NOT NULL,
    mailing_date date
);
    DROP TABLE public.mails_news;
       public         postgres    false    198            �            1259    69618    s_news    SEQUENCE     o   CREATE SEQUENCE public.s_news
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
    DROP SEQUENCE public.s_news;
       public       postgres    false            �            1259    69635    news    TABLE     �   CREATE TABLE public.news (
    id_news integer DEFAULT nextval('public.s_news'::regclass) NOT NULL,
    date_news date DEFAULT CURRENT_DATE,
    news_name character varying
);
    DROP TABLE public.news;
       public         postgres    false    197                       0    69625    e_mails 
   TABLE DATA               =   COPY public.e_mails (id_mail, mail, valid_state) FROM stdin;
    public       postgres    false    199   3       "          0    69645 
   mails_news 
   TABLE DATA               Q   COPY public.mails_news (id_relation, id_news, id_mail, mailing_date) FROM stdin;
    public       postgres    false    201   <3       !          0    69635    news 
   TABLE DATA               =   COPY public.news (id_news, date_news, news_name) FROM stdin;
    public       postgres    false    200   Y3       )           0    0    s_mail    SEQUENCE SET     7   SELECT pg_catalog.setval('public.s_mail', 4765, true);
            public       postgres    false    196            *           0    0    s_mail_news    SEQUENCE SET     <   SELECT pg_catalog.setval('public.s_mail_news', 2662, true);
            public       postgres    false    198            +           0    0    s_news    SEQUENCE SET     4   SELECT pg_catalog.setval('public.s_news', 4, true);
            public       postgres    false    197            �
           2606    69634    e_mails e_mails_pkey 
   CONSTRAINT     W   ALTER TABLE ONLY public.e_mails
    ADD CONSTRAINT e_mails_pkey PRIMARY KEY (id_mail);
 >   ALTER TABLE ONLY public.e_mails DROP CONSTRAINT e_mails_pkey;
       public         postgres    false    199            �
           2606    69650    mails_news mails_news_pkey 
   CONSTRAINT     s   ALTER TABLE ONLY public.mails_news
    ADD CONSTRAINT mails_news_pkey PRIMARY KEY (id_news, id_mail, id_relation);
 D   ALTER TABLE ONLY public.mails_news DROP CONSTRAINT mails_news_pkey;
       public         postgres    false    201    201    201            �
           2606    69644    news news_pkey 
   CONSTRAINT     Q   ALTER TABLE ONLY public.news
    ADD CONSTRAINT news_pkey PRIMARY KEY (id_news);
 8   ALTER TABLE ONLY public.news DROP CONSTRAINT news_pkey;
       public         postgres    false    200            �
           2620    69662    e_mails insert_mail    TRIGGER     m   CREATE TRIGGER insert_mail BEFORE INSERT ON public.e_mails FOR EACH ROW EXECUTE PROCEDURE public.add_mail();
 ,   DROP TRIGGER insert_mail ON public.e_mails;
       public       postgres    false    199    202            �
           2620    69665    mails_news insert_mail_news    TRIGGER     x   CREATE TRIGGER insert_mail_news BEFORE INSERT ON public.mails_news FOR EACH ROW EXECUTE PROCEDURE public.add_connect();
 4   DROP TRIGGER insert_mail_news ON public.mails_news;
       public       postgres    false    201    216            �
           2606    69656 "   mails_news mails_news_id_mail_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.mails_news
    ADD CONSTRAINT mails_news_id_mail_fkey FOREIGN KEY (id_mail) REFERENCES public.e_mails(id_mail);
 L   ALTER TABLE ONLY public.mails_news DROP CONSTRAINT mails_news_id_mail_fkey;
       public       postgres    false    199    201    2715            �
           2606    69651 "   mails_news mails_news_id_news_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.mails_news
    ADD CONSTRAINT mails_news_id_news_fkey FOREIGN KEY (id_news) REFERENCES public.news(id_news);
 L   ALTER TABLE ONLY public.mails_news DROP CONSTRAINT mails_news_id_news_fkey;
       public       postgres    false    2717    201    200                   x������ � �      "      x������ � �      !      x������ � �     