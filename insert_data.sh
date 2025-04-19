#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
#!/bin/bash

# Чтение и вставка команд в таблицу teams
cat games.csv | while IFS=',' read year round winner opponent winner_goals opponent_goals
do
  # Пропускаем заголовок CSV файла
  if [[ "$year" != "year" ]]
  then
    # Вставка команд в таблицу teams, если они еще не существуют
    $PSQL "INSERT INTO teams (name) SELECT '$winner' WHERE NOT EXISTS (SELECT 1 FROM teams WHERE name = '$winner');"
    $PSQL "INSERT INTO teams (name) SELECT '$opponent' WHERE NOT EXISTS (SELECT 1 FROM teams WHERE name = '$opponent');"

    # Получаем team_id для победителя и оппонента
    winner_id=$($PSQL "SELECT team_id FROM teams WHERE name = '$winner';")
    opponent_id=$($PSQL "SELECT team_id FROM teams WHERE name = '$opponent';")

    # Вставка игры в таблицу games
    $PSQL "INSERT INTO games (year, round, winner_id, opponent_id, winner_goals, opponent_goals) 
            VALUES ($year, '$round', $winner_id, $opponent_id, $winner_goals, $opponent_goals);"
  fi
done
