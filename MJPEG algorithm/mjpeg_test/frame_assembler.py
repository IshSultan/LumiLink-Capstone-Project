import numpy as np

WIDTH = 320
HEIGHT = 240
FRAME_SIZE = WIDTH * HEIGHT

class FrameAssembler:
    def __init__(self):
        self.buffer = bytearray()

    def push_bytes(self, data):
        self.buffer.extend(data)

    def get_frame(self):
        if len(self.buffer) >= FRAME_SIZE:
            frame_bytes = self.buffer[:FRAME_SIZE]
            self.buffer = self.buffer[FRAME_SIZE:]
            return np.frombuffer(frame_bytes, dtype=np.uint8).reshape((HEIGHT, WIDTH))
        return None