cmake_minimum_required(VERSION 3.10.2)
project(grid_guid VERSION 1.0.0)

# opencv
set(OpenCV_STATIC ON)
set(OpenCV_DIR /home/rohit/OpenCV/Android/OpenCV-android-sdk/sdk/native/jni)
find_package(OpenCV REQUIRED)

add_library(
        # sets the anme of the library
        native_opencv
        SHARED
        # ../ios/Classes/sudoku_detector/sudoku_detector.cpp
        ../ios/Classes/native_opencv.cpp
)

target_include_directories(
        native_opencv PRIVATE
        ../ios/Classes/sudoku_detector
)

find_library(log-lig log)

target_link_libraries(
        # specify the target library.
        native_opencv
        ${OpenCV_LIBS}
        ${log-lib}
)