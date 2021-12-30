import
  strformat

var this = "that"
var that = this
var x, y, z = 9000
var (a, b, c) = (1, 2, 3)
var (v1, v2, v3) = (9000, "hello", 9.4'f64)
var (test1, test2, test3) = (thisFunc(), fmt"{x}", z)
var ls = @[1, 2, 3]
var ls2 = @["this", "that", "the other"]
var ls3 = @[1.2'f64, 3.2'f64, 4.2'f64]
var ls4 = @[(1, 2, 3), (4, 5, 6), (7, 8, 9)]
var ls5 = @[true, false, true]
if x == 9000:
  var myls = @[1, 2, 3]
  for elem in myls:
    if 5 >= 7:
      echo(elem)
    elif elem == 2:
      echo("elem is 2")
    else:
      discard
  if true:
    echo("true")
elif x != 9001:
  echo("x is 9001")
  var tup = (1, 2, 3)
else:
  echo("x is neither 9000 nor 9001")
if false:
  echo("not false")
else:
  discard