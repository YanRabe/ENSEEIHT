#include "ocv_utils.hpp"
#include "meanshift.cpp"
#include "ourkmeans.cpp"
#include <opencv2/core.hpp>
#include <opencv2/imgcodecs.hpp>
#include <opencv2/highgui.hpp>
#include <opencv2/imgproc.hpp>
#include <iostream>
#include <string>

using namespace cv;
using namespace std;

int main(int argc, char** argv)
{
    const std::string keys =
        "{help h usage ?   |       | print this message         }"
        "{input i          |<none> | input image file           }"
        "{k                |<none> | number of clusters         }"
        "{groundtruth gt   |       | ground truth segmentation  }"
        "{hs               |5      | seuil spatial              }"
        "{hc               |10     | seuil colorimétrique       }"
        "{epsilon e        |1.0    | seuil d'arrêt              }"
        "{maxiter m        |3      | max iterations             }"
        "{output o         |       | output image file          }";

    CommandLineParser parser(argc, argv, keys);
    parser.about("Segmentation comparison application");

    if (parser.has("help")) {
        parser.printMessage();
        return EXIT_SUCCESS;
    }

    const string imageFilename = parser.get<string>("input");
    const int k = parser.get<int>("k");
    const string groundTruthFilename = parser.get<string>("groundtruth");
    const int hs = parser.get<int>("hs");
    const int hc = parser.get<int>("hc");
    const float epsilon = parser.get<float>("epsilon");
    const int maxIter = parser.get<int>("maxiter");
    string outputFilename = parser.get<string>("output");

    if (!parser.check()) {
        parser.printErrors();
        return EXIT_FAILURE;
    }

    cout << "Program called with the following arguments:" << endl;
    cout << "\timage file: " << imageFilename << endl;
    cout << "\tk: " << k << endl;
    if (!groundTruthFilename.empty()) cout << "\tground truth segmentation: " << groundTruthFilename << endl;
    if (outputFilename.empty()) outputFilename = "../data/images/default_output.png";
    cout << "\toutput image file: " << outputFilename + "\n" << endl;

    // load the color image to process from file
    Mat m, gt, output_img;
    m = imread(imageFilename, IMREAD_COLOR);
    if (!groundTruthFilename.empty()) {
        gt = imread(groundTruthFilename, IMREAD_COLOR);
    }

    // for debugging use the macro PRINT_MAT_INFO to print the info about the matrix, like size and type
    PRINT_MAT_INFO(m);
    PRINT_MAT_INFO(gt);
    cout << "\n" << endl;


    // 1) to call mean-shift we need to first convert the image into floats (CV_32F)
    // see the method Mat.convertTo()
    m.convertTo(m, CV_32F);
    if(!groundTruthFilename.empty()) {
        gt.convertTo(gt, CV_32F);
    }

    int rows = m.rows;
    int cols = m.cols;

    Mat labels;
    Mat centers;

    double nbLabel = meanshift(m, hc, hs, labels, epsilon, maxIter);

    output_img = Mat(rows, cols, CV_8UC3);

    int TP = 0, FP = 0, FN = 0, TN = 0;
    float P = 0.0f, S = 0.0f, DSC = 0.0f;

    for (int i = 0; i < rows * cols; i++) {
        //Indice du cluster
        int clusterIndex = labels.at<int>(i);
        int row = i / cols;
        int col = i % cols;

        //On définit la matrice de l'image de sortie
        output_img.at<Vec3b>(row, col) = Vec3b(
            static_cast<uchar>((1 - min(clusterIndex, 1)) * 255),
            static_cast<uchar>((1 - min(clusterIndex, 1)) * 255),
            static_cast<uchar>((1 - min(clusterIndex, 1)) * 255)
        );

        if(!gt.empty()) {
            float gt_pixel = gt.at<Vec3f>(row, col)[0];
            float output_pixel = (float)output_img.at<Vec3b>(row, col)[0];
            
            bool gt_forme = (gt_pixel > 0);
            bool output_forme = (output_pixel > 0);

            if (gt_forme && output_forme) {
                TP++; // L'objet est là et on l'a trouvé
            } else if (!gt_forme && !output_forme) {
                TN++; // C'est du fond et on a dit que c'était du fond
            } else if (!gt_forme && output_forme) {
                FP++; // C'est du fond mais on a détecté un objet
            } else if (gt_forme && !output_forme) {
                FN++; // L'objet est là mais on l'a raté
            }
        }
    }

    if (!gt.empty()) {
        if (TP + FP > 0) P = (float)TP / ((float)TP + (float)FP);
        if (TP + FN > 0) S = (float)TP / ((float)TP + (float)FN);
        if (2 * TP + FP + FN > 0) DSC = 2.0f * (float)TP / (2 * (float)TP + (float)FP + (float)FN);
    }

    cout << "nombre de Labels: " << nbLabel << endl;
    if(!gt.empty()) {
        cout << "Précision: " << P << endl;
        cout << "Sensibilité: " << S << endl;
        cout << "DSC: " << DSC << endl;
    }
    imwrite(outputFilename, output_img);
    imshow("Segmentation", output_img);
    waitKey(0);

    return EXIT_SUCCESS;
}