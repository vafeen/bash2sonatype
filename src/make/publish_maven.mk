# ===========================================
# ШАГ 6: ПУБЛИКАЦИЯ В MAVEN CENTRAL
# ===========================================

# Показать информацию о публикации
show-publication-info:
	@echo "Данные для публикации:"
	@echo "----------------------"
	@echo "Группа:       $(GROUP_ID)"
	@echo "Артефакт:     $(ARTIFACT_NAME)"
	@echo "Версия:       $(VERSION)"
	@echo "Пакет:        $(SOURCES_PACKAGE)"
	@echo "Репозиторий:  $(REPOSITORY_URL)"
	@echo ""

# Подтверждение публикации
confirm-publication:
	@read -p "Продолжить публикацию? (y/n): " -n 1 -r; \
	echo ""; \
	if [[ ! $$REPLY =~ ^[Yy]$$ ]]; then \
		$(call log_success,Публикация отменена); \
		exit 0; \
	fi

# Проверка файлов для публикации
check-files-for-publication:
	$(call log_info,Проверка файлов для публикации...)
	@REQUIRED_FILES="$(FINAL_JAR) $(SOURCES_JAR) $(JAVADOC_JAR) $(POM_FILE) \
	                 $(FINAL_JAR).asc $(SOURCES_JAR).asc $(JAVADOC_JAR).asc $(POM_FILE).asc \
	                 $(SETTINGS_FILE)"; \
	ALL_FOUND=true; \
	for FILE in $$REQUIRED_FILES; do \
		if [ -f "$$FILE" ]; then \
			$(call log_success,Файл найден: $$(basename "$$FILE")); \
		else \
			$(call log_error,Файл не найден: $$(basename "$$FILE")); \
			ALL_FOUND=false; \
		fi; \
	done; \
	if [ "$$ALL_FOUND" = false ]; then \
		$(call log_error,Не все файлы найдены для публикации); \
		exit 1; \
	fi

