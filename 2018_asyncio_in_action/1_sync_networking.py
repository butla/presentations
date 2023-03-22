import socket

server = socket.socket()
server.bind(('localhost', 10000))
server.listen()

while True:
    socket, address = server.accept()
    print(address, 'connected...')
    while True:
        data = socket.recv(666)
        if data:
            print(socket.getpeername(), 'sent data:', data)
        else:
            print(socket.getpeername(), 'has closed')
            break
