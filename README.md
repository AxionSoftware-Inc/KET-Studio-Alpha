<p align="center">
  <img src="assets/logo.png" width="140" />
</p>

<h1 align="center">KET Studio</h1>

<p align="center">
  A structured Quantum Development IDE with an Event-Driven Visualization Engine
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Platform-Windows-blue" />
  <img src="https://img.shields.io/badge/Version-v0.2.0--alpha-orange" />
  <img src="https://img.shields.io/badge/License-MIT-green" />
  <img src="https://img.shields.io/badge/Status-Active%20Development-purple" />
</p>

---

## 🚀 Overview

**KET Studio** is a professional native desktop IDE designed for quantum computing research and development. It provides a unified workflow by bridging the gap between raw code execution and high-fidelity visualization.

**The Workflow:**
`Run Script` → `Stream Events` → `Structured Visualization` → `Session History`

---

## ✨ Core Features

### 🧠 Modern IDE Infrastructure
- **Command-Based Architecture**: Business logic is decoupled from the UI for stability.
- **Fluent Design**: A clean, Windows-native interface inspired by modern professional tools.
- **Project Explorer**: Effortless file management and session tracking.

### 📊 Visualization Engine
KET Studio treats visualization as a first-class citizen. Instead of just reading text logs, the IDE renders rich graphical components dynamically.

- **Deterministic States**: `Idle → Running → HasOutput → Error → Stopped`.
- **Event Timeline**: Every visualization event is timestamped and stored in the session history.
- **Multi-Type Rendering**: Support for Bloch spheres, matrices, charts, and dashboards.

---

## 🔬 Visualization System (How it Works)

KET Studio supports three ways to visualize data, making it compatible with both existing code and new research.

### 1. Automatic Interception (No code change)
If your script uses `matplotlib`, KET Studio automatically intercepts `plt.show()`.
- **Works with:** `matplotlib.pyplot`, `qiskit.visualization` (circuit drawings).
- **Benefit:** You don't need to modify your scientific code to see results in the IDE panel.

### 2. The `ket_viz` Helper (Auto-Injected)
When you run a script, KET Studio injects a `ket_viz.py` module into your project directory. You can use it for structured data:

```python
import ket_viz

# Show a high-fidelity heatmap
matrix = [[0.1, 0.5], [0.8, 0.2]]
ket_viz.heatmap(matrix, title="State Density")

# Show a results histogram
counts = {"00": 512, "11": 512}
ket_viz.histogram(counts, title="Bell State Measurement")

# Display professional tables
ket_viz.table("Parameters", [["Qubits", 2], ["Shots", 1024]])
```

### 3. Raw Protocol (For other languages/tools)
The IDE listens to `stdout` for a specific protocol. Any tool can trigger a visualization by printing:
`KET_VIZ {"kind": "text", "payload": {"content": "Hello World"}}`

---

## 📸 Supported Types
- `text`: Rich text logs.
- `table`: Structured data grids.
- `heatmap`: Matrix and density visualizations.
- `image/circuit`: Static drawings and plot captures.
- `dashboard`: Combined quantum state views (Histogram + Matrix).
- `error`: Formatted Python exception displays.

---

## 💾 Installation & Requirements

### Windows (Alpha)
1. Download the latest release ZIP.
2. Extract to a preferred folder.
3. Run `KETStudio.exe`.

### Prerequisites
- **Python 3.10+** (Added to PATH).
- **Recommended Libraries**: `qiskit`, `matplotlib`, `numpy`.

---

## 🛣 Roadmap
- [x] Event-Driven Visualization Engine.
- [x] Session History & Navigation.
- [x] Modern Fluent UI Interface.
- [ ] **Alpha+**: Integrated Dependency Manager (pip auto-setup).
- [ ] **Beta**: Command Palette (Ctrl+Shift+P) & Plugin SDK.

---

## 📜 License
MIT License - Developed for the Quantum Computing Ecosystem.

<p align="center"> Building a stronger Quantum Development Ecosystem. </p>