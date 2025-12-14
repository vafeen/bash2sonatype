# Documentation 

## Setup signing data

1. Generate key pair

```
gpg --gen-key
```
Put your name, email adress and passphrase 

2. Show all keys

```
gpg --list-keys --keyid-format=SHORT
```
Output:
```
root@297bca09ab64:/bash2sonatypeExample# gpg --list-keys --keyid-format=SHORT
gpg: checking the trustdb
gpg: marginals needed: 3  completes needed: 1  trust model: pgp
gpg: depth: 0  valid:   1  signed:   0  trust: 0-, 0q, 0n, 0m, 0f, 1u
gpg: next trustdb check due at 2028-12-13
/root/.gnupg/pubring.kbx
------------------------
pub   ed25519/52D96560 2025-12-14 [SC] [expires: 2028-12-13]
      2503E8EEAE97E3162EE686194C94687C52D96560
uid         [ultimate] A <666av6@gmail.com>
sub   cv25519/D6997515 2025-12-14 [E] [expires: 2028-12-13]
```
52D96560 - your_key_id

> [!CAUTION]
> Before the following steps add "*.asc" to .gitignore

1. Export public key to file

```
gpg --armor --export your_key_id > public-key.asc
```

4. Export public key to server:

```
gpg --keyserver keyserver.ubuntu.com --send-keys your_key_id
```
5. Checking public key on server:

```
gpg --keyserver keyserver.ubuntu.com --recv-keys your_key_id
```

6. Export private key to file:

```
gpg --export-secret-keys --armor your_key_id > private-key.asc
```




## Config

Needed env variables:

### Public 
- Name of module with target library
```
export ARTIFACT_MODULE_NAME="test-publish"
```

- Path to folder with code
```
export SOURCE_CODE_PATH="$ARTIFACT_MODULE_NAME/src/main/java" # or kotlin
```

- Path to executabele file (it's different in kotlin and android libraries)
```
export ASSEMBLED_FILE="$ARTIFACT_MODULE_NAME/build/libs/$ARTIFACT_MODULE_NAME-$VERSION.jar" // kotlin 
// or 
export ASSEMBLED_FILE="$ARTIFACT_MODULE_NAME/build/outputs/aar/$ARTIFACT_MODULE_NAME-release.aar" // android
```

- Standard pom.xml variables:
```
export PROJECT_NAME
export PROJECT_DESCRIPTION

export GROUP_ID
export ARTIFACT_ID
export VERSION

export PROJECT_URL
export INCEPTION_YEAR
export DEVELOPER_EMAIL
export DEVELOPER_NAME
export SCM_URL
```

Put all this variables to some bash file `some_module_config_file`:
```
#!/bin/bash
export ARTIFACT_MODULE_NAME=
export SOURCE_CODE_PATH=
export ASSEMBLED_FILE=
...
export SCM_URL
```

### Secret 

#### Linux container / Linux host

> [!CAUTION]
> Don't put following variables with sensitive data to config file

- Sonatype data:
```
export SONATYPE_USERNAME
export SONATYPE_PASSWORD
```
- GPG signing data
```
export GPG_KEY_ID
export GPG_PASSPHRASE
export GPG_KEY_CONTENTS
```

How to create GPG_KEY_CONTENTS variable:
```
export GPG_KEY_CONTENTS=$(cat <<'EOF'
-----BEGIN PGP PRIVATE KEY BLOCK-----

secret_key
-----END PGP PRIVATE KEY BLOCK-----
EOF
)
```

#### CI/CD Github Actions

Add following secrets to repository:
- Sonatype data:
```
SONATYPE_USERNAME
SONATYPE_PASSWORD
```
- GPG signing data
```
GPG_KEY_ID
GPG_PASSPHRASE
GPG_KEY_CONTENTS
```

---
## Run


### Linux container / Linux host

Setup:
```
~/.../Your-project$ git clone https://github.com/vafeen/bash2sonatype.git
~/.../Your-project$ ./bash2sonatype/scripts/setup
```

Build project:
```
~/.../Your-project$ chmod +x ./gradlew
~/.../Your-project$ ./gradlew build
```

Publish:

```
~/.../Your-project$ source ./some_module_config_file
~/.../Your-project$ ./bash2sonatype/scripts/all_process false
```
The last argument means **auto-publishing** `true/false`


### CI/CD Github Actions

```
name: Publish

# for example, on tags
on:
  push:
    tags:
      - '*.*.*'

jobs:
  publish:
    name: Release build and publish
    runs-on: ubuntu-latest

    env:
      SONATYPE_USERNAME: ${{ secrets.SONATYPE_USERNAME }}
      SONATYPE_PASSWORD: ${{ secrets.SONATYPE_PASSWORD }}
      GPG_KEY_ID: ${{ secrets.GPG_KEY_ID }}
      GPG_PASSPHRASE: ${{ secrets.GPG_PASSPHRASE }}
      GPG_KEY_CONTENTS: ${{ secrets.GPG_KEY_CONTENTS }}

    steps:
      - name: Check out code
        uses: actions/checkout@v4

      - name: Bash2sonatype clone
        run: |
          git clone https://github.com/vafeen/bash2sonatype.git

      - name: Build
        run: |
          chmod +x ./gradlew
          ./gradlew build

      - name: Bash2sonatype publish
        run: |
          source ./some_module_config_file
          ./bash2sonatype/scripts/all_process false
```

---

## FAQ

- How to publish multiple modules?

Call modules sequentially 

```
~/.../Your-project$ source ./some_module_config_file
~/.../Your-project$ ./bash2sonatype/scripts/all_process false

~/.../Your-project$ source ./other_module_config_file
~/.../Your-project$ ./bash2sonatype/scripts/all_process false
```


