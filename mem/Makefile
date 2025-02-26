SRC = example.c mem_utils.m
INCLUDE = mem_utils.h
TARGET = mem
CFLAGS = -I.  
LDFLAGS = -framework Foundation

$(TARGET): $(SRC)
	$(CC) $(CFLAGS) $(SRC) $(LDFLAGS) -o $(TARGET)

clean:
	rm -f $(TARGET)
