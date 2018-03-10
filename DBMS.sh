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
      if [[ i -eq 1 ]]
      then
        read -p "enter the name of the primary key column : " colName
        echo -n $colName >> ./database/$dbName/$tableName/meta_$tableName
        datatypeSelect
        echo -e ":pk" >> ./database/$dbName/$tableName/meta_$tableName
      else
        read -p "enter the name of column $i : " colName
        echo -n $colName >> ./database/$dbName/$tableName/meta_$tableName
        datatypeSelect
        constraintSelect
      fi
    done
    echo "$tableName table is created successfully"
    echo "========================================="
  fi
}

displaytable(){
   read -p "enter the name of table you want to  display  its discription" tableName
  if [ ! -d ./database/$dbName/$tableName ]
    then
    echo "not a valid existing table name please try again "
    displaytable
  else
  echo "======================================="
  echo "discription of table $tableName"
  cat ./database/$dbName/$tableName/meta_$tableName


  fi

}
droptable(){
  read -p "enter the name of table you want to drop" tableName
  if [ ! -d ./database/$dbName/$tableName ]
    then
    echo "not a valid existing table name please try again "
    droptable
  else
  rm -r ./database/$dbName/$tableName
  echo " existing $tableName is deleted "

  fi

}
alterTable(){
  showTables
  read -p "enter the table name that you want to alter : " tableName
  if [ ! -d ./database/$dbName/$tableName ]
  then
    echo "not a valid existing table name please try again "
    alterTable
  else
    alterloop=1
    while [ $alterloop -eq 1 ]
    do
    echo "===================="
    echo "1-change table name"
    echo "2-add new column"
    echo "3-change datatype of a certain column"
    echo "4-delete column"
    echo "00-back"


    read -p "enter your choice: " choice

    case $choice in
    1)
      read -p "enter new name : " newtableName
      mv ./database/$dbName/$tableName/meta_$tableName ./database/$dbName/$tableName/meta_$newtableName
      mv ./database/$dbName/$tableName/data_$tableName ./database/$dbName/$tableName/data_$newtableName
      mv ./database/$dbName/$tableName ./database/$dbName/$newtableName
      tableName=$newtableName
      echo "table is renamed successfully"
      ;;

    2)
      read -p "enter the name of the new column  : " colName
      echo -n $colName >> ./database/$dbName/$tableName/meta_$tableName
      datatypeSelect
      constraintSelect
      echo "$colName column is added to $tableName successfully"
      ;;

    4)
      read -p "enter the name of column to be deleted  : " colName
      sed '/'$colName'/d' ./database/$dbName/$tableName/meta_$tableName >> ./database/$dbName/$tableName/meta_$tableName
      ;;



    00)
      alterloop=0
      ;;

    *)
      echo wrong entry
      ;;
    esac
    done
  fi
}

checkthirdfield(){
  flag=1

    if [[ "$thirdfield" = pk ]]
           then
           if [[ "$firstfieldval" != "" ]]
            then
            exists=$(awk 'BEGIN {FS=":"} {print $1}' ./database/$dbName/$tableName/data_$tableName)

            if [[ $exists = "" ]]
              then
               echo -n "$firstfieldval" >> ./database/$dbName/$tableName/data_$tableName
               echo -n ":" >> ./database/$dbName/$tableName/data_$tableName
            else
            for i in $exists
            do

              if [ $i == $firstfieldval ]
                then
                 echo "duplicated value ,must be unique"
                 checkConstrains
                 flag=1
                 break
              else
                flag=0
              fi
            done
            if [[ $flag = 0 ]]
              then
               echo -n "$firstfieldval" >> ./database/$dbName/$tableName/data_$tableName
               echo -n ":" >> ./database/$dbName/$tableName/data_$tableName

            fi



           fi


          else
            echo "error ! must be a not NULL"
            checkConstrains
         fi
   else
    checkfourthfield
    fi


}
checkfourthfield(){
  if [[ "$fourthfield" = unique ]]
          then
          if [[ "$firstfieldval" != "" ]]
            then
            exists=$(awk 'BEGIN {FS=":"} {print $j}' ./database/$dbName/$tableName/data_$tableName)
            echo $exists
            if [[ $exists = "" ]]
              then
               echo -n "$firstfieldval" >> ./database/$dbName/$tableName/data_$tableName
               echo -n ":" >> ./database/$dbName/$tableName/data_$tableName
            else
            for i in $exists
            do

              if [ $i == $firstfieldval ]
                then
                 echo "duplicated value ,must be unique"
                 checkConstrains
                 flag=1
                 break
              else
                flag=0
              fi
            done
            if [[ $flag = 0 ]]
              then
               echo -n "$firstfieldval" >> ./database/$dbName/$tableName/data_$tableName
               echo -n ":" >> ./database/$dbName/$tableName/data_$tableName

            fi



           fi


          else

            checkfifthfield
         fi



  else
    checkfifthfield
  fi

}
checkfifthfield(){

if [[ "$fifthfield" != null ]]
  then
   if [[ "$firstfieldval" = "" ]]
    then
    echo "error ! must be not null"
    checkConstrains
   else
     echo -n -e "$firstfieldval" >> ./database/$dbName/$tableName/data_$tableName
      echo -n ":" >> ./database/$dbName/$tableName/data_$tableName
   fi
else
   echo -n -e "$firstfieldval" >> ./database/$dbName/$tableName/data_$tableName

fi

}

