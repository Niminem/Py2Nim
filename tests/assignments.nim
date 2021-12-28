import
  strformat
proc thisFunc(): string = ""
var this = "that"
var x, y, z = 9000
var (a, b, c) = (1, 2, 3)
var (v1, v2, v3) = (9000, "hello", 9.4'f64)
var (test1, test2, test3) = (thisFunc(), fmt"{x}", z)
var ls = @["this", "that", "the other"]
for item in ls:
  echo(item)
if x == z:
  echo("x and z are equal")
elif x > z:
  echo("x is greater than z")
else:
  echo("x is less than z")