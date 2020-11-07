
#! /bin/bash

#progress_bar()
#{
#  local PROG_BAR_MAX=${1:-20}
#  local PROG_BAR_DELAY=${2:-1}
#  local PROG_BAR_TODO=${3:-"*"}
#  local PROG_BAR_DONE=${4:-"█"}
#  local i

#  echo -en "["
#  for i in `seq 1 $PROG_BAR_MAX`
#  do
#    echo -en "$PROG_BAR_TODO"
#  done
#  echo -en "]\0015["
#  for i in `seq 1 $PROG_BAR_MAX`
#  do
#    echo -en"$PROG_BAR_DONE"
#    sleep ${PROG_BAR_DELAY}
#  done
#  echo
#clear
#}

while true
do
#contador de ips validos
contv=0 
#contador de dados invalidos
conti=0
hora=$(date +%H)
ipvalido="^([0-9]|[1-8][0-9]|9[0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])(\.([0-9]|[1-8][0-9]|9[0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])){3}$"
ipativo="(\b([0-9]{2}|[0-9]{1}|[^100])% packet loss)"
ipinativo="(100% packet loss)"
clear

## cumprimento com o usuario, opcional e apenas uma frescura que eu inventei - carvalho

if [ 6 -lt $hora ] && [ $hora -lt 12 ] ; then
	echo "Bom dia, $USER. Aceita um cafe?"
else if [ 12 -lt $hora ] && [ $hora -lt 18 ] ; then
	echo "Boa tarde, $USER. Aceita um suco?"
else if [ 18 -lt $hora ] && [ $hora -lt 23 ] ; then
	echo "Boa noite, $USER. Hora da breja."
fi ; fi ; fi

if [ $# -eq 0 ] || [ ! -f $1 ]; then 
## se nenhum parametro foi passado
	echo "Nenhum caminho foi informado."
	input=0
	while [ ! -f $input ]
	do
	## enquanto input nao for um arquivo valido
		echo "Insira o caminho do arquivo."
		echo "Obs: Caso esteja no diretorio, por favor informar somente o nome do arquivo."
		read input
		if [ ! -f $input ] ; then
			clear
			echo "Caminho invalido."
		fi
	done
else if [ -f $1 ] ; then
## se foi, input = parametro
		input=$1
	fi
fi

touch valido.txt ; #echo VALIDOS > valido.txt ## criaçao de arquivos, talvez tentar juntar em apenas um? - carvalho
touch invalido.txt ; #echo INVALIDOS > invalido.txt

while IFS= read -r line
do

	if [[ $line =~ $ipvalido ]] ; then
		if [ $contv -eq 0 ] ; then
			echo Testando os enderecos... aguarde.
		echo -n "["
			echo -n "$line - " > valido.txt
		else 
			echo -n "$line - " >> valido.txt
		fi
		ping -c 4 $line | egrep -wo "([0-9]?[0-9]?[0-9]% packet loss)" >> valido.txt
		(( contv++ ))
		#echo "$contv"
		echo -en "\033[00;32m*\033[0m"
		#progress_bar 10
        else 
		if [ $conti -eq 0 ] ; then 
		echo "$line" > invalido.txt
		fi
		echo "$line" >> invalido.txt
		(( conti++ ))
	fi
done < "$input"

##daqui pra baixo ainda eh trabalho em progresso. juntar os validos e invalidos no resultado.txt - carvalho
## aparentemente tem um bug em que alguns endereços sao repetidos e imprimidos duas vezes. importante checar - carvalho

valido=valido.txt
invalido=invalido.txt

echo ' ' 
echo ENDERECOS ATIVOS > resultado.txt

while IFS= read -r line
do
	if [[ $line =~ $ipativo ]] ; then 
		echo $line >> resultado.txt
	fi
done < "$valido"

echo ENDERECOS INATIVOS >> resultado.txt 

while IFS= read -r line
do
	if [[ $line =~ $ipinativo ]] ; then 
		echo $line >> resultado.txt
	fi
done < "$valido"

echo INVALIDOS >> resultado.txt 

while IFS= read -r line
do
	echo $line >> resultado.txt
done < "$invalido"

cat resultado.txt

echo Fim de arquivo
echo "deseja inserir um novo arquivo[s/n]?"
read resp
test "$resp" = "n" && exit
sleep 1
clear
done




