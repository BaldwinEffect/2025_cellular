using StatsBase
using Colors, FileIO

struct Agent
    rule::Vector{Int}
    stateN::Int
end

mutable struct World
    states::Vector{Int} 
    center::Int    
end

   
function makeWorld(initial::Vector{Int}=[0,0,1,0,0],center::Int=2)
    World(initial, center)
end



function toIndex(stateV,n)
    index=0
    for c in 0:length(stateV)-1
        index+=stateV[end-c]*n^c
    end
    index+1
end


function updateWorld(world::World,agent::Agent)
    newStates = zeros(Int, length(world.states)+2)
    center=world.center+1
    for stateC in 2:length(world.states)-1 
        parent=toIndex(world.states[stateC-1:stateC+1],agent.stateN)

        newStates[stateC+1]=agent.rule[parent]

    end

    start=1
    
    while start<length(newStates)-2 && newStates[start+2]==0
        start+=1
        center-=1
    end
    
    if newStates[end-1]!=0
        push!(newStates,0)
    else
        while length(newStates)>2 && newStates[end-2]==0 
            pop!(newStates)
        end
    end

    makeWorld(newStates[start:end],center)
 
end

function countNonzeros(v::AbstractVector)
    return count(!=(0), v)
end


function alignWorlds(worlds::Vector{World})

    center=worlds[1].center
    for worldC in 2:length(worlds)
        if worlds[worldC].center>center
            center=worlds[worldC].center
        end
    end

    for worldC in 1:length(worlds)
        if worlds[worldC].center<center
            worlds[worldC].states=vcat(zeros(Int,center-worlds[worldC].center),worlds[worldC].states)
        end
    end

    longest=length(worlds[1].states)
    for worldC in 2:length(worlds)
        if length(worlds[worldC].states)>longest
            longest=length(worlds[worldC].states)
        end
    end
    

    for worldC in 1:length(worlds)
        if length(worlds[worldC].states)<longest
            worlds[worldC].states=vcat(worlds[worldC].states,zeros(Int,longest-length(worlds[worldC].states)))
        end
    end

    worlds

end

function testAgent(agent::Agent,maxYears)

    initialWorld=[0,0,1,0,0]
    fitness=-1

    worlds=Vector{World}()
    
    world=makeWorld(initialWorld)

    push!(worlds,world)
    
    yearC=0
    
    while length(world.states)>2 && yearC<maxYears
        world=updateWorld(world,agent)
        push!(worlds,world)
        yearC+=1
    end

    println(yearC-1)
    
    return worlds
    
end


function printOut(world::World)
    for b in world.states
        print(b)
    end
    print("\n")
end


maxYears=2000

#rule=[0,0,1,2,2,0,1,0,2,2,1,0,1,2,0,0,0,2,0,1,1,0,0,1,1,2,1]
#rule=[0, 0, 1, 2, 0, 0, 2, 0, 1, 2, 2, 0, 0, 1, 1, 0, 0, 2, 0, 2, 2, 2, 2, 2, 1, 0, 1] #240
#rule= [0, 2, 0, 2, 0, 2, 0, 1, 1, 2, 0, 1, 0, 1, 1, 2, 0, 0, 0, 1, 1, 1, 0, 2, 1, 1, 0] #199
#rule= [0, 2, 0, 2, 1, 0, 0, 1, 1, 2, 1, 0, 1, 0, 1, 1, 1, 0, 0, 0, 0, 0, 2, 2, 1, 1, 1] #357
#rule= [0, 2, 0, 1, 0, 2, 0, 1, 0, 2, 0, 1, 1, 0, 1, 1, 1, 2, 0, 1, 1, 2, 0, 0, 2, 1, 2] #372
#rule = [0, 2, 0, 2, 2, 0, 0, 0, 1, 2, 2, 1, 1, 1, 2, 2, 1, 2, 0, 1, 2, 2, 0, 1, 1, 0, 2] #489
#rule = [0, 2, 0, 1, 0, 2, 0, 1, 1, 2, 0, 1, 0, 2, 2, 1, 2, 1, 0, 1, 1, 2, 1, 0, 1, 0, 2] #682
#rule = [0, 2, 0, 2, 0, 2, 0, 1, 1, 2, 0, 1, 0, 1, 2, 0, 1, 2, 0, 1, 1, 2, 0, 0, 1, 2, 0] #699
#rule = [0, 2, 0, 2, 0, 1, 0, 1, 1, 2, 2, 1, 2, 0, 2, 1, 2, 0, 0, 2, 2, 2, 1, 2, 2, 0, 1] #785
#rule = [0, 2, 0, 2, 0, 1, 0, 1, 1, 2, 1, 2, 0, 1, 2, 2, 1, 0, 0, 0, 2, 1, 2, 1, 1, 0, 2] #869
#rule = [0, 2, 0, 1, 1, 0, 0, 1, 2, 2, 2, 1, 0, 2, 1, 1, 2, 1, 0, 1, 2, 1, 2, 0, 0, 2, 2] #944
rule = [0, 2, 0, 1, 0, 2, 0, 1, 2, 2, 0, 1, 1, 2, 2, 1, 1, 2, 0, 1, 1, 0, 2, 0, 2, 0, 1] #978

agent=Agent(rule,3)

worlds=alignWorlds(testAgent(agent,maxYears))

#=
for world in worlds
    printOut(world)
end
=#

# Function to map a state (0, 1, or 2) to a color.
state_to_color(s::Int) = s == 0 ? RGB(1,1,1) : s == 1 ? RGB(1,0,0) : s == 2 ? RGB(0,0,1) : error("Invalid state: $s")

# Suppose `worlds` is your Vector{World} and each World has a field `states`
nrows = length(worlds)
ncols = length(worlds[1].states)

# Build the base image (each element is one "cell" or pixel)
img = Array{RGB{Float64}}(undef, nrows, ncols)
for i in 1:nrows
    for j in 1:ncols
        img[i, j] = state_to_color(worlds[i].states[j])
    end
end

# Flip the image vertically so that the first world appears at the top.
#img = reverse(img, dims=1)

# Define the pixel scale (each cell becomes a block of pixel_size x pixel_size)
pixel_size = 15

# Repeat each element to enlarge the image.
big_img = repeat(img, inner=(pixel_size, pixel_size))

# Save the enlarged image as a PNG.
save("worlds.png", big_img)

