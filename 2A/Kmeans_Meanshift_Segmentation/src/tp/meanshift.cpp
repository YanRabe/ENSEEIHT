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

double distanceColor(Vec3f pix1, Vec3f pix2){
    double res = 0;
    for (int i = 0; i<3; i++){
        res += pow(pix1[i] - pix2[i], 2);
    }
    res = sqrt(res) / 3;
    return res;
}

int meanshift(Mat m, int hc, int hs, Mat& labels, float epsilon, int maxIter){
    int rows = m.rows;
    int cols = m.cols;
    double max = epsilon + 1;

    m.convertTo(m, CV_32FC3);

    for (int k = 1; k<= maxIter && max > epsilon; k++){
        Mat prevM = m.clone();
        for (int i = hs; i < rows - hs; i++){
            for(int j = hs; j < cols - hs; j++){
                Vec3f centerColor = prevM.at<Vec3f>(i, j);
                Vec3f rgbSum(0, 0, 0);
                int count = 0;
                for (int di = -hs; di <= hs; di++){
                    for (int dj = -hs; dj <= hs; dj++){
                        Vec3f rgbVoisin = prevM.at<Vec3f>(i + di, j + dj);
                        if (distanceColor(centerColor, rgbVoisin) <= hc){
                            rgbSum += rgbVoisin;
                            count++;
                        }
                    }
                }
                if (count > 0){
                    m.at<Vec3f>(i, j) = rgbSum / count;
                }
            }
        }
        max = 0;
        for (int i = hs; i < rows - hs; i++){
            for (int j = hs; j < cols - hs; j++){
                double dist = distanceColor(m.at<Vec3f>(i, j), prevM.at<Vec3f>(i, j));
                if (dist > max){
                    max = dist;
                }
            }
        }
    }
    // Labelisation
    m = m.reshape(3, rows * cols).clone(); //Clone m pour avoir une liste de pixels BGR
    labels = Mat(rows * cols, 1, CV_32S, Scalar(-1)); //On init tous les labels à -1 dans un vect col pour l'instant
    int label = 0;

    for (int i = 0; i < rows * cols; i++){
        if (labels.at<int>(i) != -1) { //label déjà assigné en gros
            continue;
        }

        labels.at<int>(i) = label;
        Vec3f refColor = m.at<Vec3f>(i); //la couleur de référence pour ce label/cluster
        for (int j = i + 1; j < rows * cols; j++){
            if (labels.at<int>(j) != -1){ 
                continue;
            }
            if (distanceColor(refColor, m.at<Vec3f>(j)) <= hc){ //Compare la diff de couleurs avec le seuil de tolérance
                labels.at<int>(j) = label;
            }
        }
        label++;
    }
    return label; //Pour debug
}