# Trollolo Changelog

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
