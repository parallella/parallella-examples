# This is an example hello world python code that will run on every Epiphany core. Each core will display its ID and the total number of cores
# The parallel functions (coreid and numcores) are in the parallel module hence we import this

import parallel

print "Hello world from core "+coreid()+" out of "+numcores()+" cores"
