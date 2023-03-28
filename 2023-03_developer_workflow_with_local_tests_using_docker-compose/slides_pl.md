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
Apka powinna mieć config ze zmiennych środowiskowych.
Tutaj przyjmuje adres postgresa.
Mogłaby też przyjmować inne jego parametry, ale config ma defaulty, które będą działać.
POSTGRES_HOST w aplikacji będzie miał domyślną wartość "localhost".

Postgres będzie miał persistency - trzymanie danych między restartami.

Nie musimy się zagłębiać w kod plików.
Ważne, że widzimy, że nie ma tego dużo.
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

- Lokalnie działająca aplikacja.
- możliwość eksperymentowania.
- łatwość zaczynania pracy dla nowych członków zespołu

<!--
Not being able to play with the app is a huge detriment.
You will have more bugs, longer development time.
-->

---
layout: cover
---

# Pora na testy! 🦾

---

# Testy zintegrowane (integrated)

- używanie wewnętrznych interfejsów kodu (jak testy jednostkowe)
- wykorzystanie zewnętrznych systemów (np. PostgreSQL z kontenera)
- odblokowanie mocy narzędzi, przez umożliwienie testowania:
  - jeśli możemy coś testować, to możemy tego używać (np. możliwe jest testowanie triggerów w SQL)

np. klasa repozytorium + prawdziwa baza danych)

Framework might give me some command to run it with some sqliteDB or some fake in memory thing.
We don't want that.

<!--
When using some popular framework like Django in Python, you would just write tests that use some in-memory DB,
or SQLite.
why is it bad to not have a real dB? you don't use the real thing. you can be surprised after you deploy, cause in reality the app will behave differently. You don't use the full power of y
our tools. Like triggers or functions.

Not all frameworks have tight DB integration and fakes. With this you can test everything.
-->

---

# External (functional/component/end-to-end) tests

- używanie tylko zewnętrznych interfejsów aplikacji (np. HTTP)
- konfiguracja maksymalnie zbliżona do produkcyjnej
- kompletne scenariusze używania aplikacji
- z tymi testami co mamy widać, że aplikacja faktycznie działa. End-to-end przejście przez apkę

<!--
Functional tests should wait for the app as well - tenacity.

Name is something I use.
-->

---

# Odrobina chaosu - większy realizm

- stan systemu nie jest resetowany
- Realizm daje większą pewność, że aplikacja będzie działać na produkcji.
- czasem natkniemy się na problemy, które wystąpią też na produkcji

- has to be some chaos
- with something like Django I switch to using the DB directly
- tests for things like retrieving the entire collection of objects need to ensure that the new items need to
  be there, not match the whole retrieved collection.
  This technique also helps with making tests more independent of each other, so they can be run out-of-order
  (that sometimes creeps in into test-suites) and parallelised
- a volume in docker-compose needed for persistence;
  if you get weird issues and can't figure them out, try docker-compose down -v to clear out everything.
  But remember - maybe that issue can happen in production? Although local instances have a lot of garbage data.

<!--
real app won't reset its database every call - your functional tests shouldn't too.
Integration ones as well.
You have some wiggle room to configure them, though. You can be creating a new org for every test.
You can create one, and add all the data to it. Or you can do anything in between.
Maximize chaos, but allow yourself to have the precision when you need to (e.g. be able to test a clean start,
but have the default a bit more messy and realistic).

Prawdziwa baza i nawarstwianie danych dają trochę chaosu, który czasem zrobi dziwny problem - tym samym symulując prawdziwy deployment
-->

---

# Test organization

Three separate folders.
Link the article. Mention the whys of the separation.

---

# Local vs. remote test setup

At least have something somewhere running that people can change and observe.
Best if it's local and doesn't need Internet connectivity.

Best thing is a local setup, without the need for internet even (working on the train can be quite effective).
Some dev instance (or spawnable instances, maybe with Helm) is good.
Anything that the developer can change and observe.
But local ones are the easiest/fastest to work with. And cheapest :)

---

# Techniques to show (NOT A SLIDE)

