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
I'm Michał, I'm the Primary Software Wizard at WitchSoft, my company.
The title is not more made up and pompous that something like "Chief Executive Officer".

In the recent past I did hollistic backends (with testing, reliability, infrastructure, etc.),
now I'm trying to start a business providing software directly to people.

I have twitter and everything, it's on the site.

-->

---

# What's a container?

- It contains:
  - application code
  - system components (e.g. libraries) required by the app code
  - doesn't contain a Linux kernel.
- It runs on the host's kernel, in a process namespace separated from the host's processes.
- Windows and MacOS need a Linux VM to use containers.

<!--
The target audience knows about Docker, but I'll explain in short just in case.
-->

---

# Docker and Docker Compose

- Docker: an implementation of containers.
- There are more container technologies, e.g. Podman.
- Docker Compose: describe and run set of Docker containers.

---

# Why have local tests with containers?

- higher probability that app really works vs. tests with mocks and in-memory fakes
- faster development by enabling local experimentation
- easier on-boarding of new team members

<!--
What will you gain if you use the techniques from this presentation?

More info when we get to specifics.
-->

---

# The example app (TODO)

Python REST API backed by an SQL database.
Requires migrations to run on the DB.

How do I run it?

Framework might give me some command to run it with some sqliteDB or some fake in memory thing.
We don't want that.

TODO NEXT slide - add Dockerfile, then docker-compose

<!--
Step 1: app plus database migrations - how do I run that?

When using some popular framework like Django in Python, you would just write tests that use some in-memory DB,
or SQLite.
why is it bad to not have a real dB? you don't use the real thing. you can be surprised after you deploy, cause in reality the app will behave differently. You don't use the full power of y
our tools. Like triggers or functions.

real app won't reset its database every call - your functional tests shouldn't too.
Integration ones as well.
You have some wiggle room to configure them, though. You can be creating a new org for every test.
You can create one, and add all the data to it. Or you can do anything in between.
Maximize chaos, but allow yourself to have the precision when you need to (e.g. be able to test a clean start,
but have the default a bit more messy and realistic).

Not all frameworks have tight DB integration and fakes. With this you can test everything.

Prawdziwa baza i nawarstwianie danych dają trochę chaosu, który czasem zrobi dziwny problem - tym samym symulując prawdziwy deployment

Don't show the code when it's not necessary.
Focus on the test code and ideas behind it.

Ping it to demonstrate it's working. We did a basic local test now.
Satisfy `git pull && make run` requirement.

Waiting for the DB to get up in the migrations.

Functional tests should wait for the app as well - tenacity.

Migracje traktować ogólnie. Mało pythona.
Migracje muszą czekać na bazę, bo to, że się odpali kontener nie znaczy, że baza jest gotowa.

Buduj ją z testami od razu.
Pokaż odpalanie jedną komendą
Pokaż przykłady jednostkowych, zintegrowanych, external (na cały feature).

This minimal app - how would you check that it's working? Just run it.
Ok, let's write down the command to do it.
Now everybody will be able to run it.

Stopniowo przechodź przez wszystkie obiecane tematy.
-->

---

# Interactive app setup

Not being able to play with the app is a huge detriment.
You will have more bugs, longer development time.

At least have something somewhere running that people can change and observe.
Best if it's local and doesn't need Internet connectivity.

---

# Local vs. remote test setup

Best thing is a local setup, without the need for internet even (working on the train can be quite effective).
Some dev instance (or spawnable instances, maybe with Helm) is good.
Anything that the developer can change and observe.
But local ones are the easiest/fastest to work with. And cheapest :)

---

# Podział testów

- unit - klasyczne testy jednostkowe
- integrated - używanie wewnętrznych interfejsów kodu w połączeniu z zewnętrznymi systemami;
  np. klasa repozytorium + prawdziwa baza danych)
- external - cały artefakt, konfiguracja produkcyjna albo tak blisko tej konfiguracji jak się da

TODO - link do artykułu

---

# Techniques to show (NOT A SLIDE)

Techniques:
- organizing the project so that a local instance of the app can be run with two commands: `git clone && make run`
  - compose/config env vars
- separation of unit, integrated, and functional tests (explain them)
- not resetting the test environment between tests
- local and CI test parity
  - overridey w dockerze? coś było z nimi
  - CI też odpala makefile
- debugging code running in containers
  - podpięcie się ręczne
  - podpięcie się z Pycharmem
- using "Docker mounts" to enable fast application reloading while editing code
- changes to the production code that make testing easier (configurable wait times, launching coverage)

- test code is outside of the container (additional)
- async tests, waiting for stuff (additional)
- destructive/non-destructive docker-compose tests (additional);
  non-destructive run with xdist before the destructive tests are run;
  mark destructive ones with pytest-mark;
  destructive example: graceful app shutdown

<!--
### Single command to run the app locally
Aplikacja też powinna być budowana do dockera.

### Shortly about functional and integrated tests

Sometimes the code's so simple that it won't need unit tests, though.

Unit/integrated/external test directories.


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
