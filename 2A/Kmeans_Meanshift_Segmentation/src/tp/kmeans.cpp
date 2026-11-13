#include "ocv_utils.hpp"

#include "ourkmeans.cpp"
#include <opencv2/core.hpp>
#include <opencv2/imgcodecs.hpp>
#include <opencv2/highgui.hpp>
#include <opencv2/imgproc.hpp>
#include <opencv2/imgcodecs.hpp>
#include <iostream>
#include <string>

using namespace cv;
using namespace std;


int main(int argc, char** argv)
{
    // ============================================================================
    // CommandLineParser: How to handle command-line arguments
    // ============================================================================
    // When you run a program from the terminal, you can pass arguments to it.
    // For example: ./kmeans -i=cat.jpg -k=5 --gt=ground_truth.jpg
    //
    // The CommandLineParser helps us extract and validate these arguments.
    //
    // HOW THE "keys" STRING WORKS:
    // Each line in curly braces {} defines one parameter with this format:
    // "{name aliases | default_value | description}"
    //
    // - name: The primary name for the parameter (e.g., "input", "k")
    // - aliases: Short versions you can use instead (e.g., "i" for "input")
    // - default_value: What value to use if the user doesn't provide this parameter
    //   * <none> means the parameter is REQUIRED (program will fail without it)
    //   * Empty string means the parameter is OPTIONAL
    //   * Any other value is used as the default
    // - description: Help text shown when user runs the program with --help
    //
    // IMPORTANT: SYNTAX FOR PASSING VALUES
    // OpenCV's CommandLineParser requires an EQUALS SIGN (=) to pass values:
    // ✓ CORRECT:   -i=cat.jpg  or  --input=cat.jpg
    // ✗ WRONG:     -i cat.jpg  (this treats -i as a boolean flag, "cat.jpg" ignored)
    //
    // EXAMPLES OF HOW TO USE THIS PROGRAM:
    // ./kmeans -i=cat.jpg -k=5                          (required parameters only)
    // ./kmeans --input=cat.jpg -k=5 --gt=truth.jpg      (with optional groundtruth)
    // ./kmeans --help                                   (shows help message)
    //
    // RETRIEVING THE VALUES:
    // After defining the parameters, use parser.get<Type>("name") to retrieve them:
    // - parser.get<String>("input") gets the filename as a string
    // - parser.get<int>("k") gets the number of clusters as an integer
    //
    // HOW TO ADD A NEW PARAMETER (Example: number of iterations):
    // 1. Add a new line in the "keys" string:
    //    "{iterations iter  |100    | maximum number of iterations }"
    //    This creates an optional parameter with default value 100
    //
    // 2. Retrieve it after parser.check():
    //    const int iterations = parser.get<int>("iterations");
    //
    // 3. Use it in your program, for example when calling kmeans:
    //    kmeans(data, k, labels, TermCriteria(..., iterations, ...), ...);
    //
    // 4. Users can now run: ./kmeans -i=cat.jpg -k=5 --iterations=200
    //    Remember: use = to pass the value!
    //
    // Complete documentation can be found here
    // https://docs.opencv.org/4.6.0/d0/d2e/classcv_1_1CommandLineParser.html
    // ============================================================================

    const std::string keys =
        "{help h usage ?   |       | print this message   }"
        "{input i          |<none> | input image file     }"
        "{k                |<none> | number of clusters   }"
        "{groundtruth gt   |       | ground truth segmentation image (optional) }"
        "{version v        |       | kmeans implementation version}" // Nous permet de choisir la version implémentée et donc de les comparer manuellement
        "{output o         |       | output image file    }";

    CommandLineParser parser(argc, argv, keys);
    parser.about("K-means clustering application");

    if (parser.has("help"))
    {
        parser.printMessage();
        return EXIT_SUCCESS;
    }

    const string imageFilename = parser.get<string>("input");
    const int k = parser.get<int>("k");
    const string groundTruthFilename = parser.get<string>("groundtruth");
    const string version = parser.get<string>("version");
    string outputFilename = parser.get<string>("output");

    if (!parser.check())
    {
        parser.printErrors();
        return EXIT_FAILURE;
    }

    // just for debugging, show the parsed arguments
    {
        cout << "Program called with the following arguments:" << endl;
        cout << " \timage file: " << imageFilename << endl;
        cout << " \tk: " << k << endl;
        if(!groundTruthFilename.empty()) cout << " \tground truth segmentation: " << groundTruthFilename << endl;
        if(!version.empty()) cout << " \tversion: " << version << endl;
        if(outputFilename.empty()) {
            outputFilename = "../data/images/default_output.png";
        }
        cout << "\toutput image file: " << outputFilename + "\n" << endl;
    }

    // load the color image to process from file
    Mat m, gt, output_img;
    m = imread(imageFilename, IMREAD_COLOR);
    if(!groundTruthFilename.empty()) {
        gt = imread(groundTruthFilename, IMREAD_COLOR);
    }

    // for debugging use the macro PRINT_MAT_INFO to print the info about the matrix, like size and type
    PRINT_MAT_INFO(m);
    PRINT_MAT_INFO(gt);
    cout << "\n" << endl;

    // 1) to call kmeans we need to first convert the image into floats (CV_32F)
    // see the method Mat.convertTo()
    m.convertTo(m, CV_32F);
    if(!groundTruthFilename.empty()) {
        gt.convertTo(gt, CV_32F);
    }

    // 2) kmeans asks for a mono-dimensional list of "points". Our "points" are the pixels of the image that can be seen as 3D points
    // where each coordinate is one of the color channels (e.g. R, G, B). But they are organized as a 2D table, we need
    // to re-arrange them into a single vector.
    // see the method Mat.reshape(), it is similar to matlab's reshape function.
    int rows = m.rows;
    int cols = m.cols;
    int maxIter = 3;

    m = m.reshape(3, rows * cols);

    // now we can call kmeans(...)
    Mat labels;
    Mat centers;
    double compactness = 0;
    
    if(version == "0" || version.empty()) {
        compactness = kmeans(m, k, labels, TermCriteria(
        TermCriteria::EPS+TermCriteria::COUNT, 10, 1.0), 3, KMEANS_PP_CENTERS,
        centers);
    } else if(version == "1") {
        compactness = ourKmeans(m, k, labels, maxIter, centers);
    } else {
        cout << "Erreur: Implémentation de kmeans non existante." << endl;
        return EXIT_FAILURE;
    }
    output_img = Mat(rows, cols, CV_8UC3);
    
    int TP = 0, FP = 0, FN = 0, TN = 0;
    float P = 0.0f, S = 0.0f, DSC = 0.0f;
    
    for(int i = 0; i < rows * cols; i++) {
        //Indice du cluster
        int clusterIndex = labels.at<int>(i);
        
        int row = i / cols;
        int col = i % cols;
        
        //On définit la matrice de l'image de sortie
        output_img.at<Vec3b>(row, col) = Vec3b(
            static_cast<uchar>((1 - clusterIndex) * 255),
            static_cast<uchar>((1 - clusterIndex) * 255),
            static_cast<uchar>((1 - clusterIndex) * 255)
        );

        //eval A METTRE DANS UNE AUTRE FONCTION PROBABLEMENT
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

    if(!gt.empty()) {
        if (TP + FP > 0) P = (float)TP / ((float)TP + (float)FP);
        if (TP + FN > 0) S = (float)TP / ((float)TP + (float)FN);
        if (2 * TP + FP + FN > 0) DSC = 2.0f * (float)TP / (2 * (float)TP + (float)FP + (float)FN);
    }

    //Affichage
    cout << "Compactness: " << compactness << endl;
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