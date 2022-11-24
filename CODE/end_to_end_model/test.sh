# for all files in the directory test-samples/ that ends with .wav perform the following operations:
# print the file name
# run python3 test.py --file test-samples/FILE_NAME.wav and write output to output.txt and nothing should be printed to the terminal this is done by redirecting stdout and stderr to /dev/null
# print the last two lines of the output of the previous command
# print a separator using # characters

for file in test-samples/*.wav
do
    echo $file
    python3 test.py --file $file > output.txt 2> /dev/null
    tail -n 2 output.txt
    echo "#############################################"
done


