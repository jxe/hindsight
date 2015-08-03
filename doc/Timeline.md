A *timeline* is a JSON object, matching the following schema, used to capture observed timelines (for instance the usage and notifications from an app over time) or desired timelines (for instance the desire to use something once a week for at most an hour).  Observed timelines may be precise (used this many seconds starting at these times on these days) or vague (used about two hours a week for six weeks).

It supports multiple "tracks" of timeline information, for attaching information about downloads/purchases/visits, the usage of other related apps/websites (for instance, when facebook newsfeed links out to an article), notification timing and frequency, and so on.

## Schema

At minimum it has a 'window' key and a 'tracks' key with at least one track.

'Window' is a two item array [t0, t1] with the unix timestamps from and to which the timeline is reported or desired. This is not the same as the date of the first event--for instance in a timeline in which a chrome extension tracks app usage, the window start would be the date in which the extension was installed, not the date in which you started to use the app.

'tracks' is a JSON object mapping track types to track descriptions.  Common track types:  Usage, Payments, Notifications, Downloads, Payoffs.

## Track description types

A track description describes the timeline of a particular kind of engagement.  There are several types:

### Regular

A "regularly" track describes regular usage, regular payments, etc.  Here is an example of a timeline reporting a regular usage:

```JSON
{
  window: [12093801283, 12093801283],
  tracks: {
    usage: {
      regularly: { seconds: 7200, every: 604800 }
    }
  }  
}
```

### Occurrences

An "occurrences" track describes events without duration, such as notifications or state transitions.  Here is a timeline where the payoff of using an app is described by occurrences:

```JSON
{
  window: [12093801283, 12093801283],
  tracks: {
    usage: {
      regular: { seconds: 7200, every: 604800 }
    },
    payoffs: {
      occurrences: { count: 1, 0: 12093801283 }
    }
  }  
}
```

### Samples

```JSON
{
  window: [12093801283, 12093801283],
  tracks: {
    desired: {
      latest: 12093801284,
      samples: { 12093801283: 0, 12093801284: 1 }
    }
  }  
}
```


### Bouts

A "bouts" track describes durational events, such as app usage episodes, video views, etc:

*TBD*
