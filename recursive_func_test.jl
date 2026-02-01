using Latexify

function contfrac(x::Real, n::Integer)
    n < 1 && return Int[]
    fpart, ipart = modf(x)
    fpart == 0 ? [Int(ipart)] : [Int(ipart); contfrac(1 / fpart, n - 1)]
end

# _exmpl = foldr((x, y) -> )