# Публикация в Sonatype Central
publish-to-sonatype:
	$(call log_info,Загрузка в Sonatype Central...)
	@TOKEN=$$(echo -n "$(SONATYPE_USERNAME):$(SONATYPE_PASSWORD)" | base64); \
	if [ -z "$$TOKEN" ]; then \
		$(call log_error,Не удалось создать токен авторизации); \
		exit 1; \
	fi; \
	$(call log_info,Отправка bundle через Sonatype Central API...); \
	echo "Используемый файл: $(BUNDLE_ZIP)"; \
	echo "Размер файла: $$(ls -lh "$(BUNDLE_ZIP)" | awk '{print $$5}')"; \
	RESPONSE_FILE="$(BUILD_DIR)/upload_response.txt"; \
	echo "Выполняю запрос к Sonatype Central..."; \
	echo "URL: https://central.sonatype.com/api/v1/publisher/upload"; \
	echo ""; \
	HTTP_CODE=$$(curl --request POST \
		--silent \
		--show-error \
		--write-out "HTTP_STATUS:%{http_code}" \
		--header "Authorization: Bearer $$TOKEN" \
		--header "User-Agent: Maven-Publisher/1.0" \
		--form "bundle=@$(BUNDLE_ZIP)" \
		--output "$$RESPONSE_FILE" \
		https://central.sonatype.com/api/v1/publisher/upload); \
	EXIT_CODE=$$?; \
	HTTP_STATUS=$$(echo "$$HTTP_CODE" | grep -o "HTTP_STATUS:[0-9]*" | cut -d: -f2); \
	echo ""; \
	echo "Результат запроса:"; \
	echo "Код выхода curl: $$EXIT_CODE"; \
	echo "HTTP статус: $$HTTP_STATUS"; \
	if [ -f "$$RESPONSE_FILE" ] && [ -s "$$RESPONSE_FILE" ]; then \
		echo ""; \
		echo "Ответ сервера:"; \
		cat "$$RESPONSE_FILE"; \
		echo ""; \
	fi; \
	if [ $$EXIT_CODE -eq 0 ] && ( [ "$$HTTP_STATUS" = "200" ] || [ "$$HTTP_STATUS" = "201" ] ); then \
		$(call log_success,✅ Bundle успешно загружен в Sonatype Central); \
		rm -f "$$RESPONSE_FILE" 2>/dev/null; \
	else \
		$(call log_error,❌ Ошибка загрузки bundle); \
		rm -f "$$RESPONSE_FILE" 2>/dev/null; \
		exit 1; \
	fi

# Показать успех публикации
show-publication-success:
	@echo ""
	@echo "Артефакты опубликованы:"
	@echo "  • $$(basename $(FINAL_JAR))"
	@echo "  • $$(basename $(SOURCES_JAR))"
	@echo "  • $$(basename $(JAVADOC_JAR))"
	@echo ""
	@if [ "$(IS_SNAPSHOT)" = "true" ]; then \
		$(call log_success,SNAPSHOT версия опубликована); \
	else \
		$(call log_info,RELEASE версия в staging репозитории); \
		echo "Для выпуска в Central:"; \
		echo "1. https://central.sonatype.com"; \
		echo "2. Найти staging репозиторий"; \
		echo "3. Close → Release"; \
	fi
	@echo ""
	@echo "Ссылка для проверки:"
	@echo "https://repo1.maven.org/maven2/$$(echo $(GROUP_ID) | tr '.' '/')/$(ARTIFACT_NAME)/$(VERSION)/"

# Показать ошибку публикации
show-publication-error:
	$(call log_error,Ошибка при публикации)

# Очистка после публикации
cleanup-after-publication:
	$(call log_info,Очистка временных файлов...)
	@if rm -f "$(POM_FILE)" "$(SETTINGS_FILE)" 2>/dev/null; then \
		$(call log_success,Файлы удалены); \
	else \
		$(call log_error,Ошибка удаления файлов); \
		exit 1; \
	fi
	@if rm -f "$(FINAL_JAR).asc" "$(SOURCES_JAR).asc" "$(JAVADOC_JAR).asc" "$(POM_FILE).asc" 2>/dev/null; then \
		$(call log_success,Подписи удалены); \
	else \
		$(call log_error,Ошибка удаления подписей); \
		exit 1; \
	fi
	@$(MAKE) cleanup-work-dir

# Выполнить публикацию
perform-publication:
	$(call log_info,Начало публикации...)
	@if $(MAKE) publish-to-sonatype; then \
		$(MAKE) show-publication-success; \
		# $(MAKE) cleanup-after-publication; \
		$(call log_success,Процесс публикации завершен); \
	else \
		$(MAKE) show-publication-error; \
		exit 1; \
	fi

# Общая цель публикации
.PHONY: publish
publish:
	$(call log_step,6: Публикация в Maven Central)
	$(MAKE) show-publication-info
	# $(MAKE) confirm-publication  # Раскомментировать для подтверждения
	$(MAKE) check-files-for-publication
	$(MAKE) perform-publication

# Быстрая публикация (без подтверждения)
.PHONY: quick-publish
quick-publish:
	$(call log_step,Быстрая публикация)
	$(MAKE) check-files-for-publication
	$(MAKE) publish-to-sonatype
	$(MAKE) show-publication-success

# Проверка URL публикации
.PHONY: check-publication-url
check-publication-url:
	@echo "=== ПРОВЕРКА URL ПУБЛИКАЦИИ ==="
	@echo "Репозиторий: $(REPOSITORY_URL)"
	@echo "Bundle: $(BUNDLE_ZIP)"
	@echo "Размер: $$(ls -lh "$(BUNDLE_ZIP)" | awk '{print $$5}')"
	@echo "================================"

# Тестовая публикация (без реальной отправки)
.PHONY: test-publish
test-publish:
	$(call log_info,Тестовая публикация...)
	@echo "=== ТЕСТОВЫЕ ДАННЫЕ ==="
	@echo "GROUP_ID: $(GROUP_ID)"
	@echo "ARTIFACT_NAME: $(ARTIFACT_NAME)"
	@echo "VERSION: $(VERSION)"
	@echo "USERNAME: $(SONATYPE_USERNAME)"
	@echo "PASSWORD: ***"
	@echo "GPG_KEY: $(GPG_KEY_ID)"
	@echo "======================"
	@echo "Все переменные установлены ✓"