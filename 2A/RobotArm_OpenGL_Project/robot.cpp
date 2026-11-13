#include <cstdlib>
#include <iostream>
#include <cmath>
#include <algorithm>

// for mac osx
#ifdef __APPLE__
#include <OpenGL/gl.h>
#include <OpenGL/glu.h>
#include <GLUT/glut.h>
#else
// only for windows
#ifdef _WIN32
#include <windows.h>
#endif
// for windows and linux
#include <GL/gl.h>
#include <GL/glu.h>
#include <GL/freeglut.h>

#endif

// Global variables to animate the robotic arm
float angle1 = 55.f;
float angle2 = 44.f;

// Global variables to rotate the arm as a whole
float robotAngleX = .0f;
float robotAngleY = .0f;

constexpr float angle_step = 5.f;
constexpr float joint_angle_max = 90.f;
constexpr float robot_angle_max = 360.f;

// Constant variables to define component sizes
constexpr float JOINT_WIDTH = 1.0f;
constexpr float JOINT_HEIGHT = 2.0f;
constexpr float JOINT_DEPTH = 1.0f;

constexpr float PINCERS_BASE_WIDTH = 1.0f;
constexpr float PINCERS_BASE_HEIGHT = .25f;
constexpr float PINCERS_BASE_DEPTH = .25f;

constexpr float PINCERS_WIDTH = .25f;
constexpr float PINCERS_HEIGHT = 1.0f;
constexpr float PINCERS_DEPTH = .25f;

// GLobal variables to close / open the pincers
constexpr float pincers_slide_step = PINCERS_BASE_WIDTH / 25;
constexpr float pincers_slide_max = PINCERS_BASE_WIDTH * 2;
constexpr float pincers_slide_min = PINCERS_WIDTH * 2;

float pincerSlideX = pincers_slide_max;

//Line width for the reference system
constexpr float LINE_WIDTH = 3.0f;

//bool value for wireframe switching
bool isWireframe = true;


/**
 * Function that draws the reference system (three lines along the x, y, z axis)
 */
void drawReferenceSystem()
{
    //**********************************
    // set the line width to 3.0
    //**********************************
    glLineWidth(LINE_WIDTH);

    //**********************************
    // Draw three lines along the x, y, z axis to represent the reference system
    // Use red for the x-axis, green for the y-axis and blue for the z-axis
    //**********************************
    glBegin(GL_LINES);
        glColor3f(1, 0, 0);
        glVertex3f(.0, .0, 0);
        glVertex3f(1, 0, 0);

        glColor3f(0, 1, 0);
        glVertex3f(.0, .0, 0);
        glVertex3f(0, 1, 0);

        glColor3f(0, 0, 1);
        glVertex3f(.0, .0, 0);
        glVertex3f(0, 0, 1);
    glEnd();

    //**********************************
    // reset the drawing color to white
    //**********************************
    glColor3f(1, 1, 1);

    //**********************************
    // reset the line width to 1.0
    //**********************************
    glLineWidth(1.0);

}


/**
 * Function that draws a single joint of the robotic arm
 */
void drawJoint()
{
    // first draw the reference system
    drawReferenceSystem();

    // Draw the joint as a parallelepiped (a cube scaled on the y-axis)
    glPushMatrix();
        glScalef(JOINT_WIDTH, JOINT_HEIGHT, JOINT_DEPTH);
            
        //**********************************
        // Bring the cube "up" so that the bottom face is on the xz plane
        //**********************************
        glTranslatef(0, JOINT_HEIGHT / 4, 0);

        //**********************************
        // draw the scaled cube. Remember that the scaling has to be only
        // on the local reference system, hence we need to get a local copy
        // of the modelview matrix...
        //***********************************    
        if (isWireframe)
        {
            glutWireCube(1);
        } else
        {
            glutSolidCube(1);
        }
    glPopMatrix();
}


/**
 * Function that draws the pincers'base
 */
