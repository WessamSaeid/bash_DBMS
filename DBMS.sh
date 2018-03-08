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

datatypeSelect(){
  typeloop=1
  while [ $typeloop -eq 1 ]
  do
  echo "1-datatype is string"
  echo "2-datatype is number"
  read -p "choose the datatype of $colName column ,enter the number of your choice : " colType
  case $colType in
  1)
    echo -e -n ":string" >> ./database/$dbName/$tableName/meta_$tableName
    typeloop=0
    ;;

  2)
    echo -e -n ":number" >> ./database/$dbName/$tableName/meta_$tableName
    typeloop=0
    ;;
  *)
    echo "wrong entry please try again"
    datatypeSelect
    ;;
  esac
done
}

constraintSelect(){
  primaryloop=1
  while [ $primaryloop -eq 1 ]
  do
    echo "1-primary key"
    echo "2-not a primary key"
    read -p "for $colName column ,enter the number of your choice : " colprimary
    case $colprimary in
    1)
      echo -e ":pk" >> ./database/$dbName/$tableName/meta_$tableName
      primaryloop=0
      ;;

    2)
      echo -e -n ":" >> ./database/$dbName/$tableName/meta_$tableName
      read -p "Is $colName column must have unique values y/n: " unique
      if [[ $unique = "y" ]]
      then
        echo -e -n ":unique" >> ./database/$dbName/$tableName/meta_$tableName
      else
        echo -e -n ":" >> ./database/$dbName/$tableName/meta_$tableName
      fi
      read -p "Is $colName column can accept null values y/n: " nullvalue
      if [ $nullvalue = "y" ]
      then
        echo -e ":null" >> ./database/$dbName/$tableName/meta_$tableName
      else
        echo -e ":notnull" >> ./database/$dbName/$tableName/meta_$tableName
      fi
      primaryloop=0
      ;;

    *)
      echo "wrong entry please try again"
      constraintSelect
      ;;
    esac
  done
}

createTable(){
  read -p "enter table name : " tableName
  if [ -d ./database/$dbName/$tableName ]
  then
    echo "this name is already exists please try again"
    createTable
  else
    mkdir ./database/$dbName/$tableName
    touch ./database/$dbName/$tableName/meta_$tableName
    touch ./database/$dbName/$tableName/data_$tableName
    #read -p "enter the primary key column name : " primarycol
    read -p "enter the number of columns : " colNum

    for i in $(seq $colNum)
    do
      read -p "enter the name of column $i : " colName
      echo -n $colName >> ./database/$dbName/$tableName/meta_$tableName
      datatypeSelect
      constraintSelect
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
    echo "1-show tables"
    echo "2-create new table"
    echo "3-alter table"
    echo "00-back"


    read -p "enter your choice: " choice

    case $choice in
    1)
      echo "======================="
      echo "existing tables :"
      echo $(ls ./database/$dbName)
      echo "======================="
      ;;

    2)
      createTable
      ;;

    00)
      loop=0
      ;;

    *)
      echo wrong entry
      ;;
    esac
    done
  fi

}

#trap 'echo "signal is trapped "' 2 20
while true
do
echo "========================"
echo "1-create new database"
echo "2-use database"
echo "0-exit"

read -p "enter your choice: " choice

case $choice in
1)
  createDB
  ;;

2)
  useDB
  ;;

0)
  break
  ;;

*)
  echo wrong entry
  ;;
esac
done
