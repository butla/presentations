import asyncio
import time
import aiohttp

loop = asyncio.get_event_loop()
client = aiohttp.ClientSession(loop=loop)

async def get_site(url: str):
    start_time = time.perf_counter()
    async with client.get(url) as response:
        text = await response.text()
    exec_time = time.perf_counter() - start_time
    print('Fetched', url, 'in', exec_time, 'seconds. Length:', len(text))
    return exec_time

async def main_coroutine():
    start_time = time.perf_counter()
    response_times = await asyncio.gather(
        get_site('http://wp.pl'),
        get_site('http://google.pl'),
        get_site('https://bultrowicz.com'),
        get_site('https://github.com/'),
        get_site('https://www.onet.pl/'),
    )
    print('Fetched all URLs in', time.perf_counter() - start_time, 'seconds.')
    print('Sum of all fetch times:', sum(response_times))


loop.run_until_complete(main_coroutine())
loop.run_until_complete(client.close())
