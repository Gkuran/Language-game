# -------------------------------------------------------------------------------
#								Packages
# -------------------------------------------------------------------------------

using OffsetArrays, StructArrays, Printf, DelimitedFiles, Statistics, Random


# -------------------------------------------------------------------------------
#								Initialization
# -------------------------------------------------------------------------------

mutable struct Countries_struct
	index::Int64
	name::String
    language::Vector{String, Int64, Int64} # language, lexical_density, semantic_precision
	score::Float64
	coordinates::Tuple
	neighbors::Vector{String}
end

	
function initialize_countries(countries) 

	countries[1] = Countries_struct(1, "Brazil", "portuguese", 0, ...)
	countries[2] = Countries_struct(2, "Argentina", "Spanish", 0, ...)
	# ...

end

function set_neighbors(viz) 
	#= 
	para cada país
		ver se coordenada de outro país está dentro de raio r
		se sim, push(país, neighbors)
	=#
end

# -------------------------------------------------------------------------------
#								Payoff calculation
# -------------------------------------------------------------------------------

function score_calculation(countries, i) 

	A = 0.5
	B = 0.5

	countries[i].score = A * countries[i].lexical_density + B * countries[i].semantic_precision

	#@printf "%d \n" countries[i].score
end	



# -------------------------------------------------------------------------------
#								Update rule
# -------------------------------------------------------------------------------

function update_rule(countries, i, j)

	Δ = countries[j].score-countries[i].score
	β = 1/0.1
	Wxy = 1.0/(1.0 + exp(-β*Δ))
	a = rand()

	if Wxy > a
		countries[i].language = countries[j].language
	end
end

# -------------------------------------------------------------------------------
#								Monte Carlo Step
# -------------------------------------------------------------------------------
function mcs(countries)

	for n in 0:N-1

		# selecionar país I
		# selecionar país dentro de countries.neighbors j
	
		score_calculation(countries, i)
		score_calculation(countries, j)
		
		update_rule(countries, i, j)		
	end
end

# -------------------------------------------------------------------------------
#								Time dynamics
# -------------------------------------------------------------------------------
function time_dynamics(countries)

	for t in 1:tmax
		mcs(countries)   	
    end
end

# -------------------------------------------------------------------------------
#								Save data
# -------------------------------------------------------------------------------
function save_data(variable, i)

	t=1:tmax
	directoryPath = string(@__DIR__, "/data/")
	filename = @sprintf("%sdata%d_p%.3f.dat",directoryPath, i, r)
	writedlm(filename,[t variable])
end

# -------------------------------------------------------------------------------
#								Main
# -------------------------------------------------------------------------------
function main(n,r,K)

	countries = OffsetArray{Countries_struct, 1}(undef, 0:N-1) 
	variable = OffsetArray{Float64}(undef, 0:tmax)

	variable .= 0

	initialize_countries(countries)
	set_neighbors()
	time_dynamics(countries, variable)
	save_data(variable, i)
end

# -------------------------------------------------------------------------------
#								Parameters
# -------------------------------------------------------------------------------

const tmax=10^4

Random.seed!() # put number inside () to fix seed
main()

# tarefas
# organizar dados wals
# criar coordenadas mapa topologico
# subdividir os paises