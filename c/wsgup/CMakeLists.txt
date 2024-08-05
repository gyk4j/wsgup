cmake_minimum_required(VERSION 3.25.3)

project(wsgup VERSION 0.0.1 LANGUAGES C)

# set(OPENSSL_ROOT_DIR "/usr/lib")
# set(OPENSSL_USE_STATIC_LIBS TRUE)
find_package(OpenSSL REQUIRED)

MESSAGE (STATUS "Found? ${OPENSSL_FOUND}")
MESSAGE (STATUS "Includes: ${OPENSSL_INCLUDE_DIR}")
MESSAGE (STATUS "Crypto library: ${OPENSSL_CRYPTO_LIBRARY}")

set(CPM_DOWNLOAD_VERSION 0.27.2)
set(CPM_DOWNLOAD_LOCATION "${CMAKE_BINARY_DIR}/cmake/CPM_${CPM_DOWNLOAD_VERSION}.cmake")

if(NOT (EXISTS ${CPM_DOWNLOAD_LOCATION}))
    message(STATUS "Downloading CPM.cmake")
    file(DOWNLOAD https://github.com/TheLartians/CPM.cmake/releases/download/v${CPM_DOWNLOAD_VERSION}/CPM.cmake ${CPM_DOWNLOAD_LOCATION})
endif()

include(${CPM_DOWNLOAD_LOCATION})

CPMAddPackage(
    NAME cJSON
    GITHUB_REPOSITORY DaveGamble/cJSON
    VERSION 1.7.18)
    
if(cJSON_ADDED)
    add_library(cJSON STATIC ${cJSON_SOURCE_DIR}/cJSON.c)
    target_include_directories(cJSON INTERFACE ${cJSON_SOURCE_DIR})
endif()

file(GLOB_RECURSE SOURCE_FILES src/*.c)
add_executable(${PROJECT_NAME} ${SOURCE_FILES})
target_include_directories(${PROJECT_NAME} PUBLIC include)
target_link_libraries(${PROJECT_NAME} OpenSSL::Crypto cJSON)
