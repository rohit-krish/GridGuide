#pragma once

#include <iostream>
#include <opencv2/imgproc.hpp>

using namespace std;
using namespace cv;

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
