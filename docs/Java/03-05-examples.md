## Example applications **XXX: Rob** {#examples} 
 

### EoP2 Applications {#eop2}
The [EoP2 application] is a small application used to illustrate the JAVA CLOSURE capabilities. The application creates two servers that  send frames from a web camera or IP camera to two web pages. Various filters can be applied to these frames using OpenCV to modify the images. The two webpages operate on different enclaves and permit different filters. 

The quality of the frame received by the server depends on the level it is operating at. In the example, the video server running at level orange can receive higher fidelity frames. On the other hand, the video server running at level green can only receive lower fidelity frames (e.g. lower resolution, greyscale, etc.). The [diagram](#fig-EOP2) below illustrates the intra enclave and inter enclave flows in the example application.


![Java Closure Workflow](docs/Java/images/VideoServerDiagram.png){#fig-EOP2}
