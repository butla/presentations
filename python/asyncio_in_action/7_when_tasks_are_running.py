import asyncio
import time


async def backgroud_work():
    print('entering sync sleep')
    time.sleep(2)
    print('entering async sleep')
    await asyncio.sleep(2)
    print('main task done')


async def backgroud_work_secondary():
    await asyncio.sleep(1)
    print('background 1!')


async def backgroud_work_tertiary():
    print("I'm executed until the first await when I'm created . Before that I'm sync.")
    await asyncio.sleep(3)
    print('background 2!')


# don't know the word for fourth in that form
async def backgroud_work_last():
    # I won't be executed, because I wait longer that the main tasks waits synchronously
    # and asynchronously combined!
    await asyncio.sleep(4.5)
    print('background 3!')


l = asyncio.get_event_loop()
l.create_task(backgroud_work_secondary())
l.create_task(backgroud_work_tertiary())

l.run_until_complete(backgroud_work())
print('ended')
time.sleep(2)
print("the last task won't be executed, because execution isn't in the loop anymore.")
