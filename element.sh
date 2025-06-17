#!/bin/bash
# Script to retrieve data from periodic table of elements database
PSQL="psql -X -U freecodecamp -d periodic_table -t -c"

INPUT_TYPE=""
INPUT_VALUE=""

DB_LOOKUP() {
  # database lookup using input value and regex matched query type
  ELEMENT_ID=$($PSQL "SELECT atomic_number FROM elements WHERE $INPUT_TYPE = '$INPUT_VALUE';")
  #if result is empty
  if [[ -z $ELEMENT_ID ]]; then
    echo I could not find that element in the database.
  else
    # get data and build output
    ELEMENT_DATA=$($PSQL "select atomic_number, name, symbol, type, atomic_mass, melting_point_celsius, boiling_point_celsius from elements join properties using (atomic_number) join types using (type_id) where atomic_number = $ELEMENT_ID limit 1;")
    echo "$ELEMENT_DATA" | while read ATOMIC_NUMBER BAR NAME BAR SYMBOL BAR TYPE BAR ATOMIC_MASS BAR MELTING_POINT BAR BOILING_POINT
    do
      echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $ATOMIC_MASS amu. $NAME has a melting point of $MELTING_POINT celsius and a boiling point of $BOILING_POINT celsius."
    done
  fi
}

# if input empty
if [[ -z $1 ]]; then
  # ask for input
  echo Please provide an element as an argument.
else
  INPUT_VALUE="$1"
  # if input is a number
  if [[ $INPUT_VALUE =~ ^[0-9]{1,3}$ ]]; then
    # assign query type and call database function
    INPUT_TYPE="atomic_number"
    DB_LOOKUP
  # if input is a symbol
  elif [[ $INPUT_VALUE =~ ^[A-Z][a-z]?$ ]]; then
    INPUT_TYPE="symbol"
    DB_LOOKUP
  # if input is a name
  elif [[ $INPUT_VALUE =~ ^[A-Z][a-z]+$ ]]; then
    INPUT_TYPE="name"
    DB_LOOKUP
  # Bad Input
  else
    echo I could not find that element in the database.
  fi
fi
