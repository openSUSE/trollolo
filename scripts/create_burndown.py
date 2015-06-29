#!/usr/bin/env python
import matplotlib
import imp
try:
  imp.find_module('TkAgg')
  mac_backend_available = True
except ImportError:
  mac_backend_available = False

if mac_backend_available:
  matplotlib.use('TkAgg')

import matplotlib.pyplot as plt
import argparse
import os

import burndowndata
import plot
import graph


def parseCommandLine():
  epilog = "Look at https://github.com/openSUSE/trollolo for details"
  description = "Generates Scrum Burndown Chart from YAML file"

  parser = argparse.ArgumentParser(epilog=epilog, description=description)
  parser.add_argument('sprint', metavar='NUM', help='Sprint Number')
  parser.add_argument('--output', help='Location of data to process')
  parser.add_argument('--no-tasks', action='store_true', help='Disable Tasks line in the chart', default=False)
  parser.add_argument('--with-fast-lane', action='store_true', help='Draw line for Fast Lane cards', default=False)
  parser.add_argument('--verbose', action='store_true', help='Verbose Output', default=False)
  parser.add_argument('--no-head', action='store_true', help='Run in headless mode', default=False)
  args = parser.parse_args()

  if args.output:
    os.chdir(args.output)

  if args.verbose:
    print args

  return args



### MAIN ###

# parseCommandLine() needs to be called at the beginning to retrieve the
# command line parameters or provide help on these. It returns a dict
# containing the state of all parameters. Currently the following
# parameters are available:
#
# Mandatory parameters:
# NUM                The sprint number for which the burndown chart should be generated
#
# Optional parameters:
# --file             Specify the location of the YAML file containing the sprint data,
#                    if not provided, the YAML file is expected to be in the current
#                    working directory
#
# --no-tasks         Disable drawing the tasks graph in the chart
#
# --with-fast-lane   Enable drawing the graph for fast lane cards in the chart
#
# --no-head          Disable showing the graph, to be used for automation
#
# --verbose          Verbose output
#
args = parseCommandLine()

# Create burndown data object
data = burndowndata.BurndownData(args)

# Configure plot parameters
plot = plot.Plot(data)

title = "Sprint" + str(data.sprint_number)
title_fontsize = 'large'
plot.setTitle(title, title_fontsize)
plot.setXAxisLabel("Days")

plot.drawDiagonal("grey")
plot.drawWaterLine("blue", ":")
plot.drawWeekendLines("grey", ":")

# Plot all graphs
graph_story_points = graph.Graph(plot.storyPoints())

y_label = "Story Points"
color = "black"
marker = "o"
linestyle = "solid"
linewidth = 2

graph_story_points.draw(y_label, color, marker, linestyle, linewidth, plot)

if not args.no_tasks:
  graph_tasks = graph.Graph(plot.tasks())

  y_label = "Tasks"
  color = "green"

  graph_tasks.draw(y_label, color, marker, linestyle, linewidth, plot)

if args.with_fast_lane:
  graph_fast_lane = graph.Graph(plot.fastLane())

  y_label = "Fast Lane"
  color = "red"

  graph_fast_lane.draw(y_label, color, marker, linestyle, linewidth, plot)

# Save the burndown chart
plot.saveImage(args)

