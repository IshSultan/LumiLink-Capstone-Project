#pip install pillow numpy

from PIL import Image
import io

class JPEGEncoder:
    def __init__(self, quality=75):
        self.quality = quality

    def encode(self, frame):
        img = Image.fromarray(frame, mode='L')
        buffer = io.BytesIO()
        img.save(buffer, format="JPEG", quality=self.quality)
        return buffer.getvalue()