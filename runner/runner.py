#!/usr/bin/env python3
"""
Permet de résoudre le chemin du fichier de test
et de lancer l'exécutable de scrut pour lancer
notre fichier de test.
"""
import os
import subprocess
import sys

from python.runfiles import runfiles

def main():
    if len(sys.argv) != 3:
        sys.exit("usage: runner.py <scrut> <test_file>")

    r = runfiles.Create()
    if r is None:
        sys.exit("error: cannot initialize runfiles")

    scrut, test_file = (os.path.abspath(r.Rlocation(p)) for p in sys.argv[1:3])

    result = subprocess.run([scrut, "test", test_file])
    sys.exit(result.returncode)


if __name__ == "__main__":
    main()
