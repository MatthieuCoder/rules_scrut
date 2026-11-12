"""
Macros publiques pour l'exécution des tests scrut
"""

load("@rules_python//python:defs.bzl", "py_test")

_DEFAULT_SCRUT = "@crates//scrut__scrut:scrut__scrut"
_RUNNER = "@rules_scrut//runner:runner.py"

def scrut_test(name, src, data = [], scrut = _DEFAULT_SCRUT, **kwargs):
    """Lance un test scrut

    Args:
        name: Nom du test généré
        src: Fichier .t / .md à tester
        data: Les données à placer dans le dossier courant (rlocation)
        scrut: Label du binaire scrut (défaut : @crates//scrut__scrut)
        **kwargs: Arguments à ajouter au py_test
    """
    py_test(
        name = name,
        srcs = [_RUNNER],
        main = "runner.py",
        args = ["$(rlocationpath %s)" % label for label in [scrut, src]],
        data = [scrut, src] + data,
        deps = ["@bazel_tools//tools/python/runfiles"],
        legacy_create_init = 0,
        **kwargs
    )
