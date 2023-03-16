#include <iostream>
#include <opencv2/opencv.hpp>
#include <opencv2/core.hpp>

#include "utils.h"
// #include "solver.h"

using namespace std;
using namespace cv;

void preprocess(Mat &src_img, Mat &dst_img, bool show)
{
    cvtColor(src_img, dst_img, COLOR_BGR2GRAY);
    GaussianBlur(dst_img, dst_img, Size(3, 3), 1);
    adaptiveThreshold(dst_img, dst_img, 255, ADAPTIVE_THRESH_GAUSSIAN_C, 1, 11, 2);

    if (show)
        imshow("procesed", dst_img);
}

void find_biggest_contour(Mat &src_img, float &max_area, vector<Point> &biggest_cnt)
{
    vector<vector<Point>> contours;
    vector<Vec4i> hierarchy;
    float area, peri;
    vector<Point> approx;

    max_area = 0.0;

    // find all countoures
    findContours(src_img, contours, hierarchy, RETR_EXTERNAL, CHAIN_APPROX_SIMPLE);

    for (int i = 0; i < contours.size(); i++)
    {
        area = contourArea(contours[i]);

        if (area > 50)
        {
            peri = arcLength(contours[i], true);
            approxPolyDP(contours[i], approx, 0.02 * peri, true);

            if ((area > max_area) && ((int)approx.size() == 4))
            {
                biggest_cnt = approx;
                max_area = area;
            }
        }
    }
}

void reorder_cnt(vector<Point> &contour)
{
    vector<Point> contour_tmp = contour;

    int n = contour.size();
    float sum_points[n], diff_points[n];

    for (int i = 0; i < n; i++)
    {
        sum_points[i] = contour[i].y + contour[i].x;
        diff_points[i] = contour[i].y - contour[i].x;
    }

    contour[0] = contour_tmp[argmin(sum_points)];
    contour[3] = contour_tmp[argmax(sum_points)];
    contour[1] = contour_tmp[argmin(diff_points)];
    contour[2] = contour_tmp[argmax(diff_points)];
}

void warp_perspective(vector<Point> contour, Mat img, Mat &img_res)
{
    Mat matrix;
    Point2f src[4];

    float width = 810.0, height = 810.0;

    for (int i = 0; i < 4; i++)
        src[i] = {(float)contour[i].x, (float)contour[i].y};

    Point2f dst[4] = {{0.0, 0.0}, {width, 0.0}, {0.0, height}, {width, height}};

    matrix = getPerspectiveTransform(src, dst);
    warpPerspective(img, img_res, matrix, Point(810, 810));

    cvtColor(img_res, img_res, COLOR_BGR2GRAY);
}

void split_boxes(Mat img, Mat boxes[81])
{
    resize(img, img, Size(810, 810));
    int count = 0;

    for (int i = 0; i < 9; i++)
    {
        for (int j = 0; j < 9; j++)
        {
            boxes[count] = img(Range(i * 90, (i * 90) + 90), Range(j * 90, (j * 90) + 90));
            // model trained in 70x70 image it's not nessesory to resize becuase we are doing it inside the model though i'm doing it
            resize(boxes[count], boxes[count], Size(70, 70));
            count++;
        }
    }
}

void mat_to_array(Mat img, int *boxArray, int length)
{
    // Get a pointer to the first pixel in the image
    uchar *pixelPtr = img.ptr<uchar>(0);

    for (int i = 0; i < length; i++)
        boxArray[i] = (int)pixelPtr[i];
}

int main()
{
    Mat img = imread("../../assets/1.jpg");
    // resize(img, img, Size(0,0), .2, .2);
    // resize(img, img, Size(720, 720));

    Mat img_preprocessed, img_warped;
    float area;
    vector<Point> biggest_cnt;
    Mat boxes[81];
    int boxes_arr[4900 * 81]; // 396900

    preprocess(img, img_preprocessed, false);
    find_biggest_contour(img_preprocessed, area, biggest_cnt);
    reorder_cnt(biggest_cnt);
    warp_perspective(biggest_cnt, img, img_warped);
    split_boxes(img_warped, boxes);

    // imshow("img", img_preprocessed);
    // imshow("warped", img_warped);

    int count = 0;
    const int length = 4900; // box.rows * box.cols;
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

    const int size = 4900 * 81;

    unsigned int total = sizeof(int) * size;
    int *res = (int *)malloc(total);
    memcpy(res, boxes_arr, total);

    for (int i = 0; i < size; i++)
        cout << res[i] << ' ';

    // // Print each element of the array to the console
    // for (int i = 0; i < boxes[0].rows; i++)
    // {
    //     for (int j = 0; j < boxes[0].cols; j++)
    //     {
    //         int index = i * boxes[0].cols + j;
    //         std::cout << boxArray[index] << " ";
    //         // cout << index << ' ';
    //     }
    //     std::cout << std::endl;
    // }

    // for (Mat box : boxes)
    // {
    //     imshow("box", box);
    //     waitKey(0);
    // }

    // waitKey(0);
}
