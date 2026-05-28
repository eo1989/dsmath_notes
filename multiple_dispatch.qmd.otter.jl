













function _LS(y::Array{Float64}, X::Array{Float64})
    # calc & return the LS coefficient
    return (X′ * X) \ (X′ * y)
end
