# TDD of Python microservices - Michał Bultrowicz

## Abstract (OK)
To have a successful microservice-based project you might want to start testing early on,
shorten the engineering cycles, and provide a more sane workplace for the developers.
Test-driven development (TDD) allows you to have that.

Except for the stalwart unit tests, proper TDD also requires functional tests.
This article shows how to implement those tests (using the
[Mountepy] (https://github.com/butla/mountepy) library I made, Pytest and Docker),
how to enforce TDD (using multi-process code coverage) and good code style (with automated
Pylint checks) within a team.
Furthermore, contract tests based on Swagger interface definitions are introduced as a safeguard
of the microservices' interoperability.

The focus is on services communicating through HTTP, but some general principles will also apply to
all web or network services.


## Motivation
### Why use microservices?
There are numerous upsides for implementing a big distributed system as a network of microservices.

Technology Heterogeneity
With a system composed of multiple, collaborating services, we can decide to use different technologies inside each one. This allows us to pick the right tool for each job, rather than having to select a more standardized, one-size-fits-all approach that often ends up being the lowest common denominator. Developers like working in a technology they like and they have more opportunities for that with microservices

Scaling
With a large, monolithic service, we have to scale everything together. One small part of our overall system is constrained in performance, but if that behavior is locked up in a giant monolithic application, we have to handle scaling everything as a piece. With smaller services, we can just scale those services that need scaling, allowing us to run other parts of the system on smaller, less powerful hardware,

Resilience
A key concept in resilience engineering is the bulkhead. If one component of a system fails, but that failure doesn’t cascade, you can isolate the problem and the rest of the system can carry on working. Service boundaries become your obvious bulkheads. In a monolithic service, if the service fails, everything stops working. With a monolithic system, we can run on multiple machines to reduce our chance of failure, but with microservices, we can build systems that handle the total failure of services and degrade functionality accordingly.

Ease of Deployment
A one-line change to a million-line-long monolithic application requires the whole application to be deployed in order to release the change. That could be a large-impact, high-risk deployment. In practice, large-impact, high-risk deployments end up happening infrequently due to understandable fear. Unfortunately, this means that our changes build up and build up between releases, until the new version of our application hitting production has masses of changes. And the bigger the delta between releases, the higher the risk that we’ll get something wrong!
With microservices, we can make a change to a single service and deploy it independently of the rest of the system. This allows us to get our code deployed faster. If a problem does occur, it can be isolated quickly to an individual service, making fast rollback easy to achieve. It also means we can get our new functionality out to customers faster. This is one of the main reasons why organizations like Amazon and Netflix use these architectures—to ensure they remove as many impediments as possible to getting software out the door.

Organizational Alignment
Many of us have experienced the problems associated with large teams and large codebases. These problems can be exacerbated when the team is distributed. We also know that smaller teams working on smaller codebases tend to be more productive.
Microservices allow us to better align our architecture to our organization, helping us minimize the number of people working on any one codebase to hit the sweet spot of team size and productivity. We can also shift ownership of services between teams to try to keep people working on one service colocated.

Optimizing for Replaceability (podłączyłbym pod technology heterogenity)
If you work at a medium-size or bigger organization, chances are you are aware of some big, nasty legacy system sitting in the corner. The one no one wants to touch. The one that is vital to how your company runs, but that happens to be written in some odd Fortran variant and runs only on hardware that reached end of life 25 years ago. Why hasn’t it been replaced? You know why: it’s too big and risky a job.
With our individual services being small in size, the cost to replace them with a better implementation, or even delete them altogether, is much easier to manage. How often have you deleted more than a hundred lines of code in a single day and not worried too much about it? With microservices often being of similar size, the barriers to rewriting or removing services entirely are very low.

Powinny być zgodne z 12factor app, co też daje plusy.

### Why NOT use microservices?
Trzeba pamiętać, że jak każde inne rozwiązanie w IT microservicy nie są złotym młotkiem
i trzeba wiedzieć kiedy je stosować a kiedy nie.
And be mindful that hype (and microservices were getting a lot of it), even in the supposedly
pragmatic and scientific world of software development, isn't always justified.
When in doubt if you really need microservices instead of a traditional web application,
start with the latter ("the monolith").
You can always separate out individual services later on in a gradual, iterative manner
as you gain insight into the problem domain and real-life workings of your system. 

### Microservice challenges
Of course, all the pros of the microservice approach come with some cons.
The fast-paced environment in which the systems grows and changes in many places simultaneously
can be hectic, stressful, and exhausting... if you're not following proper procedures.
And I've experienced that first-hand.

I was in a project in which it was decided to go all in on microservices from day one,
without a picture of how exactly we are going to do things.
And by doing things I mean developing interdependent application as a few rather independent teams.
In this situation, many people working on many things at once sometimes
(not as seldom as we would like) resulted in, sometimes severe, bugs.

Jeszcze jeden czynnik nawarstwiający bugi.
W dużym, rozwijającym się zespole często będzie trzeba albo wprowadzać nowych
ludzi do dewelopmentu, albo przekazywać im jakiś kod, albo samemu się przerzucać.
Jeśli jest się jednym z maintainerów i ma się coraz więcej spraw na głowie z racji
przyspieszającego projektu (ja tak miałem), to może zacząć brakować czasu na opiekę
nad utrzymywanym softem.
Mniej czasu to mniej uwagi i większe niedbalstwo, a więc błędy.
Im więcej błędów tym więcej czasu na debugowanie i jeszcze mniej czasu na resztę roboty
(a terminy gonią). Widać błędne koło.
Świezi ludzie też mogą nie być dobrymi programistami - kolejne źródło błędów.

### TDD as a solution
Jak soft często się psuje, to trzeba go testować.
TDD powinno dać:
* Confidence in face of changes.
* Automation checks everything (też dla nowych).
* Ward off bad design (też dla nowych).
TDD Requirements:
* Discipline (do tego trzeba przekonać ludzi)
* Tools (to dam)

Ale unit testy (na których ludzie czasem poprzestając przez to, że testy zintegrowane mogą być
trudniejsze) to nie rozwiązanie.
Szczególnie w przypadku Pythona, który nie sprawdza czy dobrze integrujemy moduły (czy używamy
odpowiednich interfejsów).
Nawet 100% pokrycia testowego, kiedy dysponujemy tylko unit testami nie pokaże, że aplikacja
działa dobrze i faktycznie się uruchomi.
A do tego będzie miała pełno bezsensownych testów przepchanych mockami, które tak naprawdę
nie udowadniają poprawności.

Trzeba testować całą aplikację, ale przy mikroserwisów one zależą na innych aplikacjach.
(TODO przykładowy diagramik zależności).
Czyli w praktycę trzeba by testować cały system?
Takie całościowe testy są dość długie i ciężko przeprowadzać je dla wielu drobnych
zmian (które ludzie robią) jednocześnie i niezależnie od siebie.

Rozwiązanie tych problemów przedstawiam w artykule.


## Framework-agnostic service tests
### Their place in TDD
To have TDD, and thus a maintainable microservice project, we need tests that the entirety
of a single application, the "service tests" (term used in "Building Microservices").
W książcę "Test-Driven Development with Python" takie testy, co prawda w kontekście
tradycyjnych aplikacji webowych, nazywane są testami funkcjonalnymi
i są niezbędnym elementem prawdziwego TDD z podwójną pętlą (inaczej outside-in TDD)

![](images/tdd_cycle.png "TDD cycle")

Ten obrazek, który zdawkowo tłumaczy całe TDD wzięty jest ze wspomnianej chwilę wcześniej
książki Harrego Percivala.

Widzimy, że tworzenie każdego nowego feature'a powinno zaczynać się od tworzenia testu
funkcjonalnego (serwisowego).
To też sprawdzenie, czy Pythonowy kod naprawdę działa, bo czasem zdażają się rażące
błędy, które nie przeszłyby kompilacji w statycznie typowanym języku
(nie mówię, że wolę typowane)

Należy jednak pamiętać, że nie można przesadzić z testami funkcjonalnymi i powinny one
sprawdzać tylko krytyczne ścieżki i integrację pomiędzy unitami.
Dokładne pokrycie logiki dalej przez unit testy.

### Their place in microservice tests
Service tests are the thing that say whether an application will actually not crash on start.
Robi to dzięki testowanie całego żyjącego procesu aplikacji, bez żadnych specjalnych
lokalnych flag, czy fake'ów zastępujących prawdziwe klienty baz danych.
Aplikacja nie powinna wiedzieć, że nie jest na produkcji.
(jak to zrobić w kolejnej sekcji).

Dzięki temu testy są odizolowane od całego środowiska i mogą być puszczane na maszynach
deweloperskich i w CI.
Każdy może puszczać je niezależnie, przez co development różnych feature'ów w różnych
miejscach może iść równolegle.

In his presentation about testing microservices, Martin Fowler places service tests
(which he calls out-of-process component tests) in the middle of the piramid.

![](images/test_pyramid.png "Microservice test pyramid")

Jednostkowe to wiadomo, testują jednostkę (klasę, funkcję).
Zintegrowane to taki trochę unit, ale używający prawdziwych zasobów (jak serwicowe).
Np. testy klasy repozytorium gadającego z prawdziwą bazą danych.
End-to-end testują całą zdeployowaną platformę tak, jakby korzystał z niej docelowy klient
(można nawet testować na produkcji).
Eksploracyjne już nie są zautomatyzowane (wszystkie inne muszą być!) i polegają na ludzkiej
ingenuity, żeby znaleźć luki w systemie.
Wszystkie te są bardzo ważne, ale nie mam czasu bardziej się w nie zagłębiać.

Jeśli wszystkie pojedyncze aplikacje mają testy serwisowe, to każda z osobna powinna działać
dobrze (potem zobaczymy, że nie jest tak do końca), czyli jest duża szansa, że cała platforma
będzie w porzo.
Potrzebne są e2e, żeby to naprawdę sprawdzić, ale cóż, ni ma miejsca i dużej ekspertyzy.

### Necessary tools
Żeby mieć testy serwisowe mogące chodzić lokalnie potrzeba jakoś wystawić dla serwisu
runtime dependencies, a więc:

* bazy danych (i ewentualnie jakieś inne aplikacje)
* pozostałe serwisy platformy, które wykorzystuje (pod tą kategorię można też podciągnąć
  jakiekolwiek aplikacje HTTP)

Bazy danych można ogarnąć na kilka sposobów:
Normally - a tiresome setup (a chcemy móc po prostu odpalać testy)
Verified Fakes - rarely seen. Wymagają jakiegoś przygotowania. Co to?
Docker - just create everything you need as containers. A while ago only for linux, but
now support is starting on windowns and Mac.

O ile bazy dla jednej aplikacji dałoby się wystawić, to pozostałe
serwisy ciągną za sobą ich zależności, aż w końcu trzeba by wystawiać całą platformę na
jednej maszynie, co nie dość, że nieporęczne, to często niemożliwe.
But HTTP services can be mocked (or stubbed) out for service tests.
There are a few solutions, the ones I came across with:

* WireMock - odpalane jako niezależny proces. Wychodzi z Javy. Może być konfigurowany po HTTP
* Pretenders (Python) - można używać jako biblioteki z kodu testów. Nie wydaje się mocno rozwijany.
* Mountebank - tak jak WireMock, ale więcej funkcjonalności (testy TCP, popsutych wiadomości HTTP)
  Nie wymaga Javy. Napisane w NodeJS, ale można ściagnąć standalone aplikację. To wybrałem.

Aby wygodnie używać mountebanka w testach napisałem bibliotekę [Mountepy](https://github.com/butla/mountepy).
Ładnie startuje i stopuje jego proces w testach.
Ponieważ procesy samych mikroserwisów (aplikacje HTTP) są podobne do Mountebanka, nie jako za darmo
dostałem też zarządzarkę procesami aplikacji na których wykonywane są testy.

### Test anatomy
Jako framework testowy zdecydowałem się używać Pytesta, ze względu na jego zwięzłość
i potężny i komponowalny system fixture'ów, które niebawem pokażę.

Przykładowy test serwisowy może wyglądać jak zwykły, prosty test:

```python
def test_something(our_service, db):
    db.put(TEST_DB_ENTRY)
    response = requests.get(
        our_service.url + '/something',
        headers={'Authorization': TEST_AUTH_HEADER})
    assert response.status_code == 200
```

The test is parameterized with Pytest (which I have chosen as the test framework) fixtures,
that is test resource objects: `our_service` (Mountepy handler of the service under test) and `db` (Redis client).

It's quite clear what's happening in the test: some test data is put in the data base (Redis),
the service is called through HTTP, and finally, there's an assertion on the response.
Such straightforward testing is possible thanks to the power of Pytest fixtures.
Not only can they parameterize tests, but also other fixtures.
The two top-level fixtures presented above are themselves composed of other fixtures
(which gives them a good behavior?) as presented on the diagram below.

![](images/fixtures.svg "Fixture composition")

Let's now trace all the elements that make up our test fixtures.
First, `db`:

```python
import docker
import pytest
import redis 

@pytest.yield_fixture(scope='function')
def db(db_session):
    yield db_session
    db_session.flushdb()

@pytest.fixture(scope='session')
def db_session(redis_port):
    return redis.Redis(port=redis_port, db=0)

@pytest.yield_fixture(scope='session')
def redis_port():
    docker_client = docker.Client(version='auto')
    download_image_if_missing(docker_client)
    container_id, redis_port = start_redis_container(docker_client)
    yield redis_port
    docker_client.remove_container(container_id, force=True)
```

`db` is function scoped, so it will be recreated on each test function.
To czyści bazę, ale nie tworzy jej on nowa.
Samo czyszczenie zrobione jest dzięki `yield_fixture`.
`yield` returns the resource object to the test, but the control later returns to the fixture function
(when this happens is determined by the fixture's scope).
This is an excellent way for coding clean-up logic without any callbacks.
Bierze obiekt kliencki bazy od `db_session`, który jest tworzony co sesję, czyli raz na odpalenie całego test suit.

To create a redis client, there needs to a living Redis instance.
`redis_port` is a session-scoped fixture returning a port number for a Redis, but under the hood
it creates and later destroys the whole Redis Docker container.
`start_redis_container` startuje kontener Redisa i czeka, aż on w środku zacznie odpowiadać na requesty
(fajnie by było, jakby był na coś takiego wbudowany mechanizm na czekanie na gotowość kontenera
w samym Dockerze).
Kod tego można znaleźć w [PyDAS](https://github.com/butla/pydas), który był moim eksperymentalnym projektem dla
wprowadzania TDD (można tam zobaczyć wykorzystanie wszystkich technik z tego papieru).

Thanks to this being session-scoped we don't have to spawn a new container for each test
requiring it.
This saves much time but may be looked down upon by people paranoid about test isolation
But if Redis creators did their job well, then cleaning the data base in `db` should be enough
to start each service test on a clean slate.

`download_image_if_missing` function can also download the image needed to create the container, so people running
the tests don't have to do that manually.
They can simply run the tests and everything will set itself up.

Let's get to the second base fixture - `our_service`.

```python
import mountepy

@pytest.fixture(scope='function')
def our_service(our_service_session, ext_service_impostor):
    return our_service

@pytest.yield_fixture(scope='session')
def our_service_session():
    service_command = [
        WAITRESS_BIN_PATH,
        '--port', '{port}',
        '--call', 'data_acquisition.app:get_app']

    service = mountepy.HttpService(
        service_command,
        env={
            'SOME_CONFIG_VALUE': 'blabla',
            'PORT': '{port}',
            'PYTHONPATH': PROJECT_ROOT_PATH})

    service.start()
    yield service
    service.stop()

@pytest.yield_fixture(scope='function')
def ext_service_impostor(mountebank):
    impostor = mountebank.add_imposter_simple(
        port=EXT_SERV_STUB_PORT,
        path=EXT_SERV_PATH,
        method='POST')
    yield impostor
    impostor.destroy()

@pytest.yield_fixture(scope='session')
def mountebank():
    mb = Mountebank()
    mb.start()
    yield mb
    mb.stop()
```

`our_service` właściwie tylko przekazuje jeden fixture dalej `our_service_session`
i wymusza stworzenie innego - `ext_service_impostor`
I has function scope because `ext_service_impostor` has function scope.
Fixtures can only be composed with those of the same or broader scope;
it's not possible for a session scoped test be dependent on a function scoped test.
BTW, there are more scopes, function and session are, respectively, the narrower and the broadest.

`our_service_session` creates (and later destroys) the process of the service under test with Mountepy.
This is straightforwad: you need to define the command line arguments for the service process
like you would do when using Popen, and pass service configuration as environment variables (`env=`).
The process being started here is Waitress (an WSGI container, alternative to gunicorn and uwsgi)
running the web application.

It also uses the same trick as `db` and `db_session` to save time.
It's true that here the risk of tests infuencing each other is greater, because it concerns the software
that we are writing and not something that the whole community depends on, like Redis.
But any strange behavior of the tests may indicate that we didn't write the application to be stateless,
which it should be when upholding the tenents of 12 factor app, so the tests will do their job of finding problems.

`ext_service_impostor` nie jest bezpośrednio wykorzystywany, ale wywołuje kontrolowany efekt uboczny - ustawienie
impostora (mocka usługi HTTP) w procesie mountebanka na czas trwania testu.
Robi to dzięki obiektowi zarządzającemu procesem mountebanka (który także jest stworzony raz na całe testy).
Impostor w tym przypadku jest bardzo prosty - sprawia, że POST na zadanym porcie i zadanej ścieżcę (np. "/some/resource")
będzie zwracał 200 i pustą odpowiedź (poprawnie jeśli chodzi o HTTP byłoby, żeby zwracał 204, ale tak krótszy kod)

### Remarks
Widać, że ogólnie kod, który trzeba napisać nie jest duży - można te fixture'y przeklejać między projektami.
Ale może kiedyś zrobię jakiś plugin do pytesta.
Jeśli ktoś z czytelników chce to zrobić, niech da mi znać.
Co do dockera to może są już jakieś pluginy do pytesta, żeby obługiwać ściąganie i spawnowanie kontenerów.

Może by się wydawać, że testy które odpalają kilka procesów i robią prawdziwe calle HTTP
będą wolne, ale tak być nie musi.
W przypadku PyDAS, gdzie było 8 testów serwisowych, 3 zintegrowane (wspomniane wcześniej, też używające prawdziwego Redisa)
i 40 jednostkowych całość zabierała lekko poniżej 3 sekund (Python 3.4).
Jedna rzecz, której nie wyjaśniłem to to, że po boocie kompa testy zajmą dłużej, ok 11 sekund.
No i pierwsze odpalenie testów jeśli nie mamy image'u dockerowego zatrzyma się w momencie ściągania
i zajmie tyle ile ściąganie.

Pamiętajcie, że mimo wszystko dobrze mieć te testy w osobnych folderach, żeby móc robić bardzo szybkie zmiany
i puszczać jedynie jednostkowe (ok 0.3 sekundy).

No, czyli testy wychodzą szybkie, a jak są szybkie, to ludzie się cieszą, faktycznie je puszczają i jest
jakiś zysk z posiadania testów.
Jak by były za wolne to i tak ludzie nie chcieli by ich puszczać, więc cały wysiłek
w nie włożony szedł by na marne.

Before ending the topic of service tests, a few words of warning.
When a test fails in Pytest, all of it's output is printed in addition to the test stacktrace.
Service tests start a few processes, probably all of which print quite a few messages,
so when they fail you'll be hit with a big wall of text.
The upside is that it this text will most probably state somewhere what went wrong.

Breaking a fixture sometimes happens when experimenting with and refactor the tests (which I encourage).
This can yield even crazier logs that simply failed service tests.

And the last thing - tests won't save you from all instances of human incompetence.
When I created PyDAS using TDD I wanted to put it in our staging environment it kept crashing.
It turned out that I was ignoring Redis IP from configuration and had hardcoded localhost,
which was fine with the tests.
So be confident in your tests, but never a hudred percent.


## Enforcing TDD
Żeby ludzie robili TDD

### Measuring code coverage
A propos pokrycia w service testach:
Możliwość liczenia pokrycia testami poza procesem się bardzo przydaje, żeby oszczędzić roboty jednocześnie trzymając wysoką jakość.
Czasem bez sensu duplikować wolne testy w szybkich, skoro tylko wolne dają jakąś dozę pewności (testy redisa w pydasie). Ale jeśli wolne przechodzą, to umożliwia to posiadanie szybkich z jakimiś założeniami w mockach. 

.coveragerc z PyDASa

```
[report]
fail_under = 100
[run]
source = data_acquisition
parallel = true
```

http://coverage.readthedocs.io/en/coverage-4.0.3/subprocess.html

Musi być pokryty cały kod. Jak nie ma, to fail.

W Pythonie przydaje się mieć chociaż 100, żeby mieć przekonanie, że nie zrypało się gdzieś wywołań.

Pokrycie się przydaje, żeby sprawdzić, czy nie zapomnieliśmy o żadnej linii. Niby robiąc TDD powinniśmy i tak pisać najpierw test, potem kod. Czyli fragment kodu powinien powstawać tylko, jak mamy na niego test. Ale czasem chcemy pracować trochę szybciej i dodajemy jakiegoś "ifa" w kodzie zauważając, że jest sytuacja w której coś może się wywalić. Np. chcąc zrealizować funkcjonalność dla jednego testu piszę kod, który może rzucić wyjątek. Dodaję try/except. Pokrycie przypomni mi, że nie przetestowałem tego przypadku.

Parallel - testy serwisowe też będą mierzyły pokrycie.
Nawet jak Pydas odpalał jeszcze inne rzeczy przez multiprocessing.

### Mandatory static code analysis
Wyskoczy coś w pylincie to bum.

Można false-positivy oznaczać w liniach.

tox.ini (simplified) https://tox.readthedocs.io

```
[testenv]
commands =
    coverage run -m py.test tests/
    coverage report -m
    /bin/bash -c "pylint data_acquisition --rcfile=.pylintrc"
```


## Contract tests with Swagger and Bravado
Dodatkowe zabezpieczenie przy pracy z ludźmi i mikroserwisami.

Nawet mając takie testy, jak sprawić, żeby zmiana w jednym serwisie nad którą ktoś
niezależnie pracuje (i puszcza na nią testy) nie zepsuła jakiś interakcji z serwisami?
Even if you have a way to do TDD, maybe not everyone on the teamwill follow it, making life harder
for everyone.

Powinny trzymać w ryzach nasz kontrakt.

Zapewniać, że przez przypadek nie zmieniliśmy.

### Swagger
[Swagger](http://swagger.io/) is an interface definition language. Will serve as contract description.
Now also called OpenAPI a standard under the wings of Linux Foundation.
Has many tools (online editors, code generators), integrations with different languages.

An example Swagger document written in YAML format (JSON also happens) is below.

```
swagger: '2.0'
info:
  version: "0.0.1"
  title: Some interface
paths:
  /person/{id}:
    get:
      parameters:
        -
          name: id
          in: path
          required: true
          type: string
          format: uuid
      responses:
        '200':
          description: Successful response
          schema:
            title: Person
            type: object
            properties:
              name:
                type: string
              single:
                type: boolean
```

It defines a HTTP endpoint on path /person/{id} on the service's location (e.g. http://example.com/person/zablarg13).
This endpoint will respond to a GET request.
It has one parameter - id - that is passed in the path and is a string.
The endpoint can respond with a message with status code 200 contaning the representation of
a person's data - and object with their name as string and the information if they are single (boolean).

### Contract/service tests
Contract (Swagger API description) should be separate from code so that when patches break the
contract we can detect it.
Some solutions generate Swagger from code which would have the bonus of documenting the API
(also there with a separate, static contract), but it would be pointless from the perspective
of our contract tests.

[Bravado](https://github.com/Yelp/bravado) is a library that can dynamically create client
objects for a service based on its Swagger contract.

It can automatically validate the types (schemas) of both parameters and the values returned from
services.
Can verify HTTP status codes. Status code and response schema combinations that don't exist
in Swagger are treated as invalid, e.g. if we can return a Person object with code 200 and
an empty body with code 204, returning a Person with 204 will cause an error.

It's worth noting that Bravado can be configured to enable or disable different validation checks.
This is helpful in testing the unhappy path through your service.


Bravado used In service tests: instead of “requests”

```python
def test_contract_service(swagger_spec, our_service):
    client = SwaggerClient.from_spec(
        swagger_spec,
        origin_url=our_service.url))

    request_options = {
        'headers': {'authorization': A_VALID_TOKEN},
    }

    resp_object = client.v1.submitOperation(
        body={'name': 'make_sandwich', 'repeats': 3},
        worker='Mom',
        _request_options=requet_options).result()

    assert resp_object.status == 'whatever'
```

Service tests now double as contract tests with little effort.

### Contract/unit tests
In unit tests (they take less time then service ones): https://github.com/butla/bravado-falcon
Zrobiłem takiego toola.
Dzięki architekturze Bravado każdy może zrobić takiego toola do swojego frameworka,
bo raczej frameworki mają swoje sposoby na testowanie udawanego HTTP.

```python
from bravado.client import SwaggerClient
from bravado_falcon import FalconHttpClient
import yaml
import tests # our tests package

def test_contract_unit(swagger_spec):
    client = SwaggerClient.from_spec(
        swagger_spec,
        http_client=FalconHttpClient(tests.service.api))

    resp_object = client.v1.submitOperation(
        body={'name': 'make_sandwich', 'repeats': 3},
        worker='Mom').result()

    assert resp_object.status == 'whatever'

@pytest.fixture()
def swagger_spec():
    with open('api_spec.yaml') as spec_file:
        return yaml.load(spec_file)
```

Now, with a little effort (test client of your framework can be switched for bravado one)
also unit tests can double as contract tests.
With that you can achieve full coverage of your cotract without making the test suit obnoxiously long.

Nie trzeba duplikować tego samego testu w unit i service testach, wręcz jest to zbędne,
ale to tylko dla przykładu.

## Conclusion
Z tymi narzędziami powinniście sobie dobrze poradzić w rozwijaniu niezależnych serwisów,
projekt powinien iść dobrze i wszystkie teamy powinny móc działać niezależnie nie psując sobie nic nawzajem.
Ale to jeszcze nie zapewnia sukcesu całemu projektowi.

There are more important factors of a success with microservice project that I didn't have
the time to cover:
* end-to-end tests - check for unexpected errors that happen when integrating the entire platform
  in a production-like (or just the production) environment. Those errors will eventually happen.
  That's why they are in the Fowler's testing pyramid.
* performance tests - trzeba trzymać jakiś poziom przepustowości, żeby obsłużyć klientów (to jedno),
  a drugie, że niektóre zmiany mogą drastycznie zmniejszyć performance - trzeba tego pilnować.
  zmiany mogą nieoczeki
* operations automation (deployment, data recovery, service scaling, etc.)
* monitoring of services and infrastructure

## Sources (OK)
Sam Newman. Building Microservices. O'Reilly Media, Inc., February 10, 2015.
Harry J.W. Percival. Test-Driven Development with Python. O'Reilly Media, Inc., June 19, 2014.
martinfowler.com ["Microservice Testing"](http://martinfowler.com/articles/microservice-testing/)
sdtimes.com ["Testing in production comes out of the shadows"](http://sdtimes.com/testing-production-comes-shadows/)
