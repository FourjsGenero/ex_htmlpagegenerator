# ex_htmlpagegenerator
An example showing how the Genero Web Services engine can be used to generate and serve HTML pages

This is not a replacement for Genero Web Client, this is an alternative method

It is important to note that these pages generated are very plain.  It is upto you to then make them more visually appealing by using CSS etc.  What it does hopefully show is how you can use your existing 4gl routines to get the data you want to serve on the web page, present it in an HTML page, and serve it via the Genero Application Server.

A real-life example of this is seen by this URL ... http://harness.hrnz.co.nz/gas/ws/r/infohorsews/wsd06x?Arg=hrnzg-Ptype&Arg=HorseDetails&Arg=hrnzg-DoSearch&Arg=TRUE&Arg=hrnzg-HorseId&Arg=27168 ... to bring up the details for a retired race horse.  Note the gas/ws/r in the URL :-)  They are using a technique whereby the 4gl routines are gathering the data from the database, they then use xslt to generate the html which is then served via the Genero Application Server.  If you look around that particular site, you will see numerous other pages generated in a similar manner.  (Drill down from here http://infohorse.hrnz.co.nz/datahr/fields/fields.htm.  To reduce load on the server, this first page and othere common pages are generated overnight by the same 4gl routines rather than being produced on-demand, but as you drill down you will eventually see gas/ws/r in the URL)  
