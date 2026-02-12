# 🎮 MIPS Game Project

## 📌 Overview
This project is a **MIPS assembly program** that implements a simple game in the **MARS simulator**. The game features a player navigating a **walled environment**, collecting **rewards**, and accumulating **points** while avoiding **collisions with walls**. The game includes a **display** for rendering the environment and **keyboard interaction** for movement.

---

## ✨ Features
✅ **7x7 Grid Environment** with walls (`#`), a player (`P`), and rewards (`R`).  
✅ **Player movement** using `WASD` keys.  
✅ **Score tracking**, with each collected reward adding **+5 points**.  
✅ **Randomly repositioned rewards** after collection.  
✅ **Game ends** when the player reaches **100 points** or collides with a wall.  
✅ **Extended Version:**  
   - 👾 **Enemy Mechanic**: An enemy moves with the player and attempts to block reward collection.

---

## 🔧 Requirements
- 🖥️ **MARS Simulator v4.5** ([Download Here](https://dpetersanderson.github.io/Mars4_5.jar))
- 📜 **MIPS Assembly knowledge**
- 🚫 **No external libraries or unapproved syscalls**

---

## 🛠️ Permitted Syscalls
- 🏗️ **Memory Allocation** (`sbrk`, v0 = 9)  
- ❌ **Exit** (`v0 = 10`)  
- 🎲 **Set PRNG Seed** (`v0 = 41`)  
- 🔢 **Generate Random Integer** (`v0 = 41`)  
- 🔄 **Generate Random Integer in Range** (`v0 = 42`)  

---

## 🚀 Installation & Execution
1️⃣ Download and install **MARS v4.5**.  
2️⃣ Open MARS and **load the provided MIPS assembly file** (`game.asm`).  
3️⃣ Open the **Keyboard and Display MMIO Simulator** under `Tools > Keyboard and Display MMIO Simulator`.  
4️⃣ **Run the program** and use the keyboard to control the player.  

---

## 🎮 Game Controls
🎯 `W` - Move **Up**  
⬅️ `A` - Move **Left**  
⬇️ `S` - Move **Down**  
➡️ `D` - Move **Right**  


🎯 **Good luck and happy coding!** 🚀

