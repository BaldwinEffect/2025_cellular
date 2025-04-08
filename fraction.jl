using Serialization

# Load the dictionary from the jls file
ca_dict = open("agentExamples.jls", "r") do io
    deserialize(io)
end

println(length(ca_dict))

# Now define a function to compute the fraction of CAs with at least a given fitness
function fraction_above(ca_dict::Dict{Int,Int}, fitness_threshold)
    num_meet = count(v -> v >= fitness_threshold, values(ca_dict))
    return num_meet / length(ca_dict)
end

# Example usage

# threshold = 251
# frac_p0_long = fraction_above(ca_dict, threshold)


# threshold = 134.1
# frac_p0 = fraction_above(ca_dict, threshold)

# threshold = 95.9
# frac_p1 = fraction_above(ca_dict, threshold)

# threshold = 64
# frac_bgd = fraction_above(ca_dict, threshold)

# println(frac_bgd/frac_p0)
# println(frac_bgd/frac_p1)
# println(frac_bgd/frac_p0_long)


println("medians")

threshold = 149.0
frac_p0 = fraction_above(ca_dict, threshold)

threshold = 48.5
frac_p1 = fraction_above(ca_dict, threshold)

threshold = 40.0
frac_bgd = fraction_above(ca_dict, threshold)

println(frac_bgd/frac_p0)
println(frac_bgd/frac_p1)

println(frac_p1/frac_p0)

println(frac_bgd)


