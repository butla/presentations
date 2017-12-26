Terminal wystarczy - praca z projektami pythonowymi z poziomu konsoli
=====================================================================

Tutaj znajdziecie dodatkowe informacje związane z prezentacją.

Prezentowane narzędzia
--------------------

Configi do tych narzędzi, które jakiegoś potrzebują znajdują się w folderze `configs`.

* **Bash** Shell. `.bashrc` i `.bash_aliases` idą do `~` (czyli $HOME)
* **Fish** Alternatywny shell. Nie pokazywałem go, ale warto wspomnieć. Zachęcam do
  uruchomienia, żeby zobaczyć o ile wygodniejszy może być shell.
  Pliki idą do `~/.config/fish`. Trzymanie konfiguracji w `~/.config` zamiast wpieprzania
  **wszystkiego** do `~` też wydaje mi się być krokiem w dobrą stroną.
* **Git** Rozproszona kontrola wersji. Zarządzamy konfiguracją przez `git config`.
  Moja konfiguracja:

```
user.email=michalbultrowicz@gmail.com
user.name=Michal Bultrowicz
push.default=simple
core.editor=vim
diff.tool=meld
diff.prompt=false
difftool.prompt=False
core.repositoryformatversion=0
core.filemode=true
core.bare=false
core.logallrefupdates=true
```

* **HTTPie** (komenda `http`) Wołanie HTTP z CLI. Taki cURL, tylko szybszy i wygodniejszy w użyciu.
* **Konsole** Emulator terminala od KDE (wbudowany w Kubuntu, Manjaro i inne). Pliki
  konfiguracyjne mogłyby być lepiej przemyślane, ale ten sam problem ma wiele aplikacji KDE.
  `konsolerc` -> `~/.config`, `COKOLWIEK.profile` -> `~/.local/share/konsole/`.
* **Meld** Wizualny diff. Podpięty pod moją konfigurację Gita.
* **neovim** Edytor tekstu (to trochę mało powiedziane, ale chyba wiecie o co chodzi).
  Fork Vima. Szybciej się rozwija, szybciej działa, łatwiej rozszerzalny pluginami, ma połatanych
  trochę bugów. Używam paru pluginów, żeby je zainstalować trzeba po odpaleniu programu wstukać
  `:PluginInstall`. YouCompleteMe (odpowiedzialny za uzupełnianie kodu) wymaga trochę
  skompilowanego kod, więc dla niego trzeba jeszcze wejść w `~/.vim/bundle/YouCompleteMe`
  i odpalić `install.py` (Python najlepszy!).
  `.vimrc` -> `~/.vimrc`, `init.vim` -> `~/.config/nvim`
* **pgcli** Klient PostgreSQL z podpowiadaniem składni, nazw tabel itp.
* **ptpython** Interaktywny interpreter Pythona z podpowiadaniem składni, edytowaniem
  wielolinijkowych fragmentów kodu i innymi fajnymi feature'ami.
  `config.py` -> `~/.ptpython/config.py`
* **pudb** Konsolowy wizualny debugger Pythona. Jeśli chcecie czegoś bliższego `gdb`, ale jednak
  z jakimś podpowiadaniem, polecam `ipdb`.
  `pudb.cfg` -> `~/.config/pudb.cfg`
* **pylint** Analizator statyczny Pythona. Może być zintegrowana z VIMem (u mnie przy
  pomocy pluginu Ale), można puszczać niezależnie, np. w ramach testów automatycznych,
  żeby jakość kodu nie spadała. Załączam przykładowe configi dla sprawdzania kodu produktowego oraz
  testów. Powinny się znaleźć w głównym folderze projektu.
  Jakby co, mam jeszcze zainstalowanego Pylinta globalnie (`pip3 install --user pylint`, bez sudo),
  żeby Neovim sprawdzał wszystkie edytowane pliki, nawet poza virtualenvem.
  Bystrzy zauważą, że nie miałem tego ustawionego podczas prezentacji :) Od tego czasu
  zainstalowałem sobie taki piękny plugin jak Ale.
* **pytest** Jedyny słuszny framework testowy dla Pythona. Tą nazwę nosi też narzędzie do odpalania
  testów napisanych w pyteście.
* **ranger** Manager plików. Napisany w PYTHONIE! Wszystkie pliki lądują w `~/config/ranger`.
  Te z końcówką `.conf` najlepiej wygenerować samemu (odsyłam do `man ranger` :) )
  i zmienić tam co się chce.
* **Tmux** Multiplekser terminala (moje krojone okna w terminalu). Bez tego ani rusz.
  `.tmux.conf` -> `~/.tmux.conf`
