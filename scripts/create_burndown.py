#!/usr/bin/python
import matplotlib.pyplot as plt
import numpy as np
import sys
import yaml
import os

if len(sys.argv) < 2 or len(sys.argv) > 3:
  print "Usage: machinery-burndown.py <sprint-number> [working-dir]"
  sys.exit(1)

sprint = sys.argv[1]
if len(sys.argv) > 2:
  working_dir = sys.argv[2]
  os.chdir(working_dir)

with open('burndown-data-' + sprint + '.yaml', 'r') as f:
  burndown = yaml.load(f)

meta = burndown["meta"]

total_days = meta["total_days"]

current_day = 1
x_days = []
y_open_story_points = []
y_open_tasks = []
total_tasks = []
total_story_points = []
x_days_extra = []
x_day_extra_start = []
y_story_points_done_extra = [0]
y_tasks_done_extra = [0]

for day in burndown["days"]:
  x_days.append(current_day)
  y_open_story_points.append(day["story_points"]["open"])
  y_open_tasks.append(day["tasks"]["open"])
  total_tasks.append(day["tasks"]["total"])
  total_story_points.append(day["story_points"]["total"])

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

  current_day += 1

# Add a day at the beginning of the extra days, so the curve starts at zero
if x_days_extra:
  x_days_extra = [x_days_extra[0] - 1] + x_days_extra

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
plt.suptitle('Sprint ' + sprint, fontsize='large')

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
if x_days_extra:
  plt.plot(x_days_extra, y_story_points_done_extra, 'ko-', linewidth=2)

# Tasks
plt.twinx()
plt.ylabel('Tasks', color='green')
plt.tick_params(axis='y', colors='green')
plt.axis([0, total_days + 1, ymin*scalefactor, ymax * scalefactor])
plt.plot(x_days, y_open_tasks, 'go-', linewidth=2)
if x_days_extra:
  plt.plot(x_days_extra, y_tasks_done_extra, 'go-', linewidth=2)

# Calculation of new tasks
if len(total_tasks) > 1:
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

# Draw arrow showing already done tasks at begin of sprint
tasks_done = burndown["days"][0]["tasks"]["total"] - burndown["days"][0]["tasks"]["open"]

if tasks_done > 5:
  plt.annotate("", 
	       xy=(x_days[0], scalefactor * y_open_story_points[0] - 0.5 ), xycoords='data',
	       xytext=(x_days[0], y_open_tasks[0] + 0.5), textcoords='data',
	       arrowprops=dict(arrowstyle="<|-|>", connectionstyle="arc3", color='green')
	      )

  plt.text(0.7, y_open_story_points[0], str(tasks_done) + " tasks done",
	   rotation='vertical', verticalalignment='center', color='green'
	  )

# Save the burndown chart
plt.savefig('burndown-' + sprint + '.png',bbox_inches='tight')
plt.show()
