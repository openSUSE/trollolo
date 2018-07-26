#!/usr/bin/env python
import yaml


class BurndownData:
  "Store burndown data parsed from YAML file"

  def __init__(self, args):
    self.args = args
    burndown = self.readYAML(self.args.sprint)
    self.getSprintData(burndown)
    self.setBonusTasksDayOne(burndown)
    self.setUnplannedTasksDayOne(burndown)
    self.setExtraDays()
    self.setUnplannedDays()
    self.calculateYRange(self.total_story_points[0], self.bonus_tasks_done, self.bonus_story_points_done, self.unplanned_tasks_done, self.unplanned_story_points_done)
    self.setScaleFactor(self.total_tasks[0], self.total_story_points[0])

  def readYAML(self, sprint_number):
    with open('burndown-data-' + sprint_number + '.yaml', 'r') as f:
      burndown = yaml.load(f)
    return burndown

  def getSprintData(self, burndown):
    self.sprint_number = burndown["meta"]["sprint"]
    self.weekend_lines = burndown["meta"]["weekend_lines"]
    self.total_days = burndown["meta"]["total_days"]
    self.extra_day = 0
    self.unplanned_day = 0
    self.current_day = 1
    self.days = []
    self.tasks_extra_days = []
    self.unplanned_tasks_days = []
    self.story_points_extra_days = []
    self.unplanned_story_points_days = []
    self.open_story_points = []
    self.total_story_points = []
    self.bonus_story_points_done = []
    self.total_unplanned_story_points = []
    self.unplanned_story_points_done = []
    self.open_tasks = []
    self.total_tasks = []
    self.bonus_tasks_done = []
    self.total_unplanned_tasks = []
    self.unplanned_tasks_done = []
    self.x_fast_lane = []
    self.y_fast_lane = []
    self.total_fast_lane = []
    self.total_unplanned_fast_lane = []

    for day in burndown["days"]:
      self.days.append(self.current_day)
      self.open_story_points.append(day["story_points"]["open"])
      self.total_story_points.append(day["story_points"]["total"])
      self.open_tasks.append(day["tasks"]["open"])
      self.total_tasks.append(day["tasks"]["total"])

      if "tasks_extra" in day:
        self.tasks_extra_days.append(self.current_day)
        tasks = -day["tasks_extra"]["done"]
        self.bonus_tasks_done.append(tasks)

      if "story_points_extra" in day:
        self.story_points_extra_days.append(self.current_day)
        points = -day["story_points_extra"]["done"]
        self.bonus_story_points_done.append(points)

      if "unplanned_tasks" in day:
        self.unplanned_tasks_days.append(self.current_day)
        tasks = day["unplanned_tasks"]["open"] - day["unplanned_tasks"]["total"]
        self.unplanned_tasks_done.append(tasks)
        self.total_unplanned_tasks.append(day["unplanned_tasks"]["total"])
      else:
        self.total_unplanned_tasks.append(0)

      if "unplanned_story_points" in day:
        self.unplanned_story_points_days.append(self.current_day)
        points = day["unplanned_story_points"]["open"] - day["unplanned_story_points"]["total"]
        self.unplanned_story_points_done.append(points)
        self.total_unplanned_story_points.append(day["unplanned_story_points"]["total"])
      else:
        self.total_unplanned_story_points.append(0)

      if day.has_key("fast_lane"):
        self.x_fast_lane.append(self.current_day)
        self.y_fast_lane.append(day["fast_lane"]["open"])
        self.total_fast_lane.append(day["fast_lane"]["total"])
        self.total_unplanned_fast_lane.append(0)

      self.current_day += 1
    return

  def setBonusTasksDayOne(self, burndown):
    if burndown["days"][0].has_key("tasks_extra"):
      self.bonus_tasks_day_one = burndown["days"][0]["tasks_extra"]["done"]
    else:
      self.bonus_tasks_day_one = 0
    return

  def setUnplannedTasksDayOne(self, burndown):
    if burndown["days"][0].has_key("unplanned_tasks"):
      self.unplanned_tasks_day_one = burndown["days"][0]["unplanned_tasks"]["total"] - burndown["days"][0]["unplanned_tasks"]["open"]
    else:
      self.unplanned_tasks_day_one = 0
    return

  def setExtraDays(self):
    if len(self.story_points_extra_days) > 0:
      self.story_points_extra_days = [self.story_points_extra_days[0] - 1] + self.story_points_extra_days
      self.bonus_story_points_done = [0] + self.bonus_story_points_done
    if len(self.tasks_extra_days) > 0:
      if not self.args.no_tasks and not self.bonus_tasks_day_one:
        self.tasks_extra_days = [self.tasks_extra_days[0] - 1] + self.tasks_extra_days
        self.bonus_tasks_done = [0] + self.bonus_tasks_done
      self.extra_day = 1
    return

  def setUnplannedDays(self):
    if len(self.unplanned_story_points_days) > 0:
      self.unplanned_story_points_days = [self.unplanned_story_points_days[0] - 1] + self.unplanned_story_points_days
      self.unplanned_story_points_done = [0] + self.unplanned_story_points_done
    if len(self.unplanned_tasks_days) > 0:
      if not self.args.no_tasks and not self.unplanned_tasks_day_one:
        self.unplanned_tasks_days = [self.unplanned_tasks_days[0] - 1] + self.unplanned_tasks_days
        self.unplanned_tasks_done = [0] + self.unplanned_tasks_done
      self.unplanned_day = 1
    return

  def calculateYRange(self, total_story_points, bonus_tasks_done, bonus_story_points_done, unplanned_tasks_done, unplanned_story_points_done):
    self.ymax = total_story_points + 3

    if len(bonus_tasks_done) > 0:
      ymin_bonus_tasks = min(bonus_tasks_done) -3
    else:
      ymin_bonus_tasks = 0

    if len(unplanned_tasks_done) > 0:
      ymin_unplanned_tasks = min(unplanned_tasks_done) -3
    else:
      ymin_unplanned_tasks = 0

    ymin_bonus_story_points = 0

    if len(bonus_story_points_done) > 0:
      ymin_bonus_story_points = min(bonus_story_points_done) -3

    ymin_unplanned_story_points = 0

    if len(unplanned_story_points_done) > 0:
      ymin_unplanned_story_points = min(unplanned_story_points_done) -3

    self.ymin = min(ymin_bonus_tasks, ymin_bonus_story_points, ymin_unplanned_tasks, ymin_unplanned_story_points)
    if self.ymin > -3:
      self.ymin = -3
    return

  def setScaleFactor(self, total_tasks, total_story_points):
    if total_story_points <= 0.001:
      self.scalefactor = 1
    else:
      self.scalefactor = float(total_tasks) / float(total_story_points)
    return

