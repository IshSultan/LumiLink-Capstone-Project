from capture import FrameCapture
from encoder import JPEGEncoder
from output import FileOutput  # or SocketOutput
import time

def main():

    capture = FrameCapture()
    encoder = JPEGEncoder(quality=75)
    output = FileOutput("output.mjpeg")
    # output = SocketOutput(port=8080)

    try:
        while True:
            frame = capture.get_frame()
            jpeg_bytes = encoder.encode(frame)
            output.write(jpeg_bytes)

            time.sleep(0.2)  # simulate ~5 FPS

    except KeyboardInterrupt:
        print("Stopping...")

    output.close()

if __name__ == "__main__":
    main()