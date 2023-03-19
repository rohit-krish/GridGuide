#include <string>
#include <unistd.h>
#include <opencv2/opencv.hpp>
#include "sudoku_detector.h"

using namespace std;
using namespace cv;

Mat global_img;
vector<Point> global_biggest_cnt;

extern "C"
{
    // Attributes to prevent 'unused' function from being removed and to make it visible
    __attribute__((visibility("default"))) __attribute__((used))
    const float * detect_board(uint8_t *bytes, int width, int height, int rotation, int32_t *outCount)
    {
        Mat img(height + height / 2, width, CV_8UC1, bytes);
        cvtColor(img, img, COLOR_YUV2BGRA_NV21);
        rotateMat(img, rotation);

        // copy the img to global_img
        img.copyTo(global_img);

        Mat img_preprocessed;
        float area;
        vector<Point> biggest_cnt;

        preprocess(img, img_preprocessed);
        find_biggest_contour(img_preprocessed, area, biggest_cnt);
        reorder_contour(biggest_cnt);

        // copy the biggest_cnt to global_biggest_cnt
        global_biggest_cnt.clear();
        copy(biggest_cnt.begin(), biggest_cnt.end(), back_inserter(global_biggest_cnt));

        vector<float> output;

        for (int i = 0; i < biggest_cnt.size(); i++)
        {
            output.push_back((float)biggest_cnt[i].x);
            output.push_back((float)biggest_cnt[i].y);
        }

        /*
         as the `output` variable will get destroyed after the execution of the function
         we have to store the `output` to another memory location which is not in the scope of the function
         so that the data can be still accessed through that new memory location
        */

        unsigned int total = sizeof(float) * output.size();
        float *res = (float *)malloc(total);
        memcpy(res, output.data(), total);

        *outCount = output.size();
        return res;
    }

    __attribute__((visibility("default"))) __attribute__((used))
    void extract_boxes(char* output_path) {
        /// Step 01: warp perspective
        Mat img_warped;
        warp_perspective(global_biggest_cnt, global_img, img_warped);

        // for (Point cnt : global_biggest_cnt)
            // circle(global_img, cnt, 5, Scalar(0, 255, 0), -1);

        /// Step 02: split into boxes
        Mat boxes[81];
        split_boxes(img_warped, boxes);

        /// Step 03: save the cropped boxes to the output_path

        // change current working directory to output_path
        chdir(output_path);
        // imwrite("warped.jpg", img_warped);
        // imwrite("global_img.jpg", global_img);

        for (int i = 0; i < 81; i++)
            imwrite(to_string(i)+".jpg", boxes[i]);

    }
}
