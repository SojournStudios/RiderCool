========
Overview and Description
========

>> RiderCool by Kristopher Kortright, June 2012 - Aug 2012 (o_o)
*>  This software is licensed via CERN Open Source Hardware License.
->  Must of this script was derived from tutorial code by Limor Fried 
->  and Adafruit Industries, and most of the credit goes to her and 
->  her company for providing such fantastic tutorials to the community!
->  Adafruit tutorials used can be found at http://learn.adafruit.com
->  My blog and projects can be found at http://sojournstudio.org/RiderCool

RiderCool has many purposes: 

1. Provide a technology platform for managing the pool with native XBee Network Protocol (XNP) support for sending data back for logging and to receive commands from a control router. 
2. To measure how full our pool is, and report that data back to my computer using my XBee Network Protocol (XNP) for logging and tracking (http://sojournstudio.org/xnp/)
3. To activate a solenoid/valve that is connected to a garden hose, which will fill the pool with water. 
4. To monitor, track and report-back the flow-rate of water going into the pool using an Adafruit flow-meter sensor (https://www.adafruit.com/products/828).
5. To monitor the temperature of the pool water, the ambient air, as well as ther CPU temp (https://www.adafruit.com/products/339), (https://www.adafruit.com/products/372)
6. To monitor a backup water-level sensor to ensure that the pool never over-flows.
7. To drive/control 4 RGB LED Strip controllers by Jeremy Saglimbeni; I have 40 meters of LED RGB Strip ringing-the pool. (http://thecustomgeek.com/2012/03/23/rgb ... r-ver-2-2/)
8. To displays the output of these sensors, LED status, etc on an Adafruit 1.8' TFT display for swimmers in the pool to see. (https://www.adafruit.com/products/358)
9. To provide button control resetting the system and controlling the RGB LED Strips using LED water-proof lights by Adafruit. (https://www.adafruit.com/products/482)
10. To teach me 3D printing - as this is my first 3D printing project with my MakerBot Replicator! (http://store.makerbot.com/replicator.html).
.
RiderCool was only possible because of the excellent products, tutorials and service that Limor Fried and her company Adafruit Industries provides to its customers, and I have become a dedicated fan over the 1.5 years I've been making. With this project I got to learn 3D printing and got some real use out of my years in Blender training. I also got to combine different products in a completely water-proof system. Now that it's done, of course, the summer is over and its nearly time to close the pool down. But building this helped me through alot of dark days this summer.
.
There are 4 modules (Otter Boxes) in the RiderCool system, each of which is documented below. I can only add 3 images to a post, so I'll reply to the post and add more content/images so I can show the creation pics as well as the final product when shown in action (Coming Soon!). The Power Module is a small-sized otter box with a laptop 12v/5A power supply and an adafruit 5V 2A power supply (https://www.adafruit.com/products/276) with the grounds tied-together.

The green power-button is actually not a power-button for the entire system, but rather a bypass power option that allows me to run the RGB LED Controllers by themselves without the Arduino Mega system controlling them (http://www.adafruit.com/products/916). 
.
The Interface Module combines an Adafruit 1.8' TFT display (http://www.adafruit.com/products/358) and several more water-proof buttons to allow users the ability to view the sensor stats and control the RGB LED strips while swimming in the pool.

Each of the 4 modules (otter boxes) are connected together using the new Adafruit waterproof power connectors (http://www.adafruit.com/products/743) and their new waterproof 4-wire connectors (http://www.adafruit.com/products/744). I love these things, and they came in very handy when the project grew beyond the size of one otter box! I plan to use them on most of my projects.

Lastly the RGB LED Controller module combines 4 of Jeremy's RGB LED controllers (http://thecustomgeek.com/2012/03/23/rgb ... r-ver-2-2/) in one large otter box, with the serial ports tied-together and fed into the Arduino for control. The switch allows me to use the strips manually (when combined with the green power button on the Power Module).

=========
Installation
=========
Simply install the RiderCoolNonXNP.pde script in your favorite arduino sketch directory, and load it as a project.
 
The sketch will compile cleanly on Arduino IDE v1.0.1 using the Arduino Mega 2560 as the board type.
 
You can follow-along with any changes I make here on GitHub, and make sure to check the Adafruit Forum post for RiderCool (http://forums.adafruit.com/viewtopic.php?f=25&t=32488) as that's where I will post lots of detail about the updates and answer any questions.
 
Cheers!
 
Kris Kortright