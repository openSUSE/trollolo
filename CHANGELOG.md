# Trollolo Changelog

## Master (unreleased)

* `burndown-init` only requires the `--board-id` option. The `--output` option
  is optional and defaults to the current working directory. Fix #103.
* Allow to define checklists that should not be parsed as task lists. Such lists
  can be added in the trollolorc as `no_task_checklists`.

## Version 0.1.1

* Fix the bug introduced whith always setting the burndown chart as the cover
  for `burndown --plot-to-board`, as it only worked with files in the current
  directory.

## Version 0.1.0

* Fix `plot-to-board` option in the burndown command when it is used together
  with `-o`.
* `burndown --plot-to-board` always sets the burndown chart as the cover.
  Fix #114.
* Allow to create and update an Sprint with a custom number. Fix #78.

## Version 0.0.14

* Add a new `plot-to-board` option to the burndown command to send the plotted
  burndown chart to the first card of the `Done` column.
* Add documentation for all CLI commands. Fixes #83.
* Allow to use `move-backlog` without waterline and seabed cards.
  Closes #106 and #107.
* Run `burndown` on `cleanup-sprint`. Fixes #68. 

## Version 0.0.12

* Find and remove 'Unplanned' labels on `cleanup-sprint`. Fixes #72.
* Fix `trollolo burndown-init` and `trollolo backup`.
* Remove Ruby 2.1 support. Closes #96.

## Version 0.0.11

* Add in `trollolo burndown --new-sprint` command the `total_days` and
  `weekend_lines` params. Closes #77.
* Change stdout output when running set-priorities to render the new priority
  instead of the old one. Fixes #72.

## Version 0.0.10

* Rename `sprint-cleanup` to `cleanup-sprint`.
* Configure board, list and label names to trollolorc. The commands
  `cleanup-sprint`, `move-backlog`, `set-priorities` and `setup-scrum` will use
  these names. You will still need to provide board IDs, or their aliases, as
  several boards can share the same name.
* Add `setup-scrum` command to create all necessary elements of our scrumb board
  as configured in trollolorc or using the defaults. A sample configuration can
  be found in `spec/data/trollolorc`. Fixes #57
* Add option for backlog list name in `set-priorities`.
* Add `move-backlog` command for moving a backlog from a planning to a sprint board
* Handle boards which have an "Accepted" column in addition to a "Done" column

## Version 0.0.9

* Add `sprint-cleanup` command to move cards back from the sprint board to the
  planning board. It takes all cards from the "Sprint backlog" and "Doing"
  columns on the sprint board, moves them to the "Ready" column on the planning
  board and removes all members and the "under the waterline" label.
* Add `set-priorities` command to add priorities to the title of all cards of a
  given column. The priorities are added as a prefix of the form "Pnn", where
  "nn" is the number of the card in the column. This is useful, if you use the
  order of cards as priorities and want to move them around to different columns
  without losing this information.
* Consistently use hyphens in command names, get rid of underscores.
* Fix calculation of unplanned tasks on day one
* Fix scaling tasks

## Version 0.0.8

* Burndown chart reflects unplanned work

  If unplanned work is added to the board during the sprint, separate graphs
  for the corresponding story points and tasks are drawn. For easier
  distinction, the additional graphs got different colors and are mentioned in
  the also newly added legend of the plot.

* Run integration tests of the image generation in Docker

## Version 0.0.7

* Add set-description command
* Add get-description command
* Add make-cover command to set an existing image as cover
* Add option to push burndown data to an API endpoint

## Version 0.0.6

* Track cards with unplanned work separately
* Fix error when parsing of meta data on card fails
* Implement `set-cover` command. This command uploads a picture to a given card,
  which is then set as cover.
* Fix raw output of cards list
* Fix commands to get basic data
* Don't overwrite data on first day of sprint

## Version 0.0.5

* Allow done columns which have a name stating with `Done` and do not insist on
  having a sprint number there. If multiple such columns are found, the first
  one is taken for burndown calculations.

## Version 0.0.4

* Allow to story points anywhere in the card name
* Read columns considered as not done from sprint yaml. This makes it possible
  to configure additional work in progress columns.
* Add `burndowns` command to update multiple charts at once
* Add option `--no-tasks` to not show tasks part of the graph
* Add option `--with-fast-lane` to separately plot cards which have a
  `Fast Lane` label.
* Store date and time when chart was updated
* Exclude checlists named "Feedback" from the tasks calculation
* Add commands to show organization data:
    * The command `organization` shows basic info about the organization.
    * The command `organization_members` lists all members.
* Add command to get raw JSON from Trello API
* Add handling of done tasks under the waterline at the beginning of a new
  sprint
* Add `--plot` option to `burndown` command to immediately show chart
* Add `--output` option to `plot` command to specify the directory it uses
* Save date and time of fetching burndown data
* Optionally fetch general meta data for burndown chart from special card
* Include list named "Blocked" in burndown calculation
* Implement basic backup function:
    * The command `backup` creates a backup of a board identified by its id
    * The command `show_backup` shows the content of the backup
    * The command `list_backups` shows the list of backups which have been made
    * The backups are stored to the directory `~/.trollolo/backups` in JSON
      format

## Version 0.0.3

* Document burndown generation work flow
* Show all weekend lines, not only the first two
* Use current working dir as default for burndown
* Allow for fractional story points, e.g. 0.5
* Add entry in man page for plot command
* Handle extra tasks and stories correctly
* Add command `plot` to plot directly from trollolo. This obsoletes the script,
  which is copied into the directory containing the data.
* Add option `--new-sprint` to `burndown` command to create a new sprint

## Version 0.0.2

* Initial release
