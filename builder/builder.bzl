"""
Définis les règles:

- scrut_case pour la création de règles scrut depuis bazel
- scrut_aggregate pour l'aggrégation d'un jeu de test un un seul fichier .t
- scrut_emit permet l'écriture des fichiers générés (scrut_case ou scrut_aggregate) dans le dossier de code source
"""

def _scrut_case_impl(ctx):
    """
    Permet la création d'un test scrut (.t) a partir des paramètres données

    A savoir, une description, une commande, ainsi qu'un code et retour attendu
    """
    lines = [
        ctx.attr.description,
        "  $ " + ctx.attr.command,
    ]
    for line in ctx.attr.output.splitlines():
        lines.append("  " + line)
    if ctx.attr.return_code != 0:
        lines.append("  [{}]".format(ctx.attr.return_code))

    out = ctx.actions.declare_file(ctx.attr.name + ".t")
    ctx.actions.write(output = out, content = "\n".join(lines) + "\n")
    return [DefaultInfo(files = depset([out]))]

scrut_case = rule(
    implementation = _scrut_case_impl,
    attrs = {
        "description": attr.string(mandatory = True),
        "command": attr.string(mandatory = True),
        "output": attr.string(mandatory = True),
        "return_code": attr.int(default = 0),
    },
)

def _scrut_aggregate_impl(ctx):
    """
    Permet d'aggréger plusieurs fichiers .t dans un seul et unique fichier .t
    """
    out = ctx.actions.declare_file(ctx.attr.name + ".t")
    ctx.actions.run_shell(
        inputs = ctx.files.srcs,
        outputs = [out],
        arguments = [out.path] + [f.path for f in ctx.files.srcs],
        command = 'out="$1"; shift; : > "$out"; ' +
                  'for f in "$@"; do cat "$f" >> "$out"; echo >> "$out"; done',
        mnemonic = "ScrutAggregate",
        progress_message = "Aggregating scrut files into %{output}",
    )
    return [DefaultInfo(files = depset([out]))]

scrut_aggregate = rule(
    implementation = _scrut_aggregate_impl,
    attrs = {
        "srcs": attr.label_list(allow_files = [".t"], mandatory = True),
    },
)

def _scrut_emit_impl(ctx):
    """
    Permet l'écriture des cas de tests donnés dans le dossier de workspace
    """
    dst = ctx.attr.dst_dir
    lines = [
        "#!/usr/bin/env bash",
        "set -euo pipefail",
        'mkdir -p "$BUILD_WORKSPACE_DIRECTORY/{}"'.format(dst),
    ]

    for f in ctx.files.srcs:
        target = "$BUILD_WORKSPACE_DIRECTORY/{}/{}".format(dst, f.basename)
        lines.append('cp -f "{}" "{}"'.format(f.short_path, target))
        lines.append('chmod u+w "{}"'.format(target))
    lines.append('echo "copied {} file(s) to {}"'.format(len(ctx.files.srcs), dst))

    exe = ctx.actions.declare_file(ctx.label.name + ".sh")
    ctx.actions.write(output = exe, content = "\n".join(lines) + "\n", is_executable = True)
    return [DefaultInfo(
        executable = exe,
        runfiles = ctx.runfiles(files = ctx.files.srcs),
    )]

scrut_emit = rule(
    implementation = _scrut_emit_impl,
    executable = True,
    attrs = {
        "srcs": attr.label_list(allow_files = [".t", ".md"], mandatory = True),
        "dst_dir": attr.string(mandatory = True),
    },
)
