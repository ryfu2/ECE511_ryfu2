import random

# -----------------------
# Configuration
# -----------------------
NUM_WEIGHTS = 32
NUM_SAMPLES = 100
BIT_WIDTH = 8
OUT_WIDTH = 21

random.seed(42)  # remove if you want different results each run

# -----------------------
# Helpers
# -----------------------
def rand_s8():
    return random.randint(-128, 127)

def wrap_signed(val, bits):
    mask = (1 << bits) - 1
    val &= mask
    if val & (1 << (bits - 1)):
        val -= (1 << bits)
    return val

# -----------------------
# Generate data
# -----------------------
weights = [rand_s8() for _ in range(NUM_WEIGHTS)]

inputs = [
    [rand_s8() for _ in range(NUM_WEIGHTS)]
    for _ in range(NUM_SAMPLES)
]

outputs = []
for s in range(NUM_SAMPLES):
    acc = 0
    for i in range(NUM_WEIGHTS):
        acc += weights[i] * inputs[s][i]
    outputs.append(wrap_signed(acc, OUT_WIDTH))

# -----------------------
# Write SystemVerilog
# -----------------------
with open("rom_init.sv", "w") as f:

    f.write("// -----------------------------\n")
    f.write("// Auto-generated ROM contents\n")
    f.write("// -----------------------------\n\n")

    # Declare arrays
    f.write(f"logic signed [{BIT_WIDTH-1}:0] weights [0:{NUM_WEIGHTS-1}];\n")
    f.write(f"logic signed [{BIT_WIDTH-1}:0] inputs [0:{NUM_SAMPLES-1}][0:{NUM_WEIGHTS-1}];\n")
    f.write(f"logic signed [{OUT_WIDTH-1}:0] outputs [0:{NUM_SAMPLES-1}];\n\n")

    f.write("initial begin\n\n")

    # Weights
    f.write("    // Weights\n")
    for i, w in enumerate(weights):
        f.write(f"    weights[{i}] = {w};\n")
    f.write("\n")

    # Inputs
    f.write("    // Inputs\n")
    for s in range(NUM_SAMPLES):
        for i in range(NUM_WEIGHTS):
            val = inputs[s][i]
            f.write(f"    inputs[{s}][{i}] = {val};\n")
    f.write("\n")

    # Outputs
    f.write("    // Outputs\n")
    for s, val in enumerate(outputs):
        f.write(f"    outputs[{s}] = {val};\n")

    f.write("\nend\n")

# -----------------------
# Console preview
# -----------------------
print("Generated rom_init.sv")
print("First 5 weights:", weights[:5])
print("First input sample:", inputs[0])
print("First 5 outputs:", outputs[:5])