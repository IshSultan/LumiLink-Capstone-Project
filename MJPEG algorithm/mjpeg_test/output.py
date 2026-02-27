class FileOutput:
    def __init__(self, filename):
        self.file = open(filename, "wb")

    def write(self, data):
        self.file.write(data)

    def close(self):
        self.file.close()
"""
SocketOutput class for streaming MJPEG over HTTP
This class sets up a simple HTTP server that listens for incoming connections.
When a client connects, it sends the appropriate HTTP headers for an MJPEG stream

import socket

class SocketOutput:
    def __init__(self, host="0.0.0.0", port=8080):
        server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        server.bind((host, port))
        server.listen(1)
        print("Waiting for client...")
        self.client, _ = server.accept()
        print("Client connected")

        # MJPEG HTTP header
        self.client.sendall(
            b"HTTP/1.0 200 OK\r\n"
            b"Content-Type: multipart/x-mixed-replace; boundary=frame\r\n\r\n"
        )

    def write(self, data):
        self.client.sendall(
            b"--frame\r\n"
            b"Content-Type: image/jpeg\r\n\r\n" +
            data +
            b"\r\n"
        )

    def close(self):
        self.client.close()
"""