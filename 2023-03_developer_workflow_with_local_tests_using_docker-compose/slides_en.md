---
theme: default
layout: cover
exportFilename: "developer_workflow_with_local_tests_using_docker_compose.pdf"
---

# Developer workflow with local tests using Docker Compose

## Michał "Butla" Bultrowicz

Primary Software Wizard

<br/>

https://witchsoft.com

https://bultrowicz.com

<!--
Hi! My name is Michał Bultrowicz.
You could say I'm a holistic Python back-end developer.
Other than app code I do the tests, infrastructure, ensure reliability, etc.

Nowadays I'm focusing on producing my own end-user software under my own company's banner.

Today I'll talk about the developer workflow with locas tests using Docker Compose.
-->

---
layout: center
---

Slides + notes: [https://github.com/butla/presentations](https://github.com/butla/presentations/tree/master/2023-03_developer_workflow_with_local_tests_using_docker-compose)

<!--
Slides are available in this repository. Just look for the name of this presentation there.
-->

---

# What's a container?

- a process or a group of processes separated from the host's system
- has a file system independent from the host's one
- a bit like a Virtual Machine, but not really

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

# Docker and Docker Compose

- Docker: an implementation of containers.
- There are more implementations, e.g. [Podman](https://podman.io/).
- Docker Compose: describes and manages a group of related containers.

---

# Sample application - a notes repository

<br/>

[Python REST API + PostgreSQL](https://github.com/butla/experiments/tree/master/testing__quality_assurance/sample_backend_app)

<br/>

Endpoints API:
- `POST /notes/` - create a note
- `GET /notes/{id}/` - get the note by ID
- `GET /notes/` - get all notes

<!--
Pełna przykładowa apka pod linkiem.
Znajdziecie tam trochę więcej szczegółów niż zawarłem na prezentacji.

Doesn't even have update - that bare-bones.
-->

---
layout: two-cols
---

<template v-slot:default>

# Docker Compose setup

```yaml
# docker-compose.yml
---
version: '3'
services:
  api:                # <== our app
    build:
      context: .
    image: sample_backend
    ports:
      - "8080:8080"   # <== port config
    links:
      - database
    environment:
      - POSTGRES_HOST=database  # <==
  database:
    image: postgres:15.2
    ports:
      - "5432:5432"
    environment:
      - POSTGRES_PASSWORD=postgres
    volumes:          # <== persistence
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
You can see that there's not much here.

The services defined. Compose will build the Dockerfile.

Apka powinna mieć config ze zmiennych środowiskowych.
Tutaj przyjmuje adres postgresa.
To nazwa kontenera.

POSTGRES_HOST w aplikacji będzie miał domyślną wartość "localhost".

Mogłaby też przyjmować inne jego parametry, ale config ma defaulty, które będą działać.

Postgres będzie miał persistence - trzymanie danych między restartami.
Dzięki volumeowi.

In short - what's happening in the Dockerfile.
-->

---

# Running the application

```makefile
# Makefile - central repository of dev commands
.EXPORT_ALL_VARIABLES:  # useful if Makefile gets more elaborate
SHELL:=/bin/bash  # explicit shell declaration

setup_development:
	poetry install

run: _start_compose _db_migration

_start_compose:  # leading underscore disables tab-completion
	docker-compose up -d

_db_migration:
	poetry run alembic upgrade head  # needs to be tweaked to await DB
```

- need to modify the migrations to wait for the DB to get up

```bash
$ git clone <repo>
$ cd <repo>
$ make setup_development run  # voilà! the local app is running
```

<!--
Jeśli nie lubicie Make'a, to możecie mieć jakiś inny centralny skrypt z komendami potrzebnymi w developmencie i dla CI.

Make jest spoko, bo ma shell completions i jest wszędzie.

What's happening in the makefile.

Targety z podkreśleniami nie będą podpowiadane przez completions. Nie trzeba eksponować wszystkich komend.

Odpalenie migracji może nastąpić zanim jeszcze baza będzie gotowa, stąd potrzeba czekania na nią.
W pythonie używam tenacity. Ogólnie prosta pętla jakaś pingająca bazę.

Wasze systemy nie muszą mieć bazy SQL.
Zamiast migracji może być dowolne "zapewnienie początkowych danych" dla systemu.

Jeśli wasza apka potrzebuje jakichkolwiek danych do działania, to powinny być one częścią migracji.
(a nie, np. Django fixtures).

After these commands we'll have the app running on a "clean" environment.
-->

---

# What we have already

- Live app running locally.
- The ability to experiment with the code and database.
  - Huge time-saver
  - quality improvement
- Very simple "getting started" instructions.

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

# Time for the tests! 🦾

---

# Integrated tests

- use internal interfaces (like unit tests)
- use external systems (e.g. PostgreSQL in the container)

```python
def test_create_a_note():
    # arrange
    note_contents = f"I'm a note, wee! {uuid.uuid4()}"  # some randomness
    notes_repo = NotesRepository(...)  # object that connects to the DB

    # act
    id = notes_repo.create(note_contents)  # calls out to Postgres at localhost:5432

    # assert
    with db_session() as session:  # test code also calls out to Postgres
        query = select(Note).where(Note.id == id)
        saved_object = session.execute(query).scalar()
    assert saved_object.contents == note_contents
```

- no need for mocks
- ...you should have more tests than that

<!--
First kind of tests that I'll be talking about.

Bullets.

Co się dzieje w teście.

Tak wytestowany obiekt Repository można zastępować przez dependency injection w testach jednostkowych.
-->

---

# External tests (aka. functional/e2e)

- using **only** external interfaces (e.g. HTTP, data in DB)
- configuration as close to production as possible
- harder to debug, gotta look at the container logs

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
Name is something I use.
I feel it's more precise than saying functional, or component, or end-to-end tests.

Bullets.

Pełny scenariusz akceptacyjny:
- tworzymy notkę
- pobieramy notkę po ID
- zayważamy, że notka jest w grupie wszystkich notek
-->

---

# Missing code from the previous slide

```python
import uuid, httpx, pytest, tenacity

def test_store_and_retrieve_note(app_url):
    ...

# Session scope ensures we wait only once per test suite run.
@pytest.fixture(scope="session")
def app_url():
    app_address = "http://localhost:8080"
    _wait_for_http_url(app_address)
    return app_address

# Call the app until it returns correctly or times out.
# Same technique can be used on DB migrations.
@tenacity.retry(stop=tenacity.stop_after_delay(10), wait=tenacity.wait_fixed(0.2), reraise=True)
def _wait_for_http_url(url: str):
    result = httpx.get(url)
    if result.status_code != 200:
        raise ValueError("App returned the wrong status code")
```

<!--
Możemy robić więcej testów.

Czekanie przyda się jeśli apka wstaje wolno (lepiej tego unikać),
lub gdy będziemy przeładowywać kod i puszczać testy przy zmianach plików.

Podobne czekanie można wstrzyknąć w migracje (wcześniej mówiłem, że trzeba to do nich dodać).
-->

---

# Running the tests

```makefile
SOURCES:=sample_backend tests  # source code directories for some commands

check: static_checks test  # one make target to validate the code

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

# Integrated and external tests - what do we get?
- proof that the app turns on
- higher confidence it's working - app layers seem to work together
- less work than mock setups
- freedom to use full power of the tools
- slower than unit tests, still fast (if the app is fast)
- ⚠️ no full isolation between tests

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

# No isolation - a bit of chaos

- data reset between tests might be impractical
  - for Redis it'd be OK (but prevent test parallelization)
  - too slow in SQL
- some tests (e.g. get all notes) have to take that into account
  - collections can have unpredictable elements
  - need to build isolation into the data
- random app issues will bug you

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

# A bit of chaos - more realism

- production app doesn't wipe the data all the time
- catching bugs before production:
  - local DB keeps growing
  - "flaky" tests point out race conditions
- fixing the "random app issues" increases quality
- if you can't take it at the time: `docker-compose down -v`

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

# Organizing the tests

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

- explicit separation
  - numbers of high-level tests need to be controlled
- running faster test subgroups is easy
- [more info about the 3 kinds of tests](https://bultrowicz.com/separating_kinds_of_tests/)


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

# This works for complex applications

- battle-tested at 3 companies
- can integrate many systems (Kafka, Redis, RabbitMQ, etc.)
  - just need Docker images
- AWS locally - [Localstack](https://localstack.cloud/)
  - weaker tools for GCP and Azure
- faking other REST APIs - [Mountebank](http://www.mbtest.org/)
  - check out [mountepy](https://github.com/butla/mountepy)

<!--
Localstack only for AWS.
Azure has some local emulation https://learn.microsoft.com/en-us/answers/questions/579764/local-development-with-azure-services-specifically

GCP has [some emulators](https://cloud.google.com/sdk/gcloud/reference/beta/emulators)
and it looks like the code using the [functions framework](https://cloud.google.com/functions/docs/functions-framework)
can run locally.
-->

---
layout: two-cols
---

<template v-slot:default>

# Reloading the app code in the container

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

- no need to rebuild Docker image
- app in Docker restarts on any code change
- [entr](https://bultrowicz.com/universal_reload_with_entr/)
- [fd](https://github.com/sharkdp/fd)

</template>

<!--
Zamiast entr dla przeładowywania aplikacji można użyć czegoś innego.
Instead of entr for reloading, you can use something else.
Frameworks often have reload option.
-->


---
layout: cover
---

# Continuos Integration / Delivery

---

# Organizing CI

- CI removes `docker-compose.override.yml` - prevent bad images
- CI uses the same Makefile
- subcommands of `make check` made into parallel tasks
- after checks succeed:
  - tag the built app image
  - push it out to a repo
  - use in deployments

---
layout: two-cols
---

<template v-slot:default>

# CI self-hosted runners: free ports problem

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
self-hosted runners - if there's no isolation between the networks for test runs, ports will conflict.

Get random free ports.
-->

---

# Promised, but skimmed over material

- debug code in the container
  - [CLI](https://github.com/butla/bultrowicz.com/blob/b7e0d8379b37f77efa4669857c8d88f6124c3c95/unfinished_articles/debugging_python_in_docker_with_cli.rst)
  - IDE, e.g. [Intellij/Pycharm](https://www.jetbrains.com/help/pycharm/using-docker-compose-as-a-remote-interpreter.html#run)
- changes to production code for improved testability
  - every sleep in the app is configurable, low values for tests
  - it's OK to add app features to increase testability
    - testability is an useful feature of the product
  - ...others...

<!--
- launching coverage
- if you can't implement some needed tests without changing the code, then change the code.
  Add a special endpoint, or whatever.
  You might want to hide them behind a feature flag. Or maybe not - testing in production has its place.
-->

---
layout: center
---

# Fin

# 🫠
