---
theme: default
layout: cover
---

# Developer workflow with local tests using Docker Compose

## Michał "Butla" Bultrowicz

https://bultrowicz.com

https://witchsoft.com

https://twitter.com/mmmbultrowicz

https://www.instagram.com/mmmbultrowicz/

<!--
Tutaj zrobić tyci wprowadzenia o mnie?
-->

---

# About me (TODO - zostaw na pykonik)

- mainly worked on Python back-ends
- quality assurance
- data engineering
- tech leadership
- Java, C++, C# in the past
- I plan to post more educational material in the future

<!--
Tytuł wymyśliłem. Ale wszystkie są zmyślone, a część jest rozdmuchana.
Chief Executive Officer. Pffft... Po prostu "szef" nie można?

Będę potem wrzucał jakieś filmiki techniczne na jutuby, produkował w formie tekstowej na bloga,
i w formie jakiegoś minimalnego shitcontentu na Twittera i Instagrama :)
-->

---

# What's a container?

- It contains:
  - application code
  - system components (e.g. libraries) required by the app code
  - doesn't contain a Linux kernel.
- It runs on the host's kernel, in a process namespace separated from the host's processes.
- Windows and MacOS need a Linux VM to use containers.

---

# Docker and Docker Compose

- Docker: an implementation of containers.
- There are more container technologies, e.g. Podman.
- Docker Compose: describe and run set of Docker containers.

---

# Why have local tests with containers?

- higher probability that app really works vs. mock-only testing
- faster development by enabling local experimentation
- easier on-boarding of new team members

<!--
What will you gain if you use the techniques from this presentation?

More info when we get to specifics.
-->

---

# The sample app (TODO)

Python REST API with an SQL database.

TODO prepare... experiments? Testing sample app?
Don't show the code when it's not necessary.
Focus on the test code and ideas behind it.

Show the code file, the migrations.

Run it locally, show how to set it up with Docker.
Ping it to demonstrate it's working. We did a basic local test now.
Satisfy `git pull && make run` requirement.

Waiting for the DB to get up in the migrations.

Migracje traktować ogólnie. Mało pythona.
Migracje muszą czekać na bazę, bo to, że się odpali kontener nie znaczy, że baza jest gotowa.

<!--
Najpierw, jakaś przykładowa aplikacja - API, baza danych, migracje
Buduj ją z testami od razu.
Pokaż odpalanie jedną komendą
Pokaż przykłady jednostkowych, zintegrowanych, external (na cały feature).

This minimal app - how would you check that it's working? Just run it.
Ok, let's write down the command to do it.
Now everybody will be able to run it.

Stopniowo przechodź przez wszystkie obiecane tematy.
-->

---

# Interactive test setup

Not being able to play with the app is a huge detriment.
You will have more bugs, longer development time.

---

# Local vs. remote test setup

Best thing is a local setup, without the need for internet even (working on the train can be quite effective).
Some dev instance (or spawnable instances, maybe with Helm) is good.
Anything that the developer can change and observe.
But local ones are the easiest/fastest to work with. And cheapest :)

---

# Techniques to show (NOT A SLIDE)

Techniques:
- organizing the project so that a local instance of the app can be run with two commands: `git clone && make run`
- separation of unit, integrated, and functional tests (explain them)
- not resetting the test environment between tests
- local and CI test parity
- debugging code running in containers
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
