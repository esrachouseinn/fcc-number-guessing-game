#!/bin/bash

# variable to query database
PSQL="psql --username=freecodecamp --dbname=db_users -t --no-align -c"

# prompt player for username
echo -e "\nEnter your username:"
read USERNAME

# get user id and data
USER_ID_RESULT=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")
GAMES_PLAYED=$($PSQL "SELECT COUNT(game_id) FROM games WHERE user_id='$USER_ID_RESULT'")
BEST_GAME=$($PSQL "SELECT MIN(number_of_guesses) FROM games WHERE user_id='$USER_ID_RESULT'")

# if player is not found 
if [[ -z $USER_ID_RESULT ]]
then
    # greet player
    echo -e "\nWelcome, $USERNAME! It looks like this is your first time here.\n"
    # add player to database
    INSERT_USERNAME_RESULT=$($PSQL "INSERT INTO users(username) VALUES ('$USERNAME')")
    # set games_played and best_game as default values
    GAMES_PLAYED=0
    BEST_GAME="N/A"
else
    echo -e "\nWelcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

# generate random number between 1 and 1000
SECRET_NUMBER=$(( RANDOM % 1000 + 1 ))

# variable to store number of guesses/tries
GUESS_COUNT=0

# prompt first guess
echo "Guess the secret number between 1 and 1000:"
read USER_GUESS

# loop to prompt user to guess until correct
until [[ $USER_GUESS -eq $SECRET_NUMBER ]]
do
    # check guess is valid/an integer
    if [[ ! $USER_GUESS =~ ^[0-9]+$ ]]
    then
        # request valid guess
        echo -e "\nThat is not an integer, guess again:"
    else
        # check inequalities and give hint
        if [[ $USER_GUESS -lt $SECRET_NUMBER ]]
        then
            echo "It's higher than that, guess again:"
        else 
            echo "It's lower than that, guess again:"
        fi  
    fi

    # prompt for the next guess
    read USER_GUESS
    # update guess count
    ((GUESS_COUNT++))
done

# loop ends when guess is correct so, update guess count
((GUESS_COUNT++))

# get user id
USER_ID_RESULT=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")

# add result to game history/database
INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(user_id, secret_number, number_of_guesses) VALUES ($USER_ID_RESULT, $SECRET_NUMBER, $GUESS_COUNT)")

# winning message
echo "You guessed it in $GUESS_COUNT tries. The secret number was $SECRET_NUMBER. Nice job!"
