add_executable(kmeans kmeans.cpp ocv_utils.cpp ocv_utils.hpp)
add_executable(meanshiftComp meanshiftComp.cpp ocv_utils.cpp ocv_utils.hpp)

target_link_libraries(meanshiftComp ${OpenCV_LIBS})
target_link_libraries( kmeans ${OpenCV_LIBS} )

target_compile_options(kmeans PRIVATE ${MY_COMPILE_OPTIONS})
target_compile_options(meanshiftComp PRIVATE ${MY_COMPILE_OPTIONS})

target_compile_definitions(kmeans PUBLIC ${MY_COMPILE_DEFINITIONS})
target_compile_definitions(meanshiftComp PUBLIC ${MY_COMPILE_DEFINITIONS})