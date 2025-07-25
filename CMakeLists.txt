cmake_minimum_required(VERSION 2.8)
project(orb_slam3_ros)

IF(NOT CMAKE_BUILD_TYPE)
  SET(CMAKE_BUILD_TYPE Release)
ENDIF()

MESSAGE("Build type: " ${CMAKE_BUILD_TYPE})

set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS}  -Wall   -O3")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wall   -O3")
set(CMAKE_C_FLAGS_RELEASE "${CMAKE_C_FLAGS_RELEASE} -march=native")
set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} -march=native")

# Check C++14 or C++0x support
include(CheckCXXCompilerFlag)
CHECK_CXX_COMPILER_FLAG("-std=c++14" COMPILER_SUPPORTS_CXX14)
CHECK_CXX_COMPILER_FLAG("-std=c++0x" COMPILER_SUPPORTS_CXX0X)
if(COMPILER_SUPPORTS_CXX14)
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++14")
  add_definitions(-DCOMPILEDWITHC11)
  message(STATUS "Using flag -std=c++14.")
elseif(COMPILER_SUPPORTS_CXX0X)
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++0x")
  add_definitions(-DCOMPILEDWITHC0X)
  message(STATUS "Using flag -std=c++0x.")
else()
  message(FATAL_ERROR "The compiler ${CMAKE_CXX_COMPILER} has no C++14 support. Please use a different C++ compiler.")
endif()

LIST(APPEND CMAKE_MODULE_PATH ${PROJECT_SOURCE_DIR}/cmake_modules)

find_package(OpenCV 4.2)
if(NOT OpenCV_FOUND)
  message(FATAL_ERROR "OpenCV 4.2 not found.")
endif()

MESSAGE("OPENCV VERSION:")
MESSAGE(${OpenCV_VERSION})

## Find catkin macros and libraries
## if COMPONENTS list like find_package(catkin REQUIRED COMPONENTS xyz)
## is used, also find other catkin packages
find_package(catkin REQUIRED COMPONENTS
  cv_bridge
  image_transport
  geometry_msgs
  sensor_msgs
  nav_msgs
  std_msgs
  message_filters
  roscpp
  rospy
  tf
  tf2
  visualization_msgs
  message_generation
)

find_package(Eigen3 3.1.0 REQUIRED)
find_package(Pangolin REQUIRED)

add_service_files(
  FILES
  SaveMap.srv
)

generate_messages(
  DEPENDENCIES
  std_msgs
)

catkin_package (
  CATKIN_DEPENDS roscpp rospy std_msgs cv_bridge image_transport tf sensor_msgs dynamic_reconfigure message_runtime
  LIBRARIES {PROJECT_NAME} libDBoW2 libg2o
)

find_package(PkgConfig REQUIRED)
pkg_check_modules(ORB_SLAM3 REQUIRED ORB_SLAM3)

execute_process(
  COMMAND ${PKG_CONFIG_EXECUTABLE} --variable=prefix ORB_SLAM3
  OUTPUT_VARIABLE ORB_SLAM3_PREFIX
  OUTPUT_STRIP_TRAILING_WHITESPACE
)
set(ORB_SLAM3_VOCAB_PATH "${ORB_SLAM3_PREFIX}/share/orb_slam3/Vocabulary/ORBvoc.txt.bin")
message(STATUS "ORB_SLAM3_VOCAB_PATH: ${ORB_SLAM3_VOCAB_PATH}")

include_directories(
  ${PROJECT_SOURCE_DIR}
  ${PROJECT_SOURCE_DIR}/include
  ${catkin_INCLUDE_DIRS}
  ${OpenCV_INCLUDE_DIRS}
  ${EIGEN3_INCLUDE_DIR}
  ${Pangolin_INCLUDE_DIRS}
  ${ORB_SLAM3_INCLUDE_DIRS}
)

link_directories(${ORB_SLAM3_LIBRARY_DIRS})

