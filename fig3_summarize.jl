using CSV, DataFrames, Statistics

df = CSV.read("fig3.txt", DataFrame; header=false, delim=' ', ignoreemptyrows=true)
dropmissing!(df)

rename!(df, [:groupSize, :trial, :oneOverP, :fitness])

df.groupSize = convert.(Int, df.groupSize)
df.trial     = convert.(Int, df.trial)

#cutOff=30
#filtered_df = filter(row -> row.trial <= cutOff, df)
#df=filtered_df

gdf     = groupby(df, [:groupSize, :oneOverP])

summary_df = combine(gdf,
    :fitness => mean => :mean_fitness,
    :fitness => std  => :sd_fitness,
    :fitness => length => :num_trials,
    :fitness => (x -> mean(log.(x))) => :mean_log_fitness,
    :fitness => median => :median_fitness 
)


# Unique combinations of oneOverP as a DataFrame
unique_conditions = unique(summary_df[:, [:oneOverP]])

for condition in eachrow(unique_conditions)
    oneOverPVal  = condition.oneOverP
    
    println("Condition: oneOverP = $oneOverPVal")
    

    condition_df = filter(row -> row.oneOverP == oneOverPVal, summary_df)
    
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
