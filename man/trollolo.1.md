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
    board. It is the cryptic part of the URL of the Trello board.

  * `--raw`:
    Some of the commands take a `raw` option. If this is provided the commands
    put out the raw JSON returned by the server instead of processing it to
    a more human-readable version.


## COMMANDS

### burndown-init -- Initialize burndown chart

`trollolo burndown-init --board-id=<board id> --output=<directory>`

Initialize the given directory for the generation of burndown charts. It stores
the given board id in the directory in a YAML file together with other
configuration data. The YAML file also is used to store the data for the
burndown charts. The `burndown` command can be used to update the file with
data from the specified Trello board.

The directory also gets a script to do the actual generation of the burndown
chart. Just run this script after each update of the data to get the latest
burndown chart.

### burndown -- Process data for burndown chart

`trollolo burndown --output=<directory>`

Update the burndown data in the given directory from the Trello board
specified in the YAML file in the directory. The given directory has to be
initialized before running the `burndown` command by running the
`burndown-init` command.

The actual generation of the burndown chart is done by running the script
which is put into the directory by the `burndown-init` command.

For correct generation of the burndown chart, the Trello board has to follow
a few convention. They are described in the section `CONVENTIONS for SCRUM
BOARDS`.

### fetch-burndown-data -- Read data for burndown chart

`trollolo fetch-burndown-data --board-id=<board id>`

Reads data from the specified Trello board, extracts it according to the
conventions for Scrum boards, and reports burndown data.

### get-cards -- Get card data for a board

Read all card data for a given board.

### get-checklists -- Get checklist data for a board

Read all checklist data for a given board

### get-lists -- Get list data for a board

Read all list data for a given board.


## EXAMPLES

Fetch burndown data of a Trello board configured in the configuration file:

`trollolo fetch-burndown-data --board-id=CRdddpdy`

Fetch raw data of all cards of a Trello board:

`trollolo get-cards --raw --board-id=CRdddpdy`


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


## CONVENTIONS FOR SCRUM BOARDS

The burndown functionality expects the board to follow a certain naming scheme,
so that Trollolo can process it as a Scrum board.

It expects a list `Sprint Backlog` with open items, a list `Doing` with items in
progress, and a list `Done Sprint X` with done items, where `X` is the number
of the sprint. For burndown data calculation the list with the highest number
is taken.

On work item cards the tool takes a bracketed number as suffix as size of the
item in story points. E.g. a card with the title `(3) Build magic tool` would
have three story points.

Cards under the waterline not part of the actual sprint commitment are expected
to have a label with the name "Under waterline".

An example for a board which follow this conventions is the [Trollolo Testing
Board](https://trello.com/b/CRdddpdy/trollolo-testing-board).

## COPYRIGHT

Trollolo is Copyright (C) 2013-2014 SUSE LLC
