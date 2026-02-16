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
      id: 'bell_state',
      title: 'Bell State',
      description:
          'The simplest case of quantum entanglement between two qubits.',
      icon: FluentIcons.link,
      content: '''import ket_viz
import time

print("Creating Bell State: 1/sqrt(2) * (|00> + |11>)")
time.sleep(0.5)

# Simulate results
counts = {"00": 512, "11": 512, "01": 0, "10": 0}
ket_viz.histogram(counts, title="Bell State Measurement")

print("Entanglement confirmed.")''',
    ),
    QuantumTemplate(
      id: 'grover',
      title: "Grover's Algorithm",
      description:
          'Quantum search algorithm for unstructured databases with O(sqrt(N)) speedup.',
      icon: FluentIcons.search_and_apps,
      content: '''import ket_viz
import math

print("Running Grover's Search for target state |101>...")

# Simulation of Grover iterations
for i in range(1, 4):
    print(f"Iteration {i} complete...")
    # Mocking the amplification effect
    prob = 0.3 * i
    results = {"101": int(1024 * prob), "others": int(1024 * (1-prob)/7)}
    ket_viz.histogram(results, title=f"Grover Iteration {i}")

print("Target state amplification reached 90% accuracy.")''',
    ),
    QuantumTemplate(
      id: 'noise_demo',
      title: "Noise Simulation",
      description:
          'Simulate quantum decoherence and gate errors (T1/T2 relaxation).',
      icon: FluentIcons.error_badge,
      content: '''import ket_viz
import random

print("Simulating Quantum Noise (T1 bit-flip error)...")

# Creating a noisy GHZ state
shots = 1024
results = {"000": 0, "111": 0, "error": 0}

for _ in range(shots):
    val = random.random()
    if val < 0.45: results["000"] += 1
    elif val < 0.90: results["111"] += 1
    else: results["error"] += 1

ket_viz.histogram(results, title="Noisy GHZ State Output")
print("Decoherence detected in 10% of operations.")''',
    ),
    QuantumTemplate(
      id: 'vqe',
      title: "VQE (Ground State)",
      description:
          'Hybrid quantum-classical algorithm to find the lowest eigenvalue of a Hamiltonian.',
      icon: FluentIcons.test_beaker,
      content: '''import ket_viz
import time

print("VQE Energy Minimization for H2 Molecule...")

energies = []
for i in range(20):
    energy = -1.13 + (1.0/(i+1))
    energies.append(energy)
    print(f"Step {i}: Energy = {energy:.4f} Ha")
    
    # Send intermediate results to Dashboard
    ket_viz.text(f"Convergence Step {i}: {energy:.4f}")

# Final result
ket_viz.text("Optimized Ground State Energy: -1.136 Ha")
print("VQE successfully converged.")''',
    ),
    QuantumTemplate(
      id: 'qaoa',
      title: "QAOA (Max-Cut)",
      description:
          'Quantum Approximate Optimization Algorithm for combinatorial problems.',
      icon: FluentIcons.iot,
      content: '''import ket_viz

print("Solving Max-Cut problem using QAOA...")

# Mocking the cost function heatmap
matrix = [
    [0.1, 0.2, 0.8, 0.3],
    [0.2, 0.9, 0.1, 0.1],
    [0.8, 0.1, 0.0, 0.7],
    [0.3, 0.1, 0.7, 0.2]
]

ket_viz.heatmap(matrix, title="QAOA Cost Function Landscape")
print("Found optimal partition with cost 4.")''',
    ),
  ];

  static void useTemplate(QuantumTemplate template) {
    EditorService().openFile("${template.id}.py", template.content);
  }
}
