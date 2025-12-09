# ===========================================
# ШАГ 1: ПРОВЕРКА ОКРУЖЕНИЯ И ЗАВИСИМОСТЕЙ
# ===========================================

# Проверка конфигурации
check_configuration:
	$(call log_info,Проверка конфигурации...)
	@$(MAKE) check-required-vars >/dev/null 2>&1 && \
		$(call log_success,Конфигурация найдена) || \
		($(call log_error,Конфигурация не найдена) && exit 1)

# Проверка обязательных команд
check-required-commands:
	$(call log_info,Проверка установленных программ...)
	@for cmd in java gpg jar; do \
		if command -v $$cmd >/dev/null 2>&1; then \
			$(call log_success,Команда '$$cmd' найдена); \
		else \
			$(call log_error,Команда '$$cmd' не найдена); \
			exit 1; \
		fi; \
	done

# Проверка директории с исходным кодом
check-src:
	$(call log_info,Проверка директории с исходным кодом...)
	@if [ -n "$(SOURCE_CODE_PATH)" ] && [ -d "$(SOURCE_CODE_PATH)" ]; then \
		$(call log_success,Директория с исходниками найдена); \
	else \
		$(call log_error,Директория с исходниками не найдена); \
		exit 1; \
	fi

# Проверка GPG ключа (закомментировано)
#check-gpg-environment:
#	$(call log_info,Проверка GPG ключа...)
#	@gpg --list-keys "$(GPG_KEY_ID)" >/dev/null 2>&1 && \
#		$(call log_success,GPG ключ найден) || \
#		($(call log_error,GPG ключ не найден) && exit 1)

# Общая цель проверки окружения
# .PHONY: check-environment
# check-environment:
# 	$(call log_step,1: Проверка окружения)
# 	@$(MAKE) check_configuration
# 	@$(MAKE) check-required-commands
# 	@$(MAKE) check-src
# # 	@$(MAKE) check-gpg-environment  # Раскомментировать если нужно
# 	$(call log_success,Проверка окружения завершена)

# # Альтернативный вариант с shell-функциями
# define check_configuration_shell
# 	$(call log_info,Проверка конфигурации...)
# 	@if $(MAKE) check-required-vars >/dev/null 2>&1; then \
# 		$(call log_success,Конфигурация найдена); \
# 	else \
# 		$(call log_error,Конфигурация не найдена); \
# 		exit 1; \
# 	fi
# endef

# # Быстрая проверка (все в одной цели)
# .PHONY: quick-check
# quick-check:
# 	$(call log_step,Быстрая проверка окружения)
# 	@echo "=== ПРОВЕРКА ==="
# 	@echo "GROUP_ID: $(GROUP_ID)"
# 	@echo "ARTIFACT_NAME: $(ARTIFACT_NAME)"
# 	@echo "VERSION: $(VERSION)"
# 	@echo "SOURCE_CODE_PATH: $(SOURCE_CODE_PATH)"
# 	@echo ""
# 	@echo "=== КОМАНДЫ ==="
# 	@for cmd in java gpg jar curl; do \
# 		if command -v $$cmd >/dev/null 2>&1; then \
# 			echo "✓ $$cmd"; \
# 		else \
# 			echo "✗ $$cmd"; \
# 		fi; \
# 	done
# 	@echo "=== GPG ==="
# 	@if [ -n "$(GPG_KEY_ID)" ]; then \
# 		echo "GPG_KEY_ID: $(GPG_KEY_ID)"; \
# 	else \
# 		echo "GPG_KEY_ID: не установлен"; \
# 	fi
# 	@echo "=============="