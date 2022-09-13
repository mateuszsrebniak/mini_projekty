create table kategorie (
		id_kat 		number primary key
	,	kategoria 	varchar2(20)
);

insert into kategorie values(1, 'jedynki');
insert into kategorie values(2, 'dwójki');
insert into kategorie values(3, 'trójki');
insert into kategorie values(4, 'czwórki');
insert into kategorie values(5, 'piątki');
insert into kategorie values(6, 'szóstki');

create table rzuty_gracza (
        rzut_nr 	number
    ,   kostka_1 	number
    ,   kostka_2 	number
    ,   kostka_3	number
    ,   kostka_4 	number
    ,   kostka_5 	number
	,	wynik 	 	number
	,	kategoria 	number
);

create table rzuty_komputera (
        rzut_nr 	number
    ,   kostka_1 	number
    ,   kostka_2 	number
    ,   kostka_3 	number
    ,   kostka_4 	number
    ,   kostka_5 	number
	,	wynik 		number
	,	kategoria 	number
);

alter table rzuty_komputera
add constraint unique_kat unique (kategoria)

/*pakiet symulujący grę w kości na naprostszym poziomie (wygrywa ten, kto wyrzuci większą sumę oczek)
przykład wywołania procedury:
	BEGIN
		kosci.rzucaj;
	END;*/
create or replace package kosci as
procedure zacznij_grac;
procedure rzucaj;
procedure wybor_kategorii(p_kat number);
end kosci;
-----------------------------------------------
-----------------------------------------------
create or replace package body kosci as
-----------------------------------------------
procedure pisz(p_tekst varchar2) as
begin
	dbms_output.put_line(p_tekst);
end;
-----------------------------------------------
function losuj return number as
	x number := round(dbms_random.value(1,6));
begin
    return x;
end;
-----------------------------------------------
procedure zacznij_grac as
begin
    execute immediate 'truncate table rzuty_gracza';
    execute immediate 'truncate table rzuty_komputera';
    pisz('Gra rozpoczęta! Możesz rzucać.');
end;
-----------------------------------------------
procedure rzucaj as
	v_rzut      		number;
	v_wynik     		number; 
	v_kat       		number;
	v_check     		number;
	v_kat_check 		number;
	e_koniec    		exception;
	e_brak_kategorii	exception;
	pragma exception_init(e_koniec, -20002);
	pragma exception_init(e_brak_kategorii, -20003);
	procedure nowa_kolejka(gracz number) as
		k_1 number := losuj();
		k_2 number := losuj();
		k_3 number := losuj();
		k_4 number := losuj();
		k_5 number := losuj();
	begin
	    if gracz = 1 then
			insert into rzuty_gracza(rzut_nr, kostka_1, kostka_2, kostka_3, kostka_4, kostka_5) 
			values(v_rzut, k_1, k_2, k_3, k_4, k_5);
			pisz('Kostki gracza: '||k_1||', '||k_2||', '||k_3||', '||k_4||', '||k_5);
		else
			insert into rzuty_komputera(rzut_nr, kostka_1, kostka_2, kostka_3, kostka_4, kostka_5) 
			values(v_rzut, k_1, k_2, k_3, k_4, k_5);
			pisz('Kostki komputera: '||k_1||', '||k_2||', '||k_3||', '||k_4||', '||k_5); 
		end if;
    end;
begin
	select count(*) into v_kat_check from rzuty_gracza where kategoria is null;
	if v_kat_check > 0 then
		raise_application_error(-20003, 'Nie wprowadzono kategorii. Wybierz kategorię');
	end if;
	select count(*) into v_check from rzuty_komputera;
	if v_check  >= 6 then 
        raise_application_error(-20002, 'Wszystkie kategorie zostały wykorzystane. Koniec gry');
    end if;
	
	select nvl(max(rzut_nr), 0) + 1 
    into v_rzut 
    from rzuty_gracza;
	
    nowa_kolejka(1);
    nowa_kolejka(2);
	
    select suma, ilosc_oczek
    into v_wynik, v_kat
    from komp_suma_jednakowych
    where rzut_nr = v_rzut and ilosc_oczek not in (select nvl(kategoria, 0) from rzuty_komputera)
    order by suma desc
    fetch first 1 row only;
	
    update rzuty_komputera
    set
        wynik = v_wynik,
        kategoria = v_kat
    where rzut_nr = v_rzut;
    pisz('Wynik komputera to: '||v_wynik);
	
exception
    when no_data_found then
    update rzuty_komputera
    set
        wynik = 0,
        kategoria = (   select id_kat 
                        from kategorie 
                        where id_kat not in
                                    (select kategoria
                                    from rzuty_komputera)
                        fetch first 1 row only)
    where rzut_nr = v_rzut;
	
    pisz('Wynik komputera to: '||'0');
end;
-----------------------------------------------
procedure wybor_kategorii(p_kat number) as
	v_rzut 		number;
	v_wynik 	number;
	v_check 	number;
	e_kat_zajeta exception;
	pragma exception_init(e_kat_zajeta, -20001);
begin
    select count(rzut_nr)
    into v_check 
    from rzuty_gracza 
    where kategoria = p_kat;
	
    if v_check = 0 then
        null;
    else
        raise_application_error(-20001, 'Kategoria została już wykorzystana. Wprowadź inną kategorię.');
    end if;
	
    select nvl(max(rzut_nr), 0)
    into v_rzut 
    from rzuty_gracza;
	
    select suma
    into v_wynik
    from gracz_suma_jednakowych
    where rzut_nr = v_rzut and ilosc_oczek = p_kat
    order by suma desc
    fetch first 1 row only;
	
    update rzuty_gracza
    set 
        wynik = v_wynik,
        kategoria = p_kat
    where rzut_nr = v_rzut;
end;
end kosci;