import macros, sequtils

var nimModules*: seq[string]

proc addModules*(tree: NimNode) =
    if nimModules.len > 0:
        var importStmt = nnkImportStmt.newTree()
        for module in nimModules.deduplicate():
            importStmt.add newIdentNode(module)

        tree.insert(0, importStmt)