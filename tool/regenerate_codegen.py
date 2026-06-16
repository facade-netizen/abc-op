#!/usr/bin/env python3
"""Regenerate build_runner outputs and protobuf Dart files.

Steps:
1) dart run build_runner build --delete-conflicting-outputs
2) dart pub global activate protoc_plugin
3) Find all .proto files and run: protoc --dart_out=. <file>.proto in their dirs
"""
from __future__ import annotations

import subprocess
from pathlib import Path
import sys


def run(cmd: list[str], cwd: Path | None = None) -> None:
    display = " ".join(cmd)
    print(f"\n> {display}")
    result = subprocess.run(cmd, cwd=str(cwd) if cwd else None)
    if result.returncode != 0:
        raise SystemExit(result.returncode)


def main() -> None:
    repo_root = Path(__file__).resolve().parents[1]

    # Step 1: build_runner
    run(["dart", "run", "build_runner", "build", "--delete-conflicting-outputs"], cwd=repo_root)

    # Step 2: activate protoc_plugin
    run(["dart", "pub", "global", "activate", "protoc_plugin"], cwd=repo_root)

    # Step 3: find and compile .proto files
    proto_files = sorted(repo_root.rglob("*.proto"))
    if not proto_files:
        print("No .proto files found.")
        return

    for proto in proto_files:
        # run protoc in the proto file's directory so outputs land next to it
        run(["protoc", "--dart_out=.", proto.name], cwd=proto.parent)

    print("\nDone.")


if __name__ == "__main__":
    main()
