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

ZFT runs all three subject parts: libc functions, additional functions, and linked-list functions.

### Speculative tests

Speculative tests are disabled by default. They check behavior that the subject does
not definitively require, primarily how functions handle `NULL` arguments or other
invalid inputs. Some implementations choose to guard these inputs while others
allow undefined behavior, so these tests reflect personal judgment and are not
definitive grading requirements. It is up to YOU to decide whether to enable them
and be able to defend your implementation's behavior during the defense.

Enable speculative tests with the `--speculative` flag:

```bash
zft --speculative
```

### 🛡️ Valgrind
To run tests with Valgrind, use the `--valgrind` flag:

```bash
zft --valgrind
```

> **Note:** Tests will run slower when using Valgrind. 

## 📜 License
This project is licensed under the **GPL-3.0** License. See the [LICENSE](LICENSE) file for details.