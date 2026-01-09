import serial, struct, csv, time

ser = serial.Serial('COM5', 115200)

with open('accelerometer.csv') as f:
    reader = csv.reader(f)
    next(reader)

    for r in reader:
        x = int(float(r[0]) * 256)
        y = int(float(r[1]) * 256)
        z = int(float(r[2]) * 256)

        pkt = struct.pack('<BhhhB', 0xAA, x, y, z, 0x55)
        ser.write(pkt)

        resp = ser.read(1)
        print("FPGA HX:", struct.unpack('b', resp)[0])
        time.sleep(0.01)
