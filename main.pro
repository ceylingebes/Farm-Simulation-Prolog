% Huriye Ceylin Gebeş
% 2021400306
% compiling: yes
% complete: yes


:- ['cmpefarm.pro'].
:- init_from_map.


% 1- agents_distance(+Agent1, +Agent2, -Distance)
% Computes the Manhattan distance between two agents DONE
agents_distance(Agent1, Agent2, Distance):-
    get_dict(x, Agent1, X1),
    get_dict(x, Agent2, X2),
    get_dict(y, Agent1, Y1),
    get_dict(y, Agent2, Y2),
    Distance is abs(X1 - X2) + abs(Y1 - Y2).


% 2- number_of_agents(+State, -NumberOfAgents)

% 3- value_of_farm(+State, -Value)

% 4- find_food_coordinates(+State, +AgentId, -Coordinates)

% 5- find_nearest_agent(+State, +AgentId, -Coordinates, -NearestAgent)

% 6- find_nearest_food(+State, +AgentId, -Coordinates, -FoodType, -Distance)

% 7- move_to_coordinate(+State, +AgentId, +X, +Y, -ActionList, +DepthLimit)

% 8- move_to_nearest_food(+State, +AgentId, -ActionList, +DepthLimit)

% 9- consume_all(+State, +AgentId, -NumberOfMoves, -Value, NumberOfChildren +DepthLimit)


