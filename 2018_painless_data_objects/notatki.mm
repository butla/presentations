<map version="1.0.1">
<!-- To view this file, download free mind mapping software FreeMind from http://freemind.sourceforge.net -->
<node CREATED="1515929822223" ID="ID_1300652641" MODIFIED="1515929848813" TEXT="Prezentacja">
<node CREATED="1515930013781" ID="ID_188720530" MODIFIED="1515930020831" POSITION="right" TEXT="Normalne tuple i dicty">
<node CREATED="1515930341578" ID="ID_1885654742" MODIFIED="1515930349951" TEXT="Tylko dane bez powi&#x105;zanych operacji">
<node CREATED="1515930353459" ID="ID_1120419147" MODIFIED="1515930365567" TEXT="Chocia&#x17c; mo&#x17c;na mie&#x107; funkcje zwracaj&#x105;ce je"/>
</node>
<node CREATED="1515930716437" ID="ID_272428564" MODIFIED="1515930720814" TEXT="Tuple to jak lista"/>
<node CREATED="1515930721248" ID="ID_34788223" MODIFIED="1515930742205" TEXT="Dict dodaje przynajmniej jak&#x105;&#x15b; semantyk&#x119; przez posiadanie kluczy"/>
</node>
<node CREATED="1515930021263" ID="ID_1175457884" MODIFIED="1515930025344" POSITION="right" TEXT="Normalne klasy">
<node CREATED="1515930288595" ID="ID_1875823501" MODIFIED="1515930299572" TEXT="Trzeba si&#x119; napisa&#x107; boilerplate&apos;a">
<node CREATED="1515930301829" ID="ID_1655829737" MODIFIED="1515930316077" TEXT="Przepisywanie argument&#xf3;w konstruktora na pole"/>
<node CREATED="1515930317130" ID="ID_1092730670" MODIFIED="1515930322816" TEXT="Metody do por&#xf3;wnywania"/>
<node CREATED="1515930323291" ID="ID_678429592" MODIFIED="1515930326476" TEXT="Repr"/>
</node>
<node CREATED="1515930330046" ID="ID_921793930" MODIFIED="1515930337130" TEXT="Mo&#x17c;na mie&#x107; operacje na danych"/>
</node>
<node CREATED="1515929858384" ID="ID_982678248" MODIFIED="1515929989793" POSITION="right" TEXT="Named Tuple">
<node CREATED="1515930228084" ID="ID_319079195" MODIFIED="1515930243165" TEXT="Najpierw zwyk&#x142;y, potem z typingu jako ulepszenie">
<node CREATED="1515930245952" ID="ID_1691950209" MODIFIED="1515930278426" TEXT="robienie docstring&#xf3;w"/>
<node CREATED="1515930254228" ID="ID_647933487" MODIFIED="1515930266939" TEXT="&#x142;atwe oznaczanie typ&#xf3;w p&#xf3;l"/>
</node>
<node CREATED="1515930382907" ID="ID_266984159" MODIFIED="1515930391873" TEXT="Zajebisty dla danych"/>
<node CREATED="1515930392349" ID="ID_779018580" MODIFIED="1515930403167" TEXT="Wbudowany w standardow&#x105; bibliotek&#x119;"/>
<node CREATED="1515930403999" ID="ID_1730918175" MODIFIED="1515930409336" TEXT="Nie mo&#x17c;na modyfikowa&#x107;"/>
<node CREATED="1515930758437" ID="ID_1696179095" MODIFIED="1515930789780" TEXT="Jak pracujemy interaktywnie, to dicty mog&#x105; by&#x107; podpowiedziane. Statycznie ju&#x17c; nie. A dla namedtuple tak."/>
</node>
<node CREATED="1515929997547" ID="ID_1552059327" MODIFIED="1515930005565" POSITION="right" TEXT="attrs">
<node CREATED="1515930414431" ID="ID_695939146" MODIFIED="1515930421685" TEXT="Spoza standard liba"/>
<node CREATED="1515930423177" ID="ID_209885227" MODIFIED="1515930439339" TEXT="Du&#x17c;o mniej boilerplate&apos;u ni&#x17c; w normalnych klasach"/>
<node CREATED="1515930440200" ID="ID_1358804332" MODIFIED="1515930453565" TEXT="Nie jest tak pi&#x119;knie prosty jak typing.NamedTuple"/>
<node CREATED="1515930456488" ID="ID_1979417642" MODIFIED="1515930468177" TEXT="Mo&#x17c;na mie&#x107; metody"/>
<node CREATED="1515930468907" ID="ID_1024951181" MODIFIED="1515930477676" TEXT="Mo&#x17c;e by&#x107; mutowalny lub nie"/>
</node>
<node CREATED="1515929876703" ID="ID_229392575" MODIFIED="1515929880358" POSITION="left" TEXT="Kolejno&#x15b;&#x107;">
<node CREATED="1515930496966" ID="ID_1499977390" MODIFIED="1515930510947" TEXT="tuple i dicty jako standardowe podej&#x15b;cia"/>
<node CREATED="1515930511610" ID="ID_687466390" MODIFIED="1515930516650" TEXT="Problemy przy tym">
<node CREATED="1515930519441" ID="ID_1385536328" MODIFIED="1515930526988" TEXT="Zapomnia&#x142;em kt&#xf3;re pole tupla to co"/>
<node CREATED="1515930528776" ID="ID_898453335" MODIFIED="1515930538912" TEXT="Zapomnia&#x142;em kluczy w s&#x142;owniku">
<node CREATED="1515930541905" ID="ID_892314110" MODIFIED="1515930556526" TEXT="Mo&#x17c;e trzeba trzyma&#x107; gdzie&#x15b; zestaw kluczy jako jakie&#x15b; sta&#x142;e">
<node CREATED="1515930564477" ID="ID_1565147274" MODIFIED="1515930580975" TEXT="Nie jest to wtedy &quot;self-contained&quot; (jak to po polsku?)"/>
</node>
</node>
</node>
<node CREATED="1515930595956" ID="ID_1254981476" MODIFIED="1515930601318" TEXT="NamedTuple zwyk&#x142;y"/>
<node CREATED="1515930601825" ID="ID_1052452871" MODIFIED="1515930607741" TEXT="Typing.NamedTuple"/>
<node CREATED="1515930608522" ID="ID_369804690" MODIFIED="1515930623499" TEXT="Attrs, kiedy chcemy mie&#x107; metody"/>
</node>
<node CREATED="1515930036316" ID="ID_1660232220" MODIFIED="1515930038835" POSITION="left" TEXT="Wyzwania">
<node CREATED="1515930043148" ID="ID_327314271" MODIFIED="1515930061131" TEXT="Trzeba zwr&#xf3;ci&#x107; kilka rzeczy z funkcji">
<node CREATED="1515930064112" ID="ID_1509310575" MODIFIED="1515930074826" TEXT="Mo&#x17c;e to by&#x107; te&#x17c; struktura"/>
<node CREATED="1515930963869" ID="ID_121424913" MODIFIED="1515930972238" TEXT="Tuple i udokumentowanie funkcji?"/>
</node>
<node CREATED="1515930161449" ID="ID_401139711" MODIFIED="1515930670938" TEXT="Trzeba mie&#x107; struktur&#x119; opisuj&#x105;c&#x105; kilka rzeczy">
<node CREATED="1515930187724" ID="ID_571060739" MODIFIED="1515930204819" TEXT="dict">
<node CREATED="1515930207567" ID="ID_4298480" MODIFIED="1515930224430" TEXT="mo&#x17c;e by&#x107; z&#x142;o&#x17c;ony"/>
</node>
<node CREATED="1515930694731" ID="ID_1893733189" MODIFIED="1515930694731" TEXT=""/>
</node>
<node CREATED="1515930089146" ID="ID_1032682845" MODIFIED="1515930107656" TEXT="Operowanie na obiektach zmieniaj&#x105;cych stan">
<node CREATED="1515930893569" ID="ID_48696319" MODIFIED="1515930913507" TEXT="Np klasa postaci na planszy w grze zmienia pozycj&#x119;"/>
</node>
<node CREATED="1515930112409" ID="ID_1847019053" MODIFIED="1515930142180" TEXT="Por&#xf3;wnywanie obiekt&#xf3;w">
<node CREATED="1515930919880" ID="ID_320979386" MODIFIED="1515930941242" TEXT="Dwie konfiguracje, stara i nowa"/>
</node>
</node>
<node CREATED="1516954012296" ID="ID_1650268736" MODIFIED="1516954017098" POSITION="left" TEXT="Plan prezentacji">
<node CREATED="1516954022145" ID="ID_304856167" MODIFIED="1516954044126" TEXT="Funkcje s&#x105; fajne, bo pozwalaj&#x105; &#x142;adnie podzieli&#x107; kod"/>
<node CREATED="1516954045004" ID="ID_746019038" MODIFIED="1516954065631" TEXT="Powiedzmy, &#x17c;e z jakiej&#x15b; funkcji musimy co&#x15b; zwr&#xf3;ci&#x107; z&#x142;o&#x17c;onego">
<node CREATED="1516954067868" ID="ID_743387862" MODIFIED="1516954076170" TEXT="Np dane do OAutha"/>
</node>
<node CREATED="1516954078980" ID="ID_1841723644" MODIFIED="1516954088010" TEXT="Najpierw jako tuple">
<node CREATED="1516954878591" ID="ID_335315546" MODIFIED="1516954885394" TEXT="po prostu zwracamy par&#x119; rzeczy"/>
</node>
<node CREATED="1516954092359" ID="ID_986363338" MODIFIED="1516954117613" TEXT="Jednak struktura b&#x119;dzie u&#x17c;ywana w paru miejscach, wszystkie musz&#x105; pami&#x119;ta&#x107; o kluczach/pozycjach, s&#x142;abo">
<node CREATED="1516954120967" ID="ID_758822952" MODIFIED="1516954158232" TEXT="Pokazuj minimalne fragmenty kodu przy ka&#x17c;dej stacji"/>
</node>
<node CREATED="1516954088610" ID="ID_1322774266" MODIFIED="1516960312413" TEXT="Potem jako dict">
<node CREATED="1516960327359" ID="ID_1382199614" MODIFIED="1516960348994" TEXT="Lepiej ni&#x17c; tuple, bo mamy opisowy klucz, nie liczb&#x119;"/>
</node>
<node CREATED="1516954245068" ID="ID_1295265767" MODIFIED="1516954268275" TEXT="Namedtuple zwyk&#x142;y - prawie jak dict, ale &#x142;adniej wygl&#x105;da">
<node CREATED="1516954272593" ID="ID_1463227125" MODIFIED="1516954278943" TEXT="Podpowiadanie w pycharmie jest?"/>
<node CREATED="1516954798808" ID="ID_848034588" MODIFIED="1516954819583" TEXT="Definicja wygl&#x105;da troszk&#x119; dziwnie, niestandardowo"/>
</node>
<node CREATED="1516954825221" ID="ID_1188770052" MODIFIED="1516954833602" TEXT="Typing named tuple - lepiej"/>
<node CREATED="1516954836876" ID="ID_1392013702" MODIFIED="1516954840485" TEXT="Attrs?"/>
<node CREATED="1516954841091" ID="ID_599407477" MODIFIED="1516954847927" TEXT="Dataclass w przysz&#x142;o&#x15b;ci"/>
</node>
</node>
</map>
