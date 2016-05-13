NAME = raymarch

prefix=/usr/local/browndeer
exec_prefix=${prefix}

STDCL_INCS = -I${prefix}/include
STDCL_LIBS = -L${exec_prefix}/lib -locl -lstdcl

INCS = $(STDCL_INCS)
LIBS = $(STDCL_LIBS) -lSDL

CCFLAGS += -march=native -Ofast
#CCFLAGS += -ggdb3 -O0

BUILD_OS = $(shell uname -s)

ifeq ($(BUILD_OS),Linux)
OBJS += ocl_kernels.o
endif

all: $(NAME) 

$(NAME): $(NAME).o $(OBJS) 
	$(CC) $(CCFLAGS) $(INCS) -o $(NAME) $(NAME).o $(OBJS) $(LIBS)  

ocl_kernels.o: raymarch_kern.cl
	/usr/local/browndeer/bin/clcc -I. -c -o ocl_kernels.o raymarch_kern.cl

.SUFFIXES:
.SUFFIXES: .c .o

.c.o:
	$(CC) $(CCFLAGS) $(INCS) -c $<

clean:
	rm -f *.o raymarch

