#include <opencv2/core.hpp>
#include <opencv2/imgproc.hpp>
#include "sudoku_detector.h"

using namespace std;
using namespace cv;

Mat camera_image;


void rotateMat(Mat &img, int rotation)
{
    if (rotation == 90)
    {
        transpose(img, img);
        flip(img, img, 1);
    }
    else if (rotation == 270)
    {
        transpose(img, img);
        flip(img, img, 0);
    }
    else if (rotation == 180)
    {
        flip(img, img, -1);
    }
}

extern "C"
{
    // Attributes to prevent 'unused' function from being removed and to make it visible
    __attribute__((visibility("default"))) __attribute__((used))
    const float * detect_board(uint8_t *bytes, int width, int height, int rotation, int32_t *outCount)
    {
        Mat img(height + height / 2, width, CV_8UC1, bytes);
        cvtColor(img, img, COLOR_YUV2BGRA_NV21);
        rotateMat(img, rotation);
        img.copyTo(camera_image);

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
    const int * get_boxes(int32_t *cnt) {
        // the receiving cnt is an array of 8 int values
        // creating a vector<Point> from the receiving array
        vector<Point> contour(4);

        for (int i=0; i<4; i++) {
            int x = cnt[2 * i];
            int y = cnt[2 * i + 1];
            Point p(x,y);
            contour[i] = p;
        }

        Mat image_warped;
        Mat boxes[81];
        int boxes_arr[4900 * 81]; // 396900

        warp_perspective(contour, camera_image, image_warped);
        split_boxes(image_warped, boxes);

        // converting each box of Mat to a array of int
        int count = 0;
        int length = 4900; // box.rows * box.cols;
        int *boxArray = new int[length];
        for (Mat box : boxes)
        {
            mat_to_array(box, boxArray, length);

            for (int i = 0; i < length; i++)
            {
                boxes_arr[count] = boxArray[i];
                count++;
            }
        }

        const int total_length = 4900 * 81;
        unsigned int total_byte_count = sizeof(int) * total_length;
        int *res = (int *)malloc(total_byte_count);
        memcpy(res, boxes_arr, total_byte_count);

        return res;
    }
}