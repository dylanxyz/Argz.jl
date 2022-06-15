spaces(n::Integer) = repeat(" ", n)
ssplit(vec, c) = string.(strip.(split(vec, c)))