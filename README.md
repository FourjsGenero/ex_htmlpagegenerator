# ex_htmlpagegenerator
An example showing how the Genero Web Services engine can be used to generate and serve HTML pages

This is not a replacement for Genero Web Client, this is an alternative method

It is important to note that these pages generated are very plain.  It is upto you to then make them more visually appealing by using CSS etc.  What it does hopefully show is how you can use your existing 4gl routines to get the data you want to serve on the web page, present it in an HTML page, and serve it via the Genero Application Server.

A real-life example of this is seen by this URL ... https://harness.hrnz.co.nz/gas/ws/r/infohorsews/wsd06x?Arg=hrnzg-Ptype&Arg=HorseDetails&Arg=hrnzg-DoSearch&Arg=TRUE&Arg=hrnzg-HorseId&Arg=7077E826-C51E-49D5-BECC-93B46778DDE2 ... to bring up the details for a retired race horse.  Note the gas/ws/r in the URL :-)  They are using a technique whereby the 4gl routines are gathering the data from the database, they then use xslt to generate the html which is then served via the Genero Application Server.  If you look around that particular site, you will see numerous other pages generated in a similar manner.  (Drill down from here http://infohorse.hrnz.co.nz/datahr/fields/fields.htm.  To reduce load on the server, this first page and othere common pages are generated overnight by the same 4gl routines rather than being produced on-demand, but as you drill down you will eventually see gas/ws/r in the URL)  

Run ex_htmlpagegenerator_test.  This will start the following screen
<img alt="Start screen" src="https://user-images.githubusercontent.com/13615993/32222826-a80e75e6-be9f-11e7-95e9-19dd1ebc42a6.png" width="75%" />

Click the Start button to start the Web Services program in the background.

Click the various buttons to see the different technique utilised in the creation of a web page.

The final entry illulstrates an XSLT transformation.
<img alt="XSLT Example" src="https://user-images.githubusercontent.com/13615993/32222745-609b65de-be9f-11e7-9685-d2eaff7ecd64.png" width="75%" />
