#! /bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ Alan's Salon ~~~~~\n"

MAIN_MENU() {
  if [[ $1 ]]
    then
      echo -e "\n$1"
    else
      echo "Welcome to Alan's Salon!"
  fi

  #show services
  SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")
  echo "$SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done

  #ask for service
  echo -e "\nWhat would you like today?"
  read SERVICE_ID_SELECTED

  #if not a number
  if [[ ! $SERVICE_ID_SELECTED =~ ^[1-4]+$ ]]
    then
      #send to main menu
      MAIN_MENU "That is not one of my services!"
    else
      echo -e "\nWhat's your phone number?"
      read CUSTOMER_PHONE
      #check if customer exists
      CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
      if [[ -z $CUSTOMER_NAME ]]  #customer doesn't exist
        then
          echo -e "\nI don't have you on our records.\nWhat is your name?"
          read CUSTOMER_NAME
          # insert new customer
          INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
          if [[ $INSERT_CUSTOMER_RESULT == "INSERT 0 1" ]]
            then
              echo Inserted into customers, $CUSTOMER_PHONE, $CUSTOMER_NAME
          fi
      fi
      #get customer_id
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
      #get service name
      SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
      #strip out leading and trailing spaces
      SERVICE_NAME=$(echo $SERVICE_NAME | sed -E 's/^ *| *$//g')
      CUSTOMER_NAME=$(echo $CUSTOMER_NAME | sed -E 's/^ *| *$//g')
      #get time
      echo -e "\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
      read SERVICE_TIME
      #insert appointment
      INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(time, customer_id, service_id) VALUES('$SERVICE_TIME', $CUSTOMER_ID, $SERVICE_ID_SELECTED)")
      if [[ $INSERT_APPOINTMENT_RESULT == "INSERT 0 1" ]]
        then
          echo Inserted into appointments, $SERVICE_TIME, $CUSTOMER_ID, $SERVICE_ID_SELECTED
      fi
      #inform user
      echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME.\n"
  fi
}

MAIN_MENU
