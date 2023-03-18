#include <string>
#include <unistd.h>
#include <opencv2/opencv.hpp>
#include "sudoku_detector.h"

using namespace std;
using namespace cv;

Mat global_img;

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
    void extract_boxes(float* cnt, char* output_path) {
        /// Step 01: warp perspective

        // Point2f src[4];
        Point2f* src = new Point2f[4];
        float width = 810.0, height = 810.0;
        Mat matrix;
        Mat img_warped;

        // convert the cnt to cv::Point2f datatype
        for (int i = 0; i < 4; i++)
            src[i] = {cnt[i * 2], cnt[(i * 2) + 1]};
        
        Point2f dst[4] = {{0.0, 0.0}, {width, 0.0}, {0.0, height}, {width, height}};

        matrix = getPerspectiveTransform(src, dst);
        warpPerspective(global_img, img_warped, matrix, Point(width, height));

        cvtColor(img_warped, img_warped, COLOR_BGR2GRAY);

        // chdir(output_path);
        // imwrite("warped.jpg", img_warped);
        // imwrite("global_img.jpg", global_img);

        /// Step 02: split into boxes

        Mat boxes[81];
        int count = 0;

        // make sure that the img_warped in 810x810
        resize(img_warped, img_warped, Size(810, 810));

        for (int i = 0; i < 9; i++)
        {
            for (int j = 0; j < 9; j++)
            {
                boxes[count] = img_warped(Range(i * 90, (i * 90) + 90), Range(j * 90, (j * 90) + 90));
                resize(boxes[count], boxes[count], Size(70, 70));
                count++;
            }
        }

        /// Step 03: save the cropped boxes to the output_path

        // change current working directory to output_path
        chdir(output_path);

        for (int i = 0; i < 81; i++)
            imwrite(to_string(i)+".jpg", boxes[i]);

        /// Step 04: release the dynamically allocated memory
        delete[] src;

    }
}
