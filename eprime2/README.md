# Counting Prime Numbers

The eprime2 program is derived from the eprime program included in the parallella-examples repository. The purpose of the program is to count how many prime numbers exist that are less than a supplied value.

## Build and Run

 ./build.sh

 ./run.sh value

The program will report the number of primes less than the entered numeric value. The program will report how may tests each core made and how many primes each core discovered followed by a total tests and primes line along with the output from the Linux time command.

I used the table in this web page to validate the counts:

    https://primes.utm.edu/howmany.html

Running the program with a value of 1 billion (1000000000) takes a little over 90 minutes to find the 50,847,534 primes.

## Author

original from [Matt Thompson] (mailto:<mthompson@hexwave.com>)
modifications by [Ted Swoyer] (mailto:<tswoyer@gmail.com>)

## License

GPL v3 
