#!/usr/bin/env python3
"""
Environment check script - Validates all anything-to-notebooklm skill dependencies
"""

import sys
import os
from pathlib import Path

RED = '\033[0;31m'
GREEN = '\033[0;32m'
YELLOW = '\033[1;33m'
BLUE = '\033[0;34m'
NC = '\033[0m'

SKILL_DIR = Path(__file__).parent
VENV_DIR = SKILL_DIR / ".venv"
VENV_PY = VENV_DIR / "bin" / "python"
BIN_DIR = SKILL_DIR / "bin"

def print_status(status, message):
    if status == "ok":
        print(f"{GREEN}✅ {message}{NC}")
    elif status == "warning":
        print(f"{YELLOW}⚠️  {message}{NC}")
    elif status == "error":
        print(f"{RED}❌ {message}{NC}")
    else:
        print(f"{BLUE}ℹ️  {message}{NC}")

def check_uv_version():
    import shutil
    
    if shutil.which("uv"):
        import subprocess
        try:
            result = subprocess.run(["uv", "--version"],
                                  capture_output=True,
                                  text=True,
                                  timeout=5)
            version = result.stdout.split('\n')[0] if result.stdout else "unknown"
            print_status("ok", f"uv installed ({version})")
            return True
        except:
            print_status("ok", "uv installed")
            return True
    else:
        print_status("error", "uv not found (required for package management)")
        return False

def check_venv():
    if VENV_PY.exists():
        print_status("ok", f"Virtual env found ({VENV_DIR})")
        return True
    print_status("error", f"Virtual env not found: {VENV_DIR}")
    return False

def check_command(cmd):
    import shutil

    if shutil.which(cmd):
        import subprocess
        try:
            result = subprocess.run([cmd, "--version"],
                                  capture_output=True,
                                  text=True,
                                  timeout=5)
            version = result.stdout.split('\n')[0] if result.stdout else "unknown"
            print_status("ok", f"{cmd} installed ({version})")
        except:
            print_status("ok", f"{cmd} installed")
        return True
    else:
        print_status("error", f"{cmd} not found")
        return False

def check_wrapper(cmd):
    """Check if a CLI tool is available in the venv or via bin/ wrapper."""
    venv_bin = VENV_DIR / "bin" / cmd
    wrapper = BIN_DIR / cmd

    if venv_bin.exists() and os.access(venv_bin, os.X_OK):
        print_status("ok", f"{cmd} installed (.venv/bin/{cmd})")
        return True
    elif wrapper.exists() and os.access(wrapper, os.X_OK):
        print_status("ok", f"{cmd} wrapper ready ({wrapper})")
        return True
    print_status("error", f"{cmd} not found (run ./install.sh)")
    return False

def check_notebooklm_auth():
    import subprocess
    notebooklm_wrapper = BIN_DIR / "notebooklm"
    cmd = [str(notebooklm_wrapper)] if notebooklm_wrapper.exists() else ["notebooklm"]

    try:
        result = subprocess.run(cmd + ["list"],
                              capture_output=True,
                              text=True,
                              timeout=10)

        if result.returncode == 0:
            print_status("ok", "NotebookLM authenticated")
            return True
        else:
            print_status("warning", "NotebookLM not authenticated (run: ./bin/notebooklm login)")
            return False
    except subprocess.TimeoutExpired:
        print_status("warning", "NotebookLM auth check timed out")
        return False
    except Exception as e:
        print_status("error", f"NotebookLM auth check failed: {e}")
        return False

def main():
    print(f"\n{BLUE}========================================{NC}")
    print(f"{BLUE}  Environment Check - anything-to-notebooklm{NC}")
    print(f"{BLUE}========================================{NC}\n")

    results = []

    print(f"{YELLOW}[1/5] Package Manager (uv){NC}")
    results.append(check_uv_version())
    print()

    print(f"{YELLOW}[2/5] Local Virtual Environment{NC}")
    results.append(check_venv())
    print()

    print(f"{YELLOW}[3/5] CLI Tools{NC}")
    results.append(check_wrapper("notebooklm"))
    results.append(check_wrapper("markitdown"))
    print()

    print(f"{YELLOW}[4/5] Git{NC}")
    results.append(check_command("git"))
    print()

    print(f"{YELLOW}[5/5] NotebookLM Authentication{NC}")
    results.append(check_notebooklm_auth())
    print()

    print(f"{BLUE}========================================{NC}")
    passed = sum(results)
    total = len(results)

    if passed == total:
        print(f"{GREEN}✅ All checks passed ({passed}/{total})! Environment is fully configured.{NC}")
    elif passed >= total * 0.8:
        print(f"{YELLOW}⚠️  Most checks passed ({passed}/{total}), but some issues need fixing.{NC}")
    else:
        print(f"{RED}❌ Checks failed ({passed}/{total}). Run ./install.sh to reinstall.{NC}")

    print(f"{BLUE}========================================{NC}\n")

    if passed < total:
        print("💡 Fix suggestions:")
        print("  1. Install uv: https://docs.astral.sh/uv/getting-started/")
        print("  2. Run installer: ./install.sh")
        print("  3. Authenticate NotebookLM: ./bin/notebooklm login")
        print()

    sys.exit(0 if passed == total else 1)

if __name__ == "__main__":
    main()
