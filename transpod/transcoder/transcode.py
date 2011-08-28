#!/usr/bin/env python

from __future__ import division

SAMPLES_PER_SECOND = 1.0/128.0

import math
import sys
import gobject
gobject.threads_init()
import pygst
pygst.require("0.10")
import gst, glib

mainloop = glib.MainLoop()

data_x = []
data_y = []
level = None


def log(*args):
    print "\n".join(args)


def parse_msg(bus, msg):
    #set the minimum decibels
    MIN_DB = -45
    #set the maximum decibels
    MAX_DB = 0
    #print msg
  #if current thread is running
    if True:
       #listen to messages that emit during playing
       messagePoll = msg
       struc = None
       #messagePoll = bus.poll(gst.MESSAGE_ANY,-1)
       #if the message is level

       if messagePoll.src == level:
            #get the structure of the message
            struc = messagePoll.structure
            #print struc
       #if the structure message is rms
       if struc and struc.has_key('rms'):
            #sys.stdout.write('.')
            #sys.stdout.flush()
            rms = struc["rms"]
            #get the values of rms in a list
            rms0 = abs(float(rms[0]))
            #compute for rms to decibels
            #print rms0
            #return
            rmsdb = 10 * math.log(rms0 / 32768 )
            #print rmsdb
            #compute for progress bar
            #print struc["stream-time"]
            vlrms = (rmsdb-MIN_DB) * 100 / (MAX_DB-MIN_DB)
            print vlrms
            #data_x.append(struc["stream-time"])
            #data_y.append(rms0)


def write_file():
    import math
    import cairo

    WIDTH, HEIGHT = 1200, 128 

    surface = cairo.ImageSurface (cairo.FORMAT_ARGB32, WIDTH, HEIGHT)
    ctx = cairo.Context (surface)

    ctx.scale (WIDTH, HEIGHT) # Normalizing the canvas
    ctx.rectangle(0, 0, 1, 1)
    ctx.set_source_rgb(0, 0, 0)
    ctx.fill()
    """
    pat = cairo.LinearGradient (0.0, 0.0, 0.0, 1.0)
    pat.add_color_stop_rgba (1, 0.7, 0, 0, 0.5) # First stop, 50% opacity
    pat.add_color_stop_rgba (0, 0.9, 0.7, 0.2, 1) # Last stop, 100% opacity
    """
    pat = cairo.LinearGradient (0.0, 0.0, 0.0, 1.0)
    pat.add_color_stop_rgba (1, 0.7, 0, 0, 0.5) # First stop, 50% opacity
    pat.add_color_stop_rgba (0, 0.9, 0.7, 0.2, 1) # Last stop, 100% opacity
    """
    ctx.rectangle (0, 0, 1, 1) # Rectangle(x0, y0, x1, y1)
    ctx.set_source (pat)
    ctx.fill ()
    """
    ctx.translate (1.0, 1.0) # Changing the current transformation matrix

    ctx.move_to (0, 0)
    ctx.line_to (0.2, 0.2)
    #ctx.arc (0.2, 0.1, 0.1, -math.pi/2, 0) # Arc(cx, cy, radius, start_angle, stop_angle)
    ctx.line_to (0.5, 0.1) # Line to (x,y)
    ctx.curve_to (0.5, 0.2, 0.5, 0.4, 0.2, 0.8) # Curve(x1, y1, x2, y2, x3, y3)
    ctx.close_path ()

    #ctx.set_source_rgb (0.3, 0.2, 0.5) # Solid color
    ctx.set_source(pat)
    ctx.set_line_width (0.02)
    ctx.fill ()

    surface.write_to_png ("/tmp/example.png") # Output to PNG

#write_file()
#udiaen

def on_eos(bus, msg):
    global pipeline
    pipeline.set_state(gst.STATE_NULL)
    log('on_eos')
    print("convert image")
    import matplotlib
    matplotlib.use( 'Agg' )
    import numpy as np
    import matplotlib.pyplot as plt
    import matplotlib.mlab as mlab

    import pylab
    fig = plt.figure()
    #ax = fig.add_subplot(111, axes=[])
    p = pylab.fill(data_x, data_y)
    #print p
    pylab.savefig("/tmp/test.png")
    fig
    fig.savefig("/tmp/bla.png")
    mainloop.quit()

def on_tag(bus, msg):
    taglist = msg.parse_tag()
    log('on_tag:')
    for key in taglist.keys():
      #log('\t%s = %s' % (key, taglist[key]))
      #FIXME
      pass

def on_error(bus, msg):
    error = msg.parse_error()
    log('on_error: %s' %error[1])

    mainloop.quit()
ADD = ""
if len(sys.argv) >= 3:
    print sys.argv[2]
    ADD = "t. ! queue ! audioconvert ! vorbisenc bitrate=128000 ! oggmux ! filesink name=ogg t. ! queue ! audioconvert ! lame bitrate=128 vbr=4 vbr-quality=7 ! filesink name=mp3"
print ADD
d = pipeline = gst.parse_launch("filesrc name=source ! decodebin2  ! tee name=t ! queue ! level name=level ! fakesink " + ADD)
source = d.get_by_name("source")
level = d.get_by_name("level")

if ADD:
    d.get_by_name("mp3").set_property("location", sys.argv[2] + ".mp3")
    d.get_by_name("ogg").set_property("location", sys.argv[2] + ".ogg")

globals()["level"] = level
#level.
bus = d.get_bus()
bus.add_signal_watch()
bus.connect("message", parse_msg)
bus.connect('message::eos', on_eos)
bus.connect('message::tag', on_tag)
bus.connect('message::error', on_error)
source.set_property("location", sys.argv[1])
level.set_property("interval", int(int(gst.SECOND) * SAMPLES_PER_SECOND))
d.set_state(gst.STATE_PLAYING)
d.get_state()
format = gst.Format(gst.FORMAT_TIME)
#duration = d.query_duration(format)[0]
#d.set_state(gst.STATE_NULL)

import datetime
#delta = datetime.timedelta(seconds=(duration / gst.SECOND))
#print delta

import glib
mainloop.run()
