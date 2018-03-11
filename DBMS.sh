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

showTables(){
  echo "======================="
  echo "existing tables :"
  echo $(ls ./database/$dbName)
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

defaultAccept(){
  read -p "Is $colName column have default value y/n: " defaultvalue
  if [ $defaultvalue = "y" ]
  then
    read -p "enter the default value: " default
    echo -e ":$default" >> ./database/$dbName/$tableName/meta_$tableName
  elif [[ $defaultvalue = "n" ]]
  then
    echo -e ":" >> ./database/$dbName/$tableName/meta_$tableName
  else
      echo "wrong entry"
      defaultAccept
  fi
}

nullAccept(){
  read -p "Is $colName column can accept null values y/n: " nullvalue
  if [ $nullvalue = "y" ]
  then
    echo -e -n ":null" >> ./database/$dbName/$tableName/meta_$tableName
    defaultAccept
  elif [[ $nullvalue = "n" ]]
  then
    echo -e ":notnull" >> ./database/$dbName/$tableName/meta_$tableName
  else
      echo "wrong entry"
      nullAccept
  fi
}

constraintSelect(){
      read -p "Is $colName column must have unique values y/n: " unique
      if [[ $unique = "y" ]]
      then
        echo -e ":unique" >> ./database/$dbName/$tableName/meta_$tableName
      elif [[ $unique = "n" ]]
       then
        echo -e -n ":" >> ./database/$dbName/$tableName/meta_$tableName
        nullAccept
      else
        echo "wrong entry"
        constraintSelect
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
        echo -e -n ":" >> ./database/$dbName/$tableName/meta_$tableName
        constraintSelect
      fi
    done
    echo "$tableName table is created successfully"
    echo "========================================="
  fi
}

displaytable(){
   read -p "enter the name of table you want to  display  its description : " tableName
  if [ ! -d ./database/$dbName/$tableName ]
    then
    echo "not a valid existing table name please try again "
    displaytable
  else
  echo "======================================="
  echo "description of $tableName table"
  cat ./database/$dbName/$tableName/meta_$tableName


  fi

}
droptable(){
  read -p "enter the name of table you want to drop : " tableName
  if [ ! -d ./database/$dbName/$tableName ]
    then
    echo "not a valid existing table name please try again "
    droptable
  else
  rm -r ./database/$dbName/$tableName
  echo "$tableName table is deleted "

  fi

}

nullConstraintAlter(){
  read -p "Do you want to change null constarint y/n : " nullchoice
  if [[ $nullchoice = "y" ]]
  then
    if [[ $fourthfield = "unique"  ]]
    then
      echo "this field can not be null ,this field  must have unique values "
    else
      if [[ $fifthfield = "null" ]]
      then
        read -p "your constrains is null , do you want 1- add default value 2-change it to not null ? " askuser
        case $askuser in
          1) read -p "Do you want to add or change  default value y/n " defaultchoice
          if [[ $defaultchoice = "y" ]]
           then
            read -p "enter default value : " defaultvalue
            sixtfield=$defaultvalue
          else
            sixtfield=""
          fi
          ;;



          2)
          fifthfield="notnull"
          sixtfield=""
          ;;
           *)
           echo "wrong input"
           ;;

         esac


      else
        fifthfield="null"
        read -p "Do you want to add default or change value y/n " defaultchoice
        if [[ $defaultchoice = "y" ]]
         then
          read -p "enter default value : " defaultvalue
          sixtfield=$defaultvalue
        else
          sixtfield=""
        fi

      fi
    fi

  else
    if [[ $fifthfield = "null" ]]
    then
      read -p "Do you want to add default or change value y/n " defaultchoice
      if [[ $defaultchoice = "y" ]]
       then
        read -p "enter default value : " defaultvalue
        sixtfield=$defaultvalue
      else
        sixtfield=""
      fi
    fi


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
    echo "2-add new field"
    echo "3-edit a certain field"
    echo "4-delete field"
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
      read -p "enter the name of the new field  : " colName
      echo -n $colName >> ./database/$dbName/$tableName/meta_$tableName
      datatypeSelect
      echo -e -n ":" >> ./database/$dbName/$tableName/meta_$tableName
      constraintSelect
      echo "$colName field is added to $tableName successfully"
      ;;

    3)
    fields=$(awk 'BEGIN {FS=":"} {print $1}' ./database/$dbName/$tableName/meta_$tableName)
    echo "=============================="
    echo " existing fields "
    echo "$fields"
    echo "=============================="
    read -p "enter the field to be edited  : " colName
    field=$(sed -n "/^$colName:.*/p" ./database/$dbName/$tableName/meta_$tableName)
    echo $field

    if [[ $field != "" ]]
    then
      firstfield=$(echo "$field" | cut -d ":" -f 1)
      secondfield=$(echo "$field" | cut -d ":" -f 2)
      thirdfield=$(echo "$field" | cut -d ":" -f 3)
      fourthfield=$(echo "$field" | cut -d ":" -f 4)
      fifthfield=$(echo "$field" | cut -d ":" -f 5)
      sixtfield=$(echo "$field" | cut -d ":" -f 6)
       if [[ $thirdfield = "pk" ]]
       then
      echo "1-rename field"
      echo "2-change data type"
      read -p "enter your choice : " choice
      case $choice in
      1)
        read -p "enter new name : " newfieldname
        firstfield=$newfieldname
        ;;

      2)
          echo "1-datatype is string"
          echo "2-datatype is number"
          read -p "choose the new datatype : " colType
          case $colType in
            1)
              secondfield="string"
                ;;

            2)
              secondfield="number"
              ;;
            *)
              echo "wrong entry please try again"
              ;;
            esac
            ;;
        *)
        echo "wrong entry please try again"
        ;;

      esac

    else
      echo "1-rename field"
      echo "2-change data type"
      echo "3-change another constraint"
      read -p "enter your choice : " choice
      case $choice in
      1)
        read -p "enter new name : " newfieldname
        firstfield=$newfieldname
        ;;

      2)
          echo "1-datatype is string"
          echo "2-datatype is number"
          read -p "choose the new datatype : " colType
          case $colType in
            1)
              secondfield="string"
                ;;

            2)
              secondfield="number"
              ;;
            *)
              echo "wrong entry please try again"
              ;;
            esac
            ;;

        3)

          read -p "Do you want to change uniqueness constraint y/n: " unique
          if [[ $unique = "y" ]]
          then
            if [[ $fifthfield = "notnull" ]]
            then
            if [[ $fourthfield = "unique" ]]
            then
              fourthfield=""
              nullConstraintAlter
            else
              fourthfield="unique"

            fi
          else
            echo "this field cannot be unique ,it accepts null values"
            nullConstraintAlter
          fi
          else
            nullConstraintAlter
          fi
          ;;

        *)
        echo "wrong entry please try again"
        ;;

      esac

    fi
    newfield="$firstfield:$secondfield:$thirdfield:$fourthfield:$fifthfield:$sixtfield"

    sed -i "s/^$colName:.*/$newfield/" ./database/$dbName/$tableName/meta_$tableName
  else
    echo "wrong field"
    fi

      ;;

    4)
    fields=$(awk 'BEGIN {FS=":"} {print $1}' ./database/$dbName/$tableName/meta_$tableName)
    echo "=============================="
    echo " existing fields "
    echo "$fields"
    echo "=============================="
      read -p "enter the name of field to be deleted  : " colName
      sed -i '/'$colName'/d' ./database/$dbName/$tableName/meta_$tableName
      echo "$colName column is deleted to $tableName successfully"
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
            exists=$(awk -v col=$col 'BEGIN { FS = ":" } {print $col}' ./database/$dbName/$tableName/data_$tableName)

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

   fi
