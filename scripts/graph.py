#!/usr/bin/env python

class Graph:
  "Plot various graphs into burndown chart"

  def __init__ (self, graph_data):
    self.getGraphData(graph_data)

  def getGraphData(self, graph_data):
    self.x = graph_data['x']
    self.y = graph_data['y']
    self.xy_extra = 0
    self.ymin = graph_data['ymin']
    self.ymax = graph_data['ymax']
    self.total = graph_data['total']
    self.plot_count = graph_data['plot_count']
    self.draw_tasks_diff = graph_data['draw_tasks_diff']

    if 'x_extra' in graph_data:
      self.x_extra = graph_data['x_extra']
      self.y_extra = graph_data['y_extra']
      self.xy_extra = 1

    if self.draw_tasks_diff:
      self.x_arrow_start_end = graph_data['x_arrow_start_end']
      self.y_arrow_start = graph_data['y_arrow_start']
      self.y_arrow_end = graph_data['y_arrow_end']
      self.y_arrow_start_bonus = graph_data['y_arrow_start_bonus']
      self.y_arrow_end_bonus = graph_data['y_arrow_end_bonus']
      self.y_text = graph_data['y_text']
      self.y_text_bonus = graph_data['y_text_bonus']
      self.bonus_tasks_day_one = graph_data['bonus_tasks_day_one']

    self.subplot = graph_data['subplot']
    return

  def draw(self, y_label, color, marker, linestyle, linewidth, plot):
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
    self.drawBars(color)
    if self.draw_tasks_diff:
      self.drawTasksDiff(color)
      self.drawBonusTasksDiff(color)
    return

  def drawBonus(self, color, marker, linestyle, linewidth):
    if self.xy_extra and len(self.x_extra) > 0:
      self.subplot.plot(self.x_extra, self.y_extra, color=color, marker=marker, linestyle=linestyle, linewidth=linewidth)
    return

  def drawBars(self, color):
    if len(self.total) > 1:
      width = 0.2
      spacing = 0.1
      offset = (width + spacing) * self.plot_count + 0.1
      new = []
      for i in range(1, len(self.total)):
        new.append(self.total[i] - self.total[i - 1])
      additional_days = []
      additional = []
      for i in range(len(new)):
        if new[i] != 0:
          additional_days.append(i + 1 + offset)
          additional.append(new[i])
      if len(additional) > 0:
        self.subplot.bar(additional_days, additional, width, color=color)
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

