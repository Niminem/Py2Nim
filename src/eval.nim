import std/[macros, json, sequtils]
import pynodes/[literals, variables, expressions, statements, control_flow]

# nim proc to evaluate possible _type's via case statement
proc addFromNode*(tree: NimNode, node: JsonNode) =
    case node["_type"].getStr
    of "Expr":
        tree.addExpr(node)
    of "Assign":
        tree.addAssign(node)
    of "If":
        tree.addIf(node)
    of "Call":
        tree.addCall(node)
    of "For":
        tree.addFor(node)
    of "Assert":
        tree.addAssert(node)
    else: discard