import 'package:fluent_ui/fluent_ui.dart';
import '../../core/services/editor_service.dart';

class QuantumTemplate {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final String content;

  QuantumTemplate({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.content,
  });
}

class TemplateService {
  static final List<QuantumTemplate> templates = [
    QuantumTemplate(
      id: 'bell_state_demo',
      title: 'Bell State (Entanglement)',
      description: 'The fundamental example of quantum entanglement.',
      icon: FluentIcons.reading_mode,
      content: '''# === Bell State Preparation ===
# This script demonstrates creating entanglement between İwo qubits.
import math
import ket_viz

print("--- Step 1: Initialize System ---")
frames = [
    {
        "gate": "INIT", 
        "description": "Both qubits start in the |0> state.", 
        "bloch": [{"theta": 0, "phi": 0}, {"theta": 0, "phi": 0}]
    },
    {
        "gate": "H(q0)", 
        "description": "Apply Hadamard to q0: (|0> + |1>)/sqrt(2)", 
        "bloch": [{"theta": math.pi/2, "phi": 0}, {"theta": 0, "phi": 0}]
    },
    {
        "gate": "CNOT(q0, q1)", 
        "description": "Entangle q1 with q0. Final state: (|00> + |11>)/sqrt(2)", 
        "bloch": [{"theta": math.pi/2, "phi": 0}, {"theta": math.pi/2, "phi": 0}]
    }
]

ket_viz.inspector("Bell State Evolution", frames)

print("--- Step 2: Final Measurement ---")
results = {"00": 512, "11": 512}
ket_viz.histogram(results, title="Theoretical Probabilities")

ket_viz.metrics({
    "qubits": 2,
    "shots": 1024,
    "depth": 3,
    "backend": "AerSimulator",
    "runtime": "12ms"
})

print("Simulation finished.")
''',
    ),
    QuantumTemplate(
      id: 'vqe_optimizer',
      title: "VQE Optimizer",
      description: 'Track energy minimization in real-time with charts.',
      icon: FluentIcons.test_beaker,
      content: '''# === Variational Quantum Eigensolver (VQE) ===
import time
import math
import ket_viz

print("Starting VQE Optimization loop...")

energy_history = []
target_energy = -1.1372
current_energy = 0.5

for i in range(40):
    current_energy = target_energy + (abs(target_energy - current_energy) * 0.85)
    energy_history.append(current_energy)
    
    # Live chart update
    normalized_chart = [(energy + 2.0)/4.0 for energy in energy_history]
    ket_viz.chart(normalized_chart)
    
    if i % 5 == 0:
        print(f"Iteration {i}: E = {current_energy:.6f} Ha")
    time.sleep(0.05)

ket_viz.metrics({
    "qubits": 4,
    "shots": 2048,
    "depth": 142,
    "backend": "VQE-Solver-Native",
    "optimizer": "COBYLA",
    "runtime": "840ms"
})

print(f"Ground State: {current_energy:.6f} Ha")
''',
    ),
    QuantumTemplate(
      id: 'grover_search',
      title: "Grover's Algorithm",
      description: 'Quantum search algorithm showing amplitude amplification.',
      icon: FluentIcons.search_and_apps,
      content: '''# === Grover's Search Algorithm ===
import math
import time
import ket_viz

print("Initializing Grover's Search for N=8...")

for i in range(1, 4):
    prob = 0.3 * i
    results = {"101": int(1024 * prob), "others": int(1024 * (1-prob)/7)}
    ket_viz.histogram(results, title=f"Grover Iteration {i}")
    time.sleep(0.5)

ket_viz.metrics({
    "qubits": 3,
    "shots": 1024,
    "iterations": 2,
    "target": "101",
    "backend": "Simulator-Grover-Enhanced"
})
''',
    ),
    QuantumTemplate(
      id: 'qaoa_landscape',
      title: "QAOA Cost Landscape",
      description: '2D Heatmap of the optimization surface.',
      icon: FluentIcons.iot,
      content: '''# === QAOA Landscape Visualization ===
import ket_viz

landscape = [
    [0.12, 0.45, 0.88, 0.32],
    [0.23, 0.95, 0.41, 0.15],
    [0.78, 0.12, 0.05, 0.67],
    [0.34, 0.21, 0.72, 0.28]
]

ket_viz.heatmap(landscape, title="Cost Surface")

ket_viz.metrics({
    "qubits": 6,
    "grid": "4x4",
    "surface": "QAOA-MaxCut",
    "backend": "Surface-Mapper-Pro"
})
''',
    ),
    QuantumTemplate(
      id: 'teleportation_protocol',
      title: "Quantum Teleportation",
      description: 'Send qubit state using entanglement.',
      icon: FluentIcons.cell_phone,
      content: '''# === Quantum Teleportation Protocol ===
import math
import ket_viz

frames = [
    {"gate": "Alice: Init", "bloch": [{"theta": 1.2, "phi": 0.5}, {"theta": 0, "phi": 0}, {"theta": 0, "phi": 0}]},
    {"gate": "Bell Pair", "bloch": [{"theta": 1.2, "phi": 0.5}, {"theta": math.pi/2, "phi": 0}, {"theta": math.pi/2, "phi": 0}]},
    {"gate": "Teleported!", "bloch": [{"theta": 0, "phi": 0}, {"theta": 0, "phi": 0}, {"theta": 1.2, "phi": 0.5}]}
]

ket_viz.inspector("Teleportation", frames)

ket_viz.metrics({
    "qubits": 3,
    "fidelity": 1.0,
    "protocol": "Standard",
    "backend": "Ideal-Quantum-Switch"
})
''',
    ),
    QuantumTemplate(
      id: 'error_correction',
      title: "Error Correction",
      description: '3-qubit bit-flip code simulation.',
      icon: FluentIcons.error_badge,
      content: '''# === 3-Qubit Bit-Flip Code ===
import ket_viz

results = {"000": 850, "100": 50, "010": 60, "001": 64}
ket_viz.histogram(results, title="Noisy Encoding")

ket_viz.metrics({
    "qubits": 3,
    "code": "Bit-flip [3,1,1]",
    "noise": "Depolarizing (0.05)",
    "success": "95.2%"
})

ket_viz.text("Status: Error corrected via majority vote.")
''',
    ),
    QuantumTemplate(
      id: 'qft_transform',
      title: "Quantum Fourier Transform",
      description: 'Rotation phases of the QFT.',
      icon: FluentIcons.music_note,
      content: '''# === Quantum Fourier Transform (QFT) ===
import math
import ket_viz

frames = [
    {"gate": "Input: |111>", "bloch": [{"theta": math.pi, "phi": 0}, {"theta": math.pi, "phi": 0}, {"theta": math.pi, "phi": 0}]},
    {"gate": "After QFT", "bloch": [{"theta": math.pi/2, "phi": math.pi/4}, {"theta": math.pi/2, "phi": math.pi/2}, {"theta": math.pi/2, "phi": math.pi}]}
]

ket_viz.inspector("QFT Phases", frames)

ket_viz.metrics({
    "qubits": 3,
    "complexity": "O(n^2)",
    "basis": "Fourier",
    "backend": "Matrix-Phaser"
})
''',
    ),
  ];

  static void useTemplate(QuantumTemplate template) {
    EditorService().openFile("${template.id}.py", template.content);
  }
}
