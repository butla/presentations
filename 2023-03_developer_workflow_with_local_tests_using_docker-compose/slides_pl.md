---
theme: default
layout: cover
exportFilename: "dev_workflow_with_local_tests_using_docker_compose.pdf"
---

# Developer workflow with local tests using Docker Compose

## Michał "Butla" Bultrowicz

Primary Software Wizard

<br/>

https://witchsoft.com

https://bultrowicz.com

<!--
I'm Michał, I'm the Primary Software Wizard at WitchSoft, my company.

The title is not more made up and pompous that something like "Chief Executive Officer", I think.

In the recent past I did hollistic backends (with tests, reliability, metrics, alerts, infrastructure, etc.),
now I'm trying to start a business providing software directly to end-users.

I have twitter and everything, it's on my website. I hope to put out more educational "content" in the future.
-->

---

# Co to kontener?

- proces lub grupa procesów oddzielony od systemu hosta
- ma system plików niezależny od hosta
- trochę jak VM, ale nie do końca

<!--
Mam nadzieję, że wiecie już czym są kontenery, ale na wszelki wypadek dam minimalne wprowadzenie.

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

- Docker: implementacja kontenerów.an implementation of containers.
- Jest więcej implementacji, np. [Podman](https://podman.io/).
- Docker Compose: pozwala opisać i zarządzać grupą powiązanych kontenerów.

<!--
Again, I hope you already know this, but this is a bare-bones explanation.
-->

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
Apka moja pod linkiem. Znajdziecie tam trochę więcej szczegółów niż zawarłem na prezentacji.

Zamiast Postgresa mógłby być jakiś inny system, lub kilka. Kafka, Redis, Elastic, coś innego.
Metodami, które pokażę można je wszystkie ogarnąć.

Doesn't even have update - that bare-bones.

TODO: mermaid diagram with images?
https://github.com/mermaid-js/mermaid/issues/548

There might be two slides before this.
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
- `git clone <repo> && cd <repo> && make setup_development run`

<!--
Jeśli nie lubicie Make'a, to możecie mieć jakiś inny centralny skrypt z komendami potrzebnymi w developmencie.
Make jest spoko, bo ma shell completions.

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

```python
def test_create_a_note():
    # arrange
    note_contents = "I'm a note, wee!"
    notes_repo = NotesRepository(...)

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
-->

---

# Testy zewnętrzne (external)

- używanie tylko zewnętrznych interfejsów aplikacji (np. HTTP)
- konfiguracja maksymalnie zbliżona do produkcyjnej
- kompletne scenariusze używania aplikacji
- trudniejsze w debugu, trzeba zaglądać do logów kontenerów

TODO - sample code

<!--
Name is something I use. I feel it's more precise than saying functional, or component, or end-to-end tests.

Functional tests should wait for the app as well - tenacity.
-->

---

# Testy zintegrowane i zewnętrzne - co dostajemy?
- dowód, że aplikacja rzeczywiście uruchamia się i działa
- mniej pracy niż ustawianie mocków
- odblokowanie pełnej mocy narzędzi, przez umożliwienie testowania

<!--
Większa pewność: jeśli używasz jakiś testowych zastępników od frameworka, albo np. lokalnej bazy SQLite,
to nie wszystko będzie tak samo.
Zawsze znajdą się jakieś corner casey.
I coś kiedyś zaskoczy po deploymencie (pół biedy, jeśli będzie to DEV).

Mocki: mniej pracy - szybsza iteracja.

odblokowanie mocy - np testowanie indeksów, triggerów, itp.
Triggery są trochę kontrowersyjne.
Ale jeśli możemy coś testować, to z większą pewnością możemy wpleść to w system.
Albo w ogóle dopiero wtedy się na to odważymy.

Not all frameworks have tight DB integration and fakes. With this you can test everything.
-->

---

# Odrobina chaosu - większy realizm

- reset między każdym testem niepraktyczny ze względu na czas
- stan systemu nie jest resetowany
  - niektóre testy (np. daj wszystkie notki) muszą brać na to poprawkę
- natkniemy się na więcej błędów lokalnie - nie dojdą na produkcję


<!--
real app won't reset its database every call - your functional tests shouldn't too.
Integration ones as well.
You have some wiggle room to configure them, though. You can be creating a new org for every test.
You can create one, and add all the data to it. Or you can do anything in between.
Maximize chaos, but allow yourself to have the precision when you need to (e.g. be able to test a clean start,
but have the default a bit more messy and realistic).

Prawdziwa baza i nawarstwianie danych dają trochę chaosu, który czasem zrobi dziwny problem - tym samym symulując prawdziwy deployment

- Many flaky tests showed me real race conditions.
- tests for things like retrieving the entire collection of objects need to ensure that the new items need to
  be there, not match the whole retrieved collection.
  This technique also helps with making tests more independent of each other, so they can be run out-of-order
  (that sometimes creeps in into test-suites) and parallelised
- a volume in docker-compose needed for persistence;
  if you get weird issues and can't figure them out, try docker-compose down -v to clear out everything.
  But remember - maybe that issue can happen in production? Although local instances have a lot of garbage data.

TODO ogarnij te notki
-->

---

# Test organization

Three separate folders.
Link the article. Mention the whys of the separation.

TODO

---

# Przeładowywanie kodu w kontenerze

- using "Docker mounts" to enable fast application reloading while editing code
  - pokaż odpalanie z entr jak się ma mounta (oczywiście można używać jakiś wewnętrznych frameworkowych rozwiązań,
    ale czasem są źle napisane, mielą procem. No i wymagają zmieniania konfiguracji apki, przez co odchodzi
    od wartości produkcyjnych)
- Nie dawałbym live reload w wersji produkcyjnej, tylko.
- (reloading) Tutaj też pokaż overloading domyślnego polecenia w compose dla potrzeb developmentu.

TODO

---

# Testy lokalne a CI

- CI powinien "reużywać" Makefile
- TODO pokaż `make check`
- może odpalać podkomendy równolegle w różnych stepach i ładnie je przedstawiać w CI
- docker-override z mountem może być usuwany w CI
- dobrze jak jest docker-in-docker w runnerach, żeby nie było konfliktów na portach;
  w innym przypadku trzeba pokombinować, brać jakieś wolne i wstrzykiwać je w docker-compose i w inne miejsca
  Można np zrobić override z portami.
- So build image first, then run functional tests with it. Might be done with override, pulling the image first.

---

# Debug kodu w kontenerze

- debugging code running in containers
  - podpięcie się ręczne
  - podpięcie się z Pycharmem

---

# Zmiany kodu produkcyjnego dla ułatwienia testowania

- configurable wait times
- launching coverage
- Test-enabling code can be a part of the product. Testability is a feature.
- if you can't implement some needed tests without changing the code, then change the code.
  Add a special endpoint, or whatever.
  You might want to hide them behind a feature flag. Or maybe not - testing in production has its place.

TODO maybe cut

---
layout: center
---

Fin

<!--
Some additional tools:

## Localstack
Only for AWS.
Azure has some local emulation https://learn.microsoft.com/en-us/answers/questions/579764/local-development-with-azure-services-specifically

GCP has [some emulators](https://cloud.google.com/sdk/gcloud/reference/beta/emulators)
and it looks like the code using the [functions framework](https://cloud.google.com/functions/docs/functions-framework)
can run locally.

## Mountebank
-->