else
    if [[ "$firstfieldval" = "" ]]
    then
      if [[ $sixtfield != "" ]] #there is a defult value
      then
        echo -n -e ":$sixtfield" >> ./database/$dbName/$tableName/data_$tableName
      else
        echo -n -e "null" >> ./database/$dbName/$tableName/data_$tableName
      fi
    else
    echo -n -e "$firstfieldval" >> ./database/$dbName/$tableName/data_$tableName
  fi
  

fi

}

checkConstrains(){

    firstfield=$(echo "$j" | cut -d ":" -f 1)
    secondfield=$(echo "$j" | cut -d ":" -f 2)
    thirdfield=$(echo "$j" | cut -d ":" -f 3)
    fourthfield=$(echo "$j" | cut -d ":" -f 4)
    fifthfield=$(echo "$j" | cut -d ":" -f 5)
    sixtfield=$(echo "$j" | cut -d ":" -f 6)
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
  col=0
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
     ((col++))
     checkConstrains


    done
     echo -e "" >> ./database/$dbName/$tableName/data_$tableName

  fi
}

selecttable(){
read -p "enter table name :" tableName
if [ ! -d ./database/$dbName/$tableName ]
  then
  echo "this name is not exists please try again "
  selecttable
else
  deleterecord

fi

}
deleterecord(){

  array=()
  arrayval=()
  flagdosentexist=0

  fields=$(awk 'BEGIN {FS=":"} {print $1}' ./database/$dbName/$tableName/meta_$tableName)
  echo "delete from $tableName where (condition)"
  echo "=============================="
  echo " existing fields "
  echo "$fields"
  echo "=============================="
  read -p "enter the name of field you want to use to delete record" selectedfield

  for x in $fields
  do

   if [[ $x = $selectedfield ]]
      then

      read -p "enter the value of $selectedfield : " selectedfieldvalue

      echo "delete from $tableName where $selectedfield = $selectedfieldvalue "
      lines=$(sed -n "/$selectedfieldvalue/p" ./database/$dbName/$tableName/data_$tableName)
      echo $lines
      flagdosentexist=1
      break

    fi

  done
  if [[ $flagdosentexist = 0 ]]
  then
    echo "error ! this field dosen't exists "
      echo " "
     deleterecord
 fi

  if [[ $lines != "" ]]
    then
    numVal=$(cat ./database/$dbName/$tableName/meta_$tableName | wc -l)
    leastCol=$(( $numVal - 1 ))
    for i in $(seq $leastCol)
    do
      read -p "you want add 'and' condition y/n ?" yn
      if [[ $yn = y ]]
        then
        echo "delete from $tableName where (condition)"
        echo "=============================="
        echo " existing fields "
        echo "$fields"
        echo "=============================="
        read -p "enter the name of field you want to and to delete record" selectedfieldforand

      for k in $fields
      do
      echo
      if [[ k=selectedfieldforand ]]
      then

      read -p "enter the value of $selectedfieldforand : " selectedfieldvalueforand
      array+=("$selectedfieldforand")
      arrayval+=("$selectedfieldvalueforand")
      break

      else
      echo "error ! this field dosen't exists "
      deleteoptions
      fi

      done

      elif [[ $yn = n ]]
        then
        if [[ ${array[@]} = "" ]]
          then
        cp ./database/$dbName/$tableName/data_$tableName ./database/$dbName/$tableName/datatwo_$tableName
        echo -n "" >./database/$dbName/$tableName/data_$tableName
        sed  "/$selectedfieldvalue/d" ./database/$dbName/$tableName/datatwo_$tableName >>./database/$dbName/$tableName/data_$tableName
        rm ./database/$dbName/$tableName/datatwo_$tableName
        echo "delete records "
        break
        break
      else
        deletefunction
      fi
      else
        echo "wrong input,start chose delete conditions again! "
        deleterecord
     fi
    done

  else
    echo " can't delete ! $selectedfieldvalue is not found "
    options
  fi

}

