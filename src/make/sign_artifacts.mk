# ===========================================
# ШАГ 4: ПОДПИСЬ АРТЕФАКТОВ GPG
# ===========================================

# Проверка файлов для подписи
check-files-for-signing:
	$(call log_info,Проверка файлов для подписи...)
	@REQUIRED_FILES="$(FINAL_JAR) $(SOURCES_JAR) $(JAVADOC_JAR) $(POM_FILE)"; \
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
		exit 1; \
	fi

# Подпись всех артефактов
sign-all-artifacts:
	$(call log_info,Подписание всех артефактов...)
	@TEMP_GPG_HOME="$(BUILD_DIR)/gpg-temp-home"; \
	rm -rf "$$TEMP_GPG_HOME"; \
	mkdir -p "$$TEMP_GPG_HOME"; \
	chmod 700 "$$TEMP_GPG_HOME"; \
	export GNUPGHOME="$$TEMP_GPG_HOME"; \
	\
	$(call log_info,Импорт ключа...); \
	if ! gpg --batch --import "$(GPG_KEY_FILE)" 2>/dev/null; then \
		$(call log_error,Не удалось импортировать ключ); \
		rm -rf "$$TEMP_GPG_HOME"; \
		exit 1; \
	fi; \
	\
	KEY_ID=$$(gpg --list-secret-keys --with-colons 2>/dev/null | grep '^sec:' | head -1 | cut -d: -f5); \
	if [ -z "$$KEY_ID" ]; then \
		$(call log_error,Не удалось получить ID ключа); \
		rm -rf "$$TEMP_GPG_HOME"; \
		exit 1; \
	fi; \
	SHORT_KEY_ID=$${KEY_ID: -8}; \
	$(call log_success,Ключ импортирован, ID: $$SHORT_KEY_ID); \
	\
	echo ""; \
	echo "ПОДПИСЬ ФАЙЛОВ:"; \
	echo "--------------"; \
	FILES="$(FINAL_JAR) $(SOURCES_JAR) $(JAVADOC_JAR) $(POM_FILE)"; \
	SUCCESS_COUNT=0; \
	for FILE in $$FILES; do \
		FILENAME=$$(basename "$$FILE"); \
		echo -n "  $$FILENAME ... "; \
		PASSPHRASE_FILE="$(BUILD_DIR)/passphrase.txt"; \
		echo "$(GPG_PASSPHRASE)" > "$$PASSPHRASE_FILE"; \
		chmod 600 "$$PASSPHRASE_FILE"; \
		if gpg --batch --yes \
			--passphrase-file "$$PASSPHRASE_FILE" \
			--pinentry-mode loopback \
			--local-user "$$KEY_ID" \
			--detach-sign \
			--armor \
			"$$FILE" 2>/dev/null; then \
			if [ -f "$$FILE.asc" ]; then \
				echo "✓"; \
				SUCCESS_COUNT=$$((SUCCESS_COUNT + 1)); \
			else \
				echo "✗ (подпись не создана)"; \
			fi; \
		else \
			echo "✗ (ошибка)"; \
		fi; \
		rm -f "$$PASSPHRASE_FILE"; \
	done; \
	rm -rf "$$TEMP_GPG_HOME"; \
	unset GNUPGHOME; \
	echo ""; \
	TOTAL_FILES=$$(echo $$FILES | wc -w); \
	if [ $$SUCCESS_COUNT -eq $$TOTAL_FILES ]; then \
		$(call log_success,Все файлы подписаны ($$SUCCESS_COUNT/$$TOTAL_FILES)); \
	else \
		$(call log_error,Подписано только $$SUCCESS_COUNT из $$TOTAL_FILES файлов); \
		exit 1; \
	fi

# Проверка подписей
verify-signatures:
	$(call log_info,Проверка подписей...)
	@FILES="$(FINAL_JAR) $(SOURCES_JAR) $(JAVADOC_JAR) $(POM_FILE)"; \
	ALL_VERIFIED=true; \
	VERIFIED_COUNT=0; \
	for FILE in $$FILES; do \
		SIGNATURE_FILE="$$FILE.asc"; \
		if [ -f "$$SIGNATURE_FILE" ]; then \
			$(call log_success,Подпись найдена: $$(basename "$$SIGNATURE_FILE")); \
			VERIFIED_COUNT=$$((VERIFIED_COUNT + 1)); \
		else \
			$(call log_error,Подпись не найдена для: $$(basename "$$FILE")); \
			ALL_VERIFIED=false; \
		fi; \
	done; \
	TOTAL_FILES=$$(echo $$FILES | wc -w); \
	if [ "$$ALL_VERIFIED" = false ]; then \
		$(call log_error,Найдено только $$VERIFIED_COUNT из $$TOTAL_FILES подписей); \
		exit 1; \
	else \
		$(call log_success,Все $$TOTAL_FILES подписей найдены); \
	fi

