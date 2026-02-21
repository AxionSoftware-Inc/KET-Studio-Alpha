class TutorialSection {
  final String title;
  final String content;
  final String? codeSnippet;

  TutorialSection({
    required this.title,
    required this.content,
    this.codeSnippet,
  });
}

class Tutorial {
  final String id;
  final String title;
  final String description;
  final List<TutorialSection> sections;

  Tutorial({
    required this.id,
    required this.title,
    required this.description,
    required this.sections,
  });
}

final List<Tutorial> quantumTutorials = [
  Tutorial(
    id: 'qiskit_basics',
    title: 'Qiskit Asoslari',
    description: 'Quantum davrlarini yaratish va simulyatsiya qilish.',
    sections: [
      TutorialSection(
        title: 'Quantum Circuit yaratish',
        content:
            'Qiskit-da eng asosiy element bu `QuantumCircuit` obyekti hisoblanadi.',
        codeSnippet: '''from qiskit import QuantumCircuit

# 2 ta qubit va 2 ta klassik bitli davra
qc = QuantumCircuit(2, 2)
qc.h(0) # Hadamard darvozasi
qc.cx(0, 1) # CNOT darvozasi
qc.measure([0,1], [0,1])

print(qc.draw())''',
      ),
      TutorialSection(
        title: 'Backend-da ishlatish',
        content:
            'Natijalarni olish uchun simulyator yoki real apparatni tanlash kerak.',
        codeSnippet: '''from qiskit_aer import AerSimulator
from qiskit import transpile

simulator = AerSimulator()
compiled_circuit = transpile(qc, simulator)
job = simulator.run(compiled_circuit, shots=1024)
result = job.result()
counts = result.get_counts()
print(counts)''',
      ),
    ],
  ),
  Tutorial(
    id: 'quantum_states',
    title: 'Quantum Holatlar va Matematika',
    description: 'Bra-ket notatsiyasi va superpozitsiya.',
    sections: [
      TutorialSection(
        title: 'Superpozitsiya',
        content:
            r"Quantum holati qubitning $\alpha|0\rangle + \beta|1\rangle$ ko'rinishidagi kombinatsiyasidir. Bunda $|\alpha|^2 + |\beta|^2 = 1$.",
      ),
      TutorialSection(
        title: 'Hadamard Matrix',
        content:
            r"Hadamard darvozasi holatni superpozitsiyaga o'tkazadi: $H = \frac{1}{\sqrt{2}} \begin{pmatrix} 1 & 1 \\ 1 & -1 \end{pmatrix}$",
        codeSnippet: '''# Hadamard darvozasini qo'llash
qc.h(0)''',
      ),
      TutorialSection(
        title: 'Bloch Sphere',
        content:
            "Har bir qubit holatini 3 o'lchamli sferadagi nuqta sifatida tasvirlash mumkin.",
      ),
    ],
  ),
  Tutorial(
    id: 'grover_summary',
    title: 'Grover Algoritmi',
    description: "Strukturasiz ma'lumotlar bazasidan qidirish.",
    sections: [
      TutorialSection(
        title: 'Oracle va Difuziya',
        content:
            r"Grover algoritmi ikki asosiy qismdan iborat: Oracle (qidirilayotgan holatni belgilash) va Diffusion operator (amplituda invertsiyasi).",
      ),
      TutorialSection(
        title: 'Amplituda Kuchaytirish',
        content: r"Iteratsiyalar soni taxminan $O(\sqrt{N})$ ni tashkil etadi.",
        codeSnippet: '''from qiskit.circuit.library import GroverOperator
# Grover operatorini yaratish
# oracle = ...
# grover_op = GroverOperator(oracle)''',
      ),
    ],
  ),
];
