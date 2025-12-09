PUBLISHER := make2maven
BASE_DIR := $(shell pwd)

# Путь к исходному коду
ARTIFACT_NAME := $(ARTIFACT_MODULE_NAME)
ARTIFACT_PREFIX := $(ARTIFACT_NAME)-$(VERSION)
BUILD_DIR := $(BASE_DIR)/$(PUBLISHER)/build

# Имена файлов
FINAL_JAR := $(BUILD_DIR)/$(ARTIFACT_PREFIX).jar
SOURCES_JAR := $(BUILD_DIR)/$(ARTIFACT_PREFIX)-sources.jar
JAVADOC_JAR := $(BUILD_DIR)/$(ARTIFACT_PREFIX)-javadoc.jar
POM_FILE := $(BUILD_DIR)/$(ARTIFACT_PREFIX).pom
SETTINGS_FILE := $(BUILD_DIR)/settings.xml

# Пути для bundle
MAVEN_REPO_DIR := $(BUILD_DIR)/maven-repo
MAVEN_DIR := $(MAVEN_REPO_DIR)/$(subst .,/,$(GROUP_ID))/$(ARTIFACT_NAME)/$(VERSION)
BUNDLE_ZIP := $(BUILD_DIR)/$(ARTIFACT_PREFIX).tar.gz

REPOSITORY_ID := ossrh
REPOSITORY_URL := https://central.sonatype.com/

.PHONY: check-config
check-config:
	@echo "=== ПРОВЕРКА КОНФИГУРАЦИИ ==="
	@echo "Base Dir: $(BASE_DIR)"
	@echo "Group ID: $(GROUP_ID)"
	@echo "Artifact/Module Name: $(ARTIFACT_NAME)"
	@echo "Version: $(VERSION)"
	@echo "Final JAR: $(notdir $(FINAL_JAR))"
	@echo "Sources JAR: $(notdir $(SOURCES_JAR))"
	@echo "Javadoc JAR: $(notdir $(JAVADOC_JAR))"
	@echo "POM File: $(notdir $(POM_FILE))"
	@echo "Maven Dir: $(MAVEN_DIR)"
	@echo "Target Dir: $(BUILD_DIR)"
	@echo "Repository ID: $(REPOSITORY_ID)"
	@echo "Repository URL: $(REPOSITORY_URL)"
	@echo "Username set: $(if $(SONATYPE_USERNAME),YES,NO)"
	@echo "Password set: $(if $(SONATYPE_PASSWORD),YES,NO)"
	@echo "GPG Key ID: $(GPG_KEY_ID)"
	@echo "GPG Passphrase set: $(if $(GPG_PASSPHRASE),YES,NO)"
	@echo "=============================="