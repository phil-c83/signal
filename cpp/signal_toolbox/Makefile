######################################
# target
######################################
PRJNAME = signal
# Version_mineur_str =  $(shell grep "APP_VERSION_MINOR" version.h | grep -o -E '[0-9]+' )
# Version_majeur_str =  $(shell grep "APP_VERSION_MAJOR" version.h | grep -o -E '[0-9]+' )
# TARGET = $(PRJNAME)_$(Version_majeur_str)_$(Version_mineur_str)
TARGET = $(PRJNAME)

PRJ_ROOT   = .
SIG_ROOT   = ./signal


######################################
# building variables
######################################
# debug build?
DEBUG = 1
# optimization
OPT = -Og


#######################################
# paths
#######################################
# Build path
BUILD_DIR = build


######################################
# source
######################################
# C sources

C_SOURCES += main.cpp $(SIG_ROOT)/signal.cpp  


#######################################
# binaries
#######################################
PREFIX = 
# The gcc compiler bin path can be either defined in make command via GCC_PATH variable (> make GCC_PATH=xxx)
# either it can be added to the PATH environment variable.
ifdef GCC_PATH
CPP= $(GCC_PATH)/$(PREFIX)g++
CC = $(GCC_PATH)/$(PREFIX)gcc
AS = $(GCC_PATH)/$(PREFIX)gcc -x assembler-with-cpp
CP = $(GCC_PATH)/$(PREFIX)objcopy
SZ = $(GCC_PATH)/$(PREFIX)size
else
CPP= $(PREFIX)g++
CC = $(PREFIX)gcc
AS = $(PREFIX)gcc -x assembler-with-cpp
CP = $(PREFIX)objcopy
SZ = $(PREFIX)size
endif
HEX = $(CP) -O ihex
BIN = $(CP) -O binary -S
 
#######################################
# CFLAGS
#######################################

# macros for gcc
# AS defines
AS_DEFS = 

# C defines


# AS includes
AS_INCLUDES =  


# C includes
C_INCLUDES +=  \
-I$(PRJ_ROOT) \
-I$(DAC_ROOT)/Inc

# compile gcc flags
ASFLAGS = $(AS_INCLUDES) $(OPT) -Wall -fdata-sections -ffunction-sections

CFLAGS = $(C_INCLUDES) $(OPT) -Wall -fdata-sections -ffunction-sections -Wunused-function

ifeq ($(DEBUG), 1)
CFLAGS += -g -gdwarf-2
endif

# Generate dependency information
CFLAGS += -MMD -MP -MF"$(@:%.o=%.d)"


#######################################
# LDFLAGS
#######################################
# link script

# libraries
LIBS = -lc -lm 
LIBDIR = 
LDFLAGS = $(LIBDIR) $(LIBS) -Wl,-Map=$(BUILD_DIR)/$(TARGET).map,--cref -Wl,--gc-sections

# default action: build all
all: relink $(BUILD_DIR)/$(TARGET) 
.PHONY: relink
relink:	
	-[ -e $(BUILD_DIR)/$(TARGET) ] && rm $(BUILD_DIR)/$(TARGET)

#######################################
# build the application
#######################################
# list of objects
OBJECTS = $(addprefix $(BUILD_DIR)/,$(notdir $(C_SOURCES:.cpp=.o)))
vpath %.cpp $(sort $(dir $(C_SOURCES)))

OBJECTS += $(addprefix $(BUILD_DIR)/,$(notdir $(C_SOURCES:.c=.o)))
vpath %.c $(sort $(dir $(C_SOURCES)))
# list of ASM program objects
OBJECTS += $(addprefix $(BUILD_DIR)/,$(notdir $(ASM_SOURCES:.s=.o)))
vpath %.s $(sort $(dir $(ASM_SOURCES)))

$(BUILD_DIR)/%.o: %.cpp Makefile | $(BUILD_DIR) 
	$(CPP) -c $(CFLAGS) -Wa,-a,-ad,-alms=$(BUILD_DIR)/$(notdir $(<:.cpp=.lst)) $< -o $@

$(BUILD_DIR)/%.o: %.c Makefile | $(BUILD_DIR) 
	$(CC) -c $(CFLAGS) -Wa,-a,-ad,-alms=$(BUILD_DIR)/$(notdir $(<:.c=.lst)) $< -o $@

$(BUILD_DIR)/%.o: %.s Makefile | $(BUILD_DIR)
	$(AS) -c $(CFLAGS) $< -o $@

$(BUILD_DIR)/$(TARGET): $(OBJECTS) Makefile
	$(CC) $(OBJECTS) $(LDFLAGS) -o $@
	$(SZ) $@

	
$(BUILD_DIR):
	mkdir $@		

#######################################
# clean up
#######################################
clean:
	-rm -fR $(BUILD_DIR)


#######################################
# compile json clangd database
#######################################
.PHONY: json_db
json_db:	
	bear -- make	
  
#######################################
# dependencies
#######################################
-include $(wildcard $(BUILD_DIR)/*.d)


# *** EOF ***
