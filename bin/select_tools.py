#!/usr/bin/env python3
# /// script
# requires-python = ">=3.13"
# dependencies = [
#     "InquirerPy",
#     "rich",
#     # "icecream",
#     # "ipdb",
# ]
# ///

# Minimal, dependency-friendly bootstrapper script for interactive tool selection & install
# - Falls back to `uv run --script` if third-party imports are missing
# - Detects popular package managers (brew, apt-get, dnf, yum, pacman, zypper)
# - Always performs a preflight check (already installed vs. to be installed)
# - Lets the user change the selection after preflight
# - Installs only the outstanding tools

import os
import sys
import json
import shutil
import subprocess
import shlex

# Attempt to import third-party deps. If missing, try to re-exec with `uv run --script`.
try:
    from InquirerPy import inquirer
    from InquirerPy.base.control import Choice
    from rich.console import Console
    from rich.panel import Panel
    from rich.table import Table
    from rich.text import Text
except ModuleNotFoundError:
    # If uv is available, re-exec this script via uv so it can resolve deps from the header.
    if shutil.which("uv"):
        os.execvp("uv", ["uv", "run", "--script", __file__, *sys.argv[1:]])

    # uv not found: ask user whether to run the official installer via curl
    print("Missing dependencies (InquirerPy / rich) and uv is not installed.", file=sys.stderr)
    try:
        choice = input("uv is required. Do you want to install it now via the official installer? [Y/n]: ").strip().lower()
    except KeyboardInterrupt:
        print("\nCancelled.")
        sys.exit(1)

    if choice in ("", "y", "yes"):
        try:
            # Run official installer
            subprocess.run(
                ["sh", "-c", "curl -LsSf https://astral.sh/uv/install.sh | sh"],
                check=True,
            )
        except subprocess.CalledProcessError as e:
            print(f"Failed to run uv installer: {e}", file=sys.stderr)
            sys.exit(1)

        # After install, try to re-exec with uv
        if shutil.which("uv"):
            os.execvp("uv", ["uv", "run", "--script", __file__, *sys.argv[1:]])
        else:
            print("uv installation did not succeed. Please install it manually.", file=sys.stderr)
            sys.exit(1)

    print("uv is required. Installation was declined. Exiting.", file=sys.stderr)
    sys.exit(1)

# from icecream import ic  # Uncomment for debug printing
# import ipdb  # Uncomment for interactive debugging

console = Console()


def detect_system_package_manager():
    """Detect a supported system package manager and return a command template root.

    For system-level installs we prefix with sudo where appropriate so that the
    sudo preflight can validate credentials once, upfront.
    """
    mgr = None
    if shutil.which("brew"):
        # Homebrew (macOS)
        mgr = "brew"
    elif shutil.which("apt-get"):
        # Debian/Ubuntu
        mgr = "sudo apt-get -y"
    elif shutil.which("dnf"):
        # Fedora/RHEL newer
        mgr = "sudo dnf -y"
    elif shutil.which("yum"):
        # Older RHEL/CentOS
        mgr = "sudo yum -y"
    elif shutil.which("pacman"):
        # Arch Linux
        mgr = "sudo pacman -S --noconfirm"
    elif shutil.which("zypper"):
        # openSUSE
        mgr = "sudo zypper -n"
    else:
        print("No supported system package manager found (brew, apt-get, dnf, yum, pacman, zypper). Exiting.")
        sys.exit(1)
    return mgr


def load_tool_definitions():
    """Load tool definitions from apps.json located next to this script."""
    tool_data = None
    script_dir = os.path.dirname(os.path.realpath(__file__))
    json_path = os.path.join(script_dir, "apps.json")
    try:
        with open(json_path) as f:
            tool_data = json.load(f)
    except FileNotFoundError:
        print(f"Apps definition file not found: {json_path}")
        sys.exit(1)
    return tool_data


def ensure_sudo_if_needed(pkg_mgr: str):
    """If pkg_mgr string contains 'sudo', request sudo once upfront so we fail early."""
    if "sudo" in pkg_mgr:
        print("Requesting sudo privileges once to proceed with package installation...")
        try:
            subprocess.run(["sudo", "-v"], check=True)
        except subprocess.CalledProcessError:
            print("Unable to acquire sudo privileges. Exiting.")
            sys.exit(1)


