import std/[json, strutils, osproc, os]
import nimscripter

type
    ModuleError* = object of CatchableError

proc translate*(pyModulePath: string, pyCmd:string = "python3", debug = false): string =

    let pyAst = execProcess(pyCmd, args=[getAppDir() / "parser.py",
                    pyModulePath], options={poUsePath})

    if pyAst == "": # *** make better exception handling with this process ***
        raise ModuleError.newException("Unable to parse python module. Response: ")

    let
        script = NimScriptPath getAppDir() / "interpreter.nims"
        intr = loadScript(script)

    result = intr.invoke(sourceGen, pyAst.parseJson, returnType = string)

    if debug:
        echo result
    else:
        let f = open(pyModulePath.replace(".py",".nim"), fmWrite)
        f.write(result)
        f.close()


when isMainModule:

    # discard translate("script.py", "python3", true)

    # *** implement proper cli parsing ***

    let count = paramCount()
    if count != 2:
        quit("[Incorrect Parameters] py2nim requires:\n[1] path/to/src.py\n[2] python command ex. `python3`")

    let
        params = commandLineParams()
        pyModulePath = params[0]
        pyCmd = params[1]

    if not fileExists(pyModulePath):
        quit("[Parameter 0] Python file not found: " & pyModulePath)

    discard translate(pyModulePath, pyCmd)