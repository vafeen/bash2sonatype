# ===========================================
# УТИЛИТЫ ДЛЯ СКРИПТОВ ПУБЛИКАЦИИ
# ===========================================

# Цвета для вывода
RED := \033[0;31m
GREEN := \033[0;32m
YELLOW := \033[1;33m
BLUE := \033[0;34m
NC := \033[0m # No Color

# Функции логирования
define log_info
	@echo -e "$(BLUE)[INFO]$(NC) $(1)"
endef

define log_success
	@echo -e "$(GREEN)[SUCCESS]$(NC) $(1)"
endef

define log_warning
	@echo -e "$(YELLOW)[WARNING]$(NC) $(1)"
endef

define log_error
	@echo -e "$(RED)[ERROR]$(NC) $(1)"
endef

define log_step
	@echo ""
	@echo "========================================"
	@echo "ШАГ: $(1)"
	@echo "========================================"
	@echo ""
endef

# Проверка существования команды
check_command = $(if $(shell command -v $(1) 2>/dev/null),\
	$(call log_success,Команда '$(1)' найдена),\
	$(call log_error,Команда '$(1)' не найдена) && false)

# Проверка Maven
check_maven = $(call check_command,mvn)

# Проверка обязательных переменных
check_required_vars = \
	$(if $(GROUP_ID),,$(call log_error,GROUP_ID не заполнена) $(eval __MISSING := true)) \
	$(if $(ARTIFACT_NAME),,$(call log_error,ARTIFACT_NAME не заполнена) $(eval __MISSING := true)) \
	$(if $(VERSION),,$(call log_error,VERSION не заполнена) $(eval __MISSING := true)) \
	$(if $(SONATYPE_USERNAME),,$(call log_error,SONATYPE_USERNAME не заполнена) $(eval __MISSING := true)) \
	$(if $(SONATYPE_PASSWORD),,$(call log_error,SONATYPE_PASSWORD не заполнена) $(eval __MISSING := true)) \
	$(if $(GPG_KEY_ID),,$(call log_error,GPG_KEY_ID не заполнена) $(eval __MISSING := true)) \
	$(if $(GPG_PASSPHRASE),,$(call log_error,GPG_PASSPHRASE не заполнена) $(eval __MISSING := true)) \
	$(if $(__MISSING),$(error Не заполнены обязательные переменные),$(call log_success,Все обязательные переменные заполнены))

# Создание временной директории
create_work_dir = $(shell mkdir -p $(BUILD_DIR)) \
	$(call log_success,Создано рабочее пространство)

# Очистка временных файлов
define cleanup_work_dir
	@if [ -d "$(BUILD_DIR)" ]; then \
		if rm -rf "$(BUILD_DIR)"; then \
			$(call log_success,Временная директория очищена); \
		else \
			$(call log_error,Ошибка при очистке временной директории); \
			exit 1; \
		fi; \
	fi
endef