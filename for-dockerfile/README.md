# Dafny-IPM — Interactive Proof Mode Prototype

This environment contains a modified version of **Dafny** that implements the **Interactive Proof Mode (IPM)** extension described in the accompanying research paper.
The virtual machine provides all necessary dependencies and examples for reproducing the experiments.

---

## 1. Directory Structure

The working directory is located at `/app/workdir/` and contains the following files and subdirectories:

```
/app/workdir/
├── dafny-incipm.py        # Main entry point for launching the interactive proof mode
├── smtinc.py              # Backend interface responsible for solver communication and proof state management
├── dafny-ipm.yaml      # Configuration file specifying paths to dafny and boogie DLLs
├── examples/
│   ├── example1.dfy    # First example - case splitting
│   ├── example2.dfy    # Secondary example – nonlinear arithmetic reasoning
│   └── example3.dfy    # Tertiary example – variable shadowing
└── README.md           # This document
```

---

## 2. Running the Interactive Proof Mode

The Interactive Proof Mode can be launched using:

```bash
python /app/workdir/dafny-incipm.py <file>
```

**Recommended demonstration:**

```bash
python /app/workdir/dafny-incipm.py /app/workdir/examples/example1.dfy
```

This runs the proof session for the ITE example referenced in the paper.
For further experimentation, the following example is also available:

```bash
python /app/workdir/dafny-incipm.py /app/workdir/examples/example2.dfy
```

---

## 3. Quick Demonstration

1. Execute:

```bash
   python /app/workdir/dafny-incipm.py /app/workdir/examples/example1.dfy
```

2. Follow the steps described in `example1.dfy` or in the paper.
3. To explore further, repeat with `example2.dfy` or `example3.dfy`.

---

## 4. Reference

This virtual machine accompanies the paper "**Design of an Interactive Proof Mode for Dafny**".
It provides all necessary components to reproduce the examples and experiments described in the publication.

---
