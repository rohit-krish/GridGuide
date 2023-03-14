#include <opencv2/core.hpp>
// #include <opencv2/imgproc.hpp>
#include "sudoku_detector.h"

using namespace std;
using namespace cv;

void rotateMat(Mat &image, int rotation)
{
    if (rotation == 90)
    {
        transpose(image, image);
        flip(image, image, 1);
    }
    else if (rotation == 270)
    {
        transpose(image, image);
        flip(image, image, 0);
    }
    else if (rotation == 180)
    {
        flip(image, image, -1);
    }
}

extern "C"
{
    // Attributes to prevent 'unused' function from being removed and to make it visible
    __attribute__((visibility("default"))) __attribute__((used))
    const float * detect(uint8_t *bytes, int width, int height, int rotation, int32_t *outCount)
    {
        Mat image(height + height / 2, width, CV_8UC1, bytes);
        cvtColor(image, image, COLOR_YUV2BGRA_NV21);

        rotateMat(image, rotation);

        /// don't need to resize now, it only needed when we have to crop the boxes
        /// resize(image, image, Size(720, 720));

        Mat img_preprocessed;
        float area;
        vector<Point> biggest_cnt;

        preprocess(image, img_preprocessed);
        find_biggest_contour(img_preprocessed, area, biggest_cnt);

        vector<float> output;

        for (int i = 0; i < biggest_cnt.size(); i++)
        {
            output.push_back((float)biggest_cnt[i].x);
            output.push_back((float)biggest_cnt[i].y);
        }

        /*
         as the `output` variable will get destroyed after the execution of the function
         we have to store the `output` to another memory location so that the data
         can be still accessed through that new memory location
        */

        unsigned int total = sizeof(float) * output.size();
        float *res = (float *)malloc(total);
        memcpy(res, output.data(), total);

        *outCount = output.size();
        return res;
    }
}
