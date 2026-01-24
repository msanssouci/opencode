---
agent: 'build'
description: 'Create Spring Boot Kotlin Project Skeleton'
---

# Create Spring Boot Kotlin project prompt

- Please make sure you have the following software installed on your system:

  - Java 21
  - Docker
  - Docker Compose

- If you need to custom the project name, please change the `artifactId` and the `packageName` in [download-spring-boot-project-template](./create-spring-boot-kotlin-project.prompt.md#download-spring-boot-project-template)

- If you need to update the Spring Boot version, please change the `bootVersion` in [download-spring-boot-project-template](./create-spring-boot-kotlin-project.prompt.md#download-spring-boot-project-template)

## Check Java version

- Run following command in terminal and check the version of Java

```shell
java -version
```

## Download Spring Boot project template

- Run following command in terminal to download a Spring Boot project template

```shell
curl https://start.spring.io/starter.zip \
  -d artifactId=${input:projectName:demo-kotlin} \
  -d bootVersion=3.5.9 \
  -d dependencies=actuator,configuration-processor,actuator,jooq,web,postgresql,data-redis,validation,cache \
  -d javaVersion=25 \
  -d language=kotlin \
  -d packageName=${input:packgeName:com.sans.souci.$projectName}\
  -d packaging=jar \
  -d configurationFileFormat=yaml
  -d type=gradle-project-kotlin \
  -o starter.zip
```

## Unzip the downloaded file

- Run following command in terminal to unzip the downloaded file

```shell
unzip starter.zip -d ./${input:projectName:demo-kotlin}
```

## Remove the downloaded zip file

- Run following command in terminal to delete the downloaded zip file

```shell
rm -f starter.zip
```

## Apply Gradle Version Catalog

- Create `gradle/libs.versions.toml` file to centralize version management

```toml
[versions]
kotlin = "2.3.0"
kotlin-plugin-spring = "1.9.25"
spring-boot = "3.5.9"
spring-dependency-management = "1.1.7"
archunit = "1.2.1"
flyway = "11.20.2"

[libraries]
spring-boot-starter-actuator = { module = "org.springframework.boot:spring-boot-starter-actuator" }
spring-boot-starter-cache = { module = "org.springframework.boot:spring-boot-starter-cache" }
spring-boot-starter-data-redis = { module = "org.springframework.boot:spring-boot-starter-data-redis" }
spring-boot-starter-jooq = { module = "org.springframework.boot:spring-boot-starter-jooq" }
spring-boot-starter-validation = { module = "org.springframework.boot:spring-boot-starter-validation" }
spring-boot-starter-web = { module = "org.springframework.boot:spring-boot-starter-web" }
spring-boot-configuration-processor = { module = "org.springframework.boot:spring-boot-configuration-processor" }
spring-boot-starter-test = { module = "org.springframework.boot:spring-boot-starter-test" }
jackson-module-kotlin = { module = "com.fasterxml.jackson.module:jackson-module-kotlin" }
kotlin-reflect = { module = "org.jetbrains.kotlin:kotlin-reflect" }
kotlin-test-junit5 = { module = "org.jetbrains.kotlin:kotlin-test-junit5" }
postgresql = { module = "org.postgresql:postgresql" }
flyway-database-postgresql = { module = "org.flywaydb:flyway-database-postgresql", version.ref = "flyway" }
archunit-junit5 = { module = "com.tngtech.archunit:archunit-junit5", version.ref = "archunit" }
junit-platform-launcher = { module = "org.junit.platform:junit-platform-launcher" }

[plugins]
kotlin-jvm = { id = "org.jetbrains.kotlin.jvm", version.ref = "kotlin" }
kotlin-spring = { id = "org.jetbrains.kotlin.plugin.spring", version.ref = "kotlin-plugin-spring" }
spring-boot = { id = "org.springframework.boot", version.ref = "spring-boot" }
spring-dependency-management = { id = "io.spring.dependency-management", version.ref = "spring-dependency-management" }
flyway = { id = "org.flywaydb.flyway", version.ref = "flyway" }
```

- Update `build.gradle.kts` to use the version catalog

  - Replace the `plugins` block:
  ```kotlin
  plugins {
    alias(libs.plugins.kotlin.jvm)
    alias(libs.plugins.kotlin.spring)
    alias(libs.plugins.spring.boot)
    alias(libs.plugins.spring.dependency.management)
  }
  ```

  - Replace the `dependencies` block to use catalog references:
  ```kotlin
  dependencies {
    implementation(libs.spring.boot.starter.actuator)
    implementation(libs.spring.boot.starter.cache)
    implementation(libs.spring.boot.starter.data.redis)
    implementation(libs.spring.boot.starter.jooq)
    implementation(libs.spring.boot.starter.validation)
    implementation(libs.spring.boot.starter.web)
    implementation(libs.jackson.module.kotlin)
    implementation(libs.kotlin.reflect)
    runtimeOnly(libs.postgresql)
    annotationProcessor(libs.spring.boot.configuration.processor)
    testImplementation(libs.spring.boot.starter.test)
    testImplementation(libs.kotlin.test.junit5)
    testImplementation(libs.archunit.junit5)
    testRuntimeOnly(libs.junit.platform.launcher)
  }
  ```

## Configure Flyway Database Migration

- Add Flyway plugin and PostgreSQL database driver to `build.gradle.kts`

  - Add buildscript block at the top of the file (before plugins block):
  ```kotlin
  buildscript {
    repositories {
      mavenCentral()
    }
    dependencies {
      classpath(libs.flyway.database.postgresql)
    }
  }
  ```

  - Add Flyway plugin to the plugins block:
  ```kotlin
  plugins {
    alias(libs.plugins.kotlin.jvm)
    alias(libs.plugins.kotlin.spring)
    alias(libs.plugins.spring.boot)
    alias(libs.plugins.spring.dependency.management)
    alias(libs.plugins.flyway)
  }
  ```

  - Add Flyway configuration block at the end of the file:
  ```kotlin
  flyway {
    url = "jdbc:postgresql://localhost:5432/postgres"
    user = "postgres"
    password = "rootroot"
    locations = arrayOf("filesystem:src/main/resources/db/migration")
  }
  ```

  - Make check task depend on flywayMigrate:
  ```kotlin
  tasks.named("check") {
    dependsOn("flywayMigrate")
  }
  ```

- Create migration directory structure:
  ```shell
  mkdir -p src/main/resources/db/migration
  ```

- Create example migration file `src/main/resources/db/migration/V1__Create_person_table.sql`:
  ```sql
  -- Create person table
  CREATE TABLE person (
      id BIGSERIAL PRIMARY KEY,
      first_name VARCHAR(100) NOT NULL,
      last_name VARCHAR(100) NOT NULL,
      email VARCHAR(255) UNIQUE NOT NULL,
      date_of_birth DATE,
      created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
      updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
  );

  -- Create index on email for faster lookups
  CREATE INDEX idx_person_email ON person(email);

  -- Create index on last_name for faster searches
  CREATE INDEX idx_person_last_name ON person(last_name);
  ```

- Available Flyway Gradle tasks:
  - `./gradlew flywayMigrate` - Run database migrations
  - `./gradlew flywayInfo` - View migration status
  - `./gradlew flywayValidate` - Validate applied migrations
  - `./gradlew flywayClean` - Drop all database objects (use with caution!)
  - `./gradlew check` - Runs flywayMigrate before executing checks

## Configure jOOQ Code Generation

- Add jOOQ version and plugin to version catalog (`gradle/libs.versions.toml`)

  - Add jOOQ version to `[versions]` section:
  ```toml
  jooq = "3.19.29"
  ```

  - Add jOOQ codegen plugin to `[plugins]` section:
  ```toml
  jooq-codegen = { id = "org.jooq.jooq-codegen-gradle", version.ref = "jooq" }
  ```

- Update `build.gradle.kts` to configure jOOQ code generation

  - Add jOOQ codegen plugin to the plugins block:
  ```kotlin
  plugins {
    alias(libs.plugins.kotlin.jvm)
    alias(libs.plugins.kotlin.spring)
    alias(libs.plugins.spring.boot)
    alias(libs.plugins.spring.dependency.management)
    alias(libs.plugins.flyway)
    alias(libs.plugins.jooq.codegen)
  }
  ```

  - Add PostgreSQL driver to jooqCodegen dependencies:
  ```kotlin
  dependencies {
    implementation(libs.spring.boot.starter.actuator)
    implementation(libs.spring.boot.starter.cache)
    implementation(libs.spring.boot.starter.data.redis)
    implementation(libs.spring.boot.starter.jooq)
    implementation(libs.spring.boot.starter.validation)
    implementation(libs.spring.boot.starter.web)
    implementation(libs.jackson.module.kotlin)
    implementation(libs.kotlin.reflect)
    runtimeOnly(libs.postgresql)
    jooqCodegen(libs.postgresql)
    annotationProcessor(libs.spring.boot.configuration.processor)
    testImplementation(libs.spring.boot.starter.test)
    testImplementation(libs.kotlin.test.junit5)
    testImplementation(libs.archunit.junit5)
    testRuntimeOnly(libs.junit.platform.launcher)
  }
  ```

  - Add generated sources to Kotlin source sets in the kotlin block:
  ```kotlin
  kotlin {
    compilerOptions {
      freeCompilerArgs.addAll("-Xjsr305=strict")
    }
    sourceSets {
      main {
        kotlin.srcDir("build/generated-src/jooq/main")
      }
    }
  }
  ```

  - Add jOOQ configuration block at the end of the file:
  ```kotlin
  jooq {
    configuration {
      jdbc {
        driver = "org.postgresql.Driver"
        url = "jdbc:postgresql://localhost:5432/postgres"
        user = "postgres"
        password = "rootroot"
      }
      generator {
        name = "org.jooq.codegen.KotlinGenerator"
        database {
          name = "org.jooq.meta.postgres.PostgresDatabase"
          inputSchema = "public"
        }
        target {
          packageName = "com.sans.souci.${input:projectName:demo-kotlin}.jooq"
          directory = "build/generated-src/jooq/main"
        }
      }
    }
  }
  ```

  - Set up task dependencies for code generation:
  ```kotlin
  tasks.named("jooqCodegen") {
    dependsOn("flywayMigrate")
  }

  tasks.named("compileKotlin") {
    dependsOn("jooqCodegen")
  }
  ```

- Available jOOQ Gradle tasks:
  - `./gradlew jooqCodegen` - Generate jOOQ code from database schema
  - `./gradlew build` - Full build (includes migration + codegen + compile + test)
  - `./gradlew clean build` - Clean and rebuild everything

- Generated jOOQ code:
  - Location: `build/generated-src/jooq/main`
  - Language: Kotlin (idiomatic Kotlin code with properties)
  - Package: Specified in configuration
  - Includes: Table classes, Record classes, Keys, Indexes, Schema references
  - Type-safe: Full compile-time safety for database operations

## Add additional dependencies

- Insert Spring Data Redis configurations into `application.yml` file

```yml
spring:
  data:
    redis:
      host: localhost
      port: 6379
      password: rootroot
```

- Insert Spring Data Postgres configurations into `application.yml` file

```yml
spring:
  data:
    posgres:
      host: localhost
      url: jdbc:postgresql://localhost:5432/postgres
      username: postgres
      password: rootroot

  sql:
    init:
      mode: always
      platform: postgres
      continue-on-error: true
```

- Create `docker-compose.yaml` at project root and add following services: `redis:6` and `postgresql:17`.

  - redis service should have
    - password `rootroot`
    - mapping port 6379 to 6379
    - mounting volume `./redis_data` to `/data`
  - postgresql service should have
    - password `rootroot`
    - mapping port 5432 to 5432
    - mounting volume `./postgres_data` to `/var/lib/postgresql/data`

- Insert `redis_data` and `postgres_data` directories in `.gitignore` file


## Setup Just task runner with project automation tasks
1. Install Just if not already installed using homebrew.
 Example for macOS: brew install just
2. Create a justfile in the project root with the following content:
```shell
cat > justfile <<'EOF'
# Justfile - Project Task Runner
# Run tasks with: just <task>

# Docker Compose Up
# Brings up Docker containers
# Usage: just docker-up
docker-up:
 docker compose up -d

# Docker Compose Down
# Tears down Docker containers
# Usage: just docker-down
docker-down:
  docker compose down

# docker check
# Run docker ps command
# Usage: just docker-check
docker-check:
  docker compose ps

# Gradle Build (depends on Docker Up)
# Builds project with Gradle, ensures containers are running
# Usage: just build
build: docker-up
  ./gradlew build

# Gradle Clean (depends on Down, then Up)
# Cleans Gradle, restarts containers to ensure clean state
# Usage: just clean
clean: docker-down docker-up
  ./gradlew clean

# Run Application (depends on Docker Up)
# Runs the application with Gradle BootRun, ensures environment is ready
# Usage: just run-app
run-app: docker-up
  ./gradlew bootRun
EOF
```

3. Usage Examples:
```
   just docker-up     # Brings up docker containers
   just docker-down   # Stops docker containers
   just build         # Runs build after ensuring containers are up
   just clean         # Cleans, restarting containers for clean state
   just run-app       # Runs the application after starting containers
```

- Execute just task to check if the project is working

```shell
./gradlew clean test
```

- (Optional) `docker-compose up -d` to start the services, `./gradlew spring-boot:run` to run the Spring Boot project, `docker-compose rm -sf` to stop the services.

Let's do this step by step.
