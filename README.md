# ⚡ ZFT

This project is a Libft tester written in [Zig](https://ziglang.org/). I chose Zig because it has great C interoperability and I wanted to learn this language.

## 💿 Installation Instructions

To **install** ZFT, run the following command in your terminal:

```bash
curl -sSL https://raw.githubusercontent.com/Caesarovich/zft/refs/heads/main/install.sh | bash
```

If you want to **reinstall** ZFT and overwrite the existing installation, you can use the `--reinstall` flag:

```bash
curl -sSL https://raw.githubusercontent.com/Caesarovich/zft/refs/heads/main/install.sh | bash -s -- --reinstall
```

The script will clone the repository in your Downloads folder and create an alias `zft` in your shell configuration file (`.bashrc`, `.zshrc`, or `config.fish` depending on your shell).

> **Note:** You may need to restart your terminal or run `source ~/.bashrc`, `source ~/.zshrc`, or `source config.fish` to apply the changes.

## ▶️ Usage

After installation, you can run ZFT by simply typing `zft` in your terminal. Make sure to navigate to the directory containing your Libft implementation before running the command.

```bash
# In your Libft directory
zft
```

You can also specify a custom path:

```bash
zft /path/to/your/libft

zft ../path/to/your/libft

zft .
```

### ✴️ Bonus Tests
To enable bonus tests, use the `--bonus` flag:

```bash
zft --bonus
```

### 🛡️ Valgrind
To run tests with Valgrind, use the `--valgrind` flag:

```bash
zft --valgrind
```

> **Note:** Tests will run slower when using Valgrind. 

## 📜 License
This project is licensed under the **GPL-3.0** License. See the [LICENSE](LICENSE) file for details.