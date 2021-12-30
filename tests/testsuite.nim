# To run the tests, simply execute `nimble test` in the root directory of this project

import std/os
import ../src/py2nim

# NOTE
# build a dynamic test suite (via macro / template) for each python file in the tests dir

assert translate("tests" / "basic_syntax.py", "python3", debug=true) == readFile(
        "tests" / "basic_syntax.nim"),"\nNim source differs from test: assignments.nim\n"