* **Tox** Odpalacz (jest późno, nie chce mi się inaczej tłumaczyć "runner") pythonowych testów
  tworzący virtualenvy, potencjalnie dla kilku różnych wersji Pythona. Na początku chodziło o to,
  żeby testować kod na kilku wersjach Pythona. Teraz troszkę nadużywa się Toxa, żeby mieć po
  prostu szybką automatyzację tworzenia virtualenvów dla projektu, puszczania testów, analizy
  statycznej itp. Taki ładniejszy, prostszy (z tym pewnie można się kłócić) `make`.
  Załączam przykładowy config, który odpala testy oraz Pylinta dla testów i kodu produkcyjnego.
  Czyli ma trzy komendy, które, jeśli się chce, można odpalać osobno. Każda z nich używa tego
  samego virtualenva. Plik powinien się znaleźć w głównym katalogu projektu.

Narzędzia użyte do zrobienia prezentacji
----------------------------------------

* **freemind** Stworzenie mind mapy, która służyła za notatki do tej prezentacji
oraz za jej schemat. Xmind jest ładniejszy, ale nie jest otwarty.
* **toilet** Tworzenie tekstu do "slajdów"

Dlaczego terminal?
------------------

Pracuję często na raz nad kodem, środowiskiem dla niego i automatami, które będą to wszystko
budować i wystawiać na świat. Też utrzymuję więcej niż jeden żywy projekt. Pycharm, którego
uwielbiam, nie dawał mi dość "zintegrowanego" środowiska dla takiej pracy. Musiałem przeskakiwać
między Pycharmem a terminalem. Na marginesie, gdyny nie był to duet IDE i terminal, to pewnie
były by to IDE i masa innych programów (manager plików, "tracer" logów,
mniejszy edytor tekstu, itp.).

Dalej o moim trybie pracy. Nieraz edytowałem pliki w terminalu,
bo albo musiałem to robić na zdalnym serwerze, albo robiłem tylko zmiany w jednym pliku w
jakimś projekcie, więc nie chciało mi się go specjalnie ładować do Pycharma. Trzeba to to odpalić,
wskazać virtualenva, poczekać aż się wszystko zaindeksuje... Wolałem coś szybszego.
Albo właściwie, bardziej "leniwego" (lazy).
Tak, wiem, że Pycharm (i pewnie inne IDE, ale tych już dawno nie używałem) ma emulator terminala
i nawet można się do niego przełączać nie dotykając myszki, ale raczej pełni on tam funkcję
pomocniczą. 

Wracając do tematu - w mojej pracy musiałem nieraz "być w wielu miejscach na raz", robiąc małe
rzeczy (które czasem przeobrażały się w pół dnia roboty) to tu, to tam.
Z command line wszystko było po prostu bardziej spójnym doznaniem. Ponadto, ponieważ
ponieważ większość konsolowych aplikacji jest dostosowana do współpracy z innymi (po prostu
przez uruchamianie komend) mogę bardzo prosto dopasować wszystko do swoich potrzeb
i tworzyć takie "workflowy" (nie mogę tutaj znaleźć dobrego polskiego odpowiednika) jakie
sobie wymarzę. W przypadku Pycharma (IntelliJ) musiałbym pisać pluginy w Javie. Z tego co
widzę, Windgware, np., jest o tyle lepszy, że ma pluginy pisane w Pythonie.
No i chyba nikt nie zaprzeczy, że ekosystem narzędzi, które można odpalić z konsoli jest
większy od jakiegokolwiek, który wyrósł wokół jakiegoś IDE. To w terminalu jest
więszkość mądrości starożytnych :D

I na koniec jeszcze powiem, że po prezentacji padło pytanie, czy nie wyglądam dziwnie w biurze
ze swoim VIMem itd. Cóż, na ogół nie pracuję w biurze :D Ale jak już mi się to zdarzyło,
to z naszej czwórki z mojej firmy w tamtej przestrzeni coworkingowej trzech ludzi pracowało
w terminalu. Fakt, że jeden z nich to admin. Ale ja i drugi ziomek jesteśmy programistami.
Poznałem jeszcze dwóch programistów w tamtym biurze - Pythonowiec używający Emacsa i Javoviec
używający VIMa, który jako silnik do niektórych operacji miał podpiętego Eclipsa.
Także nie jestem jakimś odosobnionym dziwolągiem :)

Dlaczego nie było więcej VIMa?
------------------------------

Skonfigurowanie VIMa aby był pełnowartościowym IDE wymaga trochę wysiłku. Poza tym, taki np.
Pycharm ma bardzo dużo funkcjonalności. Pokazanie jak można je (lub ich zamienniki) uzyskać
w VIMie z łatwością zajęłoby mi większość czasu. Dlatego, w nieokreślonej przyszłości, planuję
zrobić osobną prezentację tylko o tym.

No i jeszcze muszę naprawić kilka bugów, które ma Jedi przy analizowaniu asynchronicznego kodu :)

Poza tym, widziałem już wiele blogów i prezentacji o używaniu VIMa do programowania, a nie widziałem
jeszcze nic, co kompleksowo przedstawiałoby całą resztę czynności z którymi wiąże się praca
programisty, jak już zdecydujemy się być tym VIMowcem/Emacsowcem i siedzieć w terminalu.
Tę niszę starałem się wypełnić.
