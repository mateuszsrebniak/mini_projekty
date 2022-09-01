-- utworzenie tabeli przechowującej wersy
create table  "wersy" (	
		"id" number generated always as identity
   ,	"wers" varchar2(1000 char)
   , 	constraint "pk_wersy" primary key ("id")
)
/
-- utworzenie procedury wstawiającej wersy do tabeli 'wersy', 
-- jako parametr (p_tekst) przyjmuje tekst, w którym wersy oddzielone są od siebie separatorem '/'
create or replace procedure wstaw_wersy(p_tekst varchar2) as
type t_tbl is table of varchar(1000);
t_wersy t_tbl := t_tbl();
begin
  select trim(regexp_substr(p_tekst, '([^/]*)(/|$)', 1, level, null, 1 ))
  bulk collect into t_wersy from dual
  connect by level < regexp_count(p_tekst, '([^/]*)(/|$)');
  for i in t_wersy.first.. t_wersy.last
  loop
  insert into wersy (wers) values (t_wersy(i));
  end loop;
end;
/
/*utworzenie procedury generującej nowy wers na podstawie prawdziwych wersów (w praktyce taki sztuczny wiersz często jest ciekawszy 
niż składające się na niego oryginały, no ale co zrobić, taką mamy poezję. Na szczęście poezji nikt już na poważnie nie czyta, 
no - może poza samymi poetami, którzy czytają się wzajemnie i nieustannie porównują to do Rielkego, to do Szymborksiej, to do Bóg wie kogo. 
Choć może i w tym problem, że nikt nie czyta? Może gdyby czytano poezję tak chętnie, jak czyta się fantasy (tutaj z kolei każdy jest 
nowym Tolkienem! Tylu tych nowych Tolkienów, że to już żadna nowość)... wracając jednak - gdyby czytano poezję równie chętnie jak 
fantasy i gdyby zarobek był podobny, może wówczas najpłodniejsze umysły literackie nie szłyby w prozę, a własnie w krótsze formy? 
Nikt mi przecież nie powie, że Hanna Krall ze swoją skondesowaną do maksimum prozą nie byłaby zdolna skondensować jej do poezji! 
Zresztą powiedział Kieślowski (swoją drogą przyjaciel Hanny Krall), że to, na wyrażnie czego za pomocą filmu on potrzebował kilku milionów 
franków, Szymborska wyraziła zgrabniej za pomocą kartki, pióra i kilku linijek. No ale ostatecznie, kto dziś pamięta wiersz Szymborskiej? 
(niestety!)...*/ 
create or replace procedure generuj_wiersz(p_licz_wersow number) as
v_wers varchar2(1000);
begin
    for i in 1..p_licz_wersow
    loop
        select wers into v_wers from wersy 
        order by dbms_random.value() fetch first 1 row only;
        dbms_output.put_line(v_wers);
    end loop;
end;
/
--wstawianie wersów za pomocą procedury wstaw_wersy()
BEGIN
	wstaw_wersy('Kocham Chariel więc kiedy powiedziała/
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
');
end;