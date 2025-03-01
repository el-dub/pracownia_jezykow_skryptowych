#!/bin/bash

board=(" " " " " " " " " " " " " " " " " ")
player="X"

display_board() {
    echo " ${board[0]} | ${board[1]} | ${board[2]} "
    echo "---+---+---"
    echo " ${board[3]} | ${board[4]} | ${board[5]} "
    echo "---+---+---"
    echo " ${board[6]} | ${board[7]} | ${board[8]} "
    echo
}

validate_cell() {
    index=$1

    if [[ $index -lt 1 || $index -gt 9 || ${board[$index-1]} == "X" || ${board[$index-1]} == "O" ]]; then
        echo "Invalid move. Try again."
        return 1
    fi

    return 0
}

check_end() {
    for cell in "${board[@]}"; do
        if [[ $cell != "X" && $cell != "O" ]]; then
            return 0
        fi
    done

    return 1
}

check_winner() {
    for i in {0..2}; do
        if [[ ${board[$((i*3))]} == ${board[$((i*3+1))]} && ${board[$((i*3))]} == ${board[$((i*3+2))]} ]]; then
            echo "${board[$((i*3))]}"
            return
        fi
    done

    for i in {0..2}; do
        if [[ ${board[$i]} == ${board[$((i+3))]} && ${board[$i]} == ${board[$((i+6))]} ]]; then
            echo "${board[$i]}"
            return
        fi
    done

    if [[ (${board[0]} == ${board[4]} && ${board[4]} == ${board[8]}) || (${board[2]} == ${board[4]} && ${board[4]} == ${board[6]}) ]]; then
        echo "${board[4]}"
        return
    fi

    return
}

start_new_game() {
    echo "New game:"
    board=(" " " " " " " " " " " " " " " " " ")
    player="X"
}

while true; do
    display_board

    echo "Player ${player} enter the cell number:"
    read -r cell
    if ! validate_cell "$cell"; then
        continue
    else
        board[$((cell-1))]=$player
    fi

    if [[ $(check_winner) == "X" || $(check_winner) == "O" ]]; then
        echo "Player ${player} wins!"
        start_new_game
        continue
    elif ! check_end; then
        echo "It's a draw!"
        start_new_game
        continue
    fi

    if [[ $player == "X" ]]; then
        player="O"
    else
        player="X"
    fi
done
