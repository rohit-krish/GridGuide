int argmin(float pnt[4])
{
    int min_val = pnt[0];
    int min_arg;

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

int argmax(float pnt[4])
{
    int max_val = pnt[0];
    int max_arg;

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

// void read_and_process_cam()
// {
//     VideoCapture cap(1);
//     if (!cap.isOpened())
//     {
//         cout << "Error opening video stream or file" << endl;
//         return;
//     }
//     Mat frame;
//     Mat img_preprocessed, img_warped;
//     float area;
//     vector<Point> biggest_cnt;

//     while (1)
//     {
//         cap.read(frame);
//         if (frame.empty())
//             break;

//         preprocess(frame, img_preprocessed, false);
//         find_biggest_contour(img_preprocessed, area, biggest_cnt);
//         reorder_cnt(biggest_cnt);
//         warp_perspective(biggest_cnt, frame, img_warped);

//         imshow("preprocessed", img_preprocessed);
//         imshow("warped", img_warped);
//         if (waitKey(1) == 27)
//             break;
//     }
//     cap.release();
//     destroyAllWindows();
// }
