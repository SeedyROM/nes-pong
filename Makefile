objs := bin/headers.o bin/main.o
out := bin/pong.nes

all: $(out)

clean:
	rm -f $(objs) $(out)

.PHONY: all clean

# Assemble

./bin/%.o: ./src/%.s
	ca65 $< -o $@

./bin/main.o: ./src/main.s src/constants.s
./bin/header.o: ./src/headers.s

# Link

bin/pong.nes: ./helpers/link.x $(objs)
	ld65 -C ./helpers/link.x $(objs) -o $@

# Run 

run: 
	fceux ./bin/pong.nes	