# Копирование всех артефактов в Maven структуру
copy-all-to-maven:
	$(call log_info,Копирование ВСЕХ артефактов в Maven структуру...)
	@ALL_FILES="$(FINAL_JAR) $(SOURCES_JAR) $(JAVADOC_JAR) $(POM_FILE) \
	             $(FINAL_JAR).asc $(SOURCES_JAR).asc $(JAVADOC_JAR).asc $(POM_FILE).asc \
	             $(FINAL_JAR).md5 $(SOURCES_JAR).md5 $(JAVADOC_JAR).md5 $(POM_FILE).md5 \
	             $(FINAL_JAR).sha1 $(SOURCES_JAR).sha1 $(JAVADOC_JAR).sha1 $(POM_FILE).sha1"; \
	echo "Копирование из $(BUILD_DIR) в $(MAVEN_DIR):"; \
	echo "--------------------------------------"; \
	COPIED_COUNT=0; \
	for FILE in $$ALL_FILES; do \
		if [ -f "$$FILE" ]; then \
			FILENAME=$$(basename "$$FILE"); \
			cp "$$FILE" "$(MAVEN_DIR)/"; \
			echo "  ✓ $$FILENAME"; \
			COPIED_COUNT=$$((COPIED_COUNT + 1)); \
		else \
			FILENAME=$$(basename "$$FILE"); \
			echo "  ✗ $$FILENAME (не найден)"; \
		fi; \
	done; \
	echo ""; \
	TOTAL_FILES=$$(echo $$ALL_FILES | wc -w); \
	if [ $$COPIED_COUNT -eq $$TOTAL_FILES ]; then \
		$(call log_success,Все $$TOTAL_FILES файлов скопированы); \
	else \
		$(call log_error,Скопированы только $$COPIED_COUNT из $$TOTAL_FILES файлов); \
		exit 1; \
	fi

# Проверка структуры Maven репозитория
verify-maven-structure:
	$(call log_info,Проверка структуры Maven репозитория...)
	@REQUIRED_FILES="$(FINAL_JAR) $(SOURCES_JAR) $(JAVADOC_JAR) $(POM_FILE) \
	                 $(FINAL_JAR).asc $(SOURCES_JAR).asc $(JAVADOC_JAR).asc $(POM_FILE).asc \
	                 $(FINAL_JAR).md5 $(SOURCES_JAR).md5 $(JAVADOC_JAR).md5 $(POM_FILE).md5 \
	                 $(FINAL_JAR).sha1 $(SOURCES_JAR).sha1 $(JAVADOC_JAR).sha1 $(POM_FILE).sha1"; \
	echo "Ожидаемая структура файлов (16 файлов):"; \
	echo "--------------------------------------"; \
	MISSING_COUNT=0; \
	FOUND_COUNT=0; \
	for REQUIRED_FILE in $$REQUIRED_FILES; do \
		FILENAME=$$(basename "$$REQUIRED_FILE"); \
		FILE_PATH="$(MAVEN_DIR)/$$FILENAME"; \
		if [ -f "$$FILE_PATH" ]; then \
			echo "  ✓ $$FILENAME"; \
			FOUND_COUNT=$$((FOUND_COUNT + 1)); \
		else \
			echo "  ✗ $$FILENAME (ОТСУТСТВУЕТ)"; \
			MISSING_COUNT=$$((MISSING_COUNT + 1)); \
		fi; \
	done; \
	echo ""; \
	echo "Итого: найдено $$FOUND_COUNT из 16 файлов"; \
	echo ""; \
	echo "Реальное содержимое $(MAVEN_DIR):"; \
	echo "------------------------------"; \
	if [ -d "$(MAVEN_DIR)" ]; then \
		ls -la "$(MAVEN_DIR)"; \
	else \
		echo "Директория не существует!"; \
	fi; \
	echo ""; \
	if [ $$MISSING_COUNT -eq 0 ]; then \
		$(call log_success,✅ ВСЕ 16 файлов присутствуют!); \
	else \
		$(call log_error,❌ Отсутствуют файлы: $$MISSING_COUNT); \
		exit 1; \
	fi

# Общая цель подписи артефактов
.PHONY: sign-artifacts
sign-artifacts:
	$(call log_step,4: Подпись артефактов GPG)
	$(MAKE) check-files-for-signing
	$(MAKE) sign-all-artifacts
	$(MAKE) verify-signatures
	$(MAKE) copy-all-to-maven
	$(MAKE) verify-maven-structure
	$(call log_success,Все артефакты подписаны и проверены)

# Быстрая проверка подписей
.PHONY: quick-verify-signatures
quick-verify-signatures:
	@echo "=== БЫСТРАЯ ПРОВЕРКА ПОДПИСЕЙ ==="
	@for FILE in "$(FINAL_JAR)" "$(SOURCES_JAR)" "$(JAVADOC_JAR)" "$(POM_FILE)"; do \
		if [ -f "$$FILE.asc" ]; then \
			echo "✓ $$(basename "$$FILE").asc"; \
		else \
			echo "✗ $$(basename "$$FILE").asc"; \
		fi; \
	done
	@echo "================================"

# Очистка подписей
.PHONY: clean-signatures
clean-signatures:
	@echo "Очистка подписей..."
	@rm -f "$(FINAL_JAR).asc" "$(SOURCES_JAR).asc" "$(JAVADOC_JAR).asc" "$(POM_FILE).asc"
	@echo "Подписи удалены"