cmake_minimum_required(VERSION 3.25.3)

project(wsgup VERSION 0.0.1 LANGUAGES C)

# set(OPENSSL_ROOT_DIR "/usr/lib")
# set(OPENSSL_USE_STATIC_LIBS TRUE)
find_package(OpenSSL REQUIRED)

MESSAGE (STATUS "Found? ${OPENSSL_FOUND}")
MESSAGE (STATUS "Includes: ${OPENSSL_INCLUDE_DIR}")
MESSAGE (STATUS "Crypto library: ${OPENSSL_CRYPTO_LIBRARY}")

# build dependencies into libraries
add_library(aesccm lib/openssl/aesccm.c)
target_include_directories(aesccm PUBLIC include lib/openssl)
target_link_libraries(aesccm OpenSSL::Crypto)

add_library(cjson lib/cjson/cJSON.c)
target_include_directories(cjson PUBLIC include lib/cjson)

add_executable(wsgup src/main.c)
target_link_libraries(wsgup aesccm cjson)


