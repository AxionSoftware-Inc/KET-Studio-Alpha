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
# This script demonstrates creating entanglement between two qubits.
import math
import ket_viz

print("--- Step 1: Initialize System ---")
# Each frame shows the state of the qubits at a specific point in time.
frames = [
    {
        "gate": "INIT", 
        "description": "Both qubits start in the |0> state.", 
        "bloch": [{"theta": 0, "phi": 0}, {"theta": 0, "phi": 0}]
    },
    {
        "gate": "H(q0)", 
        "description": "Apply Hadamard to q0 to create superposition: (|0> + |1>)/sqrt(2)", 
        "bloch": [{"theta": math.pi/2, "phi": 0}, {"theta": 0, "phi": 0}]
    },
    {
        "gate": "CNOT(q0, q1)", 
        "description": "Entangle q1 with q0. Final state: (|00> + |11>)/sqrt(2)", 
        "bloch": [{"theta": math.pi/2, "phi": 0}, {"theta": math.pi/2, "phi": 0}]
    }
]

# Send the frames to the Circuit Inspector panel.
ket_viz.inspector("Bell State Evolution", frames)

# Show the predicted measurement results in a histogram.
print("--- Step 2: Final Measurement ---")
results = {"00": 512, "11": 512}
ket_viz.histogram(results, title="Theoretical Probabilities")

print("Visualization data sent successfully.")''',
    ),
    QuantumTemplate(
      id: 'grover_search',
      title: "Grover's Algorithm",
      description: 'Quantum search algorithm showing amplitude amplification.',
      icon: FluentIcons.search_and_apps,
      content: '''# === Grover's Search Algorithm ===
# Locating a target element in an unsorted database.
import math
import time
import ket_viz

print("Initializing Grover's Search for N=8...")

# Simulation of 3 iterations of amplitude amplification.
for i in range(1, 4):
    print(f"Iteration {i} in progress...")
    # Probability of the target state '101' increases each step.
    prob = 0.3 * i
    results = {
        "101": int(1024 * prob), 
        "others": int(1024 * (1-prob)/7)
    }
    # Each iteration update is sent to the Live Viz panel.
    ket_viz.histogram(results, title=f"Grover Iteration {i}")
    time.sleep(0.5)

# Example of a single qubit state during the oracle application.
# The phase of the target state is flipped.
ket_viz.inspector("Oracle Phase Flip", [
    {
        "gate": "Oracle", 
        "description": "Target state marked with negative phase.", 
        "bloch": [{"theta": math.pi/2, "phi": math.pi}]
    }
])
''',
    ),
    QuantumTemplate(
      id: 'vqe_optimization',
      title: "VQE Optimizer",
      description: 'Track energy minimization in real-time with charts.',
      icon: FluentIcons.test_beaker,
      content: '''# === Variational Quantum Eigensolver (VQE) ===
# This script simulates iterative energy minimization and visualizes convergence.
import time
import math
import ket_viz

print("Starting VQE Optimization loop...")

# Initial data for convergence chart
energy_history = []
target_energy = -1.1372
current_energy = 0.5

for i in range(40):
    # Simulated convergence math
    current_energy = target_energy + (abs(target_energy - current_energy) * 0.85)
    energy_history.append(current_energy)
    
    # Send only latest state to avoid flooding
    normalized_chart = [(energy + 2.0)/4.0 for energy in energy_history]
    ket_viz.chart(normalized_chart)
    
    if i % 5 == 0:
        print(f"Iteration {i}: E = {current_energy:.6f} Ha")
    
    time.sleep(0.05)

print(f"Optimization Complete. Ground State: {current_energy:.6f} Ha")
''',
    ),
    QuantumTemplate(
      id: 'qaoa_landscape',
      title: "QAOA Cost Landscape",
      description: '2D Heatmap of the optimization surface.',
      icon: FluentIcons.iot,
      content: '''# === QAOA Landscape Visualization ===
# Visualizing the cost function surface as a heatmap.
import ket_viz

print("Generating 2D optimization landscape...")

# 4x4 sample data representing the cost landscape for different parameters.
landscape = [
    [0.12, 0.45, 0.88, 0.32],
    [0.23, 0.95, 0.41, 0.15],
    [0.78, 0.12, 0.05, 0.67],
    [0.34, 0.21, 0.72, 0.28]
]

# Send the matrix to be rendered as a Heatmap.
ket_viz.heatmap(landscape, title="Cost Function Surface (Beta/Gamma)")

print("Heatmap generated in the Live Viz panel.")''',
    ),
    QuantumTemplate(
      id: 'teleportation_protocol',
      title: "Quantum Teleportation",
      description: 'Send qubit state using entanglement and classical bits.',
      icon: FluentIcons.cell_phone,
      content: '''# === Quantum Teleportation Protocol ===
# Moving a quantum state from Alice to Bob.
import math
import ket_viz

print("Simulating Teleportation protocol...")

# frames define the state evolution of the 3-qubit system.
frames = [
    {
        "gate": "Alice: Init", 
        "description": "Alice prepares the state |psi> to be sent.", 
        "bloch": [{"theta": 1.2, "phi": 0.5}, {"theta": 0, "phi": 0}, {"theta": 0, "phi": 0}]
    },
    {
        "gate": "Bell Pair", 
        "description": "Create entanglement between q1 and q2.", 
        "bloch": [{"theta": 1.2, "phi": 0.5}, {"theta": math.pi/2, "phi": 0}, {"theta": math.pi/2, "phi": 0}]
    },
    {
        "gate": "Teleported!", 
        "description": "State of q0 has been moved to q2 (Bob).", 
        "bloch": [{"theta": 0, "phi": 0}, {"theta": 0, "phi": 0}, {"theta": 1.2, "phi": 0.5}]
    }
]

# Send to Inspector for step-by-step review.
ket_viz.inspector("Teleportation Process", frames)
print("Teleportation complete.")''',
    ),
    QuantumTemplate(
      id: 'error_correction',
      title: "Error Correction (Bit Flip)",
      description: 'Visualization of a 3-qubit bit-flip code.',
      icon: FluentIcons.error_badge,
      content: '''# === 3-Qubit Bit-Flip Code ===
# Protecting a qubit against noise.
import ket_viz

print("Running Noise Simulation...")

# Simulation of measurement outcomes with noise.
# We correctly identify the majority even with errors.
results = {
    "000": 850,  # Correct state
    "100": 50,   # Error on q0
    "010": 60,   # Error on q1
    "001": 64    # Error on q2
}

# The Visualizer handles the resulting probability distribution.
ket_viz.histogram(results, title="Noisy Encoding Results")

ket_viz.text("Status: Error corrected via majority vote on q0, q1, q2.")
print("Simulation finished.")''',
    ),
  ];

  static void useTemplate(QuantumTemplate template) {
    EditorService().openFile("${template.id}.py", template.content);
  }
}
