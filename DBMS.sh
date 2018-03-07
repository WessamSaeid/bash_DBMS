#!/bin/bash
createDB(){
  read -p "enter database name : " dbName
  if [ -d ./database/$dbName ]
  then
    echo "this name is already exists please try again"
    createDB
  else
    mkdir ./database/$dbName
    echo "$dbName database is created successfully"
    echo "========================================="
  fi
}

showDB(){
  echo "======================="
  echo "existing databases :"
  echo $(ls ./database)
  echo "======================="
}

createTable(){
  read -p "enter table name : " tableName
  if [ -f ./database/$dbName/$tableName ]
  then
    echo "this name is already exists please try again"
    createTable
  else
    touch ./database/$dbName/$tableName
    read -p "enter the primary key column name : " primarycol
    read -p "enter the number of columns  : " colNum

    for i in $(seq $colNum)
    do
      read -p "enter the name of column $i" colName
      read -p "enter the type of $colName column " colType
      
    done
    echo "$tableName table is created successfully"
    echo "========================================="
  fi
}

useDB(){
  showDB
  read -p "enter the database you want to use : " dbName
  if [ ! -d ./database/$dbName ]
  then
    echo "not a valid existing database name please try again "
    useDB
  else
    loop=1
    while [ $loop -eq 1 ]
    do
    echo "===================="
    echo "20-show tables"
    echo "21-create new table"
    echo "22-alter table"
    echo "30-back"


    read -p "enter your choice: " choice

    case $choice in
    20)
      echo "======================="
      echo "existing tables :"
      echo $(ls ./database/$dbName)
      echo "======================="
      ;;

    21)
      createTable
      ;;

    30)
      loop=0
      ;;

    *)
      echo wrong entry
      ;;
    esac
    done
  fi

}

trap 'echo "signal is trapped "' 2 20
while true
do
echo "========================"
echo "1-create new database"
echo "2-use database"
echo "3-exit"

read -p "enter your choice: " choice

case $choice in
1)
  createDB
  ;;

2)
  useDB
  ;;

3)
  break
  ;;

*)
  echo wrong entry
  ;;
esac
done
