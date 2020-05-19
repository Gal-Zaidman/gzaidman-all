import subprocess
import shlex

def execute(c):
    command = shlex.split(c)
    completed = subprocess.run(command, stdout=subprocess.PIPE)
    if completed.returncode != 0:
        raise (
            RuntimeError(
                (
                    f"could not execute {c}",
                    f"error is {completed.stderr}",
                )
            )
        )
