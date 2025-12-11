# ===========================================
# ШАГ 2: ПОДГОТОВКА JAR ФАЙЛОВ
# ===========================================

include $(dir $(lastword $(MAKEFILE_LIST)))config.mk

# Создание sources JAR
create-sources-jar:
	$(call log_info,Создание sources JAR...)
	@if [ -n "$(SOURCE_CODE_PATH)" ] && [ -d "$(SOURCE_CODE_PATH)" ]; then \
		$(call log_info,Использую исходники из: $(SOURCE_CODE_PATH)); \
		jar cf "$(SOURCES_JAR)" -C "$(SOURCE_CODE_PATH)" . && \
		$(call log_success,Создан sources JAR из исходников); \
	else \
		if [ -n "$(SOURCE_CODE_PATH)" ]; then \
			$(call log_warning,Директория с исходным кодом не найдена: $(SOURCE_CODE_PATH)); \
		else \
			$(call log_warning,Путь к исходникам не указан (SOURCE_CODE_PATH)); \
		fi; \
		$(call log_info,Создание минимального sources JAR...); \
		PACKAGE_PATH=$$(echo "$(SOURCES_PACKAGE)" | tr '.' '/'); \
		mkdir -p "$(BUILD_DIR)/sources/$$PACKAGE_PATH"; \
		cat > "$(BUILD_DIR)/sources/$$PACKAGE_PATH/package-info.java" << 'EOF';\
/** \
 * $(ARTIFACT_NAME) $(VERSION) \
 * \
 * <p>$(PROJECT_DESCRIPTION)</p> \
 * \
 * <p>Generated sources for $(GROUP_ID):$(ARTIFACT_NAME):$(VERSION)</p> \
 * \
 * @version $(VERSION) \
 * @since $(VERSION) \
 */ \
package $(SOURCES_PACKAGE); \
EOF \
		mkdir -p "$(BUILD_DIR)/sources/META-INF"; \
		cat > "$(BUILD_DIR)/sources/META-INF/MANIFEST.MF" << 'EOF';\
Manifest-Version: 1.0 \
Created-By: Maven Publication Script \
Implementation-Title: $(ARTIFACT_NAME) Sources \
Implementation-Version: $(VERSION) \
Group-Id: $(GROUP_ID) \
Artifact-Id: $(ARTIFACT_NAME) \
Sources-Package: $(SOURCES_PACKAGE) \
EOF \
		jar cf "$(SOURCES_JAR)" -C "$(BUILD_DIR)/sources" . && \
		$(call log_success,Создан минимальный sources JAR с пакетом: $(SOURCES_PACKAGE)); \
	fi

# Создание javadoc JAR
create-javadoc-jar:
	$(call log_info,Создание javadoc JAR...)
	@mkdir -p "$(BUILD_DIR)/javadoc"
	@cat > "$(BUILD_DIR)/javadoc/index.html" << 'EOF';\
<!DOCTYPE html> \
<html lang="en"> \
<head> \
    <meta charset="UTF-8"> \
    <meta name="viewport" content="width=device-width, initial-scale=1.0"> \
    <title>$(ARTIFACT_NAME) $(VERSION) - API Documentation</title> \
</head> \
<body> \
    <h1>$(ARTIFACT_NAME) $(VERSION)</h1> \
    <p>$(PROJECT_DESCRIPTION)</p> \
    <p>Group ID: $(GROUP_ID)</p> \
    <p>Artifact ID: $(ARTIFACT_NAME)</p> \
    <p>Version: $(VERSION)</p> \
    <p>Package: $(SOURCES_PACKAGE)</p> \
    <p>Project URL: <a href="$(PROJECT_URL)">$(PROJECT_URL)</a></p> \
</body> \
</html> \
EOF
	@mkdir -p "$(BUILD_DIR)/javadoc/META-INF"
	@cat > "$(BUILD_DIR)/javadoc/META-INF/MANIFEST.MF" << 'EOF';\
Manifest-Version: 1.0 \
Created-By: Maven Publication Script \
Implementation-Title: $(ARTIFACT_NAME) Javadoc \
Implementation-Version: $(VERSION) \
Group-Id: $(GROUP_ID) \
Artifact-Id: $(ARTIFACT_NAME) \
Package: $(SOURCES_PACKAGE) \
EOF
	@jar cf "$(JAVADOC_JAR)" -C "$(BUILD_DIR)/javadoc" . && \
	$(call log_success,Создан javadoc JAR)

