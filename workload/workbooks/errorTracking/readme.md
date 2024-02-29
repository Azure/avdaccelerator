# Azure Virtual Desktop Error Search

The purpose of this workbooks is to provide not only an overview of errors in your AVD environment. But also provide the ability to track down errors, all the way down to the Event logs from session hosts.

## Requirements

AVD Insights to be configured and collecting data to Log Analytics.

### Overview

The overview tab provides a high level summary of errors, error by region. Top 5 errors by, user, code symbolic, & hostpool. It also provides alerts related to subscriptions with AVD in them.

### User Performance

The user performance tab provides a look at the user experience. It has an options group parameter that allows you to view FSLogix profile sizes of the top users with the largest profiles. Slowest FSLogix Profile load times by Gateway Region, Hostpool and Users. RTT metrics for the slowest users and IP Segment. Finally slowest logon times by Gateway Region, Hostpools and Users.  

### Errors

The errors tab provides 3 experiences. Guided, Search and Event

#### Guided
 The first is guided. In this view the user is presented with summary count tiles by AVD Error Source. Then error counts by Hostpool and Gateway region. Each set tiles is clickable to control subsequent queries. Below them, is the top Users with errors by count and Session Hosts with errors by count. Both of these views are filterable based on the selection of above tiles. 

Each of these views also provides filtering to the logs beneath them. The logs view is a union of Event log with AVD diagnostic logs. Everything above this window controls what is seen in this view. 

#### Search

Search provides the ability to enter a username OR correlationId. Which will then provide high level information on the user, their average profile load and logon times. At the bottom will load either all AVD Activities for the user, if a username is supplied. Or all activities for the specific correlationId, if that was supplied.

#### Event

Event view provides optionally, the ability to supply a username or correlationID. If one of these is supplied the AVD filters will adjust. Or the user can set the AVD filters manually. Once set, this will generate a dynamic list of session hosts based on the supplied filters.

This dynamic list is then used to union all AVD Logs and Event logs for those session hosts in one view.