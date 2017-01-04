"""
    ϵ-Greedy Implementation
"""

type epsGreedy <: BanditAlgorithmBase
    noOfArms::Int64
    noOfSteps::Int64
    lastPlayedArm::Int64

    ϵ::Float64
    cummReward::Vector{Float64}
    count::Vector{Int64}
    avgValue::Vector{Float64}

    function epsGreedy( noOfArms::Int64, ϵ::Float64 )
        new( noOfArms,
             0,
             0,
             ϵ,
             zeros(Float64,noOfArms),
             zeros(Int64,noOfArms),
             zeros(Float64,noOfArms)
        )
    end
end

function getArmIndex( agent::epsGreedy )
    if any(agent.count.==0)
        agent.lastPlayedArm = rand( find(agent.count.==0) )
    else
        if rand() > agent.ϵ
            agent.lastPlayedArm = findmax(agent.avgValue)[2]
        else
            agent.lastPlayedArm = rand(1:agent.noOfArms)
        end
    end
    return agent.lastPlayedArm
end

function updateReward( agent::epsGreedy, r::Real )
    agent.cummReward[agent.lastPlayedArm] += r
    agent.count[agent.lastPlayedArm] += 1
    agent.noOfSteps += 1

    agent.avgValue[agent.lastPlayedArm] = agent.cummReward[agent.lastPlayedArm] ./
                                            agent.count[agent.lastPlayedArm]
end

function reset( agent::epsGreedy )
    agent.noOfSteps     = 0
    agent.lastPlayedArm = 0

    agent.cummReward    = zeros( Float64, agent.noOfArms )
    agent.count         = zeros( Int64, agent.noOfArms )
    agent.avgValue      = zeros( Float64, agent.noOfArms )
end

function info_str( agent::epsGreedy )
    return @sprintf( "ϵ-Greedy (ϵ = %4.3f)", agent.ϵ )
end


"""
    ϵ_n Greedy Implementation
    Based on Auer, P., Bianchi, N. C., & Fischer, P. (2002). Finite time analysis of the multiarmed bandit problem. Machine Learning, 47, 235–256.
"""

type epsNGreedy <: BanditAlgorithmBase
    noOfArms::Int64
    noOfSteps::Int64
    lastPlayedArm::Int64

    param_c::Float64
    param_d::Float64
    ϵ::Float64

    cummReward::Vector{Float64}
    count::Vector{Int64}
    avgValue::Vector{Float64}

    function epsNGreedy( noOfArms::Int64, param_c::Real, param_d::Float64 )
        new( noOfArms,
             0,
             0,
             param_c,
             param_d,
             1,
             zeros(Float64,noOfArms),
             zeros(Int64,noOfArms),
             zeros(Float64,noOfArms)
        )
    end

    function epsNGreedy( noOfArms::Int64 )
        new( noOfArms,
             0,
             0,
             1/noOfArms,
             1,
             1,
             zeros(Float64,noOfArms),
             zeros(Int64,noOfArms),
             zeros(Float64,noOfArms)
        )
    end
end

function getArmIndex( agent::epsNGreedy )
    if any(agent.count.==0)
        agent.lastPlayedArm = find(agent.count.==0)[1]
    else
        if rand() > agent.ϵ
            agent.lastPlayedArm = findmax(agent.avgValue)[2]
        else
            agent.lastPlayedArm = rand(1:agent.noOfArms)
        end
    end
    return agent.lastPlayedArm
end

function updateReward( agent::epsNGreedy, r::Real )
    # Book keeping
    agent.cummReward[agent.lastPlayedArm] += r
    agent.count[agent.lastPlayedArm] += 1
    agent.noOfSteps += 1

    # Update the observed reward to the corresponding arm
    agent.avgValue[agent.lastPlayedArm] = agent.cummReward[agent.lastPlayedArm] ./
                                            agent.count[agent.lastPlayedArm]

    # Also change the exploration rate
    agent.ϵ     = min( 1, (agent.param_c*agent.noOfArms)/(agent.param_d*agent.noOfSteps) )
end

function reset( agent::epsNGreedy )
    agent.noOfSteps     = 0
    agent.lastPlayedArm = 0
    agent.ϵ             = 1

    agent.cummReward    = zeros( Float64, agent.noOfArms )
    agent.count         = zeros( Int64, agent.noOfArms )
    agent.avgValue      = zeros( Float64, agent.noOfArms )
end

function info_str( agent::epsNGreedy )
    return @sprintf( "ϵ_N - Greedy (c = %4.3f, d = %4.3f)", agent.param_c, agent.param_d )
end
