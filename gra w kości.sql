create table rzuty_gracza (
        rzut_nr number
    ,   kostka_1 number
    ,   kostka_2 number
    ,   kostka_3 number
    ,   kostka_4 number
    ,   kostka_5 number
);

create table rzuty_komputera (
        rzut_nr number
    ,   kostka_1 number
    ,   kostka_2 number
    ,   kostka_3 number
    ,   kostka_4 number
    ,   kostka_5 number
);

/*procedura symulująca grę w kości na naprostszym poziomie (wygrywa ten, kto wyrzuci większą sumę oczek)
przykład wywołania procedury:
	BEGIN
		rzucaj;
	END;*/
create or replace procedure rzucaj as
v_rzut number;
-- wewnętrzna funckja zastępująca dbms_random.value() o wartościach zastępujących wartości oczek na kostkach
function losuj return number as
x number := round(dbms_random.value(1,6));
    begin
        return x;
    end;
-- procedura przyjmuje jako parametr wartości 1 lub 2
-- 1 - rzut gracza
-- 2 - rzut komputera
procedure nowa_kolejka(gracz number) as
v_suma_gr number;
v_suma_kom number;
k_1 number;
k_2 number;
k_3 number;
k_4 number;
k_5 number;
    begin
        k_1 := losuj();
        k_2 := losuj();
        k_3 := losuj();
        k_4 := losuj();
        k_5 := losuj();
        if gracz = 1 then
            insert into rzuty_gracza values(v_rzut, k_1, k_2, k_3, k_4, k_5);
            dbms_output.put_line('Wyniki gracza: '||k_1||', '||k_2||', '||k_3||', '||k_4||', '||k_5);
            select k_1 + k_2 + k_3 + k_4 + k_5 into v_suma_gr from rzuty_gracza where rzut_nr = v_rzut;
            dbms_output.put_line('Suma gracza: '||v_suma_gr);
        else
            insert into rzuty_komputera values(v_rzut, k_1, k_2, k_3, k_4, k_5);
            dbms_output.put_line('Wyniki komputera: '||k_1||', '||k_2||', '||k_3||', '||k_4||', '||k_5);
            select k_1 + k_2 + k_3 + k_4 + k_5 into v_suma_kom from rzuty_komputera where rzut_nr = v_rzut;
            dbms_output.put_line('Suma komputera: '||v_suma_kom);
        end if;
    end;
begin
	select nvl(max(rzut_nr), 0) + 1 into v_rzut from rzuty_gracza; -- przypisanie numeru rzutu z jednej tabeli, 
	--gdyż dla obu graczy ta wartość powinna być identyczna
    nowa_kolejka(1); -- symulacja rzutu gracza
    nowa_kolejka(2); -- symulacja rzutu komputera
end;