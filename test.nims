# for testing/validating asts', tests, etc.
import macros


# nnkStmtList.newTree(
#   nnkForStmt.newTree(
#     newIdentNode("character"),
#     newLit("leon"),
#     nnkStmtList.newTree(
#       newIdentNode("pass")
#     )
#   )
# )

dumpastgen:
    # nnkForStmt(ident1, ident2, expr1, stmt1)
    for character in "leon":
        pass



