
using Cairo, Fontconfig
using CSV
using DataFrames
using Glob
using Gadfly
using Statistics

#
# 1) Read all matching data files
#
files = glob("2025-04-07_fig3C_*.txt", "./")

df_list = DataFrame[]
for f in files
    # Read each file. The first line is a header, columns are space-delimited.
    temp = CSV.read(f, DataFrame;
        delim=' ',
        ignorerepeated=true,
        header=1,
        normalizenames=true
    )

    push!(df_list, temp)
end

# Concatenate all into one DataFrame
df = vcat(df_list...)

#
# 2) Rename columns for clarity (optional)
#
rename!(df, :genC => :generation)
# Now we have columns: :generation, :trialC, :oneOverP, :unique
# You can confirm with: println(names(df))

#
# 3) Group by (oneOverP, generation) and compute mean of :unique
#
df_agg = combine(groupby(df, [:oneOverP, :generation]),
                 :unique => mean => :avg_unique)

#
# 4) Plot the lines for breeding (oneOverP=1.0) vs. cooperation (oneOverP=0.0)
#    using Gadfly, with a manual color scale.
#
genColors(n)=[colorant"red",colorant"blue"]

p = plot(df_agg,
    x=:generation,
    y=:avg_unique,
    color=:oneOverP,
         Geom.line,
         Scale.color_discrete(genColors),
    Guide.XLabel(""),
    Guide.YLabel(""),
         Guide.Title(""),
         Theme(key_position = :none,plot_padding=[3mm,1mm,5mm,1mm]),
Coord.Cartesian(xmin=0,xmax=5200)
)

#
# 5) Display or save the plot
#
draw(PDF("fig3C_preview.pdf", 6inch, 1.5inch), p)

# Or to display inline in IJulia/Jupyter:
# display(p)
