#!/usr/bin/env python
import matplotlib.pyplot as plt


class Plot:
  "Set all parameters needed to print burndown charts"

  def __init__ (self, data):
    self.data = data
    figure_width = 11
    figure_height = 6

    self.plot_count = 0

    self.setXKCD()
    self.createFigure(figure_width, figure_height)
    self.setXAxisLimits(0, self.data.total_days+1)
    self.setXAxisTicks(self.data.total_days)

  def setXKCD(self):
    plt.xkcd()
    return

  def createFigure(self, width, height):
    self.fig = plt.figure(1, figsize=(width, height))
    return

  def setTitle(self, title, fontsize):
    plt.suptitle(str(title), fontsize=fontsize)
    return

  def setXAxisLabel(self, label):
    plt.xlabel(label)
    return

  def drawDiagonal(self, color):
    plt.plot([1, self.data.total_days], [self.data.total_story_points[0], 0], color=color)
    return

  def drawWaterLine(self, color, linestyle):
    plt.plot([0, self.data.total_days+1], [0, 0], color=color, linestyle=linestyle)
    return

  def drawWeekendLines(self, color, linestyle):
    for weekend_line in self.data.weekend_lines:
      plt.plot([weekend_line, weekend_line], [self.data.ymin+1, self.data.ymax-1], color=color, linestyle=linestyle)
    return

  def setXAxisLimits(self, x_min, x_max):
    plt.xlim([x_min, x_max])
    return

  def setXAxisTicks(self, total_days):
    x_labels = range(0, total_days)
    x_range = range(1, total_days + 1)
    plt.xticks(x_range, x_labels)
    return

  def saveImage(self, args):
    plt.savefig('burndown-' + args.sprint + '.png',bbox_inches='tight')
    if not args.no_head:
      plt.show()
    return

  def createSubplot(self):
    if self.plot_count == 0:
      self.first_subplot = plt.subplot()
      self.subplot = self.first_subplot
    else:
      self.subplot = self.first_subplot.twinx()
    return self.subplot

  def storyPoints(self):
    story_points = {}
    story_points['draw_tasks_diff'] = 0
    story_points['x'] = self.data.days
    story_points['y'] = self.data.open_story_points
    if self.data.extra_day:
      story_points['x_extra'] = self.data.story_points_extra_days
      story_points['y_extra'] = self.data.bonus_story_points_done
    story_points['total'] = self.data.total_story_points
    story_points['ymin'] = self.data.ymin
    story_points['ymax'] = self.data.ymax
    story_points['subplot'] = self.createSubplot()
    story_points['plot_count'] = self.plot_count
    self.plot_count += 1
    return story_points

  def tasks(self):
    tasks = {}
    tasks['draw_tasks_diff'] = 0
    tasks['x'] = self.data.days
    tasks['y'] = self.data.open_tasks
    if self.data.extra_day:
      tasks['x_extra'] = self.data.tasks_extra_days
      tasks['y_extra'] = self.data.bonus_tasks_done
    if self.data.bonus_tasks_day_one:
      tasks['draw_tasks_diff'] = 1
      tasks['x_arrow_start_end'] = self.data.days[0]
      tasks['y_arrow_start'] = self.data.total_story_points[0] * self.data.scalefactor - 0.5
      tasks['y_arrow_end'] = self.data.open_tasks[0] + 0.5
      tasks['y_arrow_start_bonus'] = 0
      tasks['y_arrow_end_bonus'] = 0.5 - self.data.bonus_tasks_day_one
      tasks['y_text'] = self.data.total_story_points[0] * self.data.scalefactor
      tasks['y_text_bonus'] = self.data.bonus_tasks_done[0] / 2
      tasks['bonus_tasks_day_one'] = self.data.bonus_tasks_day_one
    tasks['total'] = self.data.total_tasks
    tasks['ymin'] = self.data.ymin * self.data.scalefactor
    tasks['ymax'] = self.data.ymax * self.data.scalefactor
    tasks['subplot'] = self.createSubplot()
    tasks['plot_count'] = self.plot_count
    self.plot_count += 1
    return tasks

  def fastLane(self):
    fast_lane = {}
    fast_lane['draw_tasks_diff'] = 0
    fast_lane['x'] = self.data.x_fast_lane
    fast_lane['y'] = self.data.y_fast_lane
    fast_lane['ymin'] = self.data.ymin
    fast_lane['ymax'] = self.data.ymax
    fast_lane['total'] = self.data.total_fast_lane
    fast_lane['subplot'] = self.createSubplot()
    fast_lane['plot_count'] = self.plot_count
    self.plot_count += 1
    return fast_lane


