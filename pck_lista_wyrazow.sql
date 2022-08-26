create or replace package pck_lista_wyrazow as
/**
*@name pck_lista_wyrazow Pakiet do obsługi list wyrazów
*@name Pakiet obsługuje proste listy wyrazów oddzielonych separatorem. Zawiera funkcje i procedury do prostych operacji i modyfikacji takich list.
 */
type T_TBL_WYRAZOW is table of varchar2(100);
/**
*@type typ tabelaryczny z jedną kolumną przyjmującą wartości tekstowe (varchar2(100))
*/
function podziel_tekst(p_tekst_wejsciowy varchar2, p_separator varchar2 default ',') return T_TBL_WYRAZOW;
/**
*@name podziel_tekst - @desc Funkcja dzieli listę wyrazów na pojedyncze wyrazy oddzielone separatorem i zwraca tablicę zawierającą te wyrazy.
*@param_1 p_tekst_wejsciowy typ varchar2. Przyjmuje listę wyrazów oddzielonych przecinkami.
*@param_2 p_separator typ varchar2. Przyjmuje wartość dla separatora. Domyślna wartość to ','.
*@return T_TBL_WYRAZOW. Funkcja zwraca tabelę zawierającą odseparowane wyrazy.
*/
procedure usun_wyrazy (p_tekst_do_zmiany varchar2);
/**
*@name usun_wyrazy - @desc Procedura wyświetla listę wyrazów zwróconą przez funckję @podziel_tekst, 
następnie usuwa z listy dwa środkowe elementy, po czym wyświetla listę po zmianach.
*@param p_tekst_do_zmiany typ varchar2. Przyjmuje listę wyrazów oddzielonych przecinkami dla funkcji @podziel_tekst, która ma zostać zmodyfikowana
*@exception no_data_found. Procedura zwraca wyjątek, gdy lista podana w @param p_tekst_do_zmiany ma mniej niż 3 elementy. Wyświetla: Zbyt krótka lista, usunięto wszystkie elementy
*/
procedure sortuj_liste (p_tekst_do_sortowania varchar2, p_kierunek_sortowania varchar2);
/**
*@name sortuj_liste - @desc Procedura sortuje listę wyrazów zwróconą przez funckję @podziel_tekst według wskazanego kierunku sortowania
*@param_1 p_tekst_do_sortowania typ varchar2. Przyjmuje listę wyrazów oddzielonych przecinkami dla funkcji @podziel_tekst, która ma zostać posortowana
*@param_2 p_kierunek_sortowania typ varchar2. Przyjmuje tylko jeden z dwóch kierunków sortowania: rosnący ('asc'), malejący ('desc')
*@exception e_blad_sortowania. Wyjątek zdefiniowany przez użytkownika. Zwracany, gdy wartość podana w @param p_kierunek_sortowania jest inna niż 'asc' lub 'desc'
Wyświetla: Błąd: Podano niewłaściwy kierunek sortowania
*/
procedure bez_duplikatow (p_tekst_poczatkowy varchar2);
/**
*@name bez_duplikatow - @desc Procedura usuwa duplikaty z listy zwróconej przez funckję @podziel_tekst, po czym wyświetla zmodyfikowaną listę
*@param p_tekst_poczatkowy typ varchar2. Przyjmuje listę wyrazów oddzielonych przecinkami dla funkcji @podziel_tekst, z której mają zostać usunięte duplikaty
*/
procedure zmien_na_liste (p_tekst varchar2, p_nowy_separator varchar2 default ',');
/**
*@name zmien_na_liste - @desc Procedura przekształca tablicę zwracaną przez funckję @podziel_tekst na wartość tekstową i wyświetla listę wyrazów oddzielonych wskazanym separatorem
*@param_1 p_tekst typ varchar2. Przyjmuje listę wyrazów oddzielonych przecinkami dla funkcji @podziel_tekst, która ma zostać przetworzona
*@param_2 p_nowy_separator typ varchar2. Przyjmuje wartość dla separatora, który ma oddzielać wyrazy na liście zwróconej przez procedurę
*@desc Procedura nie usuwa separatora zdefiniowanego w parametrze funckji @podziel_tekst, tym samym zwraca listę wyrazów oddzielonych dwoma separatorami
*/
end pck_lista_wyrazow;
/
create or replace package body pck_lista_wyrazow as
function podziel_tekst(p_tekst_wejsciowy varchar2, p_separator varchar2 default ',') return T_TBL_WYRAZOW as
t_tbl_results T_TBL_WYRAZOW := T_TBL_WYRAZOW();
G_WZOR constant varchar2(20) := '([^,]*)(,|$)';
begin
  select trim(regexp_substr(p_tekst_wejsciowy, G_WZOR, 1, level, null, 1 )||p_separator)
  bulk collect into t_tbl_results from dual
  connect by level < regexp_count(p_tekst_wejsciowy, G_WZOR);
  return t_tbl_results;
