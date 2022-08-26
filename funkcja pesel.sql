create or replace function pesel(p_data_urodzenia varchar2, p_plec varchar2) return varchar is
G_MIN_DATA_UR constant date := to_date('01-01-1900', 'DD-MM-YYYY');
v_data varchar2(10) := p_data_urodzenia;
v_plec_check varchar(1) := upper(p_plec);
v_pesel varchar2(11);
bledna_data exception;
bledna_plec exception;
v_miesiac_ur number := 0;
pragma exception_init(bledna_data, -20000);
pragma exception_init(bledna_plec, -20001);
begin
case
  when v_plec_check not in ('M', 'K') then 
    raise_application_error(-20001, 'Błąd: Błędna płeć');
  when to_date(v_data, 'DD-MM-YYYY') not between G_MIN_DATA_UR and sysdate then
    raise_application_error(-20000, 'Błąd: Błędna data urodzenia');
  when to_date(v_data, 'DD-MM-YYYY') >= to_date('01-01-2000', 'DD-MM-YYYY') then
    v_miesiac_ur := extract(month from to_date(v_data, 'DD-MM-YYYY')) + 20;
  else
    null;
end case;

v_data := replace(v_data, '-', '');
v_pesel := substr(v_data, 7);
  
case when v_miesiac_ur>0 then v_pesel := v_pesel || v_miesiac_ur || substr(v_data, 1, 2) || to_char(round(dbms_random.value(100, 999)));
    else v_pesel := v_pesel || substr(v_data, 3, 2) || substr(v_data, 1, 2) || to_char(round(dbms_random.value(100, 999)));
end case;

-- dodaje parzystą cyfrę dla kobiet
case when v_plec_check = 'K' then v_pesel := v_pesel || round(dbms_random.value(1, 4)) * 2;
-- dodaje nieparzystą cyfrę dla mężczyzn
    else v_pesel := v_pesel || (round(dbms_random.value(0, 4)) * 2) + 1;
end case;
v_pesel := v_pesel || ceil(dbms_random.value(0, 9));
return v_pesel;
end;
