#!/usr/bin/env python

class Graph:
  "Plot various graphs into burndown chart"

  def __init__ (self, graph_data):
    self.getGraphData(graph_data)

  def getGraphData(self, graph_data):
    self.x = graph_data['x']
    self.y = graph_data['y']
    self.xy_extra = 0
    self.xy_unplanned = 0
    self.ymin = graph_data['ymin']
    self.ymax = graph_data['ymax']
    self.total = graph_data['total']
    self.total_unplanned = graph_data['total_unplanned']
    self.plot_count = graph_data['plot_count']
    self.draw_tasks_diff = graph_data['draw_tasks_diff']
    self.draw_bonus_tasks_diff = graph_data['draw_bonus_tasks_diff']

    if 'x_extra' in graph_data:
      self.x_extra = graph_data['x_extra']
      self.y_extra = graph_data['y_extra']
      self.xy_extra = 1

    if 'x_unplanned' in graph_data:
      self.x_unplanned = graph_data['x_unplanned']
      self.y_unplanned = graph_data['y_unplanned']
      self.xy_unplanned = 1

    if self.draw_tasks_diff:
      self.x_arrow_start_end = graph_data['x_arrow_start_end']
      self.y_arrow_start = graph_data['y_arrow_start']
      self.y_arrow_end = graph_data['y_arrow_end']
      self.y_text = graph_data['y_text']

    if self.draw_bonus_tasks_diff:
      self.y_arrow_start_bonus = graph_data['y_arrow_start_bonus']
      self.y_arrow_end_bonus = graph_data['y_arrow_end_bonus']
      self.y_text_bonus = graph_data['y_text_bonus']
      self.bonus_tasks_day_one = graph_data['bonus_tasks_day_one']

    self.subplot = graph_data['subplot']
    return

  def draw(self, y_label, color, color_unplanned, marker, linestyle, linewidth, label, plot):
    self.plot = plot
    self.subplot.set_ylabel(y_label, color=color)
    self.subplot.set_ylim([self.ymin, self.ymax])

    if self.plot_count == 1:
      self.subplot.tick_params(axis='y', colors=color)

    if self.plot_count >= 2:
      self.subplot.tick_params(axis='y', colors=color)
      self.subplot.spines['right'].set_position(('axes', 1.15))
      self.plot.fig.subplots_adjust(right=0.8)

    self.subplot.plot(self.x, self.y, color=color, marker=marker, linestyle=linestyle, linewidth=linewidth)
    self.drawBonus(color, marker, linestyle, linewidth)
    self.drawUnplanned(color_unplanned, marker, linestyle, linewidth, label)
    self.drawBars(color, color_unplanned)
    if self.draw_tasks_diff:
      self.drawTasksDiff(color)
    if self.draw_bonus_tasks_diff:
      self.drawBonusTasksDiff(color)
    return

  def drawBonus(self, color, marker, linestyle, linewidth):
    if self.xy_extra and len(self.x_extra) > 0:
      self.subplot.plot(self.x_extra, self.y_extra, color=color, marker=marker, linestyle=linestyle, linewidth=linewidth)
    return

  def drawUnplanned(self, color_unplanned, marker, linestyle, linewidth, label):
    if self.xy_unplanned and len(self.x_unplanned) > 0:
      self.subplot.plot(self.x_unplanned, self.y_unplanned, color=color_unplanned, marker=marker, linestyle=linestyle, linewidth=linewidth, label=label)
    return

  def drawBars(self, color, color_unplanned):
    if len(self.total) > 1:
      width = 0.2
      offset = 0
      days = self.x
      days = [i+1 for i in days]

      if self.plot_count == 1:
        offset += width

      for i in range(len(days)):
        days[i] = days[i] - offset

      additional = []
      additional_unplanned = []

      for i in range(1, len(self.total)):
        additional.append(self.total[i] - self.total[i - 1])
        additional_unplanned.append(self.total_unplanned[i] - self.total_unplanned[i - 1])

      for i in range(len(additional)):
        if additional[i] != 0:
          self.subplot.bar(days[i], additional[i], width, color=color)
        if additional_unplanned[i] != 0:
          bottom = (0 if additional[i] < 0 else additional[i])
          self.subplot.bar(days[i], additional_unplanned[i], width, color=color_unplanned, bottom=bottom)
    return

  def drawTasksDiff(self, color):
    tasks_done = self.total[0] - self.y[0]

    if tasks_done > 0:
      self.subplot.annotate("",
        xy=(self.x_arrow_start_end, self.y_arrow_start), xycoords='data',
        xytext=(self.x_arrow_start_end, self.y_arrow_end), textcoords='data',
        arrowprops=dict(arrowstyle="<|-|>", connectionstyle="arc3", color=color)
      )

      self.subplot.text(0.7, self.y_text, str(int(tasks_done)) + " tasks done",
        rotation='vertical', verticalalignment='top', color=color
      )
    return

  def drawBonusTasksDiff(self, color):
    if self.bonus_tasks_day_one:
      self.subplot.annotate("",
        xy=(self.x_arrow_start_end, self.y_arrow_start_bonus), xycoords='data',
        xytext=(self.x_arrow_start_end, self.y_arrow_end_bonus), textcoords='data',
        arrowprops=dict(arrowstyle="<|-|>", connectionstyle="arc3", color=color)
      )

      self.subplot.text(0.4, self.y_text_bonus, str(int(-self.y_extra[0])) + " extra",
        rotation='vertical', verticalalignment='center', color=color
      )
      self.subplot.text(0.7, self.y_text_bonus, "tasks done",
        rotation='vertical', verticalalignment='center', color=color
      )
    return

