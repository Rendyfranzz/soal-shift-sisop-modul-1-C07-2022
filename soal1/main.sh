func_check_password(){
	local lengthPassword=${#password}

	if [[ $lengthPassword -lt 8 ]]
    	then
        	echo "Password must be more than 8 characters"

	elif [[ "$password" != *[[:upper:]]* || "$password" != *[[:lower:]]* || "$password" != *[0-9]* ]]
	then
       		echo "Password must be at least upper, lower and number!"

    	else
		func_login
	fi
}

func_login(){
	if grep -q $password "$locUser"
	then
		echo "$calendar $time LOGIN:INFO User $username logged in" >> $locLog
		echo "Login success"

		printf "Enter command [dl or att]: "
		read command
		if [[ $command == att ]]
		then
			func_att
		elif [[ $command == dl ]]
		then
			func_dl_pic
		else
			echo "Not found"
		fi

	else
		fail="Failed login attemp on user $username"
		echo $fail

		echo "$calendar $time LOGIN:ERROR $fail" >> $locLog
	fi

}

func_dl_pic(){
	printf "Enter number: "
	read n

	if [[ ! -f "$folder.zip" ]]
	then
		mkdir $folder
		count=0
		func_start_dl
	else
		func_unzip
	fi

}

func_unzip(){
	unzip -P $password $folder.zip
	rm $folder.zip

	count=$(find $folder -type f | wc -l)
	func_start_dl
}

func_start_dl(){
	for(( i=$count+1; i<=$n+$count; i++ ))
	do
		wget https://loremflickr.com/320/240 -O $folder/PIC_$i.jpg
	done

	zip --password $password -r $folder.zip $folder/
	rm -rf $folder
}

func_att(){
	awk '
	BEGIN {print "Count login attemps"}
	/LOGIN/ {++n}
	END {print "Login attemps:", n}' $locLog
}


# main
calendar=$(date +%D)
time=$(date +%T)

printf "Enter your username: "
read username

printf "Enter your password: "
read -s password

# deff dir
folder=$(date +%Y-%m-%d)_$username
locLog=/home/wahid/sisop/modul1/log.txt
locUser=/home/wahid/sisop/modul1/users/user.txt

#call fun check password
func_check_password
