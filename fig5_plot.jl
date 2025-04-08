using CSV, DataFrames, Gadfly
import Cairo, Fontconfig

filename = "fig5_p1"
#filename = "fig5_p0"

using CSV, DataFrames, Gadfly, Random

# Load the data file (assumed whitespace separated)
df = CSV.read(filename*".txt", delim=' ', ignorerepeated=true, DataFrame)

# Rename columns for clarity:
# Column 1: generation, Column 6: fitness (other columns are not used here)
rename!(df, [:generation, :col2, :col3, :col4, :col5, :fitness])

# 1. Create a DataFrame for positive fitness values and add x-axis jitter.
df_positive = filter(row -> row.fitness > -2, df)
jitter_amt = 200  # adjust the jitter amount as needed
df_positive.jitter = df_positive.generation .+ jitter_amt .* (rand(size(df_positive, 1)) .- 0.5)

# 2. Aggregate the count of zeros (fitness == -1) per generation.
df_zeros = combine(groupby(df, :generation)) do d
    # Count rows where fitness equals zero.
    zeros = sum(d.fitness .== -1)
    DataFrame(zeros = zeros)
end

# 3. Compute a scaling factor so that the zeros count (when scaled) fits within the fitness range.
#    Here we use the maximum fitness from positive values and the maximum zeros count.
fmax = maximum(df_positive.fitness)
cmax = maximum(df_zeros.zeros)
# Avoid division by zero in case no zeros exist.
scale_factor = cmax > 0 ? fmax / cmax : 1.0
df_zeros.scaled = df_zeros.zeros .* scale_factor

# 4. Create the layered plot.
p = plot(
    # Layer 1: Positive fitness scatter (blue points with jitter)
    df_positive, x=:jitter, y=:fitness, Geom.point,
    Theme(default_color="blue", point_size=0.5mm,highlight_width=0.01mm,plot_padding=[3mm,1mm,5mm,1mm]),
    #Theme(default_color="red", point_size=0.5mm,highlight_width=0.01mm,plot_padding=[1mm,1mm,5mm,1mm]),
    Guide.xlabel(""),
    Guide.ylabel(""),
#    Scale.y_continuous(minvalue=-2),
    #    Coord.Cartesian(xmin=0,xmax=5200,ymin=-2,ymax=200),
        Coord.Cartesian(xmin=0,xmax=5200,ymin=-2,ymax=60),
)

# 5. Annotate the plot to indicate the scaling factor for the zeros count.
#annot_text = "Red squares: zeros count (scaled by factor = $(round(scale_factor, digits=2)))"
#p = p |> layer(Geom.label, mapping=(x=[maximum(df_positive.generation)], y=[fmax*0.9], label=[annot_text]), 
#               Theme(alignment=:right, point_label_font_size=8pt))

# Save the plot to a file (or display it interactively)
# Save the plot as an SVG file.
draw(PDF(filename*".pdf", 6inch, 1.5inch), p)
