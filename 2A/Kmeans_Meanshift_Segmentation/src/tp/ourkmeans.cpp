#include "ocv_utils.hpp"

#include <opencv2/core.hpp>
#include <opencv2/imgcodecs.hpp>
#include <opencv2/highgui.hpp>
#include <opencv2/imgproc.hpp>
#include <opencv2/imgcodecs.hpp>
#include <iostream>
#include <string>
#include <stdio.h>
#include <stdlib.h>
#include <cmath>

using namespace cv;
using namespace std;

double distance(Vec3f pix1, Vec3f pix2){
    double res = 0;
    for (int i = 0; i < 3; i++){
        res +=pow(pix1[i] - pix2[i], 2);
    }
    return sqrt(res);
}

double ourKmeans(Mat m,  int k, Mat& labels, int maxIter, Mat& centers) {
    // Var Utiles
    centers = Mat(k, 1, m.type());

    int rows = m.rows;

    double min, max;
    double dist;

    m.convertTo(m, CV_32F);
    labels = Mat(rows, 1, CV_32S);

    //Initialisation centers
    vector<int> centerVector((size_t)k);
    centerVector[0] =  rand() % rows;
    for (int j = 1; j < k; j++) {
        max = -1;
        int maxIdx = 0;

        for (int i = 0; i < rows; i++){
            min = 1e9;
            for (int c = 0; c < j; c++) {
                dist = distance(m.at<Vec3f>(i, 0), m.at<Vec3f>(centerVector[(size_t)c], 0));
                if (dist < min){
                    min = dist;
                }
            }
            if (min > max) {
                max = min;
                maxIdx = i;

            }
        }
        centerVector[(size_t)j] = maxIdx;
    }

    //découpage en k régions
    for (int l = 0; l < maxIter; l++){
        for (int i = 0; i < rows; i++){
            min = 1e9;
            int maxLabel = 0;

            for (int c = 0; c < k; c++){
                dist = distance(m.at<Vec3f>(i, 0), m.at<Vec3f>(centerVector[(size_t)c], 0));
                if (dist < min){
                    min = dist;
                    maxLabel = c;
                }
            }
            labels.at<int>(i) = maxLabel;
        }

        //maj centres
        vector<Vec3f> sommeColor((size_t)k, Vec3f(0, 0 ,0));
        vector<int> counter((size_t)k, 0);

        for (int i = 0; i < rows; i++){
            int label = labels.at<int>(i);
            sommeColor[(size_t)label] += m.at<Vec3f>(i, 0);
            counter[(size_t)label]++;
        }

        for (int c = 0; c < k; c++){
            if (counter[(size_t)c] > 0) {
                m.at<Vec3f>(centerVector[(size_t)c], 0) = sommeColor[(size_t)c] / (float)counter[(size_t)c];
            } else {
                //Cas cluster vide
                int randIdx = rand() % rows;
                m.at<Vec3f>(centerVector[(size_t)c], 0) = m.at<Vec3f>(randIdx, 0);
            }
        }
    }
    double compactness = 0;
    for(int i = 0; i < rows; i++) {
        int label = labels.at<int>(i);
        compactness += distance(m.at<Vec3f>(i), m.at<Vec3f>(centerVector[static_cast<size_t>(label)]));
    }
    return compactness;
}