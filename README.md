el-tracker
==========

Simple command line application to track earned leave.

`el-tracker add --help`

`el-tracker use --help`

`el-tracker report --help`

You can set certain options in a configuration file in
`~/.el-tracker/config.yml`.

    ---
	global:
	 name: Randall Smith
     dsn: dbi:SQLite:dbname=/home/user/.el-tracker/el-tracker.sqlite3


