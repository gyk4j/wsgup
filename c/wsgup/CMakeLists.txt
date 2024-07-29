cmake_minimum_required(VERSION 3.25.3)

project(wsgup VERSION 0.0.1 LANGUAGES C)

# set(OPENSSL_ROOT_DIR "/usr/lib")
# set(OPENSSL_USE_STATIC_LIBS TRUE)
find_package(OpenSSL REQUIRED)

MESSAGE (STATUS "Found? ${OPENSSL_FOUND}")
MESSAGE (STATUS "Includes: ${OPENSSL_INCLUDE_DIR}")
MESSAGE (STATUS "Crypto library: ${OPENSSL_CRYPTO_LIBRARY}")

file(GLOB_RECURSE SOURCE_FILES src/*.c)
add_executable(${PROJECT_NAME} ${SOURCE_FILES})
target_include_directories(${PROJECT_NAME} PUBLIC include)
target_link_libraries(${PROJECT_NAME} OpenSSL::Crypto)
