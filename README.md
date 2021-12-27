# Py2Nim
Py2Nim is a tool to translate Python code to Nim. The output is human-readable Nim code, meant to be tweaked by hand after the translation process.

Requirements:
- Python 3.6.X or Python 3.7.X
- Ast2Json https://github.com/YoloSwagTeam/ast2json  using pip ex. `pip3 install ast2json`
- Nim Devel branch `choosenim devel` (1.6.0 seems to be working currently as well)

To Run Tests:
`nimble test` within the root directory (nimble package installation not necessary)

To Install:
`nimble install` within the root directory

To Use:
After installation, simply call `py2nim` followed by these arguments:
- path/to/src.py
- your python command or alias ex. `python3`
full example: `py2nim tests/assignment.py python3`

*** Currently In Development ***
list of features and project roadmap coming soon
