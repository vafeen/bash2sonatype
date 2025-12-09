include Makefile_source

ifneq ($(USER_CONFIG),)
    include $(USER_CONFIG)
endif

# Проверим что переменные установлены
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