# Проверка основного JAR файла
check-main-jar:
	$(call log_info,Проверка основного JAR файла $(FINAL_JAR)...)
	@if [ -f "$(FINAL_JAR)" ]; then \
		$(call log_success,Найден JAR файл: $(FINAL_JAR)); \
		$(call log_info,Проверка JAR файла...); \
		if jar tf "$(FINAL_JAR)" >/dev/null 2>&1; then \
			$(call log_success,JAR файл валиден); \
		else \
			$(call log_error,JAR файл поврежден или не является архивом); \
			exit 1; \
		fi; \
	else \
		$(call log_error,Основной JAR файл не найден: $(FINAL_JAR)); \
		echo ""; \
		echo "Убедитесь что файл существует в директории"; \
		echo ""; \
		exit 1; \
	fi

# Проверка sources JAR
check-sources-jar:
	$(call log_info,Проверка sources JAR...)
	@if [ -f "$(SOURCES_JAR)" ]; then \
		$(call log_success,Найден sources JAR: $(SOURCES_JAR)); \
		if jar tf "$(SOURCES_JAR)" >/dev/null 2>&1; then \
			$(call log_success,Sources JAR валиден); \
		else \
			$(call log_warning,Sources JAR поврежден, создаем новый...); \
			$(MAKE) create-sources-jar; \
		fi; \
	else \
		$(call log_warning,Sources JAR не найден: $(SOURCES_JAR)); \
		$(MAKE) create-sources-jar; \
	fi

# Проверка javadoc JAR
check-javadoc-jar:
	$(call log_info,Проверка javadoc JAR...)
	@if [ -f "$(JAVADOC_JAR)" ]; then \
		$(call log_success,Найден javadoc JAR: $(JAVADOC_JAR)); \
		if jar tf "$(JAVADOC_JAR)" >/dev/null 2>&1; then \
			$(call log_success,Javadoc JAR валиден); \
		else \
			$(call log_warning,Javadoc JAR поврежден, создаем новый...); \
			$(MAKE) create-javadoc-jar; \
		fi; \
	else \
		$(call log_warning,Javadoc JAR не найден: $(JAVADOC_JAR)); \
		$(MAKE) create-javadoc-jar; \
	fi

# Показать информацию о JAR файлах
show-jars-info:
	@echo ""
	@echo "Найденные JAR файлы:"
	@echo "-------------------"
	@echo ""
	@for jar_file in "$(FINAL_JAR)" "$(SOURCES_JAR)" "$(JAVADOC_JAR)"; do \
		if [ -f "$$jar_file" ]; then \
			file_size=$$(ls -lh "$$jar_file" | awk '{print $$5}'); \
			echo "  ✓ $$(basename "$$jar_file") ($$file_size)"; \
		else \
			$(call log_error,Файл не найден: $$(basename "$$jar_file")); \
			exit 1; \
		fi; \
	done
	@echo ""
	@echo "Настройки:"
	@echo "  Group ID: $(GROUP_ID)"
	@echo "  Artifact ID: $(ARTIFACT_NAME)"
	@echo "  Package: $(SOURCES_PACKAGE)"
	@if [ -n "$(SOURCE_CODE_PATH)" ]; then \
		echo "  Путь к исходникам: $(SOURCE_CODE_PATH)"; \
	else \
		echo "  Путь к исходникам: не указан (создан минимальный)"; \
	fi
	@echo ""
	$(call log_success,JAR файлы проверены и готовы!)
	@echo ""

# Общая цель подготовки JAR файлов
.PHONY: prepare-jars
prepare-jars:
	$(call log_step,2: Подготовка JAR файлов)
	$(MAKE) create-work-dir
	$(MAKE) check-main-jar
	$(MAKE) check-sources-jar
	$(MAKE) check-javadoc-jar
	$(MAKE) show-jars-info

# Альтернативная цель быстрой проверки
.PHONY: quick-jars-check
quick-jars-check:
	$(call log_info,Быстрая проверка JAR файлов...)
	@for jar in "$(FINAL_JAR)" "$(SOURCES_JAR)" "$(JAVADOC_JAR)"; do \
		if [ -f "$$jar" ]; then \
			echo "✓ $$(basename "$$jar")"; \
		else \
			echo "✗ $$(basename "$$jar")"; \
		fi; \
	done

# Создание рабочей директории
.PHONY: create-work-dir
create-work-dir:
	$(call log_info,Создание рабочей директории...)
	@mkdir -p "$(BUILD_DIR)"
	$(call log_success,Создана рабочая директория: $(BUILD_DIR))