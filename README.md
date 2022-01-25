# ical_events

ical_events is a programmer-friendly frontend for Ali Rantakari's amazing [icalBuddy](https://hasseg.org/icalBuddy/).

It converts the output from icalBuddy to JSON to help process your events as data.  It also supports original features like `--open-urls` and `eventsInMinutes:N` so you can open document links and meeting URLs included in currently occurring events or events that occur in 5 minutes.

ical_events tries to avoid opening multiple meeting URLs that typically occur in Google Calendar thanks to the default Google Meet links and Zoom for GSuite Add-On.  It also has configurable options like urls.ignore and urls.account.google/zoom so you can filter and alter URLs to open in a fine-grained manner.  See the example configuration file (use `--edit-config` below) for details.

## Usage

``` shellsession
% ical_events --edit-config
```

``` shellsession
% ical_events --open-urls eventsNow

% ical_events --open-urls eventsInMinutes:1
```

## Requirements

- macOS

- Ruby 3.0 or greater

    Sorry, but the ruby bundled with the OS/Developer Tools is too old to run this script.  Install Ruby 3.x via Homebrew.

    ``` shellsession
    % brew install ruby
    ```

- icalBuddy

    ``` shellsession
    % brew install ical-buddy
    ```

## Tip

To run this periodically from cron or launchd, create an Automator application that runs a shell script and call ical_events from there.  Run the application and grant it access to Calendars and Reminders, then you can use it in a periodic job using the open(1) command.

You may also need to manually give `/usr/sbin/cron` Full Disk Access and possibly access to Calendars and Reminders from the Privacy tab in the Security & Privacy Preference Pane.

## Author

Copyright (c) 2021-2022 Akinori MUSHA.

Licensed under the 2-clause BSD license.  See `LICENSE.txt` for
details.

Visit the [GitHub Repository](https://github.com/knu/ical_events)
for the latest information.
