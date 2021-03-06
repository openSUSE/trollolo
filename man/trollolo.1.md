# Trollolo -- Trello command line client

## SYNOPSIS

`trollolo` [command] [options]

`trollolo` help [command]


## DESCRIPTION

**Trollolo** is a command line client for Trello. It supports fetching lists
and cards and has functionality for extracting data for burndown charts.


## GENERAL OPTIONS

  * `--version`:
    Give out version of trollolo tool. Exit when done.

  * `--verbose`:
    Run in verbose mode.

  * `--board-id`:
    Most commands take a `board-id` parameter. This is the id of the Trello
    board. It is the cryptic part of the URL of the Trello board. Since the
    actual id is hard to remember, you can set an alias in the `.trollolorc`
    file and use that instead of the actual id.
    See [CONFIGURATION](#CONFIGURATION) section below.

  * `--raw`:
    Some of the commands take a `raw` option. If this is provided the commands
    put out the raw JSON returned by the server instead of processing it to
    a more human-readable version.


## COMMANDS

### help -- Display help

`trollolo help [COMMAND]`

Displays help about the available trollolo commands. Can take a command as
an argument to display detailed information about it.

### burndown init -- Initialize burndown chart

`trollolo burndown init --board-id=<board id> --output=<directory>`

Initialize the given directory for the generation of burndown charts. It stores
the given board id in the directory in a YAML file together with other
configuration data. The YAML file also is used to store the data for the
burndown charts. The `burndown update` command can be used to update the file with
data from the specified Trello board.

The directory also gets a script to do the actual generation of the burndown
chart. Just run this script after each update of the data to get the latest
burndown chart.

### burndown update -- Process data for burndown chart

`trollolo burndown update --output=<directory>`

Update the burndown data in the given directory from the Trello board
specified in the YAML file in the directory. The given directory has to be
initialized before running the `burndown update` command by running the
`burndown init` command.

The actual generation of the burndown chart is done by running the script
which is put into the directory by the `burndown init` command.

For correct generation of the burndown chart, the Trello board has to follow
a few convention. They are described in the section `CONVENTIONS for SCRUM
BOARDS`.

`trollolo burndown update --output=<output_directory> --location=<location_directory> --plot`

Update the burndown data in output_directory and plot the burndown chart for 
the data and save the file in location_directory.

### burndown multi-update -- Process data for multiple burndown charts at once

`trollolo burndown multi-update --board-list=<board list>`

Updates the burndown data for all boards specified in the YAML file in the
given directory. See the previous section for details on the update process.

### burndown plot -- Plot burndown chart

`trollolo burndown plot <sprint-number>`

Plot the burndown chart for given sprint. This command assumes that you are in
the burndown directory (initially created with `burndown init`) and that the
corresponding file `burndown-data-<sprint-number>.yaml` exists there.

### get boards -- Get boards for a member

`trollolo get boards --member-id=<member id>`

Get a list of all boards the given user is a member of.

### get cards -- Get card data for a board

`trollolo get cards --board-id=<board id>`

Read all card data for a given board.

### get checklists -- Get checklist data for a board

`trollolo get checklists --board-id=<board id>`

Read all checklist data for a given board

### get description -- Get description of a card

`trollolo get description --card-id=<card id>`

Read description of a given card.

### get lists -- Get list data for a board

`trollolo get lists --board-id=<board id>`

Read all list data for a given board.

### get members -- Get organization members

`trollolo get members --org-name=<org name>`

Read all members data for a given organization.

### get organization -- Get organization data

`trollolo get organization --org-name=<org name>`

Read organization info.

### get url -- Get raw JSON from Trello API

`trollolo get url <url fragment>`

Read raw JSON from Trello using the given URL fragment. Trollolo adds the server
part and API version as well as the credentials from the Trollolo configuration.

### backup create -- Create local copy of a board

`trollolo backup create --board-id=<board id>`

Save a local copy of a board as a JSON file. The backup will be stored in
'~/.trollolo/backup/<board-id>/'.

### backup list -- List all backups

`trollolo backup list`

Get a list of all local backups.

### backup show -- Show local backup

`trollolo backup show --board-id=<board id>`

Show the local backup of the given board.

### set cover -- Set picture as cover

`trollolo set cover <filename> --card-id=<card id>`

Make the given picture the cover for the given card. The given card must
be an attachment of the given card.

### set description -- Write description to a card

`trollolo set description --card-id=<card id>`

Write description to the given card. The description is read from STDIN, use
<^D> to end input.

### scrum init -- Setup Scrum boards

`trollolo scrum init`

Create boards, lists and labels with names configured in '~/.trollolorc' or
with the defaults.

### scrum start -- Move backlog from planning to sprint board

`trollolo scrum start --planning-board-id=<planning board id>
--sprint-board-id=<sprint board id>`

Move cards from the 'Backlog' list on the planning board to the 'Sprint
Backlog' list on the sprint board. This is generally done after the planning
meeting in preparation for a sprint.

### scrum end -- Move cards back to planning board

`trollolo scrum end --board-id=<board id> --target-board-id=<target board
id>`

Move unfinished cards from 'Sprint Backlog', 'Doing' and 'QA' lists on the sprint
board to the 'Ready' list on the planning board. This is generally done after the
sprint is finished.

### scrum prioritize -- Add priorities to card titles

`trollolo scrum prioritize --board-id=<board id>`

Add 'P<n>: ' to the beginning of every cards title in the 'Backlog' list,
replacing old values if present. 'n' is the current position of the card in the list.

### scrum backlog -- Show planning backlog of board

`trollolo scrum backlog --board-id=<board id>`

Shows planning backlog for a given board.


## EXAMPLES

Fetch raw data of all cards of a Trello board:

`trollolo get cards --raw --board-id=CRdddpdy`

Fetch raw JSON of a list:

`trollolo get url lists/53186e8391ef8671265eba9f/cards?filter=open`


## CONFIGURATION

Trollolo reads a configuration file `.trollolorc` in the home directory of the
user running the command line tool. It reads the data required to authenticate
with the Trello server from it. It's two values (the example shows random data):

```yaml
developer_public_key: 87349873487ef8732487234
member_token: 87345897238957a29835789b2374580927f3589072398579820345
```

These values have to be set with the personal access data for the Trello API
and the id of the board, which is processed.

For creating a developer key go to the
[Developer API Keys](https://trello.com/1/appKey/generate) page on Trello. It's
the key in the first box.

For creating a member token go follow the
[instructions](https://trello.com/docs/gettingstarted/index.html#getting-a-token-from-a-user)
in the Trello API documentation.

The board id is the cryptic string in the URL of your board.

The `.trollolorc` file can also be used to set aliases for board ids. When set,
you will be able to use the alias instead of the board-id in the various
commands. E.g.

With the following configuration

```
board_aliases:
  MyTrelloBoard: 53186e8391ef8671265ebf9e

```

You can issue the command:

```
  trollolo get cards --board-id=MyTrelloBoard
```


## CONVENTIONS FOR SCRUM BOARDS

The burndown functionality expects the board to follow a certain naming scheme,
so that Trollolo can process it as a Scrum board.

It expects a list `Sprint Backlog` with open items, a list `Doing` with items in
progress, and a list with a name starting with `Done`. If there are multiple
lists starting with `Done` the first one is taken.

Other names of columns with work in progress can be set in the YAML file in the
`meta` section as an array of column names under the key `doing_columns`.

On work item cards the tool takes a bracketed number as suffix as size of the
item in story points. E.g. a card with the title `(3) Build magic tool` would
have three story points.

Cards under the waterline not part of the actual sprint commitment are expected
to have a label with the name "Under waterline".

An example for a board which follow this conventions is the [Trollolo Testing
Board](https://trello.com/b/CRdddpdy/trollolo-testing-board).

## COPYRIGHT

Trollolo is Copyright (C) 2013-2015 SUSE LLC
