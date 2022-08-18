## Example applications {#examples} 

We include the EoP2 application, a small example application, which is 
used to illustrate the capabilities of the CLOSURE toolchain for Java.

The application, when partitioned, creates a videoprocessing enclave that
processes video from a webcam or IP camera, transcodes it, and sends it to 
two webservers, from which browsers can receive the video.
Various filters can be applied to these
frames using OpenCV to modify the images. The two webpages operate on different
enclaves and permit different filters to alter the images sent to the web
clients. 

The quality of the frame received by the server depends on the level it is
operating at. In the example, the video server running at level orange can
receive higher fidelity frames. On the other hand, the video server running at
level green can only receive lower fidelity frames (e.g. lower resolution,
greyscale, etc.). The [diagram](#fig-EOP2) below illustrates the intra enclave
and inter enclave flows in the example application.

![Java Closure Workflow](docs/Java/images/VideoServerDiagram.png){#fig-EOP2}

