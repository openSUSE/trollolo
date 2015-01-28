#!/usr/bin/env python
import imp
import matplotlib
try:
  imp.find_module('TkAgg')
  mac_backend_available = True
except ImportError:
  mac_backend_available = False

if mac_backend_available:
  matplotlib.use('TkAgg')

import matplotlib.pyplot as plt
import numpy as np
import sys
import yaml
import argparse
import os

epilog = "Look at https://github.com/openSUSE/trollolo for details"
description = "Generates Scrum Burndown Chart from YML file"

parser = argparse.ArgumentParser(epilog=epilog, description=description)
parser.add_argument('sprint', metavar='NUM', help='Sprint Number')
parser.add_argument('--output', help='Location of data to process')
parser.add_argument('--no-tasks', action='store_true', help='Disable Tasks line in the chart', default=False)
parser.add_argument('--with-fast-lane', action='store_true', help='Draw line for Fast Lane cards', default=False)
parser.add_argument('--verbose', action='store_true', help='Verbose Output', default=False)
args = parser.parse_args()

if args.output:
  os.chdir(args.output)

if args.verbose:
  print args

if args.verbose:
  print args

with open('burndown-data-' + args.sprint + '.yaml', 'r') as f:
  burndown = yaml.load(f)

meta = burndown["meta"]
total_days = meta["total_days"]
current_day = 1
extra_day = 0
x_days = []
y_open_story_points = []
y_open_tasks = []
total_tasks = []
total_fast_lane = []
total_story_points = []
x_days_extra = []
y_story_points_done_extra = []
y_tasks_done_extra = []
x_fast_lane = []
y_fast_lane = []

for day in burndown["days"]:
  x_days.append(current_day)
  y_open_story_points.append(day["story_points"]["open"])
  y_open_tasks.append(day["tasks"]["open"])
  total_tasks.append(day["tasks"]["total"])
  total_story_points.append(day["story_points"]["total"])

  # TODO: refactor to not to draw 0 extra Story Points Line if one task
  # in extra card been done. Example http://imagebin.suse.de/1785/img
  if "story_points_extra" in day or "tasks_extra" in day:
    x_days_extra.append(current_day)
    tasks = 0
    if day.has_key("tasks_extra"):
      tasks = -day["tasks_extra"]["done"]
    y_tasks_done_extra.append(tasks)
    points = 0
    if day.has_key("story_points_extra"):
      points = -day["story_points_extra"]["done"]
    y_story_points_done_extra.append(points)

  if day.has_key("fast_lane"):
    x_fast_lane.append(current_day)
    y_fast_lane.append(day["fast_lane"]["open"])
    total_fast_lane.append(day["fast_lane"]["total"])

  current_day += 1

# Add a day at the beginning of the extra days, so the curve starts at zero
if x_days_extra and not burndown["days"][0].has_key("tasks_extra"):
  x_days_extra = [x_days_extra[0] - 1] + x_days_extra
  y_story_points_done_extra = [0] + y_story_points_done_extra
  y_tasks_done_extra = [0] + y_tasks_done_extra
  extra_day = 1

scalefactor = float(total_tasks[0]) / float(y_open_story_points[0])

# Calculate minimum and maximum 'y' values for the axis
ymin_t_extra = 0
ymin_s_extra = 0
ymax = y_open_story_points[0] + 3

if len(y_tasks_done_extra) > 0:
  ymin_t_extra = y_tasks_done_extra[len(y_tasks_done_extra) -1] -3
if len(y_story_points_done_extra) > 0:
  ymin_s_extra = y_story_points_done_extra[len(y_story_points_done_extra) -1] -3
if ymin_t_extra < ymin_s_extra:
  ymin = ymin_t_extra
else:
  ymin = ymin_s_extra
if ymin_t_extra == 0 and ymin_s_extra == 0:
  ymin = -3

# Plot in xkcd style
plt.xkcd()

plt.figure(1, figsize=(11, 6))

# Title of the burndown chart
plt.suptitle('Sprint ' + args.sprint, fontsize='large')

plt.xlabel('Days')
plt.axis([0, total_days + 1, ymin, ymax])
plt.plot([1, total_days] , [y_open_story_points[0], 0], color='grey')
plt.plot([0, total_days + 1], [0, 0], color='blue', linestyle=':')

# Weekend lines
for weekend_line in meta["weekend_lines"]:
  plt.plot([weekend_line, weekend_line], [ymin+1, ymax-1], color='grey', linestyle=':')

# Story points
plt.ylabel('Story Points', color='black')
plt.plot(x_days, y_open_story_points, 'ko-', linewidth=2)

if x_days_extra and extra_day == 0:
  del y_story_points_done_extra[0]

