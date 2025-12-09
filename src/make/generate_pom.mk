# ===========================================
# ШАГ 3: СОЗДАНИЕ POM ФАЙЛА
# ===========================================

# Создание pom.xml
generate-pom-xml:
	$(call log_info,Создание pom.xml...)
	@POM_FILENAME="$(ARTIFACT_NAME)-$(VERSION).pom"; \
	POM_FILE="$(BUILD_DIR)/$$POM_FILENAME"; \
	export POM_FILE; \
	cat > "$$POM_FILE" << 'EOF';\
<?xml version="1.0" encoding="UTF-8"?> \
<project xmlns="http://maven.apache.org/POM/4.0.0" \
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" \
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 \
         http://maven.apache.org/xsd/maven-4.0.0.xsd"> \
    <modelVersion>4.0.0</modelVersion> \
 \
    <groupId>$(GROUP_ID)</groupId> \
    <artifactId>$(ARTIFACT_NAME)</artifactId> \
    <version>$(VERSION)</version> \
 \
    <name>$(PROJECT_NAME)</name> \
    <description>$(PROJECT_DESCRIPTION)</description> \
    <url>$(PROJECT_URL)</url> \
 \
    <licenses> \
        <license> \
            <name>Apache License, Version 2.0</name> \
            <url>https://www.apache.org/licenses/LICENSE-2.0.txt</url> \
            <distribution>repo</distribution> \
        </license> \
    </licenses> \
 \
    <developers> \
        <developer> \
            <name>$(DEVELOPER_NAME)</name> \
            <email>$(DEVELOPER_EMAIL)</email> \
            <organization>$(ORGANIZATION)</organization> \
            <organizationUrl>$(ORGANIZATION_URL)</organizationUrl> \
        </developer> \
    </developers> \
 \
    <scm> \
        <connection>scm:git:git://$$(echo $(SCM_URL) | sed 's/https:\/\///')</connection> \
        <developerConnection>scm:git:ssh://$$(echo $(SCM_URL) | sed 's/https:\/\///' | sed 's/github.com/git@github.com/')</developerConnection> \
        <url>$(PROJECT_URL)</url> \
        <tag>$(VERSION)</tag> \
    </scm> \
 \
    <properties> \
        <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding> \
        <maven.compiler.source>11</maven.compiler.source> \
        <maven.compiler.target>11</maven.compiler.target> \
        <sources.package>$(SOURCES_PACKAGE)</sources.package> \
    </properties> \
 \
    <distributionManagement> \
        <snapshotRepository> \
            <id>$(REPOSITORY_ID)</id> \
            <url>https://central.sonatype.com/content/repositories/snapshots</url> \
        </snapshotRepository> \
        <repository> \
            <id>$(REPOSITORY_ID)</id> \
            <url>https://central.sonatype.com/service/local/staging/deploy/maven2/</url> \
        </repository> \
    </distributionManagement> \
</project> \
EOF \
	$(call log_success,Создан файл: $$POM_FILENAME)

# Создание settings.xml
generate-settings-xml:
	$(call log_info,Создание settings.xml...)
	@cat > "$(SETTINGS_FILE)" << 'EOF';\
<?xml version="1.0" encoding="UTF-8"?> \
<settings xmlns="http://maven.apache.org/SETTINGS/1.0.0" \
          xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" \
          xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.0.0 \
          http://maven.apache.org/xsd/settings-1.0.0.xsd"> \
 \
    <servers> \
        <server> \
            <id>$(REPOSITORY_ID)</id> \
            <username>$(SONATYPE_USERNAME)</username> \
            <password>$(SONATYPE_PASSWORD)</password> \
        </server> \
    </servers> \
 \
    <profiles> \
        <profile> \
            <id>$(REPOSITORY_ID)</id> \
            <activation> \
                <activeByDefault>true</activeByDefault> \
            </activation> \
            <properties> \
                <gpg.executable>gpg</gpg.executable> \
                <gpg.keyname>$(GPG_KEY_ID)</gpg.keyname> \
                <gpg.passphrase>$(GPG_PASSPHRASE)</gpg.passphrase> \
            </properties> \
        </profile> \
    </profiles> \
</settings> \
EOF
	@chmod 600 "$(SETTINGS_FILE)"
	$(call log_success,Создан settings.xml)

# Создание структуры каталогов Maven
create-maven-directory-structure:
	$(call log_info,Создание структуры каталогов Maven...)
	@mkdir -p "$(MAVEN_DIR)"
	$(call log_success,Создана структура Maven)

