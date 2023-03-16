#pragma once

#include <iostream>
#include <opencv2/imgproc.hpp>

using namespace std;
using namespace cv;


void preprocess(Mat &src_img, Mat &dst_img)
{
    cvtColor(src_img, dst_img, COLOR_BGR2GRAY);
    GaussianBlur(dst_img, dst_img, Size(3, 3), 1);
    adaptiveThreshold(dst_img, dst_img, 255, ADAPTIVE_THRESH_GAUSSIAN_C, 1, 11, 2);
}

void find_biggest_contour(Mat &src_img, float &max_area, vector<Point> &biggest_cnt)
{
    vector<vector<Point>> contours;
    vector<Vec4i> hierarchy;
    float area, peri;
    vector<Point> approx;

    max_area = 0.0;

    // find all contours
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
            // model trained in 70x70 image it's not necessary to resize because we are doing it inside the model though i'm doing it
            resize(boxes[count], boxes[count], Size(70, 70));
            count++;
        }
    }
}

void mat_to_array(Mat img, int *res_array, int length)
{
    // Get a pointer to the first pixel in the image
    uchar *pixelPtr = img.ptr<uchar>(0);

    for (int i = 0; i < length; i++)
        res_array[i] = (int)pixelPtr[i];
}
