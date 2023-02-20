#!/bin/bash

#pg_dump -cC --inserts -U freecodecamp number_guess > number_guess.sql

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

#TRUNCATE_TABLE=$($PSQL "TRUNCATE users")

echo "Enter your username:"
read USERNAME

USER_INFO=$($PSQL "SELECT games_played, best_game FROM users WHERE name='$USERNAME'")
if [[ -z $USER_INFO ]]
then
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  CREATE_USER=$($PSQL "INSERT INTO users (name) VALUES ('$USERNAME')")
  BEST_GAME=1000
else
  IFS='|' read GAMES_PLAYED BEST_GAME <<< $(echo $USER_INFO)
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi
echo "Guess the secret number between 1 and 1000:"

SECRET_NUMBER=$(($RANDOM%1000))
NUMBER_OF_GUESSES=1

while [[ $GUESS != $SECRET_NUMBER ]]
do
  read GUESS
  if [[ $GUESS =~ ^[0-9]+ ]]
  then
    if [[ $GUESS -lt $SECRET_NUMBER ]]
    then
      echo "It's higher than that, guess again:"
      NUMBER_OF_GUESSES=$((++NUMBER_OF_GUESSES))
    elif [[ $GUESS -gt $SECRET_NUMBER ]]
    then
      echo "It's lower than that, guess again:"
      NUMBER_OF_GUESSES=$((++NUMBER_OF_GUESSES))
    fi
  else
    echo "That is not an integer, guess again:"
  fi
done
if [[ $NUMBER_OF_GUESSES -lt $BEST_GAME ]]
then
  UPDATE_BEST=$($PSQL "UPDATE users SET best_game=$NUMBER_OF_GUESSES WHERE name='$USERNAME'")
fi
echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"
UPDATE_GAMES=$($PSQL "UPDATE users SET games_played=$((++GAMES_PLAYED)) WHERE name='$USERNAME'")
