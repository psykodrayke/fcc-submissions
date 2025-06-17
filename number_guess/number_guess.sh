#!/bin/bash
# Script for Number Guessing Game
PSQL="psql -U freecodecamp -d number_guess -t -A -c"

# generate random number
SECRET_NUMBER=$(( RANDOM % 1000 + 1 ))

NUM_GUESSES=0

# request username
echo Enter your username:
read USERNAME

# if username empty
while [[ -z "$USERNAME" ]]; do
  # request username
  echo Enter your username:
  read USERNAME
done

USER_ID=$($PSQL "select user_id from users where username = '$USERNAME' limit 1;")
# if username empty
if [[ -z $USER_ID ]]; then
  # create new user 
  INSERT_USER_RESULT=$($PSQL "insert into users (username) values ('$USERNAME');")
  if [[ $INSERT_USER_RESULT = "INSERT 0 1" ]]; then
    # fetch new user id
    USER_ID=$($PSQL "select user_id from users where username = '$USERNAME' limit 1;")

    # print welcome
    echo "Welcome, $USERNAME! It looks like this is your first time here."
  fi
else
  GAMES_PLAYED=$($PSQL "select count(*) as total_games from games where user_id = $USER_ID;")
  BEST_GAME=$($PSQL "select min(number_of_guesses) from games where user_id = $USER_ID;")
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

# print request for first guess
echo "Guess the secret number between 1 and 1000:"
read USER_GUESS

until [[ $USER_GUESS -eq $SECRET_NUMBER ]]; do
  # increment number of guesses
  ((NUM_GUESSES++))

  # if input is NaN (1 - 1000)
  if [[ ! $USER_GUESS =~ ^([1-9][0-9]{0,2}|1000)$ ]]; then
    # print NaN msg
    echo "That is not an integer, guess again:"
    read USER_GUESS
  else
    # if input higher
    if [[ $USER_GUESS -gt $SECRET_NUMBER ]]; then
      # print lower msg
      echo "It's lower than that, guess again:"
      read USER_GUESS
    else
      # print higher msg
      echo "It's higher than that, guess again:"
      read USER_GUESS
    fi
  fi
done

# increment final guess
((NUM_GUESSES++))

INSERT_GAME_DATA_RESULT=$($PSQL "insert into games (user_id, number_of_guesses) values ($USER_ID, $NUM_GUESSES);")

if [[ $INSERT_GAME_DATA_RESULT == "INSERT 0 1" ]]; then
  # print win msg
  echo "You guessed it in $NUM_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"
fi