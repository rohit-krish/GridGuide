#pragma once

#include <iostream>
#include <opencv2/opencv.hpp>
#include <string>

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

void find_biggest_contour(const Mat src_img, float &max_area, vector<Point> &biggest_cnt)
{
    vector<vector<Point>> contours;
    vector<Vec4i> hierarchy;
    float area = 0.0, peri = 0.0;
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
    Point2f *src = new Point2f[4];
    // Point2f src[4];
    float width = 810.0, height = 810.0;

    for (int i = 0; i < 4; i++)
        src[i] = {(float)contour[i].x, (float)contour[i].y};

    Point2f dst[4] = {{0.0, 0.0}, {width, 0.0}, {0.0, height}, {width, height}};

    matrix = getPerspectiveTransform(src, dst);

    warpPerspective(img, img_res, matrix, Point(width, height));

    cvtColor(img_res, img_res, COLOR_BGR2GRAY);

    delete[] src;
}

int argmin(const float pnt[4])
{
    int min_val = pnt[0];
    int min_arg = 0;

    for (int i = 0; i < 4; i++)
    {
        if (pnt[i] < min_val)
        {
            min_val = pnt[i];
            min_arg = i;
        }
    }
    return min_arg;
}

int argmax(const float pnt[4])
{
    int max_val = pnt[0];
    int max_arg = 0;

    for (int i = 0; i < 4; i++)
    {
        if (pnt[i] > max_val)
        {
            max_val = pnt[i];
            max_arg = i;
        }
    }
    return max_arg;
}

void reorder_contour(vector<Point> &contour)
{
    if (contour.size() != 4)
        return;

    vector<Point> contour_tmp = contour;

    float *sum_points = new float[4];
    float *diff_points = new float[4];

    for (int i = 0; i < 4; i++)
    {
        sum_points[i] = contour[i].y + contour[i].x;
        diff_points[i] = contour[i].y - contour[i].x;
    }

    contour[0] = contour_tmp[argmin(sum_points)];
    contour[3] = contour_tmp[argmax(sum_points)];
    contour[1] = contour_tmp[argmin(diff_points)];
    contour[2] = contour_tmp[argmax(diff_points)];

    delete[] sum_points;
    delete[] diff_points;
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
            resize(boxes[count], boxes[count], Size(70, 70));
            count++;
        }
    }
}

Mat display_numbers(int *numbers, int *unvalid_flag, int width, int height)
{
    Mat img(height, width, CV_8UC3, Scalar(0, 0, 0));
    int h = height / 9;
    int w = width / 9;

    for (int x = 0; x < 9; x++)
    {
        for (int y = 0; y < 9; y++)
        {
            if (numbers[(y * 9) + x] != 0)
            {
                Scalar color(0, 255, 0);

                if (unvalid_flag[(y * 9) + x] == 1)
                    color = Scalar(0, 0, 255);

                int point_x = (x * w) + (int)((w / 2) * .8);
                int point_y = (y * h) + (int)((h / 2) * 1.2);
                putText(img, to_string(numbers[(y * 9) + x]), Point(point_x, point_y), FONT_HERSHEY_SIMPLEX, 2, color, 2);
            }
        }
    }
    return img;
}
