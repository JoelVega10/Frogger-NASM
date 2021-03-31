AS=nasm #Compilador de ensamblador
ASFLAGS=-f elf -g -F stabs #Ensamblador flags
LD=ld #Linker
LDFLAGS=-m elf_i386 -o#Linker flags
SOURCES=$(wildcard ./*.asm) #Fuentes
OBJECTS=$(SOURCES:.asm=.o) #Archivos object
LST=$(SOURCES:.asm=.lst) #Archivos lst
EXECUTABLE=frogger #Nombre del programa

all: $(OBJECTS)
	$(LD) $(LDFLAGS) $(EXECUTABLE) $(OBJECTS)

$(OBJECTS):  $(SOURCES)
	$(AS) $(ASFLAGS) $(SOURCES) -l $(LST)

clean:
	rm -rf *o $(EXECUTABLE)
	rm -rf *lst $(EXECUTABLE)


