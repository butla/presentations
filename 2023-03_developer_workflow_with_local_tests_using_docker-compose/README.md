Developer workflow with local tests using docker compose
========================================================

A presentation available in English and Polish.

Polish title: Lokalne testy z docker-compose a praca programisty

Video links:
- [English](https://youtu.be/hjve48cYj_U)
- [Polish](https://youtu.be/Ob-3YNgXYZc)


## Abstract

### EN

Containers have revolutionized many aspects of software development. In particular - testing.

Testing applications with the same data bases (e.g. Postgres, Redis), queues (e.g. Kafka), etc.
that they'll rely on in production grants a substantially higher degree of confidence in the software,
than tests with mocks or in-memory fakes of real connectors.

In this presentation I'll show how I use docker-compose for local running and testing of the app being developed.
How to adjust the code and set the configuration to make your work faster, ease on-boarding of new team members,
and, above all, to increase the quality.
The presented techniques emerged from working on a couple projects across the last 5 years.

The example code will be a Python back-end app, but the techniques will apply in other programming languages,
and not only for back-end applications.

The presentation assumes at least a passing familiarity with Docker and docker-compose.

The subjects covered will include:
- separation of unit, integrated, and functional tests
- organizing the project so that a local instance of the app can be run with two commands: `git clone && make run`
- not resetting the test environment between tests
- local and CI test parity
- debugging code running in containers
- using "Docker mounts" to enable fast application reloading while editing code
- changes to the production code that make testing easier

### PL

Kontenery zrewolucjonizowały wiele aspektów wytwarzanie oprogramowania. W szczególności testy.

Testowanie aplikacji w połączeniu z tymi samymi bazami danych (np. Postgres, Redis), kolejkami (np. Kafka), itp.,
na których aplikacja będzie polegała na produkcji daje dużo większą pewność, niż testy z mockami lub wyabstrachowanymi
klasami udającymi prawdziwe bazy.

W tej prezentacji pokażę jak używam docker-compose do lokalnego uruchamiania i testowania tworzonej aplikacji.
Jak należy dostosować kod i dobrać konfigurację, aby przyspieszyć pracę, ułatwić wdrażanie nowych członków zespołu,
oraz, przede wszystkim, zwiększyć jakość.
Są to techniki, które dopracowywałem w kilku projektach na przestrzeni ostatnich 5 lat.

Przykładowy kod będzie Pythonową aplikacją back-endową,
ale wykorzystane techniki będą się przekładać na inne języki programowania.
Też nie tylko aplikacje webowe mogą czerpać korzyści z używania Dockera w testach.

Prezentacja zakłada przynajmniej pobieżną znajomość Dockera i docker-compose.

Poruszane tematy będą zawierać:
- rozdzielenie testów jednostkowych, zintegrowanych i funkcjonalnych
- organizację projektu tak, aby lokalną instancję aplikacji można było uruchomić dwiema komendami: `git clone && make run`
- brak pełnego resetu środowiska między testami
- analogiczność testów lokalnych i CI
- debuggowanie kodu w kontenerach
- używanie "Docker mounts" aby umożliwić szybkie przeładowywanie kodu w trakcie pracy
- zmiany kodu produkcyjnego ułatwiające testowanie
