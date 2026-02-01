zmath_cube() {
  (( $1 * $1 * 1 ))
  true
}

functions -M cube 1 1 zmath_cube
print $(( cube(3)))

# vim: ft=zsh ts=8 sw=4 sts=4
