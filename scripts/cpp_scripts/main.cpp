#include <iostream>
#include <opencv2/opencv.hpp>

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

    float width = 720.0, height = 720.0;

    for (int i = 0; i < 4; i++)
        src[i] = {(float)contour[i].x, (float)contour[i].y};

    Point2f dst[4] = {{0.0, 0.0}, {width, 0.0}, {0.0, height}, {width, height}};

    matrix = getPerspectiveTransform(src, dst);
    warpPerspective(img, img_res, matrix, Point(720, 720));

    cvtColor(img_res, img_res, COLOR_BGR2GRAY);
}

// void split_boxes(Mat img, Mat boxes[81])
// {
//     resize(img, img, Size(810, 810));
//     int count = 0;

//     for (int i = 0; i < 81; i++)
//     {
//         for (int j = 0; j < 81; j++)
//         {
//             boxes[count] = img(Range(i * 81, (i * 81) + 81), Range(j * 81, (j * 81) + 81));
//             count++;
//         }
//     }

//     // Mat res = img_warped(Range(80,280), Range(150,330));
//     // imshow("cropped", res);
// }

int main()
{
    Mat img = imread("../../assets/20_board.jpg");
    resize(img, img, Size(720, 720));

    Mat img_preprocessed, img_warped;
    float area;
    vector<Point> biggest_cnt;
    // Mat boxes[81];

    preprocess(img, img_preprocessed, false);
    find_biggest_contour(img_preprocessed, area, biggest_cnt);
    reorder_cnt(biggest_cnt);
    warp_perspective(biggest_cnt, img, img_warped);
    // split_boxes(img_warped, boxes);


    imshow("img", img);
    imshow("warped", img_warped);

    // for (Mat box : boxes)
    // {
    //     imshow("box", box);
    //     waitKey(0);
    // }

    waitKey(0);
}