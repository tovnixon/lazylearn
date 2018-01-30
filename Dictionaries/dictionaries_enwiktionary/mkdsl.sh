#INSTPATH=./
INSTPATH=./dsl/
SOURCEPATH=./ding/ 

for PROG in ruby
do
command -v $PROG >/dev/null 2>&1 || { echo >&2 "Program $PROG is required but it's not installed.  Aborting."; exit 1; }
done

cp $SOURCEPATH/*.txt $INSTPATH

for file in  $INSTPATH/*.txt
do
echo "compiling"$file" -> dsl"
./wikt2dsl_twoway.rb $file
done
rm $INSTPATH/*.txt