checkConstrains(){

    firstfield=$(echo "$j" | cut -d ":" -f 1)
    secondfield=$(echo "$j" | cut -d ":" -f 2)
    thirdfield=$(echo "$j" | cut -d ":" -f 3)
    fourthfield=$(echo "$j" | cut -d ":" -f 4)
    fifthfield=$(echo "$j" | cut -d ":" -f 5)
    read -p "enter value of $firstfield" firstfieldval
    if [[ "$secondfield" = number ]]
    then
       if [[ "$firstfieldval" =~ ^[0-9]+$  || "$firstfieldval" =~ ^$ ]]
        then
         checkthirdfield
       else
        echo "invalid for $firstfield"
        checkConstrains
       fi
    fi

    if [[ "$secondfield" = string ]]
    then
      if [[ "$firstfieldval" =~ ^[a-zA-Z]+ || "$firstfieldval" =~ ^$ ]]
       then
        checkthirdfield
      else
        echo "invalid for $firstfield"
        checkConstrains
      fi
    fi
}
insertRecord(){

  read -p "enter table name : " tableName
  if [ ! -d ./database/$dbName/$tableName ]
  then
    echo "this name is not exists please try again"
    insertRecord
  else
    num= cat ./database/$dbName/$tableName/meta_$tableName | wc -l
    echo $num
    for j in `cat ./database/$dbName/$tableName/meta_$tableName `
    do
     checkConstrains
    done
     echo -e "" >> ./database/$dbName/$tableName/data_$tableName

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
    echo "3-insert record"
    echo "4-drop table "
    echo "5-alter table"
    echo "6- display discription of  a table"
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

    3)
      echo "======================="
      echo "existing Tables :"
      echo $(ls ./database/$dbName)
      echo "======================="

     insertRecord
     ;;

    4)
      echo "======================="
      echo "existing tables :"
      echo $(ls ./database/$dbName)
      echo "======================="
      droptable
     ;;

    5)
     alterTable
     ;;

    6)
      echo "======================="
      echo "existing tables :"
      echo $(ls ./database/$dbName)
      echo "======================="
     displaytable
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
dropDB(){
  showDB
  read -p "enter the database you want to delete : " dbName
  if [ ! -d ./database/$dbName ]
  then
    echo "not a valid existing database name please try again "
    dropDB
  else
    rm -r ./database/$dbName
    echo "$dbName is deleted sucessfully"
  fi
}

#trap 'echo "signal is trapped "' 2 20
while true
do
echo "========================"
echo "1-create new database"
echo "2-use database"
echo "3-drop datbase"
echo "0-exit"

read -p "enter your choice: " choice

case $choice in
1)
  createDB
  ;;

2)
  useDB
  ;;
3)
dropDB
;;

0)
  break
  ;;

*)
  echo wrong entry
  ;;
esac
done