deletefunction(){
 flagdelete=0
  echo -n "$lines" > ./database/$dbName/$tableName/datathree_$tableName
  catlines=$(cat ./database/$dbName/$tableName/datathree_$tableName | wc -l )
if [[ $catlines=1 ]]
  then

   for i in ${arrayval[@]}
    do
      deleteline=$(sed -n "/$i/p" ./database/$dbName/$tableName/datathree_$tableName)
      if [[ $deleteline = "" ]]
       then
       flagdelete=0
       echo "cant delete that record ,no such record is matched "
       break
      else
       flagdelete=1

      fi
    done
   if [[ $flagdelete = 1 ]]
   then
         cp ./database/$dbName/$tableName/data_$tableName ./database/$dbName/$tableName/datatwo_$tableName
        echo -n "" >./database/$dbName/$tableName/data_$tableName
        sed  "/$selectedfieldvalue/d" ./database/$dbName/$tableName/datatwo_$tableName >>./database/$dbName/$tableName/data_$tableName
        rm ./database/$dbName/$tableName/datatwo_$tableName
        echo "delete records "

   fi
else
    echo "hdwr b values w field"
fi





}


editrecord(){
read -p "enter table name : " tableName
 if [ ! -d ./database/$dbName/$tableName ]
 then
    echo "this name is not exists please try again"
    editrecord
 else
 	echo "Which field do you want to select?"
      awk 'BEGIN { FS = ":" ; OFS=" " } {print NR "-to select by " $1":"}' ./database/$dbName/$tableName/meta_$tableName
      read -p "enter your choice: " selectField
      read -p "insert the word you want to update" newrecord
      echo "Do you want to have a certain condition?"
      echo "1-Yes"
      echo "2-No"
      read -p "enter your choice: " cond
      

      case $cond in 

      	1)	echo "Which field do you want to select?"
     		awk 'BEGIN { FS = ":" ; OFS=" " } {print NR "-to select by " $1":"}' ./database/$dbName/$tableName/meta_$tableName
      		read -p "enter your choice: " wherechoice
      		read -p "where condition:" wherecond
			awk -v selfield=$selectField -v nrec=$newrecord -v wchoice=$wherechoice -v wcond=$wherecond 'BEGIN { FS=":" ; OFS= ":" } $wchoice==wcond{$selfield=nrec}1' ./database/$dbName/$tableName/data_$tableName > ./database/$dbName/$tableName/tmp && mv  ./database/$dbName/$tableName/tmp ./database/$dbName/$tableName/data_$tableName
			;;

    	2) 
			awk -v selfield=$selectField -v nrec=$newrecord  'BEGIN { FS=":" ; OFS= ":" } {$selfield=nrec}1' ./database/$dbName/$tableName/data_$tableName > ./database/$dbName/$tableName/tmp && mv  ./database/$dbName/$tableName/tmp ./database/$dbName/$tableName/data_$tableName
			;;

		*)
			echo "wrong enty"
			editrecord

			;;

    	esac

    # awk -v selfield=$selectField -v nrec=$newrecord  'BEGIN { FS=":" ; OFS= ":" } {$selfield=nrec}1' ./database/$dbName/$tableName/data_$tableName > ./database/$dbName/$tableName/awkk
	# awk -v selfield=$selectField -v nrec=$newrecord  'BEGIN { FS=":" ; OFS= ":" } $selfield=="rowaina"{$selfield=nrec}1' ./database/$dbName/$tableName/data_$tableName > ./database/$dbName/$tableName/tmp && mv  ./database/$dbName/$tableName/tmp ./database/$dbName/$tableName/data_$tableName
	# > ./database/$dbName/$tableName/tmp && mv  ./database/$dbName/$tableName/tmp ./database/$dbName/$tableName/awkk
	# $ awk '$1=="username4"{$4="anything"}1' file
	# sed -i "s/^${field_name}:.*$/${new_line}/"
    # field=`egrep ^${field_name}: ./metadata/$db/$tabl


