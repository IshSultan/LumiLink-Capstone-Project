import numpy as np

WIDTH = 320
HEIGHT = 240

class FrameCapture:
    def __init__(self):
        self.frame_number = 0

    def get_frame(self):
        # Simulated moving gradient
        frame = np.fromfunction(
            lambda y, x: (x + self.frame_number) % 256,
            (HEIGHT, WIDTH),
            dtype=int
        ).astype(np.uint8)
        self.frame_number += 1
        return frame.astype(np.uint8)