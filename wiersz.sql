-- utworzenie tabeli przechowującej wersy
create table  "wersy" (	
		"id" 			number generated always as identity
	,	"wers" 			varchar2(1000 char)
	, 	constraint 		"pk_wersy" primary key ("id")
)
/
create table  "autor" (	
		"id" number generated always as identity
	,	"imie" varchar2(50)
	,	"nazwisko" varchar2(50)
	, 	constraint "pk_autor" primary key ("id")
)
/
create table  "wiersze" (
		"id_wiersza" number(10,0)
	, 	"nr_wersu" number(10,0)
	, 	"id_wersu" number(10,0)
	, 	"id_autor" number, 
	constraint "pk_wiersze" primary key ("id_wiersza", "nr_wersu", "id_wersu")
)
/
alter table  "wiersze" add constraint "fk_id_wersu" foreign key ("id_wersu")
	  references  "wersy" ("id") enable
/
alter table  "wiersze" add constraint "fk_wiersz_autor" foreign key ("id_autor")
	  references  "autor" ("id") enable
/

--utworzenie typu tabelarycznego
create or replace type t_tbl is table of varchar2(1000);
-- pakiet pck_wiersz
create or replace package pck_wiersz as
-- procedura wstawiająca wersy do tabeli 'wersy', 
-- jako parametr (p_tekst) przyjmuje tekst, w którym wersy oddzielone są od siebie separatorem '/'
procedure wstaw_wersy(p_tekst varchar2);
/*procedura generująca nowy wiersz na podstawie prawdziwych wersów i wstawiająca go do tabeli 'wiersze' (w praktyce taki sztuczny wiersz często jest ciekawszy 
niż składające się na niego oryginały, no ale co zrobić, taką mamy poezję. Na szczęście poezji nikt już na poważnie nie czyta, 
no - może poza samymi poetami, którzy czytają się wzajemnie i nieustannie porównują to do Rielkego, to do Szymborksiej, to do 
Bóg wie kogo. Choć może i w tym problem, że nikt nie czyta? Może gdyby czytano poezję tak chętnie, jak czyta się fantasy 
(tutaj z kolei każdy jest nowym Tolkienem! Tylu tych nowych Tolkienów, że to już żadna nowość)... wracając jednak - gdyby 
czytano poezję równie chętnie jak fantasy i gdyby zarobek był podobny, może wówczas najpłodniejsze umysły literackie nie 
szłyby w prozę, a własnie w krótsze formy? Nikt mi przecież nie powie, że Hanna Krall ze swoją skondesowaną do maksimum prozą 
nie byłaby zdolna skondensować jej do poezji! Zresztą powiedział Kieślowski (swoją drogą przyjaciel Hanny Krall), że to, na 
wyrażnie czego za pomocą filmu on potrzebował kilku milionów franków, Szymborska wyraziła zgrabniej za pomocą kartki, 
pióra i kilku linijek. No ale ostatecznie, kto dziś pamięta wiersz Szymborskiej? (niestety!)...
@param p_licz_wersow - jako parametr przyjmuje liczbę wersów, z jakiej ma składać się nowy wiersz*/ 
procedure generuj(p_licz_wersow number);
-- funkcja wyświetlająca wiersz o podanym w parametrze id_wiersza
function wyswietl_wiersz(p_id_wiersza number) return t_tbl;
end pck_wiersz;

create or replace package body pck_wiersz as
---------------------------------------------
procedure wstaw_wersy(p_tekst varchar2) as
t_wersy t_tbl := t_tbl();
begin
    select trim(regexp_substr(p_tekst, '([^/]*)(/|$)', 1, level, null, 1 ))
    bulk collect into t_wersy from dual
    connect by level < regexp_count(p_tekst, '([^/]*)(/|$)');
    for i in t_wersy.first.. t_wersy.last
    loop
        insert into wersy (wers) values (t_wersy(i));
    end loop;
end wstaw_wersy;
---------------------------------------------
procedure generuj(p_licz_wersow number) as
v_id number;
v_id_wiersza number;
v_wers varchar2(1000);
begin
    select nvl(max(id_wiersza), 0) + 1 into v_id_wiersza from wiersze;
    for i in 1..p_licz_wersow
    loop
        select id, wers into v_id, v_wers from wersy 
        order by dbms_random.value() fetch first 1 row only;
        insert into wiersze(id_wiersza, nr_wersu, id_wersu, id_autor)
            values(v_id_wiersza, i, v_id, round(dbms_random.value(1,10),2));
        dbms_output.put_line(v_wers);
    end loop;
end generuj;
---------------------------------------------
function wyswietl_wiersz(p_id_wiersza number) return t_tbl as
t_wiersz t_tbl := t_tbl();
begin
    select w2.wers bulk collect into t_wiersz
    from wiersze w1 join wersy w2 on w1.id_wersu = w2.id
    where w1.id_wiersza = p_id_wiersza
    order by w1.nr_wersu;
    return t_wiersz;
end;
---------------------------------------------
end pck_wiersz;

