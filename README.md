# LSTM on FPGA — Accelerometer Sequence Model

A hardware implementation of an **LSTM (Long Short-Term Memory) recurrent neural network cell** on a Xilinx Artix-7 FPGA, built in Verilog with a fixed-point datapath. Tri-axis accelerometer samples are streamed to the board over UART, run through three parallel LSTM cells (one per axis), and the resulting hidden state is streamed back to the host.

The repo also contains a NumPy reference model (used to prototype and train the network) and a Python host script that feeds the CSV dataset to the board over the serial port.

---

## What's here

```
LSTM/
├── LSTM.ipynb              # NumPy LSTM reference model + training (BPTT) on the accelerometer data
├── UART_CSV.py             # Host script: streams accelerometer.csv to the FPGA over UART
├── accelerometer.csv       # Dataset — ~64k rows of tri-axis accelerometer readings (x, y, z)
└── LSTM/                   # Vivado project (target: xc7a100tcsg324-1, Artix-7)
    ├── LSTM.xpr
    └── LSTM.srcs/
        ├── sources_1/new/  # RTL sources (see module reference below)
        ├── sim_1/new/      # Testbenches
        └── constrs_1/new/  # constrains.xdc — pin + clock constraints
```

---

## How it works

### End-to-end data flow

```
 accelerometer.csv                                     FPGA (xc7a100t)
        │                                    ┌──────────────────────────────────────┐
        │  Q8.8 (×256), packed as            │                                        │
        │  9-byte packet over UART           │  uart_rx ─▶ packet_fsm ─▶ lstm_top     │
   UART_CSV.py ──────────────────────────────▶ │                              │        │
   (host, PySerial)                          │                       ┌──────┴──────┐ │
        ▲                                     │                    lstm_cell ×3     │ │
        │   1 byte back (top byte of h_x)     │                   (x / y / z axes)  │ │
        └─────────────────────────────────── uart_tx ◀────── hidden_vector ────────┘ │
                                              │                                        │
                                              └──────────────────────────────────────┘
```

1. **Host** (`UART_CSV.py`) reads each CSV row, converts `x, y, z` to **Q8.8 fixed-point** (multiply by 256, round to int), and packs a 9-byte frame.
2. **`uart_rx`** deserializes bytes; **`packet_fsm`** reassembles them into a signed 48-bit `input_vector = {x, y, z}` and raises `input_ready`.
3. **`lstm_top`** splits the vector into three 16-bit features and runs one **`lstm_cell1`** per axis.
4. Each cell computes the standard LSTM equations (forget / input / output gates, cell-state and hidden-state updates) in fixed-point.
5. **`top_fpga`** sends the top byte of the `h_x` hidden state back over **`uart_tx`** and toggles an LED on each processed packet.

### Fixed-point format — Q8.8

All datapath signals are 16-bit signed in **Q8.8** format: 1 sign bit, 7 integer bits, 8 fractional bits. The scale factor is **256** (`1.0` → `256`, `0.5` → `128`).

- **Multiply** (`fixed_point_multiplier`): 16×16 → 32-bit product, arithmetic-shifted right by 8 to rescale back to Q8.8.
- **Add** (`fixed_point_adder`): plain 16-bit signed addition.
- **Sigmoid** (`sigmoid_activation`): piecewise-linear approximation — `0` below −8, `1` (=256) above +8, and `0.5 + x/8` in between.
- **Tanh** (`tanh_activation`): piecewise-linear — saturates at ±1 (=±256), otherwise the identity `tanh(x) ≈ x`.

---

## RTL module reference

