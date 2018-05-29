import asyncio
import time


async def background_work():
    for _ in range(5):
        await asyncio.sleep(0.4)
        print('Working in the background...')

async def foreground_work():
    for _ in range(14):
        await asyncio.sleep(0.25)
        print('Working in the foreground...')

async def main_coroutine_3():
    tasks = [
        loop.create_task(coroutine_1()),
        loop.create_task(coroutine_2()),
        loop.create_task(coroutine_3()),
    ]
    print('waiting in main')
    while not all([task.done() for task in tasks]):
        await asyncio.sleep(0.1)
    print('done waiting in main')

loop = asyncio.get_event_loop()
task = loop.create_task(background_work())
print('Task is done? ->', task.done())
print("Task doesn't start to run until the loop starts when running the foreground task.")
time.sleep(1)
loop.run_until_complete(foreground_work())
print('Task is done? ->', task.done())