--wstawianie wersów za pomocą procedury wstaw_wersy()
BEGIN
	pck_wiersz.wstaw_wersy('Kocham Chariel więc kiedy powiedziała/
resztę życia spędzę tylko z mężczyzną z którym będę się czuła/
naprawdę świetnie/
poczułem w tym pewną szansę dla siebie/
To od tego dnia zacząłem wylewać za kołnierz/
w zamian zabierałem ją na wystawy kotów transyberyjskich/
a wieczorami błądziliśmy alejkami maszynowych parków/
zbierając nakrętki snów i te wszystkie niezauważane przez tylu mimośrody/
Chariel zardzewiała je potem w swoim pamiętniku/
tymczasem ja wyświadczałem jej szereg drobnych przyjemności/
                        jak/
dzienne przypływy i odpływy statków kuchennych/
conocne obmywanie fiordów miednicy/
nadawanie wyłącznie na fali wysokiej częstotkliwości/
i przenikanie do górnych warstw świadomości poprzez szyjkę macicy/
oraz wracanie do siebie dopiero po tym kiedy ona już wróciła do siebie/
co poświadczy załącznik numer 221/
            Wpajęczonej w rozpuszczone włosy exodus dłoni/
            na drżących ze zmęczenia palcach/
            na przełaj siebie na myśli skos/
            na dnia poniewierkę/
            A tak słodko tak dobrze śniła nas dzisiaj noc/
            gdy na rzęsie zachmurzonej powieki/
            kogut zapiał w czarną źrenicę/
A jednak Mimo wszystkich moich starań i świadczeń/
coś jeszcze gryzło Chariel/
nadgryzało poczucie bezpieczeństwa jej szczęścia bez granic/
było naprawdę upierdliwe W końcu/
postanowiłem zapytać wprost/
czy ty czujesz się Chariel ze mną świetnie?/
Chariel milczała obserwując powracające bociany/
a potem odlatujące bociany i znów wracające bociany/
Ja w międzyczasie wyświadczałem jej te wszystkie usługi/
o których wspominałem wcześniej oczywiście dodając do tego nowe usługi/
takie jak choćby pomaganie Chariel w obserwacji powracających bocianów/
a potem odlatujących bocianów/
Wraz z zamieszczonym na dole rysunkiem/
dość dokładnie zostało to opisane na stronie 666 jako "Malis avibus"/
            Dochodzimy co noc bliżej & bliżej/
            od tamtego jesiennego wieczoru gdy pierwszy raz skosztowaliśmy win/
            dochodzimy teraz o wiele wcześniej od rozbudzonych mgieł i nawoływań ptaków/
            Czułe ścieżki z wrośniętymi w nie miejscami naszych spotkań/
            coraz bardziej rozszerzają się w wiosennym słońcu/
                        już/
                            nie/
                                można/
                                    przemierzyć/
                                        ich/
                                            w/
                                                okamgnieniu/
            Coraz bardziej zmęczeni i zobojętniali nierzadko z łzawiącymi oczami/
            dochodzimy chyłkiem do siebie/
                            niet perz/
                                 o           niet perz/
                                                   o/
Ta opowieść nie ma końca/
Zawsze musielibyśmy wrócić do/
Kocham Chariel więc kiedy powiedziała/
resztę życia spędzę tylko z mężczyzną z którym będę czuła się/
naprawdę świetnie/
poczułem w tym pewną szansę dla siebie/
Zresztą czy miałbym siłę wykrztusić coś jeszcze/
przyciśnięty zardzewiałymi mimośrodami/
rozgnieciony na płask wyblakłymi nakrętkami snów/
rzucony przez Chariel w kartkę pamiętnika jak kamień w wodę?/
    Mineralogia mogłaby powiedzieć co nieco skąd się wziął/
    dlaczego właśnie w tym miejscu spierałby się do śmierci geolog z geodetą/
    Chemik prześwietliłby na wskroś kruche ciało i wskazał na związki/
    z resztą kosmosu Ot choćby ze mną/
    która wybrałam właśnie jego z brzegu kamienistej plaży/
    skupiona tylko nad tym ile kaczek pozostawi na wodzie/
    Kilka podskoków po milionach lat bezczynności/
    prawdziwie nieludzki wysiłek/
    zasiedziałych w wieczności krzemowych mięśni/
        Spoczywając w miękkim mule wspomina teraz chwilę/
        kiedy był ptakiem lecącym ponad grzywami fal/
        kamienieje marząc o dniu/
        w którym znów ożywi go czyjaś śmiertelna ręka/
		Poeta który nie kocha nawet siebie/
samotny żeglarz oceanów alkoholi/
wodzirej korowodów najprawdziwszych kłamstw/
ma najbardziej perwersyjne sny/
pięć szarych myszek białego kota/
szklane barykady/
skupiające/
krótkowzroczne donosy chorych wierszy/
                 mędrzec któremu zabito mądrość/
                 mówca któremu spalono język/
                 krzyż któremu zeskrobano resztki chrystusa/
                 poeta któremu zgwałcono serce/
opuszczony przez najbliższych/
wyklęty mały apollo zrzucony z parnasu/
zapuszcza  brodę i włosy zaczyna ćpać/
zbierać kolorowe wizje bawi go chiromancja/
restauruje spróchniałe świątki/
penetruje małe rynki wielkich spekulacji/
jego specjalność cztery szare myszki/
krótkowzroczny kot skaleczone wiersze/
                 mędrzec któremu zabito mądrość/
                 mówca któremu spalono język/
                 krzyż któremu zeskrobano resztki chrystusa/
                 poeta któremu zgwałcono serce/
dmucha w dym gitary jimi hendrixa/
traci oddech konającej a"capella janis joplin/
pyta hamleta to be or not to be/
a na wyspie lesbos zadaje this question/
ziewającemu ze wściekłości aleksandrowi synowi filipa/
czy abel zabił kaina czy faust sprzedał ciało diabła/
zapora szkła tryska krwią/
to druga myszka biały kot kalekie wiersze/
                 mędrzec któremu zabito mądrość/
                 mówca któremu spalono język/
                 krzyż któremu zeskrobano resztki chrystusa/
                 poeta któremu zgwałcono serce/
zawieszony między piętrami podświadomości/
w windzie empire state building/
traci wiarę/
przestaje być dumnym ze swego penisa/
wymiary kelie everts 110 58 88 nic nie pomogą/
kot pożera trzecią myszkę/
o czym donosi ślepnący wiersz/
po obu stronach oka/
                 mędrzec któremu zabito mądrość/
                 mówca któremu spalono język/
                 krzyż któremu zeskrobano resztki chrystusa/
                 poeta któremu zgwałcono serce/
zafascynowany głosem edith piaf/
tańcem isadory duncan/
mimo że wczoraj spartakus popędu wygrał kolejną walkę/
ze sobą że wczoraj umarła ostatnia dziewica/
a leonardo namalował płacz mony lizy/
myśli że jest/
że nic co ludzkie nie jest mu obce/
biały kot połknął naraz dwie myszki wolny wiersz/
                 mędrzec któremu zabito mądrość/
                 mówca któremu spalono język/
                 krzyż któremu zeskrobano resztki chrystusa/
                 poeta któremu zgwałcono serce/
skrzydła niepokorne/
odrąbane/
nie dały się wcisnąć/
do kapliczki/

drewniany kaleka/
na straży/

świętego spokoju/
wiosenny deszcz/
kura z podniesioną nogą/
obserwuje/
tak podwórko/
szmatka nieba/
krąg oficyn/
jedno drzewo/
smutny leśny statysta/

ambulans/
bo walenie wkoło zatok/
płetwa w koszu/
wódka może ropa/
ból wypukły czoło głowy/

policjanta polowanie/
z których drzwi?/
pięści/

                        kamienowanie/

szczerbatych okien/
świszczą listopadem/
przez wszystkie/

                         kości/

najczęstsza gra za pieniądze/
na parterze nóż zza szyi/
                        nie zaszyli/

sąsiedzi sąsiedzi!/
na językach parapetów/
wystaje cicho/
spod ciekawskich łokci/
poduszka czy zza uszka/
dłoń/?/
kawa stygnie/
godzinami dzień/
                         sczerniały/
zęby dzieciom/

w oddechu sieni/
rytmiczne wahadło na krzesełku/
z kieliszkiem/
nowy  z Zapadłej/

                         głowa przyrosła mu do paznokci/

       ... jaka pustka młoda/
           jak kapustka/
           jak kapustka młoda/
           jaka pustka.../

                                                          nie ufa nawet sobie/
mama dzwoniła po każdym grzmocie/
odbierałam z nowym błyskiem/
burza w grudniu/
nie wróży niczego/

przerwała pytaniem/
czy wszystko w porządku/

tak więc przycupnęłam na parapecie/
nie. nie umyję okien przed świętami/
i z rozmysłem przyczernię pierniki/

a teraz czekam/
aż spadnie/

może gwiazda spadnie/

wiem. wiem że nie sierpień/
ale może. w końcu/
grudnie są nieobliczalne/

sama mówiłaś przed chwilą/
że takiej burzy to jeszcze nigdy/

wiem że się martwisz/
ale pocupię. jeszcze/

pogłaskałam policzkiem/
słuchawkę/
Wtulali nas/ 
w ciepłe koce i kazali spać/
a wody rzek i kałuż/
wciąż wzbierały./
Więdły ogrody./

Nocami wracaliśmy /
w ową krainę/
zerwanych mostów /
potłuczonych nabrzeżnych latarni./
Przesiąkaliśmy wonią zgnilizny./

Gdy oni kazali nam spać /
my wciąż śniliśmy./
I przerażały nas/
nasze własne świątynie./
baran na rożnie/
wyścigi osiołków/
kantor zawodzi psalmy/
tysiącletnia świątynia zapada się w ziemię/
duchowny czarnymi od zeszłorocznych zbiorów oliwek/
rękami/
dzieli chleb/
Matkę Boską/
jak co roku/
anieli biorą do nieba/

potem/
zasypiamy na plaży/
odrzucając spod głów kamienie niewiary/
wiesz, udawanie śpiącego wcale nie było trudne, a Mary/
lekko znudzona przemykała nade mną, wokół czółna łóżka,/
wzdłuż rozchylających poły ścian - niczym zwiastun śmierci/
z książek Dicka, z filmów Schumachera/

była nieuchwytna w pasie jak dym, wychodziła lekko wraz/
z oddechem mleczną zimową wstążką i kładła siną ciszę/
na powiekach, powieki-groby zasypywała maku piaskiem,/
ciii-szeptała przez zasłonę z pluszu, ciii-miękło, głuchło na granicy/

w miejscu, w którym przestawałaś czytać wers/
zasypiałem/
Gdzie siedział ten stary człowiek pijacy piwo/
gdzie wierni słuchacze/
którym sprzedawał tanie historyjki całymi dniami/

Był/
i odszedł/
a ktoś po latach zdumiony odnalazł siebie/
w tamtej historyjce/
prostej jak prosta może być opowieść/
starego człowieka/
o życiu./
(a żeby tak mrugnięciem
mrugnięciem zabić tego dziwkę wróbla
i żeby tak 
i żeby tak nic z niego nie zostało
i żadnej kukułki)

Pedro Almodovar zakłada czerwone lakierki/
wychodzi na ulicę i przechadza się tam i z powrotem/
rozprawiając z Bunuelem o movie-punku/
w tym samym czasie ta zielona suka znowu przychodzi/
i zawraca mi głowę opowieściami o połówkach cytryn/
wyciskanych na jej kościstych sutkach/

(i że tak mocno/
że tylko skórki puste zostają/
i że te skórki/
że jakby tak człowieka w ten sam sposób/
do piersi przyłożyć)/
i takie tam brednie/

ale Pedro Almodovar przerywa nagle rozmowę/
łapie Bunuela za rękaw i obraca/
Bunuel stoi teraz twarzą zwrócona w przeciwna stronę/
w stosunku do strony opanowanej przez twarz Almodovara/
(ten Almodovar to kawał chłopa - myśli sobie Bunuel)/

(łebski gość - nie powiem)/
ale teraz zamilknij/
tak jakbyś robiła to tylko dla siebie i przepoconej pościeli/
żadnego więcej ruchu językiem !/

(położyć (się)/
odpalić od poprzedniego/
obrócić (się) na brzuch /
i z twarzą wciśniętą w resztki prześcieradła/
spokojnie spalić tego ostatniego)/

Pedro Almodovar ogląda tego dziwkę wróbla/
Luis Bunuel - Obrócony /
siłą rzeczy/
tego wróbla nie widzi/
rozpoczynają więc rozmowę od początku/

no wiec posłuchaj:/
to nie tak że nie wiem co to miłość/
ja też kocham/
ale tak żeby nic z tego nie zostało/
- ze mnie też?/
z ciebie? przede wszystkim kochana - możesz teraz być/
jak te skórki, o których mówiłaś/

to już nie ta sama rozmowa/
myśli sobie Luis Bunuel - Obrócony/
Matka Boska wśród chabrów /
Święty Jan w reumatyzmie z oparów Jordanu/
Święty Antoni zagubiony w Padwie/
Święty Jerzy umęczony po brzegi/
Tęskniący za mieczem/
/
I do kogo teraz my trędowate/
Komu swoje pacierze rozsypane/
Po wszystkich zakrętach/
I płonące jak witraże/
Szkła niebieskich oczu /

Matka Boska w białych rękawiczkach/
A my ani do karczmy ani do klasztoru/
Ani przejrzeć się w studni albo dotknąć sznura /
Tylko grzechotka w nas krzyczy/
I mówimy do innych pod wiatr/

Szubienice wzdłuż drogi /
Wyglądają jak wesołe miasteczko /
Ale znowu trzeba by zgrzeszyć/
To tylko wiersz/
zwykłe wydalanie/
toksyn z organizmu/
Pomaga wieczorami/
gdy boli mnie/
twój żołądek/
pęka twoja głowa/
i urywa się twój film/
ze mną w roli głównej/

To tylko wiersz/
czasowy regulator/
nadmiaru endorfin/
i nadziei na oszukanie/
wiecznego głodu/
twoim dotykiem/

To tylko wiersz/
przeskok iskry/
na niewłaściwą synapsę/
o jedną w lewo wyszedłby/
przepis na szarlotkę/
o jedną w prawo/
twierdzenie Talesa/

Tymczasem to znowu/
tylko wiersz –/
zawór bezpieczeństwa/
dla tych którzy/
za wszelką cenę/
chcą codziennie/
umierać z miłości/

od kiedy wiem że nadchodzi moja jesień/
coraz częściej oglądam drzewa/
jakie ze mnie wyrośnie/
korzeniami obejmie mnie/
dzieląc się kawałkiem ziemi/
zaowocuje/
ułoży w kawałkach gałęzi w liściach wysoko/
abym tak jak teraz zamknięty w plastykowym ptaku/
szukał ciepłych wiatrów/
które tak naprawdę zataczają tylko wielkie koła/
prowadząc tam i z powrotem/

pode mną puste pola/
szachownica ze wspomnień/
białe czarne białe czarne/

piję toast za nadchodzącą jesień/
pierwsze przymrozki obsiadły moją twarz/
upodabniają mnie do ojca/
ja jestem tym drzewem które z niego wyrosło/
pierwszym drzewem ostatnim drzewem/
bezowocnym drzewem/
drzewem bez korony/
drzewem bez drzew/

Nowy Rok/
w mojej pościeli/
figi i cekiny/

mam psy na smyczy przytrzymane; drżenie ich mięśni/
rezonansem świat może skruszyć na atomy./

spomiędzy palców rodzę ptaki,/
by moje imię rysowały na świeżym prześcieradle/
śniegu, na modrej płachcie lata./

tak, to moje miejsce, niezmienione/
miasto od drzwi do drzwi. cmentarza/
nie ma: jest łąka tak zielona/
jakbym ją sama malowała plakatówką/
kiedy jeszcze żyłaś, mamo -/
i wymawiam to słowo, chociaż wiem/
że to tylko wiatr zamiata przestrzeń./

błąkał się/
po świątyni/
ołtarze/
w niej większe/
niż bóstwa/

chciał podziękować/
za trzezwe myślenie/
i modrzewie przed domem/

nie znalazł bogów/

po sezonie/

Pluszowy piasek wspomina muzykę./
Loże teatru kryją czerń papieru/
spalonych książek. Milczy wybaczenie./
O broń i konia woła wierny markiz/
w śnie o Wandei, zemście i galopie./
Pocisk rozpaczy, który skupia pióra/
strzały lecącej ku zniszczonym polom./
Szuański olbrzym spala całą przeszłość,/
złotą niezgodą pijany jak winem;/
pośród konwulsji honor swój odsłania/
w prostym dramacie pękniętego serca./

Śni sen ostatni, sen przed załamaniem/
gdy rozpacz jeszcze w śmierć się nie przemieni./
Bretońskie skały wskazują na krzyże/
gotyckich katedr wśród kamiennych kręgów./
Nadzieja wlała się w kielich przeszłości,/
aktorzy toast spełnili i wyszli./
Prawdę ponieśli, która w nich została/
gdy powrócili do bujnej pamięci./

pierwszy krzyk/
ostatni szept/
data początku/
data końca/
imię/
        nazwisko/
                       adres/
                                wiek/
stara nieufność/
granice państwa/
polityka sensu stricto/
polityka sensu large/
racja narodu/
trefle/
          kara/
                   kiery/
                            piki/
as atutowy/
wieża widmo/
ja/
moje alter ego/
wieczny brak pieniędzy/
wiara bez wiary/
samotność we dwoje/
samotność w sobie/
wielki znak zapytania/
walka o byt/
idea/
         materia/
                      utopia/
                                bóg/
kolejne szaleństwo/
biała gorączka/
czarny kot/
szare myszki/
raport kropki nad i/
życie bez życia/
miłość bez słów/
miłość w słowie/
wiosna/
            lato/
                   jesień/
                             zima/
dead heat on the bridge/
in santa polonia/
na linii N - S./
Na trasie W - E/
król/
       dama/
                 walet/
                           dziesiątka/
koronacja trędowatej/
licentia poetica ex ante/
licentia poetica ex post/
zielone sukno/
sześćdziesiąt cztery/
pięćdziesiąt dwa/
błędny rycerz/
e2 - e4/
             e7 - e5/
                         pas/
                               pas/
                                      pas.../
									  
nie warto rozważać co warte a co nie/
każdy przechodzi swój reset/
docisk jest fajny/
bo wyciska z nas co najlepsze/
ale nie każdy lubi przechodzić egzorcyzmy/
ale taki jest Graal/
i dlatego zawsze przed nami/
jest daleka droga/
taka podróż/
to nasza Nibylandia/

w życiu tylko raz się pomyliłem/
że moje narodziny i śmierć są na niby/

realnie czuję sen i przebudzenie/
najlepsze kobiety to takie/
które są zagubione/
o których nie pamiętam/

mój raj to 25 stopni/
nad falą/
i pod wodą/

Podziel się Swoją Boskością,/
nie stracisz nic,/
może cień wyblaknie,/
a ja,/
będę słońcem wśród swoich,/
tylko zrozumienie mi daj/
i nakarm ból.../

Bądź,/
nie kiedyś,/
bo czas jest silniejszy niż My,/
teraz,/
w zagubieniu,/
w każdym dniu,/
zagraj ze mną w zielone.../

Zadrap mnie,/
zadrap Moja Miłości,/
na wskroś,/
w zapachu pochłonę Cię,/
w skowycie posiadę,/
Ty mnie,/
bądź bardziej niż On,/
przytul mnie.../

z podniesioną głową idzie/
bez uśmiechu,sztywna/
niczym na szczudłach klaun/
czy żyrafa,życia pantonima/

listek chciałaby skubnąć kwiatek/
a tu szuczne drzewo i sztuczna/
ikebana,całkowita monotonia/

trele gwizdają/
ugilgać by chciały/
lecz jak dumę dotknąć?/

piasek,wiadro,wapno,woda/
na pustaka się to przyda/
widelec ma widły,palce grabie/
tak wywijać nimi wiatrowo można/

dzisiaj do życia by być człowiekiem/
to nie obrazem człowieka/
w chodzącej mumi balsamicznej/

więc się uśmiechnij/
w trumnie też nie każdy dumnie leży/
życie bez uśmiechu dumy nie wnosi/
kiedy jest nudnością życia .../

...niech sobie poduma.../

Widzę, widzę łuk miesiąca//
Przez listowie gęstych rokit,//
Słyszę, słyszę stuk tętniący//
Nie podkutych dźwięcznych kopyt.//

Ach, i ciebie sen nie morzy,//
Przez rok mnie nie zapomniałeś,//
Przyzwyczaić się nie możesz,//
Żeby łóżko pustką wiało?//
 
Czy nie z tobą dyskurs toczę//
W chciwych ptaków ostrym tonie,//
Czyż nie w twoje patrzę oczy//
Z czystych, zmatowiałych stronic?//

Czemu się, jak rabuś, znowu//
Skradasz, krążysz niedaleko?//
Czy pamiętasz tę umowę://
Na mnie żywą ciągle czekać?//

Już zasypiam. W duszne ciemnie//
Księżyc rzucił ostrze swoje.//
Znowu stukot. Ach, to we mnie//
Bije ciepłe serce moje.//

Znowu więdną wszystkie zioła,//
Tylko srebrne astry kwitną,//
Zapatrzone w chłodną niebios//
Toń błękitną.//

Jakże smutna teraz jesień,//
Ach, smutniejsza niż przed laty,//
Choć tak samo żółkną liście.//
Więdną kwiaty,//

I tak samo noc miesięczna//
Sieje jasność, smutek, ciszę//
I tak samo drzew wierzchołki//
Wiatr kołysze.//

Ale teraz braknie sercu/
Tych upojeń i uniesień,/
Co swym czarem ożywiały/
Smutną jesień./

Dawniej miała noc jesienna/
Dźwięk rozkoszy w swoim hymnie,/
Bo aielska, czysta postać/
Stała przy mnie./

Przypominam jeszcze teraz/
Bladej twarzy alabastry,/
Kruzce włosy, a we włosach/
Srebrne astry./

Widzę jeszcze ciemne oczy/
I pieszczotę w ich spojrzeniu/
Widzę wszystko w księżycowym/
Oświetleniu./

Widziałem cię wczoraj w nocy – siedziałaś na regale z książkami /
i rzeźbiłaś w drewnie wiewiórki; księżyc ciął je na plastry. Cienie /
przechyliły się lekko w przyszłość – w kierunku zielonej lampki. /

Wcześniej milczałaś o końcu świata; że musisz uciec, że nie starczy /
świętości dla nas i dla kanarka. Choć on nie może zmartwychwstać, /
na twoich kolanach ciągle stygnie marzenie, najsmutniejsza klatka. /

Ale smutek to odtwarzanie na gramofonie Armstronga. Nierówne /
rytmy, wspólne światełka, żółte kreski na chodniku pod blokiem. /
Jako dzieci patrzyliśmy w niebo – dzisiaj ono kaleczy nam stopy. /

On działa, w blasku i w ciemności,/
w huku wodospadów i w ciszy snu,/
lecz inaczej, niż głoszą wasi/
pasterze, pozostający pod dobrą/
opieką. szuka najdłuższej linii,/
drogi, która jest tak okrężna, że/
prawie niewidoczna. Gubi się/
w cierpieniu. Tylko ślepcy, tylko/
sowy czują czasem jej nikły ślad/
pod powieką./

Posłuchaj pan, panie podróżny,/
co się zdarzyło na Próżnej:/
Żyła tam Jagna, dobra i czysta,/
i chodził do niej Jan kancelista,/
akurat to była niedziela,/
kręciła się karuzela./
Zabrał tam Jagnę kochanek czuły/
i całkiem zmącił jej miły umysł./

Oczy tej małej jak dwa błękity,/
myśli tej małej - białe zeszyty./
A on był dla niej jak młody bóg,/
żebyż on jeszcze kochać mógł./

A lato, jak bywa w Warszawie,/
młodym slużyło łaskawie./
On ją zabierał nieraz na lodki,/
a ona jego leczyła smutki./
Posłuchaj pan, panie wędrowny:/
nastał ten dzień niewymowny,/
odszedł bez słowa kochanek podły,/
na nic się zdały płacz jej i modły./

Oczy tej małej jak dwa błękity,/
myśli tej małej - białe zeszyty./
A on był dla niej jak młody bóg,/
żebyż on jeszcze kochać mógł./

Pociągi odchodzą i statki,/
ona nie wróci do matki./
Kto by uwierzył w całym Makowie,/
że dla niej światem był jeden człowiek./
Przez niego więc siebie zabiła/
ta, co z miłości tańczyła./
Bóg jej wybaczył czyny sercowe/
i lody podał jej malinowe./

Oczy tej małej jak dwa błękity,/
myśli tej małej - białe zeszyty./
A on był dla niej więcej niż Bóg,/
żebyż on jeszcze kochać mógł./
/
Posłuchaj, niewierny kochanku,/
co nienawidzisz poranków:/
wróci jeszcze do ciebie ta trumna,/
gdzie leży twoja kochanka dumna./
Bo taki, co kochać nie umie,/
przegra - choć wszystko rozumie./
Bóg cię pokaże swą nieczułością/
za to, żeś gardził ludzką miłością./

Oczy tej małej jak dwa błękity,/
myśli tej małej - białe zeszyty./
A tyś był dla niej więcej niż Bóg,/
pokłoń się do jej martwych nóg./

Myślałam, że dawno umarłeś, ale/
gdybyś był martwy, albo przynajmniej snem, który się wypełnił/
twoja twarz wyglądałaby inaczej. I inny jest ten wiosenny poranek,/
kiedy wracam na przekór rozkładowi, tam, gdzie nagrobek zapada/
w wilgotną trawę zagajnika – tam wszystko milczy: gałęzie, drzewa;/
tam nawet kwiaty są chore. A wzgórze rośnie w rytm stałego przyciągania/
zdumiewająco brzydkiego krajobrazu, by zaraz się przewrócić całym/
ciężarem ustalonego już wcześniej porządku. Teraz jest zima./
Jest ciepło, bo siedzę w ogrzanym pokoju. Mam książki, trochę mebli/
i twój portret, który patrzy na mnie ze ściany. Więc śmiech nadal/
wykrzywia ci twarz? Ale wejdź, zamieszkaj. Za oknem? Nic takiego./
Jedyna ścieżka. Jedyne miejsce dokąd można pójść – twój grób./
Ale nigdy nie byłam. A teraz zabierz mnie jak zakładnika./
Zawlecz nonszalancko w głąb twojego la la landu, a ja pozwolę ci kręcić/
kołami mojej plisowanej spódnicy, aż twoje oczy staną się różowe,/
zawstydzając złote oparzenia wewnątrz fałd mojego serducha./
A potem utopmy się obydwoje w fasolowym piure z ziemniakami./

Obejrzawszy importowanych filmów niejedną setkę,/
Pewna mała grupka ludności chciała sobie urządzić orgietkę./
Ściśle biorąc, tylko cztery osoby, tak: John Dreptak, Rene Trypućko,/
Jedna pani Bzibziakowa i panna Lucy Jamochłon, zwana na codzień Lućką./

Bzibziakowa przyniosła patefon, Trypućko przytargał pół basa/
I wszyscy wesolutko porozbierali się na golasa,/
Co było zresztą praktyczne z powodu letniej spiekoty,/
Po czym John Dreptak z energią zawołał: - No do roboty!/

- Do roboty! - krzyknęli wszyscy, lecz tu wpadli w stary mechanizm,/
I Trypućko wywiesił hasło "MAŁA ORGIA WZMACNIA ORGANIZM"./
"Przez orgię do dobrobytu!" - krzyknęła pani Bzibziakowa,/
A John Dreptak wygłosił referat: "Orgia wsteczna, a orgia postępowa"/

Nazwali tę orgię imieniem Czwartej Dywizji Moździerzy,/
Uchwalili, że nawiążą kontakt z XIV Chorągwią Harcerzy,/
Po czym John Dreptak uchwałę końcową zgrabnie wymaścił,/
Rozpoczynając słowami: "My, Zjednoczeni Orgiaści..."/

A kończąc ogólnym apelem, który w każdej uchwale błyska,/
Że należy się przeciwstawić tak: zagrożeniu środowiska,/
Hałasowi, chorobom psychicznym i rozbijaniu atomów./
Tu ubrali się, pozapinali, i poszli do swoich domów./

Zaś wieczorem Dreptak do Trypućki zadzwonił z taką uwagą:/
- Stary, bardzo fajnie nam to wyszło, tylko czemu żeśmy byli nago?/
- Właśnie nie wiem! - odparł Trypućko. - W garniturach my by też mogli/
I w ten sposób wytworzył się model Uroczystej Akademii, czyli - Polskiej Orgii./

Coraz trudniej nam pisać do Ciebie/
coraz trudniej do Ciebie nam być/
coraz trudniej przerobić na siedem/
numer nieba pod którym przyszło nam żyć/
 
Kiedy chciałem byś przerwała tę zabawę/
Byleś wreszcie poszła za mną/
Jakiś kułak intelektu/
powiedział że wyrywam Cię z kontekstu/
i że dura lex i sed lex/
albo jakoś tak podobnie się wyraził/
języki obce są mi obce/
i nie wiem co te słowa znaczą/
ale jestem prawie pewien/
i mnie i Ciebie tym obraził/
 
Coraz trudniej nam pisać do Ciebie/
coraz trudniej do Ciebie nam być/
coraz trudniej przerobić na siedem/
numer nieba pod którym przyszło nam żyć/
 
Tyś już przecież ani wielka, ani piękna/
już niemłoda, chyba niezbyt mądra jeszcze/
i ja mam niewiele więcej/
mam w zanadrzu już ostatnie moje serce/
i z kim ja się mam pogodzić/
z Tobą, czy z tym rzeczy stanem/
jeśli z Tobą - Ty mnie pogódź/
bo ja mogę żyć bez Ciebie/
jak nic złego się nie stało/
tak nic złego się nie stanie/
 
Coraz trudniej nam pisać do Ciebie/
coraz trudniej do Ciebie nam być/
coraz trudniej przerobić na siedem/
numer nieba pod którym przyszło nam żyć/
 
A wolność to nie jest port, nie adres i nie przystań/
wolność, to ona po to może być, żeby z niej czasem/
nie skorzystać.../

Dam ci w prezencie miasteczka/
Małe smutne miasteczka/

Miasteczka w naszych rękach/
są bardziej ponure niż zabawki/
lecz równie łatwe w obsłudze/

Bawię się miasteczkami/
Rozpruwam je/
Żaden człowiek mi stąd się nie wymknie/
Ni kwiatek ni dziecko/

Małe miasteczka są puste/
są zdane na łaskę naszych rąk/

Podsłuchuję z uchem przy drzwiach/
Przy kolejnych drzwiach moje ucho/

Domy podobne są do niemych muszli/
Ich wystygłe spirale/
nie przechowały nawet echa wiatru/
ni szmeru wody/

Parki i ogrody są martwe/
Zabawy ponumerowane/
jak w muzeum/
Nie wiem gdzie pochowano/
zamarznięte całka ptaków/

Ulice aż dźwięczą od ciszy/
A echo ciszy jest ciężkie/
O wiele cięższe/
niż słowa groźby czy miłości/

Kolej na mnie/
Porzucam miasteczka mojego dzieciństwa/
A tobie oddaję pełnię/
ich samotności/

Czy rozumiesz grozę tego daru?/
Dałam ci dziwne i smutne miasteczka/
by ci się przyśniły/

Zamykam oczy, może otwieram/
w niebo spoglądam. Jakieś białe.../
Nie wiem czy żyję, czy umieram/
Boję się wiedzieć, więc nie pytałem./

Łzy mi podano, wiszą w kroplówce,/
nadziei płynnej klepsydrze./
Leżę jak mięso na śmierci stołówce/
Ta zaraz serce mi wydrze./

Są jakieś słowa, kilka zeszytów./
W zaświat ma dusza migruje/
Zostało na chwilę niebo z sufitu/
I wiersz jakiś kiedyś/
ktoś ekshumuje./

Leszczyny z brzozy wyciągają do mnie młodzieńcze palce liści/
W drewnianej izbie Paweł Kochański gra III Koncert skrzypcowy/
i przerywa zapatrzony w sino-szare Tatry/
Szelest potoku na kamieniach czy szum starości w uszach/
Styks płynie pod ścianami mojego pokoju/

Bóle w klatce piersiowej nie oznaczają zawału/
Okno ciemnieje i światła latarni kołyszą się jak wisielcy nad ulicą/
Córka przez telefon opowiada niedzielę na Mazurach z synem i psem/
Wrony lecą wśród fal zielono-fioletowych chmur/
i w świetlistych witrażach karminu/

Wszystkie egzaminy oblane W oczach młodszego brata pogarda/
Szosą jedzie chłopak na rowerze – za kościołem skręca/
czarną ścieżką w świerkowy las/
W plecaku ma dwie książki zeszyt cztery pudełka/
tabletek nasennych i butelkę wody/
Stoi na łące i obserwuje lot siwej czapli/
Wstyd ucieczki i duma każą mu jechać do Warszawy/
Puste wieczorne ulice i zapach wiosennego deszczu/
Gdybyś zrobił to wtedy, nie myślałbyś o tym teraz/

Kwas i dreszcze już na samą myśl/
Bo mam przeczucie, że to koniec/
Przyszłaś na czas/
Nie będzie gwiezdnych wojen/
Dobrze wiem, co myślisz sobie/

Znowu będzie miło, bo tak już masz/
Dokończ, nie skończyłaś, no pij do dna/
Ja się wstrzymam, jakoś mi cierpi krtań/
Nie płacz po niej/

Zawodzę jak miastowa młodzież/
Hej, no może coś powiesz?/
Czekaj, widzę prognozę/
Przewidują zgodę/

Marudzę jak miastowa młodzież/
Nie, to nie ta odpowiedź/
Dlaczego mi zmieniasz pogodę?/
Pozostaje odejść/

Fakt, że całkiem to przyjemne, gdy/
Gniew odbiera mi kulturę/
Od kilku dni tak bardzo denerwujesz/
Przejdzie mi, ale zdążę jeszcze/

Wcisnąć komu trzeba największy kit, że/
Wstałem, nie chcę od niej kompletnie nic/
Patrzę sobie na twój najnowszy klip/

Zawodzę jak miastowa młodzież/
Hej, no może coś powiesz?/
Czekaj, widzę prognozę/
Przewidują zgodę/

Marudzę jak miastowa młodzież/
Nie, to nie ta odpowiedź/
Dlaczego mi zmieniasz pogodę?/
Pozostaje odejść/

Zawodzę jak miastowa młodzież/
Hej, no może coś powiesz?/
Czekaj, widzę prognozę/
Przewidują zgodę/

Marudzę jak miastowa młodzież/
Nie, to nie ta odpowiedź/
Dlaczego mi zmieniasz pogodę?/
Pozostaje odejść/

Obuta jesteś jedynie w noc/
i te obcasy, co idą/
za echem twoich kroków/
melodyjnych,/
harmonijnych/
i rytmicznie wzniesionych/
aż do nieba/
- albo przynajmniej z fotela do sufitu -/
postępujących za długością twych nóg/
uradowanych/
tak wielkim pięknem,/
co wznosi się i opada./

(Od obcasów po twoje włosy/
– tak rudawo podobne to/, co w górze/
i w dole –/
cała twoja nagość/
ledwie rozebrana/
z koronek)/

Szybkie,/
psotne,/
butne./

Zdjąć albo nie zdjąć/
i kroczyć płynąc bez określonego kursu./

Łodzią są buty twoje,/
a nieskończoność/
morzem./

Idź dokąd poszli tamci do ciemnego kresu/
po złote runo nicości twoją ostatnią nagrodę/
idź wyprostowany wśród tych co na kolanach/
wśród odwróconych plecami i obalonych w proch/
ocalałeś nie po to aby żyć/
masz mało czasu trzeba dać świadectwo/
bądź odważny gdy rozum zawodzi bądź odważny/
w ostatecznym rachunku jedynie to się liczy/
a Gniew twój bezsilny niech będzie jak morze/
ilekroć usłyszysz głos poniżonych i bitych/
niech nie opuszcza ciebie twoja siostra Pogarda/
dla szpiclów katów tchórzy - oni wygrają/
pójdą na twój pogrzeb i z ulgą rzucą grudę/
a kornik napisze twój uładzony życiorys/
i nie przebaczaj zaiste nie w twojej mocy/
przebaczać w imieniu tych których zdradzono o świcie/
strzeż się jednak dumy niepotrzebnej/
oglądaj w lustrze swą błazeńską twarz/
powtarzaj: zostałem powołany - czyż nie było lepszych/
strzeż się oschłości serca kochaj źródło zaranne/
ptaka o nieznanym imieniu dąb zimowy/
światło na murze splendor nieba/
one nie potrzebują twego ciepłego oddechu/
są po to aby mówić: nikt cię nie pocieszy/
czuwaj - kiedy światło na górach daje znak - wstań i/
idź/
dopóki krew obraca w piersi twoją ciemną gwiazdę/
powtarzaj stare zaklęcia ludzkości bajki i legendy/
bo tak zdobędziesz dobro którego nie zdobędziesz/
powtarzaj wielkie słowa powtarzaj je z uporem/
jak ci co szli przez pustynię i ginęli w piasku/
a nagrodzą cię za to tym co mają pod ręką/
chłostą śmiechu zabójstwem na śmietniku/
idź bo tylko tak będziesz przyjęty do grona zimnych/
czaszek/
do grona twoich przodków: Gilgamesza Hektora/
Rolanda/
obrońców królestwa bez kresu i miasta popiołów/
Bądź wierny Idź/
');
end;

--wstawianie wierszy za pomocą procedury 
begin
    for i in 1..100
    loop
        pck_wiersz.generuj(round(dbms_random.value(3, 18), 2));
    end loop;
end;

insert into autor (
    imie,
    nazwisko
) values (
    'Gricelda',
    'Luebbers'
);

insert into autor (
    imie,
    nazwisko
) values (
    'Dean',
    'Bollich'
);

insert into autor (
    imie,
    nazwisko
) values (
    'Milo',
    'Manoni'
);

insert into autor (
    imie,
    nazwisko
) values (
    'Laurice',
    'Karl'
);

insert into autor (
    imie,
    nazwisko
) values (
    'August',
    'Rupel'
);

insert into autor (
    imie,
    nazwisko
) values (
    'Salome',
    'Guisti'
);

insert into autor (
    imie,
    nazwisko
) values (
    'Lovie',
    'Ritacco'
);

insert into autor (
    imie,
    nazwisko
) values (
    'Chaya',
    'Greczkowski'
);

insert into autor (
    imie,
    nazwisko
) values (
    'Twila',
    'Coolbeth'
);

insert into autor ( 
    imie,
    nazwisko
) values (
    'Carlotta',
    'Achenbach'
);