# slajd 1
def get_user_info():
    # ...Powiedzmy, że ta funkcja jakoś zdobywa te dane...
    return 'michal.bultrowicz@gmail.com', 'Michał', 'Bultrowicz'

# slajd 2
from typing import Tuple

def get_user_info() -> Tuple[str]:
    # ...Powiedzmy, że ta funkcja jakoś zdobywa te dane...
    return 'michal.bultrowicz@gmail.com', 'Michał', 'Bultrowicz'

# slajd 3
from typing import Tuple

def get_user_info() -> Tuple[str]:
    return 'michal.bultrowicz@gmail.com', 'Michał', 'Bultrowicz'

email, name, surname = get_user_info()
do_thing_1(email, name, surname)
do_thing_2(email, name, surname)

# slajd 4
email, name, surname = get_user_info()
do_thing_1(email, name, surname)
do_thing_2(email, name, surname)

# Wersja alternatywna
def do_thing_1(user_info: Tuple[str]):
    do_inner_thing(user_info[1])
    # ... etc ...

user_info = get_user_info()
do_thing_1(user_info)
do_thing_2(user_info)

# slajd 5
from typing import Dict

def get_user_info() -> Dict[str]:
    return {
        'email': 'michal.bultrowicz@gmail.com',
        'name': 'Michał',
        'surname': 'Bultrowicz',
    }

def do_thing_1(user_info: Dict[str]):
    do_inner_thing(user_info['name'])
# niby fajnie, ale trzeba w obu (potem może w większej liczbie) miejscach pamiętać


# slajd 6
EMAIL_KEY = 'email'
NAME_KEY = 'name'
SURNAME_KEY = 'surname'

def get_user_info() -> Dict[str]:
    return {
        EMAIL_KEY: 'michal.bultrowicz@gmail.com',
        NAME_KEY: 'Michał',
        SURNAME_KEY: 'Bultrowicz',
    }

def do_thing_1(user_info: Dict[str]):
    do_inner_thing(user_info[NAME_KEY])

# slajd 7
# klasycznie, ale pokracznie
class UserInfo:
    def __init__(self, email, name, surname):
        self.email = email
        self.name = name
        self.surname = surname

def get_user_info() -> UserInfo:
    return UserInfo(
        email='michal.bultrowicz@gmail.com',
        name='Michał',
        surname='Bultrowicz',
    )

def do_thing_1(user_info: UserInfo):
    # PyCharm/VIM podpowiada, nawet
    do_inner_thing(user_info.name)

# slajd 8
# W końcu coś ciekawego! (może)
from collections import namedtuple

# zwięźle, ale niestandardowo. Duplikowanie nazwy.
UserInfo = namedtuple('UserInfo', 'email name surname')

def get_user_info() -> UserInfo:
    return UserInfo(
        email='michal.bultrowicz@gmail.com',
        name='Michał',
        surname='Bultrowicz',
    )

def do_thing_1(user_info: UserInfo):
    # PyCharm/VIM nadal podpowiada
    do_inner_thing(user_info.name)

# slajd 9
from typing import NamedTuple # od Pythona 3.5

class UserInfo(NamedTuple):
    email: str
    name: str
    surname: str
    # typy pól, kurwczę!
    # ładnie wygląda

def get_user_info() -> UserInfo:
    # PyCharm podpowiada pola przy konstruktorze
    return UserInfo(
        email='michal.bultrowicz@gmail.com',
        name='Michał',
        surname='Bultrowicz',
    )

def do_thing_1(user_info: UserInfo):
    # PyCharm/VIM nadal podpowiada
    do_inner_thing(user_info.name)


# slajd 10
class UserInfo(NamedTuple):
    email: str
    name: str
    surname: str

import base64, json

# powiedzmy, że chcemy dodać funkcje
def as_base64(self):
    return base64.b64encode(json.dumps(self._asdict()).encode())

# trochę dziwnie (fuck yeah python)
UserInfo.as_base64 = as_base64

user = UserInfo('bla@ble.com', 'Blecjusz', 'Kowalski')
user.as_base64()

# slajd 11
import attr

@attr.s
class UserInfo(NamedTuple):
    email = attr.ib(validator=attr.validators.instance_of(str))
    name = attr.ib(default='')
    surname = attr.ib(default='')

    def as_base64(self):
        return base64.b64encode(json.dumps(self._asdict()).encode())

user = UserInfo('bla@ble.com', 'Blecjusz', 'Kowalski')
user.as_base64()
# tworzenia Pycharm/VIM nie podpowiada, ale dostęp już tak

# slajd 12
# będzie dopiero w Pythonie 3.7
@dataclass
class UserInfo:
    email: str
    name: str
    surname: str

    def as_base64(self):
        return base64.b64encode(json.dumps(asdict(self)).encode())

user = UserInfo('bla@ble.com', 'Blecjusz', 'Kowalski')
user.as_base64()