| Module | File | Role |
|---|---|---|
| `top_fpga` | `top_fpga.v` | Top level: wires UART RX → FSM → LSTM → UART TX; drives the LED. |
| `packet_fsm` | `packet_fsm.v` | Parses the 9-byte serial frame into a 48-bit `{x, y, z}` vector. |
| `lstm_top` | `lstm_top.v` | Instantiates three per-axis LSTM cells and packs/unpacks the 48-bit vector. |
| `lstm_cell1` | `lstm_cell1.v` | A single LSTM cell (the one used on-chip). Constant demo weights `W = 0.5`, `B = 0`. |
| `lstm_cell` | `lstm_cell.v` | Earlier/identical copy of the cell (kept for reference). |
| `lstm_gate` | `lstm_gate.v` | Computes `activation(W_x·x + W_h·h + b)` — a multiply-accumulate feeding a sigmoid. |
| `cell_state_update` | `cell_state_update.v` | `c_t = f · c_{t-1} + i · g` |
| `hidden_state_update` | `hidden_state_update.v` | `h_t = o · tanh(c_t)` |
| `fixed_point_multiplier` | `fixed_point_multiplier.v` | Q8.8 signed multiply. |
| `fixed_point_adder` | `fixed_point_adder.v` | 16-bit signed add. |
| `sigmoid_activation` | `sigmoid_activation.v` | Piecewise-linear sigmoid. |
| `tanh_activation` | `tanh_activation.v` | Piecewise-linear tanh. |
| `uart_rx` | `uart_rx.v` | UART receiver (100 MHz clk, 115200 baud, with input synchronizer + framing-error flag). |
| `uart_tx` | `uart_tx.v` | UART transmitter (100 MHz clk, 115200 baud). |

Testbenches live in `LSTM/LSTM.srcs/sim_1/new/` — `tb_lstm_cell1.sv` reads `accelerometer.csv` directly in simulation, converts each row to Q8.8, drives the `lstm_top` DUT, and prints the per-axis hidden outputs.

---

## Serial packet protocol

Each sample is a fixed **9-byte little-endian frame**:

| Byte(s) | Field | Value |
|---|---|---|
| 0 | Header | `0xAA` |
| 1–2 | `x` | signed 16-bit, Q8.8 |
| 3–4 | `y` | signed 16-bit, Q8.8 |
| 5–6 | `z` | signed 16-bit, Q8.8 |
| 7 | (footer, low byte) | — |
| 8 | Footer | `0x55` |

> Packed by the host as `struct.pack('<BhhhB', 0xAA, x, y, z, 0x55)`. The FPGA replies with **one byte** — the most-significant byte of the `h_x` hidden state.

---

## Software

### `LSTM.ipynb` — NumPy reference model

A from-scratch LSTM with:
- **Forward pass**: forget/input/output gates + cell candidate, cell-state and hidden-state updates, and a linear output projection.
- **Backward pass**: truncated (1-step) BPTT with manual gradients and SGD weight updates.
- **Task**: next-timestep prediction on z-score-normalized accelerometer data. Config: `input_size=3`, `hidden_size=50`, `lr=0.001`, 20 epochs, 80/20 train/val split.

This model is the algorithmic reference for the hardware; the saved run reaches a train MSE of ~0.22.

### `UART_CSV.py` — host streamer

Streams the dataset to the board using **PySerial**. Opens the serial port, skips the CSV header, converts each row to Q8.8, sends the 9-byte packet, and prints any byte returned by the FPGA. Adjust the port (`COM8`) and baud rate at the top of the file for your setup.

```bash
pip install pyserial
python UART_CSV.py
```

---

## Building & running

### Simulation (Vivado)
1. Open `LSTM/LSTM.xpr` in Vivado.
2. Set `tb_lstm_cell1` as the simulation top and run behavioral simulation. It reads `accelerometer.csv` from the simulation working directory and prints per-axis outputs.

### Synthesis & hardware
1. Target part is **`xc7a100tcsg324-1`** (Artix-7). The pin-out in `constrains.xdc` — 100 MHz clock on `E3`, UART on `C4`/`D4`, LED on `T8` — matches the Digilent **Nexys A7-100T / Nexys 4 DDR**.
2. Generate the bitstream and program the board.
3. Connect over the USB-UART bridge and run `UART_CSV.py` (matching the port and baud rate) to stream data and watch the LED toggle per packet.

---

## Notes

This is a working proof-of-concept, not a production accelerator. It has known limitations and rough edges, and is intended as a learning and demonstration project rather than something to deploy as-is.
