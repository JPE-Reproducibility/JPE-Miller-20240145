#!/usr/bin/env python3
"""Compile the paper and appendix with bibliography.

The main paper (`miller_2025.tex`) and the web-only appendix (`online_appendix.tex`)
are cross-referenced via `xr`/`\\externaldocument`, so we keep intermediate outputs
(especially the `.aux` files) for both documents.

Build order:
- Pass 1: pdflatex both (generate `.aux` for cross-references)
- BibTeX:  run for both
- Pass 2-3: pdflatex both (run twice so citations and cross-references resolve)
"""

from __future__ import annotations

import subprocess
import sys
from pathlib import Path

PAPER_DIR = Path(__file__).resolve().parent
TEX_STEMS = ["miller_2025", "online_appendix"]


def run_command(cmd: list[str]) -> None:
    result = subprocess.run(
        cmd,
        cwd=PAPER_DIR,
        capture_output=True,
        text=True,
    )
    if result.returncode != 0:
        print(f"Error running: {' '.join(cmd)}", file=sys.stderr)
        if result.stdout:
            print(result.stdout, file=sys.stderr)
        if result.stderr:
            print(result.stderr, file=sys.stderr)
        raise SystemExit(result.returncode)


def run_pdflatex(tex_stem: str) -> None:
    run_command(
        [
            "pdflatex",
            "-interaction=nonstopmode",
            "-halt-on-error",
            "-file-line-error",
            f"{tex_stem}.tex",
        ]
    )


def run_bibtex(tex_stem: str) -> None:
    run_command(["bibtex", tex_stem])


def compile_all() -> None:
    print("Pass 1/3: pdflatex (generate aux files)...")
    for stem in TEX_STEMS:
        print(f"  pdflatex {stem}.tex")
        run_pdflatex(stem)

    print("BibTeX...")
    for stem in TEX_STEMS:
        print(f"  bibtex {stem}")
        run_bibtex(stem)

    for pass_num in (2, 3):
        print(f"Pass {pass_num}/3: pdflatex (resolve refs)...")
        for stem in TEX_STEMS:
            print(f"  pdflatex {stem}.tex")
            run_pdflatex(stem)

    for stem in TEX_STEMS:
        pdf_path = PAPER_DIR / f"{stem}.pdf"
        if not pdf_path.exists():
            raise SystemExit(f"Expected output not found: {pdf_path}")
        print(f"Wrote {pdf_path.name}")


def main() -> None:
    compile_all()


if __name__ == "__main__":
    main()
