markdown
# Система публикации в Maven Central

## 🚀 Быстрый старт

1. **Заполните конфигурацию:**

```bash
nano scripts/0_config.sh
```

Заполните ВСЕ переменные, особенно:

**SONATYPE_USERNAME** и **SONATYPE_PASSWORD**

**GPG_KEY_ID** и **GPG_PASSPHRASE**

Подготовьте GPG ключ:

```bash
# Генерация нового ключа
gpg --gen-key

# Просмотр ключей
gpg --list-keys --keyid-format=SHORT
```

Скопируйте последние 8 символов (например: ABCD1234)
Запустите по шагам:

```bash
# Шаг 1: Проверка
./scripts/2_check_env.sh

# Шаг 2: Подготовка JAR
./scripts/3_prepare_jars.sh

# Шаг 3: Создание POM
./scripts/4_generate_pom.sh

# Шаг 4: Подпись
./scripts/5_sign_artifacts.sh

# Шаг 5: Публикация
./scripts/6_publish_maven.sh
```
📋 Требования
Java 11+

Maven 3.6+

GPG 2.2+

Аккаунт Sonatype (https://issues.sonatype.org)

# 🔑 Настройка GPG
Экспорт ключа для GitHub Actions:

Экспорт приватного ключа
```bash
gpg --export-secret-keys --armor YOUR_KEY_ID > private-key.gpg
```

Экспорт публичного ключа на сервер
```bash
gpg --keyserver keyserver.ubuntu.com --send-keys YOUR_KEY_ID
```
Проверка публикации ключа:

```bash
gpg --keyserver keyserver.ubuntu.com --recv-keys YOUR_KEY_ID
```
# 🐛 Устранение проблем
## Ошибка: GPG подпись не работает

Проверьте что ключ существует
```bash
gpg --list-keys
```
Проверьте пароль
```
echo "test" | gpg --pinentry-mode loopback --passphrase "YOUR_PASSPHRASE" -e -a
```

## Ошибка: Доступ к репозиторию

Проверьте учетные данные Sonatype

Убедитесь что у вас есть права на группу com.castcastle

Проверьте настройки в https://issues.sonatype.org

# 📁 Структура после выполнения
```text
target/
├── cast-castle-annotations-1.0.0-alpha1.jar
├── cast-castle-annotations-1.0.0-alpha1-sources.jar
└── cast-castle-annotations-1.0.0-alpha1-javadoc.jar

*.asc           # GPG подписи (удаляются после публикации)
```

# 🔄 Использование с GitHub Actions
Экспортируйте переменные как Secrets:

```bash
# В 0_config.sh
export SONATYPE_USERNAME="${{ secrets.SONATYPE_USERNAME }}"
export SONATYPE_PASSWORD="${{ secrets.SONATYPE_PASSWORD }}"
```

---

## 9. Установка прав

```bash
# Дайте права на выполнение
chmod +x scripts/*.sh

# Сделайте 0_config.sh исполняемым (опционально)
chmod +x scripts/0_config.sh
```

## 10. Запуск
```bash
# Экспортируйте переменные
source scripts/0_config.sh

# Запустите проверку
./scripts/2_check_env.sh
```

# Если все ок, запускайте остальные шаги
Эта система позволяет легко публиковать артефакты и легко переносится в GitHub Actions через экспорт переменных!