ifneq ($(USER_CONFIG),)
    include $(USER_CONFIG)
endif

include ./src/make/utils.mk
include ./src/make/source.mk
include ./src/make/check_env.mk
include ./src/make/prepare_jars.mk
include ./src/make/generate_pom.mk
include ./src/make/sign_artifacts.mk
include ./src/make/publish_maven.mk


check:
	@echo "=== КОНФИГУРАЦИЯ ПРОЕКТА ==="
	@echo "Group ID: $(GROUP_ID)"
	@echo "Artifact: $(ARTIFACT_MODULE_NAME)"
	@echo "Version: $(VERSION)"
	@echo "Sources Package: $(SOURCES_PACKAGE)"
	@echo ""
	@echo "=== МЕТАДАННЫЕ ==="
	@echo "Project Name: $(PROJECT_NAME)"
	@echo "Description: $(PROJECT_DESCRIPTION)"
	@echo "Project URL: $(PROJECT_URL)"
	@echo "SCM URL: $(SCM_URL)"
	@echo ""
	@echo "=== РАЗРАБОТЧИК ==="
	@echo "Developer: $(DEVELOPER_NAME)"
	@echo "Email: $(DEVELOPER_EMAIL)"
	@echo "Organization: $(ORGANIZATION)"
	@echo "Organization URL: $(ORGANIZATION_URL)"
	@echo "=========================="

# ===========================================
# ПОЛНАЯ ПОСЛЕДОВАТЕЛЬНОСТЬ ПУБЛИКАЦИИ
# ===========================================

# Основные цели
.PHONY: all clean publish-full

# Полная последовательность публикации
# all: publish-full

# Полный процесс (все шаги)
publish-full: clean-all \
              prepare-env \
              copy-jar \
              check-all \
              prepare-jars \
              create-publish-files \
              sign-artifacts \
              generate-checksums \
              create-bundle-tar \
              publish-to-sonatype

# Очистить всё
clean-all:
	rm -rf ./make2maven/build