end podziel_tekst;

procedure usun_wyrazy (p_tekst_do_zmiany varchar2) as
t_tbl_do_zmiany T_TBL_WYRAZOW := podziel_tekst(p_tekst_do_zmiany);
v_indeks pls_integer := t_tbl_do_zmiany.first;
v_srodek pls_integer := round(t_tbl_do_zmiany.count/2);
begin
  dbms_output.put_line('Lista wejściowa:');
  for i in t_tbl_do_zmiany.first..t_tbl_do_zmiany.last
  loop
    dbms_output.put_line(t_tbl_do_zmiany(i));
  end loop;
  
  t_tbl_do_zmiany.delete(v_srodek);
  t_tbl_do_zmiany.delete(v_srodek +1);
  
  dbms_output.put_line('Lista po zmianach:');
  while (v_indeks is not null)
  loop
    dbms_output.put_line(t_tbl_do_zmiany(v_indeks));
	v_indeks := t_tbl_do_zmiany.next(v_indeks);
  end loop;
exception
  when no_data_found then 
  dbms_output.put_line('Zbyt krótka lista, usunięto wszystkie elementy');
end usun_wyrazy;

procedure sortuj_liste (p_tekst_do_sortowania varchar2, p_kierunek_sortowania varchar2) as
t_tbl_do_posortowania T_TBL_WYRAZOW := podziel_tekst(p_tekst_do_sortowania);
t_tbl_posortowana T_TBL_WYRAZOW;
e_blad_sortowania exception;
begin
  if lower(p_kierunek_sortowania) = 'asc' then 
  select * bulk collect into t_tbl_posortowana from table(t_tbl_do_posortowania) order by 1;
  elsif lower(p_kierunek_sortowania) = 'desc' then  
  select * bulk collect into t_tbl_posortowana from table(t_tbl_do_posortowania) order by 1 desc;
  else raise e_blad_sortowania;
  end if;
    
  for i in t_tbl_posortowana.first..t_tbl_posortowana.last
  loop
    dbms_output.put_line(t_tbl_posortowana(i));
  end loop;
  exception
  when e_blad_sortowania then
  dbms_output.put_line('Błąd: Podano niewłaściwy kierunek sortowania');
end sortuj_liste;

procedure bez_duplikatow (p_tekst_poczatkowy varchar2) as
t_unikatowe_wartosci T_TBL_WYRAZOW := T_TBL_WYRAZOW();
begin
  t_unikatowe_wartosci := set(podziel_tekst(p_tekst_poczatkowy));
  dbms_output.put_line('Lista bez duplikatów:');
  for i in t_unikatowe_wartosci.first..t_unikatowe_wartosci.last
  loop
    dbms_output.put_line(t_unikatowe_wartosci(i));
  end loop;
end bez_duplikatow;

procedure zmien_na_liste (p_tekst varchar2, p_nowy_separator varchar2 default ',') as
t_na_liste T_TBL_WYRAZOW := podziel_tekst(p_tekst);
v_lista_wyrazow varchar2(32000);
begin
  for i in t_na_liste.first..t_na_liste.last
  loop
	if i = 1 then v_lista_wyrazow := t_na_liste(1);
	else v_lista_wyrazow := v_lista_wyrazow || p_nowy_separator || ' ' || t_na_liste(i);
	end if;
  end loop;
  dbms_output.put_line(v_lista_wyrazow);
end zmien_na_liste;

end pck_lista_wyrazow;