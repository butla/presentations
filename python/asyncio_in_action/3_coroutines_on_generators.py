import collections
import itertools
import random
import time

def coroutine_1():
    for _ in range(10):
        print('Coroutine 1 working...')
        yield

def coroutine_2():
    for _ in range(3):
        print('Coroutine 2 working...')
        yield

def coroutine_3():
    for _ in range(7):
        print('Coroutine 3 working...')
        yield

def loop(coroutines):
    to_do = collections.deque(coroutines)
    while to_do:
        time.sleep(0.5)
        coroutine = to_do.popleft()
        try:
            next(coroutine)
            to_do.append(coroutine)
        except StopIteration:
            print('coroutine finished')

loop([
    coroutine_1(),
    coroutine_2(),
    coroutine_3(),
])
