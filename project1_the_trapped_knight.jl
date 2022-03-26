# Initializes the board on a [-n:n]x[-n:n] domain with spiral numbers
#
# Example: initialize_board(2) returns
# 17 16 15 14 13
# 18  5  4  3 12
# 19  6  1  2 11
# 20  7  8  9 10
# 21 22 23 24 25
#
# Inputs:
#  n     = integer size of board to allocate
# Outputs: 
#  board = 2n+1 x 2n+1 integer array filled with spiral numbers
using Plots

function initialize_board(n)
    # some helper functions to move the coordinates
    move_up = (x,y) -> (x-1, y)
    move_down = (x,y) -> (x+1, y)
    move_left = (x,y) -> (x, y-1)
    move_right = (x,y) -> (x, y+1)
    # starting from the center of the board, we need to move in a spiral
    # so the steps goes right, up, left, left, down, down, right * 3, ...
    # the direction is right, up, left, down
    action_loop = [move_right, move_up, move_left, move_down]
    # the step size changes every two turns, starting from 1 step
    action_time = 1
    
    # the result is a 2D matrix of size 2n+1 x 2n+1
    result = zeros(Int32, 2*n+1, 2*n+1)
    # start filling the matrix from center
    current = 1
    x = n + 1
    y = n + 1
    step = 0
    directions = 1
    result[x,y] = current
    
    # start moving in spiral

    while current < (2*n+1) * (2*n+1)
        # move in the current direction, for action_time steps
        for i in 1:action_time
            # move in the current direction
            x,y = action_loop[directions](x,y)
            # if we are still in the board, fill the cell
            current += 1
            if current > (2*n+1) * (2*n+1)
                break
            end
            result[x,y] = current
        end
        # change direction
        directions += 1
        # if we are done travelling down, then go to right again
        if directions == 5
            directions = 1
        end
        # increase the step size, 0.5 because the directions change happens every two turns
        action_time += 0.5
    end
    return result
end

# Simulates the trapped knight walk on a pre-initialized board and returns information about knight walk.
# 
# Inputs: 
#  board    = 2n+1 x 2n+1 integer array filled with spiral numbers
# Outputs: 
#  sequence = integer array containing the sequence of spiral numbers the knight jumped to during walk
#  x_path   = integer array containing the x coordinates of each step of knight walk
#  y_path   = integer array containing the y coordinates of each step of knight walk
# Simulates the trapped knight walk on a pre-initialized board and returns information about knight walk.
# 
# Inputs: 
#  board    = 2n+1 x 2n+1 integer array filled with spiral numbers
# Outputs: 
#  sequence = integer array containing the sequence of spiral numbers the knight jumped to during walk
#  x_path   = integer array containing the x coordinates of each step of knight walk
#  y_path   = integer array containing the y coordinates of each step of knight walk
function simulate_walk(board)

    function possible_jumps(board, x, y, values_avoid)
        jumps = [
            (2, 1), (2, -1), (-2, 1), (-2, -1),
            (1, 2), (1, -2), (-1, 2), (-1, -2)
        ]
        smallest_value_seemed = 100000000
        smallest_jump_x = -100
        smallest_jump_y = -100
        for (tx, ty) in jumps
            
            if x+tx < 1 || y+ty < 1 || x+tx > total_height || y+ty > total_height
                continue
            end
            if board[x+tx,y+ty] < smallest_value_seemed && !in(board[x+tx,y+ty], values_avoid)
                smallest_value_seemed = board[x+tx,y+ty]
                smallest_jump_x = tx
                smallest_jump_y = ty
            end
        end
        if smallest_jump_x == -100
            return -100, -100, -1
        end
        return smallest_jump_x, smallest_jump_y, smallest_value_seemed
    end

    sequence = [1] # it must start with 1
    total_height = size(board,1)
    n::Int32 = (total_height - 1) / 2
    x::Int32 = n + 1
    y::Int32 = n + 1
    x_path = [x - n - 1] # 0 centered on the board
    y_path = [y - n - 1] # 0 centered on the board

    # the helper function to get the possible positions the knight can jump to
    

    # the main loop
    tx, ty, next_value = possible_jumps(board, x, y, sequence)
    while tx != -100
        x += tx
        y += ty
        push!(sequence, next_value)
        push!(x_path, x - n - 1)
        push!(y_path, y - n - 1)
        tx, ty, next_value = possible_jumps(board, x, y, sequence)
    end
    return sequence, x_path, y_path
end





board = initialize_board(2);
display(board)
println("\n")
seq, xs, ys = simulate_walk(board);
println("Sequence = ", seq)
println("x-coordinates = ", xs)
println("y-coordinates = ", ys)

# now the full sequence, too big to display
board = initialize_board(100)
seq, xs, ys = simulate_walk(board);

println("Sequence ends with: ", seq[end])

# plot the walk path defined by xs and ys, to "output.png"
fig = plot(xs, ys)
png(fig, "output.png")