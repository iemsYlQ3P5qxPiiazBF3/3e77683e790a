#!/bin/bash
#set -x
instrc=0
pointer=0
[ "${tape[1]}" = "" ]&&tape=( 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 )
tape=( 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 )
for i in $(xxd -u -p $1|sed 's/.\{6\}/& /g');do
 ((instrc++))
 i=( $(sed 's/.\{2\}/& /g'<<<$i) )
 #echo ${i[@]}
 case ${i[0]} in
 '00')
  ((pointer++))
  ;;
 '01')
  ((pointer--))
  ;;
 '0A')
  ((tape[$pointer]++))
  ;;
 '0B')
  ((tape[$pointer]--))
  ;;
 '0C')
  #use hex representation of base 10 (00-FF)
  #if [pointer@tape] = [hex] then [hex@tape] = 0 else [hex@tape] = 1
  [ "${tape[$pointer]}" = "${tape[$(bc<<<ibase=G\;obase=A\;${i[1]})]}" ]&&tape[$(bc<<<ibase=G\;obase=A\;${i[2]})]=0||tape[$(bc<<<ibase=G\;obase=A\;${i[2]})]=1
  ;;
 '0D')
  echo "${i[1]}${i[2]}"|xxd -p -r|tee -a out
  ;;
 '0E')
  . $0 ${i[1]}${i[2]}
  #source file 0000-FFFF
  ;;
 '0F')
  . $0 ${i[1]}
  #source file 00-FF
  ;;
 '10')
  for x in $(echo "${tape[@]}"|tr -d ' '|sed 's/.\{8\}/& /g');do
   x=$(bc<<<"ibase=2;obase=G;$x")
   while [ "$(echo -n $x|wc -c)" != "2" ];do x="0$x";done
   echo "$x"|xxd -p -r|tee -a out
  done
  echo
  ;;
 '11')
  tape[$pointer]=$(( $(hexdump -ve '/1 "%u"' -n1 /dev/urandom) % $(bc<<<ibase=G\;obase=A\;${i[1]}) ))
  ;;
 '12')
  exit
  ;;
 '63')
  for x in {99..1};do echo -e "$x bottles of beer on the wall, $x bottles of beer\ntake one down, pass it around, $((x-1)) bottles of beer on the wall";done
  ;;
 '13')
  #this is control flow
  #file names have to be valid 00-FF hex values
  [ "${tape[$pointer]}" = "0" ]&&. $0 ${i[1]}||. $0 ${i[2]}
  ;;
 '14')
  pointer_s=$pointer
  ;;
 '15')
  pointer=$pointer_s
  ;;
 '16')
  echo 'Hello, World!'
  ;;
 '17')
  tape_s=$( ${tape[@]} )
  ;;
 '18')
  tape=( ${pointer_s[@]} )
  ;;
 '19')
  read -er x
  tape[$pointer]=$x #yes, this can break the 'only 0 or 1' and spaces break 4E-4D
  ;;
 '1A')
  [ ! "${tape[$(bc<<<ibase=G\;obase=A\;${i[1]})]}" = "${tape[$(bc<<<ibase=G\;obase=A\;${i[2]})]}" ]&&tape[$pointer]=0||tape[$pointer]=1
  ;;
 '1B')
  tape[$pointer]=$((${tape[$pointer]}^1))
  ;;
 '1C')
  bit_s="${tape[$pointer]}" #can't think of a better name
  ;;
 '1D')
  tape[$pointer]="$bit_s"
  ;;
 '1E')
  #quine
  cat $1
  ;;
 '1F')
  echo -e "${i[@]}\n${tape[@]}"|tr -d ' '
  for i in $(seq $pointer);do echo -n " ";done;echo "^"
  ;;
 '20')
  tape[$pointer]=$((${tape[$pointer]}*$(bc <<<ibase=G\;obase=A\;${i[1]})))
  ;;
 '21')
  tape[$pointer]=$((${tape[$pointer]}/$(bc <<<ibase=G\;obase=A\;${i[1]})))
  ;;
 '22')
  tape[$pointer]=$((${tape[$pointer]}^$(bc <<<ibase=G\;obase=A\;${i[1]})))
  ;;
 '23')
  tape[$pointer]=$((${tape[$pointer]}%$(bc <<<ibase=G\;obase=A\;${i[1]})))
  ;;
 '24')
  tape[$pointer]=$((${tape[$pointer]}**$(bc <<<ibase=G\;obase=A\;${i[1]})))
  ;;
 '25')
  tape[$pointer]=$((${tape[$pointer]}~$(bc <<<ibase=G\;obase=A\;${i[1]})))
  ;;
 '26')
  tape[$pointer]=$((${tape[$pointer]}!$(bc <<<ibase=G\;obase=A\;${i[1]})))
  ;;
 '27')
  tape[$pointer]=$((${tape[$pointer]}&$(bc <<<ibase=G\;obase=A\;${i[1]})))
  ;;
 '28')
  tape[$pointer]=$((${tape[$pointer]}|$(bc <<<ibase=G\;obase=A\;${i[1]})))
  ;;
 '29')
  : #NOP because `63` is `i` so your program doesn't print 99 bottles of beer
 '2A')
  pointer=0
  ;;
 '2B')
  while [ "${tape[$pointer]}" != "0" ];do
   . $0 ${i[1]}||. $0 ${i[2]}
  done
  ;;
 esac
 #echo -e "${i[@]}\n${tape[@]}"|tr -d ' '
 #for i in $(seq $pointer);do echo -n " ";done;echo "^"
done