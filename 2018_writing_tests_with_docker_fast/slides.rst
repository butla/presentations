Szybkie pisanie (webowych) testów z Dockerem
============================================

Michał Bultrowicz

.. Opowiem jak pomagać sobie (a nie przeszkadzać) w rozwijaniu funkcjonalności aplikacji
.. pisząc testy funkcjonalne.
.. Wielką pomocą w tym zadaniu okazują się Docker i pytest.
.. Nacisk będzie położony na aplikacje webowe,
.. ale podejście może być równie dobre w innych dziedzinach.

.. This will show two things - how I usually approach feature implementation (which I think is
.. an approach some people will benefit from), and how to write Python tests employing real systems,
.. dockerized. Oh and they will be some tricks. So that's three things.

----


Prosta aplikacja - handler
--------------------------

.. code-block:: python

    import json
    from aiohttp import web


    async def hello(request: web.Request):
        name = request.match_info.get('name', 'Señor Incognito')
        return json_response({'greeting': f'Hello, {name}!'})


    # functional programming, yay!
    json_response = partial(
        web.json_response,
        dumps=partial(json.dumps, ensure_ascii=False),
    )

----


Podstawowy test jednostkowy HTTP
--------------------------------

.. code-block:: python

    import pytest
    from awesome_server.server import create_app

    @pytest.fixture
    async def app_client(aiohttp_client):
        app = create_app()
        return await aiohttp_client(app)

    async def test_hello_works(app_client):
        name = 'Wieńczysław'
        response = await app_client.get(f'/{name}')

        assert response.status == 200
        response_json = await response.json()
        assert name in response_json['greeting']

----


Komplikacje! Ficzery!
---------------------

- audyt wszystkich imion z powitań
- nie możemy trzymać w pamięci, bo HA (High Availability)

----


Spike
-----

* ~Prototyp
* Przebicie kolca przez warstwy projektu.
* Musimy zbadać niewiadome, upewnić się, że nasze założenia działają.
* Wziął się z Extreme Programming (XP).

.. We don't know what the code will look like precisely, what'll be it's
.. cyclomatic complexity, how precisely we'll arrange it in functions (OK, here it's simple and without 
.. any if statements, but I'm talking more about the general case now).
.. But we do know how we want the interactions with it to look like. So we can write a high-level,
.. functional (or system, or integrated, or component) test.


----

.. code-block:: bash

     ____________________
    < Demo, Docker, REPL >
     --------------------
            \   ^__^
             \  (oo)\_______
                (__)\       )\/\
                    ||----w |
                    ||     ||

----


.. code-block:: bash

    $ pip install -e \
    git+https://github.com/butla/pytest-docker@b2cacbc#egg=pytest-docker


----

tests/docker-compose.yml
------------------------

.. code-block:: yaml

    ---
    version: '2'
    services:
      api:
        build: ..
        image: awesome_server
        ports:
          - "8080"
        links:
          - database
        environment:
          - REDIS_PORT=6379
          - REDIS_HOST=database

      database:
        image: redis:5.0-alpine
        ports:
          - "6379"

      waiter:
        image: butla/contaiwaiter
        ports:
          - "8080"
        links:
          - api
          - database
        environment:
          - URLS=http://api:8080
          - REDIS_HOSTNAMES=database

----

tests/test_server_functional.py (1)
-----------------------------------

.. code-block:: python

    import pytest, requests, tenacity

    @pytest.fixture(scope='session')
    def docker_services(docker_services):
        waiter_port = docker_services.port_for('waiter', 8080)
        waiter_url = f'http://localhost:{waiter_port}'
        _wait_for_compose(waiter_url)
        return docker_services

    @tenacity.retry(
        stop=tenacity.stop_after_delay(10),
        wait=tenacity.wait_fixed(0.1),
    )
    def _wait_for_compose(app_url: str):
        response = requests.get(app_url)
        response.raise_for_status()

----

tests/test_server_functional.py (2)
-----------------------------------

.. code-block:: python

    def test_names_from_greetings_get_saved(app_url, docker_services):
        names = ['Wieńczysław', 'Spycigniew', 'Perystaltyka']
        for name in names:
            requests.get(f'{app_url}/hello/{name}')

        redis_port = docker_services.port_for('database', 6379)
        redis = Redis(port=redis_port)
        saved_names = redis.lrange('names', 0, -1)
        assert {name.decode() for name in saved_names} == set(names)

----

Updated app code
----

.. code-block:: python

    SAVE_FUNCTION_KEY = 'savorado'

    async def hello(request: web.Request):
        name = request.match_info.get('name', 'Señor Incognito')
        # THIS LINE
        await (request.app[SAVE_FUNCTION_KEY](name))
        return json_response({'greeting': f'Hello, {name}!'})


----


Dopasowania pod testowalność (1)
----

.. code-block:: python

    class AppConfig(typing.NamedTuple):
        port: int
        redis_host: str
        redis_port: int
        names_collection: str = 'names'

    def run_server():
        config = env_var_config.gather_config_for_class(AppConfig)
        redis = aredis.StrictRedis(
            host=config.redis_host,
            port=config.redis_port,
        )
        save_name = partial(redis.lpush, config.names_collection)

        app = create_app(saver=save_name)

----


Dopasowania pod testowalność (2)
----

.. code-block:: python

    @pytest.fixture
    async def app_client(aiohttp_client):
        app = create_app(saver=_fake_save)
        return await aiohttp_client(app)

    async def _fake_save(_):
        pass

----


Żegnaj, okrutny świecie ;(
--------------------------


----


Przydatne zasady testów funkcjonalnych
--------------------------------------

* Nie odwołuj się do kodu produkcyjnego.
* Opcje konfiguracyjne z defaultem do jakichkolwiek sleepów.
* Wbuduj introspekcję w API.
* Wykorzystuj tylko zewnętrzne interfejsy.


----


BONUSY
------

- zbieranie coverage z dockera
