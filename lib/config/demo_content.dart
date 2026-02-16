class DemoContent {
  static const String welcomeTitle = "Welcome to KET Studio";
  static const String welcomeSubtitle = "Professional Quantum Programming IDE";

  static const String demoScript = """
# KET Studio Demo Script
# This script showcases various visualization capabilities

import math
import json
import time

def ket_viz(kind, payload):
    # Standard KET_VIZ protocol
    print(f"KET_VIZ: {json.dumps({'kind': kind, 'payload': payload})}")

print("Launching KET Studio Quantum Demo...")
time.sleep(1)

# 1. Show Dashboard (Histogram + Matrix)
ket_viz("dashboard", {
    "histogram": {
        "|00>": 450,
        "|01>": 52,
        "|10>": 48,
        "|11>": 450
    },
    "matrix": {
        "0,0": 0.707, "0,1": 0.0, "0,2": 0.0, "0,3": 0.707,
        "1,0": 0.0, "1,1": 0.0, "1,2": 0.0, "1,3": 0.0,
        "2,0": 0.0, "2,1": 0.0, "2,2": 0.0, "2,3": 0.0,
        "3,0": 0.707, "3,1": 0.0, "3,2": 0.0, "3,3": -0.707
    }
})
time.sleep(1)

# 2. Show Bloch Sphere
ket_viz("bloch", {"theta": math.pi/4, "phi": math.pi/2})
time.sleep(1)

# 3. Show a Table
ket_viz("table", {
    "title": "Quantum States Analysis",
    "rows": [
        ["State", "Amplitude", "Probability", "Phase"],
        ["|00>", "0.707", "50%", "0.0"],
        ["|11>", "0.707", "50%", "π"]
    ]
})
time.sleep(1)

# 4. Show a Heatmap
ket_viz("heatmap", {
    "title": "Entanglement Density",
    "data": [
        [1.0, 0.2, 0.1, 0.8],
        [0.2, 0.1, 0.0, 0.2],
        [0.1, 0.0, 0.3, 0.1],
        [0.8, 0.2, 0.1, 1.0]
    ]
})

print("Demo execution finished successfully.")
""";
}
