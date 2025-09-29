import pandas as pd
import matplotlib.pyplot as plt
import numpy as np

# Cargar CSV
df = pd.read_csv("result.csv")

# Valores únicos
functions = sorted(df["Functions"].unique())
threads = sorted(df["Threads"].unique())

# Posiciones para las barras
x = np.arange(len(functions))
width = 0.35

# Crear figura
fig, ax = plt.subplots(figsize=(7, 5))

# Colores y hatch para distinguir threads
colors = ["purple", "orange"]
hatches = ["//", ""]

for i, th in enumerate(threads):
    subset = df[df["Threads"] == th].sort_values("Functions")
    ax.bar(
        x + i*width - width/2,
        subset["Time(µs)"],
        width,
        yerr=subset["StdDev"],
        capsize=4,
        label=f"{th} Thread" if th == 1 else f"{th} Threads",
        color=colors[i],
        hatch=hatches[i],
        edgecolor="black"
    )

# Etiquetas y formato
ax.set_xlabel("# of imports")
ax.set_ylabel("Instantiation time (µs)")

# ticks de X en log base 10 (1, 10, 100, 1000...)
ax.set_xticks(x)
ax.set_xticklabels([f"$10^{int(np.log10(f))}$" for f in functions])

ax.set_ylim(0, max(df["Time(µs)"] + df["StdDev"]) * 1.2)

ax.legend()
ax.grid(axis="y", linestyle="--", alpha=0.6)

plt.tight_layout()
plt.savefig("results.png", dpi=300)
plt.show()