if len(x_days_extra) > 0:
  plt.plot(x_days_extra, y_story_points_done_extra, 'ko-', linewidth=2)

# Fast Lane
if args.with_fast_lane:
  plt.plot(x_fast_lane, y_fast_lane, 'go-', linewidth=1, color='red')

# Tasks
if not args.no_tasks:
  plt.twinx()
  plt.ylabel('Tasks', color='green')
  plt.tick_params(axis='y', colors='green')
  plt.axis([0, total_days + 1, ymin*scalefactor, ymax * scalefactor])
  plt.plot(x_days, y_open_tasks, 'go-', linewidth=2)
  if x_days_extra and extra_day == 0:
    del y_tasks_done_extra[0]
  if len(x_days_extra) > 0:
    plt.plot(x_days_extra, y_tasks_done_extra, 'go-', linewidth=2)

# Calculation of new tasks
if len(total_tasks) > 1 and not args.no_tasks:
  new_tasks = [0]
  for i in range(1, len(total_tasks)):
    new_tasks.append(total_tasks[i] - total_tasks[i - 1])
  effective_new_tasks_days = []
  effective_new_tasks = []
  for i in range(len(new_tasks)):
    if new_tasks[i] != 0:
      effective_new_tasks_days.append(i - 0.25 + 1)
      effective_new_tasks.append(new_tasks[i])
  if len(effective_new_tasks) > 0:
    plt.bar(effective_new_tasks_days, effective_new_tasks, .2, color='green')

# Calculation of new story points
if len(total_story_points) > 1:
  new_story_points = [0]
  for i in range(1, len(total_story_points)):
    new_story_points.append(total_story_points[i] - total_story_points[i - 1])
  effective_new_story_points_days = []
  effective_new_story_points = []
  for i in range(len(new_story_points)):
    if new_story_points[i] != 0:
      effective_new_story_points_days.append(i + 0.05 + 1)
      effective_new_story_points.append(new_story_points[i])
  if len(effective_new_story_points) > 0:
    plt.bar(effective_new_story_points_days, effective_new_story_points, .2, color='black')

# Calculation of new fast lane cards
if len(total_fast_lane) > 1 and args.with_fast_lane:
  new_fast_lane_cards = [0]
  for i in range(1, len(total_fast_lane)):
    new_fast_lane_cards.append(total_fast_lane[i] - total_fast_lane[i - 1])
  effective_new_fast_lane_days = []
  effective_new_fast_lane_cards = []
  for i in range(len(new_fast_lane_cards)):
    if new_fast_lane_cards[i] > 0:
      effective_new_fast_lane_days.append(i + 0.1 + 1)
      effective_new_fast_lane_cards.append(new_fast_lane_cards[i])
  if len(effective_new_fast_lane_cards) > 0:
    plt.bar(effective_new_fast_lane_days, effective_new_fast_lane_cards, .2, color='red')

# Draw arrow showing already done tasks at begin of sprint
tasks_done = burndown["days"][0]["tasks"]["total"] - burndown["days"][0]["tasks"]["open"]

if tasks_done > 5 and not args.no_tasks:
  plt.annotate("",
	       xy=(x_days[0], scalefactor * y_open_story_points[0] - 0.5 ), xycoords='data',
	       xytext=(x_days[0], y_open_tasks[0] + 0.5), textcoords='data',
	       arrowprops=dict(arrowstyle="<|-|>", connectionstyle="arc3", color='green')
	      )

  y_text = (scalefactor * y_open_story_points[0] + y_open_story_points[0]) / 2
  plt.text(0.7, y_text, str(int(tasks_done)) + " tasks done",
	   rotation='vertical', verticalalignment='center', color='green'
	  )

if burndown["days"][0].has_key("tasks_extra") and not args.no_tasks:
  tasks_done_extra = burndown["days"][0]["tasks_extra"]["done"]

  plt.annotate("",
	       xy=(x_days[0], scalefactor * y_story_points_done_extra[0] - 0.5 ), xycoords='data',
	       xytext=(x_days[0], 0.5 - tasks_done_extra), textcoords='data',
	       arrowprops=dict(arrowstyle="<|-|>", connectionstyle="arc3", color='green')
	      )

  y_text = - tasks_done_extra / 2
  plt.text(0.4, y_text, str(int(tasks_done_extra)) + " extra",
	   rotation='vertical', verticalalignment='center', color='green'
	  )
  plt.text(0.7, y_text, "tasks done",
	   rotation='vertical', verticalalignment='center', color='green'
	  )

# Save the burndown chart
plt.savefig('burndown-' + args.sprint + '.png',bbox_inches='tight')
plt.show()
