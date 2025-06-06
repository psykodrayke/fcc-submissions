#!/bin/bash

# bash script for salon appointment scheduler

# postgresql helper
PSQL="psql -X -U freecodecamp -d salon --tuples-only -c"

# title
echo -e "\n~~~~~ Salon Appointment Scheduler ~~~~~\n"

# main menu
MAIN_MENU() {
  if [[ $1 ]]; then
    echo -e "\n$1"
  fi

  # display services
  echo "Select a service:"
  echo -e "1) cut\n2) color\n3) perm\n4) style\n5) trim\n6) exit"
  read SERVICE_ID_SELECTED

  # send to appointment scheduler
  case $SERVICE_ID_SELECTED in
    1|2|3|4|5)
      APPOINTMENT_MENU
      ;;
    6) EXIT ;;
    *) MAIN_MENU "Please enter a valid option." ;;
  esac

}

# appointment schedule prompt
APPOINTMENT_MENU () {
  # get customer info
  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE

  # get customer id
  CUSTOMER_ID=$($PSQL "select customer_id from customers where phone='$CUSTOMER_PHONE';")

  # if customer does not exist
  if [[ -z $CUSTOMER_ID ]]; then
    # get new customer name
    echo -e "\nWhat's your name?"
    read CUSTOMER_NAME

    # insert new customer
    INSERT_CUSTOMER_RESULT=$($PSQL "insert into customers (phone, name) values ('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
  fi

  # get customer id and name
  CUSTOMER_ID=$($PSQL "select customer_id from customers where phone='$CUSTOMER_PHONE'")
  CUSTOMER_NAME=$($PSQL "select name from customers where customer_id = $CUSTOMER_ID")

  # get requested appointment time
  echo -e "\nWhat time would you like to schedule the service?"
  read SERVICE_TIME

  # if service time is blank
  while [[ -z $SERVICE_TIME ]]; do
    echo -e "\nPlease enter an appointment time."
    read SERVICE_TIME
  done

  # insert appointment
  INSERT_APPOINTMENT_RESULT=$($PSQL "insert into appointments (customer_id, service_id, time) values ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

  # get service name
  SERVICE_NAME=$($PSQL "select name from services where service_id = $SERVICE_ID_SELECTED")

  # display confirmation message: I have put you down for a <service> at <time>, <name>.
  echo -e "\nI have put you down for a $(echo $SERVICE_NAME | sed -r 's/^ *| *$//g') at $(echo $SERVICE_TIME | sed -r 's/^ *| *$//g'), $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')."
}


EXIT() {
  echo -e "\nThank you for stopping in.\n"
}

MAIN_MENU
