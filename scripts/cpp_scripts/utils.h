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

