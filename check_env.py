#!/usr/bin/env python3
"""
Environment check script - Validates all anything-to-notebooklm skill dependencies
"""

import sys
import os
import json
from pathlib import Path

RED = '\033[0;31m'
GREEN = '\033[0;32m'
YELLOW = '\033[1;33m'
BLUE = '\033[0;34m'
NC = '\033[0m'

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

def check_module(module_name, import_name=None):
    if import_name is None:
        import_name = module_name

    try:
        __import__(import_name)
        print_status("ok", f"{module_name} installed")
        return True
    except ImportError:
        print_status("error", f"{module_name} not installed")
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

def check_mcp_config():
    config_path = Path.home() / ".claude" / "config.json"

    if not config_path.exists():
        print_status("error", f"Claude config file not found: {config_path}")
        return False

    try:
        with open(config_path, 'r') as f:
            config = json.load(f)

        if "mcpServers" in config and "weixin-reader" in config["mcpServers"]:
            print_status("ok", "MCP server configured")
            return True
        else:
            print_status("warning", "MCP server not configured (manual setup required)")
            return False
    except Exception as e:
        print_status("error", f"Cannot read config file: {e}")
        return False

def check_mcp_server():
    skill_dir = Path(__file__).parent
    mcp_server = skill_dir / "wexin-read-mcp" / "src" / "server.py"

    if mcp_server.exists():
        print_status("ok", "MCP server file exists")
        return True
    else:
        print_status("error", f"MCP server file not found: {mcp_server}")
        return False

def check_notebooklm_auth():
    import subprocess

    try:
        result = subprocess.run(["notebooklm", "list"],
                              capture_output=True,
                              text=True,
                              timeout=10)

        if result.returncode == 0:
            print_status("ok", "NotebookLM authenticated")
            return True
        else:
            print_status("warning", "NotebookLM not authenticated (run: notebooklm login)")
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

    print(f"{YELLOW}[1/9] Package Manager (uv){NC}")
    results.append(check_uv_version())
    print()

    print(f"{YELLOW}[2/9] Core Python Dependencies{NC}")
    results.append(check_module("fastmcp"))
    results.append(check_module("playwright"))
    results.append(check_module("beautifulsoup4", "bs4"))
    results.append(check_module("lxml"))
    results.append(check_module("markitdown"))
    print()

    print(f"{YELLOW}[3/9] Playwright Importability{NC}")
    try:
        from playwright.sync_api import sync_playwright
        print_status("ok", "Playwright imports successfully")
        results.append(True)
    except Exception as e:
        print_status("error", f"Playwright import failed: {e}")
        results.append(False)
    print()

    print(f"{YELLOW}[4/9] NotebookLM CLI{NC}")
    results.append(check_command("notebooklm"))
    print()

    print(f"{YELLOW}[5/9] markitdown CLI{NC}")
    results.append(check_command("markitdown"))
    print()

    print(f"{YELLOW}[6/9] Git{NC}")
    results.append(check_command("git"))
    print()

    print(f"{YELLOW}[7/9] MCP Server File{NC}")
    results.append(check_mcp_server())
    print()

    print(f"{YELLOW}[8/9] MCP Configuration{NC}")
    results.append(check_mcp_config())
    print()

    print(f"{YELLOW}[9/9] NotebookLM Authentication{NC}")
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
        print("  3. Configure MCP: edit ~/.claude/config.json")
        print("  4. Authenticate NotebookLM: notebooklm login")
        print()

    sys.exit(0 if passed == total else 1)

if __name__ == "__main__":
    main()