# Копирование артефактов в Maven структуру
copy-artifacts-to-maven-structure:
	$(call log_info,Копирование ВСЕХ артефактов в Maven структуру...)
	@ARTIFACT_BASE="$(ARTIFACT_NAME)-$(VERSION)"; \
	ALL_FILES="$$ARTIFACT_BASE.jar $$ARTIFACT_BASE-sources.jar $$ARTIFACT_BASE-javadoc.jar $$ARTIFACT_BASE.pom \
	           $$ARTIFACT_BASE.jar.asc $$ARTIFACT_BASE-sources.jar.asc $$ARTIFACT_BASE-javadoc.jar.asc $$ARTIFACT_BASE.pom.asc \
	           $$ARTIFACT_BASE.jar.md5 $$ARTIFACT_BASE.jar.sha1 \
	           $$ARTIFACT_BASE-sources.jar.md5 $$ARTIFACT_BASE-sources.jar.sha1 \
	           $$ARTIFACT_BASE-javadoc.jar.md5 $$ARTIFACT_BASE-javadoc.jar.sha1 \
	           $$ARTIFACT_BASE.pom.md5 $$ARTIFACT_BASE.pom.sha1"; \
	echo "Копирование:"; \
	echo "-----------"; \
	COPIED_COUNT=0; \
	for FILE in $$ALL_FILES; do \
		SOURCE_FILE="$(BUILD_DIR)/$$FILE"; \
		if [ -f "$$SOURCE_FILE" ]; then \
			cp "$$SOURCE_FILE" "$(MAVEN_DIR)/"; \
			echo "  ✓ $$FILE"; \
			COPIED_COUNT=$$((COPIED_COUNT + 1)); \
		else \
			echo "  ✗ $$FILE (не найден)"; \
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

# Генерация контрольных сумм
generate-checksums:
	$(call log_info,Генерация контрольных сумм для основных файлов...)
	@echo "Генерация checksums (.md5 и .sha1):"
	@echo "----------------------------------"
	@MAIN_FILES="$(FINAL_JAR) $(SOURCES_JAR) $(JAVADOC_JAR) $(POM_FILE)"; \
	GENERATED_COUNT=0; \
	for FILE in $$MAIN_FILES; do \
		if [ -f "$$FILE" ]; then \
			FILENAME=$$(basename "$$FILE"); \
			echo -n "  $$FILENAME ... "; \
			if md5sum "$$FILE" | awk '{print $$1}' > "$$FILE.md5"; then \
				echo -n "md5✓ "; \
			else \
				echo "md5✗"; \
				continue; \
			fi; \
			if sha1sum "$$FILE" | awk '{print $$1}' > "$$FILE.sha1"; then \
				echo "sha1✓"; \
				GENERATED_COUNT=$$((GENERATED_COUNT + 1)); \
			else \
				echo "sha1✗"; \
				rm -f "$$FILE.md5" 2>/dev/null; \
			fi; \
		else \
			echo "  ✗ $$(basename "$$FILE") (не найден)"; \
		fi; \
	done; \
	echo ""; \
	echo "Созданные checksums:"; \
	find "$(BUILD_DIR)" -name "*.md5" -o -name "*.sha1" | xargs ls -la 2>/dev/null | sort || echo "  Нет checksums файлов"; \
	TOTAL_FILES=$$(echo $$MAIN_FILES | wc -w); \
	if [ $$GENERATED_COUNT -eq $$TOTAL_FILES ]; then \
		$(call log_success,Готово: созданы checksums для $$GENERATED_COUNT файлов); \
	else \
		$(call log_error,Проблема: созданы только для $$GENERATED_COUNT из $$TOTAL_FILES файлов); \
		exit 1; \
	fi

# Создание bundle TAR.GZ
create-bundle-tar:
	$(call log_info,Создание центрального bundle...)
	@if [ ! -d "$(MAVEN_REPO_DIR)" ] || [ -z "$$(ls -A "$(MAVEN_REPO_DIR)" 2>/dev/null)" ]; then \
		$(call log_error,Директория Maven-репозитория отсутствует или пуста: $(MAVEN_REPO_DIR)); \
		exit 1; \
	fi; \
	if tar -czf "$(BUNDLE_ZIP)" -C "$(MAVEN_REPO_DIR)" . > /dev/null 2>&1; then \
		SIZE=$$(ls -lh "$(BUNDLE_ZIP)" | awk '{print $$5}'); \
		$(call log_success,Создан bundle: $(BUNDLE_ZIP) ($$SIZE)); \
		echo ""; \
		echo "Содержимое bundle TAR.GZ:"; \
		echo "------------------------"; \
		tar -tzf "$(BUNDLE_ZIP)" | head -20; \
		echo "..."; \
	else \
		$(call log_error,Не удалось создать bundle TAR.GZ); \
		exit 1; \
	fi

# Показать созданные файлы
show-generated-files:
	@echo "=== СОЗДАННЫЕ ФАЙЛЫ ==="
	@echo "POM: $(notdir $(POM_FILE))"
	@echo "Settings: $(notdir $(SETTINGS_FILE))"
	@echo "Bundle: $(notdir $(BUNDLE_ZIP))"
	@echo "======================"

# Общая цель создания файлов публикации
.PHONY: create-publish-files
create-publish-files:
	$(call log_step,3: Создание файлов публикации)
	$(MAKE) generate-pom-xml
	$(MAKE) generate-settings-xml
	$(MAKE) generate-checksums
	$(MAKE) create-maven-directory-structure
	$(MAKE) copy-artifacts-to-maven-structure
	$(MAKE) create-bundle-tar
	$(MAKE) show-generated-files
	$(call log_success,Файлы публикации созданы)