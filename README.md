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

**KET Studio** is a lightweight native desktop IDE designed to improve the quantum computing ecosystem by providing a structured execution and visualization workflow.

It replaces fragmented tooling with a unified model:

Run → Stream Events → Structured Visualization → Session History

markdown
Copy code

---

## ✨ Core Features

### 🧠 Command-Based Architecture
- Stable Command IDs (`file.save`, `run.start`)
- Centralized Command Registry
- Pure `isEnabled` logic
- Business logic separated from UI
- Reactive state updates

### 📊 Advanced Visualization Panel
- 5-state deterministic state machine  
  `Idle → Running → HasOutput → Error → Stopped`
- Session-based history
- Timestamped event stream
- Structured rendering model

### 🔬 Supported Visualization Types

- `text`
- `table`
- `heatmap`
- `image`
- `chart`
- `dashboard`
- `error`

---

## 📸 Example

```python
import ket_viz
import matplotlib.pyplot as plt

ket_viz.text("Quantum simulation started")

matrix = [[i*j for j in range(10)] for i in range(10)]
ket_viz.heatmap(matrix, title="Interaction Matrix")

plt.plot([1,2,3,4],[1,4,9,16])
ket_viz.plot(plt, name="square.png", title="Square Function")
💾 Installation
Windows (Alpha v0.2.0)
Go to Releases

Download the latest ZIP

Extract and run KETStudio.exe

Requirements
Python 3.10+

Optional: qiskit, matplotlib

🏗 Architecture
nginx
Copy code
UI Layer
   ↓
Command Registry
   ↓
Services
   ↓
KET_VIZ Protocol
   ↓
Visualizer Renderers
Design principles:

Single source of truth

Deterministic rendering

Modular extensibility

Industrial-grade structure

🛣 Roadmap
Alpha
Event Stream Viewer

Session History

Structured Visualization

Welcome Screen + Demo

Beta (Planned)
Command Palette

Context Menus

Optional Dependency Installer

Project Templates

📜 License
MIT License

<p align="center"> Building a stronger Quantum Development Ecosystem. </p> ```