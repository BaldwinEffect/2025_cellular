using CSV, DataFrames, Statistics

df = CSV.read("fig3.txt", DataFrame; header=false, delim=' ', ignoreemptyrows=true)
dropmissing!(df)

rename!(df, [:groupSize, :trial, :oneOverP, :haremetic, :fitness])

df.groupSize = convert.(Int, df.groupSize)
df.trial     = convert.(Int, df.trial)
df.haremetic = df.haremetic .== 1.0


gdf     = groupby(df, [:groupSize, :oneOverP, :haremetic])

summary_df = combine(gdf,
    :fitness => mean => :mean_fitness,
    :fitness => std  => :sd_fitness,
    :fitness => length => :num_trials,
    :fitness => (x -> mean(log.(x))) => :mean_log_fitness,
    :fitness => median => :median_fitness 
)


# Unique combinations of oneOverP and haremetic as a DataFrame
unique_conditions = unique(summary_df[:, [:oneOverP, :haremetic]])

for condition in eachrow(unique_conditions)
    oneOverPVal  = condition.oneOverP
    haremeticVal = condition.haremetic
    
    println("Condition: oneOverP = $oneOverPVal, haremetic = $haremeticVal")
    

    condition_df = filter(row -> row.oneOverP == oneOverPVal &&
                                 row.haremetic == haremeticVal, summary_df)
    
    sort!(condition_df, :groupSize)

    for row in eachrow(condition_df)
        println("  groupSize = ", row.groupSize, 
                ", median fitness = ", row.median_fitness, 
                ", SD fitness = ", row.sd_fitness,
                ", num trials = ", row.num_trials,
		", mean log fitness = ", row.mean_log_fitness)
    end
    println()
end
