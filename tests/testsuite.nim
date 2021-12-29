# To run the tests, simply execute `nimble test` in the root directory of this project

import std/[os, macros]
import ../src/py2nim

let dir = getProjectPath().parentDir()

# NOTE
# build a dynamic test suite (via macro / template) for each python file in the tests dir

assert translate(dir / "assignments.py", "python3", debug=true) == readFile(
        dir / "assignments.nim"),"Nim source differs from test: assignments.nim"