void drawPincersBase()
{
   // Rectangle de slide
    glPushMatrix();
        glScalef(PINCERS_BASE_WIDTH, PINCERS_BASE_HEIGHT, PINCERS_BASE_DEPTH);

        glTranslatef(0., PINCERS_BASE_HEIGHT * 2, .0);

        if (isWireframe)
        {
            glutWireCube(1);
        } else
        {
            glutSolidCube(1);
        }
    glPopMatrix();
    
}


/**
 * Function that draws the actual pincers
 */
void drawPincers()
{
   // Rectangle de slide
    glPushMatrix();
        drawPincersBase();
        glPushMatrix();
            glScalef(PINCERS_WIDTH, PINCERS_HEIGHT, PINCERS_WIDTH);
            glTranslatef(-pincerSlideX,  PINCERS_HEIGHT / 2 + PINCERS_BASE_HEIGHT, .0);
            if (isWireframe)
            {
                glutWireCube(1);
            } else
            {
                glutSolidCube(1);
            }
        glPopMatrix();
        glPushMatrix();
            glScalef(PINCERS_WIDTH, PINCERS_HEIGHT, PINCERS_WIDTH);
            glTranslatef(pincerSlideX,  PINCERS_HEIGHT / 2  +PINCERS_BASE_HEIGHT, .0);
            if (isWireframe)
            {
                glutWireCube(1);
            } else
            {
                glutSolidCube(1);
            }
        glPopMatrix();
    glPopMatrix();
    
}


/**
 * Function that draws the robot as three parallelepipeds
 */
void drawRobot()
{
    //**********************************
    // we work on a copy of the current MODELVIEW matrix, hence we need to...
    //**********************************
    glPushMatrix();

    // draw the first joint
        drawJoint();

    // Draw the other joints: every joint must be placed on top of the previous one
    // and rotated according to the relevant Angle

    //**********************************
    // the second joint
    //**********************************
        glPushMatrix();
            glTranslatef(0, JOINT_HEIGHT, 0);
            glRotatef(angle1, 1, 0, 0);
            drawJoint();

    //**********************************
    // the third joint
    //**********************************
            glPushMatrix();
                glTranslatef(0, JOINT_HEIGHT, 0);
                glRotatef(angle2, 1, 0, 0);
                drawJoint();
                glPushMatrix();
                    glTranslatef(0, JOINT_HEIGHT, 0);
                    drawPincers();
                glPopMatrix();
            glPopMatrix();
        glPopMatrix();
    //**********************************
    // "Release" the copy of the current MODELVIEW matrix
    //**********************************
    glPopMatrix();

}


/**
 * Function that handles the display callback (drawing routine)
 */
void display()
{
    // clear the window
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT); //added depth buffer

    // working with the GL_MODELVIEW Matrix
    glMatrixMode(GL_MODELVIEW);

    //**********************************
    // we work on a copy of the current MODELVIEW matrix, hence we need to...
    //**********************************
    glPushMatrix();

    //**********************************
    // Rotate the robot around the x-axis and y-axis according to the relevant angles
    //**********************************
    glRotatef(robotAngleY, 0, 1, 0);
    glRotatef(robotAngleX, 1, 0, 0);

    // draw the robot
    drawRobot();

    //**********************************
    // "Release" the copy of the current MODELVIEW matrix
    //**********************************
    glPopMatrix();

    // flush drawing routines to the window
    glutSwapBuffers();
}


/**
 * Function that handles the special keys callback
 * @param[in] key the key that has been pressed
 * @param[in] x the mouse in window relative x-coordinate when the key was pressed
 * @param[in] y the mouse in window relative y-coordinate when the key was pressed
 */
