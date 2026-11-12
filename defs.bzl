"""
Macros publiques pour l'exécution des tests scrut
"""

load("@rules_python//python:defs.bzl", "py_test")

_SCRUT = "@crates//scrut__scrut:scrut__scrut"
_RUNNER = "@rules_scrut//runner:runner.py"

def scrut_test(name, src, data = [], **kwargs):
    """Lance un test scrut

    Args:
        name: Nom du test généré
        src: Fichier .t / .md à tester
        data: Les données a placer dans le dossier courrant (rlocation)
        **kwargs: Arguments à ajouter au py_test
    """
    py_test(
        name = name,
        srcs = [_RUNNER],
        main = "runner.py",
        args = ["$(rlocationpath %s)" % label for label in [_SCRUT, src]],
        data = [_SCRUT, src] + data,
        deps = ["@bazel_tools//tools/python/runfiles"],
        legacy_create_init = 0,
        **kwargs
    )
