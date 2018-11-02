import asyncio
import time

async def coroutine_1():
    for _ in range(4):
        print('Coroutine 1 working...')
        await asyncio.sleep(0.5)

async def coroutine_2():
    for _ in range(3):
        print('Coroutine 2 working...')
        await asyncio.sleep(0.8)

async def coroutine_3():
    for _ in range(9):
        print('Coroutine 3 working...')
        await asyncio.sleep(0.1)

# Everything is done asynchronously on the loop... but it's done one after another.
async def main_coroutine_1():
    await coroutine_1()
    await coroutine_2()
    await coroutine_3()

# All three coroutines will be running at the same time.
async def main_coroutine_2():
    print('waiting in main')
    await asyncio.gather(
        coroutine_1(),
        coroutine_2(),
        coroutine_3(),
    )
    print('done waiting in main')

loop = asyncio.get_event_loop()
loop.run_until_complete(main_coroutine_1())
print('----------------')
time.sleep(1)
loop.run_until_complete(main_coroutine_2())
