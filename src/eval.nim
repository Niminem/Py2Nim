import macros, json
import ../py2nim/[literals, variables, expressions, statements, control_flow]
#import eval

{.experimental:"codeReordering".} # removes the need for forward declarations in top-level code


# nim proc to evaluate possible _type's via case statement
proc addEvaluatedPyType*(tree: NimNode, node: JsonNode) =
    case node["_type"].getStr
    of "Expr":
        tree.addExpr(node)
    of "Assign":
        tree.addAssign(node)
    of "If":
        tree.addIf(node)
    of "Call":
        tree.addCall(node)
    else: discard