# Py2Nim **in development**
Py2Nim is a tool to translate Python code to Nim. The output is human-readable Nim code, meant to be tweaked by hand after the translation process.

Requirements:
- Python 3.6.X or Python 3.7.X (very important, as there are issues with Python's AST in <3.6 and >3.8)
- Ast2Json https://github.com/YoloSwagTeam/ast2json  using pip ex. `pip3 install ast2json`
- Nim Devel branch `choosenim devel` (1.6.0 seems to be working currently as well)

## To Install:
`nimble install py2nim`
or
git clone this repository and `nimble install` within the root directory

## To Run Tests:
`nimble test` within the root directory (package installation not necessary, the tests don't use the binary)

## To Use:
After installation, simply call `py2nim` followed by these arguments:
- path/to/src.py
- your python command or alias (what you use to call the appropriate python interpreter) ex. `python3`

Full example: `py2nim tests/assignment.py python3`

## Currently In Active Development

documentation, list of features, and project roadmap coming soon