fi

}


sortrecord(){

    read -p "enter table name : " tableName
    if [ ! -d ./database/$dbName/$tableName ]
    then
    echo "this name is not exists please try again"
    sortrecord
    else 
    echo "Which field do you want to select?"
    awk 'BEGIN { FS = ":" ; OFS=" " } {print $1":"}' ./database/$dbName/$tableName/meta_$tableName 
    read -p "enter the name of your choice: " selectField
    echo "1-to sort ascend​ingly"
    echo "2-to sort descendingly"
    read -p "enter your choice: " sortorder
    
    fieldtype=$(grep $selectField ./database/$dbName/$tableName/meta_$tableName | cut -d ":" -f2)

    num=$(awk -v col_name=$selectField 'BEGIN{ FS = ":"}{ if( $1 == col_name ){ print NR } }' ./database/$dbName/$tableName/meta_$tableName)
  

    if [[ "$fieldtype" = number ]]
    then
      case $sortorder in
        1)
        cat ./database/$dbName/$tableName/data_$tableName | sort -n -t ":" -k$num | tr ':' ' '
        ;;

        2)
          cat ./database/$dbName/$tableName/data_$tableName | sort -nr -t ":" -k$num | tr ':' ' '
        ;;

        esac
    else 
        case $sortorder in
        1)
        cat ./database/$dbName/$tableName/data_$tableName | sort -t ":" -k$num | tr ':' ' '
        ;;

        2)
          cat ./database/$dbName/$tableName/data_$tableName | sort -r -t ":" -k$num | tr ':' ' '
        ;;

        esac


    fi



