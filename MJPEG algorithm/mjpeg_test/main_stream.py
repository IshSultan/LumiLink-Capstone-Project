from bytestream import ByteStreamSimulator
from frame_assembler import FrameAssembler
from encoder import JPEGEncoder
from output import FileOutput

def main():

    stream = ByteStreamSimulator()
    assembler = FrameAssembler()
    encoder = JPEGEncoder(quality=75)
    output = FileOutput("output.mjpeg")

    try:
        while True:

            # read arbitrary chunk
            data = stream.read(1024)

            # push into frame assembler
            assembler.push_bytes(data)

            # check if full frame available
            frame = assembler.get_frame()
            if frame is not None:
                jpeg_bytes = encoder.encode(frame)
                output.write(jpeg_bytes)

    except KeyboardInterrupt:
        print("Stopping...")

    output.close()

if __name__ == "__main__":
    main()