void arrows(int key, int, int)
{
    //**********************************
    // Manage the update of RobotAngleX and RobotAngleY with the arrow keys
    //**********************************
    switch (key)
    {
    case GLUT_KEY_DOWN:
        if (robotAngleX > -robot_angle_max) {
            robotAngleX -= angle_step;
        }
        break;
    case GLUT_KEY_UP:
        if (robotAngleX < robot_angle_max) {
            robotAngleX += angle_step;
        }
        break;
    case GLUT_KEY_RIGHT:
        if (robotAngleY < robot_angle_max) {
            robotAngleY += angle_step;
        }
        break;
    case GLUT_KEY_LEFT:
        if (robotAngleY > -robot_angle_max) {
            robotAngleY -= angle_step;
        }
        break;
    default:
        break;
    }

    glutPostRedisplay();
}


/**
 * Function that handles the keyboard callback
 * @param key  the key that has been pressed
 * @param[in] x the mouse in window relative x-coordinate when the key was pressed
 * @param[in] y the mouse in window relative y-coordinate when the key was pressed
 */
void keyboard(unsigned char key, int, int)
{
    switch (key) {
        case 'q':
            exit(0);
            break;
        case 27:
            exit(0);
            break;
        case 'w':
            isWireframe = !isWireframe;
            break;
        //**********************************
        // Manage the update of Angle1 with the key 'a' and 'z'
        //**********************************
        case 'a':
            if (angle1 > -joint_angle_max) {
                angle1 -= angle_step;
            }
            break;
        case 'z':
            if (angle1 < joint_angle_max) {
                angle1 += angle_step;
            }
            break;
        case 'e':
            if (angle2 > -joint_angle_max) {
                angle2 -= angle_step;
            }
            break;
        case 'r':
            if (angle2 < joint_angle_max) {
                angle2 += angle_step;
            }
            break;
        case 'c':
            if (pincerSlideX > pincers_slide_min) {
                pincerSlideX -= pincers_slide_step;
            }
            break;
        case 'o':
            if (pincerSlideX < pincers_slide_max) {
                pincerSlideX += pincers_slide_step;
            }
            break;
        default:
            break;
    }

    glutPostRedisplay();
}


void init()
{
    glClearColor(0.f, 0.f, 0.f, 0.f);
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    gluPerspective(65.0, 1.0, 1.0, 100.0);

    glShadeModel(GL_FLAT);
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();

    // Place the camera
    gluLookAt(-5., 5., -5., .0, .0, 2., .0, 1., .0);

    // Test depth
    glEnable(GL_DEPTH_TEST);
}


/**
 * Function called every time the main window is resized
 * @param[in] width the new window width in pixels
 * @param[in] height the new window height in pixels
 */
void reshape(int width, int height)
{

    // define the viewport transformation;
    glViewport(0, 0, width, height);
    if (width < height)
        glViewport(0, (height - width) / 2, width, width);
    else
        glViewport((width - height) / 2, 0, height, height);
}


/**
 * Function that prints out how to use the keyboard
 */
void usage()
{
    std::cout << "\n*******\n";
    std::cout << "Arrows key: rotate the whole robot\n";
    std::cout << "[a][z] : move the second joint of the arm\n";
    std::cout << "[e][r] : move the third joint of the arm\n";
    std::cout << "[c][o] : close and open the pincers\n";
    
    std::cout << "[w] : switch between solid and wireframe view\n";
    std::cout << "[esc][q]  : terminate\n";
    std::cout << "*******\n";
}


int main(int argc, char **argv) {
    glutInit(&argc, argv);
    glutInitDisplayMode(GLUT_DOUBLE | GLUT_RGB | GLUT_DEPTH); //added GLUT DEPTH
    glutInitWindowSize(500, 500);
    glutInitWindowPosition(100, 100);
    glutCreateWindow(argv[0]);
    init();
    glutDisplayFunc(display);

    glutReshapeFunc(reshape);
    //**********************************
    // Register the keyboard function
    //**********************************
    glutKeyboardFunc(keyboard);

    //**********************************
    // Register the special key function
    //**********************************
    glutSpecialFunc(arrows);

    // just print the help
    usage();

    glutMainLoop();

    return EXIT_SUCCESS;
}