def ensure_rustup_and_binstall():
    """Ensure rustup/cargo are available; if not, offer to install via official installer.

    This runs *before* any selection, so later tools relying on cargo are available.
    """
    def _prepend_cargo_bin_to_path():
        cargo_bin = os.path.expanduser("~/.cargo/bin")
        current = os.environ.get("PATH", "")
        if cargo_bin and cargo_bin not in current.split(":"):
            os.environ["PATH"] = f"{cargo_bin}:{current}" if current else cargo_bin

    rustup_path = shutil.which("rustup")
    cargo_path = shutil.which("cargo")

    # If either rustup or cargo is missing, offer installation
    if not rustup_path or not cargo_path:
        try:
            confirm = inquirer.confirm(
                message=(
                    "Rust toolchain not fully available (rustup/cargo).\n"
                    "Do you want to install rustup now via the official installer?"
                ),
                default=True,
            ).execute()
        except KeyboardInterrupt:
            print("\nOperation cancelled by user. Exiting.")
            sys.exit(0)

        if not confirm:
            print("Rust toolchain installation skipped by user. Continuing without rust.")
            # Still try to make cargo available if a prior install exists but PATH is missing
            _prepend_cargo_bin_to_path()
            return

        try:
            # Run official rustup installer
            subprocess.run(
                ["sh", "-c", "curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y"],
                check=True,
            )
        except subprocess.CalledProcessError as e:
            print(f"Failed to run rustup installer: {e}")
            sys.exit(1)

        # Ensure current process PATH can find cargo/rustup without requiring a new shell
        _prepend_cargo_bin_to_path()
        # Sanity re-check
        if not shutil.which("cargo") or not shutil.which("rustup"):
            print("rustup/cargo not found after installation. Please open a new shell or source ~/.cargo/env.")
            # Attempt soft source by reading ~/.cargo/env for PATH only
            cargo_env = os.path.expanduser("~/.cargo/env")
            if os.path.exists(cargo_env):
                try:
                    # Best-effort: extract PATH line and update env
                    with open(cargo_env, "r") as f:
                        for line in f:
                            line = line.strip()
                            if line.startswith("export PATH="):
                                # naive eval of PATH export: export PATH="$HOME/.cargo/bin:$PATH"
                                val = line.split("=", 1)[1].strip().strip('"')
                                val = val.replace("$HOME", os.path.expanduser("~")).replace("${HOME}", os.path.expanduser("~")).replace("$PATH", os.environ.get("PATH", ""))
                                os.environ["PATH"] = val
                                break
                except Exception:
                    pass
        # Final re-check
        if not shutil.which("cargo"):
            print("cargo still not available. Continuing, but cargo-based installs may fail.")

    # Ensure cargo-binstall is available (optional helper)
    _prepend_cargo_bin_to_path()
    if not shutil.which("cargo-binstall"):
        try:
            print("Installing cargo-binstall (binary installer) ...")
            subprocess.run(["cargo", "install", "cargo-binstall"], check=True)
        except FileNotFoundError:
            print("cargo not found; cannot install cargo-binstall. Skipping.")
        except subprocess.CalledProcessError as e:
            print(f"Failed to install cargo-binstall: {e}")


def ensure_npm_if_needed(selected, name_to_app):
    """If the selection includes npm tools but npm is not available, guide the user.

    If `fnm` is available, offer to install a Node LTS (example: 24) and then restart this script.
    If `fnm` is not available, show instructions and exit.
    """
    # Determine whether any selected tool belongs to the npm category
    needs_npm = False
    for _name in selected:
        meta = name_to_app.get(_name)
        if meta and meta.get("category") == "npm":
            needs_npm = True
            break

    if not needs_npm:
        return  # nothing to do

    if shutil.which("npm"):
        return  # npm available, proceed as usual

    # npm missing
    if shutil.which("fnm"):
        console.print(Panel.fit(
            "npm is not available, but fnm was found.\n"
            "I can install a Node version now (e.g., 24) so npm becomes available,\n"
            "then restart this script.",
            title="Node.js required",
            style="yellow"
        ))
        try:
            do_install = inquirer.confirm(
                message="Install Node 24 via fnm now and restart?",
                default=True,
            ).execute()
        except KeyboardInterrupt:
            print("\nOperation cancelled by user. Exiting.")
            sys.exit(0)

        if not do_install:
            console.print("[red]npm is required for selected tools. Exiting.[/red]")
            sys.exit(1)

        try:
            # Install and activate Node 24 for the current shell session
            subprocess.run(["sh", "-c", "fnm install 24 && fnm use 24"], check=True)
        except subprocess.CalledProcessError as e:
            console.print(f"[red]Failed to install/use Node via fnm: {e}[/red]")
            sys.exit(1)

        # Try to restart this script so the new npm is picked up
        if shutil.which("uv"):
            os.execvp("uv", ["uv", "run", "--script", __file__, *sys.argv[1:]])
        else:
            os.execv(sys.executable, [sys.executable, __file__, *sys.argv[1:]])

    # fnm not found -> instruct and exit
    console.print(Panel.fit(
        "npm is not available and fnm is not installed.\n"
        "Please install fnm, then run:\n\n  fnm install 24\n  fnm use 24\n\nThen start this script again.",
        title="Node.js required",
        style="red"
    ))
    sys.exit(1)


# Detect system package manager early and request sudo once if needed
pkg_mgr = detect_system_package_manager()
ensure_sudo_if_needed(pkg_mgr)

# Load tool definitions
data = load_tool_definitions()

# Ensure rustup/cargo (and cargo-binstall) are available before selection
ensure_rustup_and_binstall()

# Build default selection once (names only)
default_selection = []
for category, info in data.items():
    for app in info.get("apps", []):
        if app.get("default", False):
            default_selection.append(app.get("name"))

