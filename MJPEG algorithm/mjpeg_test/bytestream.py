import numpy as np
import time

WIDTH = 320
HEIGHT = 240
FRAME_SIZE = WIDTH * HEIGHT

class ByteStreamSimulator:
    def __init__(self):
        self.frame_number = 0
        self.buffer = b""

    def _generate_frame_bytes(self):
        # generate one frame
        x = np.arange(WIDTH)
        frame = (x + self.frame_number) % 256
        frame = np.tile(frame, (HEIGHT, 1)).astype(np.uint8)

        self.frame_number += 1
        return frame.tobytes()

    def read(self, chunk_size=1024):
        # If buffer is low, generate another frame
        if len(self.buffer) < chunk_size:
            self.buffer += self._generate_frame_bytes()

        # Simulate streaming delay (~3 Mbps ≈ 375kB/s)
        time.sleep(chunk_size / 375000)

        chunk = self.buffer[:chunk_size]
        self.buffer = self.buffer[chunk_size:]

        return chunk