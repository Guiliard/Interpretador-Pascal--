PASCAL = fpc
SRC_DIR = src
BUILD_DIR = build
BIN_DIR = $(BUILD_DIR)/bin
OBJECT_DIR = $(BUILD_DIR)/object 
TESTS_DIR = tests

SRC_SUBDIRS := $(shell find $(SRC_DIR) -type d)

MAIN_SRC = $(SRC_DIR)/main.pas
BIN_FILE = $(BIN_DIR)/main

FPCFLAGS = -FE$(BIN_DIR) -FU$(OBJECT_DIR) $(foreach dir,$(SRC_SUBDIRS),-Fu$(dir))

all: $(BIN_FILE)

$(BIN_FILE): $(MAIN_SRC)
	@mkdir -p $(BIN_DIR) $(OBJECT_DIR)
	$(PASCAL) $(FPCFLAGS) -o$@ $<

run: test_name := $(if $(test),$(test),test01)
run: $(BIN_FILE)
	@echo "Executando com teste '$(test_name).pmm'..."
	@if [ -f $(TESTS_DIR)/$(test_name).pmm ]; then \
		$(BIN_FILE) < $(TESTS_DIR)/$(test_name).pmm; \
	else \
		echo "Teste '$(test_name).pmm' não encontrado."; \
		exit 1; \
	fi

clean:
	@echo "Limpando arquivos compilados..."
	@rm -rf $(BUILD_DIR)/bin $(BUILD_DIR)/object
	@mkdir -p $(BIN_DIR) $(OBJECT_DIR)

list-tests:
	@echo "Testes disponíveis:"
	@find $(TESTS_DIR) -name "*.pmm" -exec basename {} .pmm \;

.PHONY: all run clean list-tests