---
theme: default
layout: cover
exportFilename: "dev_workflow_with_local_tests_using_docker_compose.pdf"
---

# Lokalne testy z docker-compose a praca programisty

## Michał "Butla" Bultrowicz

Primary Software Wizard

<br/>

https://witchsoft.com

https://bultrowicz.com

<!--
Cześć, nazywam się Michał Bultrowicz.
Opowiem dziś o tym jak lokalne testy z docker-compose wpływają na pracę programisty.

(other version)

I'm Michał, I'm the Primary Software Wizard at WitchSoft, my company.

The title is not more made up and pompous that something like "Chief Executive Officer", I think.

In the recent past I did hollistic backends (with tests, reliability, metrics, alerts, infrastructure, etc.),
now I'm trying to start a business providing software directly to end-users.

I have twitter and everything, it's on my website. I hope to put out more educational "content" in the future.
-->

---
layout: center
---

Slajdy + notatki: [https://github.com/butla/presentations](https://github.com/butla/presentations/tree/master/2023-03_developer_workflow_with_local_tests_using_docker-compose)

---

# Co to kontener?

- proces lub grupa procesów oddzielony od systemu hosta
- ma system plików niezależny od hosta
- trochę jak VM, ale nie do końca

<!--
Mam nadzieję, że wiecie już czym są kontenery, Docker i Docker-compose,
ale na wszelki wypadek zrobię minimalne wprowadzenie.

A short but more technical answer
- A process or a group of processes running in a process namespace, with a separate user-space.
- It runs on the host's kernel, in a process namespace separated from the host's processes.
- It contains:
  - application code
  - system components (e.g. libraries) required by the app code
  - doesn't contain a Linux kernel.
- Windows and MacOS need a Linux VM to use containers.
-->

---

# Docker i Docker Compose

- Docker: implementacja kontenerów.
- Jest więcej implementacji, np. [Podman](https://podman.io/).
- Docker Compose: pozwala opisać i zarządzać grupą powiązanych kontenerów.

---

# Przykładowa aplikacja - repozytorium notatek

<br/>

[Python REST API + PostgreSQL](https://github.com/butla/experiments/tree/master/testing__quality_assurance/sample_backend_app)

<br/>

Endpointy API:
- `POST /notes/` - stwórz notkę
- `GET /notes/{id}/` - pobierz notkę po ID
- `GET /notes/` - pobierz wszystkie notki

<!--
Pełna przykładowa apka pod linkiem.
Znajdziecie tam trochę więcej szczegółów niż zawarłem na prezentacji.

Doesn't even have update - that bare-bones.
-->

---
layout: two-cols
---

<template v-slot:default>

# Uruchamianie aplikacji

```yaml
# docker-compose.yml
---
version: '3'
services:
  api:
    build:
      context: .
    image: sample_backend
    ports:
      - "8080:8080"
    links:
      - database
    environment:
      - POSTGRES_HOST=database
  database:
    image: postgres:15.2
    ports:
      - "5432:5432"
    environment:
      - POSTGRES_PASSWORD=postgres
    volumes:
      - db-data:/var/lib/postgresql/data
volumes:
  db-data:
```

</template>

<template v-slot:right>

<br/><br/>

```dockerfile
# Dockerfile
FROM python:3.10-alpine

EXPOSE 8080

WORKDIR /app

COPY requirements.txt /app/
RUN pip install -r requirements.txt

COPY sample_backend /app/sample_backend

CMD ["uvicorn", "--host", "0.0.0.0",
     "--port", "8080",
     "sample_backend.main:app"]
```

</template>

<!--
Nie musimy się zbytnio zagłębiać w kod plików.
Ważne, że widzimy, że nie ma tego dużo.

Apka powinna mieć config ze zmiennych środowiskowych.
Tutaj przyjmuje adres postgresa.
Mogłaby też przyjmować inne jego parametry, ale config ma defaulty, które będą działać.
POSTGRES_HOST w aplikacji będzie miał domyślną wartość "localhost".

Postgres będzie miał persistency - trzymanie danych między restartami.
-->

---

# Uruchamianie aplikacji

```makefile
# Makefile
.EXPORT_ALL_VARIABLES:
SHELL:=/bin/bash

setup_development:
	poetry install

run: _start_compose _db_migration

_start_compose:
	docker-compose up -d

_db_migration:
	poetry run alembic upgrade head
```

- modyfikacja migracji, aby czekały na pojawienie się bazy

```bash
$ git clone <repo>
$ cd <repo>
$ make setup_development run
```

<!--
Jeśli nie lubicie Make'a, to możecie mieć jakiś inny centralny skrypt z komendami potrzebnymi w developmencie.
Make jest spoko, bo ma shell completions i jest wszędzie.

Targety z podkreśleniami nie będą podpowiadane przez completions. Nie trzeba eksponować wszystkich komend.

Polecam nagłówek mieć.

Używam narzędzi pythonowych, ale w waszej technologii może to wyglądać inaczej.
Musi być coś do odpalenia migracji.

Odpalenie migracji może nastąpić zanim jeszcze baza będzie gotowa, stąd potrzeba czekania na nią.
W pythonie używam tenacity. Ogólnie prosta pętla jakaś pingająca bazę.

Wasze systemy nie muszą mieć bazy SQL.
Zamiast migracji może być dowolne "zapewnienie początkowych danych" dla systemu.

Warto zaznaczyć, że jeśli wasza apka potrzebuje jakichkolwiek danych do działania, to powinny być one częścią migracji.
(a nie, np. Django fixtures).

Po tym one-linerze będziemy mieli chodzącą aplikację nawet na "czystym" środowisku.
-->

---

# Co już mamy?

- Żywa aplikacja, lokalnie.
- Możliwość eksperymentowania.
- Bardzo prosta instrukcja uruchamiania.

<!--
Możliwość eksperymentowania - wielki plus.
Można zmieniać kod, patrzeć co się dzieje.
Skraca to development, zmniejsza ryzyko bugów.

Często problemem dla nowych członków zespołu jest w ogóle uruchomienie aplikacji.
Jeśli będziemy się trzymać tej formuły będzie to proste.
-->

---
layout: cover
---

# Pora na testy! 🦾

---

# Testy zintegrowane (integrated)

- używanie wewnętrznych interfejsów kodu (jak testy jednostkowe)
- wykorzystanie zewnętrznych systemów (np. PostgreSQL z kontenera)
- nie potrzeba mocków

```python
def test_create_a_note():
    # arrange
    note_contents = f"I'm a note, wee! {uuid.uuid4()}"  # some randomness
    notes_repo = NotesRepository(...)  # object that connects to the DB

    # act
    id = notes_repo.create(note_contents)  # calls out to Postgres at localhost:5432

    # assert
    with db_session() as session:
        query = select(Note).where(Note.id == id)
        saved_object = session.execute(query).scalar()
    assert saved_object.contents == note_contents
```

<!--
Kod w samplu trochę inny.

Po prostu odpalamy objekt, który normalnie wołał by bazę i to robi.

Tak wytestowany obiekt Repository można zastępować przez dependency injection w testach jednostkowych.
-->

---

# Testy zewnętrzne (external; aka. functional/e2e)

- używanie tylko zewnętrznych interfejsów (np. HTTP)
- konfiguracja maksymalnie zbliżona do produkcyjnej
- trudniejsze w debugu, trzeba zaglądać do logów kontenerów

```python
import uuid, httpx

def test_store_and_retrieve_note(app_url):  # a more elaborate scenario
    note_contents = f"a note {uuid.uuid4()}"  # some randomness

    create_result = httpx.post(f"{app_url}/notes/", json={"contents": note_contents})  # calling the app in Docker
    assert create_result.json()["contents"] == note_contents
    note_id = create_result.json()["id"]

    get_by_id_result = httpx.get(f"{app_url}/notes/{note_id}/")
    assert get_by_id_result.json()["contents"] == note_contents

    get_all_result = httpx.get(f"{app_url}/notes/")
    # finding the new note among all notes
    assert next(note for note in get_all_result.json() if note["id"] == note_id)
```

<!--
Name is something I use. I feel it's more precise than saying functional, or component, or end-to-end tests.

Pełny scenariusz akceptacyjny:
- tworzymy notkę
- pobieramy notkę po ID
- zayważamy, że notka jest w grupie wszystkich notek
-->

---

# Brakujący kod z poprzedniego slajdu

```python
import uuid, httpx, pytest, tenacity

# Session scope ensures we wait only once per test suite run.
@pytest.fixture(scope="session")
def app_url():
    app_address = "http://localhost:8080"
    _wait_for_http_url(app_address)
    return app_address

# Call the app until it returns correctly or times out.
@tenacity.retry(stop=tenacity.stop_after_delay(10), wait=tenacity.wait_fixed(0.2), reraise=True)
def _wait_for_http_url(url: str):
    result = httpx.get(url)
    if result.status_code != 200:
        raise ValueError("App returned the wrong status code")

def test_store_and_retrieve_note(app_url):
    ...
```

<!--
Możemy robić więcej testów.

Czekanie przyda się jeśli apka wstaje wolno (lepiej tego unikać),
lub gdy będziemy przeładowywać kod i puszczać testy przy zmianach plików.

Podobne czekanie można wstrzyknąć w migracje (wcześniej mówiłem, że trzeba to do nich dodać).
-->

---

# Uruchamianie testów

```makefile
SOURCES:=sample_backend tests

check: static_checks test

# SUBCOMMANDS =====
test:
	@echo === Running tests... ===
	@poetry run pytest tests

static_checks: _check_isort _check_format _check_linter _check_types

_check_isort:
	@echo === Checking import sorting... ===
	@poetry run isort -c $(SOURCES)

_check_format:
	@echo === Checking code formatting... ===
	@poetry run black --check $(SOURCES)

...
```

<br/>

```bash
$ make check
```

---

# Testy zintegrowane i zewnętrzne - co dostajemy?
- dowód, że aplikacja się uruchamia
- większa pewność, że działa
- mniej pracy niż ustawianie mocków
- swoboda w korzystaniu z pełnej mocy narzędzi
- wolniejsze niż jednostkowe, nadal szybkie
- ⚠️ brak pełnej izolacji między testami

<!--
Większa pewność: jeśli używasz jakiś testowych zastępników od frameworka, albo np. lokalnej bazy SQLite,
to nie wszystko będzie tak samo.
Zawsze znajdą się jakieś corner casey.
I coś kiedyś zaskoczy po deploymencie (pół biedy, jeśli będzie to DEV).

Mocki: mniej pracy - szybsza iteracja.

odblokowanie mocy - np testowanie indeksów, triggerów, itp.
Jeśli możemy coś testować, to z większą pewnością możemy wpleść to w system.
Większe poleganie na zewnętrznych systemach, mniej kodu przez to.

Not all frameworks have tight DB integration and fakes. With this you can test everything.
-->

---

# Brak izolacji - odrobina chaosu

- reset danych między każdym testem może być niepraktyczny
  - za wolny dla SQL
  - dla Redisa znośny (ale uniemożliwia równoległe testy)
- niektóre testy (np. daj wszystkie notki) muszą brać na to poprawkę
  - kolekcje "wszystkich elementów" będą zmienne
  - dobrze tworzyć odizolowane grupy danych
- losowe problemy będą irytować

<!--
Tests for things like retrieving the entire collection of objects need to ensure that the new items need to
be there, not match the whole retrieved collection.
This technique also helps with making tests more independent of each other, so they can be run out-of-order
(that sometimes creeps in into test-suites) and parallelised

Odizolowane grupy danych - nowa organizacja.
You have some wiggle room to configure them, though. You can be creating a new org for every test.
You can create one, and add all the data to it. Or you can do anything in between.

Maximize chaos, but allow yourself to have the precision when you need to (e.g. be able to test a clean start,
but have the default a bit more messy and realistic).

Może dodatkowy slajd o tym, jak sobie z tym radzić:
- Czekanie na rzeczy asynchroniczne.
- założenie, że nowe elementy kolekcji mogą się pojawiać w dowolnym momencie
-->

---

# Orobina chaosu - większy realizm

- wersja produkcyjna nie czyści co chwilę bazy
- wyłapywanie błędów przed produkcją:
  - baza rośnie
  - "flaky" testy wskazują wyścigi
- naprawianie losowych problemów zwiększy jakość
- ewentualnie można czyścić lokalną bazę: `docker-compose down -v`

<!--
Prawdziwa baza i nawarstwianie danych dają trochę chaosu,
który czasem zrobi dziwny problem - tym samym symulując prawdziwe środowisko

Realism: real app won't reset its database after every operationevery call - your functional tests shouldn't too.
Integration ones as well.

Many flaky tests showed me real race conditions.

A volume in docker-compose needed for persistence;
if you get weird issues and can't figure them out, try docker-compose down -v to clear out everything.
But remember - maybe that issue can happen in production? Although local instances have a lot of garbage data.
-->

---

# Organizacja testów

```
project_root/
├── ...
└── tests
    ├── external
    │   └── ...
    ├── integrated
    │   └── ...
    └── unit
        └── ...
```

<br/>

- jawny podział
- ilość wysokopoziomowych testów trzeba kontrolować
- łatwość puszczania szybszych podgrup
- więcej informacji o typach testów [tutaj](https://bultrowicz.com/separating_kinds_of_tests/)


<!--
It makes the team mindful about the category that each test falls under.

We need to be mindful of the categories, because the higher levels of tests are more time-consuming.
When you need to make the test suite faster, the starting point can be looking at the higher level tests and checking
whether they can't be replaced with lower level tests.

A test should be the lowest level that fulfills the job.
If you can check what you want about the code without poking a database, then do it
(meaning write a unit test instead of an integrated test).
-->

---

# Działa dla złożonych aplikacji

- sprawdzone w bojach (trzy różne firmy)
- integracja innych systemów (Kafka, Redis, Rabbit, itp.)
- AWS lokalnie - [Localstack](https://localstack.cloud/)
- udawanie innych REST API - [Mountebank](http://www.mbtest.org/)

<!--
Zamiast Postgresa mógłby być jakiś inny system, lub kilka. Kafka, Redis, Elastic, coś innego.
Metodami, które pokażę można je wszystkie ogarnąć.

Only for AWS.
Azure has some local emulation https://learn.microsoft.com/en-us/answers/questions/579764/local-development-with-azure-services-specifically

GCP has [some emulators](https://cloud.google.com/sdk/gcloud/reference/beta/emulators)
and it looks like the code using the [functions framework](https://cloud.google.com/functions/docs/functions-framework)
can run locally.
-->

---
layout: two-cols
---

<template v-slot:default>

# Przeładowywanie kodu w kontenerze

```yaml
# docker-compose.override.yml
---
version: '3'

services:

  api:
    volumes:
      # local folder mounted into the container
      - ./sample_backend/:/app/sample_backend/
```

```makefile
# Makefile
run_reloading: run
	fd --exclude .git --no-ignore '\.py$$' sample_backend \
		| entr -c make _start_compose

test_reloading:
	fd --exclude .git --no-ignore '\.py$$' \
		| entr -c make test
```

</template>

<template v-slot:right>

<br/><br/>

- nie trzeba przebudowywać Dockera
- aplikacja w Dockerze odświeża się przy zmianie pliku
- [entr](https://bultrowicz.com/universal_reload_with_entr/)
- [fd](https://github.com/sharkdp/fd)

</template>

<!--
Zamiast entr dla przeładowywania aplikacji można użyć czegoś innego.
Wiele frameworków ma opcję reload.

Entr jest uniwersalny.
-->


---
layout: cover
---

# Continuos Integration / Delivery

---

# Organizacja CI

- CI usuwa `docker-compose.override.yml` - wykluczenie źle zbudowanego obrazu
- CI używa tego samego Makefile'a
- komendy składowe `make check` rozdzielone między równoległe zadania
- po testach oznacz zbudowany obraz Dockera, wypchnij do repo, używaj w deploymentach

---
layout: two-cols
---

<template v-slot:default>

# CI self-hosted runners: wolne porty

```yaml
# docker-compose.yml
---
version: '3'
services:
  api:
    ports:
      - "${API_PORT:-8080}:8080"
    ...
  database:
    ports:
      - "${POSTGRES_PORT:-5432}:5432"
    ...
```
</template>

<template v-slot:right>

<br/><br/>

```python
# get_free_port.py
# https://unix.stackexchange.com/a/132524/128610

#!/usr/bin/env python3
import socket

s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.bind(('', 0))
addr = s.getsockname()
print(addr[1])
s.close()
```

<br/>

```bash
$ export \
  API_PORT=$(./get_free_port.py) \
  POSTGRES_PORT=$(./get_free_port.py)
$ make run check
```

</template>

<!--
self-hosted runners - jeśli nie ma izolacji sieci między uruchomieniami testów, to będą konflikty na portach
Można generować losowe porty
-->

---

# Obiecany, ale pominięty materiał

- debug kodu w kontenerze
  - [CLI](https://github.com/butla/bultrowicz.com/blob/master/unfinished_articles/debugging_python_in_docker_with_cli.rst)
  - IDE, e.g. [Intellij/Pycharm](https://www.jetbrains.com/help/pycharm/using-docker-compose-as-a-remote-interpreter.html#run)
- zmiany kodu produkcyjnego dla ułatwienia testowania
  - każdy sleep w apce konfigurowalny, małe wartości dla testów
  - to w porządku dodawać funkcjonalność dla ułatwienia testów
  - ...inne...

<!--
- configurable wait times
- launching coverage
- Test-enabling code can be a part of the product. Testability is a feature.
- if you can't implement some needed tests without changing the code, then change the code.
  Add a special endpoint, or whatever.
  You might want to hide them behind a feature flag. Or maybe not - testing in production has its place.
-->

---
layout: center
---

# Fin

# 🫠