Techniques:
- local and CI test parity
  - CI też odpala makefile
  - docker-override z mountem może być usuwany w CI
  - dobrze jak jest docker-in-docker w runnerach, żeby nie było konfliktów na portach;
    w innym przypadku trzeba pokombinować, brać jakieś wolne i wstrzykiwać je w docker-compose i w inne miejsca
    Można np zrobić override z portami.
- using "Docker mounts" to enable fast application reloading while editing code
  - pokaż odpalanie z entr jak się ma mounta (oczywiście można używać jakiś wewnętrznych frameworkowych rozwiązań,
    ale czasem są źle napisane, mielą procem. No i wymagają zmieniania konfiguracji apki, przez co odchodzi
    od wartości produkcyjnych)
- debugging code running in containers
  - podpięcie się ręczne
  - podpięcie się z Pycharmem
- changes to the production code that make testing easier (configurable wait times, launching coverage)

<!--

### using real local DBs in tests
not fakes provided by frameworks, like in Django.
Testy są dużo bardziej realistyczne w takim przypadku.
Pozwala używać i sprawdzać więcej funkcji bazy danych / data store'a, np. triggery, indexy, itp.

It's good to have some layer of abstraction so that not all tests require a DB.
I don't know what frameworks you use, but Django is awful in that aspect - it encourages using ORM objects a lot,
because tests will magically work in memory.

### Local dev tests and CI test parity
CI can run ones integrated with other apps.

You can use tools like pre-commit locally. I just use Makefiles.

CI - would be best if the image we'll be using is the same that will be pushed out.
So build image first, then run functional tests with it.

### test code is outside of the container
App configs for different kinds of tests (functional in docker, integrated in localhost).
Wartości configów (jak adres bazy) pod testy integracyjne (łączymy się z localhosta) i funkcjonalne
(łączymy się z kontenera).

Można też testy wsadzać w kontener, ale ja tego nie robię.

### No full setup/teardown

More like tests against a deployed app.

Makes the app and the tests more robust. The code needs to handle real issues.

With full setup all the time it takes a long time.

### docker mounts for code reloading
Pierwszy krok to mounty i restartowanie.

Drugi to live reload. Frameworki mogą mieć takie opcje - pokaż z FastAPI.
Tutaj też pokaż overloading domyślnego polecenia w compose dla potrzeb developmentu.
Ale przydałoby się mieć jakieś testy z domyślnym poleceniem. Może jakieś testy mogą wyłączać polecenie z compose.
Albo może ono być w lokalnym override, którego nie będzie w CI.
Tradeoffy co do parity.

Możecie też używać jakiś live-reload frameworków, albo czegoś takiego jak `entr` w poleceniu dockera.
Nie dawałbym live reload w wersji produkcyjnej, tylko.

### Async tests

If you're doing real calls you might need to wait for results.

Many flaky tests showed me real race conditions.

Use retrying decorators (like tenacity) liberally in tests.

You might wanna tune the configs in tests

### Code changes that help with tests

E.g. coverage hooks, additional endpoints behind feature flags, synchronization points.
Dodawanie jakiś testowych endpointów do kodu - też OK. Można je chować za jakąś opcją (feature flags).

100% coverage without overuse of mocks is possible.

Test-enabling code can be a part of the product. Testability is a feature.

### Additional things
**Fast docker builds** with sensible command sorting - install dependencies (use caches), then add your code.

**Design your code with testability in mind.**
You can chunk up the code better then.
Take care of more things with unit tests. So that integrated and functional tests will not multiply too much.
Separation of concerns is important.

**Guerilla testing**

Some patterns (like ORM because it lets you test the DB code without a real DB) become less appealing, as well.
Show the tests with triggers. Why bother? Locking is good, etc.

If you can reliably test more. You can really treat external apps as part of your app. Like DBs. Or Redis.

**Centralize your logs?**
Talk about logs in the context of debugging?

### Localstack
Only for AWS.
Azure has some local emulation https://learn.microsoft.com/en-us/answers/questions/579764/local-development-with-azure-services-specifically

GCP has [some emulators](https://cloud.google.com/sdk/gcloud/reference/beta/emulators)
and it looks like the code using the [functions framework](https://cloud.google.com/functions/docs/functions-framework)
can run locally.

### Mountebank
-->
