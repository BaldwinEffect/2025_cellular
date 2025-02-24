using CSV, DataFrames, Gadfly, Statistics
import Cairo, Fontconfig

case="p1"
 
xRange=5000
xTicks=[0,1000,2000,3000,4000,5000]

# Step 1: Read without a header
df = CSV.read("fig2_"*case*".txt", DataFrame; delim=' ', header=false)

# Step 2: Rename columns in-place
rename!(df, [:genC, :trial, :oneOverP, :groupN, :fitness])


# OPTIONAL: filter out incomplete trials.
#   Below is just one approach: we check how many rows each trial has,
#   then keep only those with the full set of generations.
grouped = groupby(df, :trial)
trial_sizes = combine(grouped) do sdf
    ( trial=sdf.trial[1],
      n    =nrow(sdf),
      minC =minimum(sdf.genC),
      maxC =maximum(sdf.genC) )
end

# Find largest group size or known # of generations (e.g. 50, 100)
maxsize = maximum(trial_sizes.n)
# Keep only trials with that full size:
full_trials = trial_sizes[trial_sizes.n .== maxsize, :trial]
df_complete = filter(row -> row.trial in full_trials, df)

plotN=15

all_trials = unique(df_complete.trial)
some_trials = all_trials[plotN+1:2*plotN] 

df_subset = filter(row -> row.trial in some_trials, df_complete)


# 2) Compute mean fitness at each generation:
df_mean = combine(groupby(df_complete, :genC)) do sdf
    (fitness_mean = median(sdf.fitness),)
end

println(maximum(df_mean.fitness_mean))

# 3) Plot:
#    - First layer: each trial as a thin, light line.
#    - Second layer: average as a thick, dark line.
p = plot(
    layer(
        df_mean[1:5:end, :],
        x          = :genC,
        y          = :fitness_mean,
        Geom.line,
        Theme(line_width=0.75mm,default_color=colorant"blue"),    # thick line
  #      Theme(line_width=1.0mm),    # thick line
    ),
        layer(
        df_subset[1:5:end, :],
        x     = :genC,
        y     = :fitness,
        group = :trial,
        Geom.line,
            Theme(line_width=0.15mm,default_color=colorant"grey"),
            #Theme(line_width=0.15mm),   
    ),
    #Guide.xlabel("generations"),
    #Guide.ylabel("fitness",orientation=:vertical),
    Guide.xlabel(""),
    Guide.ylabel(""),
    Coord.Cartesian(xmin=0,xmax=1.05*xRange,ymin=0,ymax=250),
    Guide.xticks(ticks=xTicks
                 ),
        #Theme(key_position = :none,plot_padding=[0mm,0mm,0mm,0mm],background_color=colorant"white"),
)

# Finally, display or save the plot:
draw(PDF("fig2_"*case*".pdf", 3inch, 2.5inch), p)
draw(PNG("fig2_"*case*".png", 3inch, 2.5inch), p)