# --- Selection loop: select -> preflight -> optional change ---
while True:
    # Ask for default vs custom
    try:
        mode = inquirer.select(
            message="Do you want to continue, installing default tools?",
            choices=[
                {"name": "YES", "value": "yes"},
                {"name": "NO - customize selection", "value": "no"},
            ],
            default="yes",
        ).execute()
    except KeyboardInterrupt:
        print("\nOperation cancelled by user. Exiting.")
        sys.exit(0)

    # Determine selection
    if mode == "yes":
        selected = list(default_selection)
    else:
        # custom selection per category
        selected = []
        for category, info in data.items():
            opts = []
            # build choices for this category with aligned names
            max_len = 0
            for app in info.get("apps", []):
                nm = app.get("name", "") or ""
                if len(nm) > max_len:
                    max_len = len(nm)

            for app in info.get("apps", []):
                name = app.get("name")
                desc = app.get("desc")
                enabled = bool(app.get("default", False))
                # align name column per category
                width = max_len + 5
                label = f"{name.ljust(width)}{desc}"
                opts.append(
                    Choice(
                        name,
                        name=label,
                        enabled=enabled
                    )
                )
            prompt = f"Select tools to install for category {category.upper()}:"
            try:
                sel = inquirer.checkbox(
                    message=prompt,
                    choices=opts,
                    instruction="(Space to toggle, ↵ to confirm, Esc to cancel)",
                    transformer=lambda x: "",
                ).execute()
            except KeyboardInterrupt:
                print("\nOperation cancelled by user. Exiting.")
                sys.exit(0)
            selected.extend(sel)

    # If no tools selected, exit early
    if not selected:
        print("No tools selected. Exiting.")
        sys.exit(0)

    # --- Preflight: compute already-installed vs to-be-installed ---
    installed_list = []
    to_install_list = []

    # Build a quick lookup of app metadata by name
    name_to_app = {}
    for _category, _info in data.items():
        for _app in _info.get("apps", []):
            _nm = _app.get("name")
            if _nm:
                name_to_app[_nm] = {"category": _category, "app": _app}

    for _name in selected:
        meta = name_to_app.get(_name)
        if not meta:
            # Unknown name; treat as to-install just in case
            to_install_list.append(_name)
            continue
        _cmd = meta["app"].get("cmd", _name)
        if shutil.which(_cmd):
            installed_list.append(_name)
        else:
            to_install_list.append(_name)

    # --- Display preflight result with Rich ---
    header = "Preflight check"
    lines = []
    lines.append("[bold]Already installed:[/bold]")
    if installed_list:
        lines += [f"• {n}" for n in installed_list]
    else:
        lines.append("(none)")
    lines.append("")
    lines.append("[bold]To be installed:[/bold]")
    if to_install_list:
        lines += [f"• {n}" for n in to_install_list]
    else:
        lines.append("(none)")

    console.print(Panel.fit("\n".join(lines), title=header, style="magenta"))

    # If everything selected is already installed, exit early with a friendly message
    if to_install_list == []:
        console.print("[green]All selected tools are already installed. Nothing to do. Exiting.[/green]")
        sys.exit(0)

    # Ensure npm is available if npm tools are selected; may restart the script
    ensure_npm_if_needed(selected, name_to_app)

    # Offer to proceed, change selection, or cancel
    try:
        next_step = inquirer.select(
            message="How do you want to proceed?",
            choices=[
                {"name": "Proceed with installation", "value": "proceed"},
                {"name": "Change selection", "value": "change"},
                {"name": "Cancel", "value": "cancel"},
            ],
            default="proceed",
        ).execute()
    except KeyboardInterrupt:
        print("\nOperation cancelled by user. Exiting.")
        sys.exit(0)

    if next_step == "cancel":
        print("Cancelled by user before installation. Exiting.")
        sys.exit(0)
    if next_step == "change":
        # loop again to re-select
        continue
    # otherwise proceed
    break

# Install only the tools that are not yet installed (from preflight)
for name in to_install_list:
    meta = name_to_app.get(name)
    if not meta:
        print(f"Skipping {name}: unknown tool definition.")
        continue

    category = meta["category"]
    app = meta["app"]
    cat_info = data.get(category, {})
    cmd_template = cat_info.get("cmd")

    # Quick sanity re-check in case state changed since preflight
    cmd = app.get("cmd", name)
    if shutil.which(cmd):
        print(f"{name} is already installed ... (skipping)")
        continue

    if category == "system":
        full_cmd = f"{pkg_mgr} {cmd_template} {name}"
    else:
        full_cmd = f"{category} {cmd_template} {name}"

    app_install = app.get("install", full_cmd)
    print(f"Installing {name} ...")

    try:
        if isinstance(app_install, str):
            subprocess.run(shlex.split(app_install), check=True)
        else:
            # If apps.json provides a list form already
            subprocess.run(app_install, check=True)
    except subprocess.CalledProcessError as e:
        print(f"Error installing {name}: {e}")
