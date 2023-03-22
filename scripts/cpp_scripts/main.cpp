#include <string>
#include <unistd.h>
// #include <iostream>
#include <opencv2/opencv.hpp>
// #include <opencv2/core.hpp>

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
            resize(boxes[count], boxes[count], Size(70, 70));
            count++;
        }
    }
}

Mat display_numbers(int *numbers, int *unvalid_flags, int width, int height)
{
    // height = (int)height*.5;
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
                if (unvalid_flags[(y * 9) + x] == 1)
                    color = Scalar(0, 0, 255);

                int point_x = (x * w) + (int)((w / 2) * .8);
                int point_y = (y * h) + (int)((h / 2) * 1.2);
                putText(img, to_string(numbers[(y * 9) + x]), Point(point_x, point_y), FONT_HERSHEY_SIMPLEX, 2, color, 2);
            }
        }
    }
    return img;
}

void myAddWeighted(cv::InputArray src1, double alpha, cv::InputArray src2, double beta, double gamma, cv::OutputArray dst)
{
    CV_Assert(src1.depth() == src2.depth() && src1.depth() == dst.depth());
    CV_Assert(src1.size() == src2.size() && src1.size() == dst.size());

    cv::Mat src1Mat = src1.getMat();
    cv::Mat src2Mat = src2.getMat();
    cv::Mat dstMat = dst.getMat();

    int depth = src1Mat.depth();
    int nChannels = src1Mat.channels();

    if (depth == CV_8U)
    {
        for (int i = 0; i < dstMat.rows; i++)
        {
            uchar* pSrc1 = src1Mat.ptr<uchar>(i);
            uchar* pSrc2 = src2Mat.ptr<uchar>(i);
            uchar* pDst = dstMat.ptr<uchar>(i);

            for (int j = 0; j < dstMat.cols; j++)
            {
                for (int c = 0; c < nChannels; c++)
                {
                    pDst[nChannels * j + c] = cv::saturate_cast<uchar>(alpha * pSrc1[nChannels * j + c] + beta * pSrc2[nChannels * j + c] + gamma);
                }
            }
        }
    }
    else if (depth == CV_32F)
    {
        for (int i = 0; i < dstMat.rows; i++)
        {
            float* pSrc1 = src1Mat.ptr<float>(i);
            float* pSrc2 = src2Mat.ptr<float>(i);
            float* pDst = dstMat.ptr<float>(i);

            for (int j = 0; j < dstMat.cols; j++)
            {
                for (int c = 0; c < nChannels; c++)
                {
                    pDst[nChannels * j + c] = cv::saturate_cast<float>(alpha * pSrc1[nChannels * j + c] + beta * pSrc2[nChannels * j + c] + gamma);
                }
            }
        }
    }
    else
    {
        CV_Error(cv::Error::StsUnsupportedFormat, "unsupported depth");
    }
}

int main()
{
    Mat img = imread("/home/rohit/Desktop/MLProjects/GridGuid/assets/19_board.jpg");
    // Mat img = imread("/home/rohit/Desktop/MLProjects/GridGuid/scripts/cpp_scripts/flutter_1.png");
    resize(img, img, Size(720, 720));

    Mat img_preprocessed, img_warped;
    float area;
    vector<Point> biggest_cnt;
    Mat boxes[81];

    preprocess(img, img_preprocessed, false);
    find_biggest_contour(img_preprocessed, area, biggest_cnt);

    copy(biggest_cnt.begin(), biggest_cnt.end(), back_inserter(biggest_cnt));

    reorder_cnt(biggest_cnt);

    warp_perspective(biggest_cnt, img, img_warped);
    // split_boxes(img_warped, boxes);

    imshow("img", img);
    imshow("warped", img_warped);

    // pretend the below is the predicted numbers
    int solved_numbers[] = {1, 2, 3, 4, 5, 6, 7, 8, 9, 1, 0, 3, 0, 5, 6, 7, 8, 9, 1, 2, 0, 4, 5, 6, 7, 8, 9, 1, 2, 0, 4, 5, 6, 7, 0, 0, 0, 0, 3, 4, 5, 6, 7, 8, 9, 1, 2, 3, 4, 5, 6, 0, 0, 0, 1, 2, 3, 4, 5, 6, 0, 0, 0, 1, 2, 0, 0, 4, 5, 6, 7, 8, 9, 1, 2, 3, 4, 5, 0, 7, 8, 9};
    int unvalid_flags[] =  {1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0};
    // what is the length of the avoe array
    Mat img_solved_numbers = display_numbers(solved_numbers, unvalid_flags, img.cols, img.rows);

    Point2f pts1[4] = {{0.0, 0.0}, {(float)img.cols, 0.0}, {0.0, (float)img.rows}, {(float)img.cols, (float)img.rows}};
    Point2f pts2[4];
    for (int i = 0; i < 4; i++)
        pts2[i] = {(float)biggest_cnt[i].x, (float)biggest_cnt[i].y};

    Mat matrix = getPerspectiveTransform(pts1, pts2);
    Mat img_inv_warp;
    img.copyTo(img_inv_warp);
    warpPerspective(img_solved_numbers, img_inv_warp, matrix, Size(img.cols, img.rows));

    Mat inv_perspective;
    img.copyTo(inv_perspective);
    addWeighted(img_inv_warp, 1, img, 0.7, 1, inv_perspective);
    // myAddWeighted(img_inv_warp, 1, img, 0.7, 1, inv_perspective);

    imshow("img_solved_numbers", img_solved_numbers);
    imshow("img_inv_warp", img_inv_warp);
    imshow("inv_perspective", inv_perspective);

    // char *input_folder = "../boxes";
    // chdir(input_folder);

    // for (int i = 0; i < 81; i++)
    // {
    //     imwrite(to_string(i)+".jpg", boxes[i]);
    //     cout << to_string(i)+".jpg\n";
    // }

    // for (Mat box : boxes)
    // {
    //     imshow("box", box);
    //     if (waitKey(0) == 27)
    //         break;
    // }

    waitKey(0);
    return 0;
}