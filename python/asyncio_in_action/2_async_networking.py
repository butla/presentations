import select
import socket

server = socket.socket()
server.setblocking(False)
server.bind(('localhost', 10000))
server.listen()

inputs = [server]

while True:
    readable, writable, exceptional = select.select(inputs, [], inputs)
    for socket in readable:
        if socket is server:
            connection, address = socket.accept()
            print(address, 'connected...')
            connection.setblocking(False)
            inputs.append(connection)
        else:
            data = socket.recv(666)
            if data:
                print(socket.getpeername(), 'sent data:', data)
            else:
                print(socket.getpeername(), 'has closed')
                inputs.remove(socket)
