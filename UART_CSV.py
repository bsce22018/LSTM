import serial, struct, csv, time

# Open serial port
ser = serial.Serial('COM8', 115200, timeout=0.1)  # timeout added so it doesn't hang

# Open CSV file
with open('accelerometer.csv') as f:
    reader = csv.reader(f)
    next(reader)  # skip header

    for i, r in enumerate(reader, start=1):
        try:
            # Convert CSV values to fixed-point integers
            x = int(float(r[0]) * 256)
            y = int(float(r[1]) * 256)
            z = int(float(r[2]) * 256)

            # Pack data into a 9-byte packet
            pkt = struct.pack('<BhhhB', 0xAA, x, y, z, 0x55)

            # Send packet
            ser.write(pkt)

            # Show what we sent
            print(f"Packet {i}: x={x}, y={y}, z={z} -> sent {pkt.hex()}")

            # Read FPGA response (if any)
            resp = ser.read(1)
            if resp:
                val = struct.unpack('b', resp)[0]
                print(f"FPGA HX: {val}")
            else:
                print("FPGA HX: no response")

            # Wait a bit before next packet
            time.sleep(0.01)

        except Exception as e:
            print(f"Error on row {i}: {e}")
