PASCAL = fpc
SRC_DIR = src
BUILD_DIR = build
TESTS_DIR = tests

SRC_SUBDIRS := $(shell find $(SRC_DIR) -type d)

MAIN_SRC = $(SRC_DIR)/main.pas
BIN_FILE = $(BUILD_DIR)/main

FPCFLAGS = -FE$(BUILD_DIR) -FU$(BUILD_DIR) $(foreach dir,$(SRC_SUBDIRS),-Fu$(dir))

all: $(BIN_FILE)

$(BIN_FILE): $(MAIN_SRC)
	@mkdir -p $(BUILD_DIR)
	$(PASCAL) $(FPCFLAGS) -o$@ $<

run: test_name := $(if $(test),$(test),test01)
run: $(BIN_FILE)
	@echo "Executando com teste '$(test_name).pmm'..."
	@if [ -f $(TESTS_DIR)/$(test_name).pmm ]; then \
		./$(BIN_FILE) < $(TESTS_DIR)/$(test_name).pmm; \
	else \
		echo "Teste '$(test_name).pmm' não encontrado."; \
		exit 1; \
	fi

clean:
	@echo "Limpando arquivos compilados..."
	@find $(BUILD_DIR) -type f -not -name '.gitkeep' -delete
	@mkdir -p $(BUILD_DIR)

list-tests:
	@echo "Testes disponíveis:"
	@find $(TESTS_DIR) -name "*.pmm" -exec basename {} .pmm \;