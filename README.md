# ZFT

This project is a Libft tester written in Zig. I chose Zig because it has great C interoperability and I wanted to learn this language.

## Installation Instructions

To install ZFT, run the following command in your terminal:

```bash
curl -sSL https://raw.githubusercontent.com/Caesarovich/zft/refs/heads/main/install.sh | bash
```

If you want to reinstall ZFT and overwrite the existing installation, you can use the `--reinstall` flag:

```bash
curl -sSL https://raw.githubusercontent.com/Caesarovich/zft/refs/heads/main/install.sh | bash -s -- --reinstall
```

This will clone the repository in your Downloads folder and create an alias `zft` in your `.bashrc` file for easy access.

## Usage

After installation, you can run ZFT by simply typing `zft` in your terminal. Make sure to navigate to the directory containing your Libft implementation before running the command.

You can specify the path to your Libft implementation using the `--libft-path` option:

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

### Bonus Tests
To enable bonus tests, use the `--bonus` flag:

```bash
zft --bonus
```