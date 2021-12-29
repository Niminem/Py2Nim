# Package
version       = "0.1.1"
author        = "Leon Lysak"
description   = "Py2Nim is a tool to translate Python code to Nim. The output is idiomatic Nim code, meant to be tweaked by hand after the translation process."
license       = "MIT"
installExt    = @["nim","py","nims"]
srcDir        = "src"
bin           = @["py2nim"]

# Dependencies
requires "nim >= 1.6.0"
requires "compiler#head"
requires "nimscripter >= 1.0.3"