using CSV, DataFrames, Gadfly, Statistics
import Cairo, Fontconfig

case="p1"

xRange=2500
xTicks=[0,1250,2500]
if case=="bgd"
    xRange=10000
    xTicks=[0,5000,10000]
end

function makeLabel(x)
    if x==5000
        return "5k"
    end
    if x==10000
        return "10k"
    end

    string(x)

end


# Step 1: Read without a header
df = CSV.read("fig1_"*case*".txt", DataFrame; delim=' ', header=false)

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
some_trials = all_trials[1:plotN] 

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
        df_mean,
        x          = :genC,
        y          = :fitness_mean,
        Geom.line,
        Theme(line_width=1.0mm,default_color=colorant"red"),    # thick line
    ),
        layer(
        df_subset,
        x     = :genC,
        y     = :fitness,
        group = :trial,
        Geom.line,
        Theme(line_width=0.15mm,default_color=colorant"blue"),   
    ),
    #Guide.xlabel("generations"),
    #Guide.ylabel("fitness",orientation=:vertical), Guide.xlabel(""),
    Guide.ylabel(""),
    Coord.Cartesian(xmin=0,xmax=1.05*xRange,ymin=0,ymax=200),
    Guide.xticks(ticks=xTicks ), Scale.x_continuous(labels=makeLabel),
    Theme(key_position =
    :none,plot_padding=[0mm,0mm,0mm,0mm],background_color=colorant"white"),
    )

# Finally, display or save the plot:
draw(PDF("fig1_"*case*".pdf", 1.75inch, 1.5inch), p)
draw(PNG("fig1_"*case*".png", 1.75inch, 1.5inch), p)