## ROS node
add_executable(ros_mono
  src/ros_mono.cc
  src/common.cc
)
target_link_libraries(ros_mono
  ${catkin_LIBRARIES}
  pangolin
  ${ORB_SLAM3_LIBRARIES}
)

## ROS node
add_executable(ros_mono_inertial 
  src/ros_mono_inertial.cc
  src/common.cc
)
target_link_libraries(ros_mono_inertial 
  ${catkin_LIBRARIES}
  pangolin
  ${ORB_SLAM3_LIBRARIES}
)

## ROS node
add_executable(ros_stereo 
  src/ros_stereo.cc
  src/common.cc
)
target_link_libraries(ros_stereo
  ${catkin_LIBRARIES}
  pangolin
  ${ORB_SLAM3_LIBRARIES}
)

## ROS node
add_executable(ros_stereo_inertial
  src/ros_stereo_inertial.cc
  src/common.cc
)
target_link_libraries(ros_stereo_inertial 
  ${catkin_LIBRARIES}
  pangolin
  ${ORB_SLAM3_LIBRARIES}
)

## ROS node
add_executable(ros_rgbd
  src/ros_rgbd.cc
  src/common.cc
)
target_link_libraries(ros_rgbd
  ${catkin_LIBRARIES}
  pangolin
  ${ORB_SLAM3_LIBRARIES}
)

## ROS node
add_executable(ros_rgbd_inertial
  src/ros_rgbd_inertial.cc
  src/common.cc
)
target_link_libraries(ros_rgbd_inertial
  ${catkin_LIBRARIES}
  pangolin
  ${ORB_SLAM3_LIBRARIES}
)

add_dependencies(ros_mono ${catkin_EXPORTED_TARGETS})
add_dependencies(ros_mono_inertial  ${catkin_EXPORTED_TARGETS})
add_dependencies(ros_stereo  ${catkin_EXPORTED_TARGETS})
add_dependencies(ros_stereo_inertial ${catkin_EXPORTED_TARGETS})
add_dependencies(ros_rgbd ${catkin_EXPORTED_TARGETS})
add_dependencies(ros_rgbd_inertial ${catkin_EXPORTED_TARGETS})

install(TARGETS ros_mono
  RUNTIME DESTINATION ${CATKIN_PACKAGE_BIN_DESTINATION}
)
install(TARGETS ros_mono_inertial 
  RUNTIME DESTINATION ${CATKIN_PACKAGE_BIN_DESTINATION}
)
install(TARGETS ros_stereo 
  RUNTIME DESTINATION ${CATKIN_PACKAGE_BIN_DESTINATION}
)
install(TARGETS ros_stereo_inertial
  RUNTIME DESTINATION ${CATKIN_PACKAGE_BIN_DESTINATION}
)
install(TARGETS ros_rgbd
  RUNTIME DESTINATION ${CATKIN_PACKAGE_BIN_DESTINATION}
)
install(TARGETS ros_rgbd_inertial
  RUNTIME DESTINATION ${CATKIN_PACKAGE_BIN_DESTINATION}
)

install(DIRECTORY launch/
  DESTINATION ${CATKIN_PACKAGE_SHARE_DESTINATION}/launch
  PATTERN "*.launch"
  PATTERN ".git" EXCLUDE
)

install(DIRECTORY config/
  DESTINATION ${CATKIN_PACKAGE_SHARE_DESTINATION}/config
)

install(CODE "
  file(MAKE_DIRECTORY \"\${CMAKE_INSTALL_PREFIX}/share/orb_slam3/Vocabulary\")
  execute_process(COMMAND ${CMAKE_COMMAND} -E create_symlink
    \"${ORB_SLAM3_VOCAB_PATH}\"
    \"\${CMAKE_INSTALL_PREFIX}/share/orb_slam3/Vocabulary/ORBvoc.txt.bin\")
  message(STATUS \"Created symlink to ORBvoc.txt.bin from ORB_SLAM3 package.\")
")