fi


}

selectrecord(){

 read -p "enter table name : " tableName
 if [ ! -d ./database/$dbName/$tableName ]
 then
    echo "this name is not exists please try again"
    selectrecord
 else
  echo "1-to select by one field "
  echo "2-to select by more than one field"
  echo "3-to select all fields "
  echo "4-to select the whole table"
  read -p "enter your choice: " selectRec

  case $selectRec in

    1)
      echo "Which field do you want to select?"
      awk 'BEGIN { FS = ":" ; OFS=" " } {print NR "-to select by " $1":"}' ./database/$dbName/$tableName/meta_$tableName
      read -p "enter your choice: " selectField
      if grep -q  $selectField "./database/$dbName/$tableName/data_$tableName"
      then
      num=$(awk -v col_num=$selectField 'BEGIN{ FS = ":"}{ if( NR == col_num ){ print $2} }' ./database/$dbName/$tableName/meta_$tableName)
      read -p "please enter the word you want to search for:" selectWord
      if [[ $num == number ]]
      then
      	  egrep ^${selectWord}: ./database/$dbName/$tableName/data_$tableName | cut -d ":" -f$selectField
  	  else 
  	  	  egrep $selectWord: ./database/$dbName/$tableName/data_$tableName | cut -d ":" -f$selectField

  	  fi
      echo "Do you want to print the result?"
      echo "1-To print using HTML"
      echo "2-To print using CSV"
      echo "0-To exit without printing"
      read -p "enter your choice: " choiceP
      case $choiceP in


        1)

			if [[ $num == number ]]
      		then
      	  	egrep ^${selectWord}: ./database/$dbName/$tableName/data_$tableName | cut -d ":" -f$selectField  > ./database/$dbName/$tableName/myfile
  	  		else 
  	  	  	egrep $selectWord: ./database/$dbName/$tableName/data_$tableName | cut -d ":" -f$selectField  > ./database/$dbName/$tableName/myfile
  	  		fi
	          awk 'BEGIN {FS = ":" ; print "<table border=3px >" }
          NR == 1{
              print "<tr>"
              tag = "th"
          }
          NR != 1{
              print "<tr>"
              tag = "td"
          }
          {
              for(i=1; i<=NF; ++i) print "<" tag " width=\"" widths[i] "\">" $i "</" tag ">"
              print "</tr>"
          }
          END { print "</table>"}' ./database/$dbName/$tableName/myfile > ./database/$dbName/$tableName/tablehtml.html
          echo "Printed successfully!"
              ;;

        2)
			if [[ $num == number ]]
      		then
      	  	egrep ^${selectWord}: ./database/$dbName/$tableName/data_$tableName | cut -d ":" -f$selectField  > ./database/$dbName/$tableName/myfile
  	  		else 
  	  	  	egrep $selectWord: ./database/$dbName/$tableName/data_$tableName | cut -d ":" -f$selectField  > ./database/$dbName/$tableName/myfile
  	  		fi          
  	  		awk '{ for (i=1;i<=NF;i++) print $i}' < ./database/$dbName/$tableName/myfile > ./database/$dbName/$tableName/testfile.csv
  	  		echo "Printed successfully!"
          ;;

        0)
          break
          ;;



      esac

      else
      echo "result not found"
      fi
      ;;

    2)

      awk 'BEGIN { FS = ":" ; OFS=" " } {print NR "-to select by " $1":"}' ./database/$dbName/$tableName/meta_$tableName
      echo "Please enter the fields you want to enter ex 2,3,4"
      read -p "enter your choice: "  fieldNum
      read -p "please enter the word you want to search for:" selectWord
      egrep  $selectWord  ./database/$dbName/$tableName/data_$tableName | cut -d ":" -f$fieldNum | tr ':' ' '

      echo "Do you want to print the result?"
      echo "1-To print using HTML"
      echo "2-To print using CSV"
      echo "0-To exit without printing"
      read -p "enter your choice: " choiceP
      case $choiceP in


        1)
          egrep  $selectWord  ./database/$dbName/$tableName/data_$tableName | cut -d ":" -f$fieldNum > ./database/$dbName/$tableName/myfile
          awk 'BEGIN {FS = ":" ; print "<table border=3px >" }
          NR == 1{
              print "<tr>"
              tag = "th"
          }
          NR != 1{
              print "<tr>"
              tag = "td"
          }
          {
              for(i=1; i<=NF; ++i) print "<" tag " width=\"" widths[i] "\">" $i "</" tag ">"
              print "</tr>"
          }
          END { print "</table>"}' ./database/$dbName/$tableName/myfile > ./database/$dbName/$tableName/tablehtml.html
          echo "Printed successfully!"
              ;;

        2)
          egrep  $selectWord  ./database/$dbName/$tableName/data_$tableName | cut -d ":" -f$fieldNum > ./database/$dbName/$tableName/myfile
          awk  ' BEGIN {FS = ":"} { for (i=1;i<=NF;i++) printf ("%s%c", $i, i+1 <= NF ? "," : "\n"); }' < ./database/$dbName/$tableName/myfile > ./database/$dbName/$tableName/testfile.csv
          echo "Printed successfully!"
          ;;


        0)
          break
          ;;



      esac
      ;;


    3)
      read -p "please enter the word you want to search for:" selectRec
      if grep -q  $selectRec "./database/$dbName/$tableName/data_$tableName"
      then
      egrep $selectRec  ./database/$dbName/$tableName/data_$tableName | tr ':' ' '
      echo "Do you want to print the result?"
      echo "1-To print using HTML"
      echo "2-To print using CSV"
      echo "0-To exit without printing"
      read -p "enter your choice: " choiceP
      case $choiceP in


        1)
          egrep $selectRec  ./database/$dbName/$tableName/data_$tableName > ./database/$dbName/$tableName/myfile
          awk 'BEGIN {FS = ":" ; print "<table border=3px >" }
          NR == 1{
              print "<tr>"
              tag = "th"
          }
          NR != 1{
              print "<tr>"
              tag = "td"
          }
          {
              for(i=1; i<=NF; ++i) print "<" tag " width=\"" widths[i] "\">" $i "</" tag ">"
              print "</tr>"
          }
          END { print "</table>"}' ./database/$dbName/$tableName/myfile > ./database/$dbName/$tableName/tablehtml.html

          echo "Printed successfully!"
              ;;

        2)
          egrep $selectRec  ./database/$dbName/$tableName/data_$tableName > ./database/$dbName/$tableName/myfile
          awk ' BEGIN {FS = ":"} { for (i=1;i<=NF;i++) printf ("%s%c", $i, i+1 <= NF ? "," : "\n"); }' < ./database/$dbName/$tableName/myfile > ./database/$dbName/$tableName/testfile.csv
           echo "Printed successfully!"
          ;;


        0)
          break
          ;;



      esac

      else
        echo "result not found"
      fi
      ;;


    4)

      cat ./database/$dbName/$tableName/data_$tableName | tr ':' ' '
      echo "Do you want to print the result?"
      echo "1-To print using HTML"
      echo "2-To print using CSV"
      echo "0-To exit without printing"
      read -p "enter your choice: " choiceP
      case $choiceP in


        1)
          cat  ./database/$dbName/$tableName/data_$tableName  > ./database/$dbName/$tableName/myfile
          awk 'BEGIN {FS = ":" ; print "<table border=3px >" }
          NR == 1{
              print "<tr>"
              tag = "th"
          }
          NR != 1{
              print "<tr>"
              tag = "td"
          }
          {
              for(i=1; i<=NF; ++i) print "<" tag " width=\"" widths[i] "\">" $i "</" tag ">"
              print "</tr>"
          }
          END { print "</table>"}' ./database/$dbName/$tableName/myfile > ./database/$dbName/$tableName/tablehtml.html

          echo "Printed successfully!"
              ;;

        2)

         cat ./database/$dbName/$tableName/data_$tableName > ./database/$dbName/$tableName/myfile
        awk ' BEGIN {FS = ":"} { for (i=1;i<=NF;i++) printf ("%s%c", $i, i+1 <= NF ? "," : "\n"); }' < ./database/$dbName/$tableName/myfile > ./database/$dbName/$tableName/testfile.csv
          ;;


        0)
          break
          ;;


      esac

      ;;
    esac


 fi
}

deleteoptions(){


  echo "=============================="
  echo " existing fields "
  echo "$fields"
  echo "=============================="
  read -p "enter the name of field you want to use to delete record" selectedfield

}

options(){

 loop=1
    while [ $loop -eq 1 ]
    do
    echo "===================="
    echo "1-show tables"
    echo "2-create new table"
    echo "3-alter table"
    echo "4-drop table "
    echo "5-display description of a table"
    echo "6-insert record"
    echo "7-select a certain record"
    echo "8-sort table"
    echo "9-edit a certain record"
    echo "10-delete  record"
    echo "00-back"


    read -p "enter your choice: " choice

    case $choice in
    1)
      showTables
      ;;

    2)
      createTable
      ;;

    3)
       alterTable
       ;;

    4)
       showTables
       droptable
        ;;

    5)
      showTables
      displaytable
      ;;

    6)
      showTables
     insertRecord
     ;;

    7)
      showTables
      selectrecord
    ;;

    8)
      showTables
      sortrecord
    ;;

    9)
      showTables
      editrecord
    ;;

   10)
     showTables
     selecttable
     ;;

   00)
      loop=0
      ;;

    *)
      echo wrong entry
      ;;
    esac
    done

}



useDB(){
  showDB
  read -p "enter the database you want to use : " dbName
  if [ ! -d ./database/$dbName ]
  then
    echo "not a valid existing database name please try again "
    useDB
  else
   options
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
