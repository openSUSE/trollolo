# Trollolo

[![Build Status](https://travis-ci.org/openSUSE/trollolo.svg?branch=master)](https://travis-ci.org/openSUSE/trollolo)

Command line tool to extract data from Trello, in particular for creating
burndown charts.

## Functionality

A detailed description of the functionality of the tool can be found in the
[man page](http://github.com/openSUSE/trollolo/blob/master/man/trollolo.1.md).

## Expectations

For expectations how the board has to be structured to make the burndown chart
functions work see the Trollolo man page. There is an
[example Trello board](https://trello.com/b/CRdddpdy/trollolo-testing-board)
which demonstrates the expected structure.

## Configuration